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
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/kardex_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/stock_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_count_repository.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_issue_repository.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_receipt_repository.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_transfer_repository.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/kardex_repository.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/stock_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_counts_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_detail_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issues_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_detail_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_selection.dart';
import 'package:mbe_ui/features/inventory/presentation/stock/product_stock_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/stock/stock_list_screen.dart';
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

class MockInventoryCountRepository extends Mock
    implements InventoryCountRepository {}

class MockStockRepository extends Mock implements StockRepository {}

class MockKardexRepository extends Mock implements KardexRepository {}

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
typedef StockListRequest = ({
  int warehouseId,
  String q,
  bool includeZero,
  int skip,
  int limit,
});

typedef KardexRequest = ({
  int productId,
  int warehouseId,
  DateTime from,
  DateTime to,
});

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

/// A catalog product, "A-100 Tornillo 1/4 caja", for the product view's
/// title.
Product aProduct(int id) => Product(
  productId: id,
  code: 'A-100',
  name: 'Tornillo 1/4 caja',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  taxIncluded: false,
  priceType: 0,
  currency: 0,
  minOrderQty: 1,
  stockable: true,
  perishable: false,
  seriable: false,
  purchasable: true,
  salable: true,
  invoiceable: true,
  stockRequired: false,
  status: EntityStatus.active,
);

/// The Entradas (067), Salidas (068), Traspasos (069) and Conteos físicos
/// (070) screens with every repository mocked. The session user is
/// configurable: its rights, whether it is an administrator, and its facility
/// and point of sale.
///
/// The display-name providers answer "Almacén {id}", "Sucursal {id}" and
/// "Empleado {id}", or `null` (a failed lookup) with `namesFail`.
class InventoryHarness {
  final receipts = MockInventoryReceiptRepository();
  final issues = MockInventoryIssueRepository();
  final transfers = MockInventoryTransferRepository();
  final counts = MockInventoryCountRepository();
  final stock = MockStockRepository();
  final kardex = MockKardexRepository();
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

  /// Every counts `list` call, oldest first.
  final countRequests = <ReceiptListRequest>[];

  /// Every stock `list` call, oldest first.
  final stockRequests = <StockListRequest>[];

  /// Every kardex `read` call, oldest first.
  final kardexRequests = <KardexRequest>[];

  /// The last [pump]'s providers, for reading the formatters in a test.
  late ProviderContainer container;

  /// The session user. [receipts] is the raw InventoryReceipts (15) right
  /// (15 = create, read, update and delete).
  static User user({
    int receipts = 15,
    int issues = 0,
    int transfers = 0,
    int counts = 0,
    int stock = 0,
    int kardex = 0,
    int purchaseOrders = 0,
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
      if (counts != 0)
        Privilege(
          systemObject: SystemObject.physicalCountAdjustment,
          rawValue: counts,
        ),
      if (stock != 0)
        Privilege(
          systemObject: SystemObject.warehouseStockReport,
          rawValue: stock,
        ),
      if (kardex != 0)
        Privilege(systemObject: SystemObject.kardex, rawValue: kardex),
      if (purchaseOrders != 0)
        Privilege(
          systemObject: SystemObject.purchasesOrders,
          rawValue: purchaseOrders,
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

  /// A session user holding only PhysicalCountAdjustment (74): [counts] is
  /// its raw right (15 = create, read, update and delete).
  static User countUser({
    int counts = 15,
    bool warehousesRead = true,
    bool productsRead = true,
    bool administrator = false,
    int? facilityId = 2,
    int? pointSaleId,
  }) => user(
    receipts: 0,
    counts: counts,
    warehousesRead: warehousesRead,
    productsRead: productsRead,
    administrator: administrator,
    facilityId: facilityId,
    pointSaleId: pointSaleId,
  );

  /// A session user holding only WarehouseStockReport (67): [stock] is its
  /// raw right (2 = read).
  static User stockUser({
    int stock = 2,
    int kardex = 0,
    bool warehousesRead = true,
    bool productsRead = true,
    bool administrator = false,
    int? facilityId = 2,
    int? pointSaleId,
  }) => user(
    receipts: 0,
    stock: stock,
    kardex: kardex,
    warehousesRead: warehousesRead,
    productsRead: productsRead,
    administrator: administrator,
    facilityId: facilityId,
    pointSaleId: pointSaleId,
  );

  /// A session user holding only Kardex (32): [kardex] is its raw right
  /// (2 = read).
  static User kardexUser({
    int kardex = 2,
    int stock = 0,
    bool warehousesRead = true,
    bool productsRead = true,
    bool administrator = false,
    int? facilityId = 2,
  }) => user(
    receipts: 0,
    stock: stock,
    kardex: kardex,
    warehousesRead: warehousesRead,
    productsRead: productsRead,
    administrator: administrator,
    facilityId: facilityId,
  );

  /// Serves [rows] from the stock `list`, recording each request.
  void serveStock(List<StockRow> rows, {int? total}) => stubStockList(
    (_) async => StockPage(items: rows, total: total ?? rows.length),
  );

  void stubStockList(
    Future<StockPage> Function(StockListRequest request) answer,
  ) {
    when(
      () => stock.list(
        warehouseId: any(named: 'warehouseId'),
        q: any(named: 'q'),
        includeZero: any(named: 'includeZero'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) {
      final request = (
        warehouseId: i.namedArguments[#warehouseId] as int,
        q: (i.namedArguments[#q] as String?) ?? '',
        includeZero: i.namedArguments[#includeZero] as bool,
        skip: i.namedArguments[#skip] as int,
        limit: i.namedArguments[#limit] as int,
      );
      stockRequests.add(request);
      return answer(request);
    });
  }

  /// Pumps the app at [location] (Existencias by default), as a stock user
  /// unless [who] is given.
  Future<GoRouter> pumpStock(
    WidgetTester tester, {
    User? who,
    String location = stockPath,
    Size surface = const Size(1400, 1000),
    bool namesFail = false,
  }) => pump(
    tester,
    who: who ?? stockUser(),
    location: location,
    surface: surface,
    namesFail: namesFail,
  );

  /// Answers [productStock] from `product`.
  void stubProductStock(ProductStock productStock) => when(
    () => stock.product(productStock.productId),
  ).thenAnswer((_) async => productStock);

  /// Pumps [productStock]'s product view, as a stock user unless [who] is
  /// given. The product is "A-100 Tornillo 1/4 caja", and warehouse `w`
  /// belongs to facility `w * 10`, "Sucursal {w * 10}".
  Future<GoRouter> pumpProductStock(
    WidgetTester tester,
    ProductStock productStock, {
    User? who,
    Size surface = const Size(1400, 1000),
  }) {
    stubProductStock(productStock);
    when(
      () => products.get(productId: productStock.productId),
    ).thenAnswer((_) async => aProduct(productStock.productId));
    when(
      () => warehouses.get(warehouseId: any(named: 'warehouseId')),
    ).thenAnswer((i) async {
      final id = i.namedArguments[#warehouseId] as int;
      return aWarehouse(id, facilityId: id * 10);
    });
    return pump(
      tester,
      who: who ?? stockUser(),
      location: '$stockPath/products/${productStock.productId}',
      surface: surface,
    );
  }

  /// Answers [result] from every kardex `read`, recording each request.
  void serveKardex(Kardex result) => stubKardex((_) async => result);

  void stubKardex(Future<Kardex> Function(KardexRequest request) answer) {
    when(
      () => kardex.read(
        productId: any(named: 'productId'),
        warehouseId: any(named: 'warehouseId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((i) {
      final request = (
        productId: i.namedArguments[#productId] as int,
        warehouseId: i.namedArguments[#warehouseId] as int,
        from: i.namedArguments[#from] as DateTime,
        to: i.namedArguments[#to] as DateTime,
      );
      kardexRequests.add(request);
      return answer(request);
    });
  }

  /// Pumps the Kardex at [location], as a kardex user unless [who] is
  /// given. Every product reads as "A-100 Tornillo 1/4 caja".
  Future<GoRouter> pumpKardex(
    WidgetTester tester, {
    User? who,
    String location = kardexPath,
    Size surface = const Size(1400, 1000),
  }) {
    when(
      () => products.get(productId: any(named: 'productId')),
    ).thenAnswer((i) async => aProduct(i.namedArguments[#productId] as int));
    return pump(
      tester,
      who: who ?? kardexUser(),
      location: location,
      surface: surface,
    );
  }

  /// Serves [rows] from the counts `list`, recording each request.
  void serveCounts(List<InventoryCountSummary> rows) => stubCountList(
    (_) async => CatalogPage(
      items: rows,
      total: rows.length,
      pageIndex: 0,
      pageSize: 20,
    ),
  );

  void stubCountList(
    Future<InventoryCountPage> Function(ReceiptListRequest request) answer,
  ) {
    when(
      () => counts.list(
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
      countRequests.add(request);
      return answer(request);
    });
  }

  /// Answers [count] from `get`.
  void stubCount(InventoryCount count) =>
      when(() => counts.get(count.id)).thenAnswer((_) async => count);

  /// Pumps the app at [location] (the counts list by default), as a counts
  /// user unless [who] is given.
  Future<GoRouter> pumpCounts(
    WidgetTester tester, {
    User? who,
    String location = inventoryCountsPath,
    Size surface = const Size(1400, 1000),
    bool namesFail = false,
  }) => pump(
    tester,
    who: who ?? countUser(),
    location: location,
    surface: surface,
    namesFail: namesFail,
  );

  /// Pumps [count]'s detail screen, as a counts user unless [who] is given.
  Future<GoRouter> pumpCount(
    WidgetTester tester,
    InventoryCount count, {
    User? who,
    Size surface = const Size(1400, 1000),
  }) {
    stubCount(count);
    serveCounts(const []);
    return pump(
      tester,
      who: who ?? countUser(),
      location: '$inventoryCountsPath/${count.id}',
      surface: surface,
    );
  }

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
        inventoryCountRepositoryProvider.overrideWithValue(counts),
        stockRepositoryProvider.overrideWithValue(stock),
        kardexRepositoryProvider.overrideWithValue(kardex),
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
          path: inventoryCountsPath,
          builder: (_, s) => Scaffold(
            body: InventoryCountsListScreen(query: ListQuery.fromUri(s.uri)),
          ),
        ),
        GoRoute(
          path: '$inventoryCountsPath/:id',
          builder: (_, s) => InventoryCountDetailScreen(
            countId: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: stockPath,
          builder: (_, s) =>
              Scaffold(body: StockListScreen(query: ListQuery.fromUri(s.uri))),
        ),
        GoRoute(
          path: '$stockPath/products/:id',
          builder: (_, s) => ProductStockScreen(
            productId: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: kardexPath,
          builder: (_, s) => Scaffold(
            body: KardexScreen(selection: KardexSelection.fromUri(s.uri)),
          ),
        ),
        GoRoute(
          path: kardexPagePath,
          builder: (_, s) => KardexScreen(
            selection: KardexSelection.fromUri(s.uri),
            pushed: true,
          ),
        ),
        // Stand-ins for the sales documents a kardex row links to: the
        // Kardex tests only check where a row goes.
        for (final path in const [
          '/sales/orders',
          '/sales/refunds',
          '/sales/delivery-orders',
        ])
          GoRoute(
            path: '$path/:id',
            builder: (_, s) => Scaffold(
              body: Text('${s.uri}', key: const Key('sales_document_route')),
            ),
          ),
        // A stand-in for the purchase order a receipt links to (spec 080).
        GoRoute(
          path: '/purchases/orders/:id',
          builder: (_, s) => Scaffold(
            body: Text('${s.uri}', key: const Key('purchase_order_route')),
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
