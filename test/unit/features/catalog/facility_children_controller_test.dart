import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_children.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/cash_drawer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_children_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouse_form_controller.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class MockCashDrawerRepository extends Mock implements CashDrawerRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _fullAccessUser = User(
  userId: 'full',
  email: 'full@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.warehouses, rawValue: 15),
    Privilege(systemObject: SystemObject.pointsOfSale, rawValue: 15),
    Privilege(systemObject: SystemObject.cashDrawers, rawValue: 15),
  ],
);

const _warehousesOnlyUser = User(
  userId: 'wh-only',
  email: 'wh-only@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.warehouses, rawValue: 2)],
);

Warehouse _warehouse(int id, int facilityId) => Warehouse(
  warehouseId: id,
  facilityId: facilityId,
  facilityName: 'Facility $facilityId',
  code: 'WH-$id',
  name: 'Warehouse $id',
  status: EntityStatus.active,
);

PointSale _pointSale(int id, int facilityId, int warehouseId) => PointSale(
  pointSaleId: id,
  facilityId: facilityId,
  facilityName: 'Facility $facilityId',
  code: 'PS-$id',
  name: 'Point of Sale $id',
  warehouseId: warehouseId,
  warehouseName: 'Warehouse $warehouseId',
  status: EntityStatus.active,
);

CashDrawer _cashDrawer(int id, int facilityId) => CashDrawer(
  cashDrawerId: id,
  facilityId: facilityId,
  facilityName: 'Facility $facilityId',
  code: 'CD-$id',
  name: 'Cash Drawer $id',
  status: EntityStatus.active,
);

void main() {
  late MockWarehouseRepository warehouseRepository;
  late MockPointSaleRepository pointSaleRepository;
  late MockCashDrawerRepository cashDrawerRepository;

  ProviderContainer containerFor(User user) => ProviderContainer(
    overrides: [
      warehouseRepositoryProvider.overrideWithValue(warehouseRepository),
      pointSaleRepositoryProvider.overrideWithValue(pointSaleRepository),
      cashDrawerRepositoryProvider.overrideWithValue(cashDrawerRepository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );

  setUp(() {
    warehouseRepository = MockWarehouseRepository();
    pointSaleRepository = MockPointSaleRepository();
    cashDrawerRepository = MockCashDrawerRepository();
  });

  group('FacilityChildrenController fetch-by-type (research §2)', () {
    test('a store issues all three fetches', () async {
      when(
        () => warehouseRepository.list(facilityId: 1, skip: 0, limit: 100),
      ).thenAnswer(
        (_) async => WarehouseListResult(items: [_warehouse(1, 1)], total: 1),
      );
      when(
        () => pointSaleRepository.list(facilityId: 1, skip: 0, limit: 100),
      ).thenAnswer(
        (_) async =>
            PointSaleListResult(items: [_pointSale(1, 1, 1)], total: 1),
      );
      when(
        () => cashDrawerRepository.list(facilityId: 1, skip: 0, limit: 100),
      ).thenAnswer(
        (_) async =>
            CashDrawerListResult(items: [_cashDrawer(1, 1)], total: 1),
      );

      final container = containerFor(_fullAccessUser);
      addTearDown(container.dispose);

      final result = await container.read(
        facilityChildrenControllerProvider(1, FacilityType.store).future,
      );

      expect(result.warehouses, hasLength(1));
      expect(result.pointsOfSale, hasLength(1));
      expect(result.cashDrawers, hasLength(1));
      verify(
        () => warehouseRepository.list(facilityId: 1, skip: 0, limit: 100),
      ).called(1);
      verify(
        () => pointSaleRepository.list(facilityId: 1, skip: 0, limit: 100),
      ).called(1);
      verify(
        () => cashDrawerRepository.list(facilityId: 1, skip: 0, limit: 100),
      ).called(1);
    });

    test(
      'a production site issues only the warehouse fetch — points of sale '
      'and cash drawers are never requested',
      () async {
        when(
          () => warehouseRepository.list(facilityId: 2, skip: 0, limit: 100),
        ).thenAnswer(
          (_) async =>
              WarehouseListResult(items: [_warehouse(2, 2)], total: 1),
        );

        final container = containerFor(_fullAccessUser);
        addTearDown(container.dispose);

        final result = await container.read(
          facilityChildrenControllerProvider(
            2,
            FacilityType.productionSite,
          ).future,
        );

        expect(result.warehouses, hasLength(1));
        expect(result.pointsOfSale, isEmpty);
        expect(result.cashDrawers, isEmpty);
        expect(result.pointsOfSaleReadable, isFalse);
        expect(result.cashDrawersReadable, isFalse);
        verifyNever(() => pointSaleRepository.list(facilityId: any(named: 'facilityId')));
        verifyNever(() => cashDrawerRepository.list(facilityId: any(named: 'facilityId')));
      },
    );

    test(
      'a store with no cash-drawer read privilege does not request cash '
      'drawers and reports the section unreadable',
      () async {
        when(
          () => warehouseRepository.list(facilityId: 3, skip: 0, limit: 100),
        ).thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

        final container = containerFor(_warehousesOnlyUser);
        addTearDown(container.dispose);

        final result = await container.read(
          facilityChildrenControllerProvider(3, FacilityType.store).future,
        );

        expect(result.warehousesReadable, isTrue);
        expect(result.pointsOfSaleReadable, isFalse);
        expect(result.cashDrawersReadable, isFalse);
        expect(result.pointsOfSale, isEmpty);
        expect(result.cashDrawers, isEmpty);
        verifyNever(() => pointSaleRepository.list(facilityId: any(named: 'facilityId')));
        verifyNever(() => cashDrawerRepository.list(facilityId: any(named: 'facilityId')));
      },
    );
  });

  group('FacilityChildrenController complete-the-collection loop (FR-019)', () {
    test('a section whose total exceeds one page is loaded completely', () async {
      when(
        () => warehouseRepository.list(facilityId: 4, skip: 0, limit: 100),
      ).thenAnswer(
        (_) async => WarehouseListResult(
          items: List.generate(100, (i) => _warehouse(i, 4)),
          total: 137,
        ),
      );
      when(
        () => warehouseRepository.list(facilityId: 4, skip: 100, limit: 100),
      ).thenAnswer(
        (_) async => WarehouseListResult(
          items: List.generate(37, (i) => _warehouse(100 + i, 4)),
          total: 137,
        ),
      );
      when(
        () => pointSaleRepository.list(facilityId: 4, skip: 0, limit: 100),
      ).thenAnswer((_) async => const PointSaleListResult(items: [], total: 0));
      when(
        () => cashDrawerRepository.list(facilityId: 4, skip: 0, limit: 100),
      ).thenAnswer((_) async => const CashDrawerListResult(items: [], total: 0));

      final container = containerFor(_fullAccessUser);
      addTearDown(container.dispose);

      final result = await container.read(
        facilityChildrenControllerProvider(4, FacilityType.store).future,
      );

      expect(result.warehouses, hasLength(137));
      expect(result.warehouseCount, 137);
      verify(
        () => warehouseRepository.list(facilityId: 4, skip: 100, limit: 100),
      ).called(1);
    });
  });

  group('FacilityChildrenController error isolation (FR-020)', () {
    test('a repository failure surfaces as AsyncError, not a thrown exception', () async {
      when(
        () => warehouseRepository.list(facilityId: 5, skip: 0, limit: 100),
      ).thenThrow(Exception('boom'));
      when(
        () => pointSaleRepository.list(facilityId: 5, skip: 0, limit: 100),
      ).thenAnswer((_) async => const PointSaleListResult(items: [], total: 0));
      when(
        () => cashDrawerRepository.list(facilityId: 5, skip: 0, limit: 100),
      ).thenAnswer((_) async => const CashDrawerListResult(items: [], total: 0));

      final container = containerFor(_fullAccessUser);
      addTearDown(container.dispose);

      await expectLater(
        container.read(
          facilityChildrenControllerProvider(5, FacilityType.store).future,
        ),
        throwsException,
      );

      final state = container.read(
        facilityChildrenControllerProvider(5, FacilityType.store),
      );
      expect(state.hasError, isTrue);
    });
  });

  group(
    'moving a record between facilities invalidates both cards '
    '(research §6, originalFacilityId)',
    () {
      test(
        'updating a warehouse to a different facility invalidates the '
        "original facility's children AND the new facility's children",
        () async {
          final facilityRepository = MockFacilityRepository();
          when(
            () => facilityRepository.get(facilityId: 1),
          ).thenAnswer((_) async => _facility(1));
          when(
            () => facilityRepository.get(facilityId: 2),
          ).thenAnswer((_) async => _facility(2));

          final loaded = _warehouse(5, 1);
          when(
            () => warehouseRepository.get(warehouseId: 5),
          ).thenAnswer((_) async => loaded);
          when(
            () => warehouseRepository.update(
              warehouseId: 5,
              facilityId: 2,
              code: any(named: 'code'),
              name: any(named: 'name'),
              comment: any(named: 'comment'),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => _warehouse(5, 2));
          when(
            () => warehouseRepository.list(
              facilityId: 1,
              skip: any(named: 'skip'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer(
            (_) async => const WarehouseListResult(items: [], total: 0),
          );
          when(
            () => warehouseRepository.list(
              facilityId: 2,
              skip: any(named: 'skip'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer(
            (_) async => const WarehouseListResult(items: [], total: 0),
          );
          when(
            () => pointSaleRepository.list(
              facilityId: any(named: 'facilityId'),
              skip: any(named: 'skip'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer(
            (_) async => const PointSaleListResult(items: [], total: 0),
          );
          when(
            () => cashDrawerRepository.list(
              facilityId: any(named: 'facilityId'),
              skip: any(named: 'skip'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer(
            (_) async => const CashDrawerListResult(items: [], total: 0),
          );

          final container = ProviderContainer(
            overrides: [
              warehouseRepositoryProvider.overrideWithValue(
                warehouseRepository,
              ),
              pointSaleRepositoryProvider.overrideWithValue(
                pointSaleRepository,
              ),
              cashDrawerRepositoryProvider.overrideWithValue(
                cashDrawerRepository,
              ),
              facilityRepositoryProvider.overrideWithValue(
                facilityRepository,
              ),
              accessControlProvider.overrideWithValue(
                AccessControlService(
                  AuthState.authenticated(token: 't', user: _fullAccessUser),
                ),
              ),
            ],
          );
          addTearDown(container.dispose);

          // Keep both cards' providers alive (as their FacilityCard widgets
          // would) so an invalidation triggers an observable rebuild rather
          // than being silently dropped by auto-dispose.
          container.listen(
            facilityChildrenControllerProvider(1, FacilityType.store),
            (_, _) {},
            fireImmediately: true,
          );
          container.listen(
            facilityChildrenControllerProvider(2, FacilityType.store),
            (_, _) {},
            fireImmediately: true,
          );
          await container.read(
            facilityChildrenControllerProvider(1, FacilityType.store).future,
          );
          await container.read(
            facilityChildrenControllerProvider(2, FacilityType.store).future,
          );
          verify(
            () => warehouseRepository.list(
              facilityId: 1,
              skip: 0,
              limit: 100,
            ),
          ).called(1);
          verify(
            () => warehouseRepository.list(
              facilityId: 2,
              skip: 0,
              limit: 100,
            ),
          ).called(1);
          // Reset the call log so the assertions below prove the *move*
          // triggered exactly one fresh fetch per facility, not just that
          // the cumulative count since warm-up happens to be >= 1.
          clearInteractions(warehouseRepository);

          await container
              .read(warehouseFormControllerProvider.notifier)
              .loadForEdit(5);
          container
              .read(warehouseFormControllerProvider.notifier)
              .facilitySelected(2, 'Facility 2');
          await container
              .read(warehouseFormControllerProvider.notifier)
              .submitUpdate();

          // Both facilities' children re-fetched — not just the new one.
          await container.read(
            facilityChildrenControllerProvider(1, FacilityType.store).future,
          );
          await container.read(
            facilityChildrenControllerProvider(2, FacilityType.store).future,
          );
          verify(
            () => warehouseRepository.list(
              facilityId: 1,
              skip: 0,
              limit: 100,
            ),
          ).called(1);
          verify(
            () => warehouseRepository.list(
              facilityId: 2,
              skip: 0,
              limit: 100,
            ),
          ).called(1);
        },
      );
    },
  );
}

Facility _facility(int id) => Facility(
  facilityId: id,
  code: 'FAC-$id',
  name: 'Facility $id',
  type: FacilityType.store,
  locationId: '55600',
  locationLabel: '55600',
  addressId: 1,
  addressLabel: 'Address',
  taxpayerRfc: 'AAA010101AAA',
  status: EntityStatus.active,
);
