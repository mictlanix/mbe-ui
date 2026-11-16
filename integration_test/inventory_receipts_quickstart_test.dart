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
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_detail_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/067-warehouse-receipts/quickstart.md steps 1–3, 5–7 and 9
/// against the REAL app (macOS desktop) and a live mbe-api (task T031).
///
///   caffeinate -dimsu flutter test \
///     integration_test/inventory_receipts_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env [--dart-define=MBE_WRITE=true]
///
/// `MBE_POS_*` is the administrator (W1 = its point-of-sale warehouse);
/// `MBE_TEST_*` is `qanoaccess`, for the gate in step 1.
///
/// **Read-only by default:** the nav entry and gate, the list, its status
/// and warehouse filters, and a purchase-order receipt's linked columns and
/// "ya se recibió completa" reason (step 8's last bullet, when one exists).
///
/// With `MBE_WRITE=true` it records a receipt through the UI: create (with
/// the 500-character limit), header warehouse W2 and back, clear the notes,
/// P1 × 3 + × 2 merged, P2 added, edited and removed, a non-stockable
/// product not offered, a 0 quantity refused, confirm with the stock check,
/// the empty-draft refusal, and cancelling a draft and the confirmed receipt
/// (stock restored). The insufficient-stock refusal reuses a confirmed
/// receipt the server can't cancel (the live test leaves one) or makes one.
///
/// **Each write run leaves on the tenant:** one cancelled receipt (stock
/// restored) and one cancelled empty draft; plus, only when no reusable one
/// exists, one confirmed 1-unit receipt of a negative-stock product.
/// The non-administrator steps (own-facility picker, `facility.other_facility`)
/// and `qareadonly` (who has no read on receipts) are not automated: no
/// seeded account has InventoryReceipts (15) rights short of administrator.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');

/// A pattern with active stockable products on the dev tenant.
const _productPattern = 'clavo';

const _wide = Size(1400, 1000);
const _list = '/inventory/receipts';

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

  testWidgets('Warehouse receipts walkthrough (real app, live mbe-api)', (
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
    final receipts = InventoryReceiptRepositoryImpl(dio);
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
            (byKey('inventory_receipts_table').evaluate().isNotEmpty ||
                find.text(l10n.inventoryReceiptEmpty).evaluate().isNotEmpty ||
                find
                    .text(l10n.inventoryReceiptFilteredEmpty)
                    .evaluate()
                    .isNotEmpty) &&
            !spinning(),
        'the receipts list loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// The receipt ids whose folio cell the table shows.
    Set<int> rowsShown() => {
      for (final e
          in find
              .descendant(
                of: byKey('inventory_receipts_table'),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w.key is ValueKey<String> &&
                      (w.key! as ValueKey<String>).value.startsWith(
                        'inventory_receipt_folio_',
                      ),
                ),
              )
              .evaluate())
        int.parse(
          (e.widget.key! as ValueKey<String>).value.substring(
            'inventory_receipt_folio_'.length,
          ),
        ),
    };

    /// Opens receipt [id]'s detail and waits for its facts.
    ///
    /// Hops via the list first: going from one detail address straight to
    /// another can keep the old page.
    Future<void> openDetail(int id) async {
      container().invalidate(inventoryReceiptDetailControllerProvider(id));
      await go(_list);
      await go('$_list/$id');
      await pumpUntilTrue(
        () => byKey('inventory_receipt_facts').evaluate().isNotEmpty,
        'receipt $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Finder inFacts(String text) => find.descendant(
      of: byKey('inventory_receipt_facts'),
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

    // ------------------------------------------------------------------
    // Login (admin)
    // ------------------------------------------------------------------
    note('logging in as admin${_write ? ' (WRITE mode)' : ' (read-only)'}');
    await login(_adminUser, _adminPass);
    final opening = await receipts.list(skip: 0, limit: 20);
    note('list: ${opening.total} receipts; W1 = $w1 (${w1Row.name})');

    // ---- 1: nav entry, between Logística and Facturación -------------------
    await step(
      '1 "Entradas de almacén" in Inventario, opens the list',
      () async {
        final entry = byKey('nav_dest_inventory-receipts');
        await pumpUntil(entry);
        expect(
          find.descendant(
            of: entry,
            matching: find.text(l10n.navInventoryReceipts),
          ),
          findsOneWidget,
        );
        double top(String key) => tester.getTopLeft(byKey(key)).dy;
        expect(
          top('nav_group_logistics'),
          lessThan(top('nav_group_inventory')),
        );
        expect(
          top('nav_group_inventory'),
          lessThan(top('nav_group_invoicing')),
        );
        await tapFinder(entry);
        await pumpUntilTrue(() => location() == _list, 'the list route');
        await waitForList();
      },
    );

    // ---- 2: list and filters ---------------------------------------------
    await step(
      '2a the list shows the newest receipts (administrator: all)',
      () async {
        await go(_list);
        await waitForList();
        await pumpUntilTrue(
          () => rowsShown().containsAll(opening.items.map((r) => r.id)),
          'the API\'s first page; have ${rowsShown()}',
        );
      },
    );

    await step('2b Estado = Confirmada, then Almacén = W1: badge 2, rows '
        'match', () async {
      await go(_list);
      await waitForList();
      await tapKey('inventory_receipts_filter_button');
      await pumpUntil(byKey('inventory_receipts_status_completed'));
      await tapKey('inventory_receipts_status_completed');
      await pumpUntilTrue(
        () => router().state.uri.queryParameters['status'] == 'completed',
        'status in the URL',
      );
      await pick('inventory_receipts_warehouse_filter', w1Row.name, w1Row.name);
      await pumpUntilTrue(
        () => router().state.uri.queryParameters['warehouse'] == '$w1',
        'warehouse in the URL',
      );
      await tapKey('filter_sheet_apply_button');
      await waitForList();
      final badge = tester.widget<Badge>(
        find.ancestor(
          of: byKey('inventory_receipts_filter_button'),
          matching: find.byType(Badge),
        ),
      );
      expect((badge.label! as Text).data, '2');
      final expected = await receipts.list(
        status: ReceiptStatus.completed,
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

    // ---- 8 (read-only part): a purchase-order receipt --------------------
    await step('8 a linked receipt shows Ordenado and the fully-received '
        'reason', () async {
      final page = await receipts.list(
        status: ReceiptStatus.completed,
        skip: 0,
        limit: 100,
      );
      final hit = page.items.where((r) => r.purchaseOrderId != null);
      if (hit.isEmpty) {
        note('step 8 SKIPPED: no purchase-order receipt among the newest 100');
        return;
      }
      final linked = await receipts.get(hit.first.id);
      await openDetail(linked.id);
      expect(byKey('inventory_receipt_purchase_order'), findsOneWidget);
      final line = linked.lines.firstWhere(
        (l) => l.purchaseOrderLineId != null,
      );
      expect(
        byKey('inventory_receipt_line_ordered_${line.id}'),
        findsOneWidget,
      );
      try {
        await receipts.complementary(linked.id);
        note('#${linked.id} has a complementary draft: reason not checked');
        return;
      } on AppError catch (e) {
        if (e.problem?.params['reason'] != 'purchase_order_fully_received') {
          note('#${linked.id} refused for ${e.problem?.params}: not checked');
          return;
        }
      }
      await tapKey('inventory_receipt_complementary');
      await pumpUntil(byKey('inventory_receipt_refusal'));
      expect(
        find.descendant(
          of: byKey('inventory_receipt_refusal'),
          matching: find.textContaining('ya se recibió completa'),
        ),
        findsOneWidget,
      );
      note('#${linked.id}: fully-received reason shown');
    });

    // ------------------------------------------------------------------
    // Writes (only with MBE_WRITE=true)
    // ------------------------------------------------------------------
    if (!_write) {
      note('MBE_WRITE is not set: skipping the steps that change data.');
    } else {
      final found = await products.list(
        search: _productPattern,
        status: EntityStatus.active,
        stockable: true,
        limit: 5,
      );
      final ProductListItem p1 = found.items[0];
      final ProductListItem p2 = found.items[1];
      final nonStockable = (await products.list(
        status: EntityStatus.active,
        stockable: false,
        limit: 1,
      )).items.firstOrNull;
      final Warehouse w2 = (await warehouses.list(
        status: EntityStatus.active,
        limit: 100,
      )).items.firstWhere((w) => w.facilityId != w1Row.facilityId);
      final tag = 'QA067 ${DateTime.now().millisecondsSinceEpoch % 100000}';
      note(
        'P1 ${p1.code}, P2 ${p2.code}, N1 ${nonStockable?.code}, '
        'W2 ${w2.name}',
      );

      int? draftId;
      await step('3 Nueva entrada starts at W1; 500+ chars refused; the '
          'draft opens as Borrador', () async {
        await go(_list);
        await waitForList();
        await tapKey('inventory_receipts_new_button');
        await pumpUntil(byKey('new_inventory_receipt_dialog'));
        await pumpUntilTrue(
          () => fieldText('new_inventory_receipt_warehouse') == w1Row.name,
          'the starting warehouse W1',
        );
        // The administrator's picker offers W2 too.
        await typeInto('new_inventory_receipt_warehouse', w2.name);
        await pumpUntil(option(w2.name), timeout: const Duration(seconds: 30));
        await typeInto('new_inventory_receipt_warehouse', w1Row.name);
        await pumpUntil(
          option(w1Row.name),
          timeout: const Duration(seconds: 30),
        );
        await tester.tap(option(w1Row.name).first);
        await pumpFor(const Duration(milliseconds: 400));
        await typeInto('new_inventory_receipt_comment', 'x' * 501);
        expect(enabled('new_inventory_receipt_submit'), isFalse);
        await typeInto('new_inventory_receipt_comment', tag);
        expect(enabled('new_inventory_receipt_submit'), isTrue);
        await tapKey('new_inventory_receipt_submit');
        await pumpUntilGone(byKey('new_inventory_receipt_dialog'));
        await pumpUntilTrue(
          () => RegExp(r'^/inventory/receipts/\d+$').hasMatch(location()),
          'the new draft opened (at ${location()})',
        );
        draftId = int.parse(location().split('/').last);
        await pumpUntil(find.text(l10n.inventoryReceiptTitleDraft('$draftId')));
        final r = await receipts.get(draftId!);
        expect(r.status, ReceiptStatus.draft);
        expect(r.warehouseId, w1);
        expect(r.comment, tag);
        await go(_list);
        await waitForList();
        expect(
          tester.widget<Text>(byKey('inventory_receipt_folio_$draftId')).data,
          l10n.inventoryReceiptDraftFolio('$draftId'),
        );
      });

      Future<void> saveHeader() async {
        expect(enabled('receipt_header_submit'), isTrue);
        await tapKey('receipt_header_submit');
        await pumpUntilGone(byKey('receipt_header_dialog'));
        await pumpFor(const Duration(milliseconds: 500));
      }

      await step('5 header: W2 changes the Sucursal; cleared notes show none; '
          'back to W1', () async {
        final id = draftId ?? (throw TestFailure('step 3 created nothing'));
        await openDetail(id);
        await tapKey('inventory_receipt_edit_header');
        await pumpUntil(byKey('receipt_header_dialog'));
        await pick('receipt_header_warehouse', w2.name, w2.name);
        await saveHeader();
        await pumpUntil(inFacts(w2.facilityName));
        expect((await receipts.get(id)).warehouseId, w2.warehouseId);

        await tapKey('inventory_receipt_edit_header');
        await pumpUntil(byKey('receipt_header_dialog'));
        await typeInto('receipt_header_comment', '');
        await saveHeader();
        await openDetail(id);
        expect(
          tester.widget<Text>(byKey('inventory_receipt_comment')).data,
          emptyValuePlaceholder,
        );
        expect((await receipts.get(id)).comment, isNull);

        await tapKey('inventory_receipt_edit_header');
        await pumpUntil(byKey('receipt_header_dialog'));
        await pick('receipt_header_warehouse', w1Row.name, w1Row.name);
        await saveHeader();
        await pumpUntil(inFacts(w1Row.facilityName));
        expect((await receipts.get(id)).warehouseId, w1);
      });

      Future<void> addLine(ProductListItem p, String qty) async {
        await tapKey('inventory_receipt_add_product');
        await pumpUntil(byKey('add_receipt_line_dialog'));
        await pick('add_receipt_line_product', p.code, p.name);
        await typeInto('add_receipt_line_quantity', qty);
        await tapKey('add_receipt_line_submit');
        await pumpUntilGone(byKey('add_receipt_line_dialog'));
        await pumpFor(const Duration(milliseconds: 500));
      }

      await step('6 lines: P1 3+2 merged, P2 edited and removed, N1 not '
          'offered, 0 refused', () async {
        final id = draftId ?? (throw TestFailure('step 3 created nothing'));
        await openDetail(id);
        await addLine(p1, '3');
        await addLine(p1, '2');
        var r = await receipts.get(id);
        final p1Line = r.lines.singleWhere((l) => l.productId == p1.productId);
        expect(p1Line.quantity, Decimal.fromInt(5));
        await pumpUntil(byKey('inventory_receipt_line_quantity_${p1Line.id}'));

        await addLine(p2, '1');
        r = await receipts.get(id);
        final p2Line = r.lines.singleWhere((l) => l.productId == p2.productId);
        await tapKey('inventory_receipt_line_edit_${p2Line.id}');
        await pumpUntil(byKey('inventory_receipt_line_quantity_dialog'));
        await typeInto('inventory_receipt_line_quantity_field', '4');
        await tapKey('inventory_receipt_line_quantity_submit');
        await pumpUntilGone(byKey('inventory_receipt_line_quantity_dialog'));
        r = await receipts.get(id);
        expect(
          r.lines.singleWhere((l) => l.id == p2Line.id).quantity,
          Decimal.fromInt(4),
        );
        await tapKey('inventory_receipt_line_remove_${p2Line.id}');
        await pumpUntil(byKey('inventory_receipt_line_remove_dialog'));
        await tapKey('inventory_receipt_line_remove_submit');
        await pumpUntilGone(byKey('inventory_receipt_line_remove_dialog'));
        await pumpUntilGone(byKey('inventory_receipt_line_edit_${p2Line.id}'));
        expect((await receipts.get(id)).lines.map((l) => l.productId), [
          p1.productId,
        ]);

        await tapKey('inventory_receipt_add_product');
        await pumpUntil(byKey('add_receipt_line_dialog'));
        if (nonStockable != null) {
          await typeInto('add_receipt_line_product', nonStockable.code);
          await pumpFor(const Duration(seconds: 3));
          expect(option(nonStockable.name), findsNothing);
        } else {
          note('no active non-stockable product: N1 not checked');
        }
        await pick('add_receipt_line_product', p1.code, p1.name);
        await typeInto('add_receipt_line_quantity', '0');
        expect(enabled('add_receipt_line_submit'), isFalse);
        await recover();
      });

      late Decimal stockBefore;
      await step('7 confirm: "Entrada {folio}", Confirmada, no edit actions, '
          'stock +5', () async {
        final id = draftId ?? (throw TestFailure('step 3 created nothing'));
        stockBefore = await onHand(p1.productId);
        await openDetail(id);
        await tapKey('inventory_receipt_confirm');
        await pumpUntil(byKey('inventory_receipt_confirm_dialog'));
        await tapKey('inventory_receipt_confirm_submit');
        await pumpUntilGone(byKey('inventory_receipt_confirm_dialog'));
        await waitForStatusLabel(l10n.inventoryReceiptStatusCompleted);
        final r = await receipts.get(id);
        expect(r.serial, isNotNull);
        await pumpUntil(find.text(l10n.inventoryReceiptTitle('${r.serial}')));
        expect(byKey('inventory_receipt_edit_header'), findsNothing);
        expect(byKey('inventory_receipt_add_product'), findsNothing);
        expect(byKey('inventory_receipt_confirm'), findsNothing);
        final after = await onHand(p1.productId);
        expect(after, stockBefore + Decimal.fromInt(5));
        note('#$id folio ${r.serial}: on hand $stockBefore → $after');
      });

      await step('7b confirming an empty draft is refused; 9a cancel the '
          'draft', () async {
        final empty = await receipts.create(warehouseId: w1, comment: tag);
        await openDetail(empty.id);
        await tapKey('inventory_receipt_confirm');
        await pumpUntil(byKey('inventory_receipt_confirm_dialog'));
        await tapKey('inventory_receipt_confirm_submit');
        await pumpUntilGone(byKey('inventory_receipt_confirm_dialog'));
        await pumpUntil(byKey('inventory_receipt_refusal'));
        expect(
          find.descendant(
            of: byKey('inventory_receipt_refusal'),
            matching: find.textContaining('no tiene partidas'),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('Receipt has no lines'), findsNothing);
        await tapKey('inventory_receipt_cancel');
        await pumpUntil(byKey('inventory_receipt_cancel_dialog'));
        await tapKey('inventory_receipt_cancel_submit');
        await pumpUntilGone(byKey('inventory_receipt_cancel_dialog'));
        await waitForStatusLabel(l10n.inventoryReceiptStatusCancelled);
        expect((await receipts.get(empty.id)).status, ReceiptStatus.cancelled);
      });

      await step('9b cancel the step-7 receipt: stock back', () async {
        final id = draftId ?? (throw TestFailure('step 3 created nothing'));
        await openDetail(id);
        await tapKey('inventory_receipt_cancel');
        await pumpUntil(byKey('inventory_receipt_cancel_dialog'));
        await tapKey('inventory_receipt_cancel_submit');
        await pumpUntilGone(byKey('inventory_receipt_cancel_dialog'));
        await waitForStatusLabel(l10n.inventoryReceiptStatusCancelled);
        expect(await onHand(p1.productId), stockBefore);
      });

      await step('9c insufficient stock: quantities and "Producto: {code}", '
          'stays Confirmada', () async {
        // A confirmed receipt in W1 whose cancel the server refuses: one the
        // live test left (QA067 notes), else a 1-unit one of a product whose
        // available stock is ≤ -1.
        Future<Decimal> available(int product) async {
          final s = (await stock.getProductStockApiV1StockProductsProductGet(
            product: product,
          )).data!;
          final row = s.warehouses?.where((w) => w.warehouse == w1).firstOrNull;
          return row == null ? Decimal.zero : Decimal.parse(row.available);
        }

        InventoryReceipt? stuck;
        final mine = await receipts.list(
          status: ReceiptStatus.completed,
          warehouseId: w1,
          skip: 0,
          limit: 50,
        );
        for (final s in mine.items) {
          final r = await receipts.get(s.id);
          if (!(r.comment ?? '').startsWith('QA067') || r.lines.length != 1) {
            continue;
          }
          final line = r.lines.single;
          if (await available(line.productId) < line.quantity) {
            stuck = r;
            break;
          }
        }
        if (stuck == null) {
          int? productId;
          final page = (await stock.listStockApiV1StockGet(
            warehouse: w1,
            limit: 100,
          )).data!;
          for (final row in page.items) {
            if (Decimal.parse(row.available) <= Decimal.fromInt(-1)) {
              productId = row.product;
              break;
            }
          }
          if (productId == null) {
            note('9c SKIPPED: no product with negative stock in W1');
            return;
          }
          final r = await receipts.create(warehouseId: w1, comment: tag);
          await receipts.addLine(
            r.id,
            productId: productId,
            quantity: Decimal.one,
          );
          stuck = await receipts.confirm(r.id);
          note('made #${stuck.id} (stays on the tenant)');
        } else {
          note('reusing #${stuck.id}');
        }
        await openDetail(stuck.id);
        await tapKey('inventory_receipt_cancel');
        await pumpUntil(byKey('inventory_receipt_cancel_dialog'));
        await tapKey('inventory_receipt_cancel_submit');
        await pumpUntilGone(byKey('inventory_receipt_cancel_dialog'));
        await pumpUntil(byKey('inventory_receipt_refusal'));
        expect(
          find.descendant(
            of: byKey('inventory_receipt_refusal'),
            matching: find.textContaining('No hay existencias suficientes'),
          ),
          findsOneWidget,
        );
        expect(
          tester.widget<Text>(byKey('inventory_receipt_refusal_product')).data,
          l10n.inventoryReceiptRefusalProduct(
            stuck.lines.single.productCode ?? '',
          ),
        );
        expect(find.textContaining('Not enough stock'), findsNothing);
        expect(inFacts(l10n.inventoryReceiptStatusCompleted), findsOneWidget);
        expect((await receipts.get(stuck.id)).status, ReceiptStatus.completed);
      });
    }

    // ---- 1b: qanoaccess has no entry and no route --------------------------
    if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
      await container().read(authProvider.notifier).signOut();
      await login(_noAccessUser, _noAccessPass);
      await step(
        '1b qanoaccess: no Inventario group, the route redirects',
        () async {
          expect(byKey('nav_dest_inventory-receipts'), findsNothing);
          expect(byKey('nav_group_inventory'), findsNothing);
          await go(_list);
          expect(location(), '/');
          expect(byKey('inventory_receipts_table'), findsNothing);
        },
      );
    } else {
      note('1b SKIPPED: MBE_TEST_USERNAME/_PASSWORD not given');
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
