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

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/kardex_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/stock_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_selection.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_sources.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/071-stock-kardex/quickstart.md walkthrough steps 1-11
/// against the REAL app (macOS desktop) and a live mbe-api (task T024), and
/// asserts SC-003 on the way: a stock row reaches its kardex in two taps (the
/// row, then "Ver kardex"), and a catalog product reaches its stock view in
/// one ("Ver existencias").
///
///   caffeinate -dimsu flutter test \
///     integration_test/stock_kardex_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env
///
/// Needs `MBE_POS_*` (the administrator; W1 = its point-of-sale warehouse),
/// and optionally `MBE_TEST_*` (`qanoaccess`, the gate in step 1b).
///
/// **Read-only: it writes nothing.** Fixtures are discovered at run time:
/// the walkthrough product P is a W1 product with stock in several
/// warehouses (and in transit, when one is), and the in-transit warehouse
/// comes from a product's in-transit stock.
///
/// Deviations from the walkthrough, on purpose:
/// - Step 4: "reloading" re-opens the saved URL after leaving the screen.
/// - Step 5: in-transit warehouses are never listed, so the sheet's picker
///   can't offer one; it is opened through the URL.
/// - Steps 6-8 use P in W1 rather than product 2926 in warehouse 15.
/// - Step 10 sets the ranges through the pushed page's URL
///   (`/inventory/kardex/view?...`), not the date picker.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');

const _wide = Size(1400, 1000);
const _stock = '/inventory/stock';
const _kardex = '/inventory/kardex';

/// How many W1 rows step 6's product discovery reads.
const _scan = 30;

/// Linked kardex rows, best first: a count, a receipt, then the rest.
const _linkPreference = [12, 4, 8, 3, 5, 2, 1, 13];

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

  testWidgets('Stock and kardex walkthrough (real app, live mbe-api)', (
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
    // API side (independent of the app's own session; reads only)
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final auth = AuthRepositoryImpl(dio);
    final token = await auth.login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final stock = StockRepositoryImpl(dio);
    final kardexRepo = KardexRepositoryImpl(dio);
    final me = await auth.me();
    final w1 = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: me.settings!.pointSaleId!)).warehouseId;
    final w1Row = await WarehouseRepositoryImpl(dio).get(warehouseId: w1);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last30 = KardexSelection.initial();

    final w1Page = await stock.list(
      warehouseId: w1,
      includeZero: false,
      skip: 0,
      limit: 50,
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
    Uri uri() => currentRouteUri(router());
    String location() =>
        router().routerDelegate.currentConfiguration.last.matchedLocation;
    String qty(Decimal d) =>
        container().read(formattersProvider).display.quantity(d.toString());

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
      Duration timeout = const Duration(seconds: 90),
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
      timeout: timeout ?? const Duration(seconds: 90),
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

    Finder editable(String key) =>
        find.descendant(of: byKey(key), matching: find.byType(EditableText));

    Finder inKey(String key, Finder f) =>
        find.descendant(of: byKey(key), matching: f);

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

    Future<void> back() async {
      final tooltip = MaterialLocalizations.of(
        tester.element(find.byType(Scaffold).last),
      ).backButtonTooltip;
      await tapFinder(find.byTooltip(tooltip));
    }

    Future<void> waitForStock() async {
      await pumpUntilTrue(
        () =>
            !spinning() &&
            (byKey('stock_table').evaluate().isNotEmpty ||
                find.text(l10n.inventoryStockEmpty).evaluate().isNotEmpty ||
                find
                    .text(l10n.inventoryStockFilteredEmpty)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .text(l10n.apiErrorWarehouseInTransitLocation)
                    .evaluate()
                    .isNotEmpty),
        'the stock list loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Future<void> waitForKardex() async {
      await pumpUntilTrue(
        () =>
            !spinning() &&
            byKey('kardex_summary').evaluate().isNotEmpty &&
            (byKey('kardex_table').evaluate().isNotEmpty ||
                find.text(l10n.inventoryKardexEmpty).evaluate().isNotEmpty),
        'the kardex loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// The texts of [table]'s row whose cell is [anchor], left to right.
    List<String> rowTexts(Finder table, Finder anchor) {
      final y = tester.getCenter(anchor.first).dy;
      final cells = <({double x, String text})>[];
      for (final e
          in find
              .descendant(of: table, matching: find.byType(Text))
              .evaluate()) {
        final box = e.renderObject;
        if (box is! RenderBox || !box.hasSize) continue;
        final c = box.localToGlobal(box.size.center(Offset.zero));
        if ((c.dy - y).abs() > 4) continue;
        final data = (e.widget as Text).data;
        if (data == null) continue;
        cells.add((x: c.dx, text: data));
      }
      cells.sort((a, b) => a.x.compareTo(b.x));
      return [for (final c in cells) c.text];
    }

    Future<void> recover() async {
      for (var i = 0; i < 4; i++) {
        final dlg = find.byType(Dialog);
        final sheet = find.byType(BottomSheet);
        final target = dlg.evaluate().isNotEmpty
            ? dlg
            : (sheet.evaluate().isNotEmpty ? sheet : null);
        if (target == null) break;
        Navigator.of(tester.element(target.first), rootNavigator: true).pop();
        await pumpFor(const Duration(milliseconds: 400));
      }
      final ex = tester.takeException();
      // ignore: avoid_print
      if (ex != null) print('QS: swallowed exception: ${_short(ex)}');
    }

    final results = <_Result>[];
    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body().timeout(const Duration(minutes: 4));
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: ${_short(ex)}');
        results.add(_Result(name, _Outcome.pass, 'ok'));
      } catch (e) {
        // ignore: avoid_print
        print(
          'QS: failed at ${uri()} (matches: ${router().routerDelegate.currentConfiguration.matches.map((m) => m.matchedLocation).toList()})',
        );
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
    // Fixtures (reads only)
    // ------------------------------------------------------------------
    // P: a W1 product with stock in the most warehouses, preferring one with
    // in-transit stock; the in-transit warehouse comes from the same scan.
    StockRow? p;
    ProductStock? pStock;
    int? transit;
    for (final r in w1Page.items.take(_scan)) {
      final s = await stock.product(r.productId);
      transit ??= s.inTransit.firstOrNull?.warehouseId;
      final better =
          pStock == null ||
          (s.inTransit.isNotEmpty && pStock.inTransit.isEmpty) ||
          (s.inTransit.isNotEmpty == pStock.inTransit.isNotEmpty &&
              s.warehouses.length > pStock.warehouses.length);
      if (better) {
        p = r;
        pStock = s;
      }
      if (s.inTransit.isNotEmpty && s.warehouses.length >= 3) break;
    }
    note(
      'W1 = $w1 (${w1Row.name}), ${w1Page.total} rows; P = '
      '${p == null ? 'none' : '#${p.productId} "${p.productCode}" in '
                '${pStock!.warehouses.map((r) => 'W${r.warehouseId}').join(',')}, '
                '${pStock.inTransit.length} in transit'}; in-transit W$transit',
    );

    // ------------------------------------------------------------------
    // Login (admin)
    // ------------------------------------------------------------------
    note('logging in as admin');
    await login(_adminUser, _adminPass);

    // ---- 1: nav entries after Conteos físicos ---------------------------
    await step('1 Existencias then Kardex in Inventario after Conteos '
        'físicos', () async {
      final counts = byKey('nav_dest_inventory-counts');
      final stockEntry = byKey('nav_dest_inventory-stock');
      final kardexEntry = byKey('nav_dest_inventory-kardex');
      await pumpUntil(stockEntry);
      expect(
        find.descendant(
          of: stockEntry,
          matching: find.text(l10n.navInventoryStock),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: kardexEntry,
          matching: find.text(l10n.navInventoryKardex),
        ),
        findsOneWidget,
      );
      final yCounts = tester.getTopLeft(counts).dy;
      final yStock = tester.getTopLeft(stockEntry).dy;
      final yKardex = tester.getTopLeft(kardexEntry).dy;
      expect(yCounts, lessThan(yStock));
      expect(yStock, lessThan(yKardex));
      await tapFinder(stockEntry);
      await pumpUntilTrue(() => location() == _stock, 'the stock route');
    });

    // ---- 2: starts on W1 ------------------------------------------------
    await step('2 Existencias starts on W1: strip names it, URL has '
        'warehouse=$w1', () async {
      await go(_stock);
      await pumpUntilTrue(
        () => uri().queryParameters['warehouse'] == '$w1',
        'warehouse=$w1 in the URL (at ${uri()})',
      );
      await waitForStock();
      await pumpUntil(
        inKey('stock_selection', find.textContaining(w1Row.name)),
      );
      expect(byKey('stock_table'), findsOneWidget);
    });

    // ---- 3: figures ------------------------------------------------------
    await step('3 a row shows on hand, reserved, available = on hand − '
        'reserved, incoming; negatives keep the minus', () async {
      await go('$_stock?warehouse=$w1');
      await waitForStock();
      final row =
          w1Page.items.where((r) => r.reserved != Decimal.zero).firstOrNull ??
          w1Page.items.first;
      expect(row.available, row.onHand - row.reserved);
      final anchor = inKey('stock_table', find.text(row.productCode));
      await pumpUntil(anchor);
      final cells = rowTexts(byKey('stock_table'), anchor);
      expect(cells, [
        row.productCode,
        row.productName,
        qty(row.onHand),
        qty(row.reserved),
        qty(row.available),
        qty(row.incoming),
      ]);
      note('row ${row.productCode}: $cells');
      final negative = w1Page.items
          .where((r) => r.onHand < Decimal.zero)
          .firstOrNull;
      if (negative == null) {
        note('3 no negative on hand on W1 page 1');
      } else {
        final c = rowTexts(
          byKey('stock_table'),
          inKey('stock_table', find.text(negative.productCode)),
        );
        expect(c[2], matches(RegExp(r'^[-−]')), reason: 'minus sign');
        note('negative row ${negative.productCode}: ${c[2]}');
      }
    });

    // ---- 4: search, switch, reload ---------------------------------------
    await step('4 search narrows; "Mostrar sin existencia" in the URL; the '
        'saved URL restores warehouse, search and switch', () async {
      final code = w1Page.items.first.productCode;
      final part = code.length >= 3 ? code.substring(0, code.length - 1) : code;
      await go('$_stock?warehouse=$w1');
      await waitForStock();
      await pumpUntil(editable('stock_search'));
      await tester.enterText(editable('stock_search').first, part);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await pumpUntilTrue(
        () => uri().queryParameters['q'] == part,
        'q=$part in the URL (at ${uri()})',
      );
      await waitForStock();
      final narrowed = await stock.list(
        warehouseId: w1,
        q: part,
        includeZero: false,
        skip: 0,
        limit: 50,
      );
      expect(narrowed.total, lessThanOrEqualTo(w1Page.total));
      for (final r in narrowed.items) {
        await pumpUntil(inKey('stock_table', find.text(r.productCode)));
      }
      final outside = w1Page.items
          .where((r) => !narrowed.items.any((n) => n.productId == r.productId))
          .firstOrNull;
      if (outside != null) {
        expect(
          inKey('stock_table', find.text(outside.productCode)),
          findsNothing,
        );
      }

      await tapKey('stock_filter_button');
      await pumpUntil(byKey('stock_include_zero'));
      expect(
        tester.widget<SwitchListTile>(byKey('stock_include_zero')).value,
        isFalse,
      );
      await tapKey('stock_include_zero');
      await pumpUntilTrue(
        () => uri().queryParameters['include_zero'] == 'true',
        'include_zero in the URL',
      );
      await tapKey('filter_sheet_apply_button');
      await pumpUntilGone(byKey('stock_include_zero'));
      await waitForStock();
      final withZero = await stock.list(
        warehouseId: w1,
        q: part,
        includeZero: true,
        skip: 0,
        limit: 50,
      );
      expect(withZero.total, greaterThanOrEqualTo(narrowed.total));
      for (final r in withZero.items) {
        await pumpUntil(inKey('stock_table', find.text(r.productCode)));
      }
      final saved = uri().toString();
      note(
        'q="$part": ${narrowed.total} of ${w1Page.total}; with zero '
        '${withZero.total}; saved $saved',
      );

      await go('/');
      await go(saved);
      await waitForStock();
      expect(uri().queryParameters['warehouse'], '$w1');
      expect(uri().queryParameters['q'], part);
      expect(uri().queryParameters['include_zero'], 'true');
      await pumpUntil(
        inKey('stock_selection', find.textContaining(w1Row.name)),
      );
      expect(
        tester
            .widget<EditableText>(editable('stock_search').first)
            .controller
            .text,
        part,
      );
      for (final r in withZero.items) {
        await pumpUntil(inKey('stock_table', find.text(r.productCode)));
      }
      await tapKey('stock_filter_button');
      await pumpUntil(byKey('stock_include_zero'));
      expect(
        tester.widget<SwitchListTile>(byKey('stock_include_zero')).value,
        isTrue,
      );
      await tapKey('filter_sheet_apply_button');
      await pumpUntilGone(byKey('stock_include_zero'));
    });

    // ---- 5: in-transit warehouse -----------------------------------------
    if (transit == null) {
      note('5 SKIPPED: no in-transit warehouse found among W1 products');
    } else {
      await step(
        '5 in-transit W$transit: the Spanish refusal, no list',
        () async {
          await go('$_stock?warehouse=$transit');
          await waitForStock();
          await pumpUntil(find.text(l10n.apiErrorWarehouseInTransitLocation));
          expect(byKey('stock_table'), findsNothing);
        },
      );
    }

    if (p == null) {
      note('6-9, 11 SKIPPED: W1 has no stock rows');
    } else {
      final prod = p;
      final ps = pStock!;
      final title = l10n
          .inventoryStockProductTitle(prod.productCode, prod.productName)
          .trim();
      final pKardexUri = Uri(
        path: kardexPagePath,
        queryParameters: {'product': '${prod.productId}', 'warehouse': '$w1'},
      );
      var onHandShown = '';

      // ---- 6: product view (SC-003 tap 1) --------------------------------
      await step('6 tap P\'s row: "$title", every warehouse, totals, '
          'En tránsito', () async {
        await go(
          Uri(
            path: _stock,
            queryParameters: {'warehouse': '$w1', 'q': prod.productCode},
          ).toString(),
        );
        await waitForStock();
        final anchor = inKey('stock_table', find.text(prod.productCode));
        await pumpUntil(anchor);
        onHandShown = rowTexts(byKey('stock_table'), anchor)[2];
        await tapFinder(anchor); // SC-003: one tap to the product view.
        await pumpUntilTrue(
          () => location() == '$_stock/products/${prod.productId}',
          'the product view (at ${location()})',
        );
        await pumpUntil(byKey('product_stock_table'));
        await pumpUntil(find.text(title));
        for (final r in ps.warehouses) {
          await pumpUntil(byKey('product_stock_kardex_${r.warehouseId}'));
        }
        final totals = ps.totals;
        for (final v in [
          totals.onHand,
          totals.reserved,
          totals.available,
          totals.incoming,
        ]) {
          expect(
            inKey('product_stock_totals', find.text(qty(v))),
            findsWidgets,
            reason: 'total ${qty(v)}',
          );
        }
        if (ps.inTransit.isEmpty) {
          expect(byKey('product_stock_in_transit'), findsNothing);
        } else {
          expect(byKey('product_stock_in_transit'), findsOneWidget);
          expect(
            inKey(
              'product_stock_in_transit',
              find.text(l10n.inventoryStockInTransitHeading),
            ),
            findsOneWidget,
          );
          for (final t in ps.inTransit) {
            expect(
              inKey('product_stock_in_transit', find.text(qty(t.onHand))),
              findsWidgets,
            );
          }
        }
        note(
          '${ps.warehouses.length} warehouse row(s), on hand '
          '${totals.onHand}, ${ps.inTransit.length} in transit',
        );
      });

      // ---- 7: to the kardex (SC-003 tap 2) --------------------------------
      await step('7 "Ver kardex" on W1 opens Kardex with P, W1, last 30 '
          'days (two taps from the stock row)', () async {
        if (location() != '$_stock/products/${prod.productId}') {
          await go('$_stock/products/${prod.productId}');
        }
        await tapKey('product_stock_kardex_$w1'); // SC-003: tap two.
        await pumpUntilTrue(
          () => location() == kardexPagePath,
          'the kardex page (at ${location()})',
        );
        expect(uri().queryParameters['product'], '${prod.productId}');
        expect(uri().queryParameters['warehouse'], '$w1');
        await waitForKardex();
        expect(find.byType(BackButton), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(l10n.navInventoryKardex),
          ),
          findsOneWidget,
        );
        final fmt = container().read(formattersProvider);
        await pumpUntil(
          inKey('kardex_selection', find.textContaining(prod.productCode)),
        );
        await pumpUntil(
          inKey('kardex_selection', find.textContaining(w1Row.name)),
        );
        expect(
          inKey(
            'kardex_selection',
            find.text(
              l10n.dateRangeFilterRange(
                fmt.display.date(last30.from),
                fmt.display.date(last30.to),
              ),
            ),
          ),
          findsOneWidget,
        );
      });

      // ---- 8: balance ------------------------------------------------------
      Kardex? k;
      await step('8 opening + in − out = closing = Existencias on hand '
          '(SC-002); count rows show "Conteo físico" and folio', () async {
        if (location() != kardexPagePath) await go(pKardexUri.toString());
        await waitForKardex();
        k = await kardexRepo.read(
          productId: prod.productId,
          warehouseId: w1,
          from: last30.from,
          to: last30.to,
        );
        final kk = k!;
        expect(kk.opening + kk.totalIn - kk.totalOut, kk.closing);
        final summary = rowTexts(
          byKey('kardex_summary'),
          inKey(
            'kardex_summary',
            find.text(l10n.inventoryKardexSummaryOpening),
          ),
        );
        for (final v in [kk.opening, kk.totalIn, kk.totalOut, kk.closing]) {
          expect(
            inKey('kardex_summary', find.text(qty(v))),
            findsWidgets,
            reason: 'summary ${qty(v)} in $summary',
          );
        }
        expect(qty(kk.closing), onHandShown, reason: 'closing vs Existencias');
        final live = (await stock.list(
          warehouseId: w1,
          q: prod.productCode,
          includeZero: true,
          skip: 0,
          limit: 50,
        )).items.firstWhere((r) => r.productId == prod.productId);
        expect(kk.closing, live.onHand);
        final counts = kk.movements
            .take(100)
            .where((m) => m.sourceType == 12 && m.document != null)
            .toList();
        for (final m in counts.take(3)) {
          final cell = byKey('kardex_doc_${m.id}');
          await pumpUntil(cell);
          final cells = rowTexts(byKey('kardex_table'), cell);
          expect(cells, contains(l10n.inventoryKardexSourceCount));
          final serial = m.document!.serial;
          expect(
            tester.widget<Text>(cell).data,
            serial != null ? '$serial' : '#${m.document!.id}',
          );
        }
        note(
          'P W1: ${kk.opening} + ${kk.totalIn} − ${kk.totalOut} = '
          '${kk.closing} (Existencias "$onHandShown"); '
          '${kk.movements.length} rows, ${counts.length} count row(s)',
        );
      });

      // ---- 9: document links ----------------------------------------------
      await step('9 a linked row opens its document; back returns to the same '
          'kardex; an unlinked row does nothing', () async {
        final access = container().read(accessControlProvider);
        KardexMovement? pick(Iterable<KardexMovement> rows) {
          for (final t in _linkPreference) {
            final m = rows
                .where(
                  (m) =>
                      m.sourceType == t &&
                      kardexDocumentRoute(m.document, access) != null,
                )
                .firstOrNull;
            if (m != null) return m;
          }
          return null;
        }

        var sel = last30;
        var rows = (k?.movements ?? const <KardexMovement>[]).take(100);
        var linked = pick(rows);
        if (linked == null) {
          // Nothing linked in 30 days: the last 366 days.
          sel = KardexSelection(
            productId: prod.productId,
            warehouseId: w1,
            from: DateTime(today.year, today.month, today.day - 365),
            to: today,
          );
          rows = (await kardexRepo.read(
            productId: prod.productId,
            warehouseId: w1,
            from: sel.from,
            to: sel.to,
          )).movements.take(100);
          linked = pick(rows);
        }
        if (linked == null) {
          throw TestFailure('no linked kardex row for P in W1 in 366 days');
        }
        final kardexUri = KardexSelection(
          productId: prod.productId,
          warehouseId: w1,
          from: sel.from,
          to: sel.to,
        ).toUri(kardexPagePath);
        if (location() != kardexPagePath ||
            uri().queryParameters['from'] !=
                kardexUri.queryParameters['from']) {
          // Stays on the pushed page, as its own range change does.
          router().replace(kardexUri.toString());
          await pumpFor(const Duration(milliseconds: 500));
        }
        await waitForKardex();
        final before = uri();
        final target = kardexDocumentRoute(linked.document, access)!;
        await tapKey('kardex_doc_${linked.id}');
        await pumpUntilTrue(
          () => location() == target,
          '$target (at ${location()})',
        );
        final facts = switch (linked.sourceType) {
          12 => 'inventory_count_facts',
          4 || 8 => 'inventory_receipt_facts',
          3 => 'inventory_issue_facts',
          5 => 'inventory_transfer_facts',
          _ => null,
        };
        if (facts != null) await pumpUntil(byKey(facts));
        await pumpFor(const Duration(seconds: 1));
        await back();
        await pumpUntilTrue(
          () => location() == kardexPagePath,
          'back on the kardex page (at ${location()})',
        );
        expect(uri().queryParameters, before.queryParameters);
        await waitForKardex();
        note(
          'type ${linked.sourceType} row ${linked.id} -> $target -> back to '
          '${uri()}',
        );

        final unlinked = rows
            .where(
              (m) =>
                  (m.sourceType == 6 || m.sourceType == 10) &&
                  kardexDocumentRoute(m.document, access) == null,
            )
            .firstOrNull;
        if (unlinked == null) {
          note('9 unlinked check SKIPPED: no itinerary or purchase-order row');
        } else {
          expect(byKey('kardex_doc_${unlinked.id}'), findsNothing);
          final label = unlinked.document != null
              ? (unlinked.document!.serial != null
                    ? '${unlinked.document!.serial}'
                    : '#${unlinked.document!.id}')
              : '#${unlinked.reference}';
          final cell = inKey('kardex_table', find.text(label));
          await tapFinder(cell);
          await pumpFor(const Duration(seconds: 1));
          expect(location(), kardexPagePath);
          note('unlinked type ${unlinked.sourceType} "$label" stayed put');
        }
      });

      // ---- 9b: back to the product view; the nav still works ------------
      await step('9b back on the kardex page returns to the product view; the '
          'side nav still works', () async {
        expect(location(), kardexPagePath);
        await back();
        await pumpUntilTrue(
          () => location() == '$_stock/products/${prod.productId}',
          'back on the product view (at ${location()})',
        );
        await pumpUntil(byKey('product_stock_table'));
        await back();
        await pumpUntilTrue(
          () => location() == _stock,
          'back on Existencias (at ${location()})',
        );
        await tapFinder(byKey('nav_dest_inventory-kardex'));
        await pumpUntilTrue(() => location() == _kardex, 'the Kardex tab');
        await pumpUntil(byKey('kardex_filter_button'));
        expect(find.byType(BackButton), findsNothing);
        await tapFinder(byKey('nav_dest_inventory-stock'));
        await pumpUntilTrue(() => location() == _stock, 'the stock tab');
        await pumpUntil(byKey('stock_filter_button'));
        await waitForStock();
      });

      // ---- 10: invalid ranges -------------------------------------------
      await step('10 367 days: the limit text, no request; reversed: its '
          'text', () async {
        final tooLong = KardexSelection(
          productId: prod.productId,
          warehouseId: w1,
          from: DateTime(today.year, today.month, today.day - 366),
          to: today,
        );
        expect(tooLong.state, KardexSelectionState.tooLong);
        await go(tooLong.toUri(kardexPagePath).toString());
        await pumpUntil(byKey('kardex_range_too_long'));
        expect(
          inKey(
            'kardex_range_too_long',
            find.text('El rango no puede pasar de 366 días.'),
          ),
          findsOneWidget,
        );
        expect(
          container().exists(kardexControllerProvider(tooLong)),
          isFalse,
          reason: 'a request was made for the 367-day range',
        );
        final reversed = KardexSelection(
          productId: prod.productId,
          warehouseId: w1,
          from: today,
          to: DateTime(today.year, today.month, today.day - 1),
        );
        await go(reversed.toUri(kardexPagePath).toString());
        await pumpUntil(byKey('kardex_range_reversed'));
        expect(
          inKey(
            'kardex_range_reversed',
            find.text(l10n.inventoryKardexRangeReversed),
          ),
          findsOneWidget,
        );
        expect(container().exists(kardexControllerProvider(reversed)), isFalse);
      });

      // ---- 11: catalog link (SC-003, one tap) ---------------------------
      await step('11 Productos View mode: "Ver existencias" opens the product '
          'view in one tap; absent in edit mode', () async {
        await go('/products/${prod.productId}?view=true');
        await pumpUntil(byKey('view_stock_button'));
        await tapKey('view_stock_button'); // SC-003: one tap.
        await pumpUntilTrue(
          () => location() == '$_stock/products/${prod.productId}',
          'the product view (at ${location()})',
        );
        await pumpUntil(byKey('product_stock_table'));
        await pumpUntil(find.text(title));
        await back();
        await pumpUntilTrue(
          () => location() == '/products/${prod.productId}',
          'back on the product (at ${location()})',
        );
        await go('/products/${prod.productId}');
        await pumpUntilTrue(
          () =>
              editable('code_field').evaluate().isNotEmpty &&
              tester
                      .widget<EditableText>(editable('code_field').first)
                      .controller
                      .text ==
                  prod.productCode,
          'the product form in edit mode',
        );
        await pumpFor(const Duration(seconds: 1));
        expect(byKey('view_stock_button'), findsNothing);
      });
    }

    // ---- 1b: qanoaccess has no entries and no routes ---------------------
    if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
      await container().read(authProvider.notifier).signOut();
      await login(_noAccessUser, _noAccessPass);
      await step(
        '1b qanoaccess: no entries; both routes redirect home',
        () async {
          expect(byKey('nav_dest_inventory-stock'), findsNothing);
          expect(byKey('nav_dest_inventory-kardex'), findsNothing);
          await go(_stock);
          expect(location(), '/');
          expect(byKey('stock_table'), findsNothing);
          await go(_kardex);
          expect(location(), '/');
          expect(byKey('kardex_summary'), findsNothing);
        },
      );
    } else {
      note('1b SKIPPED: MBE_TEST_USERNAME/_PASSWORD not given');
    }

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
  }, timeout: const Timeout(Duration(minutes: 30)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
