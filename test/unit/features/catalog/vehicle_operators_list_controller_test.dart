import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_operator_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operators_list_controller.dart';

class MockVehicleOperatorRepository extends Mock
    implements VehicleOperatorRepository {}

VehicleOperator _operator(int id, {int driverId = 1}) => VehicleOperator(
  vehicleOperatorId: id,
  driverId: driverId,
  driverName: 'Driver $driverId',
  licenseType: 'A',
  driverLicenseNumber: 'LN-$id',
  issueDate: DateTime(2026, 1, 1),
  expirationDate: DateTime(2030, 1, 1),
  issuingLocation: 'CDMX',
  status: EntityStatus.active,
);

void main() {
  late MockVehicleOperatorRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockVehicleOperatorRepository();
    container = ProviderContainer(
      overrides: [
        vehicleOperatorRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  group(
    'VehicleOperatorFilter.fromQuery (017-ui-consistency-filters FR-010, FR-017)',
    () {
      test('derives every field from a ListQuery', () {
        final filter = VehicleOperatorFilter.fromQuery(
          const ListQuery(
            search: 'Jane',
            pageIndex: 2,
            facets: {
              'driver': ['7'],
              'status': ['inactive'],
            },
          ),
        );

        expect(filter.search, 'Jane');
        expect(filter.pageIndex, 2);
        expect(filter.driverId, 7);
        expect(filter.status, EntityStatus.inactive);
        expect(filter.activeFilterCount, 2);
      });

      test('defaults from an empty ListQuery', () {
        final filter = VehicleOperatorFilter.fromQuery(const ListQuery());

        expect(filter.search, '');
        expect(filter.pageIndex, 0);
        expect(filter.driverId, isNull);
        expect(filter.status, isNull);
        expect(filter.activeFilterCount, 0);
      });
    },
  );

  group(
    'VehicleOperatorsListController (a family keyed by VehicleOperatorFilter)',
    () {
      test(
        'build(filter) maps the filter to repository query params',
        () async {
          when(
            () => repository.list(
              search: null,
              driverId: null,
              status: null,
              skip: 0,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                VehicleOperatorListResult(items: [_operator(1)], total: 1),
          );

          const filter = VehicleOperatorFilter();
          final result = await container.read(
            vehicleOperatorsListControllerProvider(filter).future,
          );

          expect(result.items, hasLength(1));
          expect(result.total, 1);
        },
      );

      test('a driver facet and a status facet both reach the repository '
          'together (FR-010, FR-013)', () async {
        when(
          () => repository.list(
            search: null,
            driverId: 7,
            status: EntityStatus.active,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => VehicleOperatorListResult(
            items: [_operator(2, driverId: 7)],
            total: 1,
          ),
        );

        const filter = VehicleOperatorFilter(
          driverId: 7,
          status: EntityStatus.active,
        );
        final result = await container.read(
          vehicleOperatorsListControllerProvider(filter).future,
        );

        expect(result.items.single.vehicleOperatorId, 2);
        verify(
          () => repository.list(
            search: null,
            driverId: 7,
            status: EntityStatus.active,
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      });

      test(
        'a different driver filter maps to a different provider instance and query',
        () async {
          when(
            () => repository.list(
              search: null,
              driverId: null,
              status: null,
              skip: 0,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                VehicleOperatorListResult(items: [_operator(1)], total: 1),
          );
          when(
            () => repository.list(
              search: null,
              driverId: 7,
              status: null,
              skip: 0,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => VehicleOperatorListResult(
              items: [_operator(2, driverId: 7)],
              total: 1,
            ),
          );

          final first = await container.read(
            vehicleOperatorsListControllerProvider(
              const VehicleOperatorFilter(),
            ).future,
          );
          final second = await container.read(
            vehicleOperatorsListControllerProvider(
              const VehicleOperatorFilter(driverId: 7),
            ).future,
          );

          expect(first.items.single.vehicleOperatorId, 1);
          expect(second.items.single.vehicleOperatorId, 2);
        },
      );

      test(
        'a different pageIndex maps to skip = pageIndex * pageSize',
        () async {
          when(
            () => repository.list(
              search: null,
              driverId: null,
              status: null,
              skip: 0,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                VehicleOperatorListResult(items: [_operator(1)], total: 21),
          );
          when(
            () => repository.list(
              search: null,
              driverId: null,
              status: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                VehicleOperatorListResult(items: [_operator(2)], total: 21),
          );

          final page0 = await container.read(
            vehicleOperatorsListControllerProvider(
              const VehicleOperatorFilter(),
            ).future,
          );
          final page1 = await container.read(
            vehicleOperatorsListControllerProvider(
              const VehicleOperatorFilter(pageIndex: 1),
            ).future,
          );

          expect(page0.items.map((o) => o.vehicleOperatorId), [1]);
          expect(page0.pageIndex, 0);
          expect(page1.items.map((o) => o.vehicleOperatorId), [2]);
          expect(page1.pageIndex, 1);
          expect(page1.total, 21);
        },
      );

      test(
        'invalidating the provider re-fetches the SAME page rather than '
        'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
        () async {
          const filter = VehicleOperatorFilter(pageIndex: 1);
          when(
            () => repository.list(
              search: null,
              driverId: null,
              status: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                VehicleOperatorListResult(items: [_operator(2)], total: 21),
          );

          await container.read(
            vehicleOperatorsListControllerProvider(filter).future,
          );

          when(
            () => repository.list(
              search: null,
              driverId: null,
              status: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                VehicleOperatorListResult(items: [_operator(99)], total: 21),
          );
          container.invalidate(vehicleOperatorsListControllerProvider(filter));

          final refreshed = await container.read(
            vehicleOperatorsListControllerProvider(filter).future,
          );
          expect(refreshed.pageIndex, 1);
          expect(refreshed.items.single.vehicleOperatorId, 99);
        },
      );
    },
  );
}
