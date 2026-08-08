import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Shared fixtures and pump helper for the POS widget tests. Kept in one
/// place so a change to `Sale`'s required fields lands once, not in four
/// test files.
class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

Sale testSale({
  int id = 42,
  int? serial,
  SaleStatus status = SaleStatus.draft,
  PaymentTerms paymentTerms = PaymentTerms.immediate,
  String total = '116.00',
  String balance = '116.00',
  List<SaleLine> lines = const [],
}) => Sale(
  id: id,
  serial: serial,
  facility: 9,
  pointSale: 3,
  salesperson: 100,
  customer: 7,
  customerName: 'Público en general',
  paymentTerms: paymentTerms,
  currency: Currency.mxn,
  exchangeRate: '1',
  promiseDate: DateTime(2026, 8, 5),
  status: status,
  lines: lines,
  subtotal: '100.00',
  taxTotal: '16.00',
  total: total,
  balance: balance,
);

SaleLine testLine({
  int id = 5,
  String quantity = '2',
  String price = '50.00',
  String discountRate = '0',
  String taxRate = '0.16',
  int? warehouse = 3,
  String? unit,
}) => SaleLine(
  id: id,
  product: 11,
  productCode: 'P-11',
  productName: 'Widget',
  unit: unit,
  quantity: quantity,
  cost: '40.00',
  price: price,
  discountRate: discountRate,
  taxRate: taxRate,
  taxIncluded: false,
  warehouse: warehouse,
  subtotal: '100.00',
  taxTotal: '16.00',
  total: '116.00',
);

/// Pumps [child] inside a localized `MaterialApp` with the POS providers
/// overridden. Returns the container so a test can read controllers back.
Future<ProviderContainer> pumpPos(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Size surface = const Size(1200, 2400),
}) async {
  // Tall by default so a step's whole content is laid out and every control
  // is built — these tests assert on enabled/disabled state, not on what
  // happens to be scrolled into view.
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        // Pinned to match `app.dart`'s own fixed `es-MX` (constitution §V) —
        // without it the test tree resolves to the first supported locale
        // and asserts against strings the app never renders.
        locale: const Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Override salesOrderOverride(SalesOrderRepository repository) =>
    salesOrderRepositoryProvider.overrideWithValue(repository);

Override customerPaymentOverride(CustomerPaymentRepository repository) =>
    customerPaymentRepositoryProvider.overrideWithValue(repository);

Override warehouseOverride(WarehouseRepository repository) =>
    warehouseRepositoryProvider.overrideWithValue(repository);
