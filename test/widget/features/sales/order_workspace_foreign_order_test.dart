import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
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

Customer _customerRecord() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// Spec 039 US3 / FR-052–FR-054: the "Pedidos" list does not distinguish
/// origin (spec A1), so a register sale can be *asked for* by id here. What
/// this file pins is the three-way answer — and, above all, that the `null`
/// arm still reopens a legacy back-office order (SC-008). That assertion is
/// the one that would silently invert if someone later "simplified" the
/// guard into "no origin ⇒ decline".
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
    ).thenAnswer((_) async => _customerRecord());
    when(
      () =>
          payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => const []);
  });

  Future<void> pumpOrder(WidgetTester tester, Sale order) async {
    when(
      () => salesOrders.getById(saleId: order.id),
    ).thenAnswer((_) async => order);
    await pumpOrdersRouted(
      tester,
      initialLocation: '/sales/orders/${order.id}',
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

  final declined = find.byKey(const Key('sales_order_foreign_notice'));
  // The tell that the workspace actually opened the order: Venta's product
  // search. A declined order renders no editable control at all — FR-053 is
  // "not offered", not "offered and disabled".
  final editable = find.byKey(const Key('pos_product_search_field'));

  group('the recorded origin decides on its own (FR-052, FR-053)', () {
    testWidgets('a register sale is declined on the field alone — nothing '
        'else about it looks like one', (tester) async {
      // A real customer, an intent to deliver, nothing paid: every proxy
      // condition says "back-office". The field overrules all three.
      await pumpOrder(
        tester,
        testSale(
          id: 42,
          customer: 7,
          fulfillmentIntent: FulfillmentMode.delivery,
          origin: SaleOrigin.pointOfSale,
        ),
      );

      expect(declined, findsOneWidget);
      expect(editable, findsNothing);
    });

    testWidgets('a back-office order resumes even where a proxy condition '
        'would have rejected it', (tester) async {
      // Recorded with a counter-pickup intent — a proxy condition that on
      // its own would decline the order, and irrelevant now that the order
      // itself says where it came from (FR-052's no-proxy rule).
      await pumpOrder(
        tester,
        testSale(
          id: 42,
          customer: 7,
          lines: [testLine()],
          fulfillmentIntent: FulfillmentMode.counterPickup,
          origin: SaleOrigin.backOffice,
        ),
      );

      expect(declined, findsNothing);
      expect(editable, findsOneWidget);
    });
  });

  group('no recorded origin falls back to the three signals (spec A9)', () {
    testWidgets('the generic walk-in customer', (tester) async {
      await pumpOrder(tester, testSale(id: 42, customer: 1));

      expect(declined, findsOneWidget);
      expect(editable, findsNothing);
    });

    testWidgets('a counter-pickup intent', (tester) async {
      await pumpOrder(
        tester,
        testSale(
          id: 42,
          customer: 7,
          fulfillmentIntent: FulfillmentMode.counterPickup,
        ),
      );

      expect(declined, findsOneWidget);
      expect(editable, findsNothing);
    });

    testWidgets('a balance below the total — the trace of a payment taken', (
      tester,
    ) async {
      await pumpOrder(
        tester,
        testSale(id: 42, customer: 7, total: '116.00', balance: '16.00'),
      );

      expect(declined, findsOneWidget);
      expect(editable, findsNothing);
    });

    testWidgets('an order raised by the previous back-office editor reopens '
        'normally (SC-008) — the assertion a "no origin ⇒ decline" '
        'simplification would silently invert', (tester) async {
      // Specs 029/032/037 raised orders exactly like this: a real customer,
      // no recorded origin (mbe-api#209 shipped no backfill, deliberately),
      // no counter-pickup intent, nothing paid. They are real orders
      // belonging to real customers and must still open.
      await pumpOrder(
        tester,
        testSale(id: 42, customer: 7, serial: 100, lines: [testLine()]),
      );

      expect(declined, findsNothing);
      expect(editable, findsOneWidget);
    });
  });
}
