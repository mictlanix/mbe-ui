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
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_refund_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/pos_sale_status_chip.dart';
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

const _create = 1;
const _read = 2;
const _update = 4;

User _user({int paymentRights = _read, bool withPayments = true}) => User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    const Privilege(systemObject: SystemObject.salesOrders, rawValue: 2),
    if (withPayments)
      Privilege(
        systemObject: SystemObject.customerPayments,
        rawValue: paymentRights,
      ),
  ],
);

SalePayment _applied(int id, {bool cancelled = false}) => SalePayment(
  id: id,
  customerPayment: 18000 + id,
  amount: '500.00',
  methodCode: 1,
  currency: Currency.mxn,
  changeAmount: '0.00',
  cancelled: cancelled,
  type: PaymentType.immediate,
  paymentDate: DateTime(2026, 11, 12, 18, 2),
);

/// Spec 059 C6 (T016–T018): the "Pagos" action in the Pedidos header and the
/// dialog it opens.
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
        search: any(named: 'search'),
        mine: any(named: 'mine'),
        status: any(named: 'status'),
        customerId: any(named: 'customerId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const RefundListResult(items: [], total: 0));
    when(
      () => payments.listForOrder(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => [_applied(9), _applied(10, cancelled: true)]);
  });

  Sale order(SaleStatus status) => testSale(
    id: 42,
    serial: 1234,
    lines: [testLine()],
    status: status,
    balance: status == SaleStatus.paid ? '0' : '116.00',
    origin: SaleOrigin.backOffice,
  );

  void stubOrder(SaleStatus status) => when(
    () => salesOrders.getById(saleId: 42),
  ).thenAnswer((_) async => order(status));

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

  final button = find.byKey(const Key('sales_order_payments_button'));
  final dialog = find.byKey(const Key('sales_order_payments_dialog'));

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  group('visibility (FR-016)', () {
    for (final status in [SaleStatus.completed, SaleStatus.paid]) {
      testWidgets('shown for a ${status.name} order with payments read', (
        tester,
      ) async {
        stubOrder(status);
        await pumpOrder(tester);

        expect(button, findsOneWidget);
        expect(find.text('Pagos'), findsOneWidget);
      });
    }

    for (final status in [SaleStatus.draft, SaleStatus.cancelled]) {
      testWidgets('hidden for a ${status.name} order', (tester) async {
        stubOrder(status);
        await pumpOrder(tester);

        expect(button, findsNothing);
      });
    }

    testWidgets('hidden without Customer Payments read', (tester) async {
      stubOrder(SaleStatus.paid);
      await pumpOrder(tester, user: _user(withPayments: false));

      expect(button, findsNothing);
    });
  });

  group('the dialog', () {
    testWidgets('lists live and reversed applications of the order', (
      tester,
    ) async {
      stubOrder(SaleStatus.paid);
      await pumpOrder(tester);

      await openDialog(tester);

      expect(dialog, findsOneWidget);
      expect(find.text('Pagos del pedido #42'), findsOneWidget);
      expect(find.byKey(const Key('applied_payment_9')), findsOneWidget);
      expect(find.byKey(const Key('applied_payment_10')), findsOneWidget);
      verify(() => payments.listForOrder(saleId: 42)).called(1);
    });

    testWidgets('says so when nothing has been applied', (tester) async {
      stubOrder(SaleStatus.completed);
      when(
        () => payments.listForOrder(saleId: any(named: 'saleId')),
      ).thenAnswer((_) async => const []);
      await pumpOrder(tester);

      await openDialog(tester);

      expect(find.text(l10n.posNoAppliedPayments), findsOneWidget);
    });

    testWidgets('shows the forbidden text when the server refuses the list', (
      tester,
    ) async {
      stubOrder(SaleStatus.paid);
      when(
        () => payments.listForOrder(saleId: any(named: 'saleId')),
      ).thenThrow(const AppError.server(statusCode: 403));
      await pumpOrder(tester);

      await openDialog(tester);

      expect(find.text(l10n.posSaleDetailPaymentsForbidden), findsOneWidget);
    });

    testWidgets('has no reverse icon without Customer Payments update', (
      tester,
    ) async {
      stubOrder(SaleStatus.paid);
      await pumpOrder(tester);

      await openDialog(tester);

      expect(
        find.descendant(of: dialog, matching: find.byIcon(Icons.undo)),
        findsNothing,
      );
    });

    testWidgets('a row opens its payment and closes the dialog', (
      tester,
    ) async {
      stubOrder(SaleStatus.paid);
      final router = await pumpOrder(tester);

      await openDialog(tester);
      await tester.tap(find.byKey(const Key('applied_payment_open_18009')));
      await tester.pumpAndSettle();

      expect(dialog, findsNothing);
      expect(router.state.uri.path, '/sales/payments/18009');
    });

    testWidgets('reversing names the amount and order, sends the reason, and '
        'the order\'s status follows', (tester) async {
      var reads = 0;
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async {
        reads++;
        return order(reads == 1 ? SaleStatus.paid : SaleStatus.completed);
      });
      when(
        () => payments.reverseApplication(
          customerPaymentId: any(named: 'customerPaymentId'),
          applicationId: any(named: 'applicationId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {});
      await pumpOrder(
        tester,
        user: _user(paymentRights: _read | _update | _create),
      );
      expect(
        find.text(posSaleStatusLabel(l10n, SaleStatus.paid)),
        findsWidgets,
      );

      await openDialog(tester);
      await tester.tap(
        find.descendant(of: dialog, matching: find.byIcon(Icons.undo)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(r'$500.00 MXN aplicados al pedido #42.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('reversal_reason_field')),
        'Aplicado al pedido equivocado',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('reversal_reason_confirm')));
      await tester.pumpAndSettle();

      verify(
        () => payments.reverseApplication(
          customerPaymentId: 18009,
          applicationId: 9,
          reason: 'Aplicado al pedido equivocado',
        ),
      ).called(1);
      expect(reads, greaterThanOrEqualTo(2));
      expect(
        find.text(posSaleStatusLabel(l10n, SaleStatus.paid)),
        findsNothing,
      );
      expect(
        find.text(posSaleStatusLabel(l10n, SaleStatus.completed)),
        findsWidgets,
      );
    });
  });
}
