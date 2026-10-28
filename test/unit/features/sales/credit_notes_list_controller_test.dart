import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/repositories/credit_note_repository.dart';
import 'package:mbe_ui/features/sales/presentation/credit_notes/credit_notes_filter.dart';
import 'package:mbe_ui/features/sales/presentation/credit_notes/credit_notes_list_controller.dart';

class MockCreditNoteRepository extends Mock implements CreditNoteRepository {}

CreditNote _note(int id, {String remaining = '10.00', int customer = 7}) =>
    CreditNote(
      id: id,
      customerId: customer,
      salesOrderId: 3000 + id,
      customerRefundId: 4000 + id,
      customerPaymentId: 5000 + id,
      issued: remaining,
      remaining: remaining,
      date: DateTime(2026, 9, 1).add(Duration(hours: id)),
    );

AccessControlService _access({bool creditRead = true}) => AccessControlService(
  AuthState.authenticated(
    token: 't',
    user: User(
      userId: 'c',
      email: 'c@example.com',
      administrator: false,
      status: EntityStatus.active,
      sessionVersion: 1,
      privileges: [
        if (creditRead)
          const Privilege(
            systemObject: SystemObject.creditPayments,
            rawValue: 2,
          ),
      ],
    ),
  ),
);

void main() {
  late MockCreditNoteRepository repository;

  setUp(() => repository = MockCreditNoteRepository());

  ProviderContainer containerFor({bool creditRead = true}) {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        creditNoteRepositoryProvider.overrideWithValue(repository),
        accessControlProvider.overrideWithValue(
          _access(creditRead: creditRead),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// A fake server holding [notes] (newest first, as the real one orders
  /// them) that honours `customer`, `open_only`, `skip` and `limit`, and counts
  /// in `total` only what its filters keep — mbe-api spec 034 FR-007.
  void serve(List<CreditNote> notes) {
    when(
      () => repository.list(
        customerId: any(named: 'customerId'),
        openOnly: any(named: 'openOnly'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((invocation) async {
      final customerId = invocation.namedArguments[#customerId] as int?;
      final openOnly = invocation.namedArguments[#openOnly] as bool;
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final all = [
        for (final n in notes)
          if ((customerId == null || n.customerId == customerId) &&
              (!openOnly || n.isOpen))
            n,
      ];
      final end = (skip + limit).clamp(0, all.length);
      return CreditNoteListResult(
        items: skip >= all.length ? const [] : all.sublist(skip, end),
        total: all.length,
      );
    });
  }

  group('the switch off — every note (FR-010)', () {
    test('asks for the first page and reports the server\'s total', () async {
      serve([for (var i = 50; i >= 1; i--) _note(i)]);

      final page = await containerFor().read(
        creditNotesListControllerProvider(const CreditNotesFilter()).future,
      );

      expect(page.items, hasLength(20));
      expect(page.total, 50);
      expect(page.pageIndex, 0);
      verify(
        () => repository.list(
          customerId: null,
          openOnly: false,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    test('page 3 skips 40 and forwards the customer', () async {
      serve([for (var i = 50; i >= 1; i--) _note(i)]);

      final page = await containerFor().read(
        creditNotesListControllerProvider(
          const CreditNotesFilter(customerId: 7, pageIndex: 2),
        ).future,
      );

      expect(page.items, hasLength(10));
      verify(
        () => repository.list(
          customerId: 7,
          openOnly: false,
          skip: 40,
          limit: 20,
        ),
      ).called(1);
    });

    test('keeps notes with nothing left — it filters nothing', () async {
      serve([_note(2, remaining: '0'), _note(1)]);

      final page = await containerFor().read(
        creditNotesListControllerProvider(const CreditNotesFilter()).future,
      );

      expect(page.items.map((n) => n.id), [2, 1]);
    });
  });

  group('the switch on — the server filters (FR-011, mbe-api spec 034)', () {
    test('asks for open notes and pages on the server\'s own count', () async {
      serve([
        for (var i = 250; i >= 1; i--) _note(i, remaining: i <= 25 ? '5' : '0'),
      ]);

      final page = await containerFor().read(
        creditNotesListControllerProvider(
          const CreditNotesFilter(openOnly: true),
        ).future,
      );

      expect(page.items, hasLength(20));
      expect(page.items.first.id, 25);
      expect(page.total, 25);
      verify(
        () => repository.list(
          customerId: null,
          openOnly: true,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    test('forwards the customer and the page', () async {
      serve([for (var i = 50; i >= 1; i--) _note(i)]);

      final page = await containerFor().read(
        creditNotesListControllerProvider(
          const CreditNotesFilter(customerId: 7, openOnly: true, pageIndex: 2),
        ).future,
      );

      expect(page.items, hasLength(10));
      verify(
        () =>
            repository.list(customerId: 7, openOnly: true, skip: 40, limit: 20),
      ).called(1);
    });

    test('no open notes is an empty page, not an error', () async {
      serve([_note(2, remaining: '0'), _note(1, remaining: '0.000000')]);

      final page = await containerFor().read(
        creditNotesListControllerProvider(
          const CreditNotesFilter(openOnly: true),
        ).future,
      );

      expect(page.items, isEmpty);
      expect(page.total, 0);
    });
  });

  test('without credit-payments read: an empty page and no request', () async {
    serve([_note(1)]);

    final page = await containerFor(
      creditRead: false,
    ).read(creditNotesListControllerProvider(const CreditNotesFilter()).future);

    expect(page.items, isEmpty);
    expect(page.total, 0);
    verifyNever(
      () => repository.list(
        customerId: any(named: 'customerId'),
        openOnly: any(named: 'openOnly'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    );
  });
}
