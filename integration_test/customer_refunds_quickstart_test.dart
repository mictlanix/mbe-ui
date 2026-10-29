import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/nav_destinations.dart';
import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_refund_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/057-customer-refunds/quickstart.md steps 1-5 and 8-10
/// against the REAL app (macOS desktop) and a live mbe-api. Steps 6-7 (confirm as
/// cash, confirm as a credit note) write stock and cash, so they run only
/// with `--dart-define=MBE_REFUND_CONFIRM=1`.
///
///   caffeinate -dimsu flutter test \
///     integration_test/customer_refunds_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env
///
/// `MBE_POS_*` is the administrator; `MBE_TEST_*` is the no-access account
/// (qanoaccess) for step 10. A paid order with returnable lines is
/// discovered at runtime (the tenant is never assumed to hold one); the test
/// skips when there is none. Step 8 cancels a draft through the UI; every
/// other draft refund it opens is cancelled in a tearDown through the
/// repository, so the tenant is left as it was. Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');
const _confirmSteps = bool.fromEnvironment('MBE_REFUND_CONFIRM');

const _wide = Size(1400, 1000);

/// A paid order the admin can refund, and the order line the test edits. A
/// refund's own line ids change with every draft, so the order's line id is
/// what identifies the line across drafts.
class _Fixture {
  _Fixture(this.orderId, this.orderLineId, this.refundable);
  final int orderId;
  final int orderLineId;
  final double refundable;

  RefundLine lineOf(CustomerRefund refund) =>
      refund.lines.firstWhere((l) => l.salesOrderLineId == orderLineId);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Customer refunds quickstart walkthrough (real app, live '
      'mbe-api)', (tester) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }

    // Frame watchdog: when the app window is not frontmost, macOS can stop
    // delivering frames and every pump then waits forever. Drives a frame by
    // hand after ~1.5 s without one; changes nothing when frames flow.
    var kicks = 0;
    var lastTs = binding.currentSystemFrameTimeStamp;
    var lastWall = DateTime.now();
    DateTime? stalledSince;
    final watchdog = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final ts = binding.currentSystemFrameTimeStamp;
      final now = DateTime.now();
      if (ts != lastTs) {
        lastTs = ts;
        lastWall = now;
      }
      if (!binding.hasScheduledFrame ||
          binding.schedulerPhase != SchedulerPhase.idle) {
        stalledSince = null;
        return;
      }
      stalledSince ??= now;
      if (now.difference(stalledSince!) < const Duration(milliseconds: 1500)) {
        return;
      }
      final raw = lastTs + now.difference(lastWall);
      lastTs = raw;
      lastWall = now;
      stalledSince = null;
      kicks++;
      binding.handleBeginFrame(raw);
      binding.handleDrawFrame();
    });
    final heartbeat = Timer.periodic(const Duration(seconds: 30), (_) {
      // ignore: avoid_print
      print(
        'QS-HB phase=${binding.schedulerPhase} '
        'scheduled=${binding.hasScheduledFrame} kicks=$kicks',
      );
    });
    addTearDown(() {
      heartbeat.cancel();
      watchdog.cancel();
      // ignore: avoid_print
      print('QS: frame watchdog drove $kicks frame(s)');
    });

    // ------------------------------------------------------------------
    // API side (independent of the app's own session)
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final refunds = CustomerRefundRepositoryImpl(dio);
    final orders = SalesOrderRepositoryImpl(dio);
    final cashSessions = CashSessionRepositoryImpl(dio);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    double qty(String s) => double.tryParse(s) ?? 0;

    Future<List<CustomerRefundSummary>> draftsOf(int orderId) async =>
        (await refunds.list(
          salesOrderId: orderId,
          status: RefundStatus.draft,
          skip: 0,
          limit: 50,
        )).items;

    /// The tenant must be left as found: every draft this test caused is
    /// cancelled. Discovery guarantees there was none before it started.
    final touchedOrders = <int>{};
    addTearDown(() async {
      for (final orderId in touchedOrders) {
        try {
          for (final draft in await draftsOf(orderId)) {
            await refunds.cancel(draft.id);
            // ignore: avoid_print
            print('QS: cancelled draft refund ${draft.id} (order $orderId)');
          }
        } on Object catch (e) {
          // ignore: avoid_print
          print('QS: CLEANUP FAILED for order $orderId: $e');
        }
      }
    });

    // Discover paid back-office orders with returnable lines and no draft
    // refund already open. Opening a refund is the only way to learn whether
    // anything is returnable (a 409 otherwise); the probe is cancelled at once.
    final candidates = await orders.listOrders(
      status: SaleStatus.paid,
      excludeOrigin: SaleOrigin.pointOfSale,
      limit: 40,
    );
    final fixtures = <_Fixture>[];
    for (final order in candidates.items) {
      if (fixtures.length >= (_confirmSteps ? 2 : 1)) break;
      if (order.status != SaleStatus.paid) continue;
      if ((await draftsOf(order.id)).isNotEmpty) continue;
      touchedOrders.add(order.id);
      try {
        final probe = await refunds.open(order.id);
        await refunds.cancel(probe.id);
        final line = probe.lines.where((l) => qty(l.refundableQuantity) > 0);
        if (line.isEmpty) continue;
        fixtures.add(
          _Fixture(
            order.id,
            line.first.salesOrderLineId,
            qty(line.first.refundableQuantity),
          ),
        );
      } on AppError {
        // Nothing to return, or not refundable: not a candidate.
      }
    }
    if (fixtures.isEmpty) {
      markTestSkipped('no paid order with returnable lines at this tenant');
      return;
    }
    final fx = fixtures.first;
    // ignore: avoid_print
    print(
      'QS: fixture order ${fx.orderId}, order line ${fx.orderLineId}, '
      'refundable ${fx.refundable}',
    );
    final session = await cashSessions.getCurrent();
    // ignore: avoid_print
    print('QS: cash session valid=${session.isValid}');

    // ------------------------------------------------------------------
    // App boot (mirrors lib/main.dart)
    // ------------------------------------------------------------------
    await initializeDateFormatting();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await TokenStorage().clear();

    tester.view.physicalSize = _wide;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const App(),
      ),
    );

    // ignore: avoid_print
    print('QS: app mounted');

    ProviderContainer container() =>
        ProviderScope.containerOf(tester.element(find.byType(App)));
    GoRouter router() => container().read(goRouterProvider);
    String location() =>
        router().routerDelegate.currentConfiguration.last.matchedLocation;

    Future<void> pumpFor(Duration d) async {
      final end = DateTime.now().add(d);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilTrue(
      bool Function() cond,
      String what, {
      Duration timeout = const Duration(seconds: 60),
    }) async {
      final end = DateTime.now().add(timeout);
      while (true) {
        await tester.pump(const Duration(milliseconds: 100));
        if (cond()) return;
        if (DateTime.now().isAfter(end)) {
          throw TestFailure('Timed out waiting for: $what');
        }
      }
    }

    Finder byKey(String k) => find.byKey(Key(k));
    bool spinning() =>
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

    Future<void> login(String user, String pass) async {
      await pumpUntilTrue(
        () => byKey('login_username_field').hitTestable().evaluate().isNotEmpty,
        'login screen',
      );
      await tester.enterText(byKey('login_username_field').hitTestable(), user);
      await tester.enterText(byKey('login_password_field').hitTestable(), pass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey('login_password_field').hitTestable());
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilTrue(
        () => byKey('login_username_field').evaluate().isEmpty,
        'login to finish',
        timeout: const Duration(seconds: 40),
      );
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> go(String path) async {
      router().go(path);
      await pumpFor(const Duration(milliseconds: 500));
    }

    int? refundIdAtLocation() {
      final m = RegExp(r'^/sales/refunds/(\d+)$').firstMatch(location());
      return m == null ? null : int.parse(m.group(1)!);
    }

    /// Opens [orderId] (Pedidos or the POS detail) and taps Devolver; returns the refund id the
    /// app navigated to.
    Future<int> tapDevolver(int orderId) async {
      // A paid order whose origin was never recorded (anything before
      // mbe-api#209) is read as a register sale, so it opens in the POS
      // detail view instead of Pedidos; both carry the same button.
      final origin = (await orders.getById(saleId: orderId)).origin;
      await go(
        origin == SaleOrigin.backOffice
            ? '/sales/orders/$orderId'
            : '/sales/pos/$orderId',
      );
      try {
        await pumpUntilTrue(
          () =>
              byKey(
                'order_refund_button',
              ).hitTestable().evaluate().isNotEmpty &&
              !spinning(),
          'the Devolver button',
          timeout: const Duration(seconds: 25),
        );
      } on TestFailure {
        final texts = find
            .byType(Text)
            .evaluate()
            .map((e) => (e.widget as Text).data ?? '')
            .where((t) => t.isNotEmpty)
            .take(60)
            .toList();
        throw TestFailure(
          'no Devolver button at ${location()} '
          '(in tree: ${byKey('order_refund_button').evaluate().length}, '
          'spinning: ${spinning()}); visible text: $texts',
        );
      }
      await tester.tap(byKey('order_refund_button').hitTestable());
      await pumpUntilTrue(
        () => refundIdAtLocation() != null,
        'the refund screen',
      );
      await pumpUntilTrue(
        () => byKey('refund_lines_table').evaluate().isNotEmpty && !spinning(),
        'refund lines',
      );
      return refundIdAtLocation()!;
    }

    Future<void> setQuantity(int lineId, String value) async {
      await tester.tap(byKey('refund_line_qty_$lineId'));
      await pumpFor(const Duration(milliseconds: 300));
      await tester.enterText(byKey('refund_line_qty_$lineId'), value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpFor(const Duration(milliseconds: 1500));
    }

    Future<void> confirmAs(String payoutKey) async {
      await tester.tap(byKey('refund_confirm_button'));
      await pumpUntilTrue(
        () => byKey('refund_confirm_dialog').evaluate().isNotEmpty,
        'the confirm dialog',
      );
      await tester.tap(byKey(payoutKey));
      await pumpFor(const Duration(milliseconds: 300));
      await tester.tap(byKey('refund_confirm_submit'));
      await pumpFor(const Duration(seconds: 2));
    }

    int chipCount() => [
      for (final st in RefundStatus.values)
        byKey('refund_status_chip_${st.name}').evaluate().length,
    ].fold(0, (a, b) => a + b);

    Future<void> waitForList(int expectedRows, String what) async {
      await pumpUntilTrue(
        () => byKey('refunds_table').evaluate().isNotEmpty && !spinning(),
        'the refunds table ($what)',
      );
      await pumpUntilTrue(
        () => chipCount() == expectedRows,
        '$expectedRows row(s) ($what); have ${chipCount()}',
        timeout: const Duration(seconds: 30),
      );
    }

    Future<void> openFilterSheet() async {
      await tester.tap(byKey('refunds_filter_button').hitTestable());
      await pumpFor(const Duration(milliseconds: 800));
    }

    Future<void> closeFilterSheet() async {
      await tester.tap(byKey('filter_sheet_apply_button').hitTestable());
      await pumpFor(const Duration(milliseconds: 800));
    }

    Future<void> submitNewRefundOrder(int orderId) async {
      await tester.tap(byKey('refund_new_order_input').hitTestable());
      await pumpFor(const Duration(milliseconds: 300));
      await tester.enterText(byKey('refund_new_order_input'), '$orderId');
      await pumpFor(const Duration(milliseconds: 200));
      await tester.testTextInput.receiveAction(TextInputAction.done);
    }

    Future<void> expectRefusal(String text) async {
      String shown() => byKey('refund_new_refusal').evaluate().isEmpty
          ? '(none)'
          : tester.widget<Text>(byKey('refund_new_refusal')).data ?? '';
      try {
        await pumpUntilTrue(
          () => shown() == text,
          'the refusal "$text"',
          timeout: const Duration(seconds: 30),
        );
      } on TestFailure {
        throw TestFailure(
          'expected refusal "$text" but the dialog shows '
          '"${shown()}" (new-refund dialog open: '
          '${byKey('refund_new_dialog').evaluate().isNotEmpty})',
        );
      }
    }

    final failures = <String>[];
    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: $ex');
        // ignore: avoid_print
        print('QS-STEP PASS $name');
      } catch (e) {
        failures.add('$name: $e');
        tester.takeException();
        // ignore: avoid_print
        print('QS-STEP FAIL $name :: $e');
      }
    }

    await login(_adminUser, _adminPass);

    int? draftId;

    await step('1. Devolver opens a draft refund, lines at 0', () async {
      draftId = await tapDevolver(fx.orderId);
      final refund = await refunds.getById(draftId!);
      expect(refund.status, RefundStatus.draft);
      expect(refund.salesOrderId, fx.orderId);
      expect(refund.lines, isNotEmpty);
      expect(refund.lines.every((l) => qty(l.quantity) == 0), isTrue);
      expect(byKey('refund_status_chip_draft'), findsOneWidget);
      expect(byKey('refund_line_qty_${fx.lineOf(refund).id}'), findsOneWidget);
    });

    await step('2. Devolver again resumes the same draft', () async {
      expect(draftId, isNotNull, reason: 'step 1 opened no draft');
      router().pop();
      await pumpFor(const Duration(seconds: 1));
      await pumpUntilTrue(
        () => byKey('order_refund_button').hitTestable().evaluate().isNotEmpty,
        'the order again',
      );
      await tester.tap(byKey('order_refund_button').hitTestable());
      await pumpUntilTrue(
        () => refundIdAtLocation() != null,
        'the refund screen again',
      );
      expect(refundIdAtLocation(), draftId);
      final drafts = await draftsOf(fx.orderId);
      expect(drafts.map((d) => d.id), [draftId]);
    });

    await step(
      '3. the quantity cap holds and a write updates totals',
      () async {
        expect(draftId, isNotNull, reason: 'step 1 opened no draft');
        final lineId = fx.lineOf(await refunds.getById(draftId!)).id;
        await pumpUntilTrue(
          () => byKey('refund_line_qty_$lineId').evaluate().isNotEmpty,
          'the stepper',
        );
        // Above "Por devolver" is refused: nothing is sent.
        await setQuantity(lineId, '${fx.refundable + 1}');
        var refund = await refunds.getById(draftId!);
        expect(
          qty(fx.lineOf(refund).quantity),
          0,
          reason: 'over-max entry must not commit',
        );

        await setQuantity(lineId, '1');
        // The write waits out the commit debounce and a slow dev backend.
        final end = DateTime.now().add(const Duration(seconds: 20));
        do {
          refund = await refunds.getById(draftId!);
          if (qty(fx.lineOf(refund).quantity) == 1) break;
          await pumpFor(const Duration(milliseconds: 500));
        } while (DateTime.now().isBefore(end));
        expect(qty(fx.lineOf(refund).quantity), 1);
        expect(qty(refund.total), greaterThan(0));
        expect(byKey('refund_total'), findsOneWidget);
        expect(
          byKey('refund_confirm_button'),
          findsOneWidget,
          reason: 'confirm appears once a line is above zero',
        );
      },
    );

    await step('5. without an open session, confirm shows the banner and '
        'sends nothing', () async {
      expect(draftId, isNotNull, reason: 'step 1 opened no draft');
      if (session.isValid) {
        // ignore: avoid_print
        print(
          'QS-STEP SKIP 5. the admin has an open cash session; closing it '
          'is not this test\'s call',
        );
        return;
      }
      await tester.tap(byKey('refund_confirm_button'));
      // The session is checked before any payout is asked for, so the banner
      // appears without the dialog (contracts C5, FR-009).
      await pumpUntilTrue(
        () =>
            byKey('refund_session_banner').evaluate().isNotEmpty ||
            byKey('refund_confirm_dialog').evaluate().isNotEmpty,
        'the session banner',
      );
      expect(
        byKey('refund_confirm_dialog'),
        findsNothing,
        reason: 'no payout is asked for without a session',
      );
      expect(byKey('refund_session_banner'), findsOneWidget);
      expect(find.text(l10n.refundSessionBanner), findsOneWidget);
      final refund = await refunds.getById(draftId!);
      expect(refund.status, RefundStatus.draft, reason: 'nothing was sent');
    });

    await step('4. the new-refund dialog refuses an unpaid and a draft '
        'order, inline', () async {
      final unpaid = (await orders.listOrders(
        status: SaleStatus.completed,
        limit: 20,
      )).items;
      final drafts = (await orders.listOrders(
        status: SaleStatus.draft,
        limit: 20,
      )).items;
      int? unpaidId;
      for (final o in unpaid) {
        if ((await draftsOf(o.id)).isEmpty) {
          unpaidId = o.id;
          break;
        }
      }
      int? draftOrderId;
      for (final o in drafts) {
        if ((await draftsOf(o.id)).isEmpty) {
          draftOrderId = o.id;
          break;
        }
      }
      if (unpaidId == null && draftOrderId == null) {
        // ignore: avoid_print
        print('QS-STEP SKIP 4. no unpaid and no draft order at this tenant');
        return;
      }

      await go('/sales/refunds');
      await pumpUntilTrue(
        () => byKey('refunds_new_button').hitTestable().evaluate().isNotEmpty,
        'the Nueva devolución button',
      );
      await tester.tap(byKey('refunds_new_button').hitTestable());
      await pumpUntilTrue(
        () => byKey('refund_new_dialog').evaluate().isNotEmpty,
        'the new-refund dialog',
      );
      if (unpaidId != null) {
        await submitNewRefundOrder(unpaidId);
        await expectRefusal(l10n.refundRefusalNotPaid(unpaidId));
      } else {
        // ignore: avoid_print
        print('QS-STEP SKIP 4a. no unpaid (completed) order at this tenant');
      }
      if (draftOrderId != null) {
        await submitNewRefundOrder(draftOrderId);
        await expectRefusal(l10n.refundRefusalNotCompleted(draftOrderId));
      } else {
        // ignore: avoid_print
        print('QS-STEP SKIP 4b. no draft order at this tenant');
      }
      expect(
        byKey('refund_new_dialog'),
        findsOneWidget,
        reason: 'a refusal keeps the dialog open',
      );
      // Nothing was opened for either order.
      for (final id in [unpaidId, draftOrderId].whereType<int>()) {
        expect(await draftsOf(id), isEmpty, reason: 'order $id');
      }
      await tester.tap(find.text(l10n.cancelButton).hitTestable());
      await pumpFor(const Duration(milliseconds: 500));
      expect(byKey('refund_new_dialog'), findsNothing);
    });

    await step('9. list filters: Abiertas, customer, order number', () async {
      expect(draftId, isNotNull, reason: 'step 1 opened no draft');
      final draft = await refunds.getById(draftId!);

      // Abiertas
      await go('/sales/refunds');
      await pumpUntilTrue(
        () => byKey('refunds_table').evaluate().isNotEmpty && !spinning(),
        'the refunds table',
      );
      await openFilterSheet();
      await tester.tap(find.text(l10n.refundsFilterOpen).hitTestable());
      await pumpFor(const Duration(seconds: 1));
      expect(router().state.uri.queryParameters['status'], 'draft');
      final openApi = await refunds.list(
        status: RefundStatus.draft,
        skip: 0,
        limit: 20,
      );
      await waitForList(openApi.items.length, 'Abiertas');
      expect(
        byKey('refund_status_chip_completed'),
        findsNothing,
        reason: 'only drafts remain',
      );
      expect(byKey('refund_status_chip_cancelled'), findsNothing);
      expect(openApi.items.map((r) => r.id), contains(draftId));
      await closeFilterSheet();

      // The discovered customer (the picker is driven by URL here; its UI
      // is covered by the widget test).
      final customerId = draft.customerId;
      if (customerId == null) {
        // ignore: avoid_print
        print('QS-STEP SKIP 9b. the fixture refund has no customer');
      } else {
        await go('/sales/refunds?customer=$customerId');
        final api = await refunds.list(
          customerId: customerId,
          skip: 0,
          limit: 20,
        );
        await waitForList(api.items.length, 'customer $customerId');
        expect(api.items.map((r) => r.id), contains(draftId));
      }

      // The order number, typed into the drawer.
      await go('/sales/refunds');
      await pumpUntilTrue(
        () => byKey('refunds_table').evaluate().isNotEmpty && !spinning(),
        'the refunds table',
      );
      await openFilterSheet();
      await tester.enterText(
        byKey('refunds_order_filter').hitTestable(),
        '${fx.orderId}',
      );
      await pumpFor(const Duration(seconds: 2));
      expect(router().state.uri.queryParameters['order'], '${fx.orderId}');
      final byOrder = await refunds.list(
        salesOrderId: fx.orderId,
        skip: 0,
        limit: 20,
      );
      await waitForList(byOrder.items.length, 'order ${fx.orderId}');
      expect(find.text('#${fx.orderId}'), findsWidgets);
      expect(byOrder.items.every((r) => r.salesOrderId == fx.orderId), isTrue);
      await closeFilterSheet();
    });

    await step('8. cancel a draft through the UI', () async {
      draftId = await tapDevolver(fx.orderId);
      await tester.tap(byKey('refund_cancel_button').hitTestable());
      await pumpUntilTrue(
        () => byKey('refund_cancel_dialog').evaluate().isNotEmpty,
        'the cancel prompt',
      );
      await tester.tap(byKey('refund_cancel_dialog_confirm').hitTestable());
      await pumpUntilTrue(
        () => byKey('refund_status_chip_cancelled').evaluate().isNotEmpty,
        'the cancelled refund',
        timeout: const Duration(seconds: 30),
      );
      expect(byKey('refund_cancel_button'), findsNothing);
      final refund = await refunds.getById(draftId!);
      expect(refund.status, RefundStatus.cancelled);
    });

    if (_confirmSteps) {
      await step('6. confirm as cash', () async {
        expect(session.isValid, isTrue, reason: 'an open session is needed');
        // Step 8 cancelled the first draft: open another and fill it.
        draftId = await tapDevolver(fx.orderId);
        final lineId = fx.lineOf(await refunds.getById(draftId!)).id;
        await setQuantity(lineId, '1');
        await confirmAs('refund_payout_cash');
        await pumpUntilTrue(
          () => byKey('refund_status_chip_completed').evaluate().isNotEmpty,
          'the completed refund',
        );
        await pumpUntilTrue(
          () =>
              find.text(l10n.refundPayoutLineCash).evaluate().isNotEmpty ||
              find.text(l10n.refundPayoutLineUnknown).evaluate().isNotEmpty,
          'the payout line',
        );
        expect(find.text(l10n.refundPayoutLineCash), findsOneWidget);
        expect(byKey('refund_confirm_button'), findsNothing);
      });

      await step('7. confirm as a credit note', () async {
        expect(session.isValid, isTrue, reason: 'an open session is needed');
        if (fixtures.length < 2) {
          // ignore: avoid_print
          print('QS-STEP SKIP 7. no second refundable order');
          return;
        }
        final second = fixtures[1];
        final id = await tapDevolver(second.orderId);
        final secondLine = second.lineOf(await refunds.getById(id)).id;
        await pumpUntilTrue(
          () => byKey('refund_line_qty_$secondLine').evaluate().isNotEmpty,
          'the stepper',
        );
        await setQuantity(secondLine, '1');
        await confirmAs('refund_payout_credit_note');
        await pumpUntilTrue(
          () => byKey('refund_status_chip_completed').evaluate().isNotEmpty,
          'the completed refund',
        );
        await pumpUntilTrue(
          () => find
              .descendant(
                of: byKey('refund_payout_line'),
                matching: find.textContaining(l10n.refundPayoutCreditNote),
              )
              .evaluate()
              .isNotEmpty,
          'the credit-note payout line',
        );
        final refund = await refunds.getById(id);
        expect(refund.status, RefundStatus.completed);
      });
    } else {
      // ignore: avoid_print
      print('QS-STEP SKIP 6-7. pass --dart-define=MBE_REFUND_CONFIRM=1');
    }

    await step('10. the no-access account sees no Devoluciones and no '
        'Devolver', () async {
      if (_noAccessUser.isEmpty || _noAccessPass.isEmpty) {
        // ignore: avoid_print
        print('QS-STEP SKIP 10. MBE_TEST_USERNAME/_PASSWORD not set');
        return;
      }
      await go('/');
      await tester.tap(find.byIcon(Icons.account_circle).hitTestable());
      await pumpFor(const Duration(milliseconds: 500));
      await tester.tap(byKey('user_menu_logout').hitTestable());
      await login(_noAccessUser, _noAccessPass);

      final ids = [
        for (final item in container().read(navDestinationsProvider))
          ...switch (item) {
            NavDestination() => [item.id],
            NavGroup() => item.children.map((d) => d.id),
          },
      ];
      expect(ids, isNot(contains('refunds')));
      expect(find.text(l10n.refundsMenuTitle), findsNothing);

      await go('/sales/refunds');
      await pumpFor(const Duration(seconds: 1));
      expect(
        location(),
        isNot('/sales/refunds'),
        reason: '/sales/refunds must redirect',
      );
      // ignore: avoid_print
      print('QS: /sales/refunds redirected to ${location()}');

      await go('/sales/orders/${fx.orderId}');
      await pumpFor(const Duration(seconds: 3));
      expect(byKey('order_refund_button'), findsNothing);
      await go('/sales/pos/${fx.orderId}');
      await pumpFor(const Duration(seconds: 3));
      expect(byKey('order_refund_button'), findsNothing);
    });

    expect(failures, isEmpty, reason: failures.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 15)));
}
