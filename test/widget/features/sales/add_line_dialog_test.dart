import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/add_line_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class _MockSales extends Mock implements SalesOrderRepository {}

class _MockOrders extends Mock implements DeliveryOrderAdminRepository {}

/// Records each add in order; refuses the one for [failOn].
class _FakeActions extends DeliveryOrderActions {
  _FakeActions({this.failOn});

  final int? failOn;
  final calls = <String>[];

  @override
  Future<AppError?> addLine(
    int id, {
    required int salesOrderDetail,
    required Decimal quantity,
  }) async {
    calls.add('$salesOrderDetail:$quantity');
    return salesOrderDetail == failOn
        ? const AppError.server(
            statusCode: 409,
            problem: ApiProblem(
              codeName: 'delivery_order.line_already_present',
              code: api.ErrorCode.deliveryOrderPeriodLineAlreadyPresent,
            ),
          )
        : null;
  }
}

SaleLine _saleLine(int id, String quantity) => SaleLine(
  id: id,
  product: id,
  productCode: 'P-$id',
  productName: 'Producto $id',
  quantity: quantity,
  price: '20',
  discountRate: '0',
  taxRate: '0.16',
  taxIncluded: false,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
);

DeliveryOrderLine _orderLine(int id, int detail, String quantity) =>
    DeliveryOrderLine(
      id: id,
      salesOrderDetailId: detail,
      productId: detail,
      productCode: 'P-$detail',
      productName: 'Producto $detail',
      warehouseId: 3,
      quantity: Decimal.parse(quantity),
      committed: Decimal.zero,
      delivered: Decimal.zero,
      returned: Decimal.zero,
      open: Decimal.parse(quantity),
    );

DeliveryOrder _deliveryOrder(int id, List<DeliveryOrderLine> lines) =>
    DeliveryOrder(
      id: id,
      facilityId: 1,
      customerId: 7,
      priority: 0,
      status: DeliveryOrderStatus.draft,
      type: FulfillmentType.delivery,
      createdAt: DateTime(2026, 11, 14),
      modifiedAt: DateTime(2026, 11, 14),
      lines: lines,
    );

/// The order being edited: it already holds sale line 101.
final _order = _deliveryOrder(9, [_orderLine(1, 101, '2')]);

/// Sale 8860: line 101 is already on the order, 102 is fully covered by
/// another order, 103 is partly covered and 104 untouched.
final _sale = Sale(
  id: 60,
  serial: 8860,
  facility: 1,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  status: SaleStatus.completed,
  lines: [
    _saleLine(101, '10'),
    _saleLine(102, '4'),
    _saleLine(103, '15'),
    _saleLine(104, '200'),
  ],
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  date: DateTime(2026, 11, 14),
  dueDate: DateTime(2026, 11, 14),
);

OpenSale _openSale(int id, int serial) => OpenSale(
  id: id,
  serial: serial,
  total: '3240.00',
  balance: '0',
  status: SaleStatus.completed,
  date: DateTime(2026, 11, 14),
);

/// Spec 061 T027: the add-line dialog (C7, FR-014, research R8).
void main() {
  late AppLocalizations l10n;
  late _MockSales sales;
  late _MockOrders orders;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    sales = _MockSales();
    orders = _MockOrders();
    when(
      () => sales.listOrders(
        customer: 7,
        status: SaleStatus.completed,
        facility: 1,
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: 20,
      ),
    ).thenAnswer(
      (_) async => OpenSalePage(
        items: [_openSale(60, 8860), _openSale(41, 8841)],
        total: 2,
      ),
    );
    when(() => sales.getById(saleId: 60)).thenAnswer((_) async => _sale);
    when(() => orders.list(salesOrder: 60, facility: 1, limit: 100)).thenAnswer(
      (_) async => const DeliveryOrderPage(
        items: [
          DeliveryOrderSummary(
            id: 9,
            facilityId: 1,
            customerId: 7,
            priority: 0,
            status: DeliveryOrderStatus.draft,
            type: FulfillmentType.delivery,
          ),
          DeliveryOrderSummary(
            id: 20,
            facilityId: 1,
            customerId: 7,
            priority: 0,
            status: DeliveryOrderStatus.inPreparation,
            type: FulfillmentType.delivery,
          ),
        ],
        total: 2,
      ),
    );
    when(() => orders.getById(9)).thenAnswer((_) async => _order);
    when(() => orders.getById(20)).thenAnswer(
      (_) async => _deliveryOrder(20, [
        _orderLine(5, 102, '4'),
        _orderLine(6, 103, '5'),
      ]),
    );
  });

  Future<List<int>> pumpDialog(
    WidgetTester tester,
    _FakeActions actions,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final results = <int>[];
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          deliveryOrderActionsProvider.overrideWith(() => actions),
          salesOrderRepositoryProvider.overrideWithValue(sales),
          deliveryOrderAdminRepositoryProvider.overrideWithValue(orders),
          customerDisplayNameProvider.overrideWith(
            (ref, id) async => 'Ferretería López',
          ),
          facilityDisplayNameProvider.overrideWith((ref, id) async => 'Centro'),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => results.add(
                  await showAddDeliveryOrderLineDialog(context, _order),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  Finder key(String k) => find.byKey(Key(k));

  Future<void> openSale(WidgetTester tester) async {
    await tester.tap(key('delivery_order_add_line_sale_60'));
    await tester.pumpAndSettle();
  }

  VoidCallback? submit(WidgetTester tester) => tester
      .widget<FilledButton>(key('delivery_order_add_line_submit'))
      .onPressed;

  testWidgets('step 1 lists the customer\'s completed sales here', (
    tester,
  ) async {
    await pumpDialog(tester, _FakeActions());

    expect(find.text(l10n.deliveryOrderAddLineStep1Title), findsOneWidget);
    expect(
      find.text(
        l10n.deliveryOrderAddLineStep1Intro('Ferretería López', 'Centro'),
      ),
      findsOneWidget,
    );
    expect(key('delivery_order_add_line_sale_60'), findsOneWidget);
    expect(key('delivery_order_add_line_sale_41'), findsOneWidget);
    expect(find.text('8860'), findsOneWidget);
    expect(key('delivery_order_add_line_load_more'), findsNothing);
  });

  testWidgets('step 1 says so when there is no sale', (tester) async {
    when(
      () => sales.listOrders(
        customer: 7,
        status: SaleStatus.completed,
        facility: 1,
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: 20,
      ),
    ).thenAnswer((_) async => const OpenSalePage(items: [], total: 0));
    await pumpDialog(tester, _FakeActions());

    expect(find.text(l10n.deliveryOrderAddLineEmptySales), findsOneWidget);
  });

  testWidgets('step 2 shows only lines with something left, not on the '
      'order', (tester) async {
    await pumpDialog(tester, _FakeActions());
    await openSale(tester);

    expect(find.text(l10n.deliveryOrderAddLineStep2Title('8860')), findsOne);
    expect(key('delivery_order_add_line_row_101'), findsNothing);
    expect(key('delivery_order_add_line_row_102'), findsNothing);
    expect(
      find.descendant(
        of: key('delivery_order_add_line_row_103'),
        matching: find.text('10'),
      ),
      findsOneWidget,
    );
    expect(key('delivery_order_add_line_row_104'), findsOneWidget);
    expect(submit(tester), isNull);
  });

  testWidgets('a quantity above what is left is invalid', (tester) async {
    await pumpDialog(tester, _FakeActions());
    await openSale(tester);

    await tester.enterText(key('delivery_order_add_line_quantity_103'), '11');
    await tester.pump();

    expect(
      find.text(l10n.deliveryOrderAddLineQuantityInvalid('10')),
      findsOneWidget,
    );
    expect(submit(tester), isNull);
  });

  testWidgets('rows send in sequence and close with how many were added', (
    tester,
  ) async {
    final actions = _FakeActions();
    final results = await pumpDialog(tester, actions);
    await openSale(tester);

    await tester.enterText(key('delivery_order_add_line_quantity_103'), '10');
    await tester.enterText(key('delivery_order_add_line_quantity_104'), '50');
    await tester.pump();
    await tester.tap(key('delivery_order_add_line_submit'));
    await tester.pumpAndSettle();

    expect(actions.calls, ['103:10', '104:50']);
    expect(results, [2]);
  });

  testWidgets('the first refusal stops the run and shows inline', (
    tester,
  ) async {
    final actions = _FakeActions(failOn: 103);
    final results = await pumpDialog(tester, actions);
    await openSale(tester);

    await tester.enterText(key('delivery_order_add_line_quantity_103'), '5');
    await tester.enterText(key('delivery_order_add_line_quantity_104'), '50');
    await tester.pump();
    await tester.tap(key('delivery_order_add_line_submit'));
    await tester.pumpAndSettle();

    expect(actions.calls, ['103:5']);
    expect(key('delivery_order_add_line_dialog'), findsOneWidget);
    expect(
      find.text(l10n.apiErrorDeliveryOrderLineAlreadyPresent),
      findsOneWidget,
    );
    expect(results, isEmpty);
  });

  testWidgets('"Otra venta" goes back to the sales', (tester) async {
    await pumpDialog(tester, _FakeActions());
    await openSale(tester);

    await tester.tap(key('delivery_order_add_line_another_sale'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.deliveryOrderAddLineStep1Title), findsOneWidget);
  });
}
