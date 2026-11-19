import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_filter.dart';

part 'delivery_itineraries_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Itinerarios" page (spec 075 FR-002, FR-003): server
/// paging, newest first, filtered by the URL facets. A page left empty by a
/// trip leaving the filter steps back to the last page that has rows.
@riverpod
class DeliveryItinerariesListController
    extends _$DeliveryItinerariesListController {
  @override
  Future<CatalogPage<ItinerarySummary>> build(
    DeliveryItinerariesFilter filter,
  ) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter, pageIndex),
    );
  }

  Future<CatalogPage<ItinerarySummary>> _fetch(
    DeliveryItinerariesFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(deliveryItineraryRepositoryProvider)
        .list(
          status: filter.status,
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
          vehicleId: filter.vehicleId,
          operatorId: filter.operatorId,
          warehouseId: filter.warehouseId,
          skip: pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
  }
}
