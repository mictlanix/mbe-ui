import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:decimal/decimal.dart';
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
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_pickers.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/075-delivery-itineraries/quickstart.md against the REAL app
/// (macOS desktop) and a live mbe-api (task T036).
///
///   caffeinate -dimsu flutter test \
///     integration_test/delivery_itineraries_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env [--dart-define=MBE_WRITE=true]
///
/// Without `caffeinate` a macOS run can stall silently. `MBE_POS_*` is the
/// administrator.
///
/// **Read-only by default:** "Itinerarios" opens from the Logística group
/// after "Por entregar", and the list loads.
///
/// With `MBE_WRITE=true` it makes its own fixtures: two completed 1-unit
/// sales at the admin's register (product pattern `clavo`), a delivery order
/// raised from each through the POS repository, confirmed (and approved when
/// approval is on) so both stand En preparación. Then, through the UI:
/// "Nuevo itinerario" with a vehicle and an operator (step 2), the same
/// vehicle refused for a second trip (3), two stops, "Cargar todo" and a
/// partial "Cargar línea" (4), ✎ and 🗑 (5), "Dar salida" (7), printing (8),
/// closing stop 1 with an image (9) and stop 2 with a drawn signature and a
/// shortfall (10), the trip closing itself, and cancelling a second trip
/// (12). Steps 1, 6, 11 and 13 are covered by the read-only part, the widget
/// tests and the large-text test.
///
/// The image goes through the dialog's real "Elegir imagen" button: the
/// native macOS open panel can't be driven, so `FilePicker.platform` is
/// replaced for the run by a picker that answers a generated PNG.
///
/// **Each write run leaves on the tenant:** two 1-unit completed sales, one
/// delivered and one partially delivered order (with its child order), one
/// closed trip and one cancelled trip, tagged `QA075` where a comment exists.
/// Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');

const _productPattern = 'clavo';
const _wide = Size(1400, 1000);
const _list = '/sales/delivery-itineraries';

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
    PlatformFile(name: 'qa075-nota.png', size: bytes.length, bytes: bytes),
  ]);
}

/// A real PNG, drawn and encoded by the engine.
Future<Uint8List> _png() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 64, 64),
    Paint()..color = const Color(0xFF2E7D32),
  );
  final image = await recorder.endRecording().toImage(64, 64);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Delivery itineraries walkthrough (real app, live mbe-api)', (
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
    final itineraries = DeliveryItineraryRepositoryImpl(dio);
    final admin = DeliveryOrderAdminRepositoryImpl(dio);
    final destinations = DeliveryOrderRepositoryImpl(dio);
    final sales = SalesOrderRepositoryImpl(dio);
    final pointSales = PointSaleRepositoryImpl(dio);
    final vehicles = VehicleRepositoryImpl(dio);
    final operators = VehicleOperatorRepositoryImpl(dio);
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

    Future<void> waitForList() => pumpUntilTrue(
      () =>
          (byKey('delivery_itineraries_table').evaluate().isNotEmpty ||
              find.text(l10n.itinerariesEmpty).evaluate().isNotEmpty) &&
          !spinning(),
      'the itineraries list loaded',
    );

    /// Opens trip [id] and waits for its facts.
    Future<void> openTrip(int id) async {
      container().invalidate(deliveryItineraryDetailControllerProvider(id));
      await go(_list);
      await go('$_list/$id');
      await pumpUntilTrue(
        () => byKey('itinerary_facts').evaluate().isNotEmpty && !spinning(),
        'trip $id',
      );
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> waitForTripStatus(ItineraryStatus status) => pumpUntilTrue(
      () => find
          .descendant(
            of: byKey('itinerary_facts'),
            matching: byKey('itinerary_status_chip_${status.name}'),
          )
          .evaluate()
          .isNotEmpty,
      'trip status ${status.name}',
    );

    /// Types [text] into a catalog picker and taps the [option] it offers.
    Future<void> pick(String pickerKey, String text, String option) async {
      final field = find.descendant(
        of: byKey(pickerKey),
        matching: find.byType(TextField),
      );
      await pumpUntil(field);
      await tester.enterText(field, text);
      final suggestion = find.text(option).hitTestable();
      await pumpUntil(suggestion);
      await tester.tap(suggestion.last);
      await pumpFor(const Duration(milliseconds: 500));
    }

    /// Taps the confirm of the prompt on screen and waits for it to close.
    Future<void> confirmPrompt() async {
      await tapKey('itinerary_confirm_submit');
      await pumpUntilGone(byKey('itinerary_confirm_submit'));
      await pumpFor(const Duration(milliseconds: 500));
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
    // Login and the read-only part
    // ------------------------------------------------------------------
    note('logging in as admin${_write ? ' (WRITE mode)' : ' (read-only)'}');
    await login(_adminUser, _adminPass);

    await step('1 "Itinerarios" is in Logística after "Por entregar", and '
        'the list loads', () async {
      final entry = byKey('nav_dest_delivery-itineraries');
      await pumpUntil(entry);
      expect(
        find.descendant(
          of: entry,
          matching: find.text(l10n.navDeliveryItineraries),
        ),
        findsOneWidget,
      );
      final forDelivery = tester.getTopLeft(byKey('nav_dest_for-delivery'));
      expect(
        tester.getTopLeft(entry).dy,
        greaterThan(forDelivery.dy),
        reason: 'after "Por entregar"',
      );
      await tapFinder(entry);
      await pumpUntilTrue(() => location() == _list, 'the list route');
      await waitForList();
      expect(byKey('delivery_itineraries_new'), findsOneWidget);
      expect(byKey('delivery_itineraries_filter_button'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Writes (only with MBE_WRITE=true)
    // ------------------------------------------------------------------
    if (!_write) {
      note('MBE_WRITE is not set: skipping the steps that change data.');
    } else {
      final png = await _png();
      final realPicker = FilePicker.platform;
      FilePicker.platform = _FakeFilePicker(png);
      addTearDown(() => FilePicker.platform = realPicker);

      ProductLookupResult? product;
      int? warehouse;

      /// A delivery order En preparación, from a completed 1-unit sale.
      Future<int> raiseOrder(String tag) async {
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
          fulfillmentType: FulfillmentType.delivery,
          comment: 'QA075 $tag',
        );
        var order = await admin.confirm(draft.id);
        if (order.status == DeliveryOrderStatus.pendingApproval) {
          order = await admin.approve(draft.id);
        }
        expect(order.status, DeliveryOrderStatus.inPreparation);
        note('sale ${sale.id} → order ${order.id} (serial ${order.serial})');
        return order.id;
      }

      final orderIds = <int>[];
      Vehicle? vehicle;
      VehicleOperator? operator;
      int? tripId;

      await step('fixtures: two orders En preparación, a free vehicle and an '
          'operator', () async {
        orderIds.add(await raiseOrder('A'));
        orderIds.add(await raiseOrder('B'));
        final page = await vehicles.list(
          status: EntityStatus.active,
          limit: 50,
        );
        for (final v in page.items) {
          final open = await itineraries.list(
            status: ItineraryStatus.open,
            vehicleId: v.vehicleId,
            limit: 1,
          );
          if (open.total == 0) {
            vehicle = v;
            break;
          }
        }
        operator = (await operators.list(
          status: EntityStatus.active,
          limit: 5,
        )).items.firstOrNull;
        if (vehicle == null || operator == null) {
          throw TestFailure(
            'needs an active vehicle with no open trip and an '
            'active operator',
          );
        }
        note(
          'vehicle ${vehicle!.vehicleId}, operator '
          '${operator!.vehicleOperatorId}',
        );
      });

      final serials = <int, int>{};
      for (final id in orderIds) {
        serials[id] = (await admin.getById(id)).serial ?? id;
      }

      await step('2 "Nuevo itinerario" with a vehicle and an operator opens '
          'the trip as Abierto', () async {
        if (vehicle == null) throw TestFailure('no fixtures');
        await go(_list);
        await waitForList();
        await tapKey('delivery_itineraries_new');
        await pumpUntil(byKey('new_itinerary_dialog'));
        await pick(
          'new_itinerary_vehicle',
          vehicle!.nickname,
          vehicleOptionLabel(vehicle!),
        );
        await pick(
          'new_itinerary_operator',
          // A prefix, so the field's own text never matches the suggestion.
          operator!.driverName.substring(
            0,
            operator!.driverName.length.clamp(1, 4),
          ),
          operator!.driverName,
        );
        await tapKey('new_itinerary_submit');
        await pumpUntilTrue(
          () => location().startsWith('$_list/'),
          'the new trip opens',
        );
        tripId = int.parse(location().split('/').last);
        await pumpUntil(byKey('itinerary_facts'));
        await waitForTripStatus(ItineraryStatus.open);
        final trip = await itineraries.getById(tripId!);
        expect(trip.vehicleId, vehicle!.vehicleId);
        expect(trip.vehicleOperatorId, operator!.vehicleOperatorId);
        note('trip $tripId');
      });

      await step('3 the same vehicle on a second trip is refused, naming the '
          'first', () async {
        if (tripId == null) throw TestFailure('step 2 made no trip');
        await go(_list);
        await waitForList();
        await tapKey('delivery_itineraries_new');
        await pumpUntil(byKey('new_itinerary_dialog'));
        await pick(
          'new_itinerary_vehicle',
          vehicle!.nickname,
          vehicleOptionLabel(vehicle!),
        );
        await tapKey('new_itinerary_submit');
        await pumpUntil(
          find.text(l10n.apiErrorVehicleOpenItineraryExists('$tripId')),
        );
        expect(byKey('new_itinerary_dialog'), findsOneWidget);
        await recover();
      });

      Future<ItineraryStop> stopFor(int orderId) async =>
          (await itineraries.getById(
            tripId!,
          )).stops.firstWhere((s) => s.deliveryOrderId == orderId);

      Future<void> addStop(int orderId) async {
        await tapKey('itinerary_add_stop');
        await pumpUntil(byKey('itinerary_add_stop_dialog'));
        final search = find.descendant(
          of: byKey('itinerary_add_stop_search'),
          matching: find.byType(TextField),
        );
        await tester.enterText(search, '${serials[orderId]}');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        final row = find
            .descendant(
              of: byKey('itinerary_add_stop_table'),
              matching: find.text('${serials[orderId]}'),
            )
            .hitTestable();
        await pumpUntil(row);
        await tester.tap(row.first);
        await pumpFor(const Duration(milliseconds: 300));
        await tapKey('itinerary_add_stop_submit');
        await pumpUntilGone(byKey('itinerary_add_stop_dialog'));
        await pumpFor(const Duration(milliseconds: 500));
      }

      await step('4 two stops: "Cargar todo" on A, half a line on B', () async {
        if (tripId == null) throw TestFailure('step 2 made no trip');
        await openTrip(tripId!);
        await addStop(orderIds[0]);
        final a = await stopFor(orderIds[0]);
        await tapKey('itinerary_stop_load_all_${a.id}');
        await confirmPrompt();
        await pumpUntil(byKey('itinerary_stop_lines_${a.id}'));

        await addStop(orderIds[1]);
        final b = await stopFor(orderIds[1]);
        final order = await admin.getById(orderIds[1]);
        final line = order.lines.first;
        await tapKey('itinerary_stop_load_line_${b.id}');
        await pumpUntil(byKey('itinerary_load_line_${line.id}'));
        await tapKey('itinerary_load_line_${line.id}');
        await tester.enterText(byKey('itinerary_load_line_quantity'), '0.5');
        await pumpFor(const Duration(milliseconds: 300));
        await tapKey('itinerary_load_line_submit');
        await pumpUntilGone(byKey('itinerary_load_line_dialog'));
        final loaded = (await stopFor(orderIds[1])).lines.single;
        expect(loaded.committed, Decimal.parse('0.5'));
        await pumpUntil(byKey('itinerary_line_edit_${loaded.id}'));
      });

      await step('5 ✎ raises the load to its maximum, 🗑 releases it, and it '
          'loads again', () async {
        final b = await stopFor(orderIds[1]);
        final line = b.lines.single;
        await tapKey('itinerary_line_edit_${line.id}');
        await pumpUntil(byKey('itinerary_adjust_dialog'));
        await tester.enterText(byKey('itinerary_adjust_quantity'), '2');
        await pumpFor(const Duration(milliseconds: 300));
        expect(
          enabled('itinerary_adjust_submit'),
          isFalse,
          reason: 'above open + loaded is refused in the field',
        );
        await tester.enterText(byKey('itinerary_adjust_quantity'), '1');
        await pumpFor(const Duration(milliseconds: 300));
        await tapKey('itinerary_adjust_submit');
        await pumpUntilGone(byKey('itinerary_adjust_dialog'));
        expect(
          (await stopFor(orderIds[1])).lines.single.committed,
          Decimal.one,
        );

        await tapKey('itinerary_line_release_${line.id}');
        await confirmPrompt();
        await pumpUntil(byKey('itinerary_stop_empty_${b.id}'));
        // Step 6's guard: an empty stop keeps "Dar salida" disabled.
        expect(enabled('itinerary_depart'), isFalse);
        expect(byKey('itinerary_depart_guard'), findsOneWidget);

        final orderLine = (await admin.getById(orderIds[1])).lines.first;
        await tapKey('itinerary_stop_load_line_${b.id}');
        await pumpUntil(byKey('itinerary_load_line_${orderLine.id}'));
        await tapKey('itinerary_load_line_${orderLine.id}');
        await tapKey('itinerary_load_line_submit');
        await pumpUntilGone(byKey('itinerary_load_line_dialog'));
        await pumpUntilTrue(() => enabled('itinerary_depart'), 'can depart');
      });

      await step('7 "Dar salida": En ruta, sent fixed, orders En tránsito, no '
          'edit left', () async {
        await tapKey('itinerary_depart');
        await pumpUntil(byKey('itinerary_depart_summary'));
        await confirmPrompt();
        await waitForTripStatus(ItineraryStatus.departed);
        for (final k in [
          'itinerary_edit_header',
          'itinerary_add_stop',
          'itinerary_depart',
        ]) {
          expect(byKey(k), findsNothing, reason: k);
        }
        for (final id in orderIds) {
          expect(
            (await admin.getById(id)).status,
            DeliveryOrderStatus.inTransit,
          );
        }
      });

      await step('8 both print buttons open the preview', () async {
        for (final k in ['itinerary_print_ticket', 'itinerary_print_notes']) {
          await tapKey(k);
          await pumpUntil(find.byType(DocumentPreviewDialog));
          await pumpFor(const Duration(seconds: 1));
          await recover();
        }
      });

      await step('9 close stop A with an uploaded image: Entregada', () async {
        final a = await stopFor(orderIds[0]);
        await tapKey('itinerary_stop_close_${a.id}');
        await pumpUntil(byKey('itinerary_close_dialog'));
        await tester.enterText(byKey('itinerary_close_name'), 'QA075 recibe');
        await tester.enterText(byKey('itinerary_close_id'), 'INE QA075');
        await tapKey('itinerary_close_choose_image');
        await pumpUntil(byKey('itinerary_close_image_name'));
        await pumpUntilTrue(() => enabled('itinerary_close_submit'), 'ready');
        await tapKey('itinerary_close_submit');
        await pumpUntilGone(byKey('itinerary_close_dialog'));
        await pumpUntil(byKey('stop_outcome_chip_delivered'));
        expect(
          (await admin.getById(orderIds[0])).status,
          DeliveryOrderStatus.delivered,
        );
      });

      await step('10 close stop B with a signature and a shortfall: the trip '
          'closes itself', () async {
        final b = await stopFor(orderIds[1]);
        final line = b.lines.single;
        await tapKey('itinerary_stop_close_${b.id}');
        await pumpUntil(byKey('itinerary_close_dialog'));
        await tester.enterText(byKey('itinerary_close_name'), 'QA075 firma');
        await tester.enterText(byKey('itinerary_close_id'), 'INE QA075');
        await tester.enterText(
          byKey('itinerary_close_delivered_${line.id}'),
          '0.5',
        );
        await pumpFor(const Duration(milliseconds: 300));
        await tapFinder(find.text(l10n.itineraryCloseProofSignature));
        final pad = byKey('signature_pad');
        await pumpUntil(pad);
        expect(
          enabled('itinerary_close_submit'),
          isFalse,
          reason: 'no reason and no signature yet',
        );
        final start = tester.getTopLeft(pad) + const Offset(40, 40);
        final gesture = await tester.startGesture(start);
        for (var i = 0; i < 10; i++) {
          await gesture.moveBy(const Offset(25, 6));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await gesture.up();
        await tapKey('itinerary_close_reason_${line.id}');
        await tapFinder(find.text(l10n.itineraryReasonDamagedGoods).last);
        await pumpUntilTrue(() => enabled('itinerary_close_submit'), 'ready');
        await tapKey('itinerary_close_submit');
        await pumpUntilGone(byKey('itinerary_close_dialog'));
        await waitForTripStatus(ItineraryStatus.closed);
        final trip = await itineraries.getById(tripId!);
        expect(trip.returnedAt, isNotNull);
        expect(
          trip.stops.firstWhere((s) => s.id == b.id).outcome,
          StopOutcome.partiallyDelivered,
        );
        expect(
          (await admin.getById(orderIds[1])).status,
          DeliveryOrderStatus.partiallyDelivered,
        );
      });

      await step('12 a new trip is cancelled: Cancelado, no print', () async {
        await go(_list);
        await waitForList();
        await tapKey('delivery_itineraries_new');
        await pumpUntil(byKey('new_itinerary_dialog'));
        await tester.enterText(byKey('new_itinerary_comment'), 'QA075 cancel');
        await tapKey('new_itinerary_submit');
        await pumpUntilTrue(
          () =>
              location().startsWith('$_list/') &&
              location() != '$_list/$tripId',
          'the new trip opens',
        );
        await pumpUntil(byKey('itinerary_cancel'));
        await tapKey('itinerary_cancel');
        await confirmPrompt();
        await waitForTripStatus(ItineraryStatus.cancelled);
        expect(byKey('itinerary_cancelled_note'), findsOneWidget);
        expect(byKey('itinerary_print_ticket'), findsNothing);
      });

      note('orders: ${orderIds.join(', ')}; trip: $tripId');
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
