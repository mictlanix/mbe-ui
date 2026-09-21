import 'package:flutter/material.dart';
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
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

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

const _readOnlyUser = User(
  userId: 'order-reader',
  email: 'order-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 1)],
);

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// Spec 039 US3 / FR-034, re-homed from `order_cancel_test.dart` onto the
/// workspace: cancel is offered on a draft and nowhere else, always behind
/// an explicit confirmation, and a server refusal leaves the order exactly
/// as it was with the reason on screen. The dialog's own keys are the ones
/// the replaced screen used (contracts/order-workspace.md §8) — re-pointed,
/// not reinvented.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late MockDeliveryOrderRepository deliveries;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

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

  Future<void> pumpOrder(WidgetTester tester, {User? user}) async {
    await pumpOrdersRouted(
      tester,
      initialLocation: '/sales/orders/42',
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
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
      ],
    );
  }

  Sale order({SaleStatus status = SaleStatus.draft}) => testSale(
    id: 42,
    lines: [testLine()],
    status: status,
    origin: SaleOrigin.backOffice,
  );

  final cancelAction = find.byKey(const Key('sales_order_cancel_button'));

  testWidgets('the cancel action is absent without update rights', (
    tester,
  ) async {
    when(
      () => salesOrders.getById(saleId: 42),
    ).thenAnswer((_) async => order());

    await pumpOrder(tester, user: _readOnlyUser);

    expect(cancelAction, findsNothing);
  });

  testWidgets('a committed order offers no destructive action', (tester) async {
    when(
      () => salesOrders.getById(saleId: 42),
    ).thenAnswer((_) async => order(status: SaleStatus.completed));

    await pumpOrder(tester);

    expect(cancelAction, findsNothing);
  });

  testWidgets('an already-cancelled order offers no destructive action', (
    tester,
  ) async {
    when(
      () => salesOrders.getById(saleId: 42),
    ).thenAnswer((_) async => order(status: SaleStatus.cancelled));

    await pumpOrder(tester);

    expect(cancelAction, findsNothing);
  });

  testWidgets('cancelling requires an explicit confirmation dialog', (
    tester,
  ) async {
    when(
      () => salesOrders.getById(saleId: 42),
    ).thenAnswer((_) async => order());

    await pumpOrder(tester);
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();

    expect(find.text(l10n.salesOrderCancelDialogTitle), findsOneWidget);
    verifyNever(() => salesOrders.cancel(saleId: any(named: 'saleId')));
  });

  testWidgets('dismissing the dialog cancels nothing', (tester) async {
    when(
      () => salesOrders.getById(saleId: 42),
    ).thenAnswer((_) async => order());

    await pumpOrder(tester);
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.salesOrderCancelDialogKeepEditing));
    await tester.pumpAndSettle();

    verifyNever(() => salesOrders.cancel(saleId: any(named: 'saleId')));
    expect(cancelAction, findsOneWidget);
  });

  testWidgets('confirming the dialog cancels the order and withdraws the '
      'action', (tester) async {
    // mbe-api's cancel returns no body, so the controller re-reads — the
    // second read is the one that must show the new status.
    var cancelled = false;
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => cancelled ? order(status: SaleStatus.cancelled) : order(),
    );
    when(() => salesOrders.cancel(saleId: 42)).thenAnswer((_) async {
      cancelled = true;
    });

    await pumpOrder(tester);
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('sales_order_cancel_confirm_button')),
    );
    await tester.pumpAndSettle();

    verify(() => salesOrders.cancel(saleId: 42)).called(1);
    expect(cancelAction, findsNothing);
  });

  testWidgets('a refused cancel keeps the order untouched with the reason '
      'shown', (tester) async {
    when(
      () => salesOrders.getById(saleId: 42),
    ).thenAnswer((_) async => order());
    when(() => salesOrders.cancel(saleId: 42)).thenThrow(
      const AppError.server(message: 'A paid order cannot be cancelled'),
    );

    await pumpOrder(tester);
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('sales_order_cancel_confirm_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('A paid order cannot be cancelled'),
      findsOneWidget,
    );
    expect(
      cancelAction,
      findsOneWidget,
      reason: 'the order is still a draft — cancel is still offered',
    );
  });
}
