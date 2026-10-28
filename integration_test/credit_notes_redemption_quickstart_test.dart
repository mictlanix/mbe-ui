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
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates the redemption half of specs/056-credit-notes/quickstart.md
/// (steps 5–9) against the REAL app (macOS desktop) and a live mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/credit_notes_redemption_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env \
///     --dart-define=MBE_POS_PRODUCT_PATTERN=clavo
///
/// **This test writes to the tenant.** It opens a cash session for the
/// `MBE_POS_*` account when it has none (and leaves it open, which the other
/// POS tests expect), raises two POS sales, and spends two real credit notes
/// on them. When it finishes — pass or fail — it reverses every application
/// it made and cancels both sales, so the notes are spendable again.
///
/// Fixtures are discovered at runtime: the named customer whose spendable
/// credit is smallest, and the walk-in note with the smallest balance.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _productPattern = String.fromEnvironment(
  'MBE_POS_PRODUCT_PATTERN',
  defaultValue: 'clavo',
);
const _walkIn = int.fromEnvironment('POS_DEFAULT_CUSTOMER_ID', defaultValue: 1);

const _wide = Size(1400, 1000);
const _cleanupReason = 'spec 056 redemption walkthrough — automatic cleanup';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Credit note redemption walkthrough (real app, live mbe-api)', (
    tester,
  ) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }

    // Frame watchdog (see credit_notes_quickstart_test.dart).
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

    void note(String text) {
      // ignore: avoid_print
      print('QS: $text');
    }

    // ------------------------------------------------------------------
    // API side: session, fixtures, sales
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final sessions = CashSessionRepositoryImpl(dio);
    final notes = CreditNoteRepositoryImpl(dio);
    final payments = CustomerPaymentRepositoryImpl(dio);
    final orders = SalesOrderRepositoryImpl(dio);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    final current = await sessions.getCurrent();
    if (current.state == SessionState.none) {
      final opened = await sessions.open(openingAmount: '0');
      note('opened cash session ${opened.cashSessionId} (left open)');
    } else if (!current.isValid) {
      markTestSkipped(
        'the cash session is ${current.state.name}; close it first',
      );
      return;
    }

    // The named customer whose spendable credit is smallest.
    final open = <CreditNote>[];
    while (true) {
      final page = await notes.list(
        openOnly: true,
        skip: open.length,
        limit: 100,
      );
      open.addAll(page.items);
      if (page.items.isEmpty || open.length >= page.total) break;
    }
    final byCustomer = <int, List<CreditNote>>{};
    for (final n in open) {
      byCustomer.putIfAbsent(n.customerId, () => []).add(n);
    }
    if (byCustomer.isEmpty) {
      markTestSkipped('no customer in this facility has spendable credit');
      return;
    }
    String totalOf(List<CreditNote> ns) =>
        ns.fold('0', (sum, n) => addAmounts(sum, n.remaining));
    final named = byCustomer.entries.reduce(
      (a, b) => compareAmounts(totalOf(a.value), totalOf(b.value)) <= 0 ? a : b,
    );
    final namedCustomer = named.key;
    final namedCredit = totalOf(named.value);
    final namedNote = named.value.first;
    note(
      'named customer $namedCustomer holds $namedCredit in ${named.value.length} note(s)',
    );

    // The walk-in note with the smallest balance.
    final walkInNotes = <CreditNote>[];
    while (true) {
      final page = await notes.list(
        customerId: _walkIn,
        skip: walkInNotes.length,
        limit: 100,
      );
      walkInNotes.addAll(page.items);
      if (page.items.isEmpty || walkInNotes.length >= page.total) break;
    }
    final walkInOpen = walkInNotes.where((n) => n.isOpen).toList()
      ..sort((a, b) => compareAmounts(a.remaining, b.remaining));
    if (walkInOpen.isEmpty) {
      markTestSkipped('no walk-in note in this facility has a balance');
      return;
    }
    final walkInNote = walkInOpen.first;
    note(
      'walk-in note ${walkInNote.id} (ticket ${walkInNote.customerPaymentId}) holds ${walkInNote.remaining}',
    );

    /// Opens a POS sale for [customer] whose total is above [above].
    Future<Sale> saleAbove(int? customer, String above) async {
      var sale = await orders.open(
        customer: customer,
        fulfillmentIntent: FulfillmentMode.counterPickup,
        origin: SaleOrigin.pointOfSale,
      );
      final warehouse = (await PointSaleRepositoryImpl(
        dio,
      ).get(pointSaleId: sale.pointSale!)).warehouseId;
      final matches = await orders.productLookup(
        pattern: _productPattern,
        customer: sale.customer,
        warehouse: warehouse,
      );
      final target = addAmounts(above, '20');
      for (final p in matches) {
        if (compareAmounts(p.price, '0') <= 0) continue;
        final qty = (parseAmount(target) / parseAmount(p.price))
            .toDouble()
            .ceil()
            .clamp(p.minOrderQty > 0 ? p.minOrderQty : 1, 1 << 30);
        final available = p.stock
            .where((s) => s.warehouse == warehouse)
            .fold('0', (sum, s) => addAmounts(sum, s.available));
        if (p.stockRequired && compareAmounts(available, '$qty') < 0) continue;
        sale = await orders.addLine(
          saleId: sale.id,
          product: p.product,
          quantity: '$qty',
          warehouse: warehouse,
        );
        return sale;
      }
      throw StateError('no stocked product matching "$_productPattern"');
    }

    final namedSale = await saleAbove(namedCustomer, namedCredit);
    final walkInSale = await saleAbove(null, walkInNote.remaining);
    note(
      'sales: named ${namedSale.id} (total ${namedSale.total}), walk-in ${walkInSale.id} (total ${walkInSale.total})',
    );

    // Cleanup runs whatever happens below: reverse what was applied, cancel
    // both sales.
    addTearDown(() async {
      for (final sale in [namedSale, walkInSale]) {
        try {
          final applied = await payments.listForOrder(saleId: sale.id);
          for (final a in applied.where((a) => !a.cancelled)) {
            await payments.reverseApplication(
              customerPaymentId: a.customerPayment,
              applicationId: a.id,
              reason: _cleanupReason,
            );
            note(
              'reversed application ${a.id} of payment ${a.customerPayment}',
            );
          }
        } catch (e) {
          note('cleanup: could not reverse on sale ${sale.id}: $e');
        }
        try {
          await orders.cancel(saleId: sale.id);
          note('cancelled sale ${sale.id}');
        } catch (e) {
          note('cleanup: could not cancel sale ${sale.id}: $e');
        }
      }
    });

    // ------------------------------------------------------------------
    // App boot
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
    String money(String amount) =>
        container().read(formattersProvider).display.currency(amount);

    Future<void> pumpFor(Duration d) async {
      final end = DateTime.now().add(d);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilTrue(
      bool Function() cond,
      String what, {
      Duration timeout = const Duration(seconds: 60),
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

    Finder byKey(String k) => find.byKey(Key(k));
    bool shown(Finder f) => f.evaluate().isNotEmpty;

    Future<void> tap(Finder f) async {
      await pumpUntilTrue(() => shown(f.hitTestable()), 'tappable $f');
      await tester.tap(f.hitTestable().first);
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> login(String user, String pass) async {
      await pumpUntilTrue(
        () => shown(byKey('login_username_field').hitTestable()),
        'login screen',
      );
      await tester.enterText(byKey('login_username_field').hitTestable(), user);
      await tester.enterText(byKey('login_password_field').hitTestable(), pass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey('login_password_field').hitTestable());
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilTrue(
        () => !shown(byKey('login_username_field')),
        'login to finish',
        timeout: const Duration(seconds: 40),
      );
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> openCobro(int saleId) async {
      // Through the sales list first: `/sales/pos/:saleId` keeps its screen
      // when only the id changes, so going straight from one sale's address
      // to another's would keep the first sale loaded.
      router().go('/sales/pos');
      await pumpFor(const Duration(seconds: 1));
      router().go('/sales/pos/$saleId');
      // The workspace sets its step from the sale once it has loaded, so the
      // forward tap waits for that, or the load would put it back on Venta.
      await pumpUntilTrue(
        () => shown(find.textContaining('Id $saleId')),
        'sale $saleId to load',
      );
      await pumpFor(const Duration(seconds: 1));
      await tap(byKey('pos_continue_to_payment'));
      await pumpUntilTrue(
        () => shown(byKey('payment_amount_field')),
        'the Cobro step',
      );
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> enterTicket(int number) async {
      await tap(byKey('payment_credit_note_redeem_tile'));
      await pumpUntilTrue(
        () => shown(byKey('credit_note_ticket_input')),
        'the ticket dialog',
      );
      await tester.enterText(byKey('credit_note_ticket_input'), '$number');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilTrue(
        () =>
            shown(byKey('credit_note_ticket_found')) ||
            shown(byKey('credit_note_ticket_refusal')),
        'the ticket lookup',
        timeout: const Duration(seconds: 30),
      );
    }

    Future<void> closeDialog() async {
      await tap(find.text(l10n.cancelButton));
      await pumpUntilTrue(
        () => !shown(byKey('credit_note_ticket_dialog')),
        'the dialog to close',
      );
    }

    final failures = <String>[];
    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: $ex');
        // ignore: avoid_print
        print('QS-STEP PASS $name');
      } catch (e) {
        failures.add('$name: $e');
        tester.takeException();
        final texts = find
            .byType(Text)
            .evaluate()
            .map((el) => (el.widget as Text).data ?? '')
            .where((t) => t.isNotEmpty)
            .take(40)
            .toList();
        // ignore: avoid_print
        print(
          'QS-DBG loc=${router().routerDelegate.currentConfiguration.uri} '
          'texts=$texts',
        );
        // ignore: avoid_print
        print('QS-STEP FAIL $name :: $e');
      }
    }

    await login(_adminUser, _adminPass);

    await step('5. the named customer\'s credit shows in Cobro', () async {
      await openCobro(namedSale.id);
      final tile = byKey('payment_credit_note_tile');
      await pumpUntilTrue(() => shown(tile), 'the credit tile');
      expect(
        find.descendant(
          of: tile,
          matching: find.text(
            l10n.paymentCreditNoteBalance(money(namedCredit)),
          ),
        ),
        findsOneWidget,
      );
    });

    await step('6. one tap spends it all: balance falls by the credit, the '
        'tile goes, the row reads "Nota de crédito"', () async {
      final before = (await orders.getById(saleId: namedSale.id)).balanceOrZero;
      final watch = Stopwatch()..start();
      await tap(byKey('payment_credit_note_tile'));
      await pumpUntilTrue(
        () => !shown(byKey('payment_credit_note_tile')),
        'the tile to go',
      );
      note('SC-001: one action; applied in ${watch.elapsedMilliseconds} ms');
      await pumpUntilTrue(
        () => shown(
          find.textContaining(
            'Nota de crédito · Nº ${namedNote.customerPaymentId}',
          ),
        ),
        'the applied credit-note row',
      );
      final after = (await orders.getById(saleId: namedSale.id)).balanceOrZero;
      expect(
        compareAmounts(subtractAmounts(before, after), namedCredit),
        0,
        reason: 'the balance falls by exactly the credit ($before → $after)',
      );
      for (final n in named.value) {
        final now = await notes.findByPayment(n.customerPaymentId);
        expect(now?.isOpen, isFalse, reason: 'note ${n.id} is spent');
      }
    });

    await step('7. a walk-in ticket shows its balance and applies', () async {
      await openCobro(walkInSale.id);
      final watch = Stopwatch()..start();
      await enterTicket(walkInNote.customerPaymentId);
      expect(byKey('credit_note_ticket_found'), findsOneWidget);
      expect(
        find.text(l10n.creditNoteTicketAvailable(money(walkInNote.remaining))),
        findsOneWidget,
      );
      await tap(byKey('credit_note_ticket_confirm'));
      await pumpUntilTrue(
        () => shown(
          find.textContaining(
            'Nota de crédito · Nº ${walkInNote.customerPaymentId}',
          ),
        ),
        'the applied walk-in row',
      );
      note('SC-002: ticket redeemed in ${watch.elapsedMilliseconds} ms');
      final now = await notes.findByPayment(walkInNote.customerPaymentId);
      expect(now?.isOpen, isFalse);
    });

    await step(
      '8. the same ticket again is refused: already on this sale',
      () async {
        await enterTicket(walkInNote.customerPaymentId);
        expect(find.text(l10n.creditNoteAlreadyOnSale), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(byKey('credit_note_ticket_confirm'))
              .onPressed,
          isNull,
        );
        await closeDialog();
      },
    );

    await step('9. a named customer\'s ticket on a walk-in sale says whose it '
        'is', () async {
      await enterTicket(namedNote.customerPaymentId);
      final refusal = tester.widget<Text>(byKey('credit_note_ticket_refusal'));
      expect(refusal.data, startsWith('Esta nota de crédito es de '));
      expect(refusal.data, isNot(contains('—')), reason: 'the owner is named');
      await closeDialog();
      final applied = await payments.listForOrder(saleId: walkInSale.id);
      expect(
        applied.where(
          (a) =>
              !a.cancelled && a.customerPayment == namedNote.customerPaymentId,
        ),
        isEmpty,
        reason: 'nothing of the named customer\'s note was applied',
      );
    });

    expect(failures, isEmpty, reason: failures.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 15)));
}
