import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';

part 'delivery_itinerary_detail_controller.g.dart';

/// One trip for its screen, keyed by id (spec 075 research R10).
///
/// Every write answers the full trip, so `DeliveryItineraryActions` puts it
/// here with [replace] and the screen never makes an extra GET. A refusal or
/// an unknown result invalidates this provider instead, and the screen
/// refetches what the server now holds.
@riverpod
class DeliveryItineraryDetailController
    extends _$DeliveryItineraryDetailController {
  @override
  Future<Itinerary> build(int id) =>
      ref.watch(deliveryItineraryRepositoryProvider).getById(id);

  /// Takes the trip a write returned as the current one.
  void replace(Itinerary trip) => state = AsyncData(trip);
}
