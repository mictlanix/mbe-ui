import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_detail_screen.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

class _MockSalesOrders extends Mock implements SalesOrderRepository {}

class _FixedAuth extends AuthNotifier {
  _FixedAuth(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Spec 069 US8 (T037): "Agregar desde pedido". The shared harness has no
/// sales-orders repository, so this file builds its own small app around the
/// transfer detail screen.
void main() {
  late AppLocalizations l10n;
  late InventoryHarness h;
  late _MockSalesOrders orders;
  late ProviderContainer container;

  final order = OpenSale(
    id: 55,
    serial: 1234,
    customerDisplayName: 'Ana Pérez',
    total: '100',
    balance: '0',
    status: SaleStatus.completed,
    date: DateTime(2026, 11, 10),
  );

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(SaleStatus.completed);
  });

  User user({int transfers = 15, bool salesOrdersRead = true}) => User(
    userId: 'clerk',
    email: 'clerk@example.com',
    administrator: false,
    status: EntityStatus.active,
    sessionVersion: 1,
    privileges: [
      Privilege(
        systemObject: SystemObject.inventoryTransfers,
        rawValue: transfers,
      ),
      if (salesOrdersRead)
        const Privilege(systemObject: SystemObject.salesOrders, rawValue: 2),
    ],
  );

  Future<void> pump(
    WidgetTester tester,
    InventoryTransfer transfer, {
    User? who,
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    when(() => h.transfers.get(transfer.id)).thenAnswer((_) async => transfer);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authProvider.overrideWith(
          () => _FixedAuth(
            AuthState.authenticated(token: 't', user: who ?? user()),
          ),
        ),
        inventoryTransferRepositoryProvider.overrideWithValue(h.transfers),
        salesOrderRepositoryProvider.overrideWithValue(orders),
        warehouseDisplayNameProvider.overrideWith(
          (ref, id) async => 'Almacén $id',
        ),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => 'Sucursal $id',
        ),
        employeeDisplayNameProvider.overrideWith(
          (ref, id) async => 'Empleado $id',
        ),
        inputDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/t',
            routes: [
              GoRoute(
                path: '/t',
                builder: (_, _) =>
                    InventoryTransferDetailScreen(transferId: transfer.id),
              ),
            ],
          ),
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    h = InventoryHarness();
    orders = _MockSalesOrders();
    when(
      () => orders.listOrders(
        search: any(named: 'search'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => OpenSalePage(items: [order], total: 1));
  });

  Future<void> open(WidgetTester tester, [InventoryTransfer? transfer]) async {
    await pump(tester, transfer ?? aTransfer());
    await tester.tap(key('inventory_transfer_add_from_order'));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: key('inventory_transfer_from_order_picker'),
        matching: find.byType(TextField),
      ),
      '12',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('1234 · Ana Pérez').last);
    await tester.pumpAndSettle();
  }

  void stubAdd(InventoryTransfer after) => when(
    () => h.transfers.addSalesOrderItems(412, salesOrderId: 55),
  ).thenAnswer((_) async => after);

  testWidgets('the search lists completed orders with no customer or '
      'facility', (tester) async {
    await open(tester);

    await choose(tester);

    // Named arguments the call didn't pass don't match: no customer, no
    // facility.
    verify(
      () => orders.listOrders(
        search: '12',
        status: SaleStatus.completed,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('Agregar is off until an order is chosen, then adds it by id '
      'and says how many products were added', (tester) async {
    stubAdd(
      aTransfer(
        lines: [
          aTransferLine(),
          aTransferLine(id: 901, productId: 8),
          aTransferLine(id: 902, productId: 9),
        ],
      ),
    );
    await open(tester);
    expect(
      tester
          .widget<ButtonStyleButton>(
            key('inventory_transfer_from_order_submit'),
          )
          .onPressed,
      isNull,
    );

    await choose(tester);
    await tester.tap(key('inventory_transfer_from_order_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.transfers.addSalesOrderItems(412, salesOrderId: 55),
    ).called(1);
    expect(key('inventory_transfer_from_order_dialog'), findsNothing);
    expect(find.text(l10n.inventoryTransferFromOrderAdded(2)), findsOneWidget);
  });

  testWidgets('says the products were already there when nothing was added', (
    tester,
  ) async {
    stubAdd(aTransfer());
    await open(tester);

    await choose(tester);
    await tester.tap(key('inventory_transfer_from_order_submit'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.inventoryTransferFromOrderNone), findsOneWidget);
  });

  testWidgets('sales_order.not_confirmed shows in Spanish with the dialog '
      'still open', (tester) async {
    final refusal = aRefusal(
      api.ErrorCode.salesOrderPeriodNotConfirmed,
      'sales_order.not_confirmed',
    );
    when(
      () => h.transfers.addSalesOrderItems(412, salesOrderId: 55),
    ).thenAnswer((_) async => throw refusal);
    await open(tester);

    await choose(tester);
    await tester.tap(key('inventory_transfer_from_order_submit'));
    await tester.pumpAndSettle();

    expect(key('inventory_transfer_from_order_dialog'), findsOneWidget);
    expect(
      find.text(
        refusal.localizedMessage(l10n, container.read(formattersProvider))!,
      ),
      findsOneWidget,
    );
    expect(find.text('SERVER TEXT'), findsNothing);
  });

  group('the button', () {
    testWidgets('shows on a draft with update on 17 and read on sales orders', (
      tester,
    ) async {
      await pump(tester, aTransfer());
      expect(key('inventory_transfer_add_from_order'), findsOneWidget);
    });

    testWidgets('is absent without read on sales orders', (tester) async {
      await pump(tester, aTransfer(), who: user(salesOrdersRead: false));
      expect(key('inventory_transfer_add_from_order'), findsNothing);
    });

    testWidgets('is absent without update on 17', (tester) async {
      await pump(tester, aTransfer(), who: user(transfers: 2));
      expect(key('inventory_transfer_add_from_order'), findsNothing);
    });

    testWidgets('is absent on a dispatched transfer', (tester) async {
      await pump(
        tester,
        aTransfer(serial: 77, status: InventoryTransferStatus.inTransit),
      );
      expect(key('inventory_transfer_add_from_order'), findsNothing);
    });
  });
}
