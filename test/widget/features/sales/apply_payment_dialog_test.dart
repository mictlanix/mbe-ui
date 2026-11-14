import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/outstanding_order.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payments/apply_payment_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

CustomerPayment _payment({String unapplied = '1500.00'}) => CustomerPayment(
  customerPaymentId: 501,
  customerId: 77,
  amount: '3000.00',
  currency: Currency.mxn,
  methodCode: 3,
  date: DateTime(2026, 11, 13, 10, 42),
  facilityId: 9,
  type: PaymentType.creditPayment,
  unapplied: unapplied,
);

OutstandingOrder _order(
  int id, {
  String total = '2400.00',
  String balance = '1800.00',
  int? serial,
  Currency currency = Currency.mxn,
}) => OutstandingOrder(
  id: id,
  serial: serial,
  date: DateTime(2026, 11, 10, 9, 30),
  dueDate: DateTime(2026, 11, 25),
  currency: currency,
  total: total,
  balance: balance,
);

OutstandingOrderPage _page(List<OutstandingOrder> orders) =>
    OutstandingOrderPage(items: orders, total: orders.length);

/// Spec 059 C5 (T010): the apply dialog.
void main() {
  late PaymentsMocks mocks;
  late CustomerPayment payment;

  setUp(() {
    mocks = PaymentsMocks();
    payment = _payment();
    when(
      () => mocks.payments.applyPayment(
        customerPaymentId: any(named: 'customerPaymentId'),
        salesOrder: any(named: 'salesOrder'),
        amount: any(named: 'amount'),
        amountChange: any(named: 'amountChange'),
      ),
    ).thenAnswer((_) async {});
  });

  void stubOrders(List<OutstandingOrder> orders) => when(
    () => mocks.payments.listOutstandingOrders(
      customerId: any(named: 'customerId'),
      search: any(named: 'search'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => _page(orders));

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          customerPaymentRepositoryProvider.overrideWithValue(mocks.payments),
          paymentDetailProvider(501).overrideWith((ref) async => payment),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                key: const Key('open'),
                onPressed: () => showApplyPaymentDialog(context, payment),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  String amountText(WidgetTester tester) => tester
      .widget<TextField>(find.byKey(const Key('apply_payment_amount')))
      .controller!
      .text;

  bool confirmEnabled(WidgetTester tester) => tester
      .widget<FilledButton>(find.byKey(const Key('apply_payment_confirm')))
      .enabled;

  Future<void> pick(WidgetTester tester, int id) async {
    await tester.tap(find.byKey(Key('apply_payment_order_$id')));
    await tester.pump();
  }

  testWidgets('names the payment and what is left to apply', (tester) async {
    stubOrders([_order(1047)]);
    await open(tester);

    expect(find.text('Aplicar pago #501'), findsOneWidget);
    expect(find.textContaining(r'Sin aplicar: $1,500.00'), findsOneWidget);
  });

  testWidgets('lists only orders in the payment\'s currency, each with '
      'its number, folio, date, balance and total', (tester) async {
    stubOrders([
      _order(1047, serial: 812),
      _order(1052, balance: '900.00', total: '900.00'),
      _order(1060, currency: Currency.usd),
    ]);
    await open(tester);

    expect(find.byKey(const Key('apply_payment_order_1047')), findsOneWidget);
    expect(find.byKey(const Key('apply_payment_order_1052')), findsOneWidget);
    expect(find.byKey(const Key('apply_payment_order_1060')), findsNothing);
    expect(find.textContaining('#1047 · Folio 812'), findsOneWidget);
    expect(find.text('#1052'), findsOneWidget);
    expect(find.textContaining('2026-11-10'), findsWidgets);
    expect(find.textContaining(r'Saldo $1,800.00'), findsOneWidget);
    expect(find.textContaining(r'Total $2,400.00'), findsOneWidget);
  });

  testWidgets('asks the server for this customer\'s orders', (tester) async {
    stubOrders([_order(1047)]);
    await open(tester);

    verify(
      () => mocks.payments.listOutstandingOrders(
        customerId: 77,
        search: '',
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(1);
  });

  testWidgets('the amount defaults to the smaller of balance and unapplied', (
    tester,
  ) async {
    stubOrders([
      _order(1047, balance: '2400.00'),
      _order(1052, balance: '900.00'),
    ]);
    await open(tester);

    await pick(tester, 1052);
    expect(amountText(tester), '900.00');
    expect(find.textContaining(r'Máximo $900.00'), findsOneWidget);

    await pick(tester, 1047);
    expect(amountText(tester), '1500.00');
    expect(find.textContaining(r'Máximo $1,500.00'), findsOneWidget);
  });

  testWidgets('confirm needs an order and a valid amount', (tester) async {
    stubOrders([_order(1052, balance: '900.00')]);
    await open(tester);
    expect(confirmEnabled(tester), isFalse);

    await pick(tester, 1052);
    expect(confirmEnabled(tester), isTrue);

    await tester.enterText(
      find.byKey(const Key('apply_payment_amount')),
      '1200',
    );
    await tester.pump();
    expect(confirmEnabled(tester), isFalse);
    expect(find.text(r'No puede ser más de $900.00.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('apply_payment_amount')), '0');
    await tester.pump();
    expect(confirmEnabled(tester), isFalse);
    expect(find.text('Escribe un monto mayor que cero.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('apply_payment_amount')),
      '450.50',
    );
    await tester.pump();
    expect(confirmEnabled(tester), isTrue);
  });

  testWidgets('says so when the customer has no orders to pay', (tester) async {
    stubOrders([_order(1060, currency: Currency.usd)]);
    await open(tester);

    expect(find.byKey(const Key('apply_payment_empty')), findsOneWidget);
    expect(
      find.text('Este cliente no tiene pedidos por pagar en MXN.'),
      findsOneWidget,
    );
  });

  testWidgets('a search that finds nothing says that instead', (tester) async {
    stubOrders([_order(1047)]);
    await open(tester);

    stubOrders(const []);
    await tester.enterText(
      find.byKey(const Key('apply_payment_search')),
      '999',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(
      find.text('Ningún pedido coincide con la búsqueda.'),
      findsOneWidget,
    );
    verify(
      () => mocks.payments.listOutstandingOrders(
        customerId: 77,
        search: '999',
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(1);
  });

  testWidgets('a load failure offers a retry', (tester) async {
    when(
      () => mocks.payments.listOutstandingOrders(
        customerId: any(named: 'customerId'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(const AppError.server());
    await open(tester);
    expect(find.text('Reintentar'), findsOneWidget);

    stubOrders([_order(1047)]);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('apply_payment_order_1047')), findsOneWidget);
  });

  testWidgets('confirming applies the amount with no change, closes the '
      'dialog and says so', (tester) async {
    stubOrders([_order(1052, balance: '900.00')]);
    await open(tester);

    await pick(tester, 1052);
    await tester.tap(find.byKey(const Key('apply_payment_confirm')));
    await tester.pumpAndSettle();

    verify(
      () => mocks.payments.applyPayment(
        customerPaymentId: 501,
        salesOrder: 1052,
        amount: '900',
      ),
    ).called(1);
    expect(find.byKey(const Key('apply_payment_dialog')), findsNothing);
    expect(find.text('Pago aplicado a #1052'), findsOneWidget);
  });

  testWidgets('a refusal shows in the dialog, clears the choice, reads the '
      'orders again and stays open', (tester) async {
    stubOrders([_order(1052, balance: '900.00')]);
    await open(tester);
    when(
      () => mocks.payments.applyPayment(
        customerPaymentId: any(named: 'customerPaymentId'),
        salesOrder: any(named: 'salesOrder'),
        amount: any(named: 'amount'),
        amountChange: any(named: 'amountChange'),
      ),
    ).thenThrow(const AppError.server());

    await pick(tester, 1052);
    await tester.tap(find.byKey(const Key('apply_payment_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('apply_payment_dialog')), findsOneWidget);
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(amountText(tester), isEmpty);
    expect(confirmEnabled(tester), isFalse);
    verify(
      () => mocks.payments.listOutstandingOrders(
        customerId: 77,
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(2);
  });

  testWidgets('a second tap while applying does not apply twice', (
    tester,
  ) async {
    stubOrders([_order(1052, balance: '900.00')]);
    await open(tester);
    final gate = Completer<void>();
    when(
      () => mocks.payments.applyPayment(
        customerPaymentId: any(named: 'customerPaymentId'),
        salesOrder: any(named: 'salesOrder'),
        amount: any(named: 'amount'),
        amountChange: any(named: 'amountChange'),
      ),
    ).thenAnswer((_) => gate.future);

    await pick(tester, 1052);
    await tester.tap(find.byKey(const Key('apply_payment_confirm')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('apply_payment_confirm')));
    await tester.pump();

    verify(
      () => mocks.payments.applyPayment(
        customerPaymentId: 501,
        salesOrder: 1052,
        amount: '900',
      ),
    ).called(1);

    gate.complete();
    await tester.pumpAndSettle();
  });
}
