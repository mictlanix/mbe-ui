import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

const _updaterUser = User(
  userId: 'order-updater',
  email: 'order-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 4)],
);

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  addresses: [
    AddressListItem(
      addressId: 11,
      label: 'Destino uno',
      type: AddressType.business,
    ),
  ],
);

/// Spec 039 US3 / FR-030–FR-033, re-homed from `order_resume_test.dart`:
/// a reopened order lands on the step its own state implies (research R2),
/// with its lines and figures restored, and a write refused because the
/// order moved underneath re-reads rather than leaving stale figures on
/// screen (spec.md Edge Cases).
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late MockDeliveryOrderRepository deliveries;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    deliveries = MockDeliveryOrderRepository();

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () =>
          payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => const []);
  });

  Future<void> pumpOrder(WidgetTester tester) async {
    await pumpOrdersRouted(
      tester,
      initialLocation: '/sales/orders/42',
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: _updaterUser),
          ),
        ),
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
      ],
    );
  }

  testWidgets('a draft with lines and no destination reopens on Venta, its '
      'lines and figures restored', (tester) async {
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(
        id: 42,
        serial: 100,
        lines: [testLine()],
        origin: SaleOrigin.backOffice,
      ),
    );

    await pumpOrder(tester);

    expect(find.byKey(const Key('pos_product_search_field')), findsOneWidget);
    expect(
      find.byKey(const Key('sale_line_discount_5')),
      findsOneWidget,
      reason: 'the line came back editable, not as a read-only echo',
    );
    expect(find.text('100'), findsOneWidget, reason: 'the folio');
  });

  testWidgets('a committed order with a destination reopens on Entrega, '
      'showing it', (tester) async {
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(
        id: 42,
        serial: 100,
        lines: [testLine()],
        status: SaleStatus.completed,
        origin: SaleOrigin.backOffice,
      ),
    );
    when(() => deliveries.listForSale(salesOrder: 42)).thenAnswer(
      (_) async => const [
        Destination(
          id: 500,
          fulfillmentType: FulfillmentType.delivery,
          shipTo: 11,
          status: DeliveryOrderStatus.draft,
          lines: [],
        ),
      ],
    );

    await pumpOrder(tester);

    expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
    expect(
      find.byKey(const Key('pos_product_search_field')),
      findsNothing,
      reason:
          'Venta is behind it — the lines are fixed once a destination '
          'exists (spec A2)',
    );
  });

  testWidgets('an order raised by the previous back-office editor — no '
      'recorded origin — reopens normally (SC-008)', (tester) async {
    // Specs 029/032/037 left real orders shaped exactly like this, and
    // mbe-api#209 shipped without a backfill, deliberately. A rule of "no
    // origin ⇒ decline" would refuse every one of them.
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(id: 42, serial: 100, lines: [testLine()]),
    );

    await pumpOrder(tester);

    expect(find.byKey(const Key('sales_order_foreign_notice')), findsNothing);
    expect(find.byKey(const Key('pos_product_search_field')), findsOneWidget);
  });

  testWidgets('a write refused because the order moved underneath re-reads '
      'it rather than leaving stale figures on screen', (tester) async {
    final draft = testSale(
      id: 42,
      lines: [testLine()],
      origin: SaleOrigin.backOffice,
    );
    final nowCommitted = testSale(
      id: 42,
      serial: 200,
      lines: [testLine()],
      status: SaleStatus.completed,
      origin: SaleOrigin.backOffice,
    );
    when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => draft);

    await pumpOrder(tester);
    expect(find.byKey(const Key('sales_order_cancel_button')), findsOneWidget);

    // Committed elsewhere between load and this edit.
    when(
      () => salesOrders.cancel(saleId: 42),
    ).thenThrow(const AppError.server(message: 'Order is already confirmed'));
    when(
      () => salesOrders.getById(saleId: 42),
    ).thenAnswer((_) async => nowCommitted);

    await tester.tap(find.byKey(const Key('sales_order_cancel_button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('sales_order_cancel_confirm_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('200'),
      findsOneWidget,
      reason: "the screen now shows the order's true folio",
    );
    expect(
      find.byKey(const Key('sales_order_cancel_button')),
      findsNothing,
      reason: 'and its true status — no longer a draft, so no cancel',
    );
  });
}
