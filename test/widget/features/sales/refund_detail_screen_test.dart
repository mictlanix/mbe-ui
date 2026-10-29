import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';
import 'session_override.dart';

const _creditNote = CreditNote(
  id: 1,
  customerId: 7,
  salesOrderId: 42,
  customerRefundId: 9,
  customerPaymentId: 300001,
  issued: '20.00',
  remaining: '20.00',
);

CashSession _staleSession() => CashSession(
  cashSessionId: 77,
  cashDrawerId: 1,
  cashDrawerName: 'Caja',
  cashDrawerCode: 'C1',
  cashierId: 5,
  cashierName: 'Ana',
  start: DateTime(2026, 10, 27),
  openingAmount: '0.00',
);

Override _access({
  bool update = true,
  bool confirm = true,
  bool paymentsRead = false,
}) => accessControlProvider.overrideWithValue(
  AccessControlService(
    AuthState.authenticated(
      token: 't',
      user: User(
        userId: 'r',
        email: 'r@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        privileges: [
          Privilege(
            systemObject: SystemObject.customerRefunds,
            rawValue: update ? 6 : 2,
          ),
          if (confirm)
            const Privilege(
              systemObject: SystemObject.customerRefundConfirm,
              rawValue: 4,
            ),
          if (paymentsRead)
            const Privilege(
              systemObject: SystemObject.customerPayments,
              rawValue: 2,
            ),
        ],
      ),
    ),
  ),
);

/// Spec 057 US1 (T022), contracts C5: the refund detail screen.
void main() {
  late MockCustomerRefundRepository refunds;
  late MockCreditNoteRepository notes;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(RefundPayout.cash);
  });

  setUp(() {
    refunds = MockCustomerRefundRepository();
    notes = MockCreditNoteRepository();
  });

  void stubGet(CustomerRefund refund) =>
      when(() => refunds.getById(refund.id)).thenAnswer((_) async => refund);

  /// A draft with one line at [quantity] of 5 refundable.
  CustomerRefund draft({String quantity = '0'}) => testRefund(
    total: quantity == '0' ? '0.00' : '20.00',
    lines: [
      testRefundLine(
        quantity: quantity,
        total: quantity == '0' ? '0.00' : '20.00',
      ),
    ],
  );

  CustomerRefund completed({int? customerId = 7, String quantity = '2'}) =>
      testRefund(
        status: RefundStatus.completed,
        serial: 5,
        customerId: customerId,
        total: '20.00',
        lines: [testRefundLine(quantity: quantity, total: '20.00')],
      );

  Future<GoRouter> pumpDetail(
    WidgetTester tester, {
    Override? access,
    CurrentSession session = const CurrentSession(state: SessionState.open),
    String location = '/sales/refunds/9',
    Size surface = const Size(1400, 1400),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        access ?? _access(),
        customerRefundOverride(refunds),
        creditNoteOverride(notes),
        sessionOverride(session),
        quantityCommitDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 400),
        ),
        customerDisplayNameProvider.overrideWith((ref, id) async => 'Ana'),
        orderLinkTargetProvider.overrideWith(
          (ref, id) async => '/sales/orders/$id',
        ),
        facilityWarehousesControllerProvider.overrideWith(
          (ref, facilityId) async => const [
            Warehouse(
              warehouseId: 3,
              facilityId: 9,
              facilityName: 'Centro',
              code: 'W3',
              name: 'Almacén Central',
              status: EntityStatus.active,
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/sales/orders',
          builder: (_, _) => const Scaffold(body: Text('orders-list')),
        ),
        GoRoute(
          path: '/sales/refunds/:refundId',
          builder: (context, state) => RefundDetailScreen(
            refundId: int.tryParse(state.pathParameters['refundId']!),
          ),
        ),
        GoRoute(
          path: '/sales/orders/:id',
          builder: (_, s) =>
              Scaffold(body: Text('order-${s.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/sales/payments/:id',
          builder: (_, s) =>
              Scaffold(body: Text('payment-${s.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/sales/cash-sessions',
          builder: (_, _) => const Scaffold(body: Text('sessions-list')),
        ),
        GoRoute(
          path: '/sales/cash-sessions/:id',
          builder: (_, s) =>
              Scaffold(body: Text('session-${s.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Finder key(String k) => find.byKey(Key(k));

  Future<void> setQuantity(WidgetTester tester, String value) async {
    await tester.enterText(key('refund_line_qty_1'), value);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  /// Taps Confirmar, picks [choice] in the dialog and submits it.
  Future<void> confirmThrough(WidgetTester tester, String choice) async {
    await tester.tap(key('refund_confirm_button'));
    await tester.pumpAndSettle();
    await tester.tap(key(choice));
    await tester.pumpAndSettle();
    await tester.tap(key('refund_confirm_submit'));
    await tester.pumpAndSettle();
  }

  group('a draft', () {
    testWidgets('with update and confirm access: steppers are live and '
        'confirm appears once a line is above zero', (tester) async {
      stubGet(draft());
      when(
        () => refunds.updateLine(9, 1, quantity: '2'),
      ).thenAnswer((_) async => draft(quantity: '2'));
      await pumpDetail(tester);

      expect(key('refund_lines_table'), findsOneWidget);
      expect(key('refund_line_qty_1'), findsOneWidget);
      expect(key('refund_line_warehouse_1'), findsOneWidget);
      expect(key('refund_status_chip_draft'), findsOneWidget);
      expect(key('refund_confirm_button'), findsNothing);
      expect(key('refund_needs_confirmer_hint'), findsNothing);

      await setQuantity(tester, '2');

      verify(() => refunds.updateLine(9, 1, quantity: '2')).called(1);
      expect(key('refund_confirm_button'), findsOneWidget);
      expect(
        find.descendant(
          of: key('refund_total'),
          matching: find.textContaining('20.00'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('with update but no confirm access: the hint and no button', (
      tester,
    ) async {
      stubGet(draft(quantity: '2'));
      await pumpDetail(tester, access: _access(confirm: false));

      expect(key('refund_line_qty_1'), findsOneWidget);
      expect(key('refund_needs_confirmer_hint'), findsOneWidget);
      expect(find.text(l10n.refundNeedsConfirmerHint), findsOneWidget);
      expect(key('refund_confirm_button'), findsNothing);
    });

    testWidgets('without update access: plain text and no actions', (
      tester,
    ) async {
      stubGet(draft(quantity: '2'));
      await pumpDetail(tester, access: _access(update: false, confirm: false));

      expect(key('refund_lines_table'), findsOneWidget);
      expect(key('refund_line_qty_1'), findsNothing);
      expect(key('refund_line_warehouse_1'), findsNothing);
      expect(key('refund_needs_confirmer_hint'), findsNothing);
      expect(key('refund_confirm_button'), findsNothing);
      expect(find.text('Almacén Central'), findsOneWidget);
    });

    testWidgets('no cash session: the banner shows and nothing is sent', (
      tester,
    ) async {
      stubGet(draft(quantity: '2'));
      await pumpDetail(
        tester,
        session: const CurrentSession(state: SessionState.none),
      );

      await tester.tap(key('refund_confirm_button'));
      await tester.pumpAndSettle();

      // The dialog never opens: no payout is asked for without a session.
      expect(key('refund_confirm_dialog'), findsNothing);
      expect(key('refund_session_banner'), findsOneWidget);
      expect(find.text(l10n.refundSessionBanner), findsOneWidget);
      verifyNever(() => refunds.confirm(any(), any()));

      await tester.tap(key('refund_session_button'));
      await tester.pumpAndSettle();
      expect(find.text('sessions-list'), findsOneWidget);
    });

    testWidgets('a stale cash session: the banner links to that session', (
      tester,
    ) async {
      stubGet(draft(quantity: '2'));
      await pumpDetail(
        tester,
        session: CurrentSession(
          state: SessionState.stale,
          session: _staleSession(),
        ),
      );

      await tester.tap(key('refund_confirm_button'));
      await tester.pumpAndSettle();

      expect(key('refund_confirm_dialog'), findsNothing);
      expect(key('refund_session_banner'), findsOneWidget);
      verifyNever(() => refunds.confirm(any(), any()));

      await tester.tap(key('refund_session_button'));
      await tester.pumpAndSettle();
      expect(find.text('session-77'), findsOneWidget);
    });

    testWidgets('a failed confirm shows the banner with the server detail', (
      tester,
    ) async {
      stubGet(draft(quantity: '2'));
      when(() => refunds.confirm(9, any())).thenThrow(
        const AppError.server(
          statusCode: 409,
          message: 'Units of line TOR-01 are on invoice F-1',
        ),
      );
      await pumpDetail(tester);

      await confirmThrough(tester, 'refund_payout_cash');

      expect(
        find.textContaining('Units of line TOR-01 are on invoice F-1'),
        findsOneWidget,
      );
      // The refund is as it was: still a draft with its confirm button.
      expect(key('refund_status_chip_draft'), findsOneWidget);
      expect(key('refund_confirm_button'), findsOneWidget);
    });

    testWidgets('a confirm that lowered a line shows the adjustment banner', (
      tester,
    ) async {
      stubGet(draft(quantity: '2'));
      when(() => refunds.confirm(9, RefundPayout.cash)).thenAnswer(
        (_) async => testRefund(
          status: RefundStatus.completed,
          serial: 5,
          total: '10.00',
          lines: [testRefundLine(quantity: '1', total: '10.00')],
        ),
      );
      when(
        () => notes.findByRefund(
          customerId: any(named: 'customerId'),
          refundId: any(named: 'refundId'),
          refundDate: any(named: 'refundDate'),
        ),
      ).thenAnswer((_) async => null);
      await pumpDetail(tester);

      await confirmThrough(tester, 'refund_payout_cash');

      expect(key('refund_adjusted_banner'), findsOneWidget);
      expect(find.text(l10n.refundAdjustedBanner), findsOneWidget);
      expect(key('refund_status_chip_completed'), findsOneWidget);
      expect(key('refund_confirm_button'), findsNothing);
    });
  });

  group('cancel', () {
    testWidgets('shows on a draft with update access, asks first, then shows '
        'the cancelled state', (tester) async {
      stubGet(draft());
      when(
        () => refunds.cancel(9),
      ).thenAnswer((_) async => testRefund(status: RefundStatus.cancelled));
      await pumpDetail(tester);

      expect(key('refund_cancel_button'), findsOneWidget);

      await tester.tap(key('refund_cancel_button'));
      await tester.pumpAndSettle();

      expect(key('refund_cancel_dialog'), findsOneWidget);
      expect(find.text(l10n.refundCancelPrompt), findsOneWidget);
      verifyNever(() => refunds.cancel(any()));

      await tester.tap(key('refund_cancel_dialog_confirm'));
      await tester.pumpAndSettle();

      verify(() => refunds.cancel(9)).called(1);
      expect(key('refund_status_chip_cancelled'), findsOneWidget);
      expect(key('refund_cancel_button'), findsNothing);
      expect(key('refund_line_qty_1'), findsNothing);
    });

    testWidgets('going back from the prompt cancels nothing', (tester) async {
      stubGet(draft());
      await pumpDetail(tester);

      await tester.tap(key('refund_cancel_button'));
      await tester.pumpAndSettle();
      await tester.tap(key('refund_cancel_dialog_back'));
      await tester.pumpAndSettle();

      verifyNever(() => refunds.cancel(any()));
      expect(key('refund_cancel_dialog'), findsNothing);
      expect(key('refund_status_chip_draft'), findsOneWidget);
      expect(key('refund_cancel_button'), findsOneWidget);
    });

    testWidgets('a draft with lines above zero shows cancel beside confirm', (
      tester,
    ) async {
      stubGet(draft(quantity: '2'));
      await pumpDetail(tester);

      expect(key('refund_cancel_button'), findsOneWidget);
      expect(key('refund_confirm_button'), findsOneWidget);
    });

    testWidgets('is absent without update access', (tester) async {
      stubGet(draft());
      await pumpDetail(tester, access: _access(update: false, confirm: false));

      expect(key('refund_cancel_button'), findsNothing);
    });

    testWidgets('is absent on a completed refund', (tester) async {
      stubGet(completed());
      when(
        () => notes.findByRefund(
          customerId: any(named: 'customerId'),
          refundId: any(named: 'refundId'),
          refundDate: any(named: 'refundDate'),
        ),
      ).thenAnswer((_) async => null);
      await pumpDetail(tester);

      expect(key('refund_cancel_button'), findsNothing);
    });

    testWidgets('is absent on a cancelled refund', (tester) async {
      stubGet(testRefund(status: RefundStatus.cancelled));
      await pumpDetail(tester);

      expect(key('refund_cancel_button'), findsNothing);
    });

    testWidgets('a failed cancel shows the banner and leaves the draft', (
      tester,
    ) async {
      stubGet(draft());
      when(() => refunds.cancel(9)).thenThrow(
        const AppError.server(statusCode: 409, message: 'Cannot cancel now'),
      );
      await pumpDetail(tester);

      await tester.tap(key('refund_cancel_button'));
      await tester.pumpAndSettle();
      await tester.tap(key('refund_cancel_dialog_confirm'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Cannot cancel now'), findsOneWidget);
      expect(key('refund_status_chip_draft'), findsOneWidget);
      expect(key('refund_cancel_button'), findsOneWidget);
    });
  });

  group('a completed refund', () {
    void stubNote(CreditNote? note) => when(
      () => notes.findByRefund(
        customerId: any(named: 'customerId'),
        refundId: any(named: 'refundId'),
        refundDate: any(named: 'refundDate'),
      ),
    ).thenAnswer((_) async => note);

    testWidgets('paid in cash: the cash payout line, read-only, no adjustment '
        'banner', (tester) async {
      stubGet(completed());
      stubNote(null);
      await pumpDetail(tester);

      expect(
        find.descendant(
          of: key('refund_payout_line'),
          matching: find.text(l10n.refundPayoutLineCash),
        ),
        findsOneWidget,
      );
      expect(key('refund_adjusted_banner'), findsNothing);
      expect(key('refund_line_qty_1'), findsNothing);
      expect(key('refund_confirm_button'), findsNothing);
      expect(find.text(l10n.refundColumnRefundable), findsNothing);
      expect(find.text(l10n.refundColumnReturned), findsOneWidget);
    });

    testWidgets('paid with a credit note: the number links to its payment '
        'when the user can read payments', (tester) async {
      stubGet(completed());
      stubNote(_creditNote);
      await pumpDetail(tester, access: _access(paymentsRead: true));

      expect(key('refund_payout_link'), findsOneWidget);
      expect(
        find.text(l10n.refundPayoutLineCreditNote(300001)),
        findsOneWidget,
      );

      await tester.tap(key('refund_payout_link'));
      await tester.pumpAndSettle();
      expect(find.text('payment-300001'), findsOneWidget);
    });

    testWidgets(
      'paid with a credit note, without payments access: plain text',
      (tester) async {
        stubGet(completed());
        stubNote(_creditNote);
        await pumpDetail(tester);

        expect(key('refund_payout_link'), findsNothing);
        expect(
          find.text(l10n.refundPayoutLineCreditNote(300001)),
          findsOneWidget,
        );
      },
    );

    testWidgets('no customer: the payout is unknown', (tester) async {
      stubGet(completed(customerId: null));
      await pumpDetail(tester);

      expect(find.text(l10n.refundPayoutLineUnknown), findsOneWidget);
      verifyNever(
        () => notes.findByRefund(
          customerId: any(named: 'customerId'),
          refundId: any(named: 'refundId'),
          refundDate: any(named: 'refundDate'),
        ),
      );
    });

    testWidgets('a failed lookup shows the payout as unknown', (tester) async {
      stubGet(completed());
      when(
        () => notes.findByRefund(
          customerId: any(named: 'customerId'),
          refundId: any(named: 'refundId'),
          refundDate: any(named: 'refundDate'),
        ),
      ).thenThrow(const AppError.network());
      await pumpDetail(tester);

      expect(find.text(l10n.refundPayoutLineUnknown), findsOneWidget);
    });
  });

  testWidgets('a cancelled refund is read-only with its chip', (tester) async {
    stubGet(
      testRefund(
        status: RefundStatus.cancelled,
        lines: [testRefundLine(quantity: '2', total: '20.00')],
        total: '20.00',
      ),
    );
    await pumpDetail(tester);

    expect(key('refund_status_chip_cancelled'), findsOneWidget);
    expect(key('refund_line_qty_1'), findsNothing);
    expect(key('refund_confirm_button'), findsNothing);
    expect(key('refund_payout_line'), findsNothing);
    expect(key('refund_needs_confirmer_hint'), findsNothing);
  });

  group('loading', () {
    testWidgets('a 404 shows the not-found state', (tester) async {
      when(() => refunds.getById(9)).thenThrow(const AppError.notFound());
      await pumpDetail(tester);

      expect(key('refund_not_found'), findsOneWidget);
      expect(key('refund_lines_table'), findsNothing);
    });

    testWidgets('a non-numeric id shows the not-found state', (tester) async {
      await pumpDetail(tester, location: '/sales/refunds/abc');

      expect(key('refund_not_found'), findsOneWidget);
      verifyNever(() => refunds.getById(any()));
    });

    testWidgets('a failed load shows the banner and a working retry', (
      tester,
    ) async {
      var calls = 0;
      when(() => refunds.getById(9)).thenAnswer((_) async {
        if (++calls == 1) throw const AppError.network();
        return draft();
      });
      await pumpDetail(tester);

      expect(key('refund_load_failed'), findsOneWidget);

      await tester.tap(key('refund_retry_button'));
      await tester.pumpAndSettle();

      expect(key('refund_load_failed'), findsNothing);
      expect(key('refund_lines_table'), findsOneWidget);
    });
  });

  testWidgets('the order number links to the order', (tester) async {
    stubGet(draft());
    await pumpDetail(tester);

    await tester.tap(key('refund_order_link'));
    await tester.pumpAndSettle();

    expect(find.text('order-42'), findsOneWidget);
  });

  testWidgets('compact layout: line blocks replace the table and nothing '
      'overflows', (tester) async {
    stubGet(draft(quantity: '2'));
    await pumpDetail(tester, surface: const Size(390, 844));

    expect(key('refund_lines_table'), findsNothing);
    expect(key('refund_line_block_1'), findsOneWidget);
    expect(key('refund_line_qty_1'), findsOneWidget);
    expect(key('refund_confirm_button'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
