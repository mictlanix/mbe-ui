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
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_filter.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/063-for-delivery-queue/quickstart.md against the REAL app
/// (macOS desktop) and a live mbe-api (research R12, task T020).
///
///   caffeinate -dimsu flutter test \
///     integration_test/for_delivery_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=...   (and _PASSWORD; administrator)
///
/// **Read-only.** "Por entregar" opens from the navigation; the period filter
/// shows the six periods with the counts the API reports; and a period that
/// holds lines lists them, in the API's order. When every period is empty
/// the steps that need a line report SKIP, which is **not** a pass: they
/// proved nothing. Spec 062's live runs leave delivery orders in En
/// preparación on the local tenant (for example 30240 and 30242).
/// Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');

const _wide = Size(1400, 1000);

enum _Outcome { pass, skip, fail }

/// Thrown by a step that can't run on this data: reported as SKIP, never as
/// PASS.
class _Skipped implements Exception {
  const _Skipped(this.why);
  final String why;
}

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('For delivery queue walkthrough (real app, live mbe-api)', (
    tester,
  ) async {
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
    addTearDown(() {
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
    final itineraries = DeliveryItineraryRepositoryImpl(dio);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

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
    String fullUri() =>
        router().routerDelegate.currentConfiguration.uri.toString();
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

    Future<void> pumpUntil(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isNotEmpty, '$f');

    Finder byKey(String k) => find.byKey(Key(k));
    bool spinning() =>
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

    Future<void> tapFinder(Finder f) async {
      // Present first, then scrolled into view (the nav rail scrolls), then
      // hit-testable.
      await pumpUntil(f);
      await tester.ensureVisible(f.first);
      await pumpFor(const Duration(milliseconds: 300));
      await pumpUntilTrue(
        () => f.hitTestable().evaluate().isNotEmpty,
        'hit-testable: $f',
      );
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

    /// Waits for the queue's table or its empty state.
    Future<void> waitForQueue() async {
      await pumpUntilTrue(
        () =>
            (byKey('for_delivery_table').evaluate().isNotEmpty ||
                find.text(l10n.forDeliveryEmpty).evaluate().isNotEmpty ||
                byKey('list_state_filtered_empty').evaluate().isNotEmpty) &&
            !spinning(),
        'the for-delivery queue loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    String periodLabel(PendingDeliveryPeriod p) => switch (p) {
      PendingDeliveryPeriod.earlier => l10n.forDeliveryPeriodEarlier,
      PendingDeliveryPeriod.yesterday => l10n.forDeliveryPeriodYesterday,
      PendingDeliveryPeriod.today => l10n.forDeliveryPeriodToday,
      PendingDeliveryPeriod.tomorrow => l10n.forDeliveryPeriodTomorrow,
      PendingDeliveryPeriod.dayAfter => l10n.forDeliveryPeriodDayAfter,
      PendingDeliveryPeriod.later => l10n.forDeliveryPeriodLater,
    };

    /// A period option as the panel prints it: label first, `(total)` last.
    Finder optionFor(PendingDeliveryPeriod p, int total) =>
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data ?? '').startsWith(periodLabel(p)) &&
              (w.data ?? '').endsWith('($total)'),
        );

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
      } on _Skipped catch (s) {
        results.add(_Result(name, _Outcome.skip, s.why));
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

    // ------------------------------------------------------------------
    // Login (admin) and what the API says the queue holds
    // ------------------------------------------------------------------
    note('logging in as admin (read-only)');
    await login(_adminUser, _adminPass);

    final opening = await itineraries.pendingDeliveries(skip: 0, limit: 20);
    for (final p in PendingDeliveryPeriod.values) {
      note('API ${p.key}: ${opening[p]?.total ?? 0} line(s)');
    }
    final today = opening[PendingDeliveryPeriod.today];

    // ---- 1: open from the navigation (US1-1) -----------------------------
    await step('1 "Por entregar" opens from the nav and loads', () async {
      final entry = byKey('nav_dest_for-delivery');
      await pumpUntil(entry);
      expect(
        find.descendant(of: entry, matching: find.text(l10n.navForDelivery)),
        findsOneWidget,
      );
      await tapFinder(entry);
      await pumpUntilTrue(
        () => location() == forDeliveryPath,
        'the queue route (at ${location()})',
      );
      await waitForQueue();
      expect(byKey('for_delivery_filter_button'), findsOneWidget);
    });

    // ---- 2: Hoy matches the API (US1-2..5) -------------------------------
    await step('2 Hoy lists the API\'s lines for today', () async {
      if (today == null || today.total == 0) {
        expect(find.text(l10n.forDeliveryEmpty), findsOneWidget);
        throw const _Skipped('no pending line scheduled for today');
      }
      expect(byKey('for_delivery_table'), findsOneWidget);
      final first = today.items.first;
      expect(
        find.text(
          first.serial == null
              ? l10n.deliveryOrderDraftFolio
              : '${first.serial}',
        ),
        findsWidgets,
      );
      expect(find.textContaining('de ${today.total}'), findsOneWidget);
    });

    // ---- 3: the panel's counts are the API's (US2-1) ---------------------
    await step(
      '3 the period filter shows the six counts the API reports',
      () async {
        await tapKey('for_delivery_filter_button');
        await pumpUntil(byKey('for_delivery_period_filter'));
        await tapKey('for_delivery_period_filter');
        await pumpFor(const Duration(milliseconds: 600));
        for (final p in PendingDeliveryPeriod.values) {
          expect(
            optionFor(p, opening[p]?.total ?? 0),
            findsWidgets,
            reason: 'option for ${p.key}',
          );
        }
      },
    );

    // ---- 4: picking a period lists its lines (US2-2, US2-4/5) ------------
    PendingDeliveryPeriod? picked;
    for (final p in PendingDeliveryPeriod.values) {
      if (p != PendingDeliveryPeriod.today && (opening[p]?.total ?? 0) > 0) {
        picked = p;
        break;
      }
    }
    await step('4 picking a period with lines lists them, badge 1', () async {
      final period = picked;
      if (period == null) {
        throw const _Skipped('no period other than Hoy holds lines');
      }
      final total = opening[period]!.total;
      await tester.tap(optionFor(period, total).last);
      await pumpUntilTrue(
        () => fullUri().contains('period=${period.key}'),
        'the period in the URL (at ${fullUri()})',
      );
      await pumpFor(const Duration(milliseconds: 800));
      // Dismiss the panel.
      await tapFinder(find.text(l10n.applyFilters));
      await waitForQueue();
      final first = opening[period]!.items.first;
      expect(
        find.text(
          first.serial == null
              ? l10n.deliveryOrderDraftFolio
              : '${first.serial}',
        ),
        findsWidgets,
      );
      expect(find.textContaining('de $total'), findsOneWidget);
      final badge = tester.widget<Badge>(
        find.ancestor(
          of: byKey('for_delivery_filter_button'),
          matching: find.byType(Badge),
        ),
      );
      expect(badge.isLabelVisible, isTrue);
    });

    // ---- 5: row tap opens the order, back keeps the period (US3) ---------
    await step(
      '5 a row opens its order, and back returns to the same period',
      () async {
        final period = picked ?? PendingDeliveryPeriod.today;
        final bucket = opening[period];
        if (bucket == null || bucket.items.isEmpty) {
          throw const _Skipped('no line to tap');
        }
        final line = bucket.items.first;
        final serial = line.serial == null
            ? l10n.deliveryOrderDraftFolio
            : '${line.serial}';
        final before = fullUri();
        await tapFinder(find.text(serial).first);
        await pumpUntilTrue(
          () => location() == '/sales/delivery-orders/${line.deliveryOrderId}',
          'the order opened (at ${location()})',
        );
        await tapFinder(
          find.byTooltip(
            MaterialLocalizations.of(
              tester.element(find.byType(Scaffold).last),
            ).backButtonTooltip,
          ),
        );
        await pumpUntilTrue(
          () => fullUri() == before,
          'back on the queue (at ${fullUri()}, wanted $before)',
        );
        await waitForQueue();
        // Same period and page after the reload, not only in the URL.
        expect(find.text(serial), findsWidgets);
        if (period != PendingDeliveryPeriod.today) {
          final badge = tester.widget<Badge>(
            find.ancestor(
              of: byKey('for_delivery_filter_button'),
              matching: find.byType(Badge),
            ),
          );
          expect(badge.isLabelVisible, isTrue);
        }
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
  }, timeout: const Timeout(Duration(minutes: 10)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
