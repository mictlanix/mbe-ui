import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_refund_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

User _user({int refundRights = 3}) => User(
  userId: 'refunder',
  email: 'refunder@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    const Privilege(systemObject: SystemObject.salesOrders, rawValue: 2),
    if (refundRights != 0)
      Privilege(
        systemObject: SystemObject.customerRefunds,
        rawValue: refundRights,
      ),
  ],
);

/// Spec 057 US1 (T023), contracts C3 and R9: "Devolver" in the Pedidos
/// header, shown for a paid order only, and what a tap does.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRefundRepository refunds;
  late _MockCustomerRepository customers;
  late _MockDeliveryOrderRepository deliveries;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    refunds = MockCustomerRefundRepository();
    customers = _MockCustomerRepository();
    deliveries = _MockDeliveryOrderRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    when(() => customers.get(customerId: any(named: 'customerId'))).thenAnswer(
      (_) async => const Customer(
        customerId: 7,
        code: 'C-7',
        name: 'FERRETERÍA LOS PINOS',
        creditLimit: '0',
        creditDays: 0,
        priceList: PriceListRef(id: 1, name: 'Mostrador'),
        status: EntityStatus.active,
      ),
    );
    when(
      () =>
          payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => const []);
    when(
      () => refunds.list(
        salesOrderId: any(named: 'salesOrderId'),
        status: any(named: 'status'),
        customerId: any(named: 'customerId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const RefundListResult(items: [], total: 0));
  });

  void stubOrder(SaleStatus status) =>
      when(() => salesOrders.getById(saleId: 42)).thenAnswer(
        (_) async => testSale(
          id: 42,
          serial: 1234,
          lines: [testLine()],
          status: status,
          balance: status == SaleStatus.paid ? '0' : '116.00',
          origin: SaleOrigin.backOffice,
        ),
      );

  Future<GoRouter> pumpOrder(WidgetTester tester, {User? user}) async {
    final (router, _) = await pumpOrdersRouted(
      tester,
      initialLocation: '/sales/orders/42',
      overrides: [
        authProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user ?? _user()),
          ),
        ),
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRefundOverride(refunds),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
      ],
    );
    return router;
  }

  final button = find.byKey(const Key('order_refund_button'));

  group('visibility', () {
    testWidgets('shown for a paid order with create and read access', (
      tester,
    ) async {
      stubOrder(SaleStatus.paid);
      await pumpOrder(tester);

      expect(button, findsOneWidget);
      expect(find.text(l10n.refundAction), findsOneWidget);
    });

    testWidgets('hidden for an unpaid order', (tester) async {
      stubOrder(SaleStatus.completed);
      await pumpOrder(tester);

      expect(button, findsNothing);
    });

    testWidgets('hidden without the create privilege', (tester) async {
      stubOrder(SaleStatus.paid);
      await pumpOrder(tester, user: _user(refundRights: 2));

      expect(button, findsNothing);
    });

    testWidgets('hidden without the read privilege', (tester) async {
      stubOrder(SaleStatus.paid);
      await pumpOrder(tester, user: _user(refundRights: 1));

      expect(button, findsNothing);
    });
  });

  group('a tap', () {
    testWidgets('navigates to the refund on RefundOpened', (tester) async {
      stubOrder(SaleStatus.paid);
      when(() => refunds.open(42)).thenAnswer((_) async => testRefund(id: 9));
      final router = await pumpOrder(tester);

      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(() => refunds.open(42)).called(1);
      expect(router.state.uri.path, '/sales/refunds/9');
    });

    testWidgets('resumes an existing draft without opening another', (
      tester,
    ) async {
      stubOrder(SaleStatus.paid);
      when(
        () => refunds.list(
          salesOrderId: 42,
          status: RefundStatus.draft,
          skip: 0,
          limit: 1,
        ),
      ).thenAnswer(
        (_) async => const RefundListResult(
          items: [
            CustomerRefundSummary(
              id: 15,
              salesOrderId: 42,
              currency: Currency.mxn,
              status: RefundStatus.draft,
              total: '0.00',
            ),
          ],
          total: 1,
        ),
      );
      final router = await pumpOrder(tester);

      await tester.tap(button);
      await tester.pumpAndSettle();

      verifyNever(() => refunds.open(any()));
      expect(router.state.uri.path, '/sales/refunds/15');
    });

    testWidgets('shows the refusal in a SnackBar otherwise, and stays', (
      tester,
    ) async {
      stubOrder(SaleStatus.paid);
      when(() => refunds.open(42)).thenThrow(
        const AppError.server(
          statusCode: 409,
          message: 'No refundable items remain on this order',
        ),
      );
      final router = await pumpOrder(tester);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining(l10n.refundRefusalNothingToReturn(42)),
        findsOneWidget,
      );
      expect(
        find.textContaining('No refundable items remain on this order'),
        findsOneWidget,
      );
      expect(router.state.uri.path, '/sales/orders/42');
    });
  });
}
