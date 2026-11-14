import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verification_queue_controller.dart';

/// Automates specs/060-payment-verification/quickstart.md against the REAL app
/// (macOS desktop) and a live mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/payment_verification_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=...   (and _PASSWORD; administrator)
///     [--dart-define=MBE_WRITE=true]
///
/// **Read-only by default.** It checks that the queue loads, lists transfers
/// from the API's own count, opens a row's read-only panel, and fits at the
/// largest text size. With `MBE_WRITE=true` it also drives the real writes,
/// each on a fresh 1.00 transfer it records itself (a credit payment, which
/// needs no cash session): one is verified from the queue, one is rejected and
/// stays listed, one is verified from the payment view, and one is refused as
/// already verified.
///
/// **Verification can't be undone and a payment can't be deleted, so each
/// write run leaves three verified 1.00 transfers and one rejected, still
/// unverified one on the tenant.** (The fourth checks the already-verified
/// refusal: it is verified through the API under a stale queue row.) Never point a write step at a seeded
/// fixture. Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');

const _wide = Size(1400, 1000);
const _desktop = Size(1680, 1000);
const _queue = '/sales/payment-verification';

enum _Outcome { pass, fail }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Payment verification walkthrough (real app, live mbe-api)', (
    tester,
  ) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }

    // ------------------------------------------------------------------
    // API side (independent of the app's own session)
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final payments = CustomerPaymentRepositoryImpl(dio);
    final customers = CustomerRepositoryImpl(dio);

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

    Future<void> pumpUntil(Finder f, {Duration? timeout}) => pumpUntilTrue(
      () => f.evaluate().isNotEmpty,
      '$f',
      timeout: timeout ?? const Duration(seconds: 30),
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
      await tester.tap(f.first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> tapKey(String k) => tapFinder(byKey(k));

    Future<void> login(String user, String pass) async {
      await pumpUntil(byKey('login_username_field'));
      await tester.enterText(byKey('login_username_field'), user);
      await tester.enterText(byKey('login_password_field'), pass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey('login_password_field'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilTrue(
        () => byKey('login_username_field').evaluate().isEmpty,
        'login finished',
        timeout: const Duration(seconds: 40),
      );
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> go(String path) async {
      router().go(path);
      await pumpFor(const Duration(milliseconds: 500));
    }

    /// Opens the queue (optionally with [query]) and waits for its table or
    /// its empty state.
    ///
    /// The queue is invalidated first: going to the address the router is
    /// already on keeps the page it holds, which predates a payment this test
    /// has just recorded through the API.
    Future<void> openQueue([String query = '']) async {
      container().invalidate(verificationQueueControllerProvider);
      router().go('$_queue$query');
      await pumpUntilTrue(
        () =>
            (byKey('verification_table').evaluate().isNotEmpty ||
                find.textContaining('No hay pagos').evaluate().isNotEmpty ||
                find.textContaining('sin verificar').evaluate().isNotEmpty) &&
            !spinning(),
        'the queue loaded',
      );
      await pumpFor(const Duration(milliseconds: 800));
    }

    /// Closes whatever dialog or panel a failed step left open.
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
        await recover();
        results.add(_Result(name, _Outcome.fail, _short(e)));
      }
      // ignore: avoid_print
      print(
        'QS-STEP ${results.last.outcome.name.toUpperCase()} '
        '${results.last.name} :: ${results.last.detail}',
      );
    }

    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    // ---- constitution §V: the largest text size, real fonts --------------
    // Checked here rather than in a widget test: only the live app renders
    // with the real fonts, and widget tests' placeholder font is far wider.
    final money = RegExp(r'^\$[\d,]+\.\d{2}( [A-Z]{3})?$');
    final dateText = RegExp(r'^\d{4}-\d{2}-\d{2}( \d{2}:\d{2})?$');
    List<String> clipped(Finder? within) {
      final cut = <String>{};
      final texts = within == null
          ? find.byType(Text)
          : find.descendant(of: within, matching: find.byType(Text));
      for (final element in texts.evaluate()) {
        final text = (element.widget as Text).data ?? '';
        if (!money.hasMatch(text) && !dateText.hasMatch(text)) continue;
        final paragraph = element.renderObject;
        if (paragraph is! RenderParagraph) continue;
        final needed = paragraph.getMaxIntrinsicWidth(double.infinity);
        if (paragraph.size.width + 0.5 < needed) {
          cut.add(
            '"$text" ${paragraph.size.width.toStringAsFixed(1)} of '
            '${needed.toStringAsFixed(1)}',
          );
        }
      }
      return cut.toList();
    }

    /// Runs [body] at the largest of the four text sizes on a desktop-width
    /// window, then puts both back. Fails on clipped money or dates, or on any
    /// framework (overflow) exception raised meanwhile.
    Future<void> atLargestText(
      Future<void> Function() body, {
      Finder? within,
    }) async {
      final prefsController = container().read(
        userDisplayPreferencesControllerProvider.notifier,
      );
      await prefsController.setTextSizeLevel(TextSizeLevel.extraLarge);
      tester.view.physicalSize = _desktop;
      await pumpFor(const Duration(milliseconds: 800));
      try {
        await body();
        await pumpFor(const Duration(milliseconds: 500));
        final cut = clipped(within);
        final ex = tester.takeException();
        expect(cut, isEmpty, reason: 'clipped: ${cut.join('; ')}');
        expect(ex, isNull, reason: 'overflow: ${ex == null ? '' : _short(ex)}');
      } finally {
        await prefsController.setTextSizeLevel(TextSizeLevel.normal);
        tester.view.physicalSize = _wide;
        await pumpFor(const Duration(milliseconds: 500));
      }
    }

    // ------------------------------------------------------------------
    // Login (admin) and what the API says the queue holds
    // ------------------------------------------------------------------
    note('logging in as admin${_write ? ' (WRITE mode)' : ' (read-only)'}');
    await login(_adminUser, _adminPass);

    final transfers = await payments.listUnverified(
      methodCode: PaymentMethod.eft.code,
      limit: 20,
    );
    final everyMethod = await payments.listUnverified(limit: 20);
    note(
      'queue: ${transfers.total} unverified transfers, '
      '${everyMethod.total} unverified payments of any method',
    );

    // ---- 1: the queue opens on transfers (US1-1, US1-2) ------------------
    await step(
      '1 the queue opens, on transfers, with the API\'s total',
      () async {
        await openQueue();
        expect(location(), _queue, reason: 'not redirected away');
        expect(byKey('verification_filter_button'), findsOneWidget);
        if (transfers.items.isEmpty) {
          note('no unverified transfers: the empty state is on screen');
          return;
        }
        expect(byKey('verification_table'), findsOneWidget);
        // The newest transfer is the first row: the queue is newest first.
        final newest = transfers.items.first.customerPaymentId;
        expect(find.text('$newest'), findsWidgets);
        // The footer formats the total with a thousands separator
        // ("1–20 de 26,247"), so compare its digits only.
        final total = '${transfers.total}';
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Text &&
                (w.data ?? '').contains(' de ') &&
                (w.data ?? '').replaceAll(RegExp(r'[^\d]'), '').endsWith(total),
          ),
          findsWidgets,
          reason: 'footer total $total',
        );
      },
    );

    // ---- 2: "Todos" shows other methods (FR-003) -------------------------
    await step('2 method "Todos" lists every method', () async {
      await openQueue('?method=all');
      if (everyMethod.items.isEmpty) return;
      final newest = everyMethod.items.first.customerPaymentId;
      expect(find.text('$newest'), findsWidgets);
    });

    // ---- 3: a row tap opens the read-only panel (FR-005a) ----------------
    await step('3 a row tap opens the read-only panel from the row', () async {
      if (transfers.items.isEmpty) return;
      await openQueue();
      final target = transfers.items.first;
      await tester.tap(find.text('${target.customerPaymentId}').first);
      await pumpUntil(byKey('verification_panel_${target.customerPaymentId}'));
      expect(find.text('Pago ${target.customerPaymentId}'), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await pumpFor(const Duration(milliseconds: 600));
      await pumpUntilGone(
        byKey('verification_panel_${target.customerPaymentId}'),
      );
    });

    // ---- 4: largest text size (constitution §V) --------------------------
    await step('4a largest text: the queue fits', () async {
      await atLargestText(() async {
        await openQueue();
      });
    });

    await step('4b largest text: the row panel fits', () async {
      if (transfers.items.isEmpty) return;
      final target = transfers.items.first;
      await openQueue();
      await atLargestText(() async {
        await tester.tap(find.text('${target.customerPaymentId}').first);
        await pumpUntil(
          byKey('verification_panel_${target.customerPaymentId}'),
        );
        await pumpFor(const Duration(milliseconds: 600));
      }, within: byKey('verification_panel_${target.customerPaymentId}'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await pumpFor(const Duration(milliseconds: 600));
    });

    // ------------------------------------------------------------------
    // Writes (only with MBE_WRITE=true)
    // ------------------------------------------------------------------
    if (!_write) {
      note('MBE_WRITE is not set: skipping the steps that change data.');
    } else {
      // A named customer: the walk-in customer can't hold a payment.
      final page = await customers.list(limit: 10);
      final customer = page.items.firstWhere((c) => c.customerId != 1);

      Future<int> recordTransfer(String tag) => payments.createPayment(
        customer: customer.customerId,
        amount: '1.00',
        method: PaymentMethod.eft.code,
        type: PaymentType.creditPayment,
        reference:
            'QA060-$tag-${DateTime.now().millisecondsSinceEpoch % 100000}',
      );

      int? fromQueue;
      int? rejected;
      int? fromView;

      await step(
        '5 verify from the queue: the row leaves, the API agrees',
        () async {
          final id = await recordTransfer('Q');
          fromQueue = id;
          note('recorded payment $id (stays on the tenant)');
          await openQueue();
          await tapKey('verify_payment_$id');
          await pumpUntil(byKey('verify_payment_dialog'));
          expect(find.textContaining('No se puede deshacer'), findsOneWidget);
          await tapKey('verify_payment_confirm');
          await pumpUntilGone(byKey('verify_payment_dialog'));
          await pumpUntilGone(byKey('verify_payment_$id'));
          expect(find.text('Pago $id verificado.'), findsOneWidget);
          final after = await payments.get(customerPaymentId: id);
          expect(after.verifierId, isNotNull, reason: 'verified on the server');
        },
      );

      await step(
        '6 reject from the queue: it stays listed, unverified',
        () async {
          final id = await recordTransfer('R');
          rejected = id;
          note('recorded payment $id (stays on the tenant, unverified)');
          await openQueue();
          await tapKey('reject_payment_$id');
          await pumpUntil(byKey('reject_payment_dialog'));
          expect(
            tester
                .widget<FilledButton>(byKey('reject_payment_confirm'))
                .enabled,
            isFalse,
            reason: 'no reason, no rejection',
          );
          await tester.enterText(
            byKey('reject_reason_field'),
            'QA060 walkthrough',
          );
          await pumpFor(const Duration(milliseconds: 200));
          await tapKey('reject_payment_confirm');
          await pumpUntilGone(byKey('reject_payment_dialog'));
          await pumpFor(const Duration(seconds: 1));
          expect(
            find.textContaining('sigue sin verificar y seguirá en la lista'),
            findsOneWidget,
          );
          expect(byKey('verify_payment_$id'), findsOneWidget);
          final after = await payments.get(customerPaymentId: id);
          expect(
            after.verifierId,
            isNull,
            reason: 'a rejection verifies nothing',
          );
        },
      );

      await step('7 verify from the payment view', () async {
        final id = await recordTransfer('V');
        fromView = id;
        note('recorded payment $id (stays on the tenant)');
        await go('/sales/payments/$id');
        await pumpUntil(byKey('payment_verify_button'));
        expect(byKey('payment_reject_button'), findsOneWidget);
        await tapKey('payment_verify_button');
        await pumpUntil(byKey('verify_payment_dialog'));
        await tapKey('verify_payment_confirm');
        await pumpUntilGone(byKey('verify_payment_dialog'));
        await pumpUntilGone(byKey('payment_verify_button'));
        expect(find.text('Verificado'), findsWidgets);
        expect(byKey('payment_reject_button'), findsNothing);
        final after = await payments.get(customerPaymentId: id);
        expect(after.verifierId, isNotNull);
      });

      await step('8 an already-verified payment is refused with its own '
          'message', () async {
        // The queue still holds a stale row nobody reloaded: open it first,
        // then let the API verify the payment underneath it.
        final id = await recordTransfer('S');
        note('recorded payment $id (stays on the tenant)');
        await openQueue();
        await pumpUntil(byKey('verify_payment_$id'));
        await payments.verify(customerPaymentId: id);
        await tapKey('verify_payment_$id');
        await pumpUntil(byKey('verify_payment_dialog'));
        await tapKey('verify_payment_confirm');
        await pumpUntil(find.text('Otra persona ya verificó este pago.'));
        expect(byKey('verify_payment_confirm'), findsNothing);
        await tapKey('verify_payment_close');
        await pumpUntilGone(byKey('verify_payment_dialog'));
        await pumpUntilGone(byKey('verify_payment_$id'));
      });

      note('verified from the queue: $fromQueue, from the view: $fromView');
      note('rejected, still unverified: $rejected');
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
  }, timeout: const Timeout(Duration(minutes: 15)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
