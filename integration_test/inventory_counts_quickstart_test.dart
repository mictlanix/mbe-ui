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
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/070-inventory-adjustments-count/quickstart.md walkthrough
/// steps 1-8, 11 and 12 against the REAL app (macOS desktop) and a live
/// mbe-api (task T032).
///
///   caffeinate -dimsu flutter test \
///     integration_test/inventory_counts_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env
///
/// Needs `MBE_POS_*` (the administrator; W1 = its point-of-sale warehouse),
/// and optionally `MBE_TEST_*` (`qanoaccess`, the gate in step 1) and
/// `MBE_READONLY_*` (`qareadonly`, step 12b; skipped when it has no read on
/// PhysicalCountAdjustment (74)).
///
/// Deviations from the walkthrough, on purpose:
/// - Step 5: the Agregar producto picker only offers stockable products, so
///   P3 (non-stockable) is refused through quick entry instead.
/// - Step 7: a 3-row paste with one unknown code (whole batch refused, the
///   row listed, 0 applied) instead of 2,001 rows; the batching itself is
///   covered by the sender unit test and the live test.
/// - Step 11 runs on the listed warehouse with the fewest stock rows (at most
///   [_maxRows]), never W1, and puts every zeroed product back.
///
/// Writes data, all tagged "QA070 …": a confirmed count of P1 and P2 and a
/// final count that puts their original on hand back; a confirmed
/// include-uncounted count and its restoring count; cancelled drafts. Every
/// draft this run leaves is cancelled at the end.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');
const _roUser = String.fromEnvironment('MBE_READONLY_USERNAME');
const _roPass = String.fromEnvironment('MBE_READONLY_PASSWORD');

const _wide = Size(1400, 1000);
const _list = '/inventory/counts';

/// The most stock rows step 11's warehouse may have (every one is zeroed,
/// then put back).
const _maxRows = 25;

enum _Outcome { pass, fail }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

typedef _Product = ({int id, String code, String name, Decimal onHand});

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Physical counts walkthrough (real app, live mbe-api)', (
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
    final auth = AuthRepositoryImpl(dio);
    final token = await auth.login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final counts = InventoryCountRepositoryImpl(dio);
    final warehouses = WarehouseRepositoryImpl(dio);
    final products = ProductRepositoryImpl(dio);
    final stock = api.StockApi(dio, appSerializers);
    final me = await auth.me();
    final w1 = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: me.settings!.pointSaleId!)).warehouseId;
    final w1Row = await warehouses.get(warehouseId: w1);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    Future<List<api.StockRow>> stockRows(int warehouse, {int? max}) async {
      final rows = <api.StockRow>[];
      for (var skip = 0; ; skip += 100) {
        final page = (await stock.listStockApiV1StockGet(
          warehouse: warehouse,
          skip: skip,
          limit: 100,
        )).data!;
        rows.addAll(page.items);
        if (page.items.length < 100) break;
        if (max != null && rows.length >= max) break;
      }
      return rows;
    }

    Future<Map<int, Decimal>> onHandOf(int warehouse) async => {
      for (final r in await stockRows(warehouse))
        r.product: Decimal.parse(r.onHand),
    };

    Future<Decimal> onHand(int product, int warehouse) async {
      final s = (await stock.getProductStockApiV1StockProductsProductGet(
        product: product,
      )).data!;
      final row = s.warehouses
          ?.where((w) => w.warehouse == warehouse)
          .firstOrNull;
      return row == null ? Decimal.zero : Decimal.parse(row.onHand);
    }

    /// Up to [want] active stockable products of [rows] with a countable
    /// (>= 0, <= 4 decimals) on hand.
    Future<List<_Product>> stockedProducts(
      List<api.StockRow> rows,
      int want,
    ) async {
      final out = <_Product>[];
      for (final r in rows) {
        final have = Decimal.parse(r.onHand);
        if (have < Decimal.zero || have.scale > 4) continue;
        final p = await products.get(productId: r.product);
        if (!p.stockable || p.status != EntityStatus.active) continue;
        if (p.code.trim().isEmpty || p.code.contains('\t')) continue;
        out.add((id: p.productId, code: p.code, name: p.name, onHand: have));
        if (out.length == want) break;
      }
      return out;
    }

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

    bool enabled(String key) =>
        tester.widget<ButtonStyleButton>(byKey(key)).onPressed != null;

    Finder editable(String key) =>
        find.descendant(of: byKey(key), matching: find.byType(EditableText));

    String fieldText(String key) =>
        tester.widget<EditableText>(editable(key).first).controller.text;

    Future<void> typeInto(String key, String text) async {
      await pumpUntil(editable(key));
      await tester.ensureVisible(editable(key).first);
      await tester.enterText(editable(key).first, text);
      await pumpFor(const Duration(milliseconds: 300));
    }

    String textOf(String key) => tester.widget<Text>(byKey(key)).data ?? '';

    Finder option(String label) =>
        find.descendant(of: find.byType(ListTile), matching: find.text(label));

    Future<void> pick(String key, String query, String label) async {
      await typeInto(key, query);
      await pumpUntil(option(label), timeout: const Duration(seconds: 30));
      await tester.tap(option(label).first);
      await pumpFor(const Duration(milliseconds: 500));
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

    Future<void> waitForList() async {
      await pumpUntilTrue(
        () =>
            (byKey('inventory_counts_table').evaluate().isNotEmpty ||
                find
                    .text(l10n.inventoryCountListEmpty)
                    .evaluate()
                    .isNotEmpty) &&
            !spinning(),
        'the counts list loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// The count ids whose folio cell the table shows, top to bottom.
    List<int> rowsShown() => [
      for (final e
          in find
              .descendant(
                of: byKey('inventory_counts_table'),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w.key is ValueKey<String> &&
                      (w.key! as ValueKey<String>).value.startsWith(
                        'inventory_count_folio_',
                      ),
                ),
              )
              .evaluate())
        int.parse(
          (e.widget.key! as ValueKey<String>).value.substring(
            'inventory_count_folio_'.length,
          ),
        ),
    ];

    Future<void> openDetail(int id) async {
      container().invalidate(inventoryCountDetailControllerProvider(id));
      await go(_list);
      await go('$_list/$id');
      await pumpUntilTrue(
        () => byKey('inventory_count_facts').evaluate().isNotEmpty,
        'count $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Finder inFacts(String text) => find.descendant(
      of: byKey('inventory_count_facts'),
      matching: find.text(text),
    );

    Finder keyPrefixed(String prefix) => find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith(prefix),
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
        await body().timeout(const Duration(minutes: 4));
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

    /// Confirms a count at [target] on [warehouse] through the API, so the
    /// stock ends where it started.
    Future<int?> restore(
      int warehouse,
      Map<int, Decimal> target,
      String tag,
    ) async {
      final c = await counts.create(warehouseId: warehouse, comment: tag);
      await counts.setLines(c.id, [
        for (final e in target.entries)
          CountLineInput.byProduct(productId: e.key, quantity: e.value),
      ]);
      return (await counts.confirm(c.id, includeUncounted: false)).count.serial;
    }

    // ------------------------------------------------------------------
    // Login (admin)
    // ------------------------------------------------------------------
    note('logging in as admin');
    await login(_adminUser, _adminPass);
    final opening = await counts.list(skip: 0, limit: 20);
    note('list: ${opening.total} counts; W1 = $w1 (${w1Row.name})');

    // ---- 1: nav entry, after Traspasos --------------------------------
    await step('1 "Conteos físicos" in Inventario after Traspasos, opens the '
        'list', () async {
      final entry = byKey('nav_dest_inventory-counts');
      await pumpUntil(entry);
      expect(
        find.descendant(
          of: entry,
          matching: find.text(l10n.navInventoryCounts),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(byKey('nav_dest_inventory-transfers')).dy,
        lessThan(tester.getTopLeft(entry).dy),
      );
      await tapFinder(entry);
      await pumpUntilTrue(() => location() == _list, 'the list route');
      await waitForList();
    });

    // ---- 2: list and filters ------------------------------------------
    await step('2a the list shows the newest counts first', () async {
      await go(_list);
      await waitForList();
      final want = opening.items.map((r) => r.id).toList();
      await pumpUntilTrue(
        () => rowsShown().toSet().containsAll(want),
        'the API\'s first page; have ${rowsShown()}',
      );
      final shown = rowsShown();
      expect(shown.where(want.contains).toList(), want, reason: 'order');
    });

    await step('2b Estado = Confirmado, Almacén = W1: badge 2, rows match; '
        'masculine chips', () async {
      await go(_list);
      await waitForList();
      await tapKey('inventory_counts_filter_button');
      await pumpUntil(byKey('inventory_counts_status_completed'));
      expect(
        find.descendant(
          of: byKey('inventory_counts_status_completed'),
          matching: find.text('Confirmado'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: byKey('inventory_counts_status_cancelled'),
          matching: find.text('Cancelado'),
        ),
        findsOneWidget,
      );
      await tapKey('inventory_counts_status_completed');
      await pumpUntilTrue(
        () => router().state.uri.queryParameters['status'] == 'completed',
        'status in the URL',
      );
      await pick('inventory_counts_warehouse_filter', w1Row.name, w1Row.name);
      await pumpUntilTrue(
        () => router().state.uri.queryParameters['warehouse'] == '$w1',
        'warehouse in the URL',
      );
      await tapKey('filter_sheet_apply_button');
      await waitForList();
      final badge = tester.widget<Badge>(
        find.ancestor(
          of: byKey('inventory_counts_filter_button'),
          matching: find.byType(Badge),
        ),
      );
      expect((badge.label! as Text).data, '2');
      final expected = await counts.list(
        status: InventoryDocumentStatus.completed,
        warehouseId: w1,
        skip: 0,
        limit: 20,
      );
      await pumpUntilTrue(
        () =>
            rowsShown().length == expected.items.length &&
            rowsShown().toSet().containsAll(expected.items.map((r) => r.id)),
        '${expected.items.length} filtered rows; have ${rowsShown()}',
      );
    });

    // ------------------------------------------------------------------
    // Writes
    // ------------------------------------------------------------------
    final tag = 'QA070 ${DateTime.now().millisecondsSinceEpoch % 100000}';
    final created = <int>[];

    // The walkthrough warehouse: W1 when it holds two countable products,
    // else the smallest listed warehouse that does.
    final listed = <Warehouse>[];
    for (var skip = 0; ; skip += 100) {
      final page = await warehouses.list(skip: skip, limit: 100);
      listed.addAll(page.items);
      if (page.items.length < 100) break;
    }
    final sized = <({Warehouse w, int total})>[];
    for (final w in listed) {
      final page = (await stock.listStockApiV1StockGet(
        warehouse: w.warehouseId,
        limit: 1,
      )).data!;
      if (page.total >= 2) sized.add((w: w, total: page.total));
    }
    sized.sort((a, b) => a.total.compareTo(b.total));

    Warehouse? ww;
    var pair = <_Product>[];
    pair = await stockedProducts(await stockRows(w1, max: 300), 2);
    if (pair.length == 2) {
      ww = listed.where((w) => w.warehouseId == w1).firstOrNull;
    }
    if (ww == null) {
      for (final c in sized) {
        pair = await stockedProducts(
          await stockRows(c.w.warehouseId, max: 300),
          2,
        );
        if (pair.length == 2) {
          ww = c.w;
          break;
        }
      }
    }
    final p3 = (await products.list(
      stockable: false,
      status: EntityStatus.active,
      limit: 1,
    )).items.firstOrNull;

    if (ww == null) {
      note('writes SKIPPED: no warehouse with two countable products');
    } else {
      final Warehouse w = ww;
      final p1 = pair[0];
      final p2 = pair[1];
      final o1 = await onHand(p1.id, w.warehouseId);
      final o2 = await onHand(p2.id, w.warehouseId);
      note(
        'walkthrough warehouse ${w.name} (#${w.warehouseId}); P1 #${p1.id} '
        '"${p1.code}" on hand $o1; P2 #${p2.id} "${p2.code}" on hand $o2; '
        'P3 ${p3?.code}',
      );
      var confirmed = false;
      var restored = false;

      try {
        int? draftId;
        await step('3 Nuevo conteo starts on W1; "QA070" draft opens with no '
            'lines', () async {
          await go(_list);
          await waitForList();
          await tapKey('inventory_counts_new_button');
          await pumpUntil(byKey('new_inventory_count_dialog'));
          await pumpUntilTrue(
            () => fieldText('new_inventory_count_warehouse') == w1Row.name,
            'the starting warehouse W1',
          );
          if (w.warehouseId != w1) {
            await pick('new_inventory_count_warehouse', w.name, w.name);
          }
          await typeInto('new_inventory_count_comment', tag);
          expect(enabled('new_inventory_count_submit'), isTrue);
          await tapKey('new_inventory_count_submit');
          await pumpUntilGone(byKey('new_inventory_count_dialog'));
          await pumpUntilTrue(
            () => RegExp(r'^/inventory/counts/\d+$').hasMatch(location()),
            'the new draft opened (at ${location()})',
          );
          draftId = int.parse(location().split('/').last);
          created.add(draftId!);
          await pumpUntil(find.text(l10n.inventoryCountTitleDraft('$draftId')));
          await pumpUntil(find.text(l10n.inventoryCountDraftEmpty));
          final r = await counts.get(draftId!);
          expect(r.status, InventoryDocumentStatus.draft);
          expect(r.warehouseId, w.warehouseId);
          expect(r.comment, tag);
          expect(r.lines, isEmpty);
        });

        Future<void> quickEntry(String code, String qty) async {
          await typeInto('count_quick_entry_code', code);
          await tester.testTextInput.receiveAction(TextInputAction.next);
          await pumpFor(const Duration(milliseconds: 300));
          await typeInto('count_quick_entry_quantity', qty);
          await tester.testTextInput.receiveAction(TextInputAction.done);
        }

        Future<String> waitFeedback(bool Function(String) ok) async {
          await pumpUntilTrue(
            () =>
                byKey('count_quick_entry_feedback').evaluate().isNotEmpty &&
                ok(textOf('count_quick_entry_feedback')),
            'quick-entry feedback',
          );
          await pumpFor(const Duration(milliseconds: 400));
          return textOf('count_quick_entry_feedback');
        }

        void expectBlind() {
          expect(find.text(l10n.inventoryCountLineColExpected), findsNothing);
          expect(find.text(l10n.inventoryCountLineColDifference), findsNothing);
          expect(keyPrefixed('inventory_count_line_expected_'), findsNothing);
          expect(keyPrefixed('inventory_count_line_difference_'), findsNothing);
        }

        await step('4 blind quick entry: P1 +3, P2 0, P1 +1 replaces; no '
            'expected quantity shown', () async {
          final id = draftId ?? (throw TestFailure('step 3 created nothing'));
          await openDetail(id);
          await quickEntry(p1.code, '${o1 + Decimal.fromInt(3)}');
          await waitFeedback((t) => t.startsWith(p1.code));
          expect(fieldText('count_quick_entry_code'), isEmpty);
          expect(fieldText('count_quick_entry_quantity'), isEmpty);
          expect(
            tester
                .widget<EditableText>(editable('count_quick_entry_code').first)
                .focusNode
                .hasFocus,
            isTrue,
          );
          await quickEntry(p2.code, '0');
          await waitFeedback((t) => t.startsWith(p2.code));
          await quickEntry(p1.code, '${o1 + Decimal.one}');
          final fb = await waitFeedback(
            (t) => t.startsWith(p1.code) && t.contains('(reemplazada)'),
          );
          expect(fb, contains('→'));
          final r = await counts.get(id);
          expect(r.lines.where((l) => l.productId == p1.id), hasLength(1));
          expect(
            r.lines.singleWhere((l) => l.productId == p1.id).quantity,
            o1 + Decimal.one,
          );
          expect(
            r.lines.singleWhere((l) => l.productId == p2.id).quantity,
            Decimal.zero,
          );
          for (final l in r.lines) {
            await pumpUntil(byKey('inventory_count_line_quantity_${l.id}'));
          }
          expectBlind();
          note('feedback: "$fb"');
        });

        await step('5 refusals: unknown code keeps the values; P3 is not '
            'stockable', () async {
          final id = draftId ?? (throw TestFailure('step 3 created nothing'));
          await openDetail(id);
          await quickEntry('NOEXISTE-070', '1');
          await pumpUntil(byKey('count_quick_entry_refusal'));
          expect(
            find.descendant(
              of: byKey('count_quick_entry_refusal'),
              matching: find.textContaining('El producto no existe.'),
            ),
            findsOneWidget,
          );
          expect(fieldText('count_quick_entry_code'), 'NOEXISTE-070');
          expect(fieldText('count_quick_entry_quantity'), '1');
          if (p3 == null) {
            note('5 P3 SKIPPED: no active non-stockable product');
          } else {
            await quickEntry(p3.code, '1');
            await pumpUntil(
              find.descendant(
                of: byKey('count_quick_entry_refusal'),
                matching: find.textContaining('no es inventariable'),
              ),
            );
          }
          expect((await counts.get(id)).lines, hasLength(2));
          await typeInto('count_quick_entry_code', '');
          await typeInto('count_quick_entry_quantity', '');
        });

        await step('6 paste: a header row is refused (row 1, Enviar off); '
            'P1 5 and P2 2,5 replace the lines', () async {
          final id = draftId ?? (throw TestFailure('step 3 created nothing'));
          await openDetail(id);
          await tapKey('inventory_count_paste');
          await pumpUntil(byKey('count_paste_dialog'));
          await typeInto(
            'count_paste_text',
            'Código\tCantidad\n${p1.code}\t5\n${p2.code}\t2,5',
          );
          await pumpUntil(byKey('count_paste_problem_1'));
          expect(
            textOf('count_paste_summary'),
            '3 filas leídas · 1 con problemas',
          );
          expect(enabled('count_paste_send'), isFalse);
          await typeInto('count_paste_text', '${p1.code}\t5\n${p2.code}\t2,5');
          await pumpUntilGone(byKey('count_paste_problems'));
          expect(enabled('count_paste_send'), isTrue);
          await tapKey('count_paste_send');
          await pumpUntilGone(byKey('count_paste_dialog'));
          final r = await counts.get(id);
          expect(r.lines, hasLength(2));
          expect(
            r.lines.singleWhere((l) => l.productId == p1.id).quantity,
            Decimal.fromInt(5),
          );
          expect(
            r.lines.singleWhere((l) => l.productId == p2.id).quantity,
            Decimal.parse('2.5'),
          );
          final l2 = r.lines.singleWhere((l) => l.productId == p2.id);
          await pumpUntilTrue(
            () =>
                byKey(
                  'inventory_count_line_quantity_${l2.id}',
                ).evaluate().isNotEmpty &&
                textOf('inventory_count_line_quantity_${l2.id}') == '2.5',
            'P2 shows 2.5',
          );
          expectBlind();
        });

        await step('7 paste refusal (3 rows, one unknown): whole batch '
            'refused, the code listed at its row, 0 applied', () async {
          final id = draftId ?? (throw TestFailure('step 3 created nothing'));
          await openDetail(id);
          final unknown = 'NOEXISTE-070-${tag.split(' ').last}';
          await tapKey('inventory_count_paste');
          await pumpUntil(byKey('count_paste_dialog'));
          await typeInto(
            'count_paste_text',
            '${p1.code}\t7\n${p2.code}\t7\n$unknown\t1',
          );
          await tapKey('count_paste_send');
          await pumpUntil(byKey('count_paste_stopped'));
          await pumpUntil(byKey('count_paste_rejected_3'));
          expect(textOf('count_paste_rejected_3'), contains(unknown));
          expect(textOf('count_paste_rejected_3'), contains('fila 3'));
          expect(
            textOf('count_paste_stopped_text'),
            'Se detuvo el envío. Se aplicaron 0 de 3 filas.',
          );
          expect(find.text(l10n.inventoryCountPasteSafeNote), findsOneWidget);
          await tapKey('count_paste_close');
          await pumpUntilGone(byKey('count_paste_dialog'));
          final r = await counts.get(id);
          expect(
            r.lines.singleWhere((l) => l.productId == p1.id).quantity,
            Decimal.fromInt(5),
          );
          expect(
            r.lines.singleWhere((l) => l.productId == p2.id).quantity,
            Decimal.parse('2.5'),
          );
        });

        await step('8 confirm (checkbox off): folio, Confirmado, Esperado/'
            'Diferencia, stock = counted, no Cancelar', () async {
          final id = draftId ?? (throw TestFailure('step 3 created nothing'));
          await openDetail(id);
          await tapKey('inventory_count_confirm');
          await pumpUntil(byKey('inventory_count_confirm_dialog'));
          expect(
            tester
                .widget<CheckboxListTile>(
                  byKey('inventory_count_confirm_include_uncounted'),
                )
                .value,
            isFalse,
          );
          await tapKey('inventory_count_confirm_submit');
          confirmed = true;
          await pumpUntilGone(byKey('inventory_count_confirm_dialog'));
          await pumpUntil(inFacts(l10n.inventoryCountStatusCompleted));
          final r = await counts.get(id);
          expect(r.status, InventoryDocumentStatus.completed);
          expect(r.serial, isNotNull);
          await pumpUntil(find.text(l10n.inventoryCountTitle('${r.serial}')));
          expect(textOf('inventory_count_serial'), '${r.serial}');
          expect(find.text(l10n.inventoryCountLineColExpected), findsWidgets);
          expect(find.text(l10n.inventoryCountLineColDifference), findsWidgets);
          for (final l in r.lines) {
            await pumpUntil(byKey('inventory_count_line_expected_${l.id}'));
            expect(
              byKey('inventory_count_line_difference_${l.id}'),
              findsOneWidget,
            );
          }
          for (final k in [
            'inventory_count_cancel',
            'inventory_count_confirm',
            'inventory_count_edit_header',
            'inventory_count_paste',
            'inventory_count_add_product',
            'count_quick_entry',
          ]) {
            expect(byKey(k), findsNothing, reason: k);
          }
          final a1 = await onHand(p1.id, w.warehouseId);
          final a2 = await onHand(p2.id, w.warehouseId);
          expect(a1, Decimal.fromInt(5));
          expect(a2, Decimal.parse('2.5'));
          note('#$id folio ${r.serial}: P1 $o1 -> $a1, P2 $o2 -> $a2');
        });
      } finally {
        if (confirmed) {
          await step('8z restore P1 and P2 on ${w.name}', () async {
            final serial = await restore(w.warehouseId, {
              p1.id: o1,
              p2.id: o2,
            }, '$tag restore');
            restored = true;
            final a1 = await onHand(p1.id, w.warehouseId);
            final a2 = await onHand(p2.id, w.warehouseId);
            expect(a1, o1);
            expect(a2, o2);
            note(
              'restored by folio $serial: P1 $a1 (was $o1), P2 $a2 '
              '(was $o2)',
            );
          });
          if (!restored) note('!!! P1/P2 NOT restored on ${w.name}');
        }
      }

      // ---- 11: include uncounted, on the smallest warehouse --------------
      ({Warehouse w, Map<int, Decimal> original, _Product p})? small;
      for (final c in sized) {
        if (c.total > _maxRows) break;
        final rows = await stockRows(c.w.warehouseId);
        if (rows.any((r) {
          final d = Decimal.parse(r.onHand);
          return d < Decimal.zero || d.scale > 4;
        })) {
          continue;
        }
        final ps = await stockedProducts(rows, 1);
        if (ps.isEmpty) continue;
        small = (
          w: c.w,
          original: {for (final r in rows) r.product: Decimal.parse(r.onHand)},
          p: ps.single,
        );
        break;
      }
      if (small == null) {
        note(
          '11 SKIPPED: no listed warehouse with 2-$_maxRows stock rows, '
          'none negative, and an active stockable product',
        );
      } else {
        final s = small;
        var uConfirmed = false;
        InventoryCount? uDone;
        try {
          await step(
            '11 include uncounted on ${s.w.name} '
            '(${s.original.length} rows): extra lines at Contado 0',
            () async {
              final u = await counts.create(
                warehouseId: s.w.warehouseId,
                comment: '$tag U',
              );
              created.add(u.id);
              await counts.setLines(u.id, [
                CountLineInput.byProduct(
                  productId: s.p.id,
                  quantity: s.original[s.p.id]!,
                ),
              ]);
              await openDetail(u.id);
              await tapKey('inventory_count_confirm');
              await pumpUntil(byKey('inventory_count_confirm_dialog'));
              await tapKey('inventory_count_confirm_include_uncounted');
              expect(
                tester
                    .widget<CheckboxListTile>(
                      byKey('inventory_count_confirm_include_uncounted'),
                    )
                    .value,
                isTrue,
              );
              await tapKey('inventory_count_confirm_submit');
              uConfirmed = true;
              await pumpUntilGone(byKey('inventory_count_confirm_dialog'));
              await pumpUntil(inFacts(l10n.inventoryCountStatusCompleted));
              final r = await counts.get(u.id);
              uDone = r;
              final added = r.lines
                  .where((l) => l.productId != s.p.id)
                  .toList();
              expect(added, isNotEmpty);
              expect(added.every((l) => l.quantity == Decimal.zero), isTrue);
              expect(
                added.map((l) => l.productId).toSet(),
                s.original.keys.where((k) => k != s.p.id).toSet(),
              );
              for (final l in added.take(5)) {
                await pumpUntil(byKey('inventory_count_line_quantity_${l.id}'));
                expect(textOf('inventory_count_line_quantity_${l.id}'), '0');
              }
              note('#${u.id} folio ${r.serial}: ${added.length} line(s) at 0');
            },
          );
        } finally {
          if (uConfirmed) {
            await step('11z restore every product of ${s.w.name}', () async {
              final done = uDone ?? await counts.get(created.last);
              final target = <int, Decimal>{
                for (final l in done.lines)
                  l.productId: s.original[l.productId] ?? l.quantityOnHand!,
              };
              final serial = await restore(
                s.w.warehouseId,
                target,
                '$tag U restore',
              );
              final after = await onHandOf(s.w.warehouseId);
              expect(after, s.original);
              note(
                'restored by folio $serial: ${s.w.name} before '
                '${s.original}, after $after',
              );
            });
          }
        }
      }

      // ---- 12: cancel a draft ------------------------------------------
      await step(
        '12a cancel a draft: Cancelado, title keeps "Borrador #id"',
        () async {
          final c = await counts.create(
            warehouseId: w.warehouseId,
            comment: '$tag C',
          );
          created.add(c.id);
          await openDetail(c.id);
          await tapKey('inventory_count_cancel');
          await pumpUntil(byKey('inventory_count_cancel_dialog'));
          await tapKey('inventory_count_cancel_submit');
          await pumpUntilGone(byKey('inventory_count_cancel_dialog'));
          await pumpUntil(inFacts(l10n.inventoryCountStatusCancelled));
          await pumpUntil(find.text(l10n.inventoryCountTitleDraft('${c.id}')));
          expect(
            (await counts.get(c.id)).status,
            InventoryDocumentStatus.cancelled,
          );
          for (final k in [
            'inventory_count_cancel',
            'inventory_count_confirm',
            'count_quick_entry',
          ]) {
            expect(byKey(k), findsNothing, reason: k);
          }
        },
      );
    }

    // ---- 12b: qareadonly sees a draft read-only --------------------------
    if (_roUser.isNotEmpty && _roPass.isNotEmpty && ww != null) {
      final ro = await counts.create(
        warehouseId: ww.warehouseId,
        comment: '$tag RO',
      );
      created.add(ro.id);
      await counts.setLines(ro.id, [
        CountLineInput.byProduct(productId: pair[0].id, quantity: Decimal.one),
      ]);
      await container().read(authProvider.notifier).signOut();
      await login(_roUser, _roPass);
      await go('$_list/${ro.id}');
      await pumpFor(const Duration(seconds: 2));
      if (location() != '$_list/${ro.id}') {
        note(
          '12b SKIPPED: qareadonly has no read on PhysicalCountAdjustment '
          '(redirected to ${location()})',
        );
      } else {
        await step('12b qareadonly: a draft opens with no quick entry, row '
            'icons or actions', () async {
          await pumpUntil(byKey('inventory_count_facts'));
          await pumpUntil(keyPrefixed('inventory_count_line_quantity_'));
          for (final k in [
            'count_quick_entry',
            'inventory_count_actions',
            'inventory_count_cancel',
            'inventory_count_confirm',
          ]) {
            expect(byKey(k), findsNothing, reason: k);
          }
          expect(keyPrefixed('inventory_count_line_edit_'), findsNothing);
          expect(keyPrefixed('inventory_count_line_remove_'), findsNothing);
        });
      }
    } else {
      note('12b SKIPPED: MBE_READONLY_* not given or no writes');
    }

    // ---- 1b: qanoaccess has no entry and no route --------------------------
    if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
      await container().read(authProvider.notifier).signOut();
      await login(_noAccessUser, _noAccessPass);
      await step('1b qanoaccess: no entry, the route redirects home', () async {
        expect(byKey('nav_dest_inventory-counts'), findsNothing);
        await go(_list);
        expect(location(), '/');
        expect(byKey('inventory_counts_table'), findsNothing);
      });
    } else {
      note('1b SKIPPED: MBE_TEST_USERNAME/_PASSWORD not given');
    }

    // ---- Hygiene: cancel every draft this run left -----------------------
    await step('z cancel the drafts this run left', () async {
      final left = <int>[];
      for (final id in created) {
        if ((await counts.get(id)).isDraft) {
          await counts.cancel(id);
          left.add(id);
        }
      }
      note(left.isEmpty ? 'no drafts left' : 'cancelled drafts $left');
    });

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
