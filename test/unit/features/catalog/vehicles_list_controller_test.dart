import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicles_list_controller.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

Vehicle _vehicle(int id) => Vehicle(
  vehicleId: id,
  licensePlate: 'PLATE-$id',
  name: 'Vehicle $id',
  nickname: 'Nick $id',
  tonsCapacity: 5,
  status: EntityStatus.active,
);

void main() {
  late MockVehicleRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockVehicleRepository();
    container = ProviderContainer(
      overrides: [vehicleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('VehicleFilter.fromQuery (017-ui-consistency-filters FR-017)', () {
    test('derives search, status, and pageIndex from a ListQuery', () {
      final filter = VehicleFilter.fromQuery(
        const ListQuery(
          search: 'PLATE-1',
          pageIndex: 2,
          facets: {
            'status': ['active'],
          },
        ),
      );

      expect(filter.search, 'PLATE-1');
      expect(filter.status, EntityStatus.active);
      expect(filter.pageIndex, 2);
    });

    test('defaults from an empty ListQuery', () {
      final filter = VehicleFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      // spec 035 FR-001/FR-002: an absent status facet now defaults to
      // Active, not "no filter" — the "All" choice is the explicit
      // `status=all` case, covered separately below.
      expect(filter.status, EntityStatus.active);
      expect(filter.pageIndex, 0);
    });

    test('an explicit "all" status clears the default (FR-004)', () {
      final filter = VehicleFilter.fromQuery(
        const ListQuery(
          facets: {
            'status': ['all'],
          },
        ),
      );

      expect(filter.status, isNull);
    });
  });

  group('VehicleFilter.activeFilterCount (FR-009)', () {
    test('is zero for the default filter', () {
      const filter = VehicleFilter();
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('counts a selected status', () {
      const filter = VehicleFilter(status: EntityStatus.inactive);
      expect(filter.activeFilterCount, 1);
      expect(filter.hasActiveFilters, isTrue);
    });
  });

  group('VehiclesListController (a family keyed by VehicleFilter)', () {
    test('build(filter) maps the filter to repository query params', () async {
      when(
        () => repository.list(search: null, status: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(1)], total: 1),
      );

      const filter = VehicleFilter();
      final result = await container.read(
        vehiclesListControllerProvider(filter).future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test(
      'a status facet in the filter is passed to the repository (FR-009)',
      () async {
        when(
          () => repository.list(
            search: null,
            status: EntityStatus.active,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => VehicleListResult(items: [_vehicle(1)], total: 1),
        );

        const filter = VehicleFilter(status: EntityStatus.active);
        final result = await container.read(
          vehiclesListControllerProvider(filter).future,
        );

        expect(result.items.single.vehicleId, 1);
        verify(
          () => repository.list(
            search: null,
            status: EntityStatus.active,
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      },
    );

    test(
      'a different search maps to a different provider instance and query',
      () async {
        when(
          () => repository.list(search: null, status: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => VehicleListResult(items: [_vehicle(1)], total: 1),
        );
        when(
          () => repository.list(
            search: 'PLATE-2',
            status: null,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => VehicleListResult(items: [_vehicle(2)], total: 1),
        );

        final first = await container.read(
          vehiclesListControllerProvider(const VehicleFilter()).future,
        );
        final second = await container.read(
          vehiclesListControllerProvider(
            const VehicleFilter(search: 'PLATE-2'),
          ).future,
        );

        expect(first.items.single.vehicleId, 1);
        expect(second.items.single.vehicleId, 2);
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(
        () => repository.list(search: null, status: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(1)], total: 21),
      );
      when(
        () => repository.list(search: null, status: null, skip: 20, limit: 20),
      ).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(2)], total: 21),
      );

      final page0 = await container.read(
        vehiclesListControllerProvider(const VehicleFilter()).future,
      );
      final page1 = await container.read(
        vehiclesListControllerProvider(
          const VehicleFilter(pageIndex: 1),
        ).future,
      );

      expect(page0.items.map((v) => v.vehicleId), [1]);
      expect(page0.pageIndex, 0);
      expect(page1.items.map((v) => v.vehicleId), [2]);
      expect(page1.pageIndex, 1);
      expect(page1.total, 21);
    });

    test('invalidating the provider re-fetches the SAME page rather than '
        'resetting to page 0 (017-ui-consistency-filters FR-025, research §3 — '
        'this is the mechanism that fixes the page-reset-on-mutation bug '
        '"for free" once page index is part of the family key)', () async {
      const filter = VehicleFilter(pageIndex: 1);
      when(
        () => repository.list(search: null, status: null, skip: 20, limit: 20),
      ).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(2)], total: 21),
      );

      await container.read(vehiclesListControllerProvider(filter).future);

      // Simulate what a form controller does after a successful mutation.
      when(
        () => repository.list(search: null, status: null, skip: 20, limit: 20),
      ).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(99)], total: 21),
      );
      container.invalidate(vehiclesListControllerProvider(filter));

      final refreshed = await container.read(
        vehiclesListControllerProvider(filter).future,
      );
      expect(refreshed.pageIndex, 1);
      expect(refreshed.items.single.vehicleId, 99);
    });
  });
}
