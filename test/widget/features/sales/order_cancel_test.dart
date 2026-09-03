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
import 'package:mbe_ui/l10n/app_localizations.dart';

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

const _readOnlyUser = User(
  userId: 'order-reader',
  email: 'order-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 2)],
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

/// FR-026: cancel lives only on the order's own screen, requires an
/// explicit confirmation, and a server refusal keeps the order untouched
/// with the message shown.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

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

  Future<ProviderContainer> pumpOrder(
    WidgetTester tester,
    int orderId, {
    User? user,
  }) => pumpPos(
    tester,
    OrderScreen(orderId: orderId),
    overrides: [
      authNotifierProvider.overrideWith(
        () => _FixedAuthNotifier(
          AuthState.authenticated(token: 't', user: user ?? _updaterUser),
        ),
      ),
      salesOrderOverride(salesOrders),
      warehouseOverride(warehouses),
      customerRepositoryProvider.overrideWithValue(customers),
      customerPaymentOverride(payments),
    ],
  );

  testWidgets('the cancel action is absent without update rights', (
    tester,
  ) async {
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(id: 42, lines: [testLine()]),
    );

    await pumpOrder(tester, 42, user: _readOnlyUser);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sales_order_cancel_button')), findsNothing);
  });

  testWidgets('cancelling requires an explicit confirmation dialog', (
    tester,
  ) async {
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(id: 42, lines: [testLine()]),
    );

    await pumpOrder(tester, 42);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sales_order_cancel_button')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.salesOrderCancelDialogTitle), findsOneWidget);
    verifyNever(() => salesOrders.cancel(saleId: any(named: 'saleId')));
  });

  testWidgets('confirming the dialog flips status and read-only mode', (
    tester,
  ) async {
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(id: 42, lines: [testLine()]),
    );
    when(() => salesOrders.cancel(saleId: 42)).thenAnswer((_) async {});
    // The controller re-reads the order after `cancel()` — mbe-api's own
    // endpoint returns no body for this call.
    var cancelled = false;
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => cancelled
          ? testSale(id: 42, lines: [testLine()], status: SaleStatus.cancelled)
          : testSale(id: 42, lines: [testLine()]),
    );
    when(() => salesOrders.cancel(saleId: 42)).thenAnswer((_) async {
      cancelled = true;
    });

    await pumpOrder(tester, 42);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sales_order_cancel_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sales_order_cancel_confirm_button')));
    await tester.pumpAndSettle();

    verify(() => salesOrders.cancel(saleId: 42)).called(1);
    expect(find.byKey(const Key('sales_order_cancel_button')), findsNothing);
    expect(find.byKey(const Key('sales_order_confirm_button')), findsNothing);
  });

  testWidgets('a refused cancel keeps the order untouched with the message '
      'shown', (tester) async {
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(id: 42, lines: [testLine()]),
    );
    when(() => salesOrders.cancel(saleId: 42)).thenThrow(
      const AppError.server(message: 'A paid order cannot be cancelled'),
    );

    await pumpOrder(tester, 42);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sales_order_cancel_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sales_order_cancel_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('A paid order cannot be cancelled'), findsOneWidget);
    expect(
      find.byKey(const Key('sales_order_cancel_button')),
      findsOneWidget,
      reason: 'the order is still a draft — cancel is still offered',
    );
  });
}
