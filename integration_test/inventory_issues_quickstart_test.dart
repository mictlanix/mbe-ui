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
import 'package:mbe_ui/core/formatting/app_formatters.dart';
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
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_detail_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/068-warehouse-issues/quickstart.md steps 1, 2 and 4-8
/// against the REAL app (macOS desktop) and a live mbe-api (task T029).
///
///   caffeinate -dimsu flutter test \
///     integration_test/inventory_issues_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env
///
/// Needs `MBE_POS_*` (the administrator; W1 = its point-of-sale warehouse)
/// and `MBE_TEST_*` (`qanoaccess`, for the gate in step 1). No seeded
/// non-administrator has InventoryIssues (16) rights, so the own-facility
/// picker, `facility.other_facility` and `qareadonly` stay manual.
///
/// Writes data: records a draft, edits its header, adds P1 x2 + x1 (merged),
/// refuses an over-stock confirm, confirms 3 units, then cancels it (stock
/// restored); also an empty draft (confirm refused) that it cancels.
/// Leaves on the tenant: two cancelled issues.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');

///
const _wide = Size(1400, 1000);
const _list = '/inventory/issues';

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

  testWidgets('Warehouse issues walkthrough (real app, live mbe-api)', (
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
    final issues = InventoryIssueRepositoryImpl(dio);
    final warehouses = WarehouseRepositoryImpl(dio);
    final products = ProductRepositoryImpl(dio);
    final stock = api.StockApi(dio, appSerializers);
    final me = await auth.me();
    final w1 = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: me.settings!.pointSaleId!)).warehouseId;
    final w1Row = await warehouses.get(warehouseId: w1);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    Future<Decimal> onHand(int product) async {
      final s = (await stock.getProductStockApiV1StockProductsProductGet(
        product: product,
      )).data!;
      final row = s.warehouses?.where((w) => w.warehouse == w1).firstOrNull;
      return row == null ? Decimal.zero : Decimal.parse(row.onHand);
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

    /// Types [query] into the [CatalogEntityPicker] under [key] and taps the
    /// suggestion [label].
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
            (byKey('inventory_issues_table').evaluate().isNotEmpty ||
                find.text(l10n.inventoryIssueEmpty).evaluate().isNotEmpty ||
                find
                    .text(l10n.inventoryIssueFilteredEmpty)
                    .evaluate()
                    .isNotEmpty) &&
            !spinning(),
        'the issues list loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// The issue ids whose folio cell the table shows.
    Set<int> rowsShown() => {
      for (final e
          in find
              .descendant(
                of: byKey('inventory_issues_table'),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w.key is ValueKey<String> &&
                      (w.key! as ValueKey<String>).value.startsWith(
                        'inventory_issue_folio_',
                      ),
                ),
              )
              .evaluate())
        int.parse(
          (e.widget.key! as ValueKey<String>).value.substring(
            'inventory_issue_folio_'.length,
          ),
        ),
    };

    /// Opens issue [id]'s detail and waits for its facts.
    ///
    /// Hops via the list first: going from one detail address straight to
    /// another can keep the old page.
    Future<void> openDetail(int id) async {
      container().invalidate(inventoryIssueDetailControllerProvider(id));
      await go(_list);
      await go('$_list/$id');
      await pumpUntilTrue(
        () => byKey('inventory_issue_facts').evaluate().isNotEmpty,
        'issue $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Finder inFacts(String text) => find.descendant(
      of: byKey('inventory_issue_facts'),
      matching: find.text(text),
    );

    Future<void> waitForStatusLabel(String label) => pumpUntil(inFacts(label));

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
        await body().timeout(const Duration(minutes: 2));
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

    // ------------------------------------------------------------------
    // Login (admin)
    // ------------------------------------------------------------------
    note('logging in as admin');
    await login(_adminUser, _adminPass);
    final opening = await issues.list(skip: 0, limit: 20);
    note('list: ${opening.total} issues; W1 = $w1 (${w1Row.name})');

    // ---- 1: nav entry, after Entradas de almacén ---------------------------
    await step(
      '1 "Salidas de almacén" in Inventario, opens the list',
      () async {
        final entry = byKey('nav_dest_inventory-issues');
        await pumpUntil(entry);
        expect(
          find.descendant(
            of: entry,
            matching: find.text(l10n.navInventoryIssues),
          ),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(byKey('nav_dest_inventory-receipts')).dy,
          lessThan(tester.getTopLeft(entry).dy),
        );
        await tapFinder(entry);
        await pumpUntilTrue(() => location() == _list, 'the list route');
        await waitForList();
      },
    );

    // ---- 2: list and filters ---------------------------------------------
    await step(
      '2a the list shows the newest issues (administrator: all)',
      () async {
        await go(_list);
        await waitForList();
        await pumpUntilTrue(
          () => rowsShown().containsAll(opening.items.map((r) => r.id)),
          'the API\'s first page; have ${rowsShown()}',
        );
        expect(find.text('Orden de compra'), findsNothing);
      },
    );

    await step('2b Estado = Confirmada, then Almacén = W1: badge 2, rows '
        'match', () async {
      await go(_list);
      await waitForList();
      await tapKey('inventory_issues_filter_button');
      await pumpUntil(byKey('inventory_issues_status_completed'));
      await tapKey('inventory_issues_status_completed');
      await pumpUntilTrue(
        () => router().state.uri.queryParameters['status'] == 'completed',
        'status in the URL',
      );
      await pick('inventory_issues_warehouse_filter', w1Row.name, w1Row.name);
      await pumpUntilTrue(
        () => router().state.uri.queryParameters['warehouse'] == '$w1',
        'warehouse in the URL',
      );
      await tapKey('filter_sheet_apply_button');
      await waitForList();
      final badge = tester.widget<Badge>(
        find.ancestor(
          of: byKey('inventory_issues_filter_button'),
          matching: find.byType(Badge),
        ),
      );
      expect((badge.label! as Text).data, '2');
      final expected = await issues.list(
        status: InventoryDocumentStatus.completed,
        warehouseId: w1,
        skip: 0,
        limit: 20,
      );
      await pumpUntilTrue(
        () =>
            rowsShown().length == expected.items.length &&
            rowsShown().containsAll(expected.items.map((r) => r.id)),
        '${expected.items.length} filtered rows; have ${rowsShown()}',
      );
    });

    // ------------------------------------------------------------------
    // Writes
    // ------------------------------------------------------------------
    // P1: a stockable product with at least 3 available in W1.
    final stockPage = (await stock.listStockApiV1StockGet(
      warehouse: w1,
      limit: 100,
    )).data!;
    ProductListItem? p1;
    Decimal? avail;
    for (final row in stockPage.items) {
      final a = Decimal.parse(row.available);
      if (a < Decimal.fromInt(3)) continue;
      final cand = (await products.list(
        status: EntityStatus.active,
        stockable: true,
        search: (await products.get(productId: row.product)).code,
        limit: 5,
      )).items.where((i) => i.productId == row.product).firstOrNull;
      if (cand == null) continue;
      p1 = cand;
      avail = a;
      break;
    }
    if (p1 == null || avail == null) {
      note('writes SKIPPED: no stockable product with >= 3 available in W1');
    } else {
      final ProductListItem prod = p1;
      final Warehouse w2 = (await warehouses.list(
        status: EntityStatus.active,
        limit: 100,
      )).items.firstWhere((w) => w.facilityId != w1Row.facilityId);
      final tag = 'QA068 ${DateTime.now().millisecondsSinceEpoch % 100000}';
      note('P1 ${prod.code} (available $avail in W1), W2 ${w2.name}');

      int? draftId;
      await step('3 Nueva salida: 500+ chars refused; the draft opens as '
          'Borrador', () async {
        await go(_list);
        await waitForList();
        await tapKey('inventory_issues_new_button');
        await pumpUntil(byKey('new_inventory_issue_dialog'));
        await pumpUntilTrue(
          () => fieldText('new_inventory_issue_warehouse') == w1Row.name,
          'the starting warehouse W1',
        );
        await typeInto('new_inventory_issue_comment', 'x' * 501);
        expect(enabled('new_inventory_issue_submit'), isFalse);
        await typeInto('new_inventory_issue_comment', tag);
        expect(enabled('new_inventory_issue_submit'), isTrue);
        await tapKey('new_inventory_issue_submit');
        await pumpUntilGone(byKey('new_inventory_issue_dialog'));
        await pumpUntilTrue(
          () => RegExp(r'^/inventory/issues/\d+$').hasMatch(location()),
          'the new draft opened (at ${location()})',
        );
        draftId = int.parse(location().split('/').last);
        await pumpUntil(find.text(l10n.inventoryIssueTitleDraft('$draftId')));
        final r = await issues.get(draftId!);
        expect(r.status, InventoryDocumentStatus.draft);
        expect(r.warehouseId, w1);
        expect(r.comment, tag);
        await go(_list);
        await waitForList();
        expect(
          tester.widget<Text>(byKey('inventory_issue_folio_$draftId')).data,
          l10n.inventoryDocumentDraftFolio('$draftId'),
        );
      });

      Future<void> saveHeader() async {
        expect(enabled('inventory_issue_header_submit'), isTrue);
        await tapKey('inventory_issue_header_submit');
        await pumpUntilGone(byKey('inventory_issue_header_dialog'));
        await pumpFor(const Duration(milliseconds: 500));
      }

      await step('4 header: W2 changes the Sucursal; cleared notes show none; '
          'back to W1; notes edited', () async {
        final id = draftId ?? (throw TestFailure('step 3 created nothing'));
        await openDetail(id);
        await tapKey('inventory_issue_edit_header');
        await pumpUntil(byKey('inventory_issue_header_dialog'));
        await pick('inventory_issue_header_warehouse', w2.name, w2.name);
        await saveHeader();
        await pumpUntil(inFacts(w2.facilityName));
        expect((await issues.get(id)).warehouseId, w2.warehouseId);

        await tapKey('inventory_issue_edit_header');
        await pumpUntil(byKey('inventory_issue_header_dialog'));
        await typeInto('inventory_issue_header_comment', '');
        await saveHeader();
        await openDetail(id);
        expect(
          tester.widget<Text>(byKey('inventory_issue_comment')).data,
          emptyValuePlaceholder,
        );
        expect((await issues.get(id)).comment, isNull);

        await tapKey('inventory_issue_edit_header');
        await pumpUntil(byKey('inventory_issue_header_dialog'));
        await pick('inventory_issue_header_warehouse', w1Row.name, w1Row.name);
        await typeInto('inventory_issue_header_comment', '$tag edited');
        await saveHeader();
        await pumpUntil(inFacts(w1Row.facilityName));
        final r = await issues.get(id);
        expect(r.warehouseId, w1);
        expect(r.comment, '$tag edited');
      });

      Future<void> addLine(String qty) async {
        await tapKey('inventory_issue_add_product');
        await pumpUntil(byKey('add_issue_line_dialog'));
        await pick('add_issue_line_product', prod.code, prod.name);
        await typeInto('add_issue_line_quantity', qty);
        await tapKey('add_issue_line_submit');
        await pumpUntilGone(byKey('add_issue_line_dialog'));
        await pumpFor(const Duration(milliseconds: 500));
      }

      Future<void> setQuantity(int lineId, String qty) async {
        await tapKey('inventory_issue_line_edit_$lineId');
        await pumpUntil(byKey('inventory_issue_line_quantity_dialog'));
        await typeInto('inventory_issue_line_quantity_field', qty);
        await tapKey('inventory_issue_line_quantity_submit');
        await pumpUntilGone(byKey('inventory_issue_line_quantity_dialog'));
        await pumpFor(const Duration(milliseconds: 500));
      }

      Future<void> confirm() async {
        await tapKey('inventory_issue_confirm');
        await pumpUntil(byKey('inventory_issue_confirm_dialog'));
        await tapKey('inventory_issue_confirm_submit');
        await pumpUntilGone(byKey('inventory_issue_confirm_dialog'));
      }

      Future<void> cancel() async {
        await tapKey('inventory_issue_cancel');
        await pumpUntil(byKey('inventory_issue_cancel_dialog'));
        await tapKey('inventory_issue_cancel_submit');
        await pumpUntilGone(byKey('inventory_issue_cancel_dialog'));
        await waitForStatusLabel(l10n.inventoryDocumentStatusCancelled);
      }

      int? lineId;
      await step(
        '5 lines: P1 x2 + x1 merged into one line of 3; 0 refused',
        () async {
          final id = draftId ?? (throw TestFailure('step 3 created nothing'));
          await openDetail(id);
          await addLine('2');
          await addLine('1');
          final r = await issues.get(id);
          final line = r.lines.singleWhere(
            (l) => l.productId == prod.productId,
          );
          expect(line.quantity, Decimal.fromInt(3));
          lineId = line.id;
          await pumpUntil(byKey('inventory_issue_line_quantity_${line.id}'));
          await tapKey('inventory_issue_add_product');
          await pumpUntil(byKey('add_issue_line_dialog'));
          await pick('add_issue_line_product', prod.code, prod.name);
          await typeInto('add_issue_line_quantity', '0');
          expect(enabled('add_issue_line_submit'), isFalse);
          await recover();
        },
      );

      await step('6 over-stock confirm refused with the quantities and '
          '"Producto: {code}"; stays Borrador', () async {
        final id = draftId ?? (throw TestFailure('step 3 created nothing'));
        final line = lineId ?? (throw TestFailure('step 5 made no line'));
        await openDetail(id);
        final over = avail! + Decimal.one;
        await setQuantity(line, '$over');
        expect((await issues.get(id)).lines.single.quantity, over);
        await confirm();
        await pumpUntil(byKey('inventory_issue_refusal'));
        expect(
          find.descendant(
            of: byKey('inventory_issue_refusal'),
            matching: find.textContaining('No hay existencias suficientes'),
          ),
          findsOneWidget,
        );
        expect(
          tester.widget<Text>(byKey('inventory_issue_refusal_product')).data,
          l10n.inventoryIssueRefusalProductWarehouse(prod.code, w1Row.name),
        );
        expect(find.textContaining('Not enough stock'), findsNothing);
        expect((await issues.get(id)).status, InventoryDocumentStatus.draft);
        await pumpUntil(find.text(l10n.inventoryIssueTitleDraft('$id')));
        await setQuantity(line, '3');
        expect(
          (await issues.get(id)).lines.single.quantity,
          Decimal.fromInt(3),
        );
      });

      late Decimal stockBefore;
      await step('7 confirm: "Salida {folio}", Confirmada, no edit actions, '
          'stock -3', () async {
        final id = draftId ?? (throw TestFailure('step 3 created nothing'));
        stockBefore = await onHand(prod.productId);
        await openDetail(id);
        await confirm();
        await waitForStatusLabel(l10n.inventoryDocumentStatusCompleted);
        final r = await issues.get(id);
        expect(r.serial, isNotNull);
        await pumpUntil(find.text(l10n.inventoryIssueTitle('${r.serial}')));
        expect(byKey('inventory_issue_edit_header'), findsNothing);
        expect(byKey('inventory_issue_add_product'), findsNothing);
        expect(byKey('inventory_issue_confirm'), findsNothing);
        final after = await onHand(prod.productId);
        expect(after, stockBefore - Decimal.fromInt(3));
        note('#$id folio ${r.serial}: on hand $stockBefore -> $after');
      });

      await step(
        '7b empty draft: confirm refused; 8a cancel the draft',
        () async {
          final empty = await issues.create(warehouseId: w1, comment: tag);
          await openDetail(empty.id);
          await confirm();
          await pumpUntil(byKey('inventory_issue_refusal'));
          expect(
            find.descendant(
              of: byKey('inventory_issue_refusal'),
              matching: find.textContaining('no tiene partidas'),
            ),
            findsOneWidget,
          );
          await cancel();
          expect(
            (await issues.get(empty.id)).status,
            InventoryDocumentStatus.cancelled,
          );
          expect(byKey('inventory_issue_cancel'), findsNothing);
          expect(byKey('inventory_issue_confirm'), findsNothing);
          expect(byKey('inventory_issue_edit_header'), findsNothing);
        },
      );

      await step('8b cancel the step-7 issue: stock back', () async {
        final id = draftId ?? (throw TestFailure('step 3 created nothing'));
        await openDetail(id);
        await cancel();
        expect(await onHand(prod.productId), stockBefore);
        expect(byKey('inventory_issue_cancel'), findsNothing);
      });
    }

    // ---- 1b: qanoaccess has no entry and no route --------------------------
    if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
      await container().read(authProvider.notifier).signOut();
      await login(_noAccessUser, _noAccessPass);
      await step(
        '1b qanoaccess: no warehouse issues entry, the route redirects',
        () async {
          expect(byKey('nav_dest_inventory-issues'), findsNothing);
          // The Inventario section can still show for a user who reads
          // products or labels (spec 077), so the destination above is the
          // claim, not the section header.
          await go(_list);
          expect(location(), '/');
          expect(byKey('inventory_issues_table'), findsNothing);
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
  }, timeout: const Timeout(Duration(minutes: 15)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
