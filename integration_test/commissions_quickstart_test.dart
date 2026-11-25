import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

/// Automates specs/078-commissions/quickstart.md steps 1-4, 10 and 13 against
/// the REAL app (macOS desktop) and a live mbe-api (task T035): sign in, open
/// Finanzas > Comisiones, open a month, choose an agent, open a line's panel,
/// create and delete a label in Configuracion > Etiquetas, and edit an agent
/// rate cell and restore it.
///
///   caffeinate -dimsu flutter test \
///     integration_test/commissions_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env
///
/// Account: `MBE_POS_*` (the administrator; rights on
/// CommissionsBySalesPerson, 112). Fixtures are discovered at run time: a
/// month that has lines (read through the API) and an agent with a rate.
/// Steps 5-9 and 11-19 stay manual (close and pay change shared data,
/// research R14). Pay is never automated.
///
/// Writes data: a label `ZZ-TEST-078-<timestamp>` that the test deletes, and
/// one agent rate that it changes and restores (also restored through the API
/// when the UI step fails). Run against dev only.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');

const _wide = Size(1400, 1000);
const _list = '/commissions';

enum _Outcome { pass, fail, skip }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

class _Skip implements Exception {
  _Skip(this.why);
  final String why;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Commissions walkthrough (real app, live mbe-api)', (
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
    final clock = Stopwatch()..start();

    // ------------------------------------------------------------------
    // API side (independent of the app's own session)
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final auth = AuthRepositoryImpl(dio);
    final token = await auth.login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final commissions = CommissionRepositoryImpl(dio);

    final tag = 'ZZ-TEST-078-${DateTime.now().millisecondsSinceEpoch}';
    final results = <_Result>[];
    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    // ------------------------------------------------------------------
    // Fixtures
    // ------------------------------------------------------------------
    final months = await commissions.listPeriods();
    final agents = await commissions.listAgents();
    CommissionPeriod? withLines;
    // The last six calendar months, then any month the list knows: a
    // database with no close yet still has live months with sales.
    final today = DateTime.now();
    var back = CommissionMonth(year: today.year, month: today.month).previous;
    final candidates = <CommissionMonth>[
      for (var i = 0; i < 6; i++, back = back.previous) back,
      for (final s in months.take(6)) s.month,
    ];
    for (final m in candidates) {
      final p = await commissions.getPeriod(m);
      if (p.lines.isNotEmpty) {
        withLines = p;
        break;
      }
    }
    final CommissionAgent? chosenAgent = withLines == null
        ? null
        : agents
              .where(
                (a) => withLines!.totalsByAgent.any(
                  (t) => t.agentId == a.employeeId,
                ),
              )
              .firstOrNull;
    final rates = await commissions.listAgentRates();
    final CommissionAgentRate? rate = rates.firstOrNull;
    note(
      'month ${withLines?.month.year}-${withLines?.month.month} '
      '(${withLines?.lines.length} line(s)), agent '
      '${chosenAgent?.employeeId} ${chosenAgent?.name}, rate ${rate?.id} '
      '(share ${rate?.share}), tag "$tag"',
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
    // The URI on screen, query included (`?agent=`), pushed routes included:
    // the app's own helper (lib/core/navigation/list_query.dart).
    String location() => currentRouteUri(router()).toString();

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
      // Present first, then scrolled into view, then hit-testable.
      await pumpUntil(f);
      await tester.ensureVisible(f.first);
      await pumpFor(const Duration(milliseconds: 300));
      await pumpUntil(f.hitTestable());
      await tester.tap(f.hitTestable().first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> tapKey(String k) => tapFinder(byKey(k));

    /// Types [text] into the editable field under [key].
    Future<void> typeInto(String key, String text) async {
      final field = find.descendant(
        of: byKey(key),
        matching: find.byType(EditableText),
      );
      await pumpUntil(field);
      await tester.enterText(field.first, text);
      await pumpFor(const Duration(milliseconds: 300));
    }

    /// Waits until the API reports [expected] as the share of [r], pumping
    /// frames meanwhile: the cell's write is a real round trip, so reading
    /// the API right after Enter can see the old value.
    Future<Decimal> waitForShare(
      CommissionAgentRate r,
      Decimal expected,
    ) async {
      var share = r.share;
      for (var i = 0; i < 20; i++) {
        await pumpFor(const Duration(milliseconds: 300));
        share = (await commissions.listAgentRates(
          agentId: r.agentId,
          labelId: r.labelId,
        )).firstWhere((x) => x.id == r.id).share;
        if (share == expected) break;
      }
      return share;
    }

    /// Submits the focused field the way Enter does.
    Future<void> pressEnter() async {
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpFor(const Duration(milliseconds: 600));
    }

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

    Future<void> waitForMonthsList() async {
      await pumpUntilTrue(
        () =>
            (byKey('commission_periods_table').evaluate().isNotEmpty ||
                byKey(
                  'commission_periods_open_month_button',
                ).evaluate().isNotEmpty) &&
            !spinning(),
        'the months list loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Future<void> waitForMonth() async {
      await pumpUntilTrue(
        () =>
            byKey('commission_month_strip').evaluate().isNotEmpty &&
            !spinning(),
        'the month loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
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

    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body().timeout(const Duration(minutes: 2));
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: ${_short(ex)}');
        results.add(_Result(name, _Outcome.pass, 'ok'));
      } on _Skip catch (s) {
        await recover();
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

    // ------------------------------------------------------------------
    // Login (admin)
    // ------------------------------------------------------------------
    note('logging in as admin');
    await login(_adminUser, _adminPass);

    // ---- 1: Finanzas > Comisiones opens the months list --------------------
    await step('1 Comisiones opens the months list', () async {
      final entry = byKey('nav_dest_commissions');
      if (entry.evaluate().isNotEmpty ||
          find.byType(NavigationRail).evaluate().isNotEmpty) {
        try {
          await tapFinder(entry);
        } on TestFailure {
          await go(_list);
        }
      } else {
        await go(_list);
      }
      await pumpUntilTrue(() => location() == _list, 'the months route');
      await waitForMonthsList();
      expect(byKey('commission_periods_open_month_button'), findsOneWidget);
    });

    // ---- 2: open a month from the dialog ----------------------------------
    await step('2 "Abrir mes" opens the month screen', () async {
      await tapKey('commission_periods_open_month_button');
      await pumpUntil(byKey('commission_open_month_dialog'));
      await tapKey('commission_open_month_confirm');
      await pumpUntilTrue(
        () => location().startsWith('/commissions/'),
        'the month route',
      );
      await waitForMonth();
      expect(byKey('commission_month_name'), findsOneWidget);
    });

    // ---- 3: choose an agent ------------------------------------------------
    await step('3 choosing an agent shows their lines', () async {
      final period = withLines;
      final agent = chosenAgent;
      if (period == null || agent == null) {
        throw _Skip('no month with lines and a listed agent');
      }
      await go('/commissions/${period.month.year}/${period.month.month}');
      await waitForMonth();
      final row = find.descendant(
        of: byKey('commission_agents_table'),
        matching: find.text(agent.name),
      );
      await tapFinder(row);
      await pumpUntilTrue(
        () =>
            byKey('commission_agent_chip').evaluate().isNotEmpty && !spinning(),
        'the agent strip',
      );
      expect(location(), contains('agent=${agent.employeeId}'));
      await pumpUntil(byKey('commission_lines_table'));
    });

    // ---- 4: open a line's panel -------------------------------------------
    await step('4 a line opens its read-only panel', () async {
      final period = withLines;
      final agent = chosenAgent;
      if (period == null || agent == null) {
        throw _Skip('no month with lines and a listed agent');
      }
      final lines = (await commissions.getPeriod(
        period.month,
        agentId: agent.employeeId,
      )).lines;
      final table = byKey('commission_lines_table');
      Finder? row;
      for (final line in lines.take(10)) {
        final f = find.descendant(
          of: table,
          matching: find.text(line.productName),
        );
        if (f.evaluate().isNotEmpty) {
          row = f;
          break;
        }
      }
      if (row == null) throw _Skip('no line of the first page is in the table');
      await tapFinder(row);
      await pumpUntil(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith(
                'commission_line_panel_',
              ),
        ),
      );
    });

    // ---- 10: create and delete a label ------------------------------------
    await step('10 create and delete a label in Etiquetas', () async {
      await go('/commissions/settings?section=labels');
      await pumpUntil(byKey('commission_new_label_button'));
      await tapKey('commission_new_label_button');
      await pumpUntil(byKey('commission_label_name_field'));
      await typeInto('commission_label_name_field', tag);
      await typeInto('commission_label_rate_field', '3');
      await tapKey('commission_label_save_button');
      await pumpUntilGone(byKey('commission_label_name_field'));
      try {
        // Find it through the search box, then open it.
        await typeInto('commission_labels_search_field', tag);
        await pressEnter();
        final cell = find.descendant(
          of: byKey('commission_labels_table'),
          matching: find.text(tag),
        );
        await tapFinder(cell);
        await tapKey('commission_label_edit_button');
        await tapKey('commission_label_delete_button');
        await tapKey('commission_label_confirm_delete_button');
        await pumpUntilGone(byKey('commission_label_name_field'));
      } finally {
        // Whatever happened in the UI, the label must not stay.
        for (final l in await commissions.listLabels()) {
          if (l.name == tag) {
            await commissions.deleteLabel(l.id);
            note('label ${l.id} deleted through the API (UI did not)');
          }
        }
      }
      expect(
        (await commissions.listLabels()).map((l) => l.name),
        isNot(contains(tag)),
      );
    });

    // ---- 13: edit a rate cell and restore it ------------------------------
    await step('13 edit an agent rate cell, then restore it', () async {
      final r = rate;
      if (r == null) throw _Skip('the tenant has no agent rate');
      // The text field inside the grid cell (agent_rates_grid.dart).
      final cell = 'commission_rate_field_${r.labelId}_${r.participationId}';
      final hundred = Decimal.fromInt(100);
      final original = (r.share * hundred).toString();
      final edited = original == '50' ? '40' : '50';
      try {
        await go('/commissions/settings?section=rates&agent=${r.agentId}');
        await pumpUntilTrue(
          () => byKey(cell).evaluate().isNotEmpty && !spinning(),
          'the rate cell $cell (is the rates grid built?)',
        );
        await typeInto(cell, edited);
        await pressEnter();
        final wanted = (Decimal.parse(edited) / hundred).toDecimal();
        expect(await waitForShare(r, wanted), wanted);
        // Let the cell take the saved value before the next edit, and give
        // it focus again (the precedent: pricing_grid_quickstart_test.dart).
        await pumpFor(const Duration(seconds: 1));
        await tapFinder(byKey(cell));
        await typeInto(cell, original);
        await pressEnter();
        expect(await waitForShare(r, r.share), r.share);
      } finally {
        final now = (await commissions.listAgentRates(
          agentId: r.agentId,
          labelId: r.labelId,
        )).where((x) => x.id == r.id).firstOrNull;
        if (now != null && now.share != r.share) {
          await commissions.updateAgentRate(r.id, r.share);
          note('rate ${r.id} restored through the API');
        }
      }
    });

    note('==== RESULTS ==== (${clock.elapsed.inSeconds}s)');
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
  }, timeout: const Timeout(Duration(minutes: 20)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
