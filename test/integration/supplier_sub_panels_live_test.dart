import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' show BankAccountsApi;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/bank_account_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';

/// Live round trip for spec 050's supplier sub-panels (research R13) against
/// a *real* mbe-api instance (constitution §VII): bank account + supplier
/// linked to an address, a contact and that account, then agreements, the
/// 409 on deleting a still-linked supplier, unlink and delete.
///
/// Operates at the repository layer like `crud_panel_flow_test.dart`. The
/// address and contact are discovered at runtime, never hard-coded; the test
/// is skipped (not failed) when the tenant has none.
///
/// Requires mbe-api at [apiBaseUrl] (default `http://127.0.0.1:8000`, or
/// `--dart-define=API_BASE_URL=...`) and an administrator account:
///   --dart-define=MBE_CATALOG_TEST_USERNAME=...
///   --dart-define=MBE_CATALOG_TEST_PASSWORD=...
///
/// Skipped entirely when credentials aren't provided — it creates and
/// deletes real records.
const _username = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');

const _canRun = _username != '' && _password != '';

void main() {
  late Dio dio;
  late SupplierRepositoryImpl supplierRepo;
  int? supplierId;
  int? agreementId;
  int? bankAccountId;

  tearDown(() async {
    // Best-effort cleanup, in dependency order. Failures are swallowed so a
    // test failure is never masked by a cleanup error.
    if (!_canRun) return;
    final sid = supplierId;
    if (sid != null) {
      try {
        if (agreementId != null) {
          await supplierRepo.deleteAgreement(
            supplierId: sid,
            agreementId: agreementId!,
          );
        }
      } catch (_) {}
      try {
        await supplierRepo.update(
          supplierId: sid,
          addressIds: const [],
          contactIds: const [],
          bankAccountIds: const [],
        );
        await supplierRepo.delete(supplierId: sid);
      } catch (_) {}
    }
    final bid = bankAccountId;
    if (bid != null) {
      // BankAccountRepository deliberately has no delete (bank accounts have
      // no screens), so cleanup calls the generated API directly.
      try {
        await BankAccountsApi(
          dio,
          appSerializers,
        ).deleteBankAccountApiV1BankAccountsBankAccountIdDelete(
          bankAccountId: bid,
        );
      } catch (_) {}
    }
    supplierId = null;
    agreementId = null;
    bankAccountId = null;
  });

  test(
    'Supplier sub-panels: links, agreements, 409 while linked, unlink, delete',
    () async {
      dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';
      supplierRepo = SupplierRepositoryImpl(dio);
      final bankRepo = BankAccountRepositoryImpl(dio);
      final addressRepo = AddressRepositoryImpl(dio);
      final contactRepo = ContactRepositoryImpl(dio);
      final suffix = DateTime.now().millisecondsSinceEpoch;

      // 1. Runtime-discovered fixtures.
      final addresses = await addressRepo.list(
        status: EntityStatus.active,
        limit: 1,
      );
      final contacts = await contactRepo.list(limit: 1);
      if (addresses.items.isEmpty || contacts.isEmpty) {
        markTestSkipped(
          'Tenant has no active address or no contact to link; '
          'cannot exercise supplier links.',
        );
        return;
      }
      final addressId = addresses.items.first.addressId;
      final contactId = contacts.first.contactId;

      // 2. Bank account with unique values.
      final bank = await bankRepo.create(
        bankName: 'Test 050 $suffix',
        accountNumber: '$suffix',
      );
      bankAccountId = bank.bankAccountId;

      // 3. Supplier linked to all three.
      final created = await supplierRepo.create(
        code: 'S50-${suffix % 100000000}',
        name: 'IntegrationTest-$suffix',
        addressIds: [addressId],
        contactIds: [contactId],
        bankAccountIds: [bank.bankAccountId],
      );
      supplierId = created.supplierId;

      // 4. Detail has exactly those links.
      final fetched = await supplierRepo.get(supplierId: created.supplierId);
      expect(fetched.addresses.map((a) => a.addressId), [addressId]);
      expect(fetched.contacts.map((c) => c.contactId), [contactId]);
      expect(fetched.bankAccounts.map((b) => b.bankAccountId), [
        bank.bankAccountId,
      ]);

      // 5. Agreements: create, update (end + clear comment), delete.
      final start = DateTime(2030, 1, 1);
      final agreement = await supplierRepo.createAgreement(
        supplierId: created.supplierId,
        start: start,
        end: DateTime(2030, 6, 30),
        comment: 'first',
      );
      agreementId = agreement.supplierAgreementId;
      var agreements = await supplierRepo.listAgreements(
        supplierId: created.supplierId,
      );
      expect(agreements, hasLength(1));
      expect(agreements.single.supplierAgreementId, agreementId);
      expect(agreements.single.end, DateTime(2030, 6, 30));
      expect(agreements.single.comment, 'first');

      await supplierRepo.updateAgreement(
        supplierId: created.supplierId,
        agreementId: agreementId!,
        start: start,
        end: DateTime(2030, 12, 31),
        comment: '',
      );
      agreements = await supplierRepo.listAgreements(
        supplierId: created.supplierId,
      );
      expect(agreements, hasLength(1));
      expect(agreements.single.end, DateTime(2030, 12, 31));
      expect(agreements.single.comment ?? '', isEmpty);

      await supplierRepo.deleteAgreement(
        supplierId: created.supplierId,
        agreementId: agreementId!,
      );
      agreementId = null;
      expect(
        await supplierRepo.listAgreements(supplierId: created.supplierId),
        isEmpty,
      );

      // 6. Delete is refused while links exist.
      await expectLater(
        supplierRepo.delete(supplierId: created.supplierId),
        throwsA(
          isA<ServerError>().having((e) => e.statusCode, 'statusCode', 409),
        ),
      );

      // 7. Unlink everything, then delete succeeds.
      await supplierRepo.update(
        supplierId: created.supplierId,
        addressIds: const [],
        contactIds: const [],
        bankAccountIds: const [],
      );
      final unlinked = await supplierRepo.get(supplierId: created.supplierId);
      expect(unlinked.addresses, isEmpty);
      expect(unlinked.contacts, isEmpty);
      expect(unlinked.bankAccounts, isEmpty);

      await supplierRepo.delete(supplierId: created.supplierId);
      supplierId = null;
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
