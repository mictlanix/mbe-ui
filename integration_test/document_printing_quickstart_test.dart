import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
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
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';

/// Automates the in-app part of specs/044-document-printing/quickstart.md §2
/// (T044) against the REAL app (macOS desktop) and a live mbe-api: M2, the
/// button half of M3, M4, the prompt half of M5, M6's reprint, M8, and H2's
/// full-screen layout at phone width.
///
///   caffeinate -dimsu flutter test \
///     integration_test/document_printing_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=...   (and _PASSWORD; administrator)
///     --dart-define=MBE_QA054_USERNAME=... (and _PASSWORD; no POS read)
///     --dart-define=MBE_QA033_USERNAME=... (and _PASSWORD; no Sales Orders)
///
/// Not covered, because they need a browser or a person: M1 (the browser's
/// print preview), pinch and trackpad zoom in M3, M7 (stopping mbe-api), M9
/// (DevTools network log), H1 (thermal printer) and H2's phone browser.
/// Read-only: it opens documents and leaves every record as it was.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noPosUser = String.fromEnvironment('MBE_QA054_USERNAME');
const _noPosPass = String.fromEnvironment('MBE_QA054_PASSWORD');
const _noOrdersUser = String.fromEnvironment('MBE_QA033_USERNAME');
const _noOrdersPass = String.fromEnvironment('MBE_QA033_PASSWORD');

const _wide = Size(1400, 1000);
const _phone = Size(400, 900);

enum _Outcome { pass, fail, soft }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Document printing quickstart, in-app checks (real app, live '
      'mbe-api)', (tester) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }

    // ------------------------------------------------------------------
    // Fixtures, read through the API
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';

    Future<int?> firstOrder(int origin, String status) async {
      final res = await dio.get<Map<String, dynamic>>(
        '/api/v1/sales-orders',
        queryParameters: {'origin': origin, 'status': status, 'limit': 1},
      );
      final items = (res.data!['items'] as List).cast<Map>();
      return items.isEmpty ? null : items.first['sales_order_id'] as int;
    }

    final posCompleted = await firstOrder(0, 'completed');
    final posDraft = await firstOrder(0, 'draft');
    final officeCompleted = await firstOrder(1, 'completed');
    final officeDraft = await firstOrder(1, 'draft');
    final sessions = await dio.get<Map<String, dynamic>>(
      '/api/v1/cash-sessions',
      queryParameters: {'limit': 20},
    );
    final closedSession = (sessions.data!['items'] as List)
        .cast<Map>()
        .where((s) => s['end'] != null)
        .firstOrNull;
    final closed = closedSession?['cash_session_id'] as int?;
    // The list shows no id; a row is found by its start, as "yyyy-MM-dd HH:mm".
    final closedStart = (closedSession?['start'] as String?)
        ?.substring(0, 16)
        .replaceFirst('T', ' ');

    // ------------------------------------------------------------------
    // App boot (mirrors lib/main.dart)
    // ------------------------------------------------------------------
    // Frame watchdog, as in pricing_grid_quickstart_test.dart: when the app
    // window is not frontmost ("Failed to foreground app"), macOS can stop
    // delivering frames and every pump waits forever. A scheduled frame that
    // hasn't begun within ~1.5 s is driven by hand.
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
    String location() =>
        router().routerDelegate.currentConfiguration.last.matchedLocation;

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
      Duration timeout = const Duration(seconds: 30),
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

    Future<void> pumpUntil(
      Finder f, {
      Duration timeout = const Duration(seconds: 30),
    }) => pumpUntilTrue(() => f.evaluate().isNotEmpty, '$f', timeout: timeout);

    Future<void> pumpUntilGone(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f');

    Finder byKey(String k) => find.byKey(Key(k));

    Future<void> tapKey(String k) async {
      final f = byKey(k);
      await pumpUntil(f);
      await tester.ensureVisible(f.first);
      await pumpFor(const Duration(milliseconds: 300));
      await tester.tap(f.first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    String textOf(String k) {
      final texts = find
          .descendant(of: byKey(k), matching: find.byType(Text))
          .evaluate()
          .map((e) => (e.widget as Text).data ?? '');
      if (byKey(k).evaluate().single.widget case final Text t) {
        return t.data ?? '';
      }
      return texts.join(' ');
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

    Future<void> login(String user, String pass) async {
      // After a sign-out more than one login screen can be mounted; only the
      // visible one takes input.
      final userField = byKey('login_username_field').hitTestable();
      final passField = byKey('login_password_field').hitTestable();
      await pumpUntil(userField);
      await pumpFor(const Duration(seconds: 1));
      await tester.enterText(userField.first, user);
      await tester.enterText(passField.first, pass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(passField.first);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilGone(userField);
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> go(String path) async {
      router().go(path);
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> recover() async {
      for (var i = 0; i < 4; i++) {
        final dlg = find.byType(Dialog);
        if (dlg.evaluate().isEmpty) break;
        Navigator.of(tester.element(dlg.first), rootNavigator: true).pop();
        await pumpFor(const Duration(milliseconds: 400));
      }
      tester.takeException();
    }

    final results = <_Result>[];
    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: ${_short(ex)}');
        results.add(_Result(name, _Outcome.pass, 'ok'));
      } catch (e) {
        try {
          final texts = find
              .byType(Text)
              .evaluate()
              .map((el) => (el.widget as Text).data ?? '')
              .where((t) => t.isNotEmpty)
              .take(50)
              .toList();
          // ignore: avoid_print
          print('QS-DBG loc=${location()} texts=$texts');
        } catch (_) {}
        await recover();
        results.add(_Result(name, _Outcome.fail, _short(e)));
      }
      // ignore: avoid_print
      print(
        'QS-STEP ${results.last.outcome.name.toUpperCase()} '
        '${results.last.name} :: ${results.last.detail}',
      );
    }

    void soft(String name, String text) {
      results.add(_Result(name, _Outcome.soft, text));
      // ignore: avoid_print
      print('QS-STEP SOFT $name :: $text');
    }

    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    note(
      'pos completed $posCompleted, pos draft $posDraft, office completed '
      '$officeCompleted, office draft $officeDraft, closed session $closed',
    );
    await login(_adminUser, _adminPass);

    // ---- M2 + M3 (buttons) ----
    for (final (label, id) in [('paid', posCompleted), ('draft', posDraft)]) {
      if (id == null) {
        soft('M2 $label POS sale ticket', 'no $label POS sale on the tenant');
        continue;
      }
      await step('M2 $label POS sale ticket opens, "Página 1 / 1"', () async {
        await go('/sales/pos/$id');
        await tapKey('pos_sale_detail_ticket');
        await waitForPreview();
        expect(textOf('document_page_indicator'), contains('1 / 1'));
        if (label == 'paid') {
          final fit = textOf('document_zoom_level');
          await tapKey('document_zoom_in');
          final once = textOf('document_zoom_level');
          await tapKey('document_zoom_in');
          final twice = textOf('document_zoom_level');
          expect({fit, once, twice}.length, 3, reason: 'level readout steps');
          // A plain wheel scrolls; it must not zoom.
          final pages = byKey('document_preview_pages');
          final at = tester.getCenter(pages);
          final pointer = TestPointer(1, PointerDeviceKind.mouse);
          await tester.sendEventToBinding(pointer.hover(at));
          await tester.sendEventToBinding(pointer.scroll(const Offset(0, 120)));
          await pumpFor(const Duration(milliseconds: 400));
          expect(textOf('document_zoom_level'), twice);
          await tapKey('document_zoom_fit');
          expect(textOf('document_zoom_level'), fit);
        }
        await closePreview();
      });
    }

    // ---- M4 ----
    if (officeCompleted == null) {
      soft('M4 pedido', 'no back-office order on the tenant');
    } else {
      await step('M4 pedido preview within 3 s of Ver pedido', () async {
        await go('/sales/orders/$officeCompleted');
        await pumpUntil(byKey('sales_order_view_pedido_button'));
        final button = byKey('sales_order_view_pedido_button');
        await tester.ensureVisible(button);
        await pumpFor(const Duration(milliseconds: 300));
        final watch = Stopwatch()..start();
        await tester.tap(button);
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
          'pedido rendered',
        );
        final ms = watch.elapsedMilliseconds;
        note('M4 pedido on screen in $ms ms (100 ms pump granularity)');
        expect(ms, lessThan(3000), reason: 'SC-002');
        expect(byKey('document_download'), findsOneWidget);
        expect(byKey('document_print'), findsOneWidget);
        await closePreview();
      });
      soft(
        'M4 multi-page pedido',
        'every back-office order on the tenant has one line, so no pedido '
            'runs past one page; page-in-view arithmetic is unit-tested',
      );
    }

    // ---- M5 (prompt half) ----
    if (officeDraft == null) {
      soft('M5 unconfirmed comment', 'no back-office draft on the tenant');
    } else {
      await step(
        'M5 unconfirmed comment prompts; Seguir editando cancels',
        () async {
          await go('/sales/orders/$officeDraft');
          // The comment lives in the header's disclosed group (spec 032).
          final more = find.text('Más detalles');
          await pumpUntil(more);
          await tester.tap(more.first);
          await pumpFor(const Duration(milliseconds: 500));
          final field = find.descendant(
            of: byKey('sales_order_comment_field'),
            matching: find.byType(EditableText),
          );
          await pumpUntil(field);
          final original = tester.widget<EditableText>(field).controller.text;
          await tester.ensureVisible(field);
          await tester.enterText(field, '${original}QS044');
          await pumpFor(const Duration(milliseconds: 300));
          int pending() => container()
              .read(unconfirmedEditsProvider(salesOrderWritesScope))
              .length;
          note('M5 pending edits after typing: ${pending()}');
          // A mouse click, as on desktop or web.
          final pedido = byKey('sales_order_view_pedido_button');
          await tester.ensureVisible(pedido);
          await tester.tap(pedido, kind: PointerDeviceKind.mouse);
          await pumpFor(const Duration(milliseconds: 600));
          note(
            'M5 after tapping Ver pedido: pending ${pending()}, prompt '
            '${find.text('Cambios sin confirmar').evaluate().length}, preview '
            '${byKey('document_preview_surface').evaluate().length}',
          );
          await pumpUntil(find.text('Cambios sin confirmar'));
          await tester.tap(find.text('Seguir editando').last);
          await pumpFor(const Duration(milliseconds: 500));
          expect(byKey('document_preview_surface'), findsNothing);
          // Put the text back and leave without saving anything.
          await tester.enterText(field, original);
          await pumpFor(const Duration(milliseconds: 300));
          await go('/sales/orders');
          final discard = find.text('Descartar');
          if (discard.evaluate().isNotEmpty) {
            await tester.tap(discard.last);
            await pumpFor(const Duration(milliseconds: 500));
          }
          final after = await dio.get<Map<String, dynamic>>(
            '/api/v1/sales-orders/$officeDraft',
          );
          expect(after.data!['comment'] ?? '', original, reason: 'unchanged');
        },
      );
    }

    // ---- M6 (reprint) ----
    if (closed == null) {
      soft('M6 cut reprint', 'no closed cash session on the tenant');
    } else {
      await step('M6 reprint a closed session\'s cut in under 30 s', () async {
        final watch = Stopwatch()..start();
        await go('/sales/cash-sessions');
        final row = find.text(closedStart!);
        await pumpUntil(row);
        await tester.tap(row.first);
        await pumpUntil(byKey('cash_session_view_cut_button'));
        await tapKey('cash_session_view_cut_button');
        await waitForPreview();
        final ms = watch.elapsedMilliseconds;
        note('M6 cut on screen in $ms ms from opening the list');
        expect(ms, lessThan(30000), reason: 'SC-007');
        await closePreview();
      });
    }
    soft(
      'M6 close then Ver corte',
      'not run: needs an open session to close; no session is open on the '
          'tenant, and opening one only to close it would add records',
    );

    // ---- H2 (layout half) ----
    if (officeCompleted != null) {
      await step('H2 phone width: the preview is full-screen', () async {
        tester.view.physicalSize = _phone;
        await go('/sales/orders/$officeCompleted');
        await tapKey('sales_order_view_pedido_button');
        await waitForPreview();
        final surface = tester.getSize(byKey('document_preview_surface'));
        expect(surface.width, _phone.width);
        expect(tester.takeException(), isNull);
        await closePreview();
        tester.view.physicalSize = _wide;
        await pumpFor(const Duration(milliseconds: 500));
      });
    }

    // ---- M8 ----
    if (_noPosUser.isEmpty) {
      soft('M8 no POS read', 'MBE_QA054_* not set');
    } else {
      await step('M8 without POS read: pedido yes, no cut anywhere', () async {
        await container().read(authProvider.notifier).signOut();
        await login(_noPosUser, _noPosPass);
        if (officeCompleted != null) {
          await go('/sales/orders/$officeCompleted');
          await pumpUntil(byKey('sales_order_view_pedido_button'));
        }
        if (closed != null) {
          await go('/sales/cash-sessions/$closed');
          expect(location(), isNot('/sales/cash-sessions/$closed'));
          expect(byKey('cash_session_view_cut_button'), findsNothing);
        }
        await go('/sales/pos/${posCompleted ?? 0}');
        expect(byKey('pos_sale_detail_ticket'), findsNothing);
      });
    }
    if (_noOrdersUser.isEmpty) {
      soft('M8 no Sales Orders read', 'MBE_QA033_* not set');
    } else {
      await step('M8 without Sales Orders read: no ticket or pedido', () async {
        await container().read(authProvider.notifier).signOut();
        await login(_noOrdersUser, _noOrdersPass);
        final auth = container().read(authProvider).value;
        note(
          'M8 signed in as ${auth is AuthAuthenticated ? auth.user.userId : auth}; '
          'can read sales orders: '
          '${container().read(accessControlProvider).can(SystemObject.salesOrders, AccessRight.read)}',
        );
        for (final path in [
          if (officeCompleted != null) '/sales/orders/$officeCompleted',
          if (posCompleted != null) '/sales/pos/$posCompleted',
        ]) {
          await go(path);
          expect(location(), isNot(path), reason: '$path is gated');
          expect(byKey('sales_order_view_pedido_button'), findsNothing);
          expect(byKey('pos_sale_detail_ticket'), findsNothing);
        }
      });
    }

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
  }, timeout: const Timeout(Duration(minutes: 10)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
