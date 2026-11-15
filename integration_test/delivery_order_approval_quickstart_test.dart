import 'dart:async';

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
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/delivery_order_approval_queue_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/delivery_order_approval_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/062-delivery-order-approval/quickstart.md against the REAL
/// app (macOS desktop) and a live mbe-api (research R11, task T026).
///
///   caffeinate -dimsu flutter test \
///     integration_test/delivery_order_approval_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=...   (and _PASSWORD; administrator)
///     [--dart-define=MBE_WRITE=true]
///
/// **Read-only by default.** "Aprobación de entregas" opens from the
/// navigation, and its rows are exactly the orders the API's approval queue
/// returns for the admin's facility (or the empty state when none).
///
/// With `MBE_WRITE=true` it raises a delivery draft and a pickup draft from
/// two completed 1-unit sales (product pattern `clavo`), confirms both through
/// the API, and **only if the server answers Pendiente de aprobación** drives
/// the rest through the UI: approve the delivery from its row, reject the
/// pickup from its row with a reason, then re-confirm the pickup and approve
/// it from its detail screen (opened by a row tap).
///
/// **The write part needs the server's `DELIVERY_ORDER_APPROVAL_REQUIRED` on.**
/// It is a deployment-wide setting that defaults to off, and the client can't
/// read it. When confirm doesn't land in Pendiente de aprobación the run
/// prints why and skips the write steps, which is **not** a pass for FR-009 or
/// FR-012: those need a server with approval on.
///
/// **Each write run leaves on the tenant:** one delivery order in En
/// preparación, one pickup order in Aprobada (it was rejected once on the
/// way), and the two 1-unit completed sales behind them. Credentials are never
/// printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');

/// A pattern the admin's register finds sellable stock for (`a` matches
/// nothing sellable on the dev tenant).
const _productPattern = 'clavo';

const _wide = Size(1400, 1000);
const _list = '/sales/delivery-orders';

enum _Outcome { pass, skip, fail }

/// Thrown by a step that can't run on this server: reported as SKIP, never as
/// PASS, so a run without approval on proves nothing it didn't check.
class _Skipped implements Exception {
  const _Skipped(this.why);
  final String why;
}

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Delivery order approval walkthrough (real app, live mbe-api)', (
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

    Future<void> pumpUntil(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isNotEmpty, '$f');

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
      await pumpUntilTrue(
        () => f.hitTestable().evaluate().isNotEmpty,
        'hit-testable: $f',
      );
      await tester.tap(f.hitTestable().first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> tapKey(String k) => tapFinder(byKey(k));

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

    /// Waits for the queue's table or its empty state.
    Future<void> waitForQueue() async {
      await pumpUntilTrue(
        () =>
            (byKey('delivery_order_approval_table').evaluate().isNotEmpty ||
                find
                    .text(l10n.deliveryOrderApprovalEmpty)
                    .evaluate()
                    .isNotEmpty) &&
            !spinning(),
        'the approval queue loaded',
      );
      await pumpFor(const Duration(milliseconds: 600));
    }

    /// Opens the queue fresh, so a write made through the API shows.
    Future<void> openQueue() async {
      container().invalidate(deliveryOrderApprovalQueueControllerProvider);
      await go(_list);
      await go(deliveryOrderApprovalPath);
      await waitForQueue();
    }

    /// Waits until the detail's facts show [status] (after a write reloads).
    Future<void> waitForStatus(DeliveryOrderStatus status) => pumpUntilTrue(
      () => find
          .descendant(
            of: byKey('delivery_order_facts'),
            matching: byKey('delivery_order_status_chip_${status.name}'),
          )
          .evaluate()
          .isNotEmpty,
      'status ${status.name}',
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
        await body();
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: ${_short(ex)}');
        results.add(_Result(name, _Outcome.pass, 'ok'));
      } on _Skipped catch (s) {
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

    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    // ------------------------------------------------------------------
    // Login (admin) and what the API says the queue holds
    // ------------------------------------------------------------------
    note('logging in as admin${_write ? ' (WRITE mode)' : ' (read-only)'}');
    await login(_adminUser, _adminPass);

    final opening = await admin.approvalQueue(limit: 20);
    note('queue: ${opening.total} order(s) waiting at the admin\'s facility');

    // ---- 1: open from the navigation (US1-1) -----------------------------
    await step(
      '1 "Aprobación de entregas" opens from the nav and loads',
      () async {
        final entry = byKey('nav_dest_delivery-order-approval');
        await pumpUntil(entry);
        expect(
          find.descendant(
            of: entry,
            matching: find.text(l10n.navDeliveryOrderApproval),
          ),
          findsOneWidget,
        );
        await tapFinder(entry);
        await pumpUntilTrue(
          () => location() == deliveryOrderApprovalPath,
          'the queue route (at ${location()})',
        );
        await waitForQueue();
      },
    );

    // ---- 2: the rows are the API's queue (US1-2) -------------------------
    await step('2 the rows are exactly what the API queue returns', () async {
      await openQueue();
      if (opening.items.isEmpty) {
        expect(find.text(l10n.deliveryOrderApprovalEmpty), findsOneWidget);
        note('queue is empty (approval may be off on this server)');
        return;
      }
      for (final o in opening.items) {
        expect(
          byKey('approve_delivery_order_${o.id}'),
          findsOneWidget,
          reason: 'approve icon of order ${o.id}',
        );
        expect(
          byKey('reject_delivery_order_${o.id}'),
          findsOneWidget,
          reason: 'reject icon of order ${o.id}',
        );
      }
      expect(
        find
            .descendant(
              of: byKey('delivery_order_approval_table'),
              matching: find.byIcon(Icons.check_circle_outline),
            )
            .evaluate()
            .length,
        opening.items.length,
        reason: 'one approve icon per row',
      );
    });

    // ------------------------------------------------------------------
    // Writes (only with MBE_WRITE=true)
    // ------------------------------------------------------------------
    if (!_write) {
      note('MBE_WRITE is not set: skipping the steps that change data.');
    } else {
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
          comment: 'QA062 $tag',
        );
        note(
          'sale ${sale.id} (${product!.code} × 1) → '
          '${type.name} draft ${draft.id} (both stay on the tenant)',
        );
        return draft.id;
      }

      int? deliveryId;
      int? pickupId;
      var approvalOn = false;

      await step('3 raise a delivery and a pickup draft and confirm both: '
          'with approval required they wait in the queue', () async {
        deliveryId = await raiseDraft(FulfillmentType.delivery, 'delivery');
        pickupId = await raiseDraft(FulfillmentType.counterPickup, 'pickup');
        final delivery = await admin.confirm(deliveryId!);
        final pickup = await admin.confirm(pickupId!);
        approvalOn =
            delivery.status == DeliveryOrderStatus.pendingApproval &&
            pickup.status == DeliveryOrderStatus.pendingApproval;
        note(
          'confirmed: delivery ${delivery.status.name}, '
          'pickup ${pickup.status.name}',
        );
        if (!approvalOn) {
          note(
            'approval is NOT required on this server '
            '(DELIVERY_ORDER_APPROVAL_REQUIRED is off): the approve and reject '
            'steps are skipped. This is not a pass for FR-009 or FR-012.',
          );
          return;
        }
        await openQueue();
        expect(byKey('approve_delivery_order_$deliveryId'), findsOneWidget);
        expect(byKey('approve_delivery_order_$pickupId'), findsOneWidget);
      });

      Future<void> whenApprovalOn(Future<void> Function() body) async {
        if (!approvalOn) {
          throw const _Skipped('approval is not required on this server');
        }
        await body();
      }

      await step('4 approve the delivery from its row: it goes to En '
          'preparación and leaves the queue', () async {
        await whenApprovalOn(() async {
          final id = deliveryId!;
          await openQueue();
          await tapKey('approve_delivery_order_$id');
          await pumpUntil(byKey('delivery_order_approve_dialog'));
          expect(
            find.text(l10n.deliveryOrderApproveNextDelivery),
            findsOneWidget,
          );
          await tapKey('delivery_order_approve_submit');
          await pumpUntilGone(byKey('delivery_order_approve_dialog'));
          await pumpUntilGone(byKey('approve_delivery_order_$id'));
          final after = await admin.getById(id);
          expect(after.status, DeliveryOrderStatus.inPreparation);
          final events = await admin.events(id);
          expect(events.last.from, DeliveryOrderStatus.pendingApproval);
          expect(events.last.to, DeliveryOrderStatus.inPreparation);
        });
      });

      final reason =
          'QA062 rechazo ${DateTime.now().millisecondsSinceEpoch % 100000}';
      await step('5 reject the pickup from its row with a reason: it is '
          'Borrador again and the reason is on the order', () async {
        await whenApprovalOn(() async {
          final id = pickupId!;
          await openQueue();
          await tapKey('reject_delivery_order_$id');
          await pumpUntil(byKey('delivery_order_reject_dialog'));
          final submit = byKey('delivery_order_reject_submit');
          expect(
            tester.widget<FilledButton>(submit).onPressed,
            isNull,
            reason: 'no reason yet',
          );
          await tester.enterText(byKey('delivery_order_reject_reason'), reason);
          await pumpFor(const Duration(milliseconds: 300));
          expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
          await tapKey('delivery_order_reject_submit');
          await pumpUntilGone(byKey('delivery_order_reject_dialog'));
          await pumpUntilGone(byKey('reject_delivery_order_$id'));
          final after = await admin.getById(id);
          expect(after.status, DeliveryOrderStatus.draft);
          expect(after.rejectionReason, reason);
          final events = await admin.events(id);
          expect(events.last.from, DeliveryOrderStatus.pendingApproval);
          expect(events.last.to, DeliveryOrderStatus.draft);
          expect(events.last.reason, reason);
        });
      });

      await step('6 re-confirm the pickup, open it from the queue and approve '
          'it on its detail screen: Aprobada', () async {
        await whenApprovalOn(() async {
          final id = pickupId!;
          final again = await admin.confirm(id);
          expect(again.status, DeliveryOrderStatus.pendingApproval);
          expect(
            again.rejectionReason,
            isNull,
            reason: 'confirming clears the stored reason',
          );
          await openQueue();
          // Tap the folio cell: the row tap pushes the order's own screen.
          await tester.tap(find.text('${again.serial}').hitTestable().first);
          await pumpUntilTrue(
            () => location() == '$_list/$id',
            'the detail of order $id (at ${location()})',
          );
          await pumpUntil(byKey('delivery_order_approve'));
          expect(byKey('delivery_order_reject'), findsOneWidget);
          await tapKey('delivery_order_approve');
          await pumpUntil(byKey('delivery_order_approve_dialog'));
          expect(
            find.text(l10n.deliveryOrderApproveNextPickup),
            findsOneWidget,
          );
          await tapKey('delivery_order_approve_submit');
          await pumpUntilGone(byKey('delivery_order_approve_dialog'));
          await waitForStatus(DeliveryOrderStatus.approved);
          expect(byKey('delivery_order_approve'), findsNothing);
          expect(
            (await admin.getById(id)).status,
            DeliveryOrderStatus.approved,
          );
          // Back returns to the queue, and the order is no longer in it.
          await tapFinder(
            find.byTooltip(
              MaterialLocalizations.of(
                tester.element(find.byType(Scaffold).last),
              ).backButtonTooltip,
            ),
          );
          await pumpUntilTrue(
            () => location() == deliveryOrderApprovalPath,
            'back on the queue (at ${location()})',
          );
          await waitForQueue();
          expect(byKey('approve_delivery_order_$id'), findsNothing);
        });
      });

      note('approved: delivery $deliveryId, pickup $pickupId');
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
