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
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_receipt_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_detail_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockInventoryReceiptRepository extends Mock
    implements InventoryReceiptRepository {}

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
  ReceiptStatus? status,
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

/// The Entradas de almacén screens with every repository mocked (spec 067
/// widget tests). The session user is configurable: its rights, whether it
/// is an administrator, and its facility and point of sale.
///
/// The display-name providers answer "Almacén {id}", "Sucursal {id}" and
/// "Empleado {id}", or `null` (a failed lookup) with `namesFail`.
class InventoryHarness {
  final receipts = MockInventoryReceiptRepository();
  final warehouses = MockWarehouseRepository();
  final products = MockProductRepository();
  final pointSales = MockPointSaleRepository();

  /// Every `list` call, oldest first.
  final requests = <ReceiptListRequest>[];

  /// The last [pump]'s providers, for reading the formatters in a test.
  late ProviderContainer container;

  /// The session user. [receipts] is the raw InventoryReceipts (15) right
  /// (15 = create, read, update and delete).
  static User user({
    int receipts = 15,
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
      if (warehousesRead)
        const Privilege(systemObject: SystemObject.warehouses, rawValue: 2),
      if (productsRead)
        const Privilege(systemObject: SystemObject.products, rawValue: 2),
    ],
  );

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
        status: i.namedArguments[#status] as ReceiptStatus?,
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
        warehouseRepositoryProvider.overrideWithValue(warehouses),
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
