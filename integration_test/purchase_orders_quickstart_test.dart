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
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/080-purchase-orders/quickstart.md steps 1–12 and 14
/// against the REAL app (macOS desktop) and a live mbe-api (task T037).
///
///   caffeinate -dims flutter test \
///     integration_test/purchase_orders_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env
///
/// `MBE_POS_*` is the administrator (rights 20, 86, 96 and 15; W1 = its
/// point-of-sale warehouse); `MBE_TEST_*` is `qanoaccess`, for step 1's gate.
///
/// **This test writes.** Fixtures are discovered at run time: an active,
/// purchasable, stockable "clavo" product with a supplier (P), another
/// product of that supplier whose cost is 0 (Z, found by adding candidates to
/// a scratch draft that is cancelled), a non-stockable purchasable product
/// (the service line) and a warehouse of another facility (W2). The approved
/// requests are made through spec 079's repository. Setup the steps don't
/// exercise is done through the repositories; what each step checks is done
/// through the UI. Everything carries a "QA080 …" tag.
///
/// What a run leaves behind: two confirmed orders (step 8's and step 14's:
/// a confirmed order can't be cancelled), one confirmed receipt (step 9:
/// 1 unit of P into W1), and cancelled drafts, receipts and requests.
/// Step 9's received quantity raises P's stock in W1 on dev.
///
/// Email is only sent while the server answers `email.not_configured` (a
/// probe with an order id that cannot exist tells); otherwise the send is
/// skipped, so nothing reaches a person.
///
/// Not automated: step 13 (no fixture user holds read on 20 without
/// writes), step 15 (largest text, manual), the timed checks (SC-001 in
/// step 3, SC-002 in step 10) and the emailed PDF arriving (mail is not
/// configured on dev).
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');

/// A pattern with active purchasable products on the dev tenant ('a' finds
/// nothing there).
const _productPattern = 'clavo';

const _wide = Size(1400, 1000);
const _orders = '/purchases/orders';
const _toPurchase = '/purchases/to-purchase';
const _requests = '/purchases/requests';
const _receipts = '/inventory/receipts';

enum _Outcome { pass, fail }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

bool _sameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Purchase orders walkthrough (real app, live mbe-api)', (
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
    final orders = PurchaseOrderRepositoryImpl(dio);
    final requests = PurchaseRequestRepositoryImpl(dio);
    final receipts = InventoryReceiptRepositoryImpl(dio);
    final warehouses = WarehouseRepositoryImpl(dio);
    final products = ProductRepositoryImpl(dio);
    final suppliers = SupplierRepositoryImpl(dio);
    final me = await auth.me();
    final w1 = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: me.settings!.pointSaleId!)).warehouseId;
    final w1Row = await warehouses.get(warehouseId: w1);
    final f1 = w1Row.facilityId;
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    final tag = 'QA080 ${DateTime.now().millisecondsSinceEpoch % 100000}';

    // Everything this run creates, for the summary and the cleanup.
    final createdOrders = <int>[];
    final createdRequests = <int>[];
    final createdReceipts = <int>[];
    final confirmedReceipts = <int>[];

    Future<PurchaseRequest> approvedRequest(List<int> productIds) async {
      var r = await requests.create(warehouseId: w1, comment: tag);
      createdRequests.add(r.id);
      for (final p in productIds) {
        r = await requests.addLine(r.id, productId: p);
      }
      await requests.submit(r.id);
      r = await requests.approve(r.id);
      for (final line in r.lines.where((l) => !l.toPurchase)) {
        r = await requests.markLine(r.id, line.id, toPurchase: true);
      }
      return r;
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
    Map<String, String> params() => router().state.uri.queryParameters;
    AppFormatters fmt() => container().read(formattersProvider);

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

    String textOf(String key) => tester.widget<Text>(byKey(key)).data ?? '';

    /// Every Text under [key], joined.
    String allTextUnder(String key) => find
        .descendant(of: byKey(key), matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .join(' ');

    Future<void> typeInto(String key, String text) async {
      final field = find.descendant(
        of: byKey(key),
        matching: find.byType(EditableText),
      );
      await pumpUntil(field);
      await tester.enterText(field.first, text);
      await pumpFor(const Duration(milliseconds: 300));
    }

    /// A suggestion row whose text satisfies [test]: a `ListTile` (pickers
    /// with a subtitle) or a row of Flutter's plain options view.
    Finder optionWhere(bool Function(String) test) => find.descendant(
      of: find.byWidgetPredicate(
        (w) =>
            w is ListTile ||
            w.runtimeType.toString().startsWith('_AutocompleteOptions<'),
      ),
      matching: find.byWidgetPredicate(
        (w) => w is Text && w.data != null && test(w.data!),
      ),
    );

    Future<void> pick(
      String key,
      String query,
      bool Function(String) label,
    ) async {
      await typeInto(key, query);
      final o = optionWhere(label);
      await pumpUntil(o, timeout: const Duration(seconds: 30));
      await tester.tap(o.first);
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

    Future<void> back() async {
      final tooltip = MaterialLocalizations.of(
        tester.element(find.byType(Scaffold).last),
      ).backButtonTooltip;
      await tapFinder(find.byTooltip(tooltip));
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> waitForTable(String tableKey, List<String> emptyTexts) async {
      await pumpUntilTrue(
        () =>
            (byKey(tableKey).evaluate().isNotEmpty ||
                emptyTexts.any((t) => find.text(t).evaluate().isNotEmpty)) &&
            !spinning(),
        '$tableKey loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Future<void> waitForList() => waitForTable('purchase_orders_table', [
      l10n.purchaseOrderEmptyMine,
      l10n.purchaseOrderEmptyAll,
    ]);

    Future<void> waitForToPurchase() =>
        waitForTable('to_purchase_groups', [l10n.toPurchaseEmpty]);

    Set<int> listRows() => find
        .descendant(
          of: byKey('purchase_orders_table'),
          matching: find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith(
                  'purchase_order_number_',
                ),
          ),
        )
        .evaluate()
        .map(
          (e) => int.parse(
            (e.widget.key! as ValueKey<String>).value.substring(
              'purchase_order_number_'.length,
            ),
          ),
        )
        .toSet();

    Future<void> expectRows(PurchaseOrderPage expected, String what) =>
        pumpUntilTrue(
          () =>
              listRows().length == expected.items.length &&
              listRows().containsAll(expected.items.map((s) => s.id)),
          '$what: ${expected.items.map((s) => s.id)}; have ${listRows()}',
        );

    /// The group card tags on screen (only the built ones: the list is
    /// lazy).
    Set<String> groupTags() => find
        .byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              RegExp(
                r'^to_purchase_group_(\d+|none)_\d+$',
              ).hasMatch((w.key! as ValueKey<String>).value),
        )
        .evaluate()
        .map(
          (e) => (e.widget.key! as ValueKey<String>).value.substring(
            'to_purchase_group_'.length,
          ),
        )
        .toSet();

    String tagOf(ToPurchaseGroup g) =>
        '${g.supplierId ?? 'none'}_${g.facilityId}';

    /// Scrolls Por comprar's lazy list from the top until [f] is built.
    Future<void> scrollGroupsTo(Finder f) async {
      final scrollable = find
          .descendant(
            of: byKey('to_purchase_groups'),
            matching: find.byType(Scrollable),
          )
          .first;
      tester.state<ScrollableState>(scrollable).position.jumpTo(0);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.scrollUntilVisible(
        f,
        150,
        scrollable: scrollable,
        maxScrolls: 200,
      );
      await pumpFor(const Duration(milliseconds: 300));
    }

    Future<void> scrollToGroup(String tag) =>
        scrollGroupsTo(byKey('to_purchase_group_$tag'));

    /// The pagination footer's text: the last child of the lazy list, so it
    /// is scrolled into view first.
    Future<String> summary() async {
      await scrollGroupsTo(byKey('to_purchase_pagination_summary'));
      return textOf('to_purchase_pagination_summary');
    }

    String paginationSummary(int pageIndex, int total) {
      final start = pageIndex * 20 + 1;
      final end = (start + 19) > total ? total : start + 19;
      final d = fmt().display;
      return l10n.toPurchasePaginationSummary(
        d.count(start),
        d.count(end),
        d.count(total),
      );
    }

    Future<void> openOrder(int id) async {
      container().invalidate(purchaseOrderDetailControllerProvider(id));
      await go(_orders);
      await go('$_orders/$id');
      await pumpUntilTrue(
        () => byKey('purchase_order_facts').evaluate().isNotEmpty,
        'order $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Finder inFacts(String text) => find.descendant(
      of: byKey('purchase_order_facts'),
      matching: find.text(text),
    );

    String statusLabel(InventoryDocumentStatus s) =>
        inventoryDocumentStatusLabel(l10n, s);

    String badge(String buttonKey) {
      final b = tester.widget<Badge>(
        find.ancestor(of: byKey(buttonKey), matching: find.byType(Badge)),
      );
      return b.isLabelVisible ? (b.label! as Text).data ?? '' : '';
    }

    Future<void> openDrawer() async {
      await tapKey('purchase_orders_filter_button');
      await pumpUntil(byKey('purchase_orders_scope_filter'));
    }

    Future<void> applyDrawer() async {
      await tapKey('filter_sheet_apply_button');
      await waitForList();
    }

    /// Picks [day] in an open date picker and accepts it.
    Future<void> pickDate(DateTime day) async {
      final dialog = find.byType(DatePickerDialog);
      await pumpUntil(dialog);
      final m = MaterialLocalizations.of(tester.element(dialog));
      final shown = tester.widget<DatePickerDialog>(dialog).initialDate!;
      if (day.month != shown.month || day.year != shown.year) {
        await tapFinder(find.byTooltip(m.nextMonthTooltip));
        await pumpFor(const Duration(milliseconds: 600));
      }
      await tapFinder(
        find.descendant(of: dialog, matching: find.text('${day.day}')),
      );
      await tapFinder(
        find.descendant(of: dialog, matching: find.text(m.okButtonLabel)),
      );
      await pumpUntilGone(dialog);
    }

    /// The snack bar texts on screen.
    String snacks() => find
        .descendant(of: find.byType(SnackBar), matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .join(' | ');

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
    // Fixtures
    // ------------------------------------------------------------------
    Product? product;
    for (final p in (await products.list(
      search: _productPattern,
      status: EntityStatus.active,
      purchasable: true,
      stockable: true,
      limit: 30,
    )).items) {
      final full = await products.get(productId: p.productId);
      if (full.supplierId != null && full.stockable) {
        product = full;
        break;
      }
    }
    if (product == null) {
      throw TestFailure(
        'no active purchasable stockable "$_productPattern" product with a '
        'supplier',
      );
    }
    final p = product;
    final supplierId = p.supplierId!;
    final supplier = await suppliers.get(supplierId: supplierId);

    // Z: a product of the same supplier with cost 0, found by adding
    // candidates to a scratch draft (the server prices a new line at cost).
    Product? zero;
    {
      final scratch = await orders.create(supplierId: supplierId, comment: tag);
      createdOrders.add(scratch.id);
      var skip = 0;
      search:
      while (true) {
        final page = await products.list(
          supplier: supplierId,
          status: EntityStatus.active,
          purchasable: true,
          stockable: true,
          skip: skip,
          limit: 50,
        );
        for (final c in page.items) {
          if (c.productId == p.productId) continue;
          final o = await orders.addLine(
            scratch.id,
            productId: c.productId,
            quantity: Decimal.one,
          );
          final line = o.lines.singleWhere((l) => l.productId == c.productId);
          await orders.removeLine(scratch.id, line.id);
          if (line.price == Decimal.zero) {
            zero = await products.get(productId: c.productId);
            break search;
          }
        }
        skip += page.items.length;
        if (page.items.isEmpty || skip >= page.total) break;
      }
      await orders.cancel(scratch.id);
    }
    if (zero == null) {
      throw TestFailure('no product of supplier $supplierId with cost 0');
    }
    final z = zero;

    final service = (await products.list(
      status: EntityStatus.active,
      purchasable: true,
      stockable: false,
      limit: 5,
    )).items.first;

    final Warehouse w2 = (await warehouses.list(
      status: EntityStatus.active,
      limit: 100,
    )).items.firstWhere((w) => w.facilityId != f1);

    note(
      'tag "$tag"; W1 $w1 (${w1Row.name}, F$f1 ${w1Row.facilityName}); '
      'P ${p.code} #${p.productId}; supplier $supplierId ${supplier.code} '
      '${supplier.name}; Z ${z.code} #${z.productId}; service '
      '${service.code} #${service.productId}; W2 ${w2.warehouseId} '
      '(${w2.name}, F${w2.facilityId})',
    );

    try {
      note('logging in as admin');
      await login(_adminUser, _adminPass);

      // ---- 1: navigation --------------------------------------------------
      await step('1 Compras holds the four entries; Por comprar and Órdenes '
          'de compra open', () async {
        await pumpUntil(byKey('nav_group_purchases'));
        final ids = [
          'purchase-requests',
          'purchase-request-approval',
          'to-purchase',
          'purchase-orders',
        ];
        for (final id in ids) {
          await pumpUntil(byKey('nav_dest_$id'));
        }
        expect(
          find.descendant(
            of: byKey('nav_dest_to-purchase'),
            matching: find.text(l10n.navToPurchase),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: byKey('nav_dest_purchase-orders'),
            matching: find.text(l10n.navPurchaseOrders),
          ),
          findsOneWidget,
        );
        double top(String id) => tester.getTopLeft(byKey('nav_dest_$id')).dy;
        for (var i = 1; i < ids.length; i++) {
          expect(top(ids[i - 1]), lessThan(top(ids[i])), reason: ids[i]);
        }
        await tapKey('nav_dest_to-purchase');
        await pumpUntilTrue(() => location() == _toPurchase, 'Por comprar');
        await waitForToPurchase();
        await tapKey('nav_dest_purchase-orders');
        await pumpUntilTrue(() => location() == _orders, 'the orders list');
        await waitForList();
      });

      // ---- 2: Por comprar ---------------------------------------------------
      PurchaseRequest? r1;
      final groupTag = '${supplierId}_$f1';
      Decimal? pCost;
      await step('2 Por comprar: group with count and estimate, "sin costo", '
          'Sin proveedor has no radio, paging, Sucursal filter', () async {
        r1 = await approvedRequest([p.productId, z.productId]);
        final pLine = r1!.lines.singleWhere((l) => l.productId == p.productId);
        final zLine = r1!.lines.singleWhere((l) => l.productId == z.productId);
        note('request #${r1!.id} folio ${r1!.serial}');

        final all = await orders.toPurchase();
        final mine = all.singleWhere(
          (g) => g.supplierId == supplierId && g.facilityId == f1,
        );
        pCost = mine.lines.singleWhere((l) => l.requestLineId == pLine.id).cost;
        expect(
          mine.lines.singleWhere((l) => l.requestLineId == zLine.id).cost,
          Decimal.zero,
        );

        // Paging over every group.
        await go(_toPurchase);
        await waitForToPurchase();
        if (all.length > 20) {
          expect(await summary(), paginationSummary(0, all.length));
          expect(
            tester.widget<IconButton>(byKey('to_purchase_next_page')).onPressed,
            isNotNull,
          );
          await tapKey('to_purchase_next_page');
          await pumpUntilTrue(() => params()['page'] == '2', 'page 2 in URL');
          await waitForToPurchase();
          expect(await summary(), paginationSummary(1, all.length));
        } else {
          note('2: only ${all.length} group(s): paging not checked');
        }

        // A "Sin proveedor" group: no radio, its tap doesn't select.
        final noneIndex = all.indexWhere((g) => g.supplierId == null);
        if (noneIndex < 0) {
          note('2: no "Sin proveedor" group on dev: not checked');
        } else {
          final none = all[noneIndex];
          final page = noneIndex ~/ 20;
          await go(page == 0 ? _toPurchase : '$_toPurchase?page=${page + 1}');
          await waitForToPurchase();
          await scrollToGroup(tagOf(none));
          expect(byKey('to_purchase_group_radio_${tagOf(none)}'), findsNothing);
          expect(
            find.descendant(
              of: byKey('to_purchase_group_${tagOf(none)}'),
              matching: find.text(l10n.toPurchaseNoSupplier),
            ),
            findsOneWidget,
          );
          await tapKey('to_purchase_group_header_${tagOf(none)}');
          expect(enabled('to_purchase_create_order'), isFalse);
        }

        // Sucursal = W1's facility, through the drawer.
        await go(_toPurchase);
        await waitForToPurchase();
        await tapKey('to_purchase_filter_button');
        await pumpUntil(byKey('to_purchase_filter_facility'));
        await pick(
          'to_purchase_filter_facility',
          w1Row.facilityName,
          (t) => t == w1Row.facilityName,
        );
        await pumpUntilTrue(
          () => params()['facility'] == '$f1',
          'facility in the URL',
        );
        await tapKey('filter_sheet_apply_button');
        await waitForToPurchase();
        final filtered = await orders.toPurchase(facilityId: f1);
        expect(filtered.every((g) => g.facilityId == f1), isTrue);
        expect(badge('to_purchase_filter_button'), '1');
        await pumpUntilTrue(
          () => groupTags().isNotEmpty,
          'groups of F$f1 on screen',
        );
        final expectedTags = filtered.take(20).map(tagOf).toSet();
        expect(
          expectedTags.containsAll(groupTags()),
          isTrue,
          reason: 'on screen ${groupTags()}, F$f1 has $expectedTags',
        );

        // Our group: line count, estimate, "sin costo".
        final group = filtered.singleWhere((g) => tagOf(g) == groupTag);
        await scrollToGroup(groupTag);
        expect(
          find.descendant(
            of: byKey('to_purchase_group_$groupTag'),
            matching: find.text(l10n.toPurchaseLineCount(group.lineCount)),
          ),
          findsOneWidget,
        );
        expect(
          textOf('to_purchase_group_total_$groupTag'),
          l10n.toPurchaseEstimate(
            fmt().display.currency(group.estimatedTotal.toString()),
          ),
        );
        if (byKey('to_purchase_group_lines_$groupTag').evaluate().isEmpty) {
          await tapKey('to_purchase_group_toggle_$groupTag');
        }
        await pumpUntil(byKey('to_purchase_line_cost_${zLine.id}'));
        expect(
          textOf('to_purchase_line_cost_${zLine.id}'),
          l10n.toPurchaseNoCost,
        );
        expect(
          textOf('to_purchase_line_cost_${pLine.id}'),
          fmt().display.currency(pCost.toString()),
        );
      });

      // ---- 3: create from a group -------------------------------------------
      int? orderB;
      await step('3 Crear orden: disabled until selected; draft at cost, '
          'costless at 0 with the warning; the group leaves', () async {
        final r = r1 ?? (throw TestFailure('step 2 made no request'));
        await go('$_toPurchase?facility=$f1');
        await waitForToPurchase();
        final before = await orders.toPurchase(facilityId: f1);
        if (before.length > 1) {
          expect(enabled('to_purchase_create_order'), isFalse);
        }
        await scrollToGroup(groupTag);
        await tapKey('to_purchase_group_radio_$groupTag');
        await pumpUntilTrue(
          () => enabled('to_purchase_create_order'),
          'Crear orden enabled',
        );
        await tapKey('to_purchase_create_order');
        await pumpUntilTrue(
          () => RegExp(r'^/purchases/orders/\d+$').hasMatch(location()),
          'the new draft opened (at ${location()})',
        );
        final id = int.parse(location().split('/').last);
        orderB = id;
        createdOrders.add(id);
        await pumpUntil(byKey('purchase_order_facts'));
        final o = await orders.get(id);
        expect(
          snacks(),
          contains(l10n.toPurchaseCreatedSnack('$id', o.lines.length)),
        );
        expect(o.status, InventoryDocumentStatus.draft);
        expect(o.supplierId, supplierId);
        final pl = o.lines.singleWhere(
          (l) =>
              l.requestLineId ==
              r.lines.firstWhere((x) => x.productId == p.productId).id,
        );
        final zl = o.lines.singleWhere(
          (l) =>
              l.requestLineId ==
              r.lines.firstWhere((x) => x.productId == z.productId).id,
        );
        expect(pl.price, pCost);
        expect(zl.price, Decimal.zero);
        await pumpUntil(byKey('order_warnings_band'));
        expect(allTextUnder('order_warnings_band'), contains(z.code));
        note('order B #$id: ${o.lines.length} line(s)');

        await back();
        await pumpUntilTrue(
          () => location() == _toPurchase,
          'back to Por comprar',
        );
        await waitForToPurchase();
        final after = await orders.toPurchase(facilityId: f1);
        expect(after.any((g) => tagOf(g) == groupTag), isFalse);
        if (after.isNotEmpty) {
          expect(await summary(), paginationSummary(0, after.length));
        }
        expect(groupTags().contains(groupTag), isFalse);
      });

      // ---- 4: create by hand -----------------------------------------------
      int? orderA;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date1 = today.add(const Duration(days: 2));
      await step(
        '4 Nueva orden: supplier, date, notes; no past dates',
        () async {
          await go(_orders);
          await waitForList();
          await tapKey('purchase_orders_new_button');
          await pumpUntil(byKey('new_purchase_order_dialog'));
          final label = '${supplier.code} — ${supplier.name}';
          await pick(
            'new_purchase_order_supplier',
            supplier.name.split(',').first,
            (t) => t == label,
          );
          await tapKey('new_purchase_order_delivery');
          await pumpUntil(find.byType(DatePickerDialog));
          final picker = tester.widget<DatePickerDialog>(
            find.byType(DatePickerDialog),
          );
          expect(picker.firstDate, today, reason: 'past dates selectable');
          await pickDate(date1);
          await typeInto('new_purchase_order_comment', tag);
          expect(enabled('new_purchase_order_submit'), isTrue);
          await tapKey('new_purchase_order_submit');
          await pumpUntilGone(byKey('new_purchase_order_dialog'));
          await pumpUntilTrue(
            () => RegExp(r'^/purchases/orders/\d+$').hasMatch(location()),
            'the new draft opened (at ${location()})',
          );
          final id = int.parse(location().split('/').last);
          orderA = id;
          createdOrders.add(id);
          await pumpUntil(inFacts(statusLabel(InventoryDocumentStatus.draft)));
          final o = await orders.get(id);
          expect(o.supplierId, supplierId);
          expect(o.comment, tag);
          expect(_sameDay(o.estimatedReceiptDate, date1), isTrue);
          expect(textOf('purchase_order_delivery'), fmt().display.date(date1));
          note('order A #$id');
        },
      );

      // ---- 5: header ----------------------------------------------------------
      await step('5 change the date; clear notes and date: both empty on '
          'reopen', () async {
        final id = orderA ?? (throw TestFailure('step 4 created nothing'));
        await openOrder(id);
        final date2 = today.add(const Duration(days: 3));
        await tapKey('purchase_order_edit_header');
        await pumpUntil(byKey('purchase_order_header_dialog'));
        await tapKey('purchase_order_header_delivery');
        await pickDate(date2);
        await tapKey('purchase_order_header_submit');
        await pumpUntilGone(byKey('purchase_order_header_dialog'));
        await pumpUntilTrue(
          () => textOf('purchase_order_delivery') == fmt().display.date(date2),
          'the new date',
        );
        expect(
          _sameDay((await orders.get(id)).estimatedReceiptDate, date2),
          isTrue,
        );

        await tapKey('purchase_order_edit_header');
        await pumpUntil(byKey('purchase_order_header_dialog'));
        await tapKey('purchase_order_header_delivery_clear');
        await typeInto('purchase_order_header_comment', '');
        await tapKey('purchase_order_header_submit');
        await pumpUntilGone(byKey('purchase_order_header_dialog'));
        await openOrder(id);
        expect(textOf('purchase_order_comment'), emptyValuePlaceholder);
        expect(textOf('purchase_order_delivery'), emptyValuePlaceholder);
        final o = await orders.get(id);
        expect(o.comment, isNull);
        expect(o.estimatedReceiptDate, isNull);
        expect(o.supplierId, supplierId, reason: 'supplier untouched');
        // The tag back, so the order stays recognizable once confirmed.
        await orders.updateHeader(id, comment: tag);
      });

      // ---- 6: lines -----------------------------------------------------------
      await step('6 add a product (W1, cost, tax); edit to W2, 1.2345, '
          '10.1234567, IVA 0; 0 and 1.23456 refused; delete', () async {
        final id = orderA ?? (throw TestFailure('step 4 created nothing'));
        await openOrder(id);
        await pumpUntil(byKey('purchase_order_lines_empty'));
        await tapKey('purchase_order_add_product');
        await pumpUntil(byKey('add_order_line_dialog'));
        await pick('add_order_line_product', p.code, (t) => t == p.name);
        await typeInto('add_order_line_quantity', '2');
        await pumpUntilTrue(
          () => enabled('add_order_line_submit'),
          '"Agregar" enabled',
        );
        await tapKey('add_order_line_submit');
        await pumpUntilGone(byKey('add_order_line_dialog'));
        var o = await orders.get(id);
        final line = o.lines.single;
        expect(line.productId, p.productId);
        expect(line.quantity, Decimal.fromInt(2));
        expect(line.warehouseId, w1, reason: 'the POS warehouse');
        if (pCost != null) expect(line.price, pCost, reason: 'at cost');
        expect(line.taxRate, Decimal.parse(p.taxRate));
        await pumpUntil(byKey('purchase_order_line_quantity_${line.id}'));
        expect(
          textOf('purchase_order_line_quantity_${line.id}'),
          fmt().display.quantity('2'),
        );

        await tapKey('purchase_order_line_edit_${line.id}');
        await pumpUntil(byKey('order_line_dialog'));
        for (final bad in ['0', '1.23456']) {
          await typeInto('order_line_quantity', bad);
          expect(enabled('order_line_submit'), isFalse, reason: '$bad taken');
          expect(
            find.text(l10n.purchaseOrderQuantityInvalid),
            findsOneWidget,
            reason: bad,
          );
        }
        await typeInto('order_line_quantity', '1.2345');
        await typeInto('order_line_price', '10.1234567');
        await pick('order_line_warehouse', w2.name, (t) => t == w2.name);
        await tapKey('order_line_tax');
        await pumpUntil(byKey('order_line_tax_0'));
        await tester.tap(byKey('order_line_tax_0').last);
        await pumpFor(const Duration(milliseconds: 600));
        expect(enabled('order_line_submit'), isTrue);
        await tapKey('order_line_submit');
        await pumpUntilGone(byKey('order_line_dialog'));
        o = await orders.get(id);
        final edited = o.lines.single;
        expect(edited.warehouseId, w2.warehouseId);
        expect(edited.quantity, Decimal.parse('1.2345'));
        expect(edited.price, Decimal.parse('10.1234567'));
        expect(edited.taxRate, Decimal.zero);
        await pumpUntil(
          find.descendant(
            of: byKey('purchase_order_lines_table'),
            matching: find.text(w2.name),
          ),
        );

        await tapKey('purchase_order_line_remove_${line.id}');
        await pumpUntil(byKey('purchase_order_line_remove_dialog'));
        await tapKey('purchase_order_line_remove_submit');
        await pumpUntilGone(byKey('purchase_order_line_remove_dialog'));
        await pumpUntil(byKey('purchase_order_lines_empty'));
        expect((await orders.get(id)).lines, isEmpty);
      });

      // ---- 7: request lines ---------------------------------------------------
      PurchaseRequest? r2;
      Future<void> addRequest(PurchaseRequest r) async {
        await tapKey('purchase_order_add_request');
        await pumpUntil(byKey('add_request_lines_dialog'));
        await pick(
          'add_request_lines_request',
          '${r.serial}',
          (t) => t.startsWith('${r.serial} · ') && t.endsWith(w1Row.name),
        );
        await pumpUntilTrue(
          () => enabled('add_request_lines_submit'),
          '"Agregar" enabled',
        );
        await tapKey('add_request_lines_submit');
        await pumpUntilTrue(
          () =>
              byKey('add_request_lines_dialog').evaluate().isEmpty ||
              byKey('add_request_lines_refusal').evaluate().isNotEmpty,
          'added or refused',
        );
      }

      await step('7 the ordered request: "ya estaba"/nothing_to_add; another '
          'request: added with "Sol. {folio}"', () async {
        final id = orderA ?? (throw TestFailure('step 4 created nothing'));
        final first = r1 ?? (throw TestFailure('step 2 made no request'));
        await openOrder(id);
        await addRequest(first);
        if (byKey('add_request_lines_refusal').evaluate().isNotEmpty) {
          expect(
            allTextUnder('add_request_lines_refusal'),
            contains(l10n.apiErrorPurchaseOrderNothingToAdd),
          );
          note('7: ordered request refused: nothing_to_add');
          await recover();
        } else {
          await pumpUntilTrue(
            () => snacks().contains(
              l10n.purchaseOrderLeftOutSnack(first.lines.length).trim(),
            ),
            'the left-out SnackBar (have "${snacks()}")',
          );
          note('7: ordered request: ${snacks()}');
        }
        expect(
          (await orders.get(id)).lines,
          isEmpty,
          reason: 'lines of an ordered request were added',
        );

        r2 = await approvedRequest([p.productId]);
        note('request #${r2!.id} folio ${r2!.serial}');
        await addRequest(r2!);
        expect(byKey('add_request_lines_refusal'), findsNothing);
        await pumpUntilTrue(
          () => snacks().contains(l10n.purchaseOrderAddRequestSnack(1)),
          'the added SnackBar (have "${snacks()}")',
        );
        final o = await orders.get(id);
        final line = o.lines.single;
        expect(line.requestId, r2!.id);
        expect(line.warehouseId, w1);
        await pumpUntilTrue(
          () =>
              byKey(
                'purchase_order_line_request_${line.id}',
              ).evaluate().isNotEmpty &&
              textOf('purchase_order_line_request_${line.id}') ==
                  l10n.purchaseOrderLineRequest('${r2!.serial}'),
          '"Sol. ${r2!.serial}" under the product',
        );
      });

      // ---- 8: confirm ---------------------------------------------------------
      final receiptsOfA = <int>[];
      await step('8 confirm (two warehouses, a service line, a price-0 '
          'line): Confirmada, two Entradas, gone on reload', () async {
        final id = orderA ?? (throw TestFailure('step 4 created nothing'));
        // Setup: a W2 line priced 0 and a service line.
        var o = await orders.addLine(
          id,
          productId: p.productId,
          quantity: Decimal.one,
        );
        final w2Line = o.lines.last;
        await orders.updateLine(
          id,
          w2Line.id,
          warehouseId: w2.warehouseId,
          price: Decimal.zero,
        );
        o = await orders.addLine(
          id,
          productId: service.productId,
          quantity: Decimal.one,
        );
        final serviceLine = o.lines.singleWhere(
          (l) => l.productId == service.productId,
        );
        await openOrder(id);
        await tapKey('purchase_order_confirm');
        await pumpUntil(byKey('purchase_order_confirm_dialog'));
        await pumpUntilTrue(
          () =>
              textOf(
                'purchase_order_confirm_warehouses',
              ).contains(w1Row.name) &&
              textOf('purchase_order_confirm_warehouses').contains(w2.name),
          'both warehouses named (have '
          '"${textOf('purchase_order_confirm_warehouses')}")',
        );
        expect(
          allTextUnder('purchase_order_confirm_zero_price'),
          contains(p.code),
        );
        await tapKey('purchase_order_confirm_submit');
        await pumpUntilGone(byKey('purchase_order_confirm_dialog'));
        await pumpUntil(
          inFacts(statusLabel(InventoryDocumentStatus.completed)),
        );
        await pumpUntil(byKey('purchase_order_receipts'));
        receiptsOfA.addAll(
          find
              .byWidgetPredicate(
                (w) =>
                    w.key is ValueKey<String> &&
                    RegExp(
                      r'^purchase_order_receipt_\d+$',
                    ).hasMatch((w.key! as ValueKey<String>).value),
              )
              .evaluate()
              .map(
                (e) => int.parse(
                  (e.widget.key! as ValueKey<String>).value.substring(
                    'purchase_order_receipt_'.length,
                  ),
                ),
              ),
        );
        createdReceipts.addAll(receiptsOfA);
        expect(receiptsOfA, hasLength(2), reason: 'one per warehouse');
        expect(snacks(), contains(l10n.purchaseOrderConfirmedSnack(2)));
        final ws = <int>{};
        for (final rid in receiptsOfA) {
          ws.add((await receipts.get(rid)).warehouseId);
        }
        expect(ws, {w1, w2.warehouseId});
        expect(byKey('purchase_order_cancel'), findsNothing);
        expect(byKey('purchase_order_edit_header'), findsNothing);

        await tapKey('purchase_order_receipt_open_${receiptsOfA.first}');
        await pumpUntilTrue(
          () => location() == '$_receipts/${receiptsOfA.first}',
          'the receipt opened (at ${location()})',
        );
        await pumpUntil(byKey('inventory_receipt_facts'));
        await back();
        await pumpUntilTrue(() => location() == '$_orders/$id', 'back');

        await openOrder(id);
        expect(byKey('purchase_order_receipts'), findsNothing);
        o = await orders.get(id);
        for (final l in o.lines) {
          final received = textOf('purchase_order_line_received_${l.id}');
          final pending = textOf('purchase_order_line_pending_${l.id}');
          if (l.id == serviceLine.id) {
            expect(received, emptyValuePlaceholder, reason: 'service');
            expect(pending, emptyValuePlaceholder, reason: 'service');
          } else {
            expect(received, fmt().display.quantity('0'), reason: '${l.id}');
            expect(
              pending,
              fmt().display.quantity('${l.quantity}'),
              reason: '${l.id}',
            );
          }
        }
        note('order A #$id confirmed: receipts $receiptsOfA');
      });

      // ---- 9: receive ---------------------------------------------------------
      await step('9 receive W1: Recibido = ordered, Pendiente 0; receipt and '
          'request link back to the order', () async {
        final id = orderA ?? (throw TestFailure('step 4 created nothing'));
        final req = r2 ?? (throw TestFailure('step 7 made no request'));
        int? w1Receipt;
        for (final rid in receiptsOfA) {
          if ((await receipts.get(rid)).warehouseId == w1) w1Receipt = rid;
        }
        if (w1Receipt == null) throw TestFailure('no W1 receipt');
        await receipts.confirm(w1Receipt);
        confirmedReceipts.add(w1Receipt);
        await openOrder(id);
        final o = await orders.get(id);
        for (final l in o.lines.where(
          (l) => l.warehouseId == w1 && l.productId == p.productId,
        )) {
          expect(
            textOf('purchase_order_line_received_${l.id}'),
            fmt().display.quantity('${l.quantity}'),
          );
          expect(
            textOf('purchase_order_line_pending_${l.id}'),
            fmt().display.quantity('0'),
          );
        }

        await go('$_receipts/$w1Receipt');
        await pumpUntil(byKey('inventory_receipt_facts'));
        await tapKey('purchase_order_link_$id');
        await pumpUntilTrue(
          () => location() == '$_orders/$id',
          'the receipt\'s order link (at ${location()})',
        );
        await pumpUntil(byKey('purchase_order_facts'));

        container().invalidate(purchaseRequestDetailControllerProvider(req.id));
        await go('$_requests/${req.id}');
        await pumpUntil(byKey('purchase_request_facts'));
        await tapKey('purchase_order_link_$id');
        await pumpUntilTrue(
          () => location() == '$_orders/$id',
          'the request\'s order link (at ${location()})',
        );
        await pumpUntil(byKey('purchase_order_facts'));
      });

      // ---- 10: print and email -------------------------------------------------
      await step('10 Imprimir shows the PDF; email suggests the supplier\'s '
          'contacts and reports email.not_configured; a draft offers '
          'neither', () async {
        final id = orderA ?? (throw TestFailure('step 4 created nothing'));
        await openOrder(id);
        await tapKey('purchase_order_print');
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
        expect(
          textOf('document_preview_title'),
          l10n.purchaseOrderTitle('$id'),
        );
        await tapKey('document_preview_close');
        await pumpUntilGone(byKey('document_preview_surface'));

        String? probe;
        try {
          await orders.email(999999999, recipients: ['qa080@example.com']);
          probe = 'no error';
        } on AppError catch (e) {
          probe = _code(e) ?? '$e';
        }
        await tapKey('purchase_order_email');
        await pumpUntil(byKey('purchase_order_email_dialog'));
        final contacts = supplier.contacts
            .map((c) => c.email?.trim() ?? '')
            .where((e) => e.contains('@'))
            .toList();
        if (contacts.isEmpty) {
          await pumpUntil(byKey('purchase_order_email_no_suggestions'));
        } else {
          await pumpUntil(byKey('purchase_order_email_suggestions'));
        }
        final emailField = find.descendant(
          of: byKey('purchase_order_email_other_field'),
          matching: find.byType(EditableText),
        );
        for (final a in ['qa080a@example.com', 'qa080b@example.com']) {
          // Focus the field first: after "Agregar" takes focus, a bare
          // enterText on the device reaches no field.
          await tapFinder(emailField);
          await tester.enterText(emailField, a);
          await pumpFor(const Duration(milliseconds: 300));
          final controller = tester.widget<EditableText>(emailField).controller;
          if (controller.text != a) {
            note('10: typing "$a" did not reach the field; set directly');
            controller.text = a;
            await pumpFor(const Duration(milliseconds: 300));
          }
          await tapKey('purchase_order_email_add_button');
          await pumpUntil(byKey('purchase_order_email_chip_$a'));
        }
        expect(
          textOf('purchase_order_email_counter'),
          l10n.salesQuoteEmailCounter(2),
          reason: 'only the two typed addresses are selected',
        );
        await typeInto('purchase_order_email_message', tag);
        if (probe != 'email.not_configured') {
          note('10: mail looks configured (probe: $probe): not sending');
          await tapKey('purchase_order_email_cancel');
        } else {
          await tapKey('purchase_order_email_send');
          await pumpUntil(byKey('purchase_order_email_refusal'));
          expect(
            allTextUnder('purchase_order_email_refusal'),
            contains(l10n.apiErrorEmailNotConfigured),
          );
          expect(byKey('purchase_order_email_dialog'), findsOneWidget);
          await tapKey('purchase_order_email_cancel');
        }
        await pumpUntilGone(byKey('purchase_order_email_dialog'));

        final draft = orderB ?? (throw TestFailure('step 3 created nothing'));
        await openOrder(draft);
        await pumpUntil(byKey('purchase_order_confirm'));
        expect(byKey('purchase_order_print'), findsNothing);
        expect(byKey('purchase_order_email'), findsNothing);
      });

      // ---- 11: cancel ---------------------------------------------------------
      await step('11 cancel the Por comprar draft: Cancelada, lines kept, '
          'back in Por comprar; a confirmed order has no cancel', () async {
        final id = orderB ?? (throw TestFailure('step 3 created nothing'));
        final before = await orders.get(id);
        await openOrder(id);
        await tapKey('purchase_order_cancel');
        await pumpUntil(byKey('purchase_order_cancel_dialog'));
        expect(
          textOf('purchase_order_cancel_body'),
          l10n.purchaseOrderCancelBody,
        );
        await tapKey('purchase_order_cancel_submit');
        await pumpUntilGone(byKey('purchase_order_cancel_dialog'));
        await pumpUntil(
          inFacts(statusLabel(InventoryDocumentStatus.cancelled)),
        );
        expect(byKey('purchase_order_actions'), findsNothing);
        final after = await orders.get(id);
        expect(after.status, InventoryDocumentStatus.cancelled);
        expect(after.lines, hasLength(before.lines.length));
        for (final l in after.lines.take(3)) {
          expect(byKey('purchase_order_line_quantity_${l.id}'), findsOneWidget);
        }
        final pending = (await orders.toPurchase(
          facilityId: f1,
        )).expand((g) => g.lines).map((l) => l.requestLineId).toSet();
        expect(
          pending.containsAll(before.lines.map((l) => l.requestLineId)),
          isTrue,
        );
        await go('$_toPurchase?facility=$f1');
        await waitForToPurchase();
        await scrollToGroup(groupTag);

        final confirmed = orderA ?? (throw TestFailure('no order A'));
        await openOrder(confirmed);
        expect(byKey('purchase_order_cancel'), findsNothing);
      });

      // ---- 12: list -----------------------------------------------------------
      await step('12a default list: own orders, no cancelled', () async {
        await go(_orders);
        await waitForList();
        final expected = await orders.list(skip: 0, limit: 20);
        expect(
          expected.items.where(
            (s) => s.status == InventoryDocumentStatus.cancelled,
          ),
          isEmpty,
        );
        await expectRows(expected, 'the default page');
        expect(badge('purchase_orders_filter_button'), '');
      });

      await step('12b Mostrar → Todas: badge 1', () async {
        await go(_orders);
        await waitForList();
        await openDrawer();
        await tapKey('purchase_orders_scope_all');
        await pumpUntilTrue(() => params()['all'] == 'true', 'all in URL');
        await applyDrawer();
        expect(badge('purchase_orders_filter_button'), '1');
        await expectRows(
          await orders.list(all: true, skip: 0, limit: 20),
          'everyone\'s',
        );
      });

      await step('12c Estado = Cancelada', () async {
        await go(_orders);
        await waitForList();
        await openDrawer();
        await tapKey('purchase_orders_status_cancelled');
        await pumpUntilTrue(
          () => params()['status'] == 'cancelled',
          'status in URL',
        );
        await applyDrawer();
        final expected = await orders.list(
          status: InventoryDocumentStatus.cancelled,
          skip: 0,
          limit: 20,
        );
        await expectRows(expected, 'cancelled');
        if (orderB != null) expect(listRows(), contains(orderB));
      });

      await step('12d Proveedor facet', () async {
        await go('$_orders?all=true');
        await waitForList();
        await openDrawer();
        await pumpUntil(byKey('purchase_orders_supplier_filter'));
        final label = '${supplier.code} — ${supplier.name}';
        await pick(
          'purchase_orders_supplier_filter',
          supplier.name.split(',').first,
          (t) => t == label,
        );
        await pumpUntilTrue(
          () => params()['supplier'] == '$supplierId',
          'supplier in URL',
        );
        await applyDrawer();
        expect(badge('purchase_orders_filter_button'), '2');
        final expected = await orders.list(
          all: true,
          supplierId: supplierId,
          skip: 0,
          limit: 20,
        );
        expect(expected.items.every((s) => s.supplierId == supplierId), isTrue);
        await expectRows(expected, 'supplier $supplierId');
      });

      await step('12e date range (from the URL)', () async {
        final from = today.subtract(const Duration(days: 1));
        await go(
          '$_orders?all=true&from=${encodePaymentsDateFacet(from)}'
          '&to=${encodePaymentsDateFacet(today)}',
        );
        await waitForList();
        expect(badge('purchase_orders_filter_button'), '2');
        final expected = await orders.list(
          all: true,
          from: from,
          to: today,
          skip: 0,
          limit: 20,
        );
        await expectRows(expected, 'the range');
        expect(listRows(), contains(orderA));
      });

      await step('12f search the order number', () async {
        final id = orderA ?? (throw TestFailure('step 4 created nothing'));
        await go('$_orders?all=true');
        await waitForList();
        await typeInto('purchase_orders_search', '$id');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await pumpUntilTrue(() => params()['search'] == '$id', 'search in URL');
        await waitForList();
        await pumpUntilTrue(
          () => listRows().length == 1 && listRows().contains(id),
          'only #$id; have ${listRows()}',
        );
      });

      // ---- 14: concurrency ------------------------------------------------------
      await step('14 confirmed elsewhere, edited here: Spanish refusal and '
          'the screen reloads as Confirmada', () async {
        var c = await orders.create(supplierId: supplierId, comment: tag);
        createdOrders.add(c.id);
        await orders.addLine(
          c.id,
          productId: p.productId,
          quantity: Decimal.one,
        );
        await openOrder(c.id);
        await pumpUntil(byKey('purchase_order_edit_header'));
        // The other session.
        c = await orders.confirm(c.id);
        createdReceipts.addAll(c.receipts.map((r) => r.id));
        note(
          'order C #${c.id} confirmed elsewhere: receipts '
          '${c.receipts.map((r) => r.id)}',
        );
        await tapKey('purchase_order_edit_header');
        await pumpUntil(byKey('purchase_order_header_dialog'));
        await typeInto('purchase_order_header_comment', '$tag edited');
        await tapKey('purchase_order_header_submit');
        await pumpUntil(byKey('purchase_order_header_refusal'));
        final refusal = allTextUnder('purchase_order_header_refusal');
        note('14: refusal "$refusal"');
        expect(
          [
            l10n.apiErrorDocumentNotEditable,
            l10n.apiErrorLockBusy,
          ].any(refusal.contains),
          isTrue,
          reason: 'refusal "$refusal"',
        );
        await recover();
        await pumpUntil(
          inFacts(statusLabel(InventoryDocumentStatus.completed)),
        );
        expect(byKey('purchase_order_edit_header'), findsNothing);
        expect((await orders.get(c.id)).comment, tag);
      });

      // ---- 1b: qanoaccess -------------------------------------------------------
      if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
        await container().read(authProvider.notifier).signOut();
        await login(_noAccessUser, _noAccessPass);
        await step('1b qanoaccess: no Por comprar / Órdenes de compra, the '
            'routes redirect home', () async {
          expect(byKey('nav_dest_to-purchase'), findsNothing);
          expect(byKey('nav_dest_purchase-orders'), findsNothing);
          await go(_orders);
          expect(location(), '/');
          expect(byKey('purchase_orders_table'), findsNothing);
          await go(_toPurchase);
          expect(location(), '/');
          await go('$_orders/${orderA ?? 1}');
          expect(location(), '/');
        });
      } else {
        note('1b SKIPPED: MBE_TEST_USERNAME/_PASSWORD not given');
      }
    } finally {
      // Leave dev clean.
      final left = <String>[];
      for (final id in createdReceipts) {
        if (confirmedReceipts.contains(id)) {
          left.add('receipt #$id confirmed (kept)');
          continue;
        }
        try {
          final r = await receipts.cancel(id);
          left.add('receipt #$id ${r.status.name}');
        } on Object catch (e) {
          left.add('receipt #$id NOT CANCELLED (${_code(e) ?? _short(e)})');
        }
      }
      for (final id in createdOrders) {
        try {
          var o = await orders.get(id);
          if (o.status == InventoryDocumentStatus.draft) {
            o = await orders.cancel(id);
          }
          left.add('order #$id ${o.status.name}');
        } on Object catch (e) {
          left.add('order #$id NOT CANCELLED (${_code(e) ?? _short(e)})');
        }
      }
      for (final id in createdRequests) {
        try {
          var r = await requests.get(id);
          if (r.status != PurchaseRequestStatus.cancelled) {
            r = await requests.cancel(id);
          }
          left.add('request #$id ${r.status.name}');
        } on Object catch (e) {
          left.add('request #$id NOT CANCELLED (${_code(e) ?? _short(e)})');
        }
      }
      note('cleanup: ${left.join(', ')}');
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
  }, timeout: const Timeout(Duration(minutes: 25)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
