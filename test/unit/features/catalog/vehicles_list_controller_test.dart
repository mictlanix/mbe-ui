import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
  active: true,
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

  group('VehicleSearchController', () {
    test('starts empty', () {
      expect(container.read(vehicleSearchControllerProvider), '');
    });

    test('updates on searchChanged', () {
      container
          .read(vehicleSearchControllerProvider.notifier)
          .searchChanged('PLATE-1');
      expect(container.read(vehicleSearchControllerProvider), 'PLATE-1');
    });
  });

  group('VehiclesListController', () {
    test(
      'build() maps the current search to repository query params',
      () async {
        when(
          () => repository.list(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => VehicleListResult(items: [_vehicle(1)], total: 1),
        );

        final result = await container.read(
          vehiclesListControllerProvider.future,
        );

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test('changing the search text re-fetches from skip=0', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(1)], total: 1),
      );
      await container.read(vehiclesListControllerProvider.future);

      when(
        () => repository.list(search: 'PLATE-2', skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(2)], total: 1),
      );
      container
          .read(vehicleSearchControllerProvider.notifier)
          .searchChanged('PLATE-2');

      final result = await container.read(
        vehiclesListControllerProvider.future,
      );
      expect(result.items.single.vehicleId, 2);
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(1)], total: 21),
      );
      await container.read(vehiclesListControllerProvider.future);

      when(() => repository.list(search: null, skip: 20, limit: 20)).thenAnswer(
        (_) async => VehicleListResult(items: [_vehicle(2)], total: 21),
      );

      await container.read(vehiclesListControllerProvider.notifier).goToPage(1);

      final page = container.read(vehiclesListControllerProvider).value!;
      expect(page.items.map((v) => v.vehicleId), [2]);
      expect(page.pageIndex, 1);
      expect(page.total, 21);
    });
  });
}
