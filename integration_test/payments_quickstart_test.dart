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
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

/// Automates specs/054-payments-list-search/quickstart.md "Manual
/// walkthrough" (T045) against the REAL app (macOS desktop) and a live
/// mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/payments_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=...   (and _PASSWORD; administrator)
///     --dart-define=MBE_QA054_USERNAME=... (and _PASSWORD)
///
/// `MBE_QA054_*` is a non-administrator with Customer Payments read on a
/// facility and neither Payments Editor nor POS read, so one account covers
/// steps 8–10 (see test/integration/TEST_ACCOUNTS.md). Read-only: it creates
/// and changes nothing. Fixtures are discovered at runtime, in a bounded scan
/// of the facility's most recent payments. Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _qaUser = String.fromEnvironment('MBE_QA054_USERNAME');
const _qaPass = String.fromEnvironment('MBE_QA054_PASSWORD');

const _wide = Size(1400, 1000);
const _phone = Size(400, 900);

/// How many of the facility's newest payments the fixture scan reads.
const _scanSize = 200;

enum _Outcome { pass, fail, soft }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Payments quickstart walkthrough (real app, live mbe-api)', (
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
    Uri uri() => router().routerDelegate.currentConfiguration.uri;
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

    Future<void> pumpUntil(
      Finder f, {
      Duration timeout = const Duration(seconds: 30),
    }) => pumpUntilTrue(() => f.evaluate().isNotEmpty, '$f', timeout: timeout);

    Future<void> pumpUntilGone(
      Finder f, {
      Duration timeout = const Duration(seconds: 30),
    }) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f', timeout: timeout);

    Finder byKey(String k) => find.byKey(Key(k));
    Finder inTable(String text) =>
        find.descendant(of: byKey('payments_table'), matching: find.text(text));
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

    /// Every text rendered inside the payments table.
    List<String> tableTexts() => find
        .descendant(of: byKey('payments_table'), matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    /// Waits for the table (or the empty view) to settle on [expected]: each
    /// expected folio is shown, no folio outside it is, and every customer
    /// name has resolved (no "…" or "#id" placeholder).
    Future<void> expectRows(List<CustomerPayment> expected, String what) async {
      final ids = expected.map((p) => '${p.customerPaymentId}').toSet();
      await pumpUntilTrue(
        () {
          if (spinning()) return false;
          if (expected.isEmpty) {
            return byKey('payments_table').evaluate().isEmpty ||
                tableTexts().every((t) => !RegExp(r'^\d+$').hasMatch(t));
          }
          if (byKey('payments_table').evaluate().isEmpty) return false;
          final texts = tableTexts();
          return ids.every(texts.contains) &&
              texts.every((t) => t != '…' && !t.startsWith('#'));
        },
        '$what: rows ${ids.take(5)}…',
        timeout: const Duration(seconds: 60),
      );
    }

    int badgeCount() {
      final badge = tester.widget<Badge>(
        find.ancestor(
          of: byKey('payments_filter_button'),
          matching: find.byType(Badge),
        ),
      );
      if (!badge.isLabelVisible) return 0;
      return int.parse((badge.label! as Text).data!);
    }

    Future<void> login(String user, String pass) async {
      await pumpUntil(byKey('login_username_field'));
      await tester.enterText(byKey('login_username_field'), user);
      await tester.enterText(byKey('login_password_field'), pass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey('login_password_field'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilGone(
        byKey('login_username_field'),
        timeout: const Duration(seconds: 40),
      );
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> go(String path) async {
      router().go(path);
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> openDetail(int id) async {
      router().push('/sales/payments/$id');
      await pumpUntilTrue(
        () =>
            (byKey('payment_summary_amount').evaluate().isNotEmpty ||
                byKey('payment_not_found').evaluate().isNotEmpty) &&
            !spinning(),
        'payment $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 800));
    }

    Future<void> openDrawer() async {
      await tapKey('payments_filter_button');
      await pumpUntil(byKey('filter_sheet_apply_button'));
    }

    Future<void> closeDrawer() async {
      await tapKey('filter_sheet_apply_button');
      await pumpUntilGone(byKey('filter_sheet_apply_button'));
    }

    Future<void> recover() async {
      final close = byKey('filter_sheet_close_button');
      if (close.evaluate().isNotEmpty) {
        await tester.tap(close.first);
        await pumpFor(const Duration(milliseconds: 500));
      }
      for (var i = 0; i < 4; i++) {
        final dlg = find.byType(Dialog);
        if (dlg.evaluate().isEmpty) break;
        Navigator.of(tester.element(dlg.first), rootNavigator: true).pop();
        await pumpFor(const Duration(milliseconds: 400));
      }
      tester.takeException();
    }

    final results = <_Result>[];
    Future<void> step(
      String name,
      Future<void> Function() body, {
      bool soft = false,
    }) async {
      var note = '';
      try {
        await body();
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: ${_short(ex)}');
        results.add(_Result(name, _Outcome.pass, 'ok$note'));
      } catch (e) {
        try {
          final texts = find
              .byType(Text)
              .evaluate()
              .map((el) => (el.widget as Text).data ?? '')
              .where((t) => t.isNotEmpty)
              .take(40)
              .toList();
          // ignore: avoid_print
          print('QS-DBG loc=${uri()} texts=$texts');
        } catch (_) {}
        await recover();
        results.add(
          _Result(name, soft ? _Outcome.soft : _Outcome.fail, _short(e)),
        );
      }
      // ignore: avoid_print
      print(
        'QS-STEP ${results.last.outcome.name.toUpperCase()} '
        '${results.last.name} :: ${results.last.detail}',
      );
    }

    void softFinding(String name, String text) {
      results.add(_Result(name, _Outcome.soft, text));
      // ignore: avoid_print
      print('QS-STEP SOFT $name :: $text');
    }

    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    // ------------------------------------------------------------------
    // Login (admin) and fixture discovery
    // ------------------------------------------------------------------
    note('logging in as admin');
    await login(_adminUser, _adminPass);
    final facilityId = container().read(userFacilityIdProvider);
    if (facilityId == null) {
      markTestSkipped('The admin account has no facility.');
      return;
    }

    final scanned = <CustomerPayment>[];
    for (var skip = 0; skip < _scanSize; skip += 100) {
      final page = await payments.list(
        facilityId: facilityId,
        skip: skip,
        limit: 100,
      );
      scanned.addAll(page.items);
      if (page.items.length < 100) break;
    }
    final apps = <int, List<PaymentApplication>>{};
    for (var i = 0; i < scanned.length; i += 20) {
      final batch = scanned.skip(i).take(20).toList();
      final lists = await Future.wait(
        batch.map(
          (p) =>
              payments.listApplications(customerPaymentId: p.customerPaymentId),
        ),
      );
      for (var j = 0; j < batch.length; j++) {
        apps[batch[j].customerPaymentId] = lists[j];
      }
    }
    final withReversed = scanned.where(
      (p) => apps[p.customerPaymentId]!.any((a) => a.reversed),
    );
    final reversedPayment = withReversed.isEmpty ? null : withReversed.first;

    // An application to a register sale and one to a back-office order,
    // classified from the order's own recorded origin.
    ({int paymentId, int saleId})? posLink;
    ({int paymentId, int saleId})? officeLink;
    for (final p in scanned) {
      if (posLink != null && officeLink != null) break;
      for (final a in apps[p.customerPaymentId]!) {
        final sale = await orders.getById(saleId: a.saleId);
        final link = (paymentId: p.customerPaymentId, saleId: a.saleId);
        if (sale.origin == SaleOrigin.pointOfSale) posLink ??= link;
        if (sale.origin == SaleOrigin.backOffice) officeLink ??= link;
      }
    }

    // Register sales dominate recent payments, so look for a back-office
    // order the other way round: from the facility's completed ones.
    if (officeLink == null) {
      final res = await dio.get<Map<String, dynamic>>(
        '/api/v1/sales-orders',
        queryParameters: {
          'origin': 1,
          'facility': facilityId,
          'status': 'completed',
          'limit': 20,
        },
      );
      for (final o in (res.data!['items'] as List).cast<Map>()) {
        final saleId = o['sales_order_id'] as int;
        final paid = await payments.listForOrder(saleId: saleId);
        if (paid.isNotEmpty) {
          officeLink = (paymentId: paid.first.customerPayment, saleId: saleId);
          break;
        }
      }
    }

    // spec 055: a payment with a ticket (a credit payment or an advance) and
    // one without, for the ticket step.
    final ticketPayment = scanned.where((p) => p.type.hasTicket).firstOrNull;
    final noTicketPayment = scanned.where((p) => !p.type.hasTicket).firstOrNull;
    final nameSource = scanned.where((p) => p.customerName != null).firstOrNull;

    final withSession = scanned.where((p) => p.cashSessionId != null);
    final sessionPayment = withSession.isEmpty ? null : withSession.first;

    final otherFacility = (await payments.searchAcrossFacilities(
      limit: 100,
    )).items.where((p) => p.facilityId != facilityId).firstOrNull;

    final referenced = (await payments.searchAcrossFacilities(
      reference: '0',
      limit: 50,
    )).items.where((p) => (p.reference ?? '').trim().length >= 6).firstOrNull;

    note(
      'facility $facilityId; scanned ${scanned.length}; reversed '
      '${reversedPayment?.customerPaymentId}; pos $posLink; office '
      '$officeLink; other-facility ${otherFacility?.customerPaymentId}; '
      'reference ${referenced?.customerPaymentId}',
    );

    // ---- 1 ----
    await step(
      '1 Ventas → Pagos lists the facility, newest first, named',
      () async {
        await go('/sales/orders');
        await tapFinder(find.text('Pagos'));
        await pumpUntilTrue(
          () => location() == '/sales/payments',
          'on /sales/payments',
        );
        final expected = (await payments.list(facilityId: facilityId)).items;
        await expectRows(expected, 'page 1');
        final shown = tableTexts().where((t) => RegExp(r'^\d+$').hasMatch(t));
        expect(
          shown.take(expected.length).toList(),
          expected.map((p) => '${p.customerPaymentId}').toList(),
          reason: 'rows are in the server\'s newest-first order',
        );
        for (var i = 1; i < expected.length; i++) {
          expect(
            expected[i].date.isAfter(expected[i - 1].date),
            isFalse,
            reason: 'newest first',
          );
        }
      },
    );

    // ---- 1b (spec 055 T039) ----
    // Checked here rather than in a widget test: only the live app renders
    // with the real fonts, and widget tests' placeholder font is far wider.
    // Measured at the reviewer's desktop window (1680 wide); the narrower
    // walkthrough window is only reported, not asserted.
    List<String> wrapped() {
      final amount = RegExp(r'^\$[\d,]+\.\d{2} [A-Z]{3}$');
      final date = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$');
      final cut = <String>{};
      for (final element
          in find
              .descendant(
                of: byKey('payments_table'),
                matching: find.byType(Text),
              )
              .evaluate()) {
        final text = (element.widget as Text).data ?? '';
        if (!amount.hasMatch(text) && !date.hasMatch(text)) continue;
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

    await step('1b desktop width: amounts and dates fit on one line', () async {
      await go('/sales/payments');
      final expected = (await payments.list(facilityId: facilityId)).items;
      await expectRows(expected, 'page 1');
      note('at ${_wide.width.toInt()} wide, wrapped: ${wrapped().take(4)}');
      tester.view.physicalSize = const Size(1680, 1000);
      await pumpFor(const Duration(milliseconds: 800));
      final cut = wrapped();
      tester.view.physicalSize = _wide;
      await pumpFor(const Duration(milliseconds: 500));
      expect(cut, isEmpty, reason: cut.join('; '));
    });

    // ---- 2 ----
    final first = scanned.first;
    await step('2a customer filter narrows, badge 1', () async {
      final customer = await customers.get(customerId: first.customerId);
      await go('/sales/payments');
      await openDrawer();
      final field = find.descendant(
        of: byKey('payments_filter_customer'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(field, customer.code);
      final option = find.text('${customer.code} — ${customer.name}');
      await pumpUntilTrue(
        () => option.evaluate().isNotEmpty,
        'customer suggestion',
      );
      await tester.tap(option.last);
      await pumpFor(const Duration(milliseconds: 500));
      await closeDrawer();
      expect(uri().queryParameters['customer'], '${first.customerId}');
      await expectRows(
        (await payments.list(
          facilityId: facilityId,
          customerId: first.customerId,
        )).items,
        'customer',
      );
      expect(badgeCount(), 1);
    });

    await step(
      '2b date range picked in the dialog narrows; "Cualquier fecha" clears it',
      () async {
        // spec 055 FR-020: through the chip's own picker, not the address.
        // Days 1 and 2 of the current month are never after today, which the
        // picker would reject.
        final now = DateTime.now();
        final endDay = now.day >= 2 ? 2 : 1;
        String ymd(int day) =>
            '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${day.toString().padLeft(2, '0')}';

        await go('/sales/payments');
        await openDrawer();
        await tapKey('date_range_filter_chip');
        final dialog = find.byType(DateRangePickerDialog);
        await pumpUntil(dialog);
        await tester.tap(
          find.descendant(of: dialog, matching: find.text('1')).first,
        );
        await pumpFor(const Duration(milliseconds: 400));
        await tester.tap(
          find.descendant(of: dialog, matching: find.text('$endDay')).first,
        );
        await pumpFor(const Duration(milliseconds: 400));
        final save = MaterialLocalizations.of(
          tester.element(dialog),
        ).saveButtonLabel;
        await tester.tap(find.text(save));
        await pumpUntilGone(dialog);
        await closeDrawer();

        expect(uri().queryParameters['date-from'], ymd(1));
        expect(uri().queryParameters['date-to'], ymd(endDay));
        await expectRows(
          (await payments.list(
            facilityId: facilityId,
            dateFrom: DateTime(now.year, now.month, 1),
            dateTo: DateTime(now.year, now.month, endDay),
          )).items,
          'picked range',
        );
        expect(badgeCount(), 1);

        await openDrawer();
        await tapFinder(
          find.descendant(
            of: byKey('date_range_filter_chip'),
            matching: find.byIcon(Icons.close),
          ),
        );
        await closeDrawer();
        expect(uri().queryParameters.containsKey('date-from'), isFalse);
        expect(uri().queryParameters.containsKey('date-to'), isFalse);
        expect(badgeCount(), 0);
        await expectRows(
          (await payments.list(facilityId: facilityId)).items,
          'cleared range',
        );
      },
    );

    await step('2c Transferencia narrows, badge 1', () async {
      await go('/sales/payments');
      await openDrawer();
      await tapKey('payments_filter_method_null');
      await tapFinder(find.text('Transferencia electrónica de fondos').last);
      await pumpFor(const Duration(milliseconds: 500));
      await closeDrawer();
      expect(uri().queryParameters['method'], '${PaymentMethod.eft.code}');
      await expectRows(
        (await payments.list(
          facilityId: facilityId,
          methodCode: PaymentMethod.eft.code,
        )).items,
        'transfer',
      );
      expect(badgeCount(), 1);
    });

    await step('2d "Sin verificar" narrows, two facets count 2', () async {
      await openDrawer();
      await tapKey('payments_filter_verified_no');
      await pumpFor(const Duration(milliseconds: 500));
      await closeDrawer();
      expect(uri().queryParameters['verified'], 'false');
      await expectRows(
        (await payments.list(
          facilityId: facilityId,
          methodCode: PaymentMethod.eft.code,
          verified: false,
        )).items,
        'transfer + unverified',
      );
      expect(badgeCount(), 2);
    });

    if (sessionPayment == null) {
      softFinding('2e cash session', 'no scanned payment has a cash session');
    } else {
      await step('2e cash session found by typing its number', () async {
        final sid = sessionPayment.cashSessionId!;
        await go('/sales/payments');
        await openDrawer();
        final field = find.descendant(
          of: byKey('payments_filter_cash_session'),
          matching: find.byType(TextFormField),
        );
        await tester.ensureVisible(field);
        await tester.tap(field);
        await pumpFor(const Duration(milliseconds: 300));
        await tester.enterText(field, '$sid');
        // The picker's default option rows are plain text (no ListTile);
        // the typed "$sid" never carries the leading "#".
        final option = find.textContaining('#$sid · ');
        await pumpUntilTrue(
          () => option.evaluate().isNotEmpty,
          'session suggestion',
        );
        await tester.tap(option.first);
        await pumpFor(const Duration(milliseconds: 500));
        await closeDrawer();
        expect(uri().queryParameters['cash-session'], '$sid');
        await expectRows(
          (await payments.list(
            facilityId: facilityId,
            cashSessionId: sid,
          )).items,
          'cash session',
        );
        expect(badgeCount(), 1);
      });
    }

    // ---- 3 ----
    await step(
      '3 clearing returns the unfiltered list, not one shift',
      () async {
        await go('/sales/payments?method=3&verified=false');
        await openDrawer();
        await tapKey('filter_sheet_clear_all_button');
        await pumpFor(const Duration(milliseconds: 500));
        if (byKey('filter_sheet_apply_button').evaluate().isNotEmpty) {
          await closeDrawer();
        }
        expect(uri().queryParameters, isEmpty);
        final expected = (await payments.list(facilityId: facilityId)).items;
        await expectRows(expected, 'cleared');
        expect(badgeCount(), 0);
        final sessions = scanned.map((p) => p.cashSessionId).toSet();
        expect(
          sessions.length,
          greaterThan(1),
          reason: 'the facility list spans more than one cash session',
        );
      },
    );

    // ---- 4 ----
    if (reversedPayment == null) {
      softFinding(
        '4 reversed application',
        'none among the facility\'s newest ${scanned.length} payments',
      );
    } else {
      await step(
        '4 reversed row muted, "Revertida", excluded from Aplicado',
        () async {
          final id = reversedPayment.customerPaymentId;
          await openDetail(id);
          await pumpUntil(byKey('payment_applications_table'));
          final list = apps[id]!;
          expect(
            byKey('payment_chip_reversed'),
            findsNWidgets(list.where((a) => a.reversed).length),
          );
          final applied = paymentAmountLabel(
            container().read(formattersProvider),
            appliedTotal(list),
            reversedPayment.currency,
          );
          expect(
            find.descendant(
              of: byKey('payment_summary_applied'),
              matching: find.text(applied),
            ),
            findsOneWidget,
          );
          router().pop();
          await pumpFor(const Duration(milliseconds: 500));
        },
      );
    }

    // ---- 5 ----
    Future<void> orderLink(
      ({int paymentId, int saleId}) link,
      String prefix,
    ) async {
      await go('/sales/payments');
      await openDetail(link.paymentId);
      await tapKey('payment_order_link_${link.saleId}');
      await pumpUntilTrue(
        () => location() == '$prefix/${link.saleId}',
        'opened $prefix/${link.saleId} (at ${location()})',
      );
      await pumpFor(const Duration(seconds: 2));
      router().pop();
      await pumpFor(const Duration(milliseconds: 500));
    }

    if (posLink == null) {
      softFinding('5a POS sale link', 'no scanned application to a POS sale');
    } else {
      await step(
        '5a a POS sale opens in /sales/pos/:id',
        () => orderLink(posLink!, '/sales/pos'),
      );
    }
    // spec 055 FR-019: a missing back-office application is a failure, not a
    // skipped step — tool/seed_payment_fixtures.py creates it.
    await step('5b a back-office order opens in /sales/orders/:id', () async {
      if (officeLink == null) {
        throw TestFailure(
          'no payment on the tenant is applied to a back-office order — '
          'run tool/seed_payment_fixtures.py',
        );
      }
      await orderLink(officeLink, '/sales/orders');
    });

    // ---- 14 (spec 055 FR-021) ----
    await step('14 the ticket opens from the payment view and from the row, '
        'and is absent where the server has none', () async {
      if (ticketPayment == null) {
        throw TestFailure(
          'no credit payment or advance in the facility — '
          'run tool/seed_payment_fixtures.py',
        );
      }
      final id = ticketPayment.customerPaymentId;

      Future<void> previewShowsTicket() async {
        await pumpUntil(byKey('document_preview_pages'));
        // The title Text carries the key itself.
        expect(
          tester.widget<Text>(byKey('document_preview_title')).data,
          'Ticket de pago · #$id',
        );
        expect(byKey('document_print'), findsOneWidget);
        expect(byKey('document_download'), findsOneWidget);
        await tapKey('document_preview_close');
        await pumpUntilGone(byKey('document_preview_surface'));
      }

      // From the payment view.
      await go('/sales/payments');
      await openDetail(id);
      await tapKey('payment_view_ticket_button');
      await previewShowsTicket();
      router().pop();
      await pumpFor(const Duration(milliseconds: 500));

      // From the list row.
      await go('/sales/payments');
      await expectRows(
        (await payments.list(facilityId: facilityId)).items,
        'list before the row ticket',
      );
      await tapKey('payment_view_ticket_$id');
      await previewShowsTicket();

      // A payment without a ticket offers neither control.
      if (noTicketPayment == null) {
        throw TestFailure('no payment without a ticket in the facility');
      }
      final other = noTicketPayment.customerPaymentId;
      expect(byKey('payment_view_ticket_$other'), findsNothing);
      await openDetail(other);
      expect(byKey('payment_view_ticket_button'), findsNothing);
      router().pop();
      await pumpFor(const Duration(milliseconds: 500));
    });

    // ---- 15 (spec 055 FR-009) ----
    await step('15 customer-name search narrows the facility list', () async {
      final name = nameSource?.customerName;
      if (name == null || name.length < 4) {
        throw TestFailure('no payment with a customer name to search for');
      }
      // A fragment in a different letter case, from the middle of the name.
      final part = name.substring(1, name.length - 1).toUpperCase();
      await go('/sales/payments');
      await tester.enterText(
        find.descendant(
          of: byKey('payments_search_field'),
          matching: find.byType(TextField),
        ),
        part,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilTrue(
        () => uri().queryParameters['search'] == part,
        'search=$part',
      );
      final expected = (await payments.list(
        facilityId: facilityId,
        search: part,
      )).items;
      expect(expected, isNotEmpty, reason: 'the server finds "$part"');
      await expectRows(expected, 'customer-name search');
      for (final p in expected) {
        expect(
          p.customerName!.toLowerCase(),
          contains(part.toLowerCase()),
          reason: 'payment ${p.customerPaymentId}',
        );
      }
    });

    // ---- 6 / 7 ----
    if (referenced == null) {
      softFinding('6-7 reference search', 'no payment with a reference');
    } else {
      final ref = referenced.reference!.trim();
      final part = ref.substring(1, ref.length - 1);
      List<CustomerPayment> found = const [];
      await step('6 Todas las sucursales + reference search', () async {
        await go('/sales/payments');
        await tapFinder(find.text('Todas las sucursales'));
        await pumpUntilTrue(
          () => uri().queryParameters['scope'] == 'all',
          'scope=all',
        );
        final watch = Stopwatch()..start();
        await tester.enterText(byKey('payments_search_field'), part);
        await tester.testTextInput.receiveAction(TextInputAction.search);
        found = (await payments.searchAcrossFacilities(reference: part)).items;
        await expectRows(found, 'reference search');
        note('reference search shown in ${watch.elapsed.inMilliseconds} ms');
        expect(inTable('${referenced.customerPaymentId}'), findsOneWidget);
        expect(find.text('Sucursal'), findsWidgets);
        await openDrawer();
        expect(byKey('payments_filter_customer'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith(
                  'payments_filter_method_',
                ),
          ),
          findsNothing,
        );
        expect(byKey('payments_filter_verified_any'), findsNothing);
        expect(byKey('payments_filter_cash_session'), findsNothing);
        await closeDrawer();
      });

      await step('7 Back from a payment keeps mode, search and page', () async {
        final before = uri();
        await tapFinder(inTable('${referenced.customerPaymentId}'));
        await pumpUntil(byKey('payment_summary_amount'));
        final back = MaterialLocalizations.of(
          tester.element(find.byType(AppBar).last),
        ).backButtonTooltip;
        await tapFinder(find.byTooltip(back).last);
        await pumpUntilTrue(
          () => location() == '/sales/payments',
          'back on the list',
        );
        expect(uri().queryParameters, before.queryParameters);
        await expectRows(found, 'after Back');
      });
    }

    // ---- 11 (admin half) ----
    Finder writeActions() => find.byWidgetPredicate((w) {
      if (w is Text) {
        return const {
          'Verificar',
          'Rechazar',
          'Revertir',
          'Editar',
          'Aplicar',
          'Guardar',
        }.contains(w.data);
      }
      if (w is Icon) {
        return [
          Icons.edit,
          Icons.edit_outlined,
          Icons.delete,
          Icons.delete_outline,
          Icons.undo,
          Icons.verified,
        ].contains(w.icon);
      }
      return false;
    });

    await step('11a admin: no verify, reverse or edit anywhere', () async {
      await go('/sales/payments');
      await expectRows(
        (await payments.list(facilityId: facilityId)).items,
        'list',
      );
      expect(writeActions(), findsNothing);
      await openDetail((reversedPayment ?? first).customerPaymentId);
      expect(writeActions(), findsNothing);
      router().pop();
      await pumpFor(const Duration(milliseconds: 500));
    });

    // ---- 12 ----
    await step(
      '12 phone width: wraps and scrolls, nothing overflows',
      () async {
        tester.view.physicalSize = _phone;
        await go('/sales/payments');
        await expectRows(
          (await payments.list(facilityId: facilityId)).items,
          'phone list',
        );
        expect(tester.takeException(), isNull);
        await openDetail((reversedPayment ?? first).customerPaymentId);
        await pumpUntilTrue(
          () =>
              byKey('payment_applications_table').evaluate().isNotEmpty ||
              byKey('payment_applications_empty').evaluate().isNotEmpty,
          'applications',
        );
        expect(tester.takeException(), isNull);
        router().pop();
        tester.view.physicalSize = _wide;
        await pumpFor(const Duration(milliseconds: 500));
      },
    );

    // ---- 8–10 as the non-editor without POS read ----
    if (_qaUser.isEmpty || _qaPass.isEmpty) {
      softFinding('8-10 non-editor', 'MBE_QA054_USERNAME/_PASSWORD not set');
    } else {
      await container().read(authProvider.notifier).signOut();
      await login(_qaUser, _qaPass);
      final qaFacility = container().read(userFacilityIdProvider);

      await step(
        '8 non-editor: no mode switch; customer search only; ?scope=all '
        'ignored',
        () async {
          expect(qaFacility, isNotNull);
          await go('/sales/payments');
          final expected = (await payments.list(facilityId: qaFacility!)).items;
          await expectRows(expected, 'non-editor list');
          expect(byKey('payments_scope_switch'), findsNothing);
          // spec 055 FR-009: every reader of Pagos has the customer-name
          // search in the facility scope; the reference search stays an
          // all-facilities, Payments Editor feature.
          expect(byKey('payments_search_field'), findsOneWidget);
          expect(find.text('Buscar cliente…'), findsOneWidget);
          await go('/sales/payments?scope=all');
          await expectRows(expected, 'scope=all typed');
          expect(byKey('payments_scope_switch'), findsNothing);
          expect(byKey('payments_search_field'), findsOneWidget);
          expect(find.text('Buscar cliente…'), findsOneWidget);
          expect(find.text('Buscar referencia…'), findsNothing);
          expect(find.text('Sucursal'), findsNothing);
        },
      );

      if (otherFacility == null) {
        softFinding('9 other facility', 'no payment outside the facility');
      } else {
        await step('9 another facility\'s payment is "no existe"', () async {
          final id = otherFacility.customerPaymentId;
          await go('/sales/payments');
          await openDetail(id);
          expect(byKey('payment_not_found'), findsOneWidget);
          expect(find.text('El pago $id no existe.'), findsOneWidget);
          router().pop();
          await pumpFor(const Duration(milliseconds: 500));
        });
      }

      if (otherFacility == null) {
        softFinding(
          '9b server refuses another facility',
          'no payment outside the facility',
        );
      } else {
        // spec 055 FR-017, mbe-api#273: the server itself refuses what the
        // client already hides. By id it answers 404 (so the id's existence
        // isn't revealed), and the list with another facility answers 403.
        await step('9b the server refuses another facility\'s reads', () async {
          final qaDio = Dio(BaseOptions(baseUrl: apiBaseUrl));
          final qaToken = await AuthRepositoryImpl(
            qaDio,
          ).login(username: _qaUser, password: _qaPass);
          qaDio.options.headers['Authorization'] = 'Bearer $qaToken';
          Future<int?> statusOf(
            String path, [
            Map<String, dynamic>? query,
          ]) async => (await qaDio.get<Object?>(
            path,
            queryParameters: query,
            options: Options(validateStatus: (_) => true),
          )).statusCode;

          final id = otherFacility.customerPaymentId;
          final base = '/api/v1/customer-payments';
          expect(await statusOf('$base/$id'), 404, reason: 'payment by id');
          expect(
            await statusOf('$base/$id/applications'),
            404,
            reason: 'its applications',
          );
          expect(await statusOf('$base/$id/ticket'), 404, reason: 'its ticket');
          expect(
            await statusOf(base, {'facility': otherFacility.facilityId}),
            403,
            reason: 'the list of another facility',
          );
        });
      }

      await step(
        '10 no POS read: no session facet, session is plain text',
        () async {
          await go('/sales/payments');
          await openDrawer();
          expect(byKey('payments_filter_customer'), findsOneWidget);
          expect(byKey('payments_filter_cash_session'), findsNothing);
          await closeDrawer();
          if (sessionPayment == null || qaFacility != facilityId) {
            throw TestFailure(
              'no payment with a cash session in this facility',
            );
          }
          await openDetail(
            sessionPayment.cashSessionId == null
                ? first.customerPaymentId
                : sessionPayment.customerPaymentId,
          );
          expect(byKey('payment_cash_session_link'), findsNothing);
          expect(find.text('#${sessionPayment.cashSessionId}'), findsOneWidget);
          router().pop();
          await pumpFor(const Duration(milliseconds: 500));
        },
      );

      await step(
        '11b non-editor: no verify, reverse or edit anywhere',
        () async {
          await go('/sales/payments');
          await pumpUntil(byKey('payments_table'));
          expect(writeActions(), findsNothing);
          await openDetail(first.customerPaymentId);
          expect(writeActions(), findsNothing);
        },
      );
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
