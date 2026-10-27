import 'dart:async';
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_cell_key.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/pricing_defaults.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_controller.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/033-bulk-pricing-grid/quickstart.md "Manual" steps 1–18
/// (T058/T059) against the REAL app (macOS desktop) and a live mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/pricing_grid_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_PRICING_TEST_USERNAME=... (and _PASSWORD; pricing update)
///     --dart-define=MBE_QA033_USERNAME=...        (and _PASSWORD; read-only)
///
/// Steps 17–18 of the quickstart predate slices C and D shipping inside 033,
/// so they are checked in their shipped form: the column ⋮ menu is present
/// for the editor and absent for the read-only account (17'), and a worklist
/// chip's count matches the API and narrows the grid (18'). The menu's bulk
/// actions are opened, not executed.
///
/// The tenant is shared dev data. Every product whose prices the test may
/// touch is snapshotted before the first edit, and a tear-down registered
/// before any write restores changed prices, deletes every price row the test
/// created, and deletes the price lists it created. Credentials are never
/// printed.
const _adminUser = String.fromEnvironment('MBE_PRICING_TEST_USERNAME');
const _adminPass = String.fromEnvironment('MBE_PRICING_TEST_PASSWORD');
const _roUser = String.fromEnvironment('MBE_QA033_USERNAME');
const _roPass = String.fromEnvironment('MBE_QA033_PASSWORD');

/// Wide enough that every price-list column fits beside the nav rail, so
/// cells are tappable without scrolling the grid sideways.
const _wide = Size(2200, 1200);

/// Narrower than the grid's minimum width — step 14's sideways check.
const _narrow = Size(1200, 1000);

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

  testWidgets('Pricing grid quickstart walkthrough (real app, live mbe-api)', (
    tester,
  ) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped(
        'MBE_PRICING_TEST_USERNAME/_PASSWORD dart-defines are required.',
      );
      return;
    }

    // ------------------------------------------------------------------
    // API side (independent of the app's own session)
    // ------------------------------------------------------------------
    // Every API call is bounded: an unanswered request must fail the step,
    // not hang the run.
    final dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final priceLists = PriceListRepositoryImpl(dio);
    final prices = ProductPriceRepositoryImpl(dio);
    final products = ProductRepositoryImpl(dio);
    final orders = SalesOrderRepositoryImpl(dio);

    final tag = '$_tagPrefix${DateTime.now().millisecondsSinceEpoch}';
    final es = lookupAppLocalizations(const Locale('es'));
    final en = lookupAppLocalizations(const Locale('en'));

    // ------------------------------------------------------------------
    // Tenant restoration — registered before anything is written.
    // ------------------------------------------------------------------
    /// Every price row (id → price) of these products, as found before the
    /// test touched them. Teardown puts each product back exactly to this.
    ///
    /// Mirrored into a journal in the app's own preferences on every change,
    /// so a run that is killed (and never reaches its teardown) is undone by
    /// the next run before it starts.
    final snapshot = <int, Map<int, String>>{};
    final snapshotRows = <int, List<ProductPrice>>{};
    final createdLists = <int>{};
    final teardownLog = <String>[];
    int? cancelledOrderId;
    final journalPrefs = await SharedPreferences.getInstance();

    Future<void> writeJournal() => journalPrefs.setString(
      _journalKey,
      jsonEncode({
        'lists': createdLists.toList(),
        'rows': {
          for (final e in snapshot.entries)
            '${e.key}': {for (final r in e.value.entries) '${r.key}': r.value},
        },
      }),
    );

    Future<void> snapshotProducts(Iterable<int> productIds) async {
      for (final id in productIds) {
        if (snapshot.containsKey(id)) continue;
        final rows = await prices.listByProduct(productId: id, limit: 100);
        snapshotRows[id] = rows;
        snapshot[id] = {for (final r in rows) r.productPriceId: r.price};
      }
      await writeJournal();
    }

    Future<void> trackList(int id) async {
      createdLists.add(id);
      await writeJournal();
    }

    /// Puts [snap]'s products back and deletes [lists]; returns
    /// (restored, deleted rows).
    Future<(int, int)> restore(
      Map<int, Map<int, String>> snap,
      Set<int> lists,
      List<String> log,
    ) async {
      var restored = 0;
      var deleted = 0;
      for (final entry in snap.entries) {
        try {
          final before = entry.value;
          final now = await prices.listByProduct(
            productId: entry.key,
            limit: 100,
          );
          for (final p in now) {
            final was = before[p.productPriceId];
            if (was == null) {
              await dio.delete<void>(
                '/api/v1/product-prices/${p.productPriceId}',
              );
              deleted++;
              log.add(
                'deleted price ${p.productPriceId} '
                '(product ${p.productId}, list ${p.priceList.priceListId})',
              );
            } else if (!sameAmount(was, p.price)) {
              await prices.update(productPriceId: p.productPriceId, price: was);
              restored++;
              log.add(
                'restored price ${p.productPriceId} '
                '(product ${p.productId}) ${p.price} -> $was',
              );
            }
          }
          final after = await prices.listByProduct(
            productId: entry.key,
            limit: 100,
          );
          final same =
              after.length == before.length &&
              after.every(
                (p) =>
                    before[p.productPriceId] != null &&
                    sameAmount(before[p.productPriceId], p.price),
              );
          if (!same) log.add('MISMATCH product ${entry.key} after restore');
        } catch (e) {
          log.add('ERROR restoring product ${entry.key}: ${_short(e)}');
        }
      }
      // Every list this test ever creates carries [_tagPrefix], so a sweep
      // by name also catches lists from a killed run whose id was never
      // journalled.
      try {
        final all = await priceLists.list(limit: 100);
        lists.addAll(
          all.items
              .where((l) => l.name.startsWith(_tagPrefix))
              .map((l) => l.priceListId),
        );
      } catch (_) {}
      for (final id in lists) {
        try {
          await priceLists.delete(priceListId: id);
          log.add('deleted price list $id');
        } catch (e) {
          final gone =
              e.toString().contains('NotFound') || e.toString().contains('404');
          log.add(
            gone
                ? 'price list $id already deleted'
                : 'ERROR deleting price list $id: ${_short(e)}',
          );
        }
      }
      return (restored, deleted);
    }

    // Pre-run sweep: undo whatever a killed earlier run left behind.
    {
      final raw = journalPrefs.getString(_journalKey);
      final staleSnap = <int, Map<int, String>>{};
      final staleLists = <int>{};
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        staleLists.addAll((j['lists'] as List).cast<int>());
        (j['rows'] as Map<String, dynamic>).forEach((pid, rows) {
          staleSnap[int.parse(pid)] = {
            for (final r in (rows as Map<String, dynamic>).entries)
              int.parse(r.key): r.value as String,
          };
        });
      }
      final log = <String>[];
      final (r, d) = await restore(staleSnap, staleLists, log);
      await journalPrefs.remove(_journalKey);
      // ignore: avoid_print
      print(
        'QS-PRESWEEP journal ${raw == null ? 'absent' : 'found'}; restored '
        '$r, deleted rows $d; ${log.isEmpty ? 'nothing to undo' : log.join('; ')}',
      );
    }

    addTearDown(() async {
      try {
        await (await SharedPreferences.getInstance()).remove('locale_override');
      } catch (_) {}
      final (restored, deleted) = await restore(
        snapshot,
        createdLists,
        teardownLog,
      );
      if (!teardownLog.any(
        (l) => l.startsWith('ERROR') || l.startsWith('MISMATCH'),
      )) {
        await journalPrefs.remove(_journalKey);
      }
      // ignore: avoid_print
      print(
        'QS-TEARDOWN snapshot products ${snapshot.length}, restored '
        '$restored, deleted rows $deleted, cancelled order '
        '$cancelledOrderId',
      );
      for (final line in teardownLog) {
        // ignore: avoid_print
        print('QS-TEARDOWN $line');
      }
    });

    // ------------------------------------------------------------------
    // App boot (mirrors lib/main.dart)
    // ------------------------------------------------------------------
    // Frame watchdog. When the app window is not frontmost (the runner
    // reports "Failed to foreground app"), macOS can stop delivering engine
    // frames, and every pump then waits forever — the first run sat idle
    // for 20 minutes. When a scheduled frame has not begun within ~1.5 s,
    // drive one by hand with a timestamp that keeps advancing in real time,
    // so animations still finish. Changes nothing when frames flow.
    var kicks = 0;
    // Heartbeat: names where the run is, so a hang is attributable from the
    // log alone.
    var currentStep = 'boot';
    var waitingOn = '';
    final heartbeat = Timer.periodic(const Duration(seconds: 30), (_) {
      // ignore: avoid_print
      print(
        'QS-HB step="$currentStep" wait="$waitingOn" '
        'phase=${binding.schedulerPhase} scheduled=${binding.hasScheduledFrame} '
        'kicks=$kicks',
      );
    });
    var lastTs = binding.currentSystemFrameTimeStamp;
    var lastWall = DateTime.now();
    var stalledSince = <DateTime>[];
    final watchdog = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final ts = binding.currentSystemFrameTimeStamp;
      final now = DateTime.now();
      if (ts != lastTs) {
        lastTs = ts;
        lastWall = now;
      }
      if (!binding.hasScheduledFrame ||
          binding.schedulerPhase != SchedulerPhase.idle) {
        stalledSince = [];
        return;
      }
      if (stalledSince.isEmpty) {
        stalledSince = [now];
        return;
      }
      if (now.difference(stalledSince.first) <
          const Duration(milliseconds: 1500)) {
        return;
      }
      final raw = lastTs + now.difference(lastWall);
      lastTs = raw;
      lastWall = now;
      stalledSince = [];
      kicks++;
      binding.handleBeginFrame(raw);
      binding.handleDrawFrame();
    });
    addTearDown(() {
      watchdog.cancel();
      heartbeat.cancel();
      // ignore: avoid_print
      print('QS: frame watchdog drove $kicks frame(s)');
    });

    await initializeDateFormatting();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await writeJournal();
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
    Uri uri() => router().routerDelegate.currentConfiguration.uri;

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
      waitingOn = what;
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

    Future<void> pumpUntilGone(
      Finder f, {
      Duration timeout = const Duration(seconds: 30),
    }) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f', timeout: timeout);

    Finder byKey(String k) => find.byKey(Key(k));
    Finder keyPrefix(String prefix) => find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith(prefix),
    );

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
      // Re-submits if the first "done" is lost (seen once when the window
      // was not frontmost).
      for (var attempt = 1; ; attempt++) {
        await tester.tap(byKey('login_password_field'));
        await pumpFor(const Duration(milliseconds: 300));
        await tester.testTextInput.receiveAction(TextInputAction.done);
        try {
          await pumpUntilGone(
            byKey('login_username_field'),
            timeout: const Duration(seconds: 15),
          );
          break;
        } on TestFailure {
          if (attempt == 3) rethrow;
          // ignore: avoid_print
          print(
            'QS: login submit attempt $attempt did not leave the login screen',
          );
        }
      }
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> go(String path) async {
      waitingOn = 'go $path';
      router().go(path);
      await pumpFor(const Duration(milliseconds: 500));
    }

    AppLocalizations l10n() =>
        AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
    String money(String? amount) =>
        container().read(formattersProvider).display.currency(amount);

    Future<void> recover() async {
      for (var i = 0; i < 3; i++) {
        final close = byKey('filter_sheet_close_button');
        if (close.evaluate().isEmpty) break;
        await tester.tap(close.first);
        await pumpFor(const Duration(milliseconds: 500));
      }
      for (var i = 0; i < 4; i++) {
        final dlg = find.byType(Dialog);
        if (dlg.evaluate().isEmpty) break;
        Navigator.of(tester.element(dlg.first), rootNavigator: true).pop();
        await pumpFor(const Duration(milliseconds: 400));
      }
      if (keyPrefix('price_cell_field_').evaluate().isNotEmpty) {
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await pumpFor(const Duration(milliseconds: 300));
      }
      tester.takeException();
    }

    final results = <_Result>[];
    Future<void> step(
      String name,
      Future<String?> Function() body, {
      bool soft = false,
    }) async {
      try {
        currentStep = name;
        final detail = await body().timeout(const Duration(minutes: 3));
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: ${_short(ex)}');
        results.add(_Result(name, _Outcome.pass, detail ?? 'ok'));
      } catch (e) {
        try {
          final texts = find
              .byType(Text)
              .evaluate()
              .map((el) => (el.widget as Text).data ?? '')
              .where((t) => t.isNotEmpty)
              .take(40)
              .toList();
          // ignore: avoid_print
          print('QS-DBG loc=${uri()} texts=$texts');
        } catch (_) {}
        await recover();
        results.add(
          _Result(name, soft ? _Outcome.soft : _Outcome.fail, _short(e)),
        );
      }
      // ignore: avoid_print
      print(
        'QS-STEP ${results.last.outcome.name.toUpperCase()} '
        '${results.last.name} :: ${results.last.detail}',
      );
    }

    void softFinding(String name, String text) {
      results.add(_Result(name, _Outcome.soft, text));
      // ignore: avoid_print
      print('QS-STEP SOFT $name :: $text');
    }

    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    // ---- grid helpers ----
    PricingGridFilter gridFilter() =>
        PricingGridFilter.fromQuery(ListQuery.fromUri(uri()));
    PricingGridState? grid() =>
        container().read(pricingGridControllerProvider(gridFilter())).value;

    Future<PricingGridState> gridLoaded() async {
      await pumpUntilTrue(
        () {
          final s = grid();
          return s != null &&
              s.page != null &&
              s.inFlight.isEmpty &&
              byKey('pricing_grid_table').evaluate().isNotEmpty;
        },
        'grid loaded at ${uri()}',
        timeout: const Duration(seconds: 60),
      );
      await pumpFor(const Duration(milliseconds: 400));
      return grid()!;
    }

    Future<void> gridSettled() => pumpUntilTrue(
      () => grid() != null && grid()!.inFlight.isEmpty,
      'no write in flight',
    );

    String cellKey(int p, int l) => 'price_cell_${p}_$l';
    String fieldKey(int p, int l) => 'price_cell_field_${p}_$l';

    List<String> textsIn(Finder f) => find
        .descendant(of: f, matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    String cellText(int p, int l) => textsIn(byKey(cellKey(p, l))).join(' ');

    Future<String> apiPrice(int productId, int listId) async {
      final all = await prices.listByProduct(productId: productId, limit: 100);
      return all
          .firstWhere(
            (x) => x.priceList.priceListId == listId,
            orElse: () => throw TestFailure(
              'no price for product $productId on list $listId',
            ),
          )
          .price;
    }

    Future<Map<String, dynamic>?> apiPriceRow(int productId, int listId) async {
      final res = await dio.get<Map<String, dynamic>>(
        '/api/v1/product-prices',
        queryParameters: {'product': productId, 'limit': 100},
      );
      for (final r
          in (res.data!['items'] as List).cast<Map<String, dynamic>>()) {
        if ((r['price_list'] as Map)['price_list_id'] == listId) return r;
      }
      return null;
    }

    Future<void> openCell(int p, int l) async {
      await tapKey(cellKey(p, l));
      await pumpUntil(byKey(fieldKey(p, l)));
      await pumpFor(const Duration(milliseconds: 300));
    }

    var enterViaAction = false;

    /// Presses Enter in the open cell [p]/[l]. A hardware Enter on macOS is
    /// delivered through the text-input system, which a test cannot drive
    /// with a key event, so the text-input "done" action is the fallback.
    Future<void> pressEnter(int p, int l) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await pumpFor(const Duration(milliseconds: 400));
      if (byKey(fieldKey(p, l)).evaluate().isNotEmpty) {
        enterViaAction = true;
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await pumpFor(const Duration(milliseconds: 400));
      }
      await gridSettled();
    }

    Future<void> escape() async {
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await pumpFor(const Duration(milliseconds: 400));
    }

    String plus(String amount, String delta) =>
        (Decimal.parse(amount) + Decimal.parse(delta)).toStringAsFixed(2);

    Finder inSheet(String text) => find.byWidgetPredicate((w) {
      return w is Text && w.data == text;
    }).hitTestable();

    /// Top of [text] inside the open side sheet. Hit-testable only: the
    /// modal barrier hides everything behind the sheet, including the
    /// products table's own "Estado" column header.
    double sheetTextY(String text) {
      final candidates = find
          .text(text)
          .hitTestable()
          .evaluate()
          .where(
            (e) =>
                tester.getTopLeft(find.byElementPredicate((x) => x == e)).dx >
                _wide.width - 400,
          )
          .toList();
      if (candidates.length != 1) {
        throw TestFailure('"$text" in the sheet ${candidates.length} times');
      }
      return tester
          .getTopLeft(find.byElementPredicate((x) => x == candidates.single))
          .dy;
    }

    // ------------------------------------------------------------------
    // Login (admin)
    // ------------------------------------------------------------------
    note('logging in as the pricing editor');
    await login(_adminUser, _adminPass);

    final listsAtStart = (await priceLists.list(limit: 100)).items;
    note(
      'price lists: ${listsAtStart.map((l) => '${l.priceListId}:${l.name}').join(', ')}'
      '; configured cost list id $costPriceListId '
      '${listsAtStart.any((l) => l.priceListId == costPriceListId) ? 'exists' : 'does NOT exist'}',
    );

    // ==================================================================
    // Slice A — price lists (US7) and products drawer (US6)
    // ==================================================================
    await step('2 /price-lists has no margin columns', () async {
      await go('/price-lists');
      await pumpUntil(byKey('price_lists_table'));
      await pumpUntil(find.text(listsAtStart.first.name));
      final texts = textsIn(byKey('price_lists_table'));
      final marginish = texts.where(
        (t) => RegExp(
          'margen|margin|utilidad|profit|ganancia',
          caseSensitive: false,
        ).hasMatch(t),
      );
      expect(marginish, isEmpty, reason: 'margin wording on the list');
      expect(texts, contains(l10n().priceListNameLabel));
      return 'table texts are name + rows only';
    });

    await step('1a existing list opens with only a name field', () async {
      await go('/price-lists');
      await tapFinder(
        find.descendant(
          of: byKey('price_lists_table'),
          matching: find.text(listsAtStart.first.name),
        ),
      );
      await pumpUntil(byKey('price_list_name_field'));
      final sheetFields = find
          .byType(TextFormField)
          .evaluate()
          .where(
            (e) =>
                tester.getTopLeft(find.byElementPredicate((x) => x == e)).dx >
                1000,
          );
      expect(sheetFields.length, 1, reason: 'only the name field');
      expect(
        find.textContaining(
          RegExp('margen|margin|utilidad|profit', caseSensitive: false),
        ),
        findsNothing,
      );
      await tapKey('filter_sheet_close_button');
      await pumpUntilGone(byKey('price_list_name_field'));
      return 'list "${listsAtStart.first.name}" viewed (not edited)';
    });

    int? createdListId;
    await step('3 create a price list with only a name', () async {
      await go('/price-lists');
      await tapKey('new_price_list_button');
      await pumpUntil(byKey('price_list_name_field'));
      final sheetFields = find
          .byType(TextFormField)
          .evaluate()
          .where(
            (e) =>
                tester.getTopLeft(find.byElementPredicate((x) => x == e)).dx >
                1000,
          );
      expect(sheetFields.length, 1, reason: 'only the name field');
      await tester.enterText(byKey('price_list_name_field'), tag);
      await pumpFor(const Duration(milliseconds: 300));
      await tapKey('save_button');
      await pumpUntilTrue(() {
        return byKey('price_list_name_field').evaluate().isEmpty ||
            byKey('edit_price_list_button').evaluate().isNotEmpty;
      }, 'saved');
      final found = (await priceLists.list(
        search: tag,
        limit: 10,
      )).items.where((l) => l.name == tag).toList();
      expect(found, hasLength(1), reason: 'list exists in mbe-api');
      createdListId = found.single.priceListId;
      await trackList(createdListId!);
      if (byKey('filter_sheet_close_button').evaluate().isNotEmpty) {
        await tapKey('filter_sheet_close_button');
      }
      return 'created list $createdListId "$tag" with only a name';
    });

    await step('1b rename a list and save; the change sticks', () async {
      if (createdListId == null) throw TestFailure('no list from step 3');
      final renamed = '$tag R';
      await go('/price-lists?search=${Uri.encodeQueryComponent(tag)}');
      await pumpUntil(
        find.descendant(
          of: byKey('price_lists_table'),
          matching: find.text(tag),
        ),
      );
      await tapFinder(find.byTooltip(l10n().editActionTooltip));
      await pumpUntil(byKey('price_list_name_field'));
      if (byKey('edit_price_list_button').evaluate().isNotEmpty) {
        await tapKey('edit_price_list_button');
      }
      await tester.enterText(byKey('price_list_name_field'), renamed);
      await pumpFor(const Duration(milliseconds: 300));
      await tapKey('save_button');
      await pumpFor(const Duration(seconds: 1));
      waitingOn = '1b: API re-read of list $createdListId';
      final stored = await priceLists.get(priceListId: createdListId!);
      expect(stored.name, renamed);
      if (byKey('filter_sheet_close_button').evaluate().isNotEmpty) {
        await tapKey('filter_sheet_close_button');
      }
      await go('/price-lists?search=${Uri.encodeQueryComponent(renamed)}');
      await pumpUntil(
        find.descendant(
          of: byKey('price_lists_table'),
          matching: find.text(renamed),
        ),
      );
      // Not needed past this point; it would only add a grid column.
      waitingOn = '1b: API delete of list $createdListId';
      await priceLists.delete(priceListId: createdListId!);
      createdLists.remove(createdListId);
      await writeJournal();
      teardownLog.add('deleted price list $createdListId (in-test, step 1b)');
      return 'renamed the step-3 list to "$renamed" (re-read from the API), '
          'then deleted it';
    });

    await step('4 products drawer: heading, order status→attributes→'
        'supplier→labels', () async {
      await go('/products');
      await pumpUntil(
        byKey('products_table'),
        timeout: const Duration(seconds: 60),
      );
      await tapKey('products_filter_button');
      await pumpUntil(byKey('filter_sheet_apply_button'));
      await pumpFor(const Duration(seconds: 1));
      final l = l10n();
      final status = sheetTextY(l.statusFilterLabel);
      final attrs = sheetTextY(l.productsAttributesFilterLabel);
      final stockY = tester.getTopLeft(byKey('products_filter_stockable')).dy;
      final supplier = sheetTextY(l.productsSupplierFilter);
      String order =
          'status $status < attributes $attrs < stockable chip '
          '$stockY < supplier $supplier';
      expect(status < attrs, isTrue, reason: order);
      expect(attrs < stockY, isTrue, reason: order);
      expect(stockY < supplier, isTrue, reason: order);
      if (byKey('products_filter_label').evaluate().isNotEmpty) {
        final labels = sheetTextY(l.productsLabelFilter);
        order = '$order < labels $labels';
        expect(supplier < labels, isTrue, reason: order);
      } else {
        order = '$order (no labels on the tenant: section hidden)';
      }
      return order;
    });

    await step(
      '5 language switch: heading translated, no [key] fallback',
      () async {
        // The deployment default is es_MX, so prove both directions: English
        // first, then switch back to Spanish.
        final prefsCtl = container().read(
          userDisplayPreferencesControllerProvider.notifier,
        );
        if (byKey('filter_sheet_apply_button').evaluate().isEmpty) {
          await go('/products');
          await tapKey('products_filter_button');
        }
        await pumpUntil(byKey('filter_sheet_apply_button'));
        expect(inSheet(es.productsAttributesFilterLabel), findsOneWidget);
        await prefsCtl.setLocaleOverride(const Locale('en'));
        await pumpUntil(inSheet(en.productsAttributesFilterLabel));
        await prefsCtl.setLocaleOverride(const Locale('es'));
        await pumpUntil(inSheet(es.productsAttributesFilterLabel));
        final bracketed = find
            .byType(Text)
            .evaluate()
            .map((e) => (e.widget as Text).data ?? '')
            .where((t) => RegExp(r'^\[.*\]$').hasMatch(t))
            .toList();
        expect(bracketed, isEmpty, reason: 'untranslated keys: $bracketed');
        await prefsCtl.setLocaleOverride(null);
        await pumpFor(const Duration(milliseconds: 500));
        await tapKey('filter_sheet_apply_button');
        await pumpUntilGone(byKey('filter_sheet_apply_button'));
        return '"${en.productsAttributesFilterLabel}" (en) ⇄ '
            '"${es.productsAttributesFilterLabel}" (es); override cleared';
      },
    );

    // ==================================================================
    // Slice B — the grid
    // ==================================================================
    // A temporary list with a non-degenerate band, for step 11's R6 check
    // (every list on the tenant is 0/0). Created through the API before the
    // grid loads so it renders as a column.
    int? bandListId;
    const bandLow = '0.1';
    const bandHigh = '0.35';
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/api/v1/price-lists',
        data: {
          'name': '$tag band',
          'low_profit_margin': bandLow,
          'high_profit_margin': bandHigh,
        },
      );
      bandListId = res.data!['price_list_id'] as int;
      await trackList(bandListId);
      note('band list $bandListId created (low $bandLow, high $bandHigh)');
    } catch (e) {
      note('could not create the band list: ${_short(e)}');
    }

    PricingGridState? page1;
    await step(
      '6 /pricing renders a populated grid, no product selected',
      () async {
        await go('/pricing');
        page1 = await gridLoaded();
        final s = page1!;
        expect(s.rows, isNotEmpty);
        expect(uri().queryParameters, isEmpty);
        final first = s.rows.first.product.productId;
        for (final l in s.allLists) {
          expect(byKey(cellKey(first, l.priceListId)), findsOneWidget);
        }
        return '${s.rows.length} rows × ${s.allLists.length} list columns, '
            '${s.page!.total} products in total, at bare /pricing';
      },
    );
    if (page1 == null) {
      softFinding('6+', 'grid did not load; remaining grid steps skipped');
    }

    // Snapshot everything on page 1 before any edit.
    final rows = page1?.rows ?? const [];
    await snapshotProducts(rows.map((r) => r.product.productId));
    note('snapshotted ${snapshot.length} products');

    final lists = page1?.allLists ?? const <PriceList>[];
    final colIds = lists.map((l) => l.priceListId).toList();
    // The edit column: the list with a price on the most page-1 rows.
    int? editList;
    var bestCount = -1;
    for (final l in colIds) {
      final n = rows.where((r) => r.prices[l] != null).length;
      if (n > bestCount) {
        bestCount = n;
        editList = l;
      }
    }
    // Four consecutive rows priced on that list.
    int? base;
    if (editList != null) {
      for (var i = 0; i + 3 < rows.length; i++) {
        if (List.generate(
          4,
          (k) => rows[i + k].prices[editList],
        ).every((p) => p != null)) {
          base = i;
          break;
        }
      }
    }
    note('edit column $editList, base row $base');
    int pid(int i) => rows[i].product.productId;

    await step('7 "not set" differs visibly from \$0.00', () async {
      final s = grid()!;
      ({int p, int l})? unset;
      ({int p, int l})? zero;
      for (final r in s.rows) {
        for (final l in colIds) {
          final pr = r.prices[l];
          if (pr == null) unset ??= (p: r.product.productId, l: l);
          if (pr != null && Decimal.parse(pr.price) == Decimal.zero) {
            zero ??= (p: r.product.productId, l: l);
          }
        }
      }
      if (unset == null) throw TestFailure('no unpriced cell on page 1');
      final shown = cellText(unset.p, unset.l);
      expect(shown, l10n().pricingPriceNotSet);
      expect(shown, isNot(money('0')));
      final notSetColor = tester
          .widget<Text>(
            find.descendant(
              of: byKey(cellKey(unset.p, unset.l)),
              matching: find.byType(Text),
            ),
          )
          .style
          ?.color;
      expect(notSetColor, isNotNull, reason: 'muted colour on "not set"');
      if (zero != null) {
        expect(cellText(zero.p, zero.l), money('0'));
        return 'cell ${unset.p}/${unset.l} reads "$shown" (muted); real '
            '\$0.00 cell ${zero.p}/${zero.l} reads "${money('0')}"';
      }
      return 'cell ${unset.p}/${unset.l} reads "$shown" in a muted colour '
          '(≠ "${money('0')}"); no stored 0.00 price on page 1 to compare '
          'side by side';
    });

    // ---- 8 ----
    String? step8Old;
    await step('8 click → editable, value selected; Enter saves and opens '
        'the cell below', () async {
      if (editList == null || base == null) {
        throw TestFailure('no four consecutive priced rows on page 1');
      }
      final p = pid(base);
      final l = editList;
      step8Old = rows[base].prices[l]!.price;
      await openCell(p, l);
      final field = tester.widget<TextField>(byKey(fieldKey(p, l)));
      final c = field.controller!;
      expect(c.text, isNotEmpty);
      expect(c.selection.start, 0, reason: 'value selected');
      expect(c.selection.end, c.text.length, reason: 'value selected');
      final next = plus(step8Old!, '1');
      await tester.enterText(byKey(fieldKey(p, l)), next);
      await pressEnter(p, l);
      expect(sameAmount(await apiPrice(p, l), next), isTrue);
      await pumpUntil(byKey(fieldKey(pid(base! + 1), l)));
      return 'product $p list $l: $step8Old → $next saved; '
          'row ${base! + 1} same column opened'
          '${enterViaAction ? ' (Enter sent as the text-input done action)' : ''}';
    });

    // ---- 9 ----
    await step('9 Tab across a row and off its end opens the next row\'s '
        'first price column', () async {
      if (editList == null || base == null) throw TestFailure('no fixture');
      final p = pid(base + 1);
      if (byKey(fieldKey(p, editList)).evaluate().isEmpty) {
        await openCell(p, editList);
      }
      final startCol = colIds.indexOf(editList!);
      for (var c = startCol; c < colIds.length - 1; c++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await pumpUntil(byKey(fieldKey(p, colIds[c + 1])));
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await pumpUntil(byKey(fieldKey(pid(base! + 2), colIds.first)));
      await gridSettled();
      expect(grid()!.rejected, isEmpty, reason: 'tabbing wrote nothing bad');
      await escape();
      // Passing over cells without typing must not write.
      final after = await prices.listByProduct(productId: p, limit: 100);
      for (final was in snapshotRows[p]!) {
        final now = after.firstWhere(
          (x) => x.productPriceId == was.productPriceId,
        );
        expect(
          sameAmount(now.price, was.price),
          isTrue,
          reason:
              'tabbing over product $p changed list '
              '${was.priceList.priceListId}',
        );
      }
      return 'tabbed ${colIds.length - startCol} times from list $editList; '
          'landed on product ${pid(base! + 2)} list ${colIds.first}; no writes';
    });

    // ---- 10 ----
    await step('10 "abc" + Enter stays flagged with a reason; price unchanged '
        '(also after reload)', () async {
      if (editList == null || base == null) throw TestFailure('no fixture');
      final p = pid(base + 2);
      final l = editList;
      final stored = snapshotRows[p]!.firstWhere(
        (x) => x.priceList.priceListId == l,
      );
      await openCell(p, l);
      await tester.enterText(byKey(fieldKey(p, l)), 'abc');
      await pressEnter(p, l);
      if (keyPrefix('price_cell_field_').evaluate().isNotEmpty) await escape();
      expect(cellText(p, l), contains('abc'));
      expect(byKey('price_cell_badge_${p}_$l'), findsOneWidget);
      final tip = tester.widget<Tooltip>(
        find
            .ancestor(of: byKey(cellKey(p, l)), matching: find.byType(Tooltip))
            .first,
      );
      expect(tip.message, l10n().pricingInvalidAmountError);
      expect(sameAmount(await apiPrice(p, l), stored.price), isTrue);
      // Reload.
      // `.value` keeps the previous data while a refresh is loading, so wait
      // on the refreshed future itself.
      final reloadedFuture = container().refresh(
        pricingGridControllerProvider(gridFilter()).future,
      );
      await pumpUntilTrue(
        () => !container()
            .read(pricingGridControllerProvider(gridFilter()))
            .isLoading,
        'reload finished',
      );
      await reloadedFuture;
      final reloaded = await gridLoaded();
      expect(reloaded.rejected, isEmpty);
      expect(cellText(p, l), money(stored.price));
      return 'cell shows "abc" + error badge, tooltip "${tip.message}"; API and '
          'reloaded grid still ${money(stored.price)}';
    });

    // ---- 11a: create on a list with a real band ----
    await step('11a fill an empty cell: created without a profit prompt; band '
        '= list margins', () async {
      if (bandListId == null) throw TestFailure('no band list');
      if (rows.isEmpty) throw TestFailure('no rows');
      final p = pid(0);
      await openCell(p, bandListId);
      await tester.enterText(byKey(fieldKey(p, bandListId!)), '123.45');
      await pressEnter(p, bandListId!);
      expect(
        find.byType(Dialog),
        findsNothing,
        reason: 'no prompt of any kind',
      );
      expect(find.byType(AlertDialog), findsNothing);
      if (keyPrefix('price_cell_field_').evaluate().isNotEmpty) await escape();
      final row = await apiPriceRow(p, bandListId!);
      expect(row, isNotNull, reason: 'row created');
      expect(sameAmount(row!['price'] as String, '123.45'), isTrue);
      expect(
        sameAmount(row['low_profit'] as String, bandLow),
        isTrue,
        reason: 'low_profit ${row['low_profit']}',
      );
      expect(
        sameAmount(row['high_profit'] as String, bandHigh),
        isTrue,
        reason: 'high_profit ${row['high_profit']}',
      );
      expect(cellText(p, bandListId!), contains(money('123.45')));
      return 'row ${row['product_price_id']} created at 123.45 with band '
          '[${row['low_profit']}, ${row['high_profit']}] = the list\'s '
          '[$bandLow, $bandHigh]';
    });

    // ---- 12 ----
    await step('12 summary bar counts; ⌘Z undoes the last; revert all '
        'restores the load-time prices', () async {
      if (editList == null || base == null) throw TestFailure('no fixture');
      final l = editList;
      final pa = pid(base);
      final pb = pid(base + 1);
      final s0 = grid()!;
      final baseA = s0.baseline[_k(pa, l)]!;
      final baseB = s0.baseline[_k(pb, l)]!;
      final createdBefore = s0.changedCount; // step 11a's created cell
      await openCell(pa, l);
      await tester.enterText(byKey(fieldKey(pa, l)), plus(baseA, '2'));
      await pressEnter(pa, l);
      await pumpUntil(byKey(fieldKey(pb, l)));
      await tester.enterText(byKey(fieldKey(pb, l)), plus(baseB, '2'));
      await pressEnter(pb, l);
      if (keyPrefix('price_cell_field_').evaluate().isNotEmpty) await escape();
      final summary = l10n().pricingGridSummary(createdBefore + 2);
      await pumpUntil(
        find.descendant(
          of: byKey('pricing_grid_summary_bar'),
          matching: find.text(summary),
        ),
      );
      expect(sameAmount(await apiPrice(pb, l), plus(baseB, '2')), isTrue);

      // ⌘Z — needs focus inside the screen's shortcut scope.
      final scope = find.ancestor(
        of: byKey('pricing_grid_search_field'),
        matching: find.byType(CallbackShortcuts),
      );
      final column = find
          .descendant(
            of: find
                .descendant(of: scope.first, matching: find.byType(Focus))
                .first,
            matching: find.byType(Column),
          )
          .first;
      Focus.of(tester.element(column)).requestFocus();
      await pumpFor(const Duration(milliseconds: 300));
      final historyBefore = grid()!.history.length;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await pumpFor(const Duration(milliseconds: 600));
      await gridSettled();
      var how = '⌘Z shortcut';
      if (grid()!.history.length == historyBefore) {
        how = 'undo button (⌘Z did not reach the shortcut)';
        await tapKey('pricing_grid_undo_last');
        await gridSettled();
      }
      expect(
        sameAmount(await apiPrice(pb, l), baseB),
        isTrue,
        reason: 'undo restored the last edit',
      );
      expect(
        sameAmount(await apiPrice(pa, l), plus(baseA, '2')),
        isTrue,
        reason: 'undo touched only the last edit',
      );
      await pumpUntil(
        find.descendant(
          of: byKey('pricing_grid_summary_bar'),
          matching: find.text(l10n().pricingGridSummary(createdBefore + 1)),
        ),
      );

      await tapKey('pricing_grid_revert_all');
      await gridSettled();
      await pumpFor(const Duration(milliseconds: 500));
      expect(sameAmount(await apiPrice(pa, l), baseA), isTrue);
      expect(sameAmount(await apiPrice(pb, l), baseB), isTrue);
      final left = grid()!.changedCount;
      return 'summary read "$summary"; undo via $how restored product $pb; '
          'revert all restored product $pa; $left change(s) remain — the '
          'step-11a created cell, which revert-all cannot un-create by design '
          '(no delete in the bulk write)';
    });

    // ---- 13 ----
    await step(
      '13 changing page with changes outstanding warns first',
      () async {
        if (!(grid()?.hasChanges ?? false)) {
          // Make one so there is something to lose.
          if (editList == null || base == null) throw TestFailure('no fixture');
          final p = pid(base + 3);
          final was = grid()!.baseline[_k(p, editList)]!;
          await openCell(p, editList);
          await tester.enterText(byKey(fieldKey(p, editList!)), plus(was, '3'));
          await pressEnter(p, editList!);
          if (keyPrefix('price_cell_field_').evaluate().isNotEmpty) {
            await escape();
          }
        }
        final before = grid()!.rows.map((r) => r.product.productId).toList();
        final next = MaterialLocalizations.of(
          tester.element(byKey('pricing_grid_table')),
        ).nextPageTooltip;
        await tapFinder(find.byTooltip(next));
        await pumpUntil(byKey('pricing_grid_discard_dialog'));
        await tapKey('pricing_grid_discard_cancel');
        await pumpUntilGone(byKey('pricing_grid_discard_dialog'));
        await pumpFor(const Duration(milliseconds: 600));
        expect(
          uri().queryParameters['page'],
          isNull,
          reason: 'stayed on page 1',
        );
        expect(grid()!.rows.map((r) => r.product.productId).toList(), before);
        expect(grid()!.hasChanges, isTrue, reason: 'history kept');
        return 'next-page opened the discard dialog; "stay" kept page 1 and '
            'its changes';
      },
    );

    // ---- 14 ----
    await step('14 long name ellipsized + tooltip; only the grid scrolls '
        'sideways', () async {
      tester.view.physicalSize = _narrow;
      await pumpFor(const Duration(seconds: 1));
      final s = grid()!;
      final longest = s.rows
          .map((r) => r.product.name)
          .reduce((a, b) => a.length >= b.length ? a : b);
      final nameText = find.descendant(
        of: byKey('pricing_grid_table'),
        matching: find.text(longest),
      );
      await pumpUntil(nameText);
      final w = tester.widget<Text>(nameText.first);
      expect(w.overflow, TextOverflow.ellipsis);
      expect(w.maxLines, 1);
      final tip = tester.widget<Tooltip>(
        find.ancestor(of: nameText.first, matching: find.byType(Tooltip)).first,
      );
      expect(tip.message, longest);
      final para = tester.renderObject<RenderParagraph>(
        find.descendant(of: nameText.first, matching: find.byType(RichText)),
      );
      final truncated = para.didExceedMaxLines;

      bool horizontal(Element e) {
        final sc = e.widget as Scrollable;
        return sc.axisDirection == AxisDirection.left ||
            sc.axisDirection == AxisDirection.right;
      }

      final hScrollables = find.byType(Scrollable).evaluate().where(horizontal);
      final inGrid = find
          .descendant(
            of: byKey('pricing_grid_table'),
            matching: find.byType(Scrollable),
          )
          .evaluate()
          .where(horizontal)
          .toSet();
      final textFields = find
          .descendant(
            of: find.byType(EditableText),
            matching: find.byType(Scrollable),
          )
          .evaluate()
          .toSet();
      final outside = hScrollables
          .where((e) => !inGrid.contains(e) && !textFields.contains(e))
          .toList();
      expect(
        outside,
        isEmpty,
        reason: 'a horizontal scroller outside the grid',
      );
      final extents = inGrid
          .map(
            (e) => ((e as StatefulElement).state as ScrollableState).position,
          )
          .map((pos) => (pos.viewportDimension, pos.maxScrollExtent))
          .toList();
      note(
        'step 14 horizontal scrollers in the grid (viewport, max): $extents',
      );
      final gridScroll = inGrid
          .map((e) => (e as StatefulElement).state as ScrollableState)
          .where((st) => st.position.maxScrollExtent > 50)
          .toList();
      expect(
        gridScroll,
        isNotEmpty,
        reason: 'grid scrolls sideways itself: $extents',
      );
      expect(tester.takeException(), isNull, reason: 'no overflow');
      final searchRight = tester
          .getTopRight(byKey('pricing_grid_search_field'))
          .dx;
      expect(searchRight <= _narrow.width, isTrue);
      final overflow = gridScroll.first.position.maxScrollExtent;
      tester.view.physicalSize = _wide;
      await pumpFor(const Duration(seconds: 1));
      return 'longest name "${longest.length > 40 ? '${longest.substring(0, 40)}…' : longest}" '
          'is ellipsis/maxLines 1 with a full-name tooltip '
          '(${truncated ? 'visibly truncated' : 'fits at this width, not truncated'}); '
          'at ${_narrow.width.toInt()} px the grid scrolls '
          '${overflow.toStringAsFixed(0)} px '
          'internally, no other horizontal scroller';
    });
    tester.view.physicalSize = _wide;

    // ---- 15 ----
    await step(
      '15 "price lists shown" narrows columns; survives navigation',
      () async {
        if (colIds.length < 2) throw TestFailure('need two lists');
        final hide = colIds.firstWhere(
          (id) => id != editList,
          orElse: () => colIds.last,
        );
        // Leaving with changes would prompt; the prompt is step 13's subject.
        await tapKey('pricing_grid_filter_button');
        await pumpUntil(byKey('pricing_grid_columns_section'));
        await tapKey('pricing_grid_column_chip_$hide');
        await pumpFor(const Duration(milliseconds: 500));
        await tapKey('filter_sheet_apply_button');
        await pumpUntilGone(byKey('filter_sheet_apply_button'));
        var s = await gridLoaded();
        final p0 = s.rows.first.product.productId;
        expect(byKey(cellKey(p0, hide)), findsNothing);
        expect(keyPrefix('pricing_grid_column_menu_$hide'), findsNothing);
        for (final id in colIds.where((i) => i != hide)) {
          expect(byKey(cellKey(p0, id)), findsOneWidget);
        }
        await go('/products');
        await pumpUntil(
          byKey('products_table'),
          timeout: const Duration(seconds: 60),
        );
        await go('/pricing');
        s = await gridLoaded();
        expect(
          byKey(cellKey(s.rows.first.product.productId, hide)),
          findsNothing,
          reason: 'choice survived /products and back',
        );
        // Restore every column.
        await tapKey('pricing_grid_filter_button');
        await pumpUntil(byKey('pricing_grid_columns_section'));
        await tapKey('pricing_grid_column_chip_$hide');
        await pumpFor(const Duration(milliseconds: 500));
        await tapKey('filter_sheet_apply_button');
        await pumpUntilGone(byKey('filter_sheet_apply_button'));
        s = await gridLoaded();
        expect(
          byKey(cellKey(s.rows.first.product.productId, hide)),
          findsOneWidget,
        );
        return 'hid list $hide; still hidden after /products → /pricing; '
            're-shown';
      },
    );

    // ---- 17' (editor) ----
    await step("17' editor: column ⋮ menu on every header, actions reachable "
        '(not executed)', () async {
      await go('/pricing');
      final s = await gridLoaded();
      for (final id in colIds) {
        expect(byKey('pricing_grid_column_menu_$id'), findsOneWidget);
      }
      final l = editList ?? colIds.first;
      await tapKey('pricing_grid_column_menu_$l');
      await pumpUntil(byKey('pricing_grid_fill_down_$l'));
      expect(byKey('pricing_grid_adjust_field_$l'), findsOneWidget);
      expect(byKey('pricing_grid_adjust_apply_$l'), findsOneWidget);
      final costExists = s.allLists.any(
        (x) => x.priceListId == costPriceListId,
      );
      expect(
        byKey('pricing_grid_copy_cost_$l'),
        costExists && l != costPriceListId ? findsOneWidget : findsNothing,
      );
      // The anchor toggles: a second tap closes the menu.
      await tapKey('pricing_grid_column_menu_$l');
      await pumpUntilGone(byKey('pricing_grid_fill_down_$l'));
      return 'menu on all ${colIds.length} headers; list $l menu shows fill-down '
          '+ adjust-by-% field/apply; copy-from-cost '
          '${costExists ? 'present' : 'absent (configured cost list $costPriceListId does not exist on this tenant)'}; '
          'nothing executed';
    });

    // ---- 18' (editor) + 11b ----
    int? worklistList;
    await step("18' worklist chips: counts match the API; a chip narrows the "
        'grid to unpriced rows', () async {
      await go('/pricing');
      final s = await gridLoaded();
      await pumpUntil(byKey('pricing_grid_worklist_all'));
      final facets = await products.productMissingPriceFacets(
        status: EntityStatus.active,
      );
      final counts = {for (final f in facets) f.priceListId: f.missingCount};
      for (final pl in s.allLists) {
        final label = l10n().pricingGridWorklistMissing(
          pl.name,
          counts[pl.priceListId] ?? 0,
        );
        await pumpUntil(
          find.descendant(
            of: byKey('pricing_grid_worklist_${pl.priceListId}'),
            matching: find.text(label),
          ),
        );
      }
      // The smallest non-empty worklist among the pre-existing lists.
      final candidates =
          s.allLists
              .where((pl) => !pl.name.startsWith(tag))
              .where((pl) => (counts[pl.priceListId] ?? 0) > 0)
              .toList()
            ..sort(
              (a, b) =>
                  counts[a.priceListId]!.compareTo(counts[b.priceListId]!),
            );
      if (candidates.isEmpty) throw TestFailure('no list missing a price');
      final target = candidates.first.priceListId;
      await tapKey('pricing_grid_worklist_$target');
      await pumpUntilTrue(
        () => uri().queryParameters['missing'] == '$target',
        'missing=$target',
      );
      final w = await gridLoaded();
      final expected = await products.list(
        status: EntityStatus.active,
        missingPriceList: target,
        limit: 20,
      );
      expect(
        w.rows.map((r) => r.product.productId).toList(),
        expected.items.map((p) => p.productId).toList(),
      );
      expect(w.page!.total, counts[target]);
      for (final r in w.rows) {
        expect(
          cellText(r.product.productId, target),
          l10n().pricingPriceNotSet,
        );
      }
      final chip = tester.widget<ChoiceChip>(
        byKey('pricing_grid_worklist_$target'),
      );
      expect(chip.selected, isTrue);
      worklistList = target;
      return 'chips for ${s.allLists.length} lists match '
          '/products/prices/missing-facets (${s.allLists.map((p) => '${p.priceListId}:${counts[p.priceListId]}').join(', ')}); '
          '"${candidates.first.name}" chip → ${w.rows.length} rows, all "not set", '
          'same ids/total as GET /products?missing_price_list=$target';
    });

    await step('11b fill a worklist cell; count drops; a sales order still '
        'accepts the normal price', () async {
      final target = worklistList;
      if (target == null) throw TestFailure('no worklist from 18\'');
      final w = grid()!;
      await snapshotProducts(w.rows.map((r) => r.product.productId));
      final before = w.page!.total;
      final p = w.rows.first.product.productId;
      // A "normal" price: what the product sells for on another list, if any.
      final other = snapshotRows[p]!.where(
        (x) => x.priceList.priceListId != target,
      );
      final price = other.isEmpty
          ? '100.00'
          : Decimal.parse(other.first.price).toStringAsFixed(2);
      await openCell(p, target);
      await tester.enterText(byKey(fieldKey(p, target)), price);
      await pressEnter(p, target);
      expect(find.byType(Dialog), findsNothing);
      if (keyPrefix('price_cell_field_').evaluate().isNotEmpty) await escape();
      final row = await apiPriceRow(p, target);
      expect(row, isNotNull);
      final listRes = await dio.get<Map<String, dynamic>>(
        '/api/v1/price-lists/$target',
      );
      final listLow = listRes.data!['low_profit_margin'] as String;
      final listHigh = listRes.data!['high_profit_margin'] as String;
      expect(sameAmount(row!['low_profit'] as String, listLow), isTrue);
      expect(sameAmount(row['high_profit'] as String, listHigh), isTrue);
      final listName = w.allLists
          .firstWhere((x) => x.priceListId == target)
          .name;
      await pumpUntil(
        find.descendant(
          of: byKey('pricing_grid_worklist_$target'),
          matching: find.text(
            l10n().pricingGridWorklistMissing(listName, before - 1),
          ),
        ),
      );

      // A sales order whose customer buys on this list.
      String orderNote;
      final customers = await dio.get<Map<String, dynamic>>(
        '/api/v1/customers',
        queryParameters: {'limit': 100},
      );
      final onList = (customers.data!['items'] as List)
          .cast<Map<String, dynamic>>()
          .where((c) => (c['price_list'] as Map?)?['price_list_id'] == target)
          .toList();
      if (onList.isEmpty) {
        orderNote =
            'no customer on list $target among the first 100; '
            'sales-order check skipped';
      } else {
        final customerId = onList.first['customer_id'] as int;
        final order = await orders.open(
          customer: customerId,
          origin: SaleOrigin.backOffice,
        );
        cancelledOrderId = order.id;
        try {
          final withLine = await orders.addLine(
            saleId: order.id,
            product: p,
            quantity: '1',
          );
          final line = withLine.lines.singleWhere((x) => x.product == p);
          expect(
            sameAmount(line.price, price),
            isTrue,
            reason: 'line priced from the new row',
          );
          final explicit = await orders.addLine(
            saleId: order.id,
            product: p,
            quantity: '1',
            price: price,
          );
          expect(explicit.lines.where((x) => x.product == p), hasLength(2));
        } finally {
          await orders.cancel(saleId: order.id);
        }
        orderNote =
            'draft order ${order.id} (customer $customerId) took the '
            'product at ${money(price)} both from the list and explicitly, '
            'then was cancelled';
      }
      return 'product $p on list $target created at $price, band '
          '[${row['low_profit']}, ${row['high_profit']}] = list margins '
          '[$listLow, $listHigh] (quickstart\'s "[0,1] if 0/0" is superseded '
          'by research R6 Landed); chip $before → ${before - 1}; $orderNote';
    });

    // ==================================================================
    // 16 / 17' — read-only account
    // ==================================================================
    if (_roUser.isEmpty || _roPass.isEmpty) {
      softFinding('16 read-only', 'MBE_QA033_USERNAME/_PASSWORD not set');
    } else {
      // Leave the editor session cleanly: a discard prompt is not this
      // step's subject.
      await go('/products');
      await container().read(authProvider.notifier).signOut();
      await login(_roUser, _roPass);

      await step('16 read-only: prices legible, nothing opens, no menu, no '
          'summary bar, hint says why', () async {
        await go('/pricing');
        final s = await gridLoaded();
        expect(s.rows, isNotEmpty);
        final ids = s.rows.take(5).map((r) => r.product.productId).toList();
        final api = await prices.listForProducts(
          productIds: ids,
          priceListIds: s.allLists.map((l) => l.priceListId).toList(),
        );
        var checked = 0;
        for (final p in ids) {
          for (final pl in s.allLists) {
            final match = api.where(
              (x) =>
                  x.productId == p && x.priceList.priceListId == pl.priceListId,
            );
            expect(
              cellText(p, pl.priceListId),
              match.isEmpty
                  ? l10n().pricingPriceNotSet
                  : money(match.first.price),
            );
            checked++;
          }
        }
        final priced = api.first;
        await tester.tap(
          byKey(cellKey(priced.productId, priced.priceList.priceListId)),
        );
        await pumpFor(const Duration(milliseconds: 600));
        expect(keyPrefix('price_cell_field_'), findsNothing);
        expect(grid()!.active, isNull);
        expect(byKey('pricing_grid_summary_bar'), findsNothing);
        expect(find.text(l10n().pricingGridReadOnlyHint), findsOneWidget);
        expect(find.text(l10n().pricingGridHint), findsNothing);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await pumpFor(const Duration(milliseconds: 400));
        expect(byKey('pricing_grid_summary_bar'), findsNothing);
        return '$checked cells match the API; tapping a price opened nothing; '
            'hint "${l10n().pricingGridReadOnlyHint}"';
      });

      await step("17' read-only: no column ⋮ menu on any header", () async {
        await gridLoaded();
        expect(keyPrefix('pricing_grid_column_menu_'), findsNothing);
        for (final pl in grid()!.allLists) {
          expect(
            find.descendant(
              of: byKey('pricing_grid_table'),
              matching: find.text(pl.name),
            ),
            findsWidgets,
          );
        }
        return 'headers render names only';
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
  }, timeout: const Timeout(Duration(minutes: 15)));
}

PriceCellKey _k(int p, int l) => PriceCellKey(productId: p, priceListId: l);

/// Every price list this test creates is named with this prefix, which is
/// what the pre-run sweep and teardown match on.
const _tagPrefix = 'QS033 ';
const _journalKey = 'qs033_quickstart_journal';

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
