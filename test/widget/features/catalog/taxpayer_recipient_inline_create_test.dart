import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_inline_create.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

class MockSatCatalogRepository extends Mock implements SatCatalogRepository {}

const _user = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 15),
  ],
);

/// The customer form's "New" tax recipient: the full recipient form in a
/// dialog, returning what it created (046-catalog-improvements contracts C2).
void main() {
  late MockTaxpayerRecipientRepository repository;

  setUp(() => repository = MockTaxpayerRecipientRepository());

  /// Pumps a button that opens the dialog and records what it resolves to.
  Future<List<TaxpayerRecipientListItem?>> pumpOpener(
    WidgetTester tester,
  ) async {
    final results = <TaxpayerRecipientListItem?>[];
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          taxpayerRecipientRepositoryProvider.overrideWithValue(repository),
          satCatalogRepositoryProvider.overrideWithValue(
            MockSatCatalogRepository(),
          ),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(token: 't', user: _user),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                key: const Key('open'),
                onPressed: () async => results.add(
                  await showTaxpayerRecipientInlineCreateDialog(context),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('saving creates the recipient and returns it to the caller', (
    tester,
  ) async {
    when(
      () => repository.create(
        taxpayerRecipientId: 'XAXX010101000',
        email: 'acme@example.com',
        name: 'Acme Corp',
        postalCode: any(named: 'postalCode'),
        regime: any(named: 'regime'),
      ),
    ).thenAnswer(
      (_) async => const TaxpayerRecipient(
        taxpayerRecipientId: 'XAXX010101000',
        name: 'Acme Corp',
        email: 'acme@example.com',
      ),
    );
    final results = await pumpOpener(tester);

    await tester.enterText(
      find.byKey(const Key('taxpayer_recipient_id_field')),
      'XAXX010101000',
    );
    await tester.enterText(
      find.byKey(const Key('taxpayer_recipient_name_field')),
      'Acme Corp',
    );
    await tester.enterText(
      find.byKey(const Key('taxpayer_recipient_email_field')),
      'acme@example.com',
    );
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(results.single?.taxpayerRecipientId, 'XAXX010101000');
    expect(results.single?.name, 'Acme Corp');
  });

  testWidgets('dismissing the dialog returns null and creates nothing', (
    tester,
  ) async {
    final results = await pumpOpener(tester);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(results, [null]);
    verifyNever(
      () => repository.create(
        taxpayerRecipientId: any(named: 'taxpayerRecipientId'),
        email: any(named: 'email'),
        name: any(named: 'name'),
        postalCode: any(named: 'postalCode'),
        regime: any(named: 'regime'),
      ),
    );
  });
}
