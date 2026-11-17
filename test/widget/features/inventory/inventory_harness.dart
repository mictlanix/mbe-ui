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
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_issue_repository.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_receipt_repository.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_transfer_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_detail_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issues_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_detail_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/in_transit_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_detail_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockInventoryReceiptRepository extends Mock
    implements InventoryReceiptRepository {}

class MockInventoryIssueRepository extends Mock
    implements InventoryIssueRepository {}

class MockInventoryTransferRepository extends Mock
    implements InventoryTransferRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// One `list` call's filter, as the list screen sent it.
typedef ReceiptListRequest = ({
  InventoryDocumentStatus? status,
  int? warehouseId,
  int skip,
});

/// One transfers `list` call's filter, as the list screen sent it.
typedef TransferListRequest = ({
  InventoryTransferStatus? status,
  int? warehouseId,
  int skip,
});

/// A warehouse for the pickers.
Warehouse aWarehouse(int id, {int facilityId = 2}) => Warehouse(
  warehouseId: id,
  facilityId: facilityId,
  facilityName: 'Sucursal $facilityId',
  code: 'W$id',
  name: 'Almacén $id',
  status: EntityStatus.active,
);

/// The Entradas (067), Salidas (068) and Traspasos (069) screens with
/// every repository mocked. The session user is configurable: its rights, whether it
/// is an administrator, and its facility and point of sale.
///
/// The display-name providers answer "Almacén {id}", "Sucursal {id}" and
/// "Empleado {id}", or `null` (a failed lookup) with `namesFail`.
class InventoryHarness {
  final receipts = MockInventoryReceiptRepository();
  final issues = MockInventoryIssueRepository();
  final transfers = MockInventoryTransferRepository();
  final warehouses = MockWarehouseRepository();
  final facilities = MockFacilityRepository();
  final products = MockProductRepository();
  final pointSales = MockPointSaleRepository();

  /// Every `list` call, oldest first.
  final requests = <ReceiptListRequest>[];

  /// Every issues `list` call, oldest first.
  final issueRequests = <ReceiptListRequest>[];

  /// Every transfers `list` call, oldest first.
  final transferRequests = <TransferListRequest>[];

  /// The last [pump]'s providers, for reading the formatters in a test.
  late ProviderContainer container;

  /// The session user. [receipts] is the raw InventoryReceipts (15) right
  /// (15 = create, read, update and delete).
  static User user({
    int receipts = 15,
    int issues = 0,
    int transfers = 0,
    bool warehousesRead = true,
    bool productsRead = true,
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
      if (receipts != 0)
        Privilege(
          systemObject: SystemObject.inventoryReceipts,
          rawValue: receipts,
        ),
      if (issues != 0)
        Privilege(systemObject: SystemObject.inventoryIssues, rawValue: issues),
      if (transfers != 0)
        Privilege(
          systemObject: SystemObject.inventoryTransfers,
          rawValue: transfers,
        ),
      if (warehousesRead)
        const Privilege(systemObject: SystemObject.warehouses, rawValue: 2),
      if (productsRead)
        const Privilege(systemObject: SystemObject.products, rawValue: 2),
    ],
  );

  /// A session user holding only InventoryIssues (16): [issues] is its raw
  /// right (15 = create, read, update and delete).
  static User issueUser({
    int issues = 15,
    bool warehousesRead = true,
    bool productsRead = true,
    bool administrator = false,
    int? facilityId = 2,
    int? pointSaleId,
  }) => user(
    receipts: 0,
    issues: issues,
    warehousesRead: warehousesRead,
    productsRead: productsRead,
    administrator: administrator,
    facilityId: facilityId,
    pointSaleId: pointSaleId,
  );

  /// A session user holding only InventoryTransfers (17): [transfers] is its
  /// raw right (15 = create, read, update and delete).
  static User transferUser({
    int transfers = 15,
    bool warehousesRead = true,
    bool productsRead = true,
    bool administrator = false,
    int? facilityId = 2,
    int? pointSaleId,
  }) => user(
    receipts: 0,
    transfers: transfers,
    warehousesRead: warehousesRead,
    productsRead: productsRead,
    administrator: administrator,
    facilityId: facilityId,
    pointSaleId: pointSaleId,
  );

  /// Serves [rows] from the transfers `list`, recording each request.
  void serveTransfers(List<InventoryTransferSummary> rows) => stubTransferList(
    (_) async => CatalogPage(
      items: rows,
      total: rows.length,
      pageIndex: 0,
      pageSize: 20,
    ),
  );

  void stubTransferList(
    Future<InventoryTransferPage> Function(TransferListRequest request) answer,
  ) {
    when(
      () => transfers.list(
        status: any(named: 'status'),
        warehouseId: any(named: 'warehouseId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) {
      final request = (
        status: i.namedArguments[#status] as InventoryTransferStatus?,
        warehouseId: i.namedArguments[#warehouseId] as int?,
        skip: i.namedArguments[#skip] as int,
      );
      transferRequests.add(request);
      return answer(request);
    });
  }

  /// Answers [transfer] from `get`.
  void stubTransfer(InventoryTransfer transfer) =>
      when(() => transfers.get(transfer.id)).thenAnswer((_) async => transfer);

  /// Pumps the app at [location] (the transfers list by default), as a
  /// transfers user unless [who] is given.
  Future<GoRouter> pumpTransfers(
    WidgetTester tester, {
    User? who,
    String location = inventoryTransfersPath,
    Size surface = const Size(1400, 1000),
    bool namesFail = false,
  }) => pump(
    tester,
    who: who ?? transferUser(),
    location: location,
    surface: surface,
    namesFail: namesFail,
  );

  /// Pumps [transfer]'s detail screen, as a transfers user unless [who] is
  /// given.
  Future<GoRouter> pumpTransfer(
    WidgetTester tester,
    InventoryTransfer transfer, {
    User? who,
    Size surface = const Size(1400, 1000),
  }) {
    stubTransfer(transfer);
    serveTransfers(const []);
    return pump(
      tester,
      who: who ?? transferUser(),
      location: '$inventoryTransfersPath/${transfer.id}',
      surface: surface,
    );
  }

  /// Serves [rows] from the issues `list`, recording each request.
  void serveIssues(List<InventoryIssueSummary> rows) => stubIssueList(
    (_) async => CatalogPage(
      items: rows,
      total: rows.length,
      pageIndex: 0,
      pageSize: 20,
    ),
  );

  void stubIssueList(
    Future<InventoryIssuePage> Function(ReceiptListRequest request) answer,
  ) {
    when(
      () => issues.list(
        status: any(named: 'status'),
        warehouseId: any(named: 'warehouseId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) {
      final request = (
        status: i.namedArguments[#status] as InventoryDocumentStatus?,
        warehouseId: i.namedArguments[#warehouseId] as int?,
        skip: i.namedArguments[#skip] as int,
      );
      issueRequests.add(request);
      return answer(request);
    });
  }

  /// Answers [issue] from `get`.
  void stubIssue(InventoryIssue issue) =>
      when(() => issues.get(issue.id)).thenAnswer((_) async => issue);

  /// Pumps the app at [location] (the issues list by default), as an issues
  /// user unless [who] is given.
  Future<GoRouter> pumpIssues(
    WidgetTester tester, {
    User? who,
    String location = inventoryIssuesPath,
    Size surface = const Size(1400, 1000),
    bool namesFail = false,
  }) => pump(
    tester,
    who: who ?? issueUser(),
    location: location,
    surface: surface,
    namesFail: namesFail,
  );

  /// Pumps [issue]'s detail screen, as an issues user unless [who] is given.
  Future<GoRouter> pumpIssue(
    WidgetTester tester,
    InventoryIssue issue, {
    User? who,
    Size surface = const Size(1400, 1000),
  }) {
    stubIssue(issue);
    serveIssues(const []);
    return pump(
      tester,
      who: who ?? issueUser(),
      location: '$inventoryIssuesPath/${issue.id}',
      surface: surface,
    );
  }

  /// Serves [rows] from `list`, recording each request.
  void serve(List<InventoryReceiptSummary> rows) => stubList(
    (_) async => CatalogPage(
      items: rows,
      total: rows.length,
      pageIndex: 0,
      pageSize: 20,
    ),
  );

  void stubList(
    Future<InventoryReceiptPage> Function(ReceiptListRequest request) answer,
  ) {
    when(
      () => receipts.list(
        status: any(named: 'status'),
        warehouseId: any(named: 'warehouseId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) {
      final request = (
        status: i.namedArguments[#status] as InventoryDocumentStatus?,
        warehouseId: i.namedArguments[#warehouseId] as int?,
        skip: i.namedArguments[#skip] as int,
      );
      requests.add(request);
      return answer(request);
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

  /// Answers [receipt] from `get`.
  void stubReceipt(InventoryReceipt receipt) =>
      when(() => receipts.get(receipt.id)).thenAnswer((_) async => receipt);

  /// Pumps [receipt]'s detail screen.
  Future<GoRouter> pumpReceipt(
    WidgetTester tester,
    InventoryReceipt receipt, {
    User? who,
    Size surface = const Size(1400, 1000),
  }) {
    stubReceipt(receipt);
    serve(const []);
    return pump(
      tester,
      who: who,
      location: '$inventoryReceiptsPath/${receipt.id}',
      surface: surface,
    );
  }

  /// Pumps the app at [location] (the list by default).
  Future<GoRouter> pump(
    WidgetTester tester, {
    User? who,
    String location = inventoryReceiptsPath,
    Size surface = const Size(1400, 1000),
    bool namesFail = false,
    bool settle = true,
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
        inventoryReceiptRepositoryProvider.overrideWithValue(receipts),
        inventoryIssueRepositoryProvider.overrideWithValue(issues),
        inventoryTransferRepositoryProvider.overrideWithValue(transfers),
        warehouseRepositoryProvider.overrideWithValue(warehouses),
        facilityRepositoryProvider.overrideWithValue(facilities),
        productRepositoryProvider.overrideWithValue(products),
        pointSaleRepositoryProvider.overrideWithValue(pointSales),
        inputDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
        warehouseDisplayNameProvider.overrideWith(
          (ref, id) async => namesFail ? null : 'Almacén $id',
        ),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => namesFail ? null : 'Sucursal $id',
        ),
        employeeDisplayNameProvider.overrideWith(
          (ref, id) async => namesFail ? null : 'Empleado $id',
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authProvider.future);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: inventoryReceiptsPath,
          builder: (_, s) => Scaffold(
            body: InventoryReceiptsListScreen(query: ListQuery.fromUri(s.uri)),
          ),
        ),
        GoRoute(
          path: inventoryIssuesPath,
          builder: (_, s) => Scaffold(
            body: InventoryIssuesListScreen(query: ListQuery.fromUri(s.uri)),
          ),
        ),
        GoRoute(
          path: '$inventoryIssuesPath/:id',
          builder: (_, s) => InventoryIssueDetailScreen(
            issueId: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: inventoryTransfersPath,
          builder: (_, s) => Scaffold(
            body: InventoryTransfersListScreen(query: ListQuery.fromUri(s.uri)),
          ),
        ),
        GoRoute(
          path: inTransitPath,
          builder: (_, _) => const InTransitScreen(),
        ),
        GoRoute(
          path: '$inventoryTransfersPath/:id',
          builder: (_, s) => InventoryTransferDetailScreen(
            transferId: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: '$inventoryReceiptsPath/:id',
          builder: (_, s) => InventoryReceiptDetailScreen(
            receiptId: int.tryParse(s.pathParameters['id'] ?? ''),
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
    if (settle) await tester.pumpAndSettle();
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
