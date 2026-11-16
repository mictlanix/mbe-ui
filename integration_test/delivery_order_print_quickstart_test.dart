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
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_print.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/064-delivery-order-print/quickstart.md against the REAL app
/// (macOS desktop) and a live mbe-api (research R11, task T022).
///
///   caffeinate -dimsu flutter test \
///     integration_test/delivery_order_print_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=...   (and _PASSWORD; administrator)
///
/// **Read-only.** It never writes: it finds, through the API, orders already
/// on the tenant (a printable one, an unprintable one and, if there is one,
/// an order whose lines come from two warehouses), then drives the app on
/// them. A step that has no data to run on is reported SKIP, never PASS.
///
/// The documents themselves are rendered by mbe-api and checked there; what
/// this proves is that the app offers the right actions, opens the right
/// document in the preview and asks the right question first.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');

const _wide = Size(1400, 1000);
const _phone = Size(400, 900);
const _list = '/sales/delivery-orders';

enum _Outcome { pass, fail, skip }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

/// Thrown by a step that has nothing to run on.
class _Skip implements Exception {
  _Skip(this.reason);
  final String reason;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Delivery order print walkthrough (real app, live mbe-api)', (
    tester,
  ) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }

    // Frame watchdog: see reference_macos_integration_test_traps. When the
    // app window is not frontmost macOS can stop delivering frames and every
    // pump then waits forever.
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
    addTearDown(() {
      watchdog.cancel();
      // ignore: avoid_print
      print('QS: frame watchdog drove $kicks frame(s)');
    });

    // ------------------------------------------------------------------
    // API side: find the orders to drive
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final admin = DeliveryOrderAdminRepositoryImpl(dio);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    final everything = (await admin.list(
      statuses: DeliveryOrderStatus.values,
      limit: 50,
    )).items;
    bool printable(DeliveryOrderSummary o) =>
        o.status != DeliveryOrderStatus.draft &&
        o.status != DeliveryOrderStatus.pendingApproval;
    final printables = [
      for (final o in everything)
        if (printable(o) && o.serial != null) o,
    ];
    final unprintable = everything.where((o) => !printable(o)).firstOrNull;

    // One printable order whose lines come from one warehouse, and one from
    // several, by reading each order's lines (the list has none).
    DeliveryOrder? single;
    DeliveryOrder? multi;
    for (final summary in printables.take(15)) {
      final order = await admin.getById(summary.id);
      final warehouses = distinctWarehouses(order.lines);
      if (warehouses.length >= 2) {
        multi ??= order;
      } else if (warehouses.isNotEmpty) {
        single ??= order;
      }
      if (single != null && multi != null) break;
    }

    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    note(
      'tenant: ${everything.length} order(s); printable ${printables.length}; '
      'unprintable '
      '${unprintable == null ? 'none' : '#${unprintable.id} ${unprintable.status.name}'}; '
      'single-warehouse ${single?.id ?? 'none'}; '
      'multi-warehouse ${multi?.id ?? 'none'}',
    );

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

    ProviderContainer container() =>
        ProviderScope.containerOf(tester.element(find.byType(App)));
    GoRouter router() => container().read(goRouterProvider);

    // ------------------------------------------------------------------
    // Harness helpers
    // ------------------------------------------------------------------
    Future<void> pumpFor(Duration d) async {
      final end = DateTime.now().add(d);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilTrue(
      bool Function() cond,
      String what, {
      Duration timeout = const Duration(seconds: 40),
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

    Future<void> pumpUntil(Finder f, {Duration? timeout}) => pumpUntilTrue(
      () => f.evaluate().isNotEmpty,
      '$f',
      timeout: timeout ?? const Duration(seconds: 40),
    );

    Future<void> pumpUntilGone(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f');

    Finder byKey(String k) => find.byKey(Key(k));
    bool spinning() =>
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

    Future<void> tapFinder(Finder f) async {
      await pumpUntil(f);
      await tester.ensureVisible(f.first);
      await pumpFor(const Duration(milliseconds: 300));
      await pumpUntil(f.hitTestable());
      await tester.tap(f.hitTestable().first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> tapKey(String k) => tapFinder(byKey(k));

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
      );
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> go(String path) async {
      router().go(path);
      await pumpFor(const Duration(milliseconds: 500));
    }

    /// The list for one order: every status, narrowed to its folio.
    Future<void> openListFor(DeliveryOrder order) async {
      await go('$_list?status=all&search=${order.serial}');
      await pumpUntilTrue(
        () =>
            byKey('delivery_orders_table').evaluate().isNotEmpty && !spinning(),
        'the list for folio ${order.serial}',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Future<void> openDetail(int id) async {
      await go(_list);
      await go('$_list/$id');
      await pumpUntilTrue(
        () =>
            byKey('delivery_order_facts').evaluate().isNotEmpty && !spinning(),
        'delivery order $id',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// The preview is open and its pages have rendered.
    Future<void> waitForPreview() async {
      await pumpUntil(byKey('document_preview_surface'));
      await pumpUntilTrue(
        () =>
            byKey('document_page_indicator').evaluate().isNotEmpty &&
            find
                .descendant(
                  of: byKey('document_preview_surface'),
                  matching: find.byType(CircularProgressIndicator),
                )
                .evaluate()
                .isEmpty,
        'document rendered',
      );
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> closePreview() async {
      await tapKey('document_preview_close');
      await pumpUntilGone(byKey('document_preview_surface'));
    }

    String previewTitle() =>
        tester.widget<Text>(byKey('document_preview_title')).data ?? '';

    Future<void> recover() async {
      for (var i = 0; i < 4; i++) {
        final dlg = find.byType(Dialog);
        if (dlg.evaluate().isEmpty) break;
        Navigator.of(tester.element(dlg.first), rootNavigator: true).pop();
        await pumpFor(const Duration(milliseconds: 400));
      }
      tester.takeException();
      tester.view.physicalSize = _wide;
    }

    final results = <_Result>[];
    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: ${_short(ex)}');
        results.add(_Result(name, _Outcome.pass, 'ok'));
      } on _Skip catch (skip) {
        results.add(_Result(name, _Outcome.skip, skip.reason));
      } catch (e) {
        await recover();
        results.add(_Result(name, _Outcome.fail, _short(e)));
      }
      // ignore: avoid_print
      print(
        'QS-STEP ${results.last.outcome.name.toUpperCase()} '
        '${results.last.name} :: ${results.last.detail}',
      );
    }

    // ------------------------------------------------------------------
    // Login and the walkthrough
    // ------------------------------------------------------------------
    note('logging in as admin (read-only)');
    await login(_adminUser, _adminPass);

    // ---- 1: an order that can't print has no action (US1-3, US2-2) --------
    await step('1 a draft or pending order offers no print action', () async {
      final order = unprintable;
      if (order == null) throw _Skip('no draft or pending order on the tenant');
      await openDetail(order.id);
      expect(byKey('delivery_order_view_ticket'), findsNothing);
      expect(byKey('delivery_order_view_letter'), findsNothing);
      await go('$_list?status=all');
      await pumpUntil(byKey('delivery_orders_table'));
      await pumpFor(const Duration(milliseconds: 600));
      expect(byKey('delivery_order_view_ticket_${order.id}'), findsNothing);
    });

    // ---- 2: the ticket from the list row (US2-1, US2-3) ------------------
    await step('2 a list row opens its ticket in the preview', () async {
      final order = single;
      if (order == null) throw _Skip('no one-warehouse printable order');
      await openListFor(order);
      final icon = byKey('delivery_order_view_ticket_${order.id}');
      expect(icon, findsOneWidget);
      final uriBefore = router().state.uri.toString();
      await tapFinder(icon);
      await waitForPreview();
      expect(
        previewTitle(),
        l10n.documentDeliveryTicketTitle('${order.serial}'),
      );
      await closePreview();
      // The list is as it was: same address, same row (FR-040).
      expect(router().state.uri.toString(), uriBefore);
      expect(icon, findsOneWidget);
    });

    // ---- 3: the ticket and the Letter format from the detail (US1, US4) ---
    await step('3 the detail screen opens the ticket and the letter', () async {
      final order = single;
      if (order == null) throw _Skip('no one-warehouse printable order');
      await openDetail(order.id);
      expect(byKey('delivery_order_view_ticket'), findsOneWidget);
      expect(byKey('delivery_order_view_letter'), findsOneWidget);

      await tapKey('delivery_order_view_ticket');
      await waitForPreview();
      expect(
        previewTitle(),
        l10n.documentDeliveryTicketTitle('${order.serial}'),
      );
      await closePreview();

      await tapKey('delivery_order_view_letter');
      await waitForPreview();
      expect(
        previewTitle(),
        l10n.documentDeliveryOrderLetterTitle('${order.serial}'),
      );
      await closePreview();
    });

    // ---- 4: two warehouses ask first (US3) ------------------------------
    await step('4 a two-warehouse order asks which lines to print', () async {
      final order = multi;
      if (order == null) throw _Skip('no two-warehouse printable order');
      final warehouses = distinctWarehouses(order.lines);
      await openDetail(order.id);

      // Dismissing opens nothing.
      await tapKey('delivery_order_view_ticket');
      await pumpUntil(byKey('delivery_ticket_scope_dialog'));
      expect(byKey('delivery_ticket_scope_all'), findsOneWidget);
      for (final id in warehouses) {
        expect(byKey('delivery_ticket_scope_$id'), findsOneWidget);
      }
      await tapKey('delivery_ticket_scope_cancel');
      await pumpUntilGone(byKey('delivery_ticket_scope_dialog'));
      expect(byKey('document_preview_surface'), findsNothing);

      // One warehouse: the title names it.
      await tapKey('delivery_order_view_ticket');
      await pumpUntil(byKey('delivery_ticket_scope_dialog'));
      await tapKey('delivery_ticket_scope_${warehouses.first}');
      await tapKey('delivery_ticket_scope_confirm');
      await waitForPreview();
      final title = previewTitle();
      expect(
        title.startsWith(l10n.documentDeliveryTicketTitle('${order.serial}')),
        isTrue,
        reason: title,
      );
      expect(
        title.split(' · ').length,
        3,
        reason: 'folio and warehouse: $title',
      );
      await closePreview();

      // Every line: no warehouse in the title.
      await tapKey('delivery_order_view_ticket');
      await pumpUntil(byKey('delivery_ticket_scope_dialog'));
      await tapKey('delivery_ticket_scope_confirm');
      await waitForPreview();
      expect(
        previewTitle(),
        l10n.documentDeliveryTicketTitle('${order.serial}'),
      );
      await closePreview();

      // From the list the same question comes after a brief lookup.
      await openListFor(order);
      await tapKey('delivery_order_view_ticket_${order.id}');
      await pumpUntil(byKey('delivery_ticket_scope_dialog'));
      await tapKey('delivery_ticket_scope_cancel');
      await pumpUntilGone(byKey('delivery_ticket_scope_dialog'));
    });

    // ---- 5: phone width (quickstart 11) --------------------------------
    await step(
      '5 phone width keeps the row action and a full preview',
      () async {
        final order = single;
        if (order == null) throw _Skip('no one-warehouse printable order');
        tester.view.physicalSize = _phone;
        await openListFor(order);
        await tapKey('delivery_order_view_ticket_${order.id}');
        await waitForPreview();
        final surface = tester.getSize(byKey('document_preview_surface'));
        expect(surface.width, _phone.width, reason: 'fullscreen on a phone');
        await closePreview();
        tester.view.physicalSize = _wide;
        await pumpFor(const Duration(milliseconds: 400));
      },
    );

    // ------------------------------------------------------------------
    // Summary
    // ------------------------------------------------------------------
    note('==== RESULTS ====');
    for (final r in results) {
      note(
        '${r.outcome.name.toUpperCase().padRight(4)} ${r.name} :: ${r.detail}',
      );
    }
    final failed = results.where((r) => r.outcome == _Outcome.fail).toList();
    expect(
      failed,
      isEmpty,
      reason: failed.map((r) => '${r.name}: ${r.detail}').join('\n'),
    );
  }, timeout: const Timeout(Duration(minutes: 15)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
