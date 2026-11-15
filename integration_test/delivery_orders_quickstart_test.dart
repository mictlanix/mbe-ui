import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/061-delivery-orders/quickstart.md against the REAL app
/// (macOS desktop) and a live mbe-api (research R12, task T040).
///
///   caffeinate -dimsu flutter test \
///     integration_test/delivery_orders_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=...   (and _PASSWORD; administrator)
///     [--dart-define=MBE_WRITE=true]
///
/// **Read-only by default.** "Órdenes de entrega" opens from the navigation,
/// the list loads, a status filter narrows it (or shows the empty state), and
/// the newest order's detail loads with its lines and history.
///
/// With `MBE_WRITE=true` it raises two draft delivery orders through the POS
/// repository (`DeliveryOrderRepository.create`), each from a completed
/// 1-unit sale it rings up itself (product pattern `clavo`, which the admin's
/// register can sell). On the delivery draft it edits the header, confirms
/// and cancels it through the UI and checks the history; on the pickup draft
/// it confirms, marks it ready and hands it over with a generated 1×1 PNG.
///
/// The photo goes through the dialog's real "Elegir archivo" button: the
/// native macOS open panel can't be driven, so `FilePicker.platform` is
/// replaced for the run by a picker that answers the generated PNG. Every
/// other part of the handover (fields, upload, proof section) is the real
/// one.
///
/// **Each write run leaves on the tenant:** one cancelled delivery order, one
/// picked-up order with the PNG as its proof, and the two 1-unit completed
/// sales they came from (quickstart.md accepts this). Requeue is not
/// automated: it needs a FAILED order, which only an itinerary produces
/// (quickstart step 9). Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');

/// A pattern the admin's register finds sellable stock for (`a` matches
/// nothing sellable on the dev tenant).
const _productPattern = 'clavo';

const _wide = Size(1400, 1000);
const _list = '/sales/delivery-orders';

enum _Outcome { pass, fail }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

/// Answers [bytes] as the one chosen file, in place of the native panel.
class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.bytes);

  final Uint8List bytes;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async => FilePickerResult([
    PlatformFile(name: 'qa061-proof.png', size: bytes.length, bytes: bytes),
  ]);
}

/// A real 1×1 PNG, drawn and encoded by the engine.
Future<Uint8List> _onePixelPng() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 1, 1),
    Paint()..color = const Color(0xFF2E7D32),
  );
  final image = await recorder.endRecording().toImage(1, 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Delivery orders walkthrough (real app, live mbe-api)', (
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
    final admin = DeliveryOrderAdminRepositoryImpl(dio);
    final destinations = DeliveryOrderRepositoryImpl(dio);
    final sales = SalesOrderRepositoryImpl(dio);
    final pointSales = PointSaleRepositoryImpl(dio);
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
      // Present first, then scrolled into view (the nav rail scrolls, and
      // "Órdenes de entrega" can sit below its fold), then hit-testable.
      await pumpUntil(f);
      await tester.ensureVisible(f.first);
      await pumpFor(const Duration(milliseconds: 300));
      await pumpUntil(f.hitTestable());
      await tester.tap(f.hitTestable().first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> tapKey(String k) => tapFinder(byKey(k));

    bool enabled(String key) =>
        tester.widget<FilledButton>(byKey(key)).onPressed != null;

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

    /// Waits for the list's table or its empty state.
    Future<void> waitForList() async {
      await pumpUntilTrue(
        () =>
            (byKey('delivery_orders_table').evaluate().isNotEmpty ||
                find.text(l10n.deliveryOrdersEmpty).evaluate().isNotEmpty) &&
            !spinning(),
        'the delivery-orders list loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// Status chips in the list's table, by status.
    Map<DeliveryOrderStatus, int> chipsInTable() => {
      for (final s in DeliveryOrderStatus.values)
        s: find
            .descendant(
              of: byKey('delivery_orders_table'),
              matching: byKey('delivery_order_status_chip_${s.name}'),
            )
            .evaluate()
            .length,
    };

    Finder chip(DeliveryOrderStatus s) =>
        byKey('delivery_order_status_chip_${s.name}');

    String serialShown() =>
        tester.widget<Text>(byKey('delivery_order_serial')).data ?? '';

    /// Opens order [id]'s detail and waits for its history.
    ///
    /// Hops via the list first: going from one detail address straight to
    /// another can keep the old page.
    Future<void> openDetail(int id) async {
      container().invalidate(deliveryOrderDetailControllerProvider(id));
      await go(_list);
      await go('$_list/$id');
      await pumpUntilTrue(
        () =>
            byKey('delivery_order_history').evaluate().isNotEmpty &&
            find
                .descendant(
                  of: byKey('delivery_order_history'),
                  matching: find.byType(LinearProgressIndicator),
                )
                .evaluate()
                .isEmpty &&
            !spinning(),
        'delivery order $id with its history',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// Waits until the screen's facts show [status] (after a write reloads).
    Future<void> waitForStatus(DeliveryOrderStatus status) => pumpUntilTrue(
      () => find
          .descendant(of: byKey('delivery_order_facts'), matching: chip(status))
          .evaluate()
          .isNotEmpty,
      'status ${status.name}',
    );

    /// Every event the server holds for [id] is a row of the history.
    Future<List<DeliveryOrderEvent>> expectHistoryMatches(int id) async {
      final events = await admin.events(id);
      await pumpUntilTrue(
        () => events.every(
          (e) => byKey('delivery_order_event_${e.id}').evaluate().isNotEmpty,
        ),
        'the ${events.length} history row(s) of order $id',
      );
      return events;
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
    // Login (admin) and what the API says the list holds
    // ------------------------------------------------------------------
    note('logging in as admin${_write ? ' (WRITE mode)' : ' (read-only)'}');
    await login(_adminUser, _adminPass);

    // The list opens on the active statuses (FR-003, mbe-api#312).
    final opening = await admin.list(
      statuses: DeliveryOrderStatus.active,
      limit: 20,
    );
    note(
      'list: ${opening.total} active delivery orders at the admin\'s '
      'facility',
    );

    // ---- 1: open from the navigation (US1-1) -----------------------------
    await step('1 "Órdenes de entrega" opens from the nav and loads', () async {
      final entry = byKey('nav_dest_delivery-orders');
      await pumpUntil(entry);
      expect(
        find.descendant(of: entry, matching: find.text(l10n.navDeliveryOrders)),
        findsOneWidget,
      );
      await tapFinder(entry);
      await pumpUntilTrue(() => location() == _list, 'the list route');
      await waitForList();
      if (opening.items.isEmpty) {
        expect(find.text(l10n.deliveryOrdersEmpty), findsOneWidget);
        return;
      }
      // Active statuses, newest first: the first page has the API's rows.
      final shown = chipsInTable().values.fold(0, (a, b) => a + b);
      expect(shown, opening.items.length, reason: 'rows on the first page');
      expect(byKey('delivery_orders_filter_button'), findsOneWidget);
    });

    // ---- 2: a status filter narrows the list (US1-3) ---------------------
    await step('2 a status filter narrows the list', () async {
      // A status the first page holds, so the narrowing is visible; any
      // status when the list is empty (then the empty state shows).
      final status = opening.items.isEmpty
          ? DeliveryOrderStatus.failed
          : opening.items.first.status;
      final label = deliveryOrderStatusLabel(l10n, status);
      await go(_list);
      await waitForList();
      await tapKey('delivery_orders_filter_button');
      await pumpUntil(byKey('delivery_orders_status_filter'));
      await tapKey('delivery_orders_status_filter');
      await pumpFor(const Duration(milliseconds: 600));
      await tester.tap(find.text(label).hitTestable().last);
      await pumpFor(const Duration(milliseconds: 800));
      expect(
        router().state.uri.queryParameters['status'],
        '${status.value}',
        reason: 'the filter is in the URL',
      );
      await tapKey('filter_sheet_apply_button');
      await waitForList();

      final filtered = await admin.list(statuses: [status], limit: 20);
      note('status ${status.name}: ${filtered.total} order(s)');
      if (filtered.items.isEmpty) {
        expect(find.text(l10n.deliveryOrdersEmpty), findsOneWidget);
        return;
      }
      await pumpUntilTrue(
        () => chipsInTable()[status] == filtered.items.length,
        '${filtered.items.length} ${status.name} row(s); '
        'have ${chipsInTable()}',
      );
      final others = chipsInTable().entries
          .where((e) => e.key != status && e.value > 0)
          .toList();
      expect(others, isEmpty, reason: 'only ${status.name} rows remain');
    });

    // ---- 3: an order's detail loads (US1-5, US5) -------------------------
    await step('3 a row opens the detail: facts, lines and history', () async {
      if (opening.items.isEmpty) {
        note('no delivery order at this facility: detail not checked');
        return;
      }
      final target = opening.items.first;
      await go(_list);
      await waitForList();
      await tester.tap(
        find
            .descendant(
              of: byKey('delivery_orders_table'),
              matching: find.byType(DeliveryOrderStatusChip),
            )
            .first,
      );
      await pumpUntilTrue(
        () => location() == '$_list/${target.id}',
        'the detail of order ${target.id} (at ${location()})',
      );
      await pumpUntil(byKey('delivery_order_history'));
      final order = await admin.getById(target.id);
      await pumpUntil(
        find.descendant(
          of: byKey('delivery_order_facts'),
          matching: chip(order.status),
        ),
      );
      expect(
        serialShown(),
        order.serial == null ? l10n.deliveryOrderDraftFolio : '${order.serial}',
      );
      expect(byKey('delivery_order_lines'), findsOneWidget);
      for (final line in order.lines) {
        expect(
          find.descendant(
            of: byKey('delivery_order_lines'),
            matching: find.text(line.productCode),
          ),
          findsWidgets,
          reason: 'line ${line.id} (${line.productCode})',
        );
      }
      final events = await expectHistoryMatches(order.id);
      note(
        'order ${order.id}: ${order.lines.length} line(s), '
        '${events.length} event(s)',
      );
      expect(byKey('delivery_order_events_error'), findsNothing);
      await tapFinder(
        find.byTooltip(
          MaterialLocalizations.of(
            tester.element(find.byType(Scaffold).last),
          ).backButtonTooltip,
        ),
      );
      await pumpUntilTrue(() => location() == _list, 'back on the list');
    });

    // ------------------------------------------------------------------
    // Writes (only with MBE_WRITE=true)
    // ------------------------------------------------------------------
    if (!_write) {
      note('MBE_WRITE is not set: skipping the steps that change data.');
    } else {
      final png = await _onePixelPng();
      final realPicker = FilePicker.platform;
      FilePicker.platform = _FakeFilePicker(png);
      addTearDown(() => FilePicker.platform = realPicker);

      ProductLookupResult? product;
      int? warehouse;

      /// Rings up a completed 1-unit sale at the admin's register and raises
      /// a draft of [type] from it through the POS repository.
      Future<int> raiseDraft(FulfillmentType type, String tag) async {
        final opened = await sales.open(origin: SaleOrigin.pointOfSale);
        if (opened.pointSale == null) {
          throw TestFailure('the admin has no point of sale to sell from');
        }
        warehouse ??= (await pointSales.get(
          pointSaleId: opened.pointSale!,
        )).warehouseId;
        product ??=
            (await sales.productLookup(
                  pattern: _productPattern,
                  customer: opened.customer,
                  warehouse: warehouse,
                ))
                .where(
                  (p) =>
                      compareAmounts(p.price, '0') > 0 &&
                      (!p.stockRequired ||
                          p.stock.any(
                            (s) =>
                                s.warehouse == warehouse &&
                                compareAmounts(s.available, '2') >= 0,
                          )),
                )
                .firstOrNull;
        if (product == null) {
          await sales.cancel(saleId: opened.id);
          throw TestFailure(
            'no sellable "$_productPattern" product in warehouse $warehouse',
          );
        }
        final withLine = await sales.addLine(
          saleId: opened.id,
          product: product!.product,
          quantity: '1',
          warehouse: warehouse,
        );
        final sale = await sales.confirm(saleId: withLine.id);
        expect(sale.status, SaleStatus.completed);
        final draft = await destinations.create(
          salesOrder: sale.id,
          fulfillmentType: type,
          comment: 'QA061 $tag',
        );
        note(
          'sale ${sale.id} (${product!.code} × 1) → '
          '${type.name} draft ${draft.id} (both stay on the tenant)',
        );
        return draft.id;
      }

      int? deliveryId;
      int? pickupId;

      await step('4 raise a delivery draft from a 1-unit sale; it opens as '
          'Borrador with one history line', () async {
        deliveryId = await raiseDraft(FulfillmentType.delivery, 'delivery');
        await openDetail(deliveryId!);
        await waitForStatus(DeliveryOrderStatus.draft);
        expect(serialShown(), l10n.deliveryOrderDraftFolio);
        expect(find.text(l10n.deliveryOrderTitleDraft), findsOneWidget);
        final events = await expectHistoryMatches(deliveryId!);
        expect(events, hasLength(1));
        expect(events.single.from, isNull);
        expect(events.single.to, DeliveryOrderStatus.draft);
        expect(byKey('delivery_order_edit_header'), findsOneWidget);
        expect(byKey('delivery_order_cancel'), findsOneWidget);
        expect(enabled('delivery_order_confirm'), isTrue);
      });

      final comment =
          'QA061 header ${DateTime.now().millisecondsSinceEpoch % 100000}';
      await step('5 edit the header: priority and comment stick', () async {
        final id = deliveryId ?? (throw TestFailure('step 4 raised nothing'));
        final before = await admin.getById(id);
        final priority = before.priority + 1;
        await tapKey('delivery_order_edit_header');
        await pumpUntil(byKey('delivery_order_header_dialog'));
        expect(
          enabled('delivery_order_header_save'),
          isFalse,
          reason: 'nothing changed yet',
        );
        await tester.enterText(
          byKey('delivery_order_header_priority'),
          '$priority',
        );
        await tester.enterText(byKey('delivery_order_header_comment'), comment);
        await pumpFor(const Duration(milliseconds: 300));
        expect(enabled('delivery_order_header_save'), isTrue);
        await tapKey('delivery_order_header_save');
        await pumpUntilGone(byKey('delivery_order_header_dialog'));
        await pumpUntil(
          find.descendant(
            of: byKey('delivery_order_detail_band'),
            matching: find.text(comment),
          ),
        );
        final after = await admin.getById(id);
        expect(after.priority, priority);
        expect(after.comment, comment);
        expect(after.status, DeliveryOrderStatus.draft);
      });

      await step(
        '6 confirm: the folio appears and the status moves on',
        () async {
          final id = deliveryId ?? (throw TestFailure('step 4 raised nothing'));
          await openDetail(id);
          await tapKey('delivery_order_confirm');
          await pumpUntil(byKey('delivery_order_confirm_dialog'));
          expect(byKey('delivery_order_confirm_summary'), findsOneWidget);
          await tapKey('delivery_order_confirm_submit');
          await pumpUntilGone(byKey('delivery_order_confirm_dialog'));
          await pumpUntilTrue(
            () => serialShown() != l10n.deliveryOrderDraftFolio,
            'a folio in place of Borrador',
          );
          final after = await admin.getById(id);
          expect(after.serial, isNotNull);
          expect(
            after.status,
            anyOf(
              DeliveryOrderStatus.inPreparation,
              DeliveryOrderStatus.pendingApproval,
            ),
          );
          await waitForStatus(after.status);
          expect(serialShown(), '${after.serial}');
          expect(
            find.text(l10n.deliveryOrderTitle('${after.serial}')),
            findsOneWidget,
          );
          expect(byKey('delivery_order_edit_header'), findsNothing);
          expect(byKey('delivery_order_add_line'), findsNothing);
          expect(byKey('delivery_order_confirm'), findsNothing);
          final events = await expectHistoryMatches(id);
          expect(events, hasLength(2));
          note(
            'order $id confirmed as folio ${after.serial} '
            '(${after.status.name})',
          );
        },
      );

      await step('7 cancel with a reason: Cancelada, and the reason in the '
          'history', () async {
        final id = deliveryId ?? (throw TestFailure('step 4 raised nothing'));
        final reason =
            'QA061 walkthrough ${DateTime.now().millisecondsSinceEpoch % 1000}';
        await tapKey('delivery_order_cancel');
        await pumpUntil(byKey('delivery_order_cancel_dialog'));
        expect(
          enabled('delivery_order_cancel_submit'),
          isFalse,
          reason: 'no reason, no cancel',
        );
        await tester.enterText(byKey('delivery_order_cancel_reason'), reason);
        await pumpFor(const Duration(milliseconds: 300));
        expect(enabled('delivery_order_cancel_submit'), isTrue);
        await tapKey('delivery_order_cancel_submit');
        await pumpUntilGone(byKey('delivery_order_cancel_dialog'));
        await waitForStatus(DeliveryOrderStatus.cancelled);
        expect(byKey('delivery_order_cancel'), findsNothing);
        final after = await admin.getById(id);
        expect(after.status, DeliveryOrderStatus.cancelled);
        final events = await expectHistoryMatches(id);
        final cancelled = events.lastWhere(
          (e) => e.to == DeliveryOrderStatus.cancelled,
        );
        expect(cancelled.reason, reason);
        await pumpUntil(byKey('delivery_order_event_reason_${cancelled.id}'));
        expect(
          tester
              .widget<Text>(
                byKey('delivery_order_event_reason_${cancelled.id}'),
              )
              .data,
          reason,
        );
      });

      await step(
        '8 pickup: confirm → Aprobada, ready → Lista para recoger',
        () async {
          pickupId = await raiseDraft(FulfillmentType.counterPickup, 'pickup');
          final id = pickupId!;
          await openDetail(id);
          await waitForStatus(DeliveryOrderStatus.draft);
          await tapKey('delivery_order_confirm');
          await pumpUntil(byKey('delivery_order_confirm_dialog'));
          await tapKey('delivery_order_confirm_submit');
          await pumpUntilGone(byKey('delivery_order_confirm_dialog'));
          await pumpUntilTrue(
            () => serialShown() != l10n.deliveryOrderDraftFolio,
            'a folio in place of Borrador',
          );
          final confirmed = await admin.getById(id);
          if (confirmed.status == DeliveryOrderStatus.pendingApproval) {
            throw TestFailure(
              'the tenant requires approval: the pickup waits in Pendiente de '
              'aprobación and cannot be marked ready here',
            );
          }
          expect(confirmed.status, DeliveryOrderStatus.approved);
          await waitForStatus(DeliveryOrderStatus.approved);

          await tapKey('delivery_order_ready');
          await pumpUntil(byKey('delivery_order_ready_dialog'));
          await tapKey('delivery_order_ready_submit');
          await pumpUntilGone(byKey('delivery_order_ready_dialog'));
          await waitForStatus(DeliveryOrderStatus.readyForPickup);
          expect(
            (await admin.getById(id)).status,
            DeliveryOrderStatus.readyForPickup,
          );
        },
      );

      await step('9 hand over with name, identification and a 1×1 PNG; the '
          'proof shows', () async {
        final id = pickupId ?? (throw TestFailure('step 8 raised nothing'));
        await openDetail(id);
        await waitForStatus(DeliveryOrderStatus.readyForPickup);
        await tapKey('delivery_order_pickup');
        await pumpUntil(byKey('delivery_order_pickup_dialog'));
        expect(enabled('delivery_order_pickup_submit'), isFalse);
        const receiver = 'QA061 Receptor';
        const idShown = 'INE QA061';
        await tester.enterText(byKey('delivery_order_pickup_name'), receiver);
        await tester.enterText(byKey('delivery_order_pickup_id'), idShown);
        await pumpFor(const Duration(milliseconds: 300));
        expect(
          enabled('delivery_order_pickup_submit'),
          isFalse,
          reason: 'no photo yet',
        );
        // The real button; FilePicker.platform answers the generated PNG.
        await tapKey('delivery_order_pickup_choose_file');
        await pumpUntil(byKey('delivery_order_pickup_file_name'));
        expect(enabled('delivery_order_pickup_submit'), isTrue);
        await tapKey('delivery_order_pickup_submit');
        await pumpUntilGone(byKey('delivery_order_pickup_dialog'));
        await waitForStatus(DeliveryOrderStatus.pickedUp);
        await pumpUntil(byKey('delivery_order_proof_receiver'));
        expect(
          tester.widget<Text>(byKey('delivery_order_proof_receiver')).data,
          receiver,
        );
        expect(
          tester.widget<Text>(byKey('delivery_order_proof_id_shown')).data,
          idShown,
        );
        await pumpUntilTrue(
          () =>
              byKey('delivery_order_proof_photo').evaluate().isNotEmpty ||
              byKey('delivery_order_proof_failed').evaluate().isNotEmpty,
          'the proof photo',
        );
        expect(byKey('delivery_order_proof_failed'), findsNothing);
        final proof = await admin.proof(id);
        expect(proof.receiverName, receiver);
        expect(proof.receiverIdShown, idShown);
        expect((await admin.getById(id)).status, DeliveryOrderStatus.pickedUp);
        expect(
          byKey('delivery_order_actions'),
          findsNothing,
          reason: 'a picked-up order offers no action',
        );
      });

      note('cancelled: $deliveryId, picked up: $pickupId');
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
