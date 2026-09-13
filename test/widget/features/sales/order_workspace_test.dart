import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/fulfillment_mode_selector.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Holds update on `salesOrders`, matching what this workspace's actions gate
/// on (constitution §IV) — mirrors `order_screen_test.dart`'s own fixture.
const _updaterUser = User(
  userId: 'order-updater',
  email: 'order-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 4)],
);

Override _authOverride() => authNotifierProvider.overrideWith(
  () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: _updaterUser)),
);

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockDeliveryOrderRepository extends Mock implements DeliveryOrderRepository {}

const _realCustomer = CustomerListItem(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
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

/// Spec 039 US1: the full happy path for an existing customer, Cliente
/// through the transition into Entrega. `DeliveryStep` itself — assigning
/// destinations, closing the step, the commit that follows — is the real,
/// unmodified widget (contracts/shared-step-seam.md), already covered by its
/// own suite (`destination_assignment_test.dart` and siblings); this file's
/// job is the seam and the two new steps, not re-proving `DeliveryStep`.
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
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    // Entrega's own destinations list — empty, since this file's job is the
    // seam and the transition into the step, not `DeliveryStep` itself
    // (already covered by `destination_assignment_test.dart` and siblings).
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => const []);
  });

  Future<ProviderContainer> pumpWorkspace(WidgetTester tester, {int? orderId}) async {
    final (_, container) = await pumpOrdersRouted(
      tester,
      initialLocation: orderId == null ? '/sales/orders/new' : '/sales/orders/$orderId',
      overrides: [
        _authOverride(),
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
      ],
    );
    return container;
  }

  group('the Cliente step (FR-009…FR-016)', () {
    testWidgets('a new order writes nothing on mount and shows the customer '
        'search, not the facts view', (tester) async {
      await pumpWorkspace(tester);

      verifyNever(() => salesOrders.open(
        customer: any(named: 'customer'),
        salesperson: any(named: 'salesperson'),
        fulfillmentIntent: any(named: 'fulfillmentIntent'),
      ));
      expect(find.byKey(const Key('pos_customer_picker')), findsOneWidget);
      // Nothing else to fill in yet — no product search, no header panel.
      expect(find.byKey(const Key('pos_product_search_field')), findsNothing);
    });

    testWidgets('the generic walk-in customer never appears in results '
        '(FR-011, SC-004)', (tester) async {
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer(
        (_) async => const CustomerPage(
          items: [
            CustomerListItem(
              customerId: 1,
              code: 'C-1',
              name: 'PÚBLICO EN GENERAL',
              creditLimit: '0',
              creditDays: 0,
              priceList: PriceListRef(id: 1, name: 'Mostrador'),
              status: EntityStatus.active,
            ),
          ],
          total: 1,
        ),
      );

      await pumpWorkspace(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PUBLICO',
      );
      await tester.pumpAndSettle();

      expect(find.text('C-1 — PÚBLICO EN GENERAL'), findsNothing);
    });

    testWidgets('picking a customer opens the draft with that customer and '
        'an intent to deliver in one request, then advances to Venta '
        '(FR-014, FR-015)', (tester) async {
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer((_) async => const CustomerPage(items: [_realCustomer], total: 1));
      final opened = testSale(customer: 7, fulfillmentIntent: FulfillmentMode.delivery);
      when(
        () => salesOrders.open(
          customer: 7,
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: FulfillmentMode.delivery,
        ),
      ).thenAnswer((_) async => opened);
      // The `/sales/orders/new` → `/sales/orders/<id>` URL rewrite mounts a
      // brand-new `OrderWorkspaceScreen`, which re-reads the order by id.
      when(
        () => salesOrders.getById(saleId: opened.id),
      ).thenAnswer((_) async => opened);

      await pumpWorkspace(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PINOS',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-7 — FERRETERÍA LOS PINOS'));
      await tester.pumpAndSettle();

      // Exactly one request, carrying the customer and the intent together
      // — never a create followed by a correcting update (research R3).
      verify(
        () => salesOrders.open(
          customer: 7,
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: FulfillmentMode.delivery,
        ),
      ).called(1);
      verifyNever(
        () => salesOrders.updateHeader(
          saleId: any(named: 'saleId'),
          customer: any(named: 'customer'),
        ),
      );
      // Venta is now showing: the product search field is the tell.
      expect(find.byKey(const Key('pos_product_search_field')), findsOneWidget);
      expect(find.byKey(const Key('pos_customer_picker')), findsNothing);
    });
  });

  group('the Venta step (FR-017…FR-023)', () {
    // Reaches Venta the same way a real user does — via the Cliente step's
    // attach — exercising the URL rewrite's own re-derivation of the step
    // from the order's state (research R2), not a shortcut around it.
    Future<ProviderContainer> pumpOnVenta(WidgetTester tester, {int lineCount = 0}) async {
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer((_) async => const CustomerPage(items: [_realCustomer], total: 1));
      final opened = testSale(
        customer: 7,
        fulfillmentIntent: FulfillmentMode.delivery,
        lines: lineCount == 0 ? const [] : [testLine(id: 5)],
      );
      when(
        () => salesOrders.open(
          customer: 7,
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: FulfillmentMode.delivery,
        ),
      ).thenAnswer((_) async => opened);
      when(
        () => salesOrders.getById(saleId: opened.id),
      ).thenAnswer((_) async => opened);

      final container = await pumpWorkspace(tester);
      await tester.enterText(find.byKey(const Key('pos_customer_picker')), 'PINOS');
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-7 — FERRETERÍA LOS PINOS'));
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('the fulfilment-mode selector is never rendered (FR-021)', (
      tester,
    ) async {
      await pumpOnVenta(tester);
      expect(find.byType(FulfillmentModeSelector), findsNothing);
    });

    testWidgets('the forward action is labelled for delivery, disabled with '
        'no lines (FR-022)', (tester) async {
      await pumpOnVenta(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      expect(find.text(l10n.salesOrderContinueToDeliveryAction), findsOneWidget);
      final button = tester.widget<FloatingActionButton>(
        find.byKey(const Key('pos_continue_to_payment')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('the forward action enables with at least one line', (
      tester,
    ) async {
      await pumpOnVenta(tester, lineCount: 1);
      final button = tester.widget<FloatingActionButton>(
        find.byKey(const Key('pos_continue_to_payment')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('choosing "Continuar a entrega" advances to Entrega', (
      tester,
    ) async {
      await pumpOnVenta(tester, lineCount: 1);
      await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
      await tester.pumpAndSettle();

      // Entrega is now showing: its own destinations empty-state/add action
      // replaces Venta's product search field.
      expect(find.byKey(const Key('pos_product_search_field')), findsNothing);
      expect(find.byKey(const Key('delivery_add_destination_button')), findsOneWidget);
    });
  });
}
