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
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_screen.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

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
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 4)],
);

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// US2: a draft survives being left, reopens editable, and a mutation
/// refused because it changed underneath re-reads the true state (scenario
/// 5, Edge Cases).
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

  Future<ProviderContainer> pumpOrder(WidgetTester tester, int orderId) => pumpPos(
    tester,
    OrderScreen(orderId: orderId),
    overrides: [
      authNotifierProvider.overrideWith(
        () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: _updaterUser)),
      ),
      salesOrderOverride(salesOrders),
      warehouseOverride(warehouses),
      customerRepositoryProvider.overrideWithValue(customers),
      customerPaymentOverride(payments),
    ],
  );

  testWidgets('reopening an existing order loads header and lines editable', (
    tester,
  ) async {
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(id: 42, serial: 100, lines: [testLine()]),
    );

    await pumpOrder(tester, 42);
    await tester.pumpAndSettle();

    expect(find.text('100'), findsOneWidget, reason: 'the folio, shown as the reference');
    expect(find.byKey(const Key('sale_line_discount_5')), findsOneWidget);
  });

  testWidgets('removing the last line leaves a zero-total draft with confirm '
      'unavailable', (tester) async {
    final withLine = testSale(id: 42, lines: [testLine()]);
    when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => withLine);
    when(() => salesOrders.removeLine(saleId: 42, lineId: 5)).thenAnswer(
      (_) async => testSale(id: 42, total: '0', balance: '0'),
    );

    await pumpOrder(tester, 42);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Eliminar línea'));
    await tester.pumpAndSettle();

    final button = tester.widget<FloatingActionButton>(
      find.byKey(const Key('sales_order_confirm_button')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets(
    "a stale draft's refused header edit refreshes to the order's true "
    'state',
    (tester) async {
      final draft = testSale(id: 42, lines: [testLine()]);
      final nowConfirmed = testSale(
        id: 42,
        serial: 200,
        lines: [testLine()],
        status: SaleStatus.completed,
      );
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => draft);

      await pumpOrder(tester, 42);
      await tester.pumpAndSettle();

      // The order was confirmed elsewhere between load and this edit.
      when(() => salesOrders.confirm(saleId: 42))
          .thenThrow(const AppError.server(message: 'Order is already confirmed'));
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => nowConfirmed);

      await tester.tap(find.byKey(const Key('sales_order_confirm_button')));
      await tester.pumpAndSettle();

      expect(find.text('200'), findsOneWidget, reason: 'the screen now shows the real folio');
      expect(find.byKey(const Key('sales_order_confirm_button')), findsNothing);
    },
  );
}
