import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_header_panel.dart';
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

const _user = User(
  userId: 'order-updater',
  email: 'order-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: UserSettings(facilityId: 9),
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 7)],
);

Override _authOverride() => authNotifierProvider.overrideWith(
  () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: _user)),
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

/// FR-034, constitution §VI (spec 029): both Sales Orders screens at 390 px
/// — a phone at the counter — reachable by vertical scroll alone, nothing
/// forcing the page sideways (`pos_compact_layout_test.dart`'s own SC-007/
/// FR-053 rule, extended to this feature's screens).
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

  testWidgets(
    'the list renders at 390 px with no horizontal overflow of the page '
    'body',
    (tester) async {
      stubListOrders(
        salesOrders,
        page: testSalesPage([testOpenSale(id: 1, status: SaleStatus.draft)]),
      );

      await pumpPos(
        tester,
        SalesOrdersListScreen(query: const ListQuery()),
        surface: phoneSurface,
        overrides: [_authOverride(), salesOrderOverride(salesOrders)],
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'the order screen renders at 390 px with lines as SaleLineCard — the '
    'established compact treatment — and no horizontal overflow',
    (tester) async {
      when(() => salesOrders.getById(saleId: 42)).thenAnswer(
        (_) async => testSale(id: 42, lines: [testLine()]),
      );

      await pumpPos(
        tester,
        const OrderScreen(orderId: 42),
        surface: phoneSurface,
        overrides: [
          _authOverride(),
          salesOrderOverride(salesOrders),
          warehouseOverride(warehouses),
          customerRepositoryProvider.overrideWithValue(customers),
          customerPaymentOverride(payments),
        ],
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(LayoutBreakpoints.isCompact(tester.element(find.byType(OrderHeaderPanel))), isTrue);
      // `OrderHeaderPanel`'s `ResponsiveFormGrid` measures its own width
      // (not `MediaQuery`) and collapses to one column below its first
      // breakpoint — already covered generically by
      // `responsive_form_grid_test.dart`; this only confirms the panel
      // still renders every field without overflowing at this width.
      // Currency and priority moved behind the disclosure in spec 032
      // FR-004, so the compact check has to open it first. spec 037 FR-011
      // moved `OrderHeaderPanel` below `CustomerBar`, pushing the toggle far
      // enough down this compact `ListView` that it's no longer reliably
      // inside the initial viewport — scroll it into view before tapping,
      // the same treatment this test already gives `SaleLineCard` below.
      await tester.ensureVisible(
        find.byKey(const Key('sales_order_more_details_toggle')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sales_order_more_details_toggle')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sales_order_currency_field')), findsOneWidget);
      expect(find.byKey(const Key('sales_order_priority_field')), findsOneWidget);

      // The compact body puts header and lines in one `ListView` — the
      // line lives below the fold at this height, so it must be scrolled
      // into view before a finder can see it (a lazily-built sliver child
      // that's off-screen simply isn't mounted yet).
      for (var i = 0; i < 10 && find.byType(SaleLineCard).evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      // `SaleLineRow` is the wide-tier arrangement of the very same data
      // (`sale_line_row.dart` doc comment) — its absence here, alongside
      // the card, confirms the compact swap actually happened rather than
      // both just being present.
      expect(find.byType(SaleLineCard), findsOneWidget);
      expect(find.byType(SaleLineRow), findsNothing);
    },
  );
}
