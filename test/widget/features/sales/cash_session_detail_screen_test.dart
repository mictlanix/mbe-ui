import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/sales/presentation/cash_session_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

const _canCloseUser = User(
  userId: 'supervisor',
  email: 'supervisor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.cashSessionClose, rawValue: 4)],
);

const _cannotCloseUser = User(
  userId: 'cashier',
  email: 'cashier@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

/// Reads the point of sale (so may view a cash cut) but cannot close sessions.
const _cutReaderUser = User(
  userId: 'auditor',
  email: 'auditor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pos, rawValue: 2)],
);

/// Can close a session and view its cut.
const _closerAndCutReaderUser = User(
  userId: 'supervisor-pos',
  email: 'supervisor-pos@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.cashSessionClose, rawValue: 4),
    Privilege(systemObject: SystemObject.pos, rawValue: 2),
  ],
);

CashSession _openSession() => CashSession(
  cashSessionId: 1,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime.now(),
  openingAmount: '500',
  paymentsByMethod: const [PaymentMethodTotal(method: 1, total: '3240')],
);

CashSession _closedSession({int id = 2}) => CashSession(
  cashSessionId: id,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 4, 9),
  end: DateTime(2026, 8, 4, 18),
  cashSupervisorId: 200,
  cashSupervisorName: 'Luis Reyes',
  openingAmount: '500',
);

void main() {
  late MockCashSessionRepository repository;

  setUp(() {
    repository = MockCashSessionRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User user,
    required CashSession session,
    List<Override> overrides = const [],
  }) async {
    when(
      () => repository.get(cashSessionId: session.cashSessionId),
    ).thenAnswer((_) async => session);

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        cashSessionRepositoryProvider.overrideWithValue(repository),
        accessControlProvider.overrideWithValue(
          AccessControlService(AuthState.authenticated(token: 't', user: user)),
        ),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CashSessionDetailScreen(cashSessionId: session.cashSessionId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CashSessionDetailScreen — summary (US2)', () {
    testWidgets('shows drawer, cashier, opening amount and per-method '
        'payments for an open session', (tester) async {
      await pumpScreen(tester, user: _canCloseUser, session: _openSession());

      expect(find.text('Caja 1'), findsWidgets);
      expect(find.text('Ana López'), findsOneWidget);
      expect(find.byKey(const Key('cash_session_status_chip_open')), findsOneWidget);
      expect(find.textContaining('3,240'), findsOneWidget);
    });

    testWidgets('a closed session shows who closed it and no count/close '
        'region at all', (tester) async {
      await pumpScreen(tester, user: _canCloseUser, session: _closedSession());

      expect(find.text('Luis Reyes'), findsOneWidget);
      expect(find.byKey(const Key('cash_session_status_chip_closed')), findsOneWidget);
      expect(find.byKey(const Key('cash_session_close_button')), findsNothing);
      expect(
        find.byKey(const Key('cash_session_denomination_field_500')),
        findsNothing,
      );
    });
  });

  group('CashSessionDetailScreen — close region gating (US2)', () {
    testWidgets(
      'an open session with cashSessionClose:update shows the count table '
      'and Close button',
      (tester) async {
        await pumpScreen(tester, user: _canCloseUser, session: _openSession());

        expect(
          find.byKey(const Key('cash_session_denomination_field_500')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('cash_session_close_button')), findsOneWidget);
      },
    );

    testWidgets(
      'an open session without cashSessionClose:update shows the '
      'supervisor-required message instead — absent, not disabled (FR-025)',
      (tester) async {
        await pumpScreen(tester, user: _cannotCloseUser, session: _openSession());

        expect(
          find.byKey(const Key('cash_session_supervisor_required_message')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('cash_session_close_button')), findsNothing);
        expect(
          find.byKey(const Key('cash_session_denomination_field_500')),
          findsNothing,
        );
      },
    );
  });

  group('CashSessionDetailScreen — counting (US2)', () {
    testWidgets('entering a quantity updates the counted total and '
        'difference live', (tester) async {
      await pumpScreen(tester, user: _canCloseUser, session: _openSession());

      await tester.enterText(
        find.byKey(const Key('cash_session_denomination_field_500')),
        '3',
      );
      await tester.pump();

      // 500*3 = 1500 counted; expected 500 (opening) + 3240 (cash) = 3740.
      expect(find.textContaining('1,500'), findsWidgets);
    });

    testWidgets('a non-zero difference does not block Close — no dialog, '
        'submits immediately (FR-019)', (tester) async {
      when(
        () => repository.close(cashSessionId: 1, counts: any(named: 'counts')),
      ).thenAnswer((_) async => _openSession());

      await pumpScreen(tester, user: _canCloseUser, session: _openSession());

      await tester.enterText(
        find.byKey(const Key('cash_session_denomination_field_500')),
        '3',
      );
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('cash_session_close_button')));
      await tester.tap(find.byKey(const Key('cash_session_close_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('cash_session_confirm_empty_count_button')),
        findsNothing,
      );
      verify(
        () => repository.close(cashSessionId: 1, counts: any(named: 'counts')),
      ).called(1);
      expect(find.text('Session closed'), findsOneWidget);
    });

    testWidgets('an all-zero count requires the empty-count confirmation '
        'before closing (FR-021)', (tester) async {
      when(
        () => repository.close(cashSessionId: 1, counts: const []),
      ).thenAnswer((_) async => _openSession());

      await pumpScreen(tester, user: _canCloseUser, session: _openSession());

      await tester.ensureVisible(find.byKey(const Key('cash_session_close_button')));
      await tester.tap(find.byKey(const Key('cash_session_close_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('cash_session_confirm_empty_count_button')),
        findsOneWidget,
      );
      verifyNever(
        () => repository.close(
          cashSessionId: any(named: 'cashSessionId'),
          counts: any(named: 'counts'),
        ),
      );

      await tester.tap(find.byKey(const Key('cash_session_confirm_empty_count_button')));
      await tester.pumpAndSettle();

      verify(() => repository.close(cashSessionId: 1, counts: const [])).called(1);
    });
  });

  group('CashSessionDetailScreen — the cash cut (spec 044 US3)', () {
    late FakeDocumentSource source;
    late FakeDocumentOutput output;

    setUp(() {
      source = FakeDocumentSource();
      output = FakeDocumentOutput();
    });

    List<Override> documentOverrides() => [
      documentSourceProvider.overrideWithValue(source),
      documentOutputProvider.overrideWithValue(output),
    ];

    final viewCutButton = find.byKey(const Key('cash_session_view_cut_button'));
    final viewCutInDialog = find.byKey(
      const Key('cash_session_view_cut_dialog_button'),
    );

    /// Counts 3 × 500 and presses Close, leaving the "Session closed" dialog
    /// showing.
    Future<void> closeSession(WidgetTester tester) async {
      await tester.enterText(
        find.byKey(const Key('cash_session_denomination_field_500')),
        '3',
      );
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('cash_session_close_button')));
      await tester.tap(find.byKey(const Key('cash_session_close_button')));
      await tester.pumpAndSettle();
    }

    testWidgets('a closed session offers "View cut" in the body to a user '
        'with point-of-sale read (FR-006)', (tester) async {
      await pumpScreen(
        tester,
        user: _cutReaderUser,
        session: _closedSession(),
        overrides: documentOverrides(),
      );

      expect(viewCutButton, findsOneWidget);
      expect(find.text('View cut'), findsOneWidget);
    });

    testWidgets('sits under the payment amounts, its right edge on theirs, '
        'not at the screen\'s left edge', (tester) async {
      final session = _closedSession().copyWith(
        paymentsByMethod: const [PaymentMethodTotal(method: 1, total: '1750')],
      );
      await pumpScreen(
        tester,
        user: _cutReaderUser,
        session: session,
        overrides: documentOverrides(),
      );

      final amount = find.textContaining('1,750');
      expect(amount, findsOneWidget);
      expect(
        tester.getTopRight(viewCutButton).dx,
        closeTo(tester.getTopRight(amount).dx, 0.5),
      );
      expect(
        tester.getTopLeft(viewCutButton).dy,
        greaterThan(tester.getBottomLeft(amount).dy),
      );
    });

    testWidgets('pressing it opens that session\'s cut in the preview',
        (tester) async {
      await pumpScreen(
        tester,
        user: _cutReaderUser,
        session: _closedSession(),
        overrides: documentOverrides(),
      );

      await tester.ensureVisible(viewCutButton);
      await tester.tap(viewCutButton);
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched, hasLength(1));
      expect(source.fetched.single.kind, DocumentKind.cashCut);
      expect(source.fetched.single.recordId, 2);
      expect(source.fetched.single.title, 'Cash cut · 000002');
    });

    testWidgets('is absent for a user without point-of-sale read — even one '
        'who can close sessions (FR-040)', (tester) async {
      await pumpScreen(
        tester,
        user: _canCloseUser,
        session: _closedSession(),
        overrides: documentOverrides(),
      );

      expect(viewCutButton, findsNothing);
    });

    testWidgets('is absent on an open session, whatever the user may do '
        '(US3-5)', (tester) async {
      await pumpScreen(
        tester,
        user: _closerAndCutReaderUser,
        session: _openSession(),
        overrides: documentOverrides(),
      );

      expect(viewCutButton, findsNothing);
      expect(find.byKey(const Key('cash_session_close_button')), findsOneWidget);
    });

    testWidgets('the close dialog no longer says the figures will not be '
        'shown again (FR-008)', (tester) async {
      when(
        () => repository.close(cashSessionId: 1, counts: any(named: 'counts')),
      ).thenAnswer((_) async => _openSession());
      await pumpScreen(
        tester,
        user: _closerAndCutReaderUser,
        session: _openSession(),
        overrides: documentOverrides(),
      );

      await closeSession(tester);

      expect(find.text('Session closed'), findsOneWidget);
      // The message still reports the three figures ...
      expect(find.textContaining(', difference '), findsOneWidget);
      // ... and no longer claims they cannot be seen again.
      expect(find.textContaining('will not be shown again'), findsNothing);
    });

    testWidgets('the close dialog offers "View cut" to a user with '
        'point-of-sale read, and pressing it closes that dialog before '
        'opening the preview, so dialogs never stack (FR-005)', (tester) async {
      when(
        () => repository.close(cashSessionId: 1, counts: any(named: 'counts')),
      ).thenAnswer((_) async => _openSession());
      await pumpScreen(
        tester,
        user: _closerAndCutReaderUser,
        session: _openSession(),
        overrides: documentOverrides(),
      );
      await closeSession(tester);
      expect(viewCutInDialog, findsOneWidget);

      await tester.tap(viewCutInDialog);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(
        find.byType(Dialog),
        findsOneWidget,
        reason: 'only the preview is open',
      );
      expect(source.fetched.single.kind, DocumentKind.cashCut);
      expect(source.fetched.single.recordId, 1);
      expect(source.fetched.single.title, 'Cash cut · 000001');
    });

    testWidgets('the close dialog offers no "View cut" to a user who may '
        'close but not view cuts — nothing is shown disabled', (tester) async {
      when(
        () => repository.close(cashSessionId: 1, counts: any(named: 'counts')),
      ).thenAnswer((_) async => _openSession());
      await pumpScreen(
        tester,
        user: _canCloseUser,
        session: _openSession(),
        overrides: documentOverrides(),
      );

      await closeSession(tester);

      expect(find.text('Session closed'), findsOneWidget);
      expect(viewCutInDialog, findsNothing);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('after the close, the screen shows the session as closed with '
        'its own "View cut", without leaving it (FR-007, US3-4)',
        (tester) async {
      when(
        () => repository.close(cashSessionId: 1, counts: any(named: 'counts')),
      ).thenAnswer((_) async => _closedSession(id: 1));
      await pumpScreen(
        tester,
        user: _closerAndCutReaderUser,
        session: _openSession(),
        overrides: documentOverrides(),
      );
      // The server now reports the session closed.
      when(
        () => repository.get(cashSessionId: 1),
      ).thenAnswer((_) async => _closedSession(id: 1));

      await closeSession(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cash_session_status_chip_closed')), findsOneWidget);
      expect(find.byKey(const Key('cash_session_close_button')), findsNothing);
      expect(viewCutButton, findsOneWidget);
    });
  });
}
