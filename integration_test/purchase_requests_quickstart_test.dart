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
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_detail_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/079-purchase-requests/quickstart.md steps 1–11 against
/// the REAL app (macOS desktop) and a live mbe-api (task T036).
///
///   caffeinate -dims flutter test \
///     integration_test/purchase_requests_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env
///
/// `MBE_POS_*` is the administrator (rights 86, 96 and 20; W1 = its
/// point-of-sale warehouse); `MBE_TEST_*` is `qanoaccess`, for step 1's gate.
///
/// **This test writes.** Every request it creates is cancelled before it
/// ends, so a run leaves only cancelled requests (notes "QA079 …") behind.
/// Setup the steps don't exercise (a request to reject, the bulk batch, a
/// draft with a line) is made through the repository; what each step checks
/// is done through the UI.
///
/// Not automated: the timed checks (SC-001 in step 5, SC-002 in step 8) and
/// steps 12–14 (no fixture user, manual largest-text check).
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');

/// A pattern with active purchasable products on the dev tenant ('a' finds
/// nothing there).
const _productPattern = 'clavo';

const _wide = Size(1400, 1000);
const _list = '/purchases/requests';
const _queue = '/purchases/request-approval';

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

  testWidgets('Purchase requests walkthrough (real app, live mbe-api)', (
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
    final requests = PurchaseRequestRepositoryImpl(dio);
    final warehouses = WarehouseRepositoryImpl(dio);
    final products = ProductRepositoryImpl(dio);
    final me = await auth.me();
    final w1 = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: me.settings!.pointSaleId!)).warehouseId;
    final w1Row = await warehouses.get(warehouseId: w1);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    final tag = 'QA079 ${DateTime.now().millisecondsSinceEpoch % 100000}';

    /// Every request this run creates, cancelled at the end.
    final created = <int>[];
    Future<PurchaseRequest> apiDraft() async {
      final r = await requests.create(warehouseId: w1, comment: tag);
      created.add(r.id);
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

    String textOf(String key) {
      final w = tester.widget(byKey(key));
      if (w is RecordIdText) return w.text;
      return (w as Text).data ?? '';
    }

    /// Every submitted request, oldest first (the endpoint caps a page at
    /// 100).
    Future<List<PurchaseRequestSummary>> wholeQueue() async {
      final out = <PurchaseRequestSummary>[];
      while (true) {
        final page = await requests.approvalQueue(skip: out.length, limit: 100);
        out.addAll(page.items);
        if (page.items.isEmpty || out.length >= page.total) return out;
      }
    }

    Future<void> typeInto(String key, String text) async {
      final field = find.descendant(
        of: byKey(key),
        matching: find.byType(EditableText),
      );
      await pumpUntil(field);
      await tester.enterText(field.first, text);
      await pumpFor(const Duration(milliseconds: 300));
    }

    String fieldText(String key) => tester
        .widget<EditableText>(
          find
              .descendant(of: byKey(key), matching: find.byType(EditableText))
              .first,
        )
        .controller
        .text;

    /// The picker's suggestion rows labelled [label] (every picker here has
    /// a subtitle, so its rows are ListTiles).
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

    Future<void> waitForList() => waitForTable('purchase_requests_table', [
      l10n.purchaseRequestEmptyMine,
      l10n.purchaseRequestEmptyAll,
      l10n.purchaseRequestFilteredEmpty,
    ]);

    Future<void> waitForQueue() => waitForTable(
      'purchase_request_approval_table',
      [l10n.purchaseRequestQueueEmpty],
    );

    /// The request ids whose folio cell the table under [tableKey] shows,
    /// top to bottom.
    List<int> rowsIn(String tableKey) {
      final cells = find
          .descendant(
            of: byKey(tableKey),
            matching: find.byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith(
                    'purchase_request_folio_',
                  ),
            ),
          )
          .evaluate()
          .toList();
      double top(Element e) =>
          (e.renderObject! as RenderBox).localToGlobal(Offset.zero).dy;
      cells.sort((a, b) => top(a).compareTo(top(b)));
      return [
        for (final e in cells)
          int.parse(
            (e.widget.key! as ValueKey<String>).value.substring(
              'purchase_request_folio_'.length,
            ),
          ),
      ];
    }

    Set<int> listRows() => rowsIn('purchase_requests_table').toSet();

    Future<void> openDetail(int id) async {
      container().invalidate(purchaseRequestDetailControllerProvider(id));
      await go(_list);
      await go('$_list/$id');
      await pumpUntilTrue(
        () => byKey('purchase_request_facts').evaluate().isNotEmpty,
        'request $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    Finder inFacts(String text) => find.descendant(
      of: byKey('purchase_request_facts'),
      matching: find.text(text),
    );

    /// Opens the queue page that holds [id] (oldest first, 20 a page).
    Future<void> openQueueAt(int id) async {
      final all = await wholeQueue();
      final index = all.indexWhere((s) => s.id == id);
      if (index < 0) throw TestFailure('#$id is not in the approval queue');
      final page = index ~/ 20;
      await go(_queue);
      await go(page == 0 ? _queue : '$_queue?page=${page + 1}');
      await waitForQueue();
    }

    Future<void> openDrawer() async {
      await tapKey('purchase_requests_filter_button');
      await pumpUntil(byKey('purchase_requests_scope_filter'));
    }

    Future<void> applyDrawer() async {
      await tapKey('filter_sheet_apply_button');
      await waitForList();
    }

    String badge(String buttonKey) {
      final b = tester.widget<Badge>(
        find.ancestor(of: byKey(buttonKey), matching: find.byType(Badge)),
      );
      return b.isLabelVisible ? (b.label! as Text).data ?? '' : '';
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
    // Fixtures: a purchasable product (min > 1 preferred), a warehouse of
    // another facility.
    // ------------------------------------------------------------------
    final found = await products.list(
      search: _productPattern,
      status: EntityStatus.active,
      purchasable: true,
      limit: 50,
    );
    if (found.items.isEmpty) {
      throw TestFailure('no active purchasable "$_productPattern" product');
    }
    ProductListItem product = found.items.first;
    int? minimum;
    {
      final scratch = await apiDraft();
      for (final p in found.items) {
        final r = await requests.addLine(scratch.id, productId: p.productId);
        final l = r.lines.singleWhere((l) => l.productId == p.productId);
        await requests.removeLine(scratch.id, l.id);
        if ((l.minOrderQty ?? 0) > 1) {
          product = p;
          minimum = l.minOrderQty;
          break;
        }
      }
      await requests.cancel(scratch.id);
    }
    final Warehouse w2 = (await warehouses.list(
      status: EntityStatus.active,
      limit: 100,
    )).items.firstWhere((w) => w.facilityId != w1Row.facilityId);
    note(
      'tag "$tag"; W1 $w1 (${w1Row.name}); product ${product.code} '
      '"${product.name}" min $minimum; W2 ${w2.warehouseId} (${w2.name}, '
      '${w2.facilityName})',
    );

    try {
      // ----------------------------------------------------------------
      // Login (admin)
      // ----------------------------------------------------------------
      note('logging in as admin');
      await login(_adminUser, _adminPass);

      // ---- 1: navigation --------------------------------------------------
      await step('1 Compras holds both entries, between Inventario and '
          'Finanzas; opens the list', () async {
        final group = byKey('nav_group_purchases');
        await pumpUntil(group);
        expect(
          find.descendant(
            of: group,
            matching: find.text(l10n.navPurchasesGroup),
          ),
          findsWidgets,
        );
        double top(String key) => tester.getTopLeft(byKey(key)).dy;
        expect(
          top('nav_group_inventory'),
          lessThan(top('nav_group_purchases')),
        );
        expect(top('nav_group_purchases'), lessThan(top('nav_group_finance')));
        final requestsEntry = byKey('nav_dest_purchase-requests');
        final approvalEntry = byKey('nav_dest_purchase-request-approval');
        await pumpUntil(requestsEntry);
        await pumpUntil(approvalEntry);
        expect(
          find.descendant(
            of: requestsEntry,
            matching: find.text(l10n.navPurchaseRequests),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: approvalEntry,
            matching: find.text(l10n.navPurchaseRequestApproval),
          ),
          findsOneWidget,
        );
        expect(
          top('nav_dest_purchase-requests'),
          lessThan(top('nav_dest_purchase-request-approval')),
        );
        await tapFinder(approvalEntry);
        await pumpUntilTrue(() => location() == _queue, 'the queue route');
        await waitForQueue();
        await tapFinder(requestsEntry);
        await pumpUntilTrue(() => location() == _list, 'the list route');
        await waitForList();
      });

      // ---- 2: create --------------------------------------------------------
      int? id1;
      await step('2 Nueva solicitud starts at W1; creates "Solicitud · '
          'Borrador #{id}"', () async {
        await go(_list);
        await waitForList();
        await tapKey('purchase_requests_new_button');
        await pumpUntil(byKey('new_purchase_request_dialog'));
        await pumpUntilTrue(
          () => fieldText('new_purchase_request_warehouse') == w1Row.name,
          'the starting warehouse W1 (have '
          '"${fieldText('new_purchase_request_warehouse')}")',
        );
        await typeInto('new_purchase_request_comment', tag);
        expect(enabled('new_purchase_request_submit'), isTrue);
        await tapKey('new_purchase_request_submit');
        await pumpUntilGone(byKey('new_purchase_request_dialog'));
        await pumpUntilTrue(
          () => RegExp(r'^/purchases/requests/\d+$').hasMatch(location()),
          'the new draft opened (at ${location()})',
        );
        final id = int.parse(location().split('/').last);
        id1 = id;
        created.add(id);
        await pumpUntil(find.text(l10n.purchaseRequestTitleDraft('$id')));
        await pumpUntil(inFacts(l10n.purchaseRequestStatusDraft));
        final r = await requests.get(id);
        expect(r.status, PurchaseRequestStatus.draft);
        expect(r.serial, isNull);
        expect(r.warehouseId, w1);
        expect(r.comment, tag);
        note('created #$id');
      });

      // ---- 3: lines ---------------------------------------------------------
      int? line1;
      await step('3 add the min-order product; below-minimum band; 0 and '
          '1.234 refused; destination in another facility', () async {
        final id = id1 ?? (throw TestFailure('step 2 created nothing'));
        await openDetail(id);
        await pumpUntil(byKey('purchase_request_lines_empty'));
        await tapKey('purchase_request_add_product');
        await pumpUntil(byKey('add_request_line_dialog'));
        await pick('add_request_line_product', product.code, product.name);
        await pumpUntilTrue(
          () => enabled('add_request_line_submit'),
          '"Agregar" enabled',
        );
        await tapKey('add_request_line_submit');
        await pumpUntilGone(byKey('add_request_line_dialog'));
        var r = await requests.get(id);
        final line = r.lines.single;
        line1 = line.id;
        expect(line.productId, product.productId);
        expect(line.productName, isNotEmpty);
        expect(
          line.quantity,
          minimum == null ? Decimal.one : Decimal.fromInt(minimum),
          reason: 'quantity = the minimum',
        );
        expect(line.warehouseId, w1, reason: 'destination = header warehouse');
        await pumpUntil(byKey('purchase_request_line_quantity_${line.id}'));
        await pumpUntil(find.text(line.productName));

        if (minimum == null) {
          note(
            'step 3: no "$_productPattern" product with a minimum above '
            '1: the band is not checked',
          );
        } else {
          await tapKey('purchase_request_line_edit_${line.id}');
          await pumpUntil(byKey('request_line_dialog'));
          await typeInto('request_line_quantity', '${minimum! - 1}');
          expect(enabled('request_line_submit'), isTrue);
          await tapKey('request_line_submit');
          await pumpUntilGone(byKey('request_line_dialog'));
          await pumpUntil(byKey('request_minimum_band'));
          expect(
            find.descendant(
              of: byKey('request_minimum_band'),
              matching: find.textContaining('($minimum)'),
            ),
            findsOneWidget,
          );
          r = await requests.get(id);
          expect(r.lines.single.quantity, Decimal.fromInt(minimum! - 1));
        }

        await tapKey('purchase_request_line_edit_${line.id}');
        await pumpUntil(byKey('request_line_dialog'));
        final kept = fieldText('request_line_quantity');
        await typeInto('request_line_quantity', '0');
        expect(enabled('request_line_submit'), isFalse, reason: '0 accepted');
        expect(find.text(l10n.purchaseRequestQuantityInvalid), findsOneWidget);
        await typeInto('request_line_quantity', '1.234');
        expect(
          enabled('request_line_submit'),
          isFalse,
          reason: '1.234 accepted',
        );
        expect(find.text(l10n.purchaseRequestQuantityInvalid), findsOneWidget);
        await typeInto('request_line_quantity', kept);
        await pick('request_line_destination', w2.name, w2.name);
        expect(enabled('request_line_submit'), isTrue);
        await tapKey('request_line_submit');
        await pumpUntilGone(byKey('request_line_dialog'));
        r = await requests.get(id);
        expect(r.lines.single.warehouseId, w2.warehouseId);
        await pumpUntil(
          find.descendant(
            of: byKey('purchase_request_lines_table'),
            matching: find.text(w2.name),
          ),
        );
      });

      // ---- 4: header --------------------------------------------------------
      Future<void> saveHeader() async {
        expect(enabled('purchase_request_header_submit'), isTrue);
        await tapKey('purchase_request_header_submit');
        await pumpUntilGone(byKey('purchase_request_header_dialog'));
        await pumpFor(const Duration(milliseconds: 500));
      }

      await step('4 edit the notes, then clear them: none shown', () async {
        final id = id1 ?? (throw TestFailure('step 2 created nothing'));
        await openDetail(id);
        await tapKey('purchase_request_edit_header');
        await pumpUntil(byKey('purchase_request_header_dialog'));
        await typeInto('purchase_request_header_comment', '$tag edited');
        await saveHeader();
        await pumpUntilTrue(
          () => textOf('purchase_request_comment') == '$tag edited',
          'the edited notes',
        );
        await tapKey('purchase_request_edit_header');
        await pumpUntil(byKey('purchase_request_header_dialog'));
        await typeInto('purchase_request_header_comment', '');
        await saveHeader();
        await openDetail(id);
        expect(textOf('purchase_request_comment'), emptyValuePlaceholder);
        final r = await requests.get(id);
        expect(r.comment, isNull);
        expect(r.warehouseId, w1, reason: 'warehouse untouched');
      });

      // ---- 5: submit --------------------------------------------------------
      int? emptyId;
      await step('5a submitting an empty draft: "no tiene partidas"; cancel '
          'the draft (11)', () async {
        final empty = await apiDraft();
        emptyId = empty.id;
        await openDetail(empty.id);
        await tapKey('purchase_request_submit');
        await pumpUntil(byKey('purchase_request_submit_dialog'));
        await tapKey('purchase_request_submit_submit');
        await pumpUntil(byKey('purchase_request_dialog_refusal'));
        expect(
          find.descendant(
            of: byKey('purchase_request_dialog_refusal'),
            matching: find.textContaining(l10n.apiErrorPurchaseRequestNoLines),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('no lines'), findsNothing);
        await recover();
        expect(
          (await requests.get(empty.id)).status,
          PurchaseRequestStatus.draft,
        );
        // Step 11, draft half: cancel it through the UI.
        await tapKey('purchase_request_cancel');
        await pumpUntil(byKey('purchase_request_cancel_dialog'));
        expect(
          textOf('purchase_request_cancel_body'),
          l10n.purchaseRequestCancelDraftBody,
        );
        await tapKey('purchase_request_cancel_submit');
        await pumpUntilGone(byKey('purchase_request_cancel_dialog'));
        await pumpUntil(inFacts(l10n.purchaseRequestStatusCancelled));
        expect(byKey('purchase_request_actions'), findsNothing);
        expect(
          (await requests.get(empty.id)).status,
          PurchaseRequestStatus.cancelled,
        );
      });

      int? serial1;
      await step('5b submit: folio, Enviada, no edit actions', () async {
        final id = id1 ?? (throw TestFailure('step 2 created nothing'));
        await openDetail(id);
        await tapKey('purchase_request_submit');
        await pumpUntil(byKey('purchase_request_submit_dialog'));
        expect(
          textOf('purchase_request_submit_body'),
          l10n.purchaseRequestSubmitFirstBody,
        );
        if (minimum != null) {
          // Step 3 left the line one below its minimum: listed, not blocking.
          expect(
            byKey('purchase_request_submit_below_minimum'),
            findsOneWidget,
          );
        }
        await tapKey('purchase_request_submit_submit');
        await pumpUntilGone(byKey('purchase_request_submit_dialog'));
        await pumpUntil(inFacts(l10n.purchaseRequestStatusSubmitted));
        final r = await requests.get(id);
        expect(r.status, PurchaseRequestStatus.submitted);
        expect(r.serial, isNotNull);
        serial1 = r.serial;
        await pumpUntil(find.text(l10n.purchaseRequestTitle('${r.serial}')));
        expect(textOf('purchase_request_serial'), '${r.serial}');
        expect(byKey('purchase_request_edit_header'), findsNothing);
        expect(byKey('purchase_request_add_product'), findsNothing);
        expect(byKey('purchase_request_submit'), findsNothing);
        expect(byKey('purchase_request_line_edit_$line1'), findsNothing);
        expect(byKey('purchase_request_line_remove_$line1'), findsNothing);
        note('#$id folio $serial1');
      });

      // ---- 6: approve -------------------------------------------------------
      await step('6 queue: oldest first, line count; Aprobar sets Aprobada '
          'and Aprobó; leaves the queue', () async {
        final id = id1 ?? (throw TestFailure('step 2 created nothing'));
        await openQueueAt(id);
        final page = int.tryParse(params()['page'] ?? '1')! - 1;
        final expected = await requests.approvalQueue(
          skip: page * 20,
          limit: 20,
        );
        final dates = expected.items.map((s) => s.date).toList();
        expect(dates, [...dates]..sort(), reason: 'API not oldest first');
        await pumpUntilTrue(
          () =>
              rowsIn('purchase_request_approval_table').join(',') ==
              expected.items.map((s) => s.id).join(','),
          'the queue rows in API order (have '
          '${rowsIn('purchase_request_approval_table')})',
        );
        expect(textOf('purchase_request_lines_$id'), '1');
        await tapKey('purchase_request_folio_$id');
        await pumpUntilTrue(
          () => location() == '$_list/$id',
          'the detail opened from the queue (at ${location()})',
        );
        await pumpUntil(byKey('purchase_request_approve'));
        expect(byKey('purchase_request_reject'), findsOneWidget);
        await tapKey('purchase_request_approve');
        await pumpUntil(byKey('purchase_request_approve_dialog'));
        await tapKey('purchase_request_approve_submit');
        await pumpUntilGone(byKey('purchase_request_approve_dialog'));
        await pumpUntil(inFacts(l10n.purchaseRequestStatusApproved));
        await pumpUntil(byKey('purchase_request_approver'));
        final r = await requests.get(id);
        expect(r.status, PurchaseRequestStatus.approved);
        expect(r.approverId, isNotNull);
        expect(r.approvalTime, isNotNull);
        expect(r.serial, serial1);
        final after = await wholeQueue();
        expect(after.any((s) => s.id == id), isFalse);
        await go(_queue);
        await waitForQueue();
        expect(byKey('purchase_request_folio_$id'), findsNothing);
      });

      // ---- 7: reject and resubmit -------------------------------------------
      int? id3;
      await step('7 reject with a reason: Borrador, same folio; resubmit: '
          'Enviada, back in the queue', () async {
        final r3 = await apiDraft();
        id3 = r3.id;
        await requests.addLine(r3.id, productId: product.productId);
        final serial = (await requests.submit(r3.id)).serial;
        await openDetail(r3.id);
        await tapKey('purchase_request_reject');
        await pumpUntil(byKey('purchase_request_reject_dialog'));
        expect(enabled('purchase_request_reject_submit'), isFalse);
        await typeInto('purchase_request_reject_reason', '$tag reason');
        expect(enabled('purchase_request_reject_submit'), isTrue);
        await tapKey('purchase_request_reject_submit');
        await pumpUntilGone(byKey('purchase_request_reject_dialog'));
        await pumpUntil(inFacts(l10n.purchaseRequestStatusDraft));
        expect(textOf('purchase_request_serial'), '$serial');
        await pumpUntil(find.text(l10n.purchaseRequestTitle('$serial')));
        var r = await requests.get(r3.id);
        expect(r.status, PurchaseRequestStatus.draft);
        expect(r.serial, serial);
        await tapKey('purchase_request_submit');
        await pumpUntil(byKey('purchase_request_submit_dialog'));
        expect(
          textOf('purchase_request_submit_body'),
          l10n.purchaseRequestSubmitResubmitBody('$serial'),
        );
        await tapKey('purchase_request_submit_submit');
        await pumpUntilGone(byKey('purchase_request_submit_dialog'));
        await pumpUntil(inFacts(l10n.purchaseRequestStatusSubmitted));
        r = await requests.get(r3.id);
        expect(r.status, PurchaseRequestStatus.submitted);
        expect(r.serial, serial);
        await openQueueAt(r3.id);
        await pumpUntil(byKey('purchase_request_folio_${r3.id}'));
      });

      // ---- 8: bulk approve --------------------------------------------------
      await step('8 bulk: select three, one cancelled meanwhile: "2 de 3" '
          'and "ya no está enviada"', () async {
        final ids = <int>[?id3];
        while (ids.length < 3) {
          final r = await apiDraft();
          await requests.addLine(r.id, productId: product.productId);
          await requests.submit(r.id);
          ids.add(r.id);
        }
        await openQueueAt(ids.last);
        for (final id in ids) {
          if (byKey('purchase_request_select_$id').evaluate().isEmpty) {
            throw TestFailure(
              '#$id is not on the queue page with ${ids.last} '
              '(rows ${rowsIn('purchase_request_approval_table')})',
            );
          }
        }
        for (final id in ids) {
          await tapKey('purchase_request_select_$id');
        }
        expect(location(), _queue, reason: 'a checkbox navigated');
        await pumpUntil(find.text(l10n.purchaseRequestApproveSelected('3')));
        final stale = ids.last;
        await requests.cancel(stale);
        await tapKey('purchase_request_approve_selected');
        await pumpUntil(byKey('purchase_request_bulk_result_dialog'));
        expect(
          textOf('purchase_request_bulk_result_summary'),
          l10n.purchaseRequestBulkResultSummary('2', '3'),
        );
        expect(
          textOf('purchase_request_bulk_result_refused_$stale'),
          contains(l10n.apiErrorPurchaseRequestNotSubmitted),
        );
        await tapKey('purchase_request_bulk_result_close');
        await pumpUntilGone(byKey('purchase_request_bulk_result_dialog'));
        for (final id in ids) {
          final r = await requests.get(id);
          expect(
            r.status,
            id == stale
                ? PurchaseRequestStatus.cancelled
                : PurchaseRequestStatus.approved,
            reason: '#$id',
          );
        }
        await pumpUntil(find.text(l10n.purchaseRequestApproveSelected('0')));
      });

      // ---- 9: list ----------------------------------------------------------
      await step('9a default list: own requests, no cancelled', () async {
        await go(_list);
        await waitForList();
        final expected = await requests.list(skip: 0, limit: 20);
        expect(
          expected.items.where(
            (s) => s.status == PurchaseRequestStatus.cancelled,
          ),
          isEmpty,
          reason: 'the default scope returned cancelled requests',
        );
        await pumpUntilTrue(
          () =>
              listRows().length == expected.items.length &&
              listRows().containsAll(expected.items.map((s) => s.id)),
          'the API\'s default page; have ${listRows()}',
        );
        expect(badge('purchase_requests_filter_button'), '');
      });

      await step('9b Mostrar → Todas: everyone\'s, badge 1', () async {
        await go(_list);
        await waitForList();
        await openDrawer();
        await tapKey('purchase_requests_scope_all');
        await pumpUntilTrue(() => params()['all'] == 'true', 'all in the URL');
        await applyDrawer();
        expect(badge('purchase_requests_filter_button'), '1');
        final expected = await requests.list(all: true, skip: 0, limit: 20);
        await pumpUntilTrue(
          () =>
              listRows().length == expected.items.length &&
              listRows().containsAll(expected.items.map((s) => s.id)),
          '${expected.items.length} rows of everyone; have ${listRows()}',
        );
      });

      await step('9c Estado = Cancelada (default scope): cancelled ones '
          'appear', () async {
        await go(_list);
        await waitForList();
        await openDrawer();
        await tapKey('purchase_requests_status_cancelled');
        await pumpUntilTrue(
          () => params()['status'] == 'cancelled',
          'status in the URL',
        );
        await applyDrawer();
        expect(params().containsKey('all'), isFalse);
        expect(badge('purchase_requests_filter_button'), '1');
        final expected = await requests.list(
          status: PurchaseRequestStatus.cancelled,
          skip: 0,
          limit: 20,
        );
        await pumpUntilTrue(
          () =>
              listRows().length == expected.items.length &&
              listRows().containsAll(expected.items.map((s) => s.id)),
          '${expected.items.length} cancelled rows; have ${listRows()}',
        );
        if (emptyId != null) {
          expect(listRows(), contains(emptyId), reason: 'step 5a\'s draft');
        }
      });

      await step('9d search the folio: matching rows', () async {
        final serial =
            serial1 ?? (throw TestFailure('step 5b submitted nothing'));
        await go('$_list?all=true');
        await waitForList();
        await typeInto('purchase_requests_search', '$serial');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await pumpUntilTrue(
          () => params()['search'] == '$serial',
          'search in the URL',
        );
        await waitForList();
        final expected = await requests.list(
          all: true,
          serial: serial,
          skip: 0,
          limit: 20,
        );
        expect(expected.items.every((s) => s.serial == serial), isTrue);
        await pumpUntilTrue(
          () =>
              listRows().length == expected.items.length &&
              listRows().containsAll(expected.items.map((s) => s.id)),
          'folio $serial rows ${expected.items.map((s) => s.id)}; have '
          '${listRows()}',
        );
        expect(listRows(), contains(id1));
        final facilities = expected.items.map((s) => s.facilityId).toList();
        expect(
          facilities.toSet().length,
          facilities.length,
          reason: 'more than one row per facility',
        );
        note('folio $serial: ${expected.items.length} row(s)');
      });

      // ---- 10: marks --------------------------------------------------------
      await step(
        '10a approved: unmark a line, reopen: still unmarked',
        () async {
          final id = id1 ?? (throw TestFailure('step 2 created nothing'));
          final lineId = line1 ?? (throw TestFailure('step 3 added no line'));
          final before = (await requests.get(id)).lines.single.toPurchase;
          expect(before, isTrue, reason: 'a new line starts marked');
          await openDetail(id);
          final mark = byKey(
            'purchase_request_line_to_purchase_${lineId}_true',
          );
          await pumpUntil(mark);
          expect(tester.widget(mark), isA<Checkbox>());
          await tapFinder(mark);
          await pumpUntil(
            byKey('purchase_request_line_to_purchase_${lineId}_false'),
          );
          await openDetail(id);
          await pumpUntil(
            byKey('purchase_request_line_to_purchase_${lineId}_false'),
          );
          expect((await requests.get(id)).lines.single.toPurchase, isFalse);
        },
      );

      int? draftWithLine;
      await step('10b draft: the Comprar marks are read-only', () async {
        final d = await apiDraft();
        draftWithLine = d.id;
        final r = await requests.addLine(d.id, productId: product.productId);
        final line = r.lines.single;
        await openDetail(d.id);
        final mark = byKey(
          'purchase_request_line_to_purchase_${line.id}_${line.toPurchase}',
        );
        await pumpUntil(mark);
        expect(tester.widget(mark), isNot(isA<Checkbox>()));
        expect(
          find.descendant(
            of: byKey('purchase_request_lines_table'),
            matching: find.byType(Checkbox),
          ),
          findsNothing,
        );
      });

      // ---- 11: cancel -------------------------------------------------------
      await step('11 cancel a draft and an approved request: Cancelada, no '
          'actions', () async {
        final draft =
            draftWithLine ?? (throw TestFailure('step 10b made no draft'));
        final id = id1 ?? (throw TestFailure('step 2 created nothing'));
        for (final target in [draft, id]) {
          await openDetail(target);
          final r = await requests.get(target);
          await tapKey('purchase_request_cancel');
          await pumpUntil(byKey('purchase_request_cancel_dialog'));
          expect(
            textOf('purchase_request_cancel_body'),
            r.status == PurchaseRequestStatus.draft
                ? l10n.purchaseRequestCancelDraftBody
                : l10n.purchaseRequestCancelBody('${r.serial}'),
          );
          await tapKey('purchase_request_cancel_submit');
          await pumpUntilGone(byKey('purchase_request_cancel_dialog'));
          await pumpUntil(inFacts(l10n.purchaseRequestStatusCancelled));
          expect(byKey('purchase_request_actions'), findsNothing);
          expect(
            (await requests.get(target)).status,
            PurchaseRequestStatus.cancelled,
          );
        }
      });

      // ---- 1b: qanoaccess has no Compras and no route ------------------------
      if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
        await container().read(authProvider.notifier).signOut();
        await login(_noAccessUser, _noAccessPass);
        await step(
          '1b qanoaccess: no Compras group, the routes redirect home',
          () async {
            expect(byKey('nav_group_purchases'), findsNothing);
            expect(byKey('nav_dest_purchase-requests'), findsNothing);
            expect(byKey('nav_dest_purchase-request-approval'), findsNothing);
            await go(_list);
            expect(location(), '/');
            expect(byKey('purchase_requests_table'), findsNothing);
            await go(_queue);
            expect(location(), '/');
          },
        );
      } else {
        note('1b SKIPPED: MBE_TEST_USERNAME/_PASSWORD not given');
      }
    } finally {
      // Leave dev clean: cancel anything this run left open.
      final left = <String>[];
      for (final id in created) {
        try {
          var r = await requests.get(id);
          if (r.status != PurchaseRequestStatus.cancelled) {
            r = await requests.cancel(id);
          }
          left.add('#$id ${r.status.name}');
        } on Object catch (e) {
          left.add('#$id NOT CANCELLED (${_short(e)})');
        }
      }
      note('cleanup: ${left.join(', ')}');
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
  }, timeout: const Timeout(Duration(minutes: 20)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
