import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

User _user({required bool administrator, int? facilityId, int? pointSaleId}) =>
    User(
      userId: 'user-1',
      email: 'user@example.com',
      administrator: administrator,
      status: EntityStatus.active,
      sessionVersion: 1,
      settings: UserSettings(facilityId: facilityId, pointSaleId: pointSaleId),
      privileges: const [],
    );

Warehouse _warehouse(int id, {int facilityId = 2}) => Warehouse(
  warehouseId: id,
  facilityId: facilityId,
  facilityName: 'Matriz',
  code: 'W$id',
  name: 'Almacén $id',
  status: EntityStatus.active,
);

const _pointSale = PointSale(
  pointSaleId: 11,
  facilityId: 2,
  facilityName: 'Matriz',
  code: 'POS1',
  name: 'Caja 1',
  warehouseId: 3,
  warehouseName: 'Almacén 3',
  status: EntityStatus.active,
);

/// Spec 067 FR-005, FR-017, research R5 (T007).
void main() {
  late MockWarehouseRepository warehouses;
  late MockPointSaleRepository pointSales;

  setUp(() {
    warehouses = MockWarehouseRepository();
    pointSales = MockPointSaleRepository();
    when(
      () => warehouses.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => WarehouseListResult(items: [_warehouse(3)], total: 1),
    );
    when(
      () => pointSales.get(pointSaleId: 11),
    ).thenAnswer((_) async => _pointSale);
    when(
      () => warehouses.get(warehouseId: 3),
    ).thenAnswer((_) async => _warehouse(3));
  });

  Future<ProviderContainer> container(User user) async {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        warehouseRepositoryProvider.overrideWithValue(warehouses),
        pointSaleRepositoryProvider.overrideWithValue(pointSales),
        authProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    await c.read(authProvider.future);
    return c;
  }

  Future<List<Warehouse>> options(ProviderContainer c, String search) =>
      inventoryWarehouseOptions(
        warehouses,
        c.read(inventoryWarehouseScopeProvider),
        search,
      );

  void verifyList({required int? facilityId, String? search}) => verify(
    () => warehouses.list(
      search: search,
      facilityId: facilityId,
      status: EntityStatus.active,
      limit: 10,
    ),
  ).called(1);

  test('an administrator gets no facility filter', () async {
    final c = await container(_user(administrator: true, facilityId: 2));

    expect(await options(c, 'nor'), [_warehouse(3)]);
    verifyList(facilityId: null, search: 'nor');
  });

  test('a non-administrator gets their own facility', () async {
    final c = await container(_user(administrator: false, facilityId: 2));

    expect(c.read(inventoryWarehouseScopeProvider).noFacility, isFalse);
    await options(c, '');
    verifyList(facilityId: 2);
  });

  test('a non-administrator with no facility gets the flag and no '
      'options', () async {
    final c = await container(_user(administrator: false));

    expect(c.read(inventoryWarehouseScopeProvider).noFacility, isTrue);
    expect(await options(c, ''), isEmpty);
    verifyNever(
      () => warehouses.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    );
  });

  test('the filter variant never limits by facility', () async {
    await container(_user(administrator: false, facilityId: 2));

    await inventoryFilterWarehouseOptions(warehouses, 'a');
    verifyList(facilityId: null, search: 'a');
  });

  group('starting warehouse', () {
    test("is the point of sale's warehouse in the user's facility", () async {
      final c = await container(
        _user(administrator: false, facilityId: 2, pointSaleId: 11),
      );

      expect(await c.read(inventoryStartingWarehouseProvider.future), 3);
    });

    test('is null with no point of sale', () async {
      final c = await container(_user(administrator: false, facilityId: 2));

      expect(await c.read(inventoryStartingWarehouseProvider.future), isNull);
      verifyNever(() => pointSales.get(pointSaleId: any(named: 'pointSaleId')));
    });

    test('is null when the point-of-sale lookup fails', () async {
      when(
        () => pointSales.get(pointSaleId: 11),
      ).thenAnswer((_) async => throw const AppError.auth());
      final c = await container(
        _user(administrator: false, facilityId: 2, pointSaleId: 11),
      );

      expect(await c.read(inventoryStartingWarehouseProvider.future), isNull);
    });

    test('is null for a non-administrator when the warehouse is in another '
        'facility, but kept for an administrator', () async {
      when(
        () => warehouses.get(warehouseId: 3),
      ).thenAnswer((_) async => _warehouse(3, facilityId: 9));

      final user = await container(
        _user(administrator: false, facilityId: 2, pointSaleId: 11),
      );
      expect(
        await user.read(inventoryStartingWarehouseProvider.future),
        isNull,
      );

      final admin = await container(
        _user(administrator: true, facilityId: 2, pointSaleId: 11),
      );
      expect(await admin.read(inventoryStartingWarehouseProvider.future), 3);
    });
  });
}
