import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

const _updaterUser = User(
  userId: 'order-updater',
  email: 'order-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 6)],
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
      label: 'Av. Reforma 100',
      type: AddressType.business,
    ),
  ],
);

Destination _created() => const Destination(
  id: 500,
  fulfillmentType: FulfillmentType.delivery,
  shipTo: 11,
  addressSummary: 'Av. Reforma 100',
  status: DeliveryOrderStatus.draft,
  lines: [],
);

/// mictlanix/mbe-ui#183: "Add destination" in the back-office order
/// workspace did nothing.
///
/// The destination sheet is pushed on the **root** navigator, which is not a
/// descendant of the workspace's nested `ProviderScope`. So the sheet's
/// providers resolved against the register's scope: `saleEditorProvider` was
/// the POS controller, whose `confirm()` threw a `StateError` with no POS
/// sale open (swallowed: only `AppError` was caught), or, with one open,
/// confirmed **that** sale instead of the order.
///
/// These tests drive the real routed workspace (`pumpOrdersRouted`), so the
/// sheet lands on the real root navigator — the existing destination suites
/// pump `DeliveryStep` under a single root scope, where the bug cannot show.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late MockDeliveryOrderRepository deliveries;

  /// What the server holds, so a re-read after a create (confirming re-keys
  /// the step's delivery controller by the now-completed sale) finds it.
  late List<Destination> stored;

  final draft = testSale(
    id: 42,
    customer: 7,
    fulfillmentIntent: FulfillmentMode.delivery,
    lines: [testLine(id: 5, quantity: '10')],
    origin: SaleOrigin.backOffice,
  );
  final confirmed = testSale(
    id: 42,
    serial: 1001,
    status: SaleStatus.completed,
    customer: 7,
    fulfillmentIntent: FulfillmentMode.delivery,
    lines: [testLine(id: 5, quantity: '10')],
    origin: SaleOrigin.backOffice,
  );

  setUpAll(() {
    registerFallbackValue(FulfillmentType.delivery);
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    deliveries = MockDeliveryOrderRepository();
    stored = [];

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () =>
          payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => draft);
    when(
      () => salesOrders.confirm(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => confirmed);
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => List.of(stored));
  });

  void stubCreate(Future<Destination> Function() answer) {
    when(
      () => deliveries.create(
        salesOrder: any(named: 'salesOrder'),
        fulfillmentType: any(named: 'fulfillmentType'),
        shipTo: any(named: 'shipTo'),
        contact: any(named: 'contact'),
        date: any(named: 'date'),
        comment: any(named: 'comment'),
        lines: any(named: 'lines'),
      ),
    ).thenAnswer((_) async {
      final created = await answer();
      stored.add(created);
      return created;
    });
  }

  Future<ProviderContainer> pumpOrder(
    WidgetTester tester, {
    List<Override> extra = const [],
    Size surface = const Size(1400, 2400),
  }) async {
    final (_, container) = await pumpOrdersRouted(
      tester,
      initialLocation: '/sales/orders/42',
      surface: surface,
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
        ...extra,
      ],
    );
    return container;
  }

  /// From the resumed draft on Venta: continue to Entrega, open the sheet,
  /// pick the customer's address, and press "Add destination".
  Future<void> addDestination(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delivery_add_destination_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('destination_editor')), findsOneWidget);

    await tester.tap(find.byKey(const Key('destination_address_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('address_option_11')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('destination_save_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('confirms the order, creates its destination, and shows it on '
      'the step (wide tier: side sheet)', (tester) async {
    stubCreate(() async => _created());
    await pumpOrder(tester);

    await addDestination(tester);

    expect(tester.takeException(), isNull);
    verify(() => salesOrders.confirm(saleId: 42)).called(1);
    verify(
      () => deliveries.create(
        salesOrder: 42,
        fulfillmentType: FulfillmentType.delivery,
        shipTo: 11,
        contact: any(named: 'contact'),
        date: any(named: 'date'),
        comment: any(named: 'comment'),
        lines: any(named: 'lines'),
      ),
    ).called(1);
    // The sheet closed and the step the user is looking at shows it.
    expect(find.byKey(const Key('destination_editor')), findsNothing);
    expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
  });

  testWidgets('works the same from the bottom sheet below the large tier', (
    tester,
  ) async {
    stubCreate(() async => _created());
    await pumpOrder(tester, surface: const Size(1000, 2400));

    await addDestination(tester);

    expect(tester.takeException(), isNull);
    verify(() => salesOrders.confirm(saleId: 42)).called(1);
    expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
  });

  testWidgets('shows the destination when the create is slower than the '
      'step\'s re-read of the confirmed order', (tester) async {
    // Confirming re-keys the step's delivery controller by the completed
    // sale; that new instance lists destinations while the create is still
    // in flight, so it finds none. The create must still land on it.
    stubCreate(
      () => Future.delayed(const Duration(milliseconds: 300), _created),
    );
    await pumpOrder(tester);

    await addDestination(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
  });

  testWidgets('never confirms a sale the register has open instead of the '
      'order', (tester) async {
    stubCreate(() async => _created());
    final registerSale = testSale(id: 99, customer: 7);
    final container = await pumpOrder(
      tester,
      extra: [fixedPosSale(registerSale)],
    );
    // Keep the register's sale alive for the whole test, as a real session
    // with the register open would.
    container.listen(posSaleControllerProvider, (_, _) {});
    await container.read(posSaleControllerProvider.future);

    await addDestination(tester);

    verifyNever(() => salesOrders.confirm(saleId: 99));
    verify(() => salesOrders.confirm(saleId: 42)).called(1);
  });

  testWidgets('an unexpected failure is shown in the sheet, never swallowed',
      (tester) async {
    stubCreate(() async => throw StateError('unexpected'));
    await pumpOrder(tester);

    await addDestination(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('destination_editor')), findsOneWidget);
    expect(find.byKey(const Key('destination_editor_error')), findsOneWidget);
    // Not stuck: the user can try again.
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('destination_save_button')))
          .onPressed,
      isNotNull,
    );
  });
}
