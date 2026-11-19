import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_itinerary_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_list_controller.dart';

import 'delivery_itinerary_fixtures.dart';

class _MockRepository extends Mock implements DeliveryItineraryRepository {}

/// Spec 075 FR-002, FR-003: server paging by 20, every facet forwarded.
void main() {
  late _MockRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockRepository();
    container = ProviderContainer(
      overrides: [
        deliveryItineraryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  void stub(int total) =>
      when(
        () => repository.list(
          status: any(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          vehicleId: any(named: 'vehicleId'),
          operatorId: any(named: 'operatorId'),
          warehouseId: any(named: 'warehouseId'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (i) async => ItineraryPage(
          items: i.namedArguments[#skip] == 40 && total <= 40
              ? const []
              : [fakeItinerarySummary()],
          total: total,
        ),
      );

  test('requests page 2 as skip 20, limit 20, with every facet', () async {
    stub(58);
    final filter = DeliveryItinerariesFilter(
      status: ItineraryStatus.departed,
      dateFrom: DateTime(2026, 11, 1),
      dateTo: DateTime(2026, 11, 18),
      vehicleId: 4,
      operatorId: 9,
      warehouseId: 3,
      pageIndex: 1,
    );

    final page = await container.read(
      deliveryItinerariesListControllerProvider(filter).future,
    );

    verify(
      () => repository.list(
        status: ItineraryStatus.departed,
        dateFrom: DateTime(2026, 11, 1),
        dateTo: DateTime(2026, 11, 18),
        vehicleId: 4,
        operatorId: 9,
        warehouseId: 3,
        skip: 20,
        limit: 20,
      ),
    ).called(1);
    expect(page.total, 58);
    expect(page.pageIndex, 1);
    expect(page.items, hasLength(1));
  });

  test('a page left empty steps back to the last page with rows', () async {
    stub(25);

    final page = await container.read(
      deliveryItinerariesListControllerProvider(
        const DeliveryItinerariesFilter(pageIndex: 2),
      ).future,
    );

    expect(page.pageIndex, 1);
    expect(page.items, isNotEmpty);
  });
}
