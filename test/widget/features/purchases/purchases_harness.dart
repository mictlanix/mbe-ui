import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/purchase_request_approval_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_list_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_detail_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_list_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockPurchaseRequestRepository extends Mock
    implements PurchaseRequestRepository {}

class MockPurchaseOrderRepository extends Mock
    implements PurchaseOrderRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class MockSupplierRepository extends Mock implements SupplierRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// One `approvalQueue` call's parts, as the queue screen sent them.
typedef ApprovalQueueCall = ({int? facilityId, int skip, int limit});

/// One `list` call's parts, as the list screen sent them.
typedef RequestListCall = ({bool all, int? serial, int skip, int limit});

/// One orders `list` call's parts, as the orders list screen sent them.
typedef OrderListCall = ({bool all, int? orderId, int skip, int limit});

/// A warehouse for the pickers.
Warehouse aWarehouse(int id, {int facilityId = 2}) => Warehouse(
  warehouseId: id,
  facilityId: facilityId,
  facilityName: 'Sucursal $facilityId',
  code: 'W$id',
  name: 'Almacén $id',
  status: EntityStatus.active,
);

/// The Solicitudes de compra screens (spec 079), Por comprar and the
/// purchase orders list and detail (spec 080), with every repository
/// mocked. The session user is configurable: its rights, whether it is an
/// administrator, and its facility and point of sale.
///
/// The display-name providers answer "Almacén {id}", "Sucursal {id}" and
/// "Empleado {id}".
class PurchasesHarness {
  final requests = MockPurchaseRequestRepository();
  final orders = MockPurchaseOrderRepository();
  final warehouses = MockWarehouseRepository();
  final products = MockProductRepository();
  final pointSales = MockPointSaleRepository();
  final suppliers = MockSupplierRepository();

  /// Every `list` call, oldest first.
  final listCalls = <RequestListCall>[];

  /// Every `approvalQueue` call, oldest first.
  final queueCalls = <ApprovalQueueCall>[];

  /// Every orders `list` call, oldest first.
  final orderListCalls = <OrderListCall>[];

  /// The last [pump]'s providers.
  late ProviderContainer container;

  /// The session user. [requestRights] is the raw PurchaseRequest (86) right
  /// (15 = create, read, update and delete); [approvalRights] the raw
  /// PurchaseRequestApproval (96) right and [orderRights] the raw
  /// PurchasesOrders (20) right.
  static User user({
    int requestRights = 15,
    int approvalRights = 0,
    int orderRights = 0,
    bool warehousesRead = true,
    bool productsRead = true,
    bool facilitiesRead = false,
    bool employeesRead = false,
    bool suppliersRead = false,
    bool receiptsRead = false,
    bool administrator = false,
    int? facilityId = 2,
    int? pointSaleId,
  }) => User(
    userId: 'clerk',
    email: 'clerk@example.com',
    administrator: administrator,
    status: EntityStatus.active,
    sessionVersion: 1,
    settings: UserSettings(facilityId: facilityId, pointSaleId: pointSaleId),
    privileges: [
      if (requestRights != 0)
        Privilege(
          systemObject: SystemObject.purchaseRequest,
          rawValue: requestRights,
        ),
      if (approvalRights != 0)
        Privilege(
          systemObject: SystemObject.purchaseRequestApproval,
          rawValue: approvalRights,
        ),
      if (orderRights != 0)
        Privilege(
          systemObject: SystemObject.purchasesOrders,
          rawValue: orderRights,
        ),
      if (warehousesRead)
        const Privilege(systemObject: SystemObject.warehouses, rawValue: 2),
      if (productsRead)
        const Privilege(systemObject: SystemObject.products, rawValue: 2),
      if (facilitiesRead)
        const Privilege(systemObject: SystemObject.facilities, rawValue: 2),
      if (employeesRead)
        const Privilege(systemObject: SystemObject.employees, rawValue: 2),
      if (suppliersRead)
        const Privilege(systemObject: SystemObject.suppliers, rawValue: 2),
      if (receiptsRead)
        const Privilege(
          systemObject: SystemObject.inventoryReceipts,
          rawValue: 2,
        ),
    ],
  );

  /// Serves [rows] from `list`, recording each call.
  void serve(List<PurchaseRequestSummary> rows) {
    when(
      () => requests.list(
        all: any(named: 'all'),
        status: any(named: 'status'),
        facilityId: any(named: 'facilityId'),
        warehouseId: any(named: 'warehouseId'),
        creatorId: any(named: 'creatorId'),
        serial: any(named: 'serial'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) async {
      listCalls.add((
        all: i.namedArguments[#all] as bool,
        serial: i.namedArguments[#serial] as int?,
        skip: i.namedArguments[#skip] as int,
        limit: i.namedArguments[#limit] as int,
      ));
      return CatalogPage(
        items: rows,
        total: rows.length,
        pageIndex: 0,
        pageSize: 20,
      );
    });
  }

  /// Serves [rows] from `approvalQueue`, paged by `skip` and `limit` like
  /// the server, recording each call. Call it again to change what the next
  /// reload answers.
  void serveQueue(List<PurchaseRequestSummary> rows) {
    when(
      () => requests.approvalQueue(
        facilityId: any(named: 'facilityId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) async {
      final skip = i.namedArguments[#skip] as int;
      final limit = i.namedArguments[#limit] as int;
      queueCalls.add((
        facilityId: i.namedArguments[#facilityId] as int?,
        skip: skip,
        limit: limit,
      ));
      return CatalogPage(
        items: rows.skip(skip).take(limit).toList(),
        total: rows.length,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    });
  }

  /// Answers [warehouses] from every warehouse search.
  void serveWarehouses(List<Warehouse> items) =>
      when(
        () => warehouses.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(items: items, total: items.length),
      );

  /// Answers [request] from `get`.
  void stubRequest(PurchaseRequest request) =>
      when(() => requests.get(request.id)).thenAnswer((_) async => request);

  /// Pumps [request]'s detail screen.
  Future<GoRouter> pumpRequest(
    WidgetTester tester,
    PurchaseRequest request, {
    User? who,
    Size surface = const Size(1400, 1000),
  }) {
    stubRequest(request);
    serve(const []);
    return pump(
      tester,
      who: who,
      location: '$purchaseRequestsPath/${request.id}',
      surface: surface,
    );
  }

  /// Serves [rows] from the orders repository's `list` as one page of
  /// [total] (the row count by default), recording each call.
  void serveOrders(List<PurchaseOrderSummary> rows, {int? total}) {
    when(
      () => orders.list(
        all: any(named: 'all'),
        status: any(named: 'status'),
        supplierId: any(named: 'supplierId'),
        creatorId: any(named: 'creatorId'),
        orderId: any(named: 'orderId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) async {
      final skip = i.namedArguments[#skip] as int;
      final limit = i.namedArguments[#limit] as int;
      orderListCalls.add((
        all: i.namedArguments[#all] as bool,
        orderId: i.namedArguments[#orderId] as int?,
        skip: skip,
        limit: limit,
      ));
      return CatalogPage(
        items: rows,
        total: total ?? rows.length,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    });
  }

  /// Answers [order] from the orders repository's `get`.
  void stubOrder(PurchaseOrder order) =>
      when(() => orders.get(order.id)).thenAnswer((_) async => order);

  /// Pumps [order]'s detail screen (spec 080).
  Future<GoRouter> pumpOrder(
    WidgetTester tester,
    PurchaseOrder order, {
    User? who,
    Size surface = const Size(1400, 1000),
    List<Override> extraOverrides = const [],
  }) {
    stubOrder(order);
    return pump(
      tester,
      who: who,
      location: '$purchaseOrdersPath/${order.id}',
      surface: surface,
      extraOverrides: extraOverrides,
    );
  }

  /// Pumps the app at [location] (the list by default). [settle] false
  /// pumps one frame only, to see a loading state. [extraOverrides] adds
  /// providers, such as the document fakes.
  Future<GoRouter> pump(
    WidgetTester tester, {
    User? who,
    String location = purchaseRequestsPath,
    Size surface = const Size(1400, 1000),
    bool settle = true,
    List<Override> extraOverrides = const [],
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: who ?? user()),
          ),
        ),
        purchaseRequestRepositoryProvider.overrideWithValue(requests),
        purchaseOrderRepositoryProvider.overrideWithValue(orders),
        warehouseRepositoryProvider.overrideWithValue(warehouses),
        productRepositoryProvider.overrideWithValue(products),
        pointSaleRepositoryProvider.overrideWithValue(pointSales),
        supplierRepositoryProvider.overrideWithValue(suppliers),
        inputDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
        warehouseDisplayNameProvider.overrideWith(
          (ref, id) async => 'Almacén $id',
        ),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => 'Sucursal $id',
        ),
        employeeDisplayNameProvider.overrideWith(
          (ref, id) async => 'Empleado $id',
        ),
        ...extraOverrides,
      ],
    );
    addTearDown(container.dispose);
    await container.read(authProvider.future);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: purchaseRequestsPath,
          builder: (_, s) => Scaffold(
            body: PurchaseRequestsListScreen(query: ListQuery.fromUri(s.uri)),
          ),
        ),
        GoRoute(
          path: purchaseRequestApprovalPath,
          builder: (_, s) => Scaffold(
            body: PurchaseRequestApprovalScreen(
              query: ListQuery.fromUri(s.uri),
            ),
          ),
        ),
        GoRoute(
          path: toPurchasePath,
          builder: (_, s) =>
              Scaffold(body: ToPurchaseScreen(query: ListQuery.fromUri(s.uri))),
        ),
        GoRoute(
          path: purchaseOrdersPath,
          builder: (_, s) => Scaffold(
            body: PurchaseOrdersListScreen(query: ListQuery.fromUri(s.uri)),
          ),
        ),
        // A stand-in for the receipt detail: "Abrir" only needs to land.
        GoRoute(
          path: '$inventoryReceiptsPath/:id',
          builder: (_, s) => Scaffold(
            body: Text(
              'receipt ${s.pathParameters['id']}',
              key: const Key('receipt_stand_in'),
            ),
          ),
        ),
        GoRoute(
          path: '$purchaseOrdersPath/:orderId',
          builder: (_, s) => PurchaseOrderDetailScreen(
            orderId: int.tryParse(s.pathParameters['orderId'] ?? ''),
          ),
        ),
        GoRoute(
          path: '$purchaseRequestsPath/:id',
          builder: (_, s) => PurchaseRequestDetailScreen(
            requestId: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    settle ? await tester.pumpAndSettle() : await tester.pump();
    return router;
  }
}

Finder key(String k) => find.byKey(Key(k));

/// A coded refusal carrying English server text that must never be shown.
AppError aRefusal(
  api.ErrorCode code,
  String codeName, [
  Map<String, Object?> params = const {},
]) => AppError.validation(
  [],
  'SERVER TEXT',
  ApiProblem(
    codeName: codeName,
    code: code,
    params: params,
    detail: 'SERVER TEXT',
  ),
);
