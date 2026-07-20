import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
  active: true,
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

  group('VehicleOperatorFilterController', () {
    test('starts with no filters', () {
      final filter = container.read(vehicleOperatorFilterControllerProvider);
      expect(filter.search, '');
      expect(filter.driverId, isNull);
      expect(filter.activeFilterCount, 0);
    });

    test('driverSelected sets driverId and the badge count', () {
      container
          .read(vehicleOperatorFilterControllerProvider.notifier)
          .driverSelected(7, 'Jane Doe');

      final filter = container.read(vehicleOperatorFilterControllerProvider);
      expect(filter.driverId, 7);
      expect(filter.driverDisplayText, 'Jane Doe');
      expect(filter.activeFilterCount, 1);
    });

    test('reset clears the driver filter but keeps search', () {
      final notifier = container.read(
        vehicleOperatorFilterControllerProvider.notifier,
      );
      notifier.searchChanged('Jane');
      notifier.driverSelected(7, 'Jane Doe');

      notifier.reset();

      final filter = container.read(vehicleOperatorFilterControllerProvider);
      expect(filter.search, 'Jane');
      expect(filter.driverId, isNull);
    });
  });

  group('VehicleOperatorsListController', () {
    test(
      'build() maps the current filter to repository query params',
      () async {
        when(
          () =>
              repository.list(search: null, driverId: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async =>
              VehicleOperatorListResult(items: [_operator(1)], total: 1),
        );

        final result = await container.read(
          vehicleOperatorsListControllerProvider.future,
        );

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test('selecting a driver filter re-fetches from skip=0', () async {
      when(
        () => repository.list(search: null, driverId: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => VehicleOperatorListResult(items: [_operator(1)], total: 1),
      );
      await container.read(vehicleOperatorsListControllerProvider.future);

      when(
        () => repository.list(search: null, driverId: 7, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => VehicleOperatorListResult(
          items: [_operator(2, driverId: 7)],
          total: 1,
        ),
      );
      container
          .read(vehicleOperatorFilterControllerProvider.notifier)
          .driverSelected(7, 'Jane Doe');

      final result = await container.read(
        vehicleOperatorsListControllerProvider.future,
      );
      expect(result.items.single.vehicleOperatorId, 2);
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.list(search: null, driverId: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async =>
            VehicleOperatorListResult(items: [_operator(1)], total: 21),
      );
      await container.read(vehicleOperatorsListControllerProvider.future);

      when(
        () =>
            repository.list(search: null, driverId: null, skip: 20, limit: 20),
      ).thenAnswer(
        (_) async =>
            VehicleOperatorListResult(items: [_operator(2)], total: 21),
      );

      await container
          .read(vehicleOperatorsListControllerProvider.notifier)
          .goToPage(1);

      final page = container
          .read(vehicleOperatorsListControllerProvider)
          .value!;
      expect(page.items.map((o) => o.vehicleOperatorId), [2]);
      expect(page.pageIndex, 1);
      expect(page.total, 21);
    });
  });
}
