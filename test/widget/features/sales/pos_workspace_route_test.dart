import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/app_navigation.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

const _registerPointSale = 3;

Customer _customer({int id = 7}) => Customer(
  customerId: id,
  code: 'C-$id',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'Mostrador'),
  shipping: false,
  shippingRequiredDocument: false,
  status: EntityStatus.active,
);

/// spec 023 contracts/pos-workspace.md §1, §6 — routing, the `/new` → real-id
/// URL rewrite, the unreachable-sale panel, and the Back button's
/// discard-if-empty behaviour.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late MockCashSessionRepository cashSessions;
  late MockPointSaleRepository pointSales;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    cashSessions = MockCashSessionRepository();
    pointSales = MockPointSaleRepository();

    when(() => cashSessions.getCurrent()).thenAnswer(
      (_) async => const CurrentSession(state: SessionState.open),
    );
    when(() => customers.get(customerId: any(named: 'customerId')))
        .thenAnswer((_) async => _customer());
    when(() => payments.outstandingBalanceFor(customerId: any(named: 'customerId')))
        .thenAnswer((_) async => '0');
    when(() => pointSales.get(pointSaleId: any(named: 'pointSaleId'))).thenAnswer(
      (_) async => const PointSale(
        pointSaleId: _registerPointSale,
        facilityId: 9,
        facilityName: 'Matriz',
        code: 'PS-1',
        name: 'Caja 1',
        warehouseId: 1,
        warehouseName: 'Principal',
        status: EntityStatus.active,
      ),
    );
    for (final status in SaleStatus.values) {
      if (status == SaleStatus.cancelled) continue;
      when(
        () => salesOrders.listOpen(
          pointSale: any(named: 'pointSale'),
          status: status,
          dateFrom: any(named: 'dateFrom'),
        ),
      ).thenAnswer((_) async => const OpenSalePage(items: [], total: 0));
    }
  });

  List<Override> overrides({int? registerPointSaleId = _registerPointSale}) => [
    authNotifierProvider.overrideWith(
      () => _FixedAuthNotifier(
        AuthState.authenticated(
          token: 't',
          user: User(
            userId: 'cashier-1',
            email: 'cashier@example.com',
            administrator: false,
            status: EntityStatus.active,
            sessionVersion: 1,
            settings: registerPointSaleId == null
                ? null
                : UserSettings(pointSaleId: registerPointSaleId),
            privileges: const [],
          ),
        ),
      ),
    ),
    salesOrderOverride(salesOrders),
    warehouseOverride(warehouses),
    customerRepositoryProvider.overrideWithValue(customers),
    customerPaymentOverride(payments),
    cashSessionRepositoryProvider.overrideWithValue(cashSessions),
    pointSaleRepositoryProvider.overrideWithValue(pointSales),
  ];

  group('/sales/pos/new — nothing is created until the first action', () {
    testWidgets('mounts with no sale and calls open() zero times', (
      tester,
    ) async {
      final (router, _) = await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/new',
        overrides: overrides(),
      );

      verifyNever(() => salesOrders.open());
      expect(router.state.uri.path, '/sales/pos/new');
    });

    testWidgets(
      'the first action opens the sale and rewrites the URL to /sales/pos/<id>',
      (tester) async {
        when(() => salesOrders.open()).thenAnswer((_) async => testSale(id: 99));

        final (router, container) = await pumpPosRouted(
          tester,
          initialLocation: '/sales/pos/new',
          overrides: overrides(),
        );

        await container.read(posSaleControllerProvider.notifier).ensureOpen();
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/sales/pos/99');
        verify(() => salesOrders.open()).called(1);
      },
    );
  });

  group('/sales/pos/:saleId — loads the existing sale, never opens a new one', () {
    testWidgets('calls getById with that id, and never open()', (tester) async {
      when(() => salesOrders.getById(saleId: 42))
          .thenAnswer((_) async => testSale(id: 42));

      final (router, _) = await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/42',
        overrides: overrides(),
      );

      expect(router.state.uri.path, '/sales/pos/42');
      verify(() => salesOrders.getById(saleId: 42)).called(1);
      verifyNever(() => salesOrders.open());
    });
  });

  group('an unreachable sale (contracts/pos-workspace.md §1.2)', () {
    testWidgets('an unknown sale (404) renders the unreachable panel, opening no sale', (
      tester,
    ) async {
      when(() => salesOrders.getById(saleId: 999))
          .thenThrow(const AppError.notFound());

      await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/999',
        overrides: overrides(),
      );

      expect(find.byKey(const Key('pos_sale_unreachable')), findsOneWidget);
      verifyNever(() => salesOrders.open());
    });

    testWidgets('a cancelled sale renders the unreachable panel', (tester) async {
      when(() => salesOrders.getById(saleId: 5))
          .thenAnswer((_) async => testSale(id: 5, status: SaleStatus.cancelled));

      await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/5',
        overrides: overrides(),
      );

      expect(find.byKey(const Key('pos_sale_unreachable')), findsOneWidget);
    });

    testWidgets('a sale belonging to another register renders the unreachable panel', (
      tester,
    ) async {
      when(() => salesOrders.getById(saleId: 6)).thenAnswer(
        (_) async => testSale(id: 6, pointSale: 999),
      );

      await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/6',
        overrides: overrides(registerPointSaleId: _registerPointSale),
      );

      expect(find.byKey(const Key('pos_sale_unreachable')), findsOneWidget);
    });
  });

  group('Back discards an empty draft (contracts/pos-workspace.md §6)', () {
    testWidgets('cancels the empty draft, then returns to the list', (
      tester,
    ) async {
      when(() => salesOrders.open())
          .thenAnswer((_) async => testSale(id: 77, lines: const []));
      when(() => salesOrders.cancel(saleId: 77)).thenAnswer((_) async {});
      when(
        () => salesOrders.listSales(
          pointSale: any(named: 'pointSale'),
          status: any(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const OpenSalePage(items: [], total: 0));

      final (router, container) = await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos',
        overrides: overrides(),
      );

      router.push('/sales/pos/new');
      await tester.pumpAndSettle();

      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/sales/pos/77');

      await tester.tap(find.byKey(const Key('pos_workspace_back')));
      await tester.pumpAndSettle();

      verify(() => salesOrders.cancel(saleId: 77)).called(1);
      expect(router.state.uri.path, '/sales/pos');
    });
  });

  group(
    'layout: no rail, no bounded width, one footer band '
    '(contracts/pos-workspace.md §2, §3)',
    () {
      testWidgets('no AppNavigation rail is present', (tester) async {
        when(() => salesOrders.getById(saleId: 10))
            .thenAnswer((_) async => testSale(id: 10, lines: [testLine()]));
        when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
            .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

        await pumpPosRouted(
          tester,
          initialLocation: '/sales/pos/10',
          overrides: overrides(),
          surface: const Size(1440, 900),
        );

        expect(find.byType(AppNavigation), findsNothing);
        expect(find.byType(NavigationDrawer), findsNothing);
      });

      testWidgets(
        'the capture surface spans the full window width — nothing bounds '
        'or centres it',
        (tester) async {
          when(() => salesOrders.getById(saleId: 11))
              .thenAnswer((_) async => testSale(id: 11, lines: [testLine()]));
          when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
              .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

          const width = 1440.0;
          await pumpPosRouted(
            tester,
            initialLocation: '/sales/pos/11',
            overrides: overrides(),
            surface: const Size(width, 900),
          );

          final totalsBarWidth = tester.getSize(find.byType(SaleTotalsBar)).width;
          expect(
            totalsBarWidth,
            width,
            reason:
                'the footer band is a direct, unbounded child of the '
                'workspace body — it should span the same width the '
                'Scaffold itself renders at, not a narrower centred column',
          );
        },
      );

      testWidgets(
        'the primary action lives inside SaleTotalsBar — one footer band, '
        'not two',
        (tester) async {
          when(() => salesOrders.getById(saleId: 12))
              .thenAnswer((_) async => testSale(id: 12, lines: [testLine()]));
          when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
              .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

          await pumpPosRouted(
            tester,
            initialLocation: '/sales/pos/12',
            overrides: overrides(),
            surface: const Size(1440, 900),
          );

          expect(
            find.descendant(
              of: find.byType(SaleTotalsBar),
              matching: find.byKey(const Key('pos_continue_to_payment')),
            ),
            findsOneWidget,
          );
        },
      );
    },
  );
}
