import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_screen.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_screen.dart';

import 'pos_test_harness.dart';
import 'sales_orders_list_screen_test.dart' show stubListOrders;

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

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

/// Update rights, no create — enough to see priority stay editable on a
/// finished order (US4 scenario 2) without also seeing "New order".
const _updaterUser = User(
  userId: 'order-updater',
  email: 'order-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: UserSettings(facilityId: 9),
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 4)],
);

/// Read only — US4 scenario 4's user: browses and reads, nothing else.
const _readerUser = User(
  userId: 'order-reader',
  email: 'order-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: UserSettings(facilityId: 9),
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 2)],
);

/// Spec 032 FR-004/FR-005: currency, priority and comment now live behind a
/// disclosure that is closed on arrival. Their *gating* is what these tests
/// are about, so they open it and then assert exactly as before.
Future<void> _expandDetails(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('sales_order_more_details_toggle')));
  await tester.pumpAndSettle();
}

Override _authOverride(User user) => authNotifierProvider.overrideWith(
  () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: user)),
);

/// FR-027 (spec 029): a confirmed, paid or cancelled order renders
/// read-only — priority the single field a privileged user may still
/// change — and a read-only user sees no mutating affordance anywhere,
/// neither on the order screen nor on the list it comes from.
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
    required User user,
    int orderId = 42,
  }) => pumpPos(
    tester,
    OrderScreen(orderId: orderId),
    overrides: [
      _authOverride(user),
      salesOrderOverride(salesOrders),
      warehouseOverride(warehouses),
      customerRepositoryProvider.overrideWithValue(customers),
      customerPaymentOverride(payments),
    ],
  );

  for (final entry in {
    'a confirmed order': SaleStatus.completed,
    'a cancelled order': SaleStatus.cancelled,
  }.entries) {
    group('${entry.key} (US4 scenario 1)', () {
      setUp(() {
        when(() => salesOrders.getById(saleId: 42)).thenAnswer(
          (_) async => testSale(id: 42, status: entry.value, lines: [testLine()]),
        );
      });

      testWidgets('renders read-only — no add-line, no confirm, no cancel', (
        tester,
      ) async {
        await pumpOrderScreen(tester, user: _updaterUser);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('sales_order_confirm_button')), findsNothing);
        expect(find.byKey(const Key('sales_order_cancel_button')), findsNothing);

        await _expandDetails(tester);

        final currency = tester.widget<DropdownButtonFormField<Currency>>(
          find.byKey(const Key('sales_order_currency_field')),
        );
        expect(currency.onChanged, isNull);

        final salesperson = tester.widget<CatalogEntityPicker<EmployeeListItem>>(
          find.byKey(const Key('sales_order_salesperson_field')),
        );
        expect(salesperson.enabled, isFalse);

        // `fieldKey` lands on the inner `TextField`, not the
        // `ConfirmableTextField` wrapper itself.
        final comment = tester.widget<TextField>(
          find.byKey(const Key('sales_order_comment_field')),
        );
        expect(comment.enabled, isFalse);
      });

      testWidgets(
        'priority alone stays editable for a user with update rights '
        '(US4 scenario 2)',
        (tester) async {
          await pumpOrderScreen(tester, user: _updaterUser);
          await tester.pumpAndSettle();
          await _expandDetails(tester);

          final priority = tester.widget<DropdownButtonFormField<Priority>>(
            find.byKey(const Key('sales_order_priority_field')),
          );
          expect(priority.onChanged, isNotNull);
        },
      );

      testWidgets(
        'a read-only user sees no create, edit, confirm or cancel '
        'affordance (US4 scenario 4)',
        (tester) async {
          await pumpOrderScreen(tester, user: _readerUser);
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('sales_order_confirm_button')), findsNothing);
          expect(find.byKey(const Key('sales_order_cancel_button')), findsNothing);

          await _expandDetails(tester);

          final priority = tester.widget<DropdownButtonFormField<Priority>>(
            find.byKey(const Key('sales_order_priority_field')),
          );
          expect(
            priority.onChanged,
            isNull,
            reason: 'priority survives completion but still needs update rights',
          );
        },
      );
    });
  }

  testWidgets(
    'a read-only user sees no New Order action on the list either '
    '(US4 scenario 4)',
    (tester) async {
      stubListOrders(salesOrders, page: testSalesPage(const []));

      await pumpPos(
        tester,
        SalesOrdersListScreen(query: const ListQuery()),
        overrides: [_authOverride(_readerUser), salesOrderOverride(salesOrders)],
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sales_orders_new_order_button')), findsNothing);
    },
  );
}
