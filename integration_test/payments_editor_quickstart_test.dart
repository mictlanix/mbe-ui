import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/outstanding_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

/// Automates specs/059-payments-editor/quickstart.md against the REAL app
/// (macOS desktop) and a live mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/payments_editor_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=...   (and _PASSWORD; administrator)
///     [--dart-define=MBE_WRITE=true]
///
/// **Read-only by default.** It checks that the new actions are on screen, in
/// the right places, and that the new surfaces fit at the largest text size.
/// With `MBE_WRITE=true` it also drives the real writes on a payment it
/// records itself: record a 1.00 credit payment, apply it to an outstanding
/// order, then reverse that application. Every order ends as it started;
/// **the new payment stays on the tenant** (a payment can't be deleted). The
/// seeded payment is never written to: a payment reversed off an order can't
/// be applied to it again (legacy `UNIQUE (sales_order, customer_payment)`).
///
/// Fixtures come from `tool/seed_payment_fixtures.py` (a payment applied to a
/// back-office order, and a second outstanding order of the same customer),
/// discovered at runtime. Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');

const _wide = Size(1400, 1000);
const _desktop = Size(1680, 1000);

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

  testWidgets('Payments editor walkthrough (real app, live mbe-api)', (
    tester,
  ) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }

    // ------------------------------------------------------------------
    // API side (independent of the app's own session)
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final payments = CustomerPaymentRepositoryImpl(dio);
    final orders = SalesOrderRepositoryImpl(dio);
    final customers = CustomerRepositoryImpl(dio);

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
      Duration timeout = const Duration(seconds: 30),
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
      timeout: timeout ?? const Duration(seconds: 30),
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
      await tester.tap(f.first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> tapKey(String k) => tapFinder(byKey(k));

    Future<void> login(String user, String pass) async {
      await pumpUntil(byKey('login_username_field'));
      await tester.enterText(byKey('login_username_field'), user);
      await tester.enterText(byKey('login_password_field'), pass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey('login_password_field'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilTrue(
        () => byKey('login_username_field').evaluate().isEmpty,
        'login finished',
        timeout: const Duration(seconds: 40),
      );
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> go(String path) async {
      router().go(path);
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> openPayment(int id) async {
      router().go('/sales/payments/$id');
      await pumpUntilTrue(
        () =>
            byKey('payment_summary_amount').evaluate().isNotEmpty &&
            !spinning(),
        'payment $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 800));
    }

    /// Closes whatever dialog a failed step left open.
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

    // ---- constitution §V: the largest text size, real fonts --------------
    // Checked here rather than in a widget test: only the live app renders
    // with the real fonts, and widget tests' placeholder font is far wider.
    final money = RegExp(r'^\$[\d,]+\.\d{2}( [A-Z]{3})?$');
    final dateText = RegExp(r'^\d{4}-\d{2}-\d{2}( \d{2}:\d{2})?$');
    List<String> clipped(Finder? within) {
      final cut = <String>{};
      final texts = within == null
          ? find.byType(Text)
          : find.descendant(of: within, matching: find.byType(Text));
      for (final element in texts.evaluate()) {
        final text = (element.widget as Text).data ?? '';
        if (!money.hasMatch(text) && !dateText.hasMatch(text)) continue;
        final paragraph = element.renderObject;
        if (paragraph is! RenderParagraph) continue;
        final needed = paragraph.getMaxIntrinsicWidth(double.infinity);
        if (paragraph.size.width + 0.5 < needed) {
          cut.add(
            '"$text" ${paragraph.size.width.toStringAsFixed(1)} of '
            '${needed.toStringAsFixed(1)}',
          );
        }
      }
      return cut.toList();
    }

    /// Runs [body] at the largest of the four text sizes on a desktop-width
    /// window, then puts both back. Fails on clipped money or dates, or on any
    /// framework (overflow) exception raised meanwhile.
    /// [within] limits the check to one surface, such as a dialog, so screens
    /// behind it don't count.
    Future<void> atLargestText(
      Future<void> Function() body, {
      Finder? within,
    }) async {
      final prefsController = container().read(
        userDisplayPreferencesControllerProvider.notifier,
      );
      await prefsController.setTextSizeLevel(TextSizeLevel.extraLarge);
      tester.view.physicalSize = _desktop;
      await pumpFor(const Duration(milliseconds: 800));
      try {
        await body();
        await pumpFor(const Duration(milliseconds: 500));
        final cut = clipped(within);
        final ex = tester.takeException();
        expect(cut, isEmpty, reason: 'clipped: ${cut.join('; ')}');
        expect(ex, isNull, reason: 'overflow: ${ex == null ? '' : _short(ex)}');
      } finally {
        await prefsController.setTextSizeLevel(TextSizeLevel.normal);
        tester.view.physicalSize = _wide;
        await pumpFor(const Duration(milliseconds: 500));
      }
    }

    // ------------------------------------------------------------------
    // Login (admin) and fixture discovery
    // ------------------------------------------------------------------
    note('logging in as admin${_write ? ' (WRITE mode)' : ' (read-only)'}');
    await login(_adminUser, _adminPass);
    final facilityId = container().read(userFacilityIdProvider);
    if (facilityId == null) {
      markTestSkipped('The admin account has no facility.');
      return;
    }

    // A back-office order with a live application, and a second outstanding
    // order of the same customer (see tool/seed_payment_fixtures.py).
    ({SalePayment application, int saleId, CustomerPayment payment})? seeded;
    final res = await dio.get<Map<String, dynamic>>(
      '/api/v1/sales-orders',
      queryParameters: {
        'origin': 1,
        'facility': facilityId,
        'status': 'completed',
        'limit': 50,
      },
    );
    for (final o in (res.data!['items'] as List).cast<Map>()) {
      final saleId = o['sales_order_id'] as int;
      final live = (await payments.listForOrder(
        saleId: saleId,
      )).where((a) => !a.cancelled).firstOrNull;
      if (live == null) continue;
      final payment = await payments.get(
        customerPaymentId: live.customerPayment,
      );
      if (payment.facilityId != facilityId) continue;
      seeded = (application: live, saleId: saleId, payment: payment);
      break;
    }
    if (seeded == null) {
      markTestSkipped(
        'No back-office order with an applied payment: run '
        'tool/seed_payment_fixtures.py.',
      );
      return;
    }
    final fixture = seeded;
    final paymentId = fixture.payment.customerPaymentId;
    final applicationId = fixture.application.id;
    final saleId = fixture.saleId;

    OutstandingOrder? spare;
    final outstanding = await payments.listOutstandingOrders(
      customerId: fixture.payment.customerId,
      limit: 100,
    );
    for (final o in outstanding.items) {
      if (o.id != saleId &&
          o.currency == fixture.payment.currency &&
          compareAmounts(o.balance, '0') > 0) {
        spare = o;
        break;
      }
    }
    note(
      'facility $facilityId; payment $paymentId, application $applicationId, '
      'order $saleId; spare order ${spare?.id}',
    );

    // ---- 1: record button and form validation (US2) ----------------------
    await step(
      '1 Pagos offers "Registrar pago"; an empty form is refused',
      () async {
        await go('/sales/payments');
        await pumpUntil(byKey('payments_record_button'));
        await tapKey('payments_record_button');
        await pumpUntil(byKey('record_payment_dialog'));
        await tapKey('record_payment_save');
        await pumpUntil(find.text('Elige un cliente.'));
        expect(find.text('Elige un método de pago.'), findsOneWidget);
        expect(find.text('Escribe un monto mayor que cero.'), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await pumpUntilGone(byKey('record_payment_dialog'));
      },
    );

    // ---- 2: the payment view's actions (US1) -----------------------------
    await step('2 payment view: reverse on the live application', () async {
      await openPayment(paymentId);
      expect(
        byKey('payment_application_reverse_$applicationId'),
        findsOneWidget,
      );
      final fullyApplied =
          compareAmounts(fixture.payment.unapplied, '0.01') <= 0;
      expect(
        byKey('payment_apply_button').evaluate().isEmpty,
        fullyApplied,
        reason:
            '"Aplicar a pedido" shows only while money is left unapplied '
            '(unapplied ${fixture.payment.unapplied})',
      );
    });

    // ---- 3: Pedidos "Pagos" (US3) ---------------------------------------
    await step(
      '3 Pedidos: "Pagos" lists the application and opens its payment',
      () async {
        await go('/sales/orders/$saleId');
        await pumpUntil(byKey('sales_order_payments_button'));
        await tapKey('sales_order_payments_button');
        await pumpUntil(byKey('sales_order_payments_dialog'));
        await pumpUntil(byKey('applied_payment_$applicationId'));
        await tapKey('applied_payment_open_$paymentId');
        await pumpUntilTrue(
          () => location() == '/sales/payments/$paymentId',
          'on the payment view',
        );
      },
    );

    // ---- 4: largest text size on the new surfaces (constitution §V) ------
    await step(
      '4a largest text: payment view and its reverse column fit',
      () async {
        await atLargestText(() async {
          await openPayment(paymentId);
        });
      },
    );

    await step('4b largest text: record dialog fits', () async {
      await go('/sales/payments');
      await tapKey('payments_record_button');
      await pumpUntil(byKey('record_payment_dialog'));
      await atLargestText(() async {
        await tapKey('record_payment_save');
        await pumpFor(const Duration(milliseconds: 600));
      }, within: find.byType(Dialog));
      await tester.tap(find.text('Cancelar'));
      await pumpUntilGone(byKey('record_payment_dialog'));
    });

    await step('4c largest text: Pedidos payments dialog fits', () async {
      await go('/sales/orders/$saleId');
      await tapKey('sales_order_payments_button');
      await pumpUntil(byKey('applied_payment_$applicationId'));
      await atLargestText(() async {
        await pumpFor(const Duration(milliseconds: 300));
      }, within: find.byType(Dialog));
      await tester.tap(byKey('sales_order_payments_close'));
      await pumpUntilGone(byKey('sales_order_payments_dialog'));
    });

    // ---- write steps (opt-in) --------------------------------------------
    // They work on a payment this run records, never on the seeded one: a
    // reversed application stays on record, and the server keeps one
    // application per payment and order (legacy `UNIQUE (sales_order,
    // customer_payment)`), so a payment reversed off an order can never be
    // applied to it again. Recording, applying and reversing a fresh payment
    // leaves every order as it was; only the new 1.00 payment remains.
    if (!_write) {
      note('MBE_WRITE is not set: skipping the steps that change data.');
    } else {
      int? recordedId;

      await step(
        '5 record a credit payment (UI): its view offers apply and ticket',
        () async {
          final customer = await customers.get(
            customerId: fixture.payment.customerId,
          );
          await go('/sales/payments');
          await tapKey('payments_record_button');
          await pumpUntil(byKey('record_payment_dialog'));

          await tester.enterText(
            find.descendant(
              of: byKey('record_payment_customer'),
              matching: find.byType(TextFormField),
            ),
            customer.code,
          );
          final option = find.text('${customer.code} — ${customer.name}');
          await pumpUntil(option);
          await tester.tap(option.last);
          await pumpFor(const Duration(milliseconds: 500));

          // The first method that is not cash, so no cash session is needed.
          await tapKey('record_payment_method');
          await pumpFor(const Duration(milliseconds: 500));
          final items = find.byType(DropdownMenuItem<int>).evaluate().toList();
          var pick = items.length > 1 ? 1 : 0;
          for (var i = 0; i < items.length; i++) {
            final text = find
                .descendant(
                  of: find.byWidget(items[i].widget),
                  matching: find.byType(Text),
                )
                .evaluate()
                .map((e) => (e.widget as Text).data ?? '')
                .join(' ')
                .toLowerCase();
            if (!text.contains('efectivo')) {
              pick = i;
              break;
            }
          }
          await tester.tap(find.byWidget(items[pick].widget).last);
          await pumpFor(const Duration(milliseconds: 500));

          await tester.enterText(
            byKey('record_payment_reference'),
            'QA059-${DateTime.now().millisecondsSinceEpoch % 100000}',
          );
          await tester.enterText(byKey('record_payment_amount'), '1.00');
          await pumpFor(const Duration(milliseconds: 300));
          await tapKey('record_payment_save');

          await pumpUntilTrue(
            () =>
                location().startsWith('/sales/payments/') &&
                location() != '/sales/payments/$paymentId',
            'on the new payment',
            timeout: const Duration(seconds: 40),
          );
          final id = int.parse(location().split('/').last);
          recordedId = id;
          await pumpUntil(byKey('payment_summary_amount'));
          final created = await payments.get(customerPaymentId: id);
          expect(created.type, PaymentType.creditPayment);
          expect(compareAmounts(created.amount, '1'), 0);
          expect(compareAmounts(created.unapplied, '1'), 0);
          expect(byKey('payment_apply_button'), findsOneWidget);
          expect(byKey('payment_view_ticket_button'), findsOneWidget);
          note('recorded payment $id (stays on the tenant)');
        },
      );

      final target = spare;
      final id = recordedId;
      if (target == null || id == null) {
        note(
          'No spare outstanding order or no recorded payment: skipping '
          'apply and reverse.',
        );
      } else {
        late String balanceBefore;

        await step(
          '6 apply the new payment to an outstanding order (UI)',
          () async {
            await openPayment(id);
            await tapKey('payment_apply_button');
            await pumpUntil(byKey('apply_payment_dialog'));
            await pumpUntil(byKey('apply_payment_order_${target.id}'));
            await atLargestText(() async {
              await pumpFor(const Duration(milliseconds: 300));
            }, within: find.byType(Dialog));
            balanceBefore = (await orders.getById(
              saleId: target.id,
            )).balanceOrZero;
            await tapKey('apply_payment_order_${target.id}');
            await tapKey('apply_payment_confirm');
            await pumpUntilGone(byKey('apply_payment_dialog'));
            await pumpFor(const Duration(seconds: 1));

            final applied = await payments.get(customerPaymentId: id);
            expect(
              compareAmounts(applied.unapplied, '0.01') <= 0,
              isTrue,
              reason: 'nothing left unapplied: ${applied.unapplied}',
            );
            final after = (await orders.getById(
              saleId: target.id,
            )).balanceOrZero;
            expect(
              compareAmounts(subtractAmounts(balanceBefore, after), '1'),
              0,
              reason: 'order ${target.id}: $balanceBefore → $after',
            );
          },
        );

        await step(
          '7 reverse that application (UI): reason required, order restored',
          () async {
            final application = (await payments.listApplications(
              customerPaymentId: id,
            )).firstWhere((a) => !a.reversed && a.saleId == target.id);
            await openPayment(id);
            await tapKey('payment_application_reverse_${application.id}');
            await pumpUntil(byKey('reversal_reason_field'));
            expect(find.textContaining('#${target.id}'), findsWidgets);
            expect(
              tester
                  .widget<FilledButton>(byKey('reversal_reason_confirm'))
                  .enabled,
              isFalse,
              reason: 'no reason, no reversal',
            );
            await tester.enterText(
              byKey('reversal_reason_field'),
              'QA059 walkthrough',
            );
            await pumpFor(const Duration(milliseconds: 200));
            await tapKey('reversal_reason_confirm');
            await pumpUntilGone(byKey('reversal_reason_dialog'));
            await pumpFor(const Duration(seconds: 1));

            final freed = await payments.get(customerPaymentId: id);
            expect(compareAmounts(freed.unapplied, '1'), 0);
            final reversed = (await payments.listApplications(
              customerPaymentId: id,
            )).firstWhere((a) => a.id == application.id);
            expect(reversed.reversed, isTrue);
            final after = (await orders.getById(
              saleId: target.id,
            )).balanceOrZero;
            expect(
              compareAmounts(after, balanceBefore),
              0,
              reason: 'order ${target.id} back to $balanceBefore: $after',
            );
            expect(byKey('payment_apply_button'), findsOneWidget);
          },
        );
      }
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
