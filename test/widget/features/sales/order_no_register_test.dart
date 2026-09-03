import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_screen.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';
import 'sales_orders_list_screen_test.dart' show stubListOrders;

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

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// A user with sales-order create rights but **no point of sale configured**
/// — the FR-014 blocked state. Listing and reading still work; only creating
/// is withheld, and told before the salesperson types anything (spec 029
/// contracts/sales-orders-screen.md §2.6).
const _noRegisterUser = User(
  userId: 'no-register-salesperson',
  email: 'no-register@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: UserSettings(facilityId: 9),
  privileges: [
    Privilege(systemObject: SystemObject.salesOrders, rawValue: 5), // create+read
  ],
);

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

  List<Override> overridesFor(User user) => [
    authNotifierProvider.overrideWith(
      () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: user)),
    ),
    salesOrderOverride(salesOrders),
    warehouseOverride(warehouses),
    customerRepositoryProvider.overrideWithValue(customers),
    customerPaymentOverride(payments),
  ];

  testWidgets(
    'the list still loads, but New order is replaced by the notice',
    (tester) async {
      stubListOrders(salesOrders, page: testSalesPage(const []));

      await pumpPos(
        tester,
        const SalesOrdersListScreen(query: ListQuery()),
        overrides: overridesFor(_noRegisterUser),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sales_orders_new_order_button')), findsNothing);
      expect(
        find.byKey(const Key('sales_order_no_register_notice')),
        findsOneWidget,
      );
      expect(find.text(l10n.salesOrderNoRegisterTitle), findsOneWidget);
      verify(
        () => salesOrders.listOrders(
          mine: any(named: 'mine'),
          facility: any(named: 'facility'),
          salesperson: any(named: 'salesperson'),
          status: any(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
    },
  );

  testWidgets(
    'an already-open order still opens read-write — only creation is '
    'blocked, never the read/edit surface',
    (tester) async {
      when(() => salesOrders.getById(saleId: 42)).thenAnswer(
        (_) async => testSale(id: 42, lines: [testLine()]),
      );

      await pumpPos(
        tester,
        const OrderScreen(orderId: 42),
        overrides: overridesFor(_noRegisterUser),
      );
      await tester.pumpAndSettle();

      verifyNever(() => salesOrders.open());
      expect(find.byKey(const Key('sales_order_confirm_button')), findsOneWidget);
    },
  );
}
