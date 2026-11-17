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
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_detail_controller.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/069-inventory-transfers/quickstart.md steps 1-8, 10 and 11
/// against the REAL app (macOS desktop) and a live mbe-api (task T039).
///
///   caffeinate -dimsu flutter test \
///     integration_test/inventory_transfers_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env
///
/// Accounts: `MBE_POS_*` (the administrator; the only account with rights on
/// InventoryTransfers, 17), `MBE_TEST_*` (`qanoaccess`, for the gate in step
/// 1) and, for step 11, `MBE_READONLY_*` (`qareadonly`; when it has no read
/// on 17 the step is recorded as skipped, with the reason). Step 9 (a
/// non-administrator) stays manual: none is seeded.
///
/// Fixtures are discovered at run time: two listed warehouses W1 and W2 (one
/// facility), a W3 in another facility when there is one, an active
/// stockable product P1 with >= 11 available at W1 (and P2 with >= 3), and a
/// completed sales order with stockable lines (step 8 is skipped when none).
/// **Each facility used must have an in-transit warehouse**; otherwise
/// dispatch fails with `facility.no_in_transit_location`.
///
/// Writes data, every note tagged `QA069 device <n>`. Leaves on the tenant
/// only received, closed or cancelled transfers, never a draft.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');
const _readOnlyUser = String.fromEnvironment('MBE_READONLY_USERNAME');
const _readOnlyPass = String.fromEnvironment('MBE_READONLY_PASSWORD');

const _wide = Size(1400, 1000);
const _list = '/inventory/transfers';

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

Decimal _d(int n) => Decimal.fromInt(n);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Inventory transfers walkthrough (real app, live mbe-api)', (
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
    final transfers = InventoryTransferRepositoryImpl(dio);
    final issues = InventoryIssueRepositoryImpl(dio);
    final warehouses = WarehouseRepositoryImpl(dio);
    final products = ProductRepositoryImpl(dio);
    final orders = SalesOrderRepositoryImpl(dio);
    final stock = api.StockApi(dio, appSerializers);
    final me = await auth.me();
    final posWarehouseId = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: me.settings!.pointSaleId!)).warehouseId;
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    Future<Decimal> onHand(int product, int warehouse) async {
      final s = (await stock.getProductStockApiV1StockProductsProductGet(
        product: product,
      )).data!;
      final row = s.warehouses
          ?.where((w) => w.warehouse == warehouse)
          .firstOrNull;
      return row == null ? Decimal.zero : Decimal.parse(row.onHand);
    }

    final tag =
        'QA069 device ${DateTime.now().millisecondsSinceEpoch % 100000}';
    var noteCount = 0;
    String nextNote() => '$tag api ${++noteCount}';
    final created = <int>[];
    final results = <_Result>[];
    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    // ------------------------------------------------------------------
    // Fixtures
    // ------------------------------------------------------------------
    final listed = <Warehouse>[];
    for (var skip = 0; ; skip += 100) {
      final page = await warehouses.list(
        status: EntityStatus.active,
        skip: skip,
        limit: 100,
      );
      listed.addAll(page.items);
      if (page.items.length < 100) break;
    }
    // The POS warehouse first: the new-transfer dialog starts there.
    final candidates = [
      ...listed.where((w) => w.warehouseId == posWarehouseId),
      ...listed.where((w) => w.warehouseId != posWarehouseId),
    ];
    Warehouse? w1;
    Warehouse? w2;
    Warehouse? w3;
    ProductListItem? p1;
    ProductListItem? p2;
    for (final candidate in candidates) {
      final rows = <({int product, Decimal available})>[];
      for (var skip = 0; ; skip += 100) {
        final page = (await stock.listStockApiV1StockGet(
          warehouse: candidate.warehouseId,
          skip: skip,
          limit: 100,
        )).data!;
        for (final r in page.items) {
          final available = Decimal.parse(r.available);
          if (available >= _d(3)) {
            rows.add((product: r.product, available: available));
          }
        }
        if (page.items.length < 100 || rows.length >= 30) break;
      }
      final others = listed
          .where((x) => x.warehouseId != candidate.warehouseId)
          .toList();
      if (others.isEmpty) continue;
      ProductListItem? big;
      ProductListItem? small;
      for (final r in rows) {
        if (big != null && small != null) break;
        final full = await products.get(productId: r.product);
        if (!full.stockable || full.status != EntityStatus.active) continue;
        final item = (await products.list(
          status: EntityStatus.active,
          stockable: true,
          search: full.code,
          limit: 5,
        )).items.where((i) => i.productId == r.product).firstOrNull;
        if (item == null) continue;
        if (big == null && r.available >= _d(11)) {
          big = item;
        } else {
          small ??= item;
        }
      }
      if (big == null) continue;
      w1 = candidate;
      w2 =
          others.where((x) => x.facilityId == w1!.facilityId).firstOrNull ??
          others.first;
      w3 = listed
          .where(
            (x) =>
                x.facilityId != w1!.facilityId &&
                x.warehouseId != w2!.warehouseId,
          )
          .firstOrNull;
      p1 = big;
      p2 = small;
      break;
    }
    if (w1 == null || w2 == null || p1 == null) {
      fail(
        'no fixtures: needs a stocked product (>= 11 available) at a '
        'listed warehouse with another warehouse to send to',
      );
    }
    final Warehouse sourceW = w1;
    final Warehouse destW = w2;
    final ProductListItem prod1 = p1;
    final ProductListItem? prod2 = p2;
    final crossW = w3 ?? w2;
    note(
      'W1 ${sourceW.warehouseId} ${sourceW.name} (F${sourceW.facilityId}), '
      'W2 ${destW.warehouseId} ${destW.name} (F${destW.facilityId}), '
      'W3 ${w3?.warehouseId} ${w3?.name}, P1 ${prod1.code}, '
      'P2 ${prod2?.code}, pos warehouse $posWarehouseId',
    );
    final startsAtW1 = posWarehouseId == sourceW.warehouseId;

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

    /// Like [pumpUntil], listing the suggestion rows on a timeout.
    Future<void> pumpUntilRow(Finder f) async {
      try {
        await pumpUntil(f, timeout: const Duration(seconds: 25));
      } on TestFailure {
        final rows = [
          for (final e in find.byType(ListTile).evaluate())
            for (final t
                in find
                    .descendant(
                      of: find.byWidget(e.widget),
                      matching: find.byType(Text),
                    )
                    .evaluate())
              (t.widget as Text).data,
        ];
        throw TestFailure('rows shown: $rows; wanted $f');
      }
    }

    Future<void> pumpUntilGone(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f');

    Finder byKey(String k) => find.byKey(Key(k));
    bool spinning() =>
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

    Future<void> tapFinder(Finder f) async {
      // Present first, then scrolled into view (the nav rail scrolls), then
      // hit-testable.
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

    /// The text an editable field under [key] holds.
    String fieldText(String key) => tester
        .widget<EditableText>(
          find
              .descendant(of: byKey(key), matching: find.byType(EditableText))
              .first,
        )
        .controller
        .text;

    Future<void> typeInto(String key, String text) async {
      final field = find.descendant(
        of: byKey(key),
        matching: find.byType(EditableText),
      );
      await pumpUntil(field);
      await tester.enterText(field.first, text);
      await pumpFor(const Duration(milliseconds: 300));
    }

    /// The picker's suggestion rows labelled [label].
    Finder option(String label) =>
        find.descendant(of: find.byType(ListTile), matching: find.text(label));

    /// Types [query] into the picker under [key] and taps the suggestion
    /// [label].
    Future<void> pick(String key, String query, String label) async {
      // Search on what precedes any parenthesis: "ZUMPANGO 2 (Agregados)".
      await typeInto(key, query.split(' (').first);
      await pumpUntilRow(option(label));
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
            (byKey('inventory_transfers_table').evaluate().isNotEmpty ||
                find.text(l10n.inventoryTransferEmpty).evaluate().isNotEmpty ||
                find.text(l10n.clearFiltersButton).evaluate().isNotEmpty) &&
            !spinning(),
        'the transfers list loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// The transfer ids whose folio cell the table shows.
    Set<int> rowsShown() => {
      for (final e
          in find
              .descendant(
                of: byKey('inventory_transfers_table'),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w.key is ValueKey<String> &&
                      (w.key! as ValueKey<String>).value.startsWith(
                        'inventory_transfer_folio_',
                      ),
                ),
              )
              .evaluate())
        int.parse(
          (e.widget.key! as ValueKey<String>).value.substring(
            'inventory_transfer_folio_'.length,
          ),
        ),
    };

    /// Opens transfer [id]'s detail and waits for its facts. Hops via the
    /// list first: going from one detail address straight to another can keep
    /// the old page.
    Future<void> openDetail(int id) async {
      container().invalidate(inventoryTransferDetailControllerProvider(id));
      await go(_list);
      await go('$_list/$id');
      await pumpUntilTrue(
        () => byKey('inventory_transfer_facts').evaluate().isNotEmpty,
        'transfer $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Finder inChip(String text) => find.descendant(
      of: byKey('inventory_transfer_status_chip'),
      matching: find.text(text),
    );

    Future<void> waitForStatus(String label) => pumpUntil(inChip(label));

    String textOf(String key) => tester.widget<Text>(byKey(key)).data!;

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

    // Writes through the API, for set-up that is not the step's subject.
    Future<InventoryTransfer> newDraft(Warehouse from, Warehouse to) async {
      final t = await transfers.create(
        warehouseId: from.warehouseId,
        warehouseToId: to.warehouseId,
        comment: nextNote(),
      );
      created.add(t.id);
      return t;
    }

    bool noTransit(Object e) =>
        e is AppError &&
        e.problem?.codeName == 'facility.no_in_transit_location';

    // ------------------------------------------------------------------
    // Login (admin)
    // ------------------------------------------------------------------
    note('logging in as admin');
    await login(_adminUser, _adminPass);
    final opening = await transfers.list(skip: 0, limit: 20);
    note('list: ${opening.total} transfers; tag "$tag"');

    // ---- 1: nav entry, after Salidas ---------------------------------------
    await step(
      '1 "Traspasos" in Inventario, after Salidas, opens the list',
      () async {
        final entry = byKey('nav_dest_inventory-transfers');
        await pumpUntil(entry);
        expect(
          find.descendant(
            of: entry,
            matching: find.text(l10n.navInventoryTransfers),
          ),
          findsOneWidget,
        );
        final issuesY = tester
            .getTopLeft(byKey('nav_dest_inventory-issues'))
            .dy;
        expect(issuesY, lessThan(tester.getTopLeft(entry).dy));
        await tapFinder(entry);
        await pumpUntilTrue(() => location() == _list, 'the list route');
        await waitForList();
      },
    );

    // ---- 2: list and filters -------------------------------------------------
    await step('2a the list shows the newest transfers', () async {
      await go(_list);
      await waitForList();
      await pumpUntilTrue(
        () => rowsShown().containsAll(opening.items.map((r) => r.id)),
        'the API\'s first page; have ${rowsShown()}',
      );
    });

    // ------------------------------------------------------------------
    // Writes
    // ------------------------------------------------------------------
    final Decimal avail = await onHand(prod1.productId, sourceW.warehouseId);
    int? t3; // the step 3 transfer
    int? t4; // the step 4 transfer (refused dispatch, later cancelled)
    var w1Drift = Decimal.zero; // what step 6 left at W1 (and, without W3, W2)
    var w2Drift = Decimal.zero;
    late Decimal w1Before;
    late Decimal w2Before;

    Future<void> addLine(String code, String name, String qty) async {
      await tapKey('inventory_transfer_add_product');
      await pumpUntil(byKey('add_transfer_line_dialog'));
      await pick('add_transfer_line_product', code, name);
      await typeInto('add_transfer_line_quantity', qty);
      await tapKey('add_transfer_line_submit');
      await pumpUntilGone(byKey('add_transfer_line_dialog'));
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> dispatchInUi() async {
      await tapKey('inventory_transfer_dispatch');
      await pumpUntil(byKey('inventory_transfer_dispatch_dialog'));
      await tapKey('inventory_transfer_dispatch_submit');
      await pumpUntilGone(byKey('inventory_transfer_dispatch_dialog'));
    }

    // ---- 3: create and dispatch (US2) ---------------------------------------
    final stopwatch3 = Stopwatch();
    await step(
      '3 Nuevo traspaso W1 → W2, header, lines merged, dispatch',
      () async {
        await go(_list);
        await waitForList();
        stopwatch3.start();
        await tapKey('inventory_transfers_new_button');
        await pumpUntil(byKey('new_inventory_transfer_dialog'));
        if (startsAtW1) {
          await pumpUntilTrue(
            () => fieldText('new_inventory_transfer_warehouse') == sourceW.name,
            'the starting warehouse is the POS warehouse W1',
          );
        } else {
          await pick(
            'new_inventory_transfer_warehouse',
            sourceW.name,
            sourceW.name,
          );
        }
        await pick(
          'new_inventory_transfer_destination',
          destW.name,
          destW.name,
        );
        await typeInto('new_inventory_transfer_comment', tag);
        expect(enabled('new_inventory_transfer_submit'), isTrue);
        await tapKey('new_inventory_transfer_submit');
        await pumpUntilGone(byKey('new_inventory_transfer_dialog'));
        await pumpUntilTrue(
          () => RegExp(r'^/inventory/transfers/\d+$').hasMatch(location()),
          'the new draft opened (at ${location()})',
        );
        final id = int.parse(location().split('/').last);
        t3 = id;
        created.add(id);
        await pumpUntil(find.text(l10n.inventoryTransferTitleDraft('$id')));
        final r = await transfers.get(id);
        expect(r.status, InventoryTransferStatus.draft);
        expect(r.warehouseId, sourceW.warehouseId);
        expect(r.warehouseToId, destW.warehouseId);
        expect(r.comment, tag);

        // W1 → W1 in Editar encabezado: "deben ser distintos".
        await tapKey('inventory_transfer_edit_header');
        await pumpUntil(byKey('inventory_transfer_header_dialog'));
        await pick(
          'inventory_transfer_header_destination',
          sourceW.name,
          sourceW.name,
        );
        await tapKey('inventory_transfer_header_submit');
        await pumpUntil(find.textContaining('deben ser distintos'));
        expect((await transfers.get(id)).warehouseToId, destW.warehouseId);
        await recover();

        // P1 × 4 then × 2 = one line of 6; P2 × 3.
        await addLine(prod1.code, prod1.name, '4');
        await addLine(prod1.code, prod1.name, '2');
        var lines = (await transfers.get(id)).lines;
        expect(
          lines.where((l) => l.productId == prod1.productId),
          hasLength(1),
        );
        expect(
          lines.singleWhere((l) => l.productId == prod1.productId).quantity,
          _d(6),
        );
        if (prod2 != null) {
          await addLine(prod2.code, prod2.name, '3');
          lines = (await transfers.get(id)).lines;
          expect(lines, hasLength(2));
        }

        w1Before = await onHand(prod1.productId, sourceW.warehouseId);
        w2Before = await onHand(prod1.productId, destW.warehouseId);
        final p2Before = prod2 == null
            ? Decimal.zero
            : await onHand(prod2.productId, sourceW.warehouseId);
        await dispatchInUi();
        await waitForStatus(l10n.inventoryTransferStatusInTransit);
        stopwatch3.stop();
        final sent = await transfers.get(id);
        expect(sent.status, InventoryTransferStatus.inTransit);
        expect(sent.serial, isNotNull);
        await pumpUntil(
          find.text(l10n.inventoryTransferTitle('${sent.serial}')),
        );
        for (final line in sent.lines) {
          expect(
            byKey('inventory_transfer_line_sent_${line.id}'),
            findsOneWidget,
          );
          expect(
            byKey('inventory_transfer_line_received_${line.id}'),
            findsOneWidget,
          );
          expect(
            byKey('inventory_transfer_line_outstanding_${line.id}'),
            findsOneWidget,
          );
          expect(line.quantityReceived, Decimal.zero);
          expect(line.quantityOutstanding, line.quantity);
        }
        expect(
          await onHand(prod1.productId, sourceW.warehouseId),
          w1Before - _d(6),
        );
        expect(await onHand(prod1.productId, destW.warehouseId), w2Before);
        if (prod2 != null) {
          expect(
            await onHand(prod2.productId, sourceW.warehouseId),
            p2Before - _d(3),
          );
        }
        note(
          '#$id folio ${sent.serial}; W1 P1 $w1Before -> ${w1Before - _d(6)}; '
          'draft-to-dispatch took ${stopwatch3.elapsed.inSeconds}s '
          '(${prod2 == null ? 1 : 2} products)',
        );
      },
    );

    await step(
      '2b (once step 3 has an in-transit transfer to W2) Estado = En tránsito, then Almacén = W2: badge 2, rows '
      'match',
      () async {
        await go(_list);
        await waitForList();
        await tapKey('inventory_transfers_filter_button');
        await pumpUntil(byKey('inventory_transfers_status_inTransit'));
        await tapKey('inventory_transfers_status_inTransit');
        await pumpUntilTrue(
          () => router().state.uri.queryParameters['status'] == 'in_transit',
          'status in the URL',
        );
        await pick(
          'inventory_transfers_warehouse_filter',
          destW.name,
          destW.name,
        );
        await pumpUntilTrue(
          () =>
              router().state.uri.queryParameters['warehouse'] ==
              '${destW.warehouseId}',
          'warehouse in the URL',
        );
        await tapKey('filter_sheet_apply_button');
        await waitForList();
        final badge = tester.widget<Badge>(
          find.ancestor(
            of: byKey('inventory_transfers_filter_button'),
            matching: find.byType(Badge),
          ),
        );
        expect((badge.label! as Text).data, '2');
        final expected = await transfers.list(
          status: InventoryTransferStatus.inTransit,
          warehouseId: destW.warehouseId,
          skip: 0,
          limit: 20,
        );
        await pumpUntilTrue(
          () =>
              rowsShown().length == expected.items.length &&
              rowsShown().containsAll(expected.items.map((r) => r.id)),
          '${expected.items.length} filtered rows; have ${rowsShown()}',
        );
      },
    );

    // ---- 4: insufficient stock ---------------------------------------------
    await step(
      '4 dispatch with stock + 1 refused with "Producto: … · Almacén: …"; '
      'stays Borrador',
      () async {
        final t = await newDraft(sourceW, destW);
        t4 = t.id;
        final over = avail + Decimal.one;
        await transfers.addLine(
          t.id,
          productId: prod1.productId,
          quantity: over,
        );
        await openDetail(t.id);
        await dispatchInUi();
        await pumpUntil(byKey('inventory_transfer_refusal'));
        expect(
          find.descendant(
            of: byKey('inventory_transfer_refusal'),
            matching: find.textContaining('No hay existencias suficientes'),
          ),
          findsOneWidget,
        );
        expect(
          textOf('inventory_transfer_refusal_product'),
          l10n.inventoryTransferRefusalProductWarehouse(
            prod1.code,
            sourceW.name,
          ),
        );
        final r = await transfers.get(t.id);
        expect(r.status, InventoryTransferStatus.draft);
        expect(r.serial, isNull);
        await pumpUntil(find.text(l10n.inventoryTransferTitleDraft('${t.id}')));
      },
    );

    // ---- 5: receive (US3) ---------------------------------------------------
    Decimal? w2AfterP1;
    await step('5 receive: prefilled, 7 refused, 4+3 partial, then unchanged '
        '= Recibido', () async {
      final id = t3 ?? (throw TestFailure('step 3 created nothing'));
      final sent = await transfers.get(id);
      if (sent.status != InventoryTransferStatus.inTransit) {
        throw TestFailure('step 3 left #$id ${sent.status.name}');
      }
      final l1 = sent.lines.singleWhere((l) => l.productId == prod1.productId);
      final l2 = prod2 == null
          ? null
          : sent.lines.singleWhere((l) => l.productId == prod2.productId);
      await openDetail(id);
      final started = Stopwatch()..start();
      await tapKey('inventory_transfer_receive');
      await pumpUntil(byKey('inventory_transfer_receive_dialog'));
      expect(fieldText('inventory_transfer_receive_field_${l1.id}'), '6');
      if (l2 != null) {
        expect(fieldText('inventory_transfer_receive_field_${l2.id}'), '3');
      }
      await typeInto('inventory_transfer_receive_field_${l1.id}', '7');
      await pumpUntil(byKey('inventory_transfer_receive_error_${l1.id}'));
      expect(enabled('inventory_transfer_receive_submit'), isFalse);
      await typeInto('inventory_transfer_receive_field_${l1.id}', '4');
      expect(enabled('inventory_transfer_receive_submit'), isTrue);
      await tapKey('inventory_transfer_receive_submit');
      await pumpUntilGone(byKey('inventory_transfer_receive_dialog'));
      await pumpFor(const Duration(milliseconds: 600));
      var r = await transfers.get(id);
      expect(r.status, InventoryTransferStatus.inTransit);
      expect(
        r.lines.singleWhere((l) => l.id == l1.id).quantityOutstanding,
        _d(2),
      );
      expect(
        await onHand(prod1.productId, destW.warehouseId),
        w2Before + _d(4),
      );
      w2AfterP1 = w2Before + _d(4);
      await waitForStatus(l10n.inventoryTransferStatusInTransit);

      // Again, the dialog unchanged: what is left.
      final second = Stopwatch()..start();
      await tapKey('inventory_transfer_receive');
      await pumpUntil(byKey('inventory_transfer_receive_dialog'));
      expect(fieldText('inventory_transfer_receive_field_${l1.id}'), '2');
      await tapKey('inventory_transfer_receive_submit');
      await pumpUntilGone(byKey('inventory_transfer_receive_dialog'));
      await waitForStatus(l10n.inventoryTransferStatusReceived);
      second.stop();
      r = await transfers.get(id);
      expect(r.status, InventoryTransferStatus.received);
      expect(
        await onHand(prod1.productId, destW.warehouseId),
        w2Before + _d(6),
      );
      w2AfterP1 = w2Before + _d(6);
      expect(byKey('inventory_transfer_receive'), findsNothing);
      note(
        'receipt with two lowered lines + the rest took '
        '${started.elapsed.inSeconds}s in total; the unchanged receipt '
        'took ${second.elapsed.inSeconds}s',
      );
    });

    // ---- 6: close the remainder (US4) ---------------------------------------
    await step('6 close the remainder: W1 → W3 of 5, receive 3, Cerrar '
        'pendiente', () async {
      final t = await newDraft(sourceW, crossW);
      await transfers.addLine(
        t.id,
        productId: prod1.productId,
        quantity: _d(5),
      );
      final w1Pre = await onHand(prod1.productId, sourceW.warehouseId);
      final destPre = await onHand(prod1.productId, crossW.warehouseId);
      note('step 6: W1 on hand $w1Pre before dispatching 5');
      InventoryTransfer sent;
      try {
        sent = await transfers.dispatch(t.id);
      } on Object catch (e) {
        if (noTransit(e)) {
          await transfers.cancel(t.id);
          throw _Skip('facility has no in-transit warehouse');
        }
        rethrow;
      }
      final line = sent.lines.single;
      await openDetail(t.id);
      await tapKey('inventory_transfer_receive');
      await pumpUntil(byKey('inventory_transfer_receive_dialog'));
      await typeInto('inventory_transfer_receive_field_${line.id}', '3');
      await tapKey('inventory_transfer_receive_submit');
      await pumpUntilGone(byKey('inventory_transfer_receive_dialog'));
      await pumpFor(const Duration(milliseconds: 600));
      expect(
        (await transfers.get(t.id)).status,
        InventoryTransferStatus.inTransit,
      );
      await tapKey('inventory_transfer_close');
      await pumpUntil(byKey('inventory_transfer_close_dialog'));
      await tapKey('inventory_transfer_close_submit');
      await pumpUntilGone(byKey('inventory_transfer_close_dialog'));
      await waitForStatus(l10n.inventoryTransferStatusReceived);
      final r = await transfers.get(t.id);
      expect(r.status, InventoryTransferStatus.received);
      final rl = r.lines.single;
      expect(rl.quantity, _d(5));
      expect(rl.quantityReceived, _d(3));
      expect(rl.quantityOutstanding, Decimal.zero);
      expect(byKey('inventory_transfer_close'), findsNothing);
      // 5 went out, 2 came back: W1 is 3 down.
      expect(await onHand(prod1.productId, sourceW.warehouseId), w1Pre - _d(3));
      w1Drift = _d(3);
      if (crossW.warehouseId == destW.warehouseId) w2Drift = _d(3);
      expect(
        await onHand(prod1.productId, crossW.warehouseId),
        destPre + _d(3),
      );
      note(
        '#${t.id} W${sourceW.warehouseId} -> W${crossW.warehouseId}'
        '${w3 == null ? ' (same facility: no W3)' : ' (cross-facility)'}',
      );
    });

    // ---- 7: cancel (US6) -----------------------------------------------------
    Future<void> cancelInUi() async {
      await tapKey('inventory_transfer_cancel');
      await pumpUntil(byKey('inventory_transfer_cancel_dialog'));
      await tapKey('inventory_transfer_cancel_submit');
      await pumpUntilGone(byKey('inventory_transfer_cancel_dialog'));
    }

    await step(
      '7a cancel a draft: Cancelado, the title keeps "Borrador #"',
      () async {
        final id = t4 ?? (throw TestFailure('step 4 created nothing'));
        await openDetail(id);
        await cancelInUi();
        await waitForStatus(l10n.inventoryTransferStatusCancelled);
        expect(
          find.text(l10n.inventoryTransferTitleDraft('$id')),
          findsOneWidget,
        );
        expect(
          (await transfers.get(id)).status,
          InventoryTransferStatus.cancelled,
        );
        expect(byKey('inventory_transfer_cancel'), findsNothing);
        expect(byKey('inventory_transfer_edit_header'), findsNothing);
      },
    );

    await step('7b cancel a received transfer whose destination issued the '
        'goods: stock message naming W2', () async {
      final id = t3 ?? (throw TestFailure('step 3 created nothing'));
      if ((await transfers.get(id)).status !=
          InventoryTransferStatus.received) {
        throw TestFailure('step 5 did not leave #$id received');
      }
      // Issue everything P1 has at W2, so the stock cannot go back.
      final atW2 = await onHand(prod1.productId, destW.warehouseId);
      final issue = await issues.create(
        warehouseId: destW.warehouseId,
        comment: nextNote(),
      );
      await issues.addLine(
        issue.id,
        productId: prod1.productId,
        quantity: atW2,
      );
      await issues.confirm(issue.id);
      try {
        await openDetail(id);
        await cancelInUi();
        await pumpUntil(byKey('inventory_transfer_refusal'));
        expect(
          textOf('inventory_transfer_refusal_product'),
          l10n.inventoryTransferRefusalProductWarehouse(prod1.code, destW.name),
        );
        expect(
          (await transfers.get(id)).status,
          InventoryTransferStatus.received,
        );
      } finally {
        await issues.cancel(issue.id);
      }
    });

    await step('7c cancel the step 5 transfer: W1 and W2 back to their '
        'pre-dispatch stock', () async {
      final id = t3 ?? (throw TestFailure('step 3 created nothing'));
      final w1Now = await onHand(prod1.productId, sourceW.warehouseId);
      final w2Now = await onHand(prod1.productId, destW.warehouseId);
      expect(
        w2Now,
        w2AfterP1 == null ? w2Now : w2AfterP1! + w2Drift,
        reason: 'W2 after the issue was cancelled',
      );
      await openDetail(id);
      await cancelInUi();
      await waitForStatus(l10n.inventoryTransferStatusCancelled);
      expect(
        (await transfers.get(id)).status,
        InventoryTransferStatus.cancelled,
      );
      expect(await onHand(prod1.productId, sourceW.warehouseId), w1Now + _d(6));
      expect(await onHand(prod1.productId, destW.warehouseId), w2Now - _d(6));
      expect(w1Now + _d(6), w1Before - w1Drift);
      expect(w2Now - _d(6), w2Before + w2Drift);
    });

    // ---- 8: fill from a sales order (US8) -----------------------------------
    await step('8 Agregar desde pedido: missing products added, repeat adds '
        'nothing', () async {
      final page = await orders.listOrders(
        status: SaleStatus.completed,
        limit: 15,
      );
      if (page.items.isEmpty) throw _Skip('no completed sales order');
      // Find an order whose stockable products yield >= 1 line, through a
      // scratch draft the API cancels again.
      final scratch = await newDraft(sourceW, destW);
      var orderIdx = -1;
      late InventoryTransfer full;
      late InventoryTransfer best;
      for (var i = 0; i < page.items.length; i++) {
        try {
          full = await transfers.addSalesOrderItems(
            scratch.id,
            salesOrderId: page.items[i].id,
          );
        } on AppError {
          continue;
        }
        // Prefer an order with two products, so one is missing from the draft.
        if (full.lines.isNotEmpty && (orderIdx < 0 || full.lines.length > 1)) {
          orderIdx = i;
          best = full;
          if (full.lines.length > 1) break;
        }
      }
      await transfers.cancel(scratch.id);
      if (orderIdx < 0) throw _Skip('no order gave stockable lines');
      final order = page.items[orderIdx];
      final orderProducts = {
        for (final l in best.lines) l.productId: l.quantity,
      };
      // A draft that already holds one of the order's products.
      final keep = orderProducts.keys.first;
      final t = await newDraft(sourceW, destW);
      await transfers.addLine(t.id, productId: keep, quantity: Decimal.one);
      await openDetail(t.id);

      Future<void> fromOrder() async {
        await tapKey('inventory_transfer_add_from_order');
        await pumpUntil(byKey('inventory_transfer_from_order_dialog'));
        final folio = '${order.serial ?? '#${order.id}'}';
        final customer = posSaleCustomerLabel(order);
        await typeInto(
          'inventory_transfer_from_order_picker',
          customer == '—' ? folio : customer,
        );
        // No subtitle, so the suggestion is a plain text row.
        final row = find.byWidgetPredicate(
          (w) => w is Text && (w.data ?? '').startsWith('$folio ·'),
        );
        await pumpUntilRow(row);
        await tester.tap(row.first);
        await pumpFor(const Duration(milliseconds: 500));
        await tapKey('inventory_transfer_from_order_submit');
        await pumpUntilGone(byKey('inventory_transfer_from_order_dialog'));
      }

      await fromOrder();
      final missing = orderProducts.length - 1;
      await pumpUntil(
        find.text(
          missing == 0
              ? l10n.inventoryTransferFromOrderNone
              : l10n.inventoryTransferFromOrderAdded(missing),
        ),
      );
      var r = await transfers.get(t.id);
      expect(
        r.lines.map((l) => l.productId).toSet(),
        orderProducts.keys.toSet(),
      );
      expect(
        r.lines.singleWhere((l) => l.productId == keep).quantity,
        Decimal.one,
        reason: 'the existing line must be unchanged',
      );
      final snapshot = [for (final l in r.lines) (l.productId, l.quantity)];
      await pumpFor(const Duration(seconds: 5)); // let the snackbar go
      await fromOrder();
      await pumpUntil(find.text(l10n.inventoryTransferFromOrderNone));
      r = await transfers.get(t.id);
      expect([for (final l in r.lines) (l.productId, l.quantity)], snapshot);
      note(
        'order ${order.serial ?? order.id}: $missing product(s) added to '
        '#${t.id}, repeat added none',
      );
    });

    // ---- 10: in transit (US7) -----------------------------------------------
    await step('10 En tránsito: F1 lines and product totals; F2 via the '
        'picker; a row opens its transfer', () async {
      final t = await newDraft(sourceW, crossW);
      await transfers.addLine(
        t.id,
        productId: prod1.productId,
        quantity: _d(2),
      );
      InventoryTransfer sent;
      try {
        sent = await transfers.dispatch(t.id);
      } on Object catch (e) {
        if (noTransit(e)) {
          await transfers.cancel(t.id);
          throw _Skip('facility has no in-transit warehouse');
        }
        rethrow;
      }
      await transfers.receive(t.id, lines: {sent.lines.single.id: Decimal.one});
      final folio = '${sent.serial}';

      await go(_list);
      await waitForList();
      await tapKey('inventory_transfers_in_transit_button');
      await pumpUntilTrue(
        () => location() == '/inventory/transfers/in-transit',
        'the in-transit route',
      );
      // Administrator: the picker; choose F1 explicitly.
      final pickerField = find.descendant(
        of: find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith(
                'in_transit_facility_picker_',
              ),
        ),
        matching: find.byType(EditableText),
      );
      await pumpUntil(pickerField);
      await tester.enterText(pickerField.first, sourceW.facilityName);
      await pumpFor(const Duration(milliseconds: 300));
      final facilityRow = find.text(sourceW.facilityName);
      await pumpUntilTrue(
        () => facilityRow.evaluate().length >= 2,
        'the facility suggestion',
      );
      await tester.tap(facilityRow.last);
      await pumpFor(const Duration(milliseconds: 500));
      await pumpUntil(byKey('in_transit_lines_table'));
      await pumpUntil(byKey('in_transit_products_table'));
      final mineRow = find.descendant(
        of: byKey('in_transit_lines_table'),
        matching: find.text(folio),
      );
      await pumpUntil(mineRow);

      // Switch to the destination's facility; the same transfer shows there.
      final destFacility = crossW.facilityId;
      if (destFacility != sourceW.facilityId) {
        await typeInto(
          'in_transit_facility_picker_${sourceW.facilityId}',
          crossW.facilityName,
        );
        final crossRow = find.text(crossW.facilityName);
        await pumpUntilTrue(
          () => crossRow.evaluate().length >= 2,
          'the destination facility suggestion',
        );
        await tester.tap(crossRow.last);
        await pumpFor(const Duration(milliseconds: 500));
        await pumpUntil(byKey('in_transit_lines_table'));
        await pumpUntil(
          find.descendant(
            of: byKey('in_transit_lines_table'),
            matching: find.text(folio),
          ),
        );
      }
      final row = find.descendant(
        of: byKey('in_transit_lines_table'),
        matching: find.text(folio),
      );
      await tester.ensureVisible(row.first);
      await pumpFor(const Duration(milliseconds: 300));
      await tester.tap(row.first);
      await pumpUntilTrue(
        () => location() == '$_list/${t.id}',
        'the row opened its transfer (at ${location()})',
      );
      await pumpUntil(byKey('inventory_transfer_facts'));
      // Leave the tenant tidy: cancel it (stock restored).
      await cancelInUi();
      await waitForStatus(l10n.inventoryTransferStatusCancelled);
    });

    // ---- Leave nothing in draft ---------------------------------------------
    for (final id in created) {
      final status = (await transfers.get(id)).status;
      // A step that failed halfway can leave one in transit.
      if (status == InventoryTransferStatus.draft ||
          status == InventoryTransferStatus.inTransit) {
        await transfers.cancel(id);
      }
    }

    // ---- 1b: qanoaccess has no entry and no route ----------------------------
    if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
      await container().read(authProvider.notifier).signOut();
      await login(_noAccessUser, _noAccessPass);
      await step('1b qanoaccess: no entry, the route redirects home', () async {
        expect(byKey('nav_dest_inventory-transfers'), findsNothing);
        await go(_list);
        expect(location(), '/');
        expect(byKey('inventory_transfers_table'), findsNothing);
      });
    } else {
      note('1b SKIPPED: MBE_TEST_USERNAME/_PASSWORD not given');
    }

    // ---- 11: read-only --------------------------------------------------------
    if (_readOnlyUser.isNotEmpty && _readOnlyPass.isNotEmpty) {
      await container().read(authProvider.notifier).signOut();
      await login(_readOnlyUser, _readOnlyPass);
      await step(
        '11 read-only: no Nuevo traspaso, no detail actions',
        () async {
          await go(_list);
          if (location() != _list) {
            throw _Skip(
              '$_readOnlyUser has no read on InventoryTransfers (17): the '
              'route redirected to ${location()}; needs an account with read '
              'only on 17',
            );
          }
          await waitForList();
          expect(byKey('inventory_transfers_new_button'), findsNothing);
          const actions = [
            'inventory_transfer_cancel',
            'inventory_transfer_close',
            'inventory_transfer_edit_header',
            'inventory_transfer_add_from_order',
            'inventory_transfer_add_product',
            'inventory_transfer_dispatch',
            'inventory_transfer_receive',
          ];
          for (final status in InventoryTransferStatus.values) {
            final page = await transfers.list(
              status: status,
              skip: 0,
              limit: 1,
            );
            if (page.items.isEmpty) continue;
            await openDetail(page.items.first.id);
            for (final k in actions) {
              expect(byKey(k), findsNothing, reason: '$k on ${status.name}');
            }
          }
        },
      );
    } else {
      note('11 SKIPPED: MBE_READONLY_USERNAME/_PASSWORD not given');
    }

    note('==== RESULTS ==== (${clock.elapsed.inSeconds}s)');
    for (final id in created) {
      final r = await transfers.get(id);
      note('  #$id ${r.status.name} serial ${r.serial}');
    }
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
