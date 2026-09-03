import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_screen.dart';
import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Holds update on `salesOrders` — the privilege the order screen's confirm
/// and cancel actions gate on (FR-003, constitution §IV). Every test in this
/// file needs it to see the mutating affordances at all.
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

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// FR-015, SC-005: `/sales/orders/new` writes nothing on mount — the order
/// is created by the first action that needs one, mirroring
/// `pos_lazy_open_test.dart`'s coverage of the same rule for the register.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
  });

  Future<ProviderContainer> pumpOrderScreen(
    WidgetTester tester, {
    int? orderId,
  }) {
    return pumpPos(
      tester,
      OrderScreen(orderId: orderId),
      overrides: [
        _authOverride(),
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
      ],
    );
  }

  group('a brand-new order (/sales/orders/new)', () {
    testWidgets('opens no order at all on mount', (tester) async {
      await pumpOrderScreen(tester);

      verifyNever(() => salesOrders.open());
      verifyNever(() => salesOrders.getById(saleId: any(named: 'saleId')));
    });

    testWidgets('confirm is disabled with no lines', (tester) async {
      await pumpOrderScreen(tester);

      final button = tester.widget<FloatingActionButton>(
        find.byKey(const Key('sales_order_confirm_button')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets(
      // spec 036 FR-001/FR-002/FR-003: only the customer bar and a hint
      // render until a specific customer is attached; confirm stays
      // disabled and the generic customer never appears in the picker.
      'shows only the customer bar — no product search field — and the '
      'generic customer is excluded from its picker',
      (tester) async {
        when(
          () => customers.list(search: any(named: 'search'), limit: 10),
        ).thenAnswer(
          (_) async => const CustomerPage(
            items: [
              // id 1 is `posDefaultCustomerId`'s test-time default (no
              // `--dart-define` set) — the actual generic customer, not the
              // unrelated id 7 this file's other fixtures happen to use.
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

        await pumpOrderScreen(tester);

        expect(
          find.byKey(const Key('sales_order_choose_customer_hint')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('sales_order_product_search_field')),
          findsNothing,
        );
        final button = tester.widget<FloatingActionButton>(
          find.byKey(const Key('sales_order_confirm_button')),
        );
        expect(button.onPressed, isNull);

        await tester.tap(find.byKey(const Key('pos_customer_search_button')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('pos_customer_picker')),
          'PUBLICO',
        );
        await tester.pumpAndSettle();
        // The generic customer (id 1, `posDefaultCustomerId`) never appears
        // as a result here — the picker excludes it.
        expect(find.text('C-1 — PÚBLICO EN GENERAL'), findsNothing);
      },
    );

    testWidgets(
      // spec 036 FR-004: reading an order that was already saved against the
      // generic customer before this feature shipped still works correctly
      // — the gate only blocks *new* selections, not existing data.
      'an order already billed to the generic customer still opens and '
      'displays correctly',
      (tester) async {
        when(() => salesOrders.getById(saleId: 99)).thenAnswer(
          (_) async => testSale(id: 99, customer: 1, lines: [testLine()]),
        );

        await pumpOrderScreen(tester, orderId: 99);
        await tester.pumpAndSettle();

        expect(find.text('PÚBLICO EN GENERAL'), findsWidgets);
        expect(
          find.byKey(const Key('sales_order_product_search_field')),
          findsNothing,
          reason:
              'the customer is still the generic one, so the gate still '
              'applies — this only proves the read path itself works',
        );
      },
    );

    testWidgets('the first added line opens the order, then reuses it', (
      tester,
    ) async {
      final container = await pumpOrderScreen(tester);
      final notifier = container.read(orderEditorControllerProvider(null).notifier);

      when(() => salesOrders.open()).thenAnswer((_) async => testSale(id: 500));
      when(
        () => salesOrders.addLine(
          saleId: any(named: 'saleId'),
          product: any(named: 'product'),
          quantity: any(named: 'quantity'),
          price: any(named: 'price'),
          discountRate: any(named: 'discountRate'),
          taxRate: any(named: 'taxRate'),
          warehouse: any(named: 'warehouse'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => testSale(id: 500, lines: [testLine()]));

      await notifier.addLine(product: 11, quantity: '1');
      await notifier.addLine(product: 12, quantity: '1');
      await tester.pumpAndSettle();

      verify(() => salesOrders.open()).called(1);
      expect(
        container.read(orderEditorControllerProvider(null)).valueOrNull?.id,
        500,
      );
    });
  });

  group('an existing order (/sales/orders/:orderId)', () {
    testWidgets('loads it — no open() call', (tester) async {
      when(() => salesOrders.getById(saleId: 42)).thenAnswer(
        (_) async => testSale(id: 42, lines: [testLine()]),
      );

      await pumpOrderScreen(tester, orderId: 42);
      await tester.pumpAndSettle();

      verifyNever(() => salesOrders.open());
      verify(() => salesOrders.getById(saleId: 42)).called(1);
    });

    testWidgets('confirm is enabled with at least one line', (tester) async {
      when(() => salesOrders.getById(saleId: 42)).thenAnswer(
        (_) async => testSale(id: 42, lines: [testLine()]),
      );

      await pumpOrderScreen(tester, orderId: 42);
      await tester.pumpAndSettle();

      final button = tester.widget<FloatingActionButton>(
        find.byKey(const Key('sales_order_confirm_button')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets(
      'a refused confirm names every offending line and leaves the order '
      'a draft',
      (tester) async {
        when(() => salesOrders.getById(saleId: 42)).thenAnswer(
          (_) async => testSale(id: 42, lines: [testLine()]),
        );
        when(() => salesOrders.confirm(saleId: 42)).thenThrow(
          const AppError.server(
            message: 'Widget requires stock but no warehouse is set',
          ),
        );

        await pumpOrderScreen(tester, orderId: 42);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('sales_order_confirm_button')));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Widget requires stock'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('sales_order_confirm_button')),
          findsOneWidget,
          reason: 'the order stays a draft — confirm is still offered',
        );
      },
    );

    testWidgets('a paid order renders read-only — no confirm, no cancel', (
      tester,
    ) async {
      when(() => salesOrders.getById(saleId: 42)).thenAnswer(
        (_) async => testSale(
          id: 42,
          lines: [testLine()],
          status: SaleStatus.paid,
        ),
      );

      await pumpOrderScreen(tester, orderId: 42);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sales_order_confirm_button')), findsNothing);
      expect(find.byKey(const Key('sales_order_cancel_button')), findsNothing);
    });
  });
}
