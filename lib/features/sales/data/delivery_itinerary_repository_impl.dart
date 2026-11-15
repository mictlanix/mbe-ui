import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_itinerary_repository.dart';

final deliveryItineraryRepositoryProvider =
    Provider<DeliveryItineraryRepository>((ref) {
      return DeliveryItineraryRepositoryImpl(ref.watch(dioProvider));
    });

/// `DeliveryItineraryRepository` backed by the generated
/// `DeliveryItinerariesApi` (spec 063 R2).
class DeliveryItineraryRepositoryImpl implements DeliveryItineraryRepository {
  DeliveryItineraryRepositoryImpl(Dio dio)
    : _api = api.DeliveryItinerariesApi(dio, appSerializers);

  final api.DeliveryItinerariesApi _api;

  @override
  Future<PendingDeliveriesResult> pendingDeliveries({
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await _api
          .pendingDeliveriesApiV1DeliveryItinerariesDeliveriesGet(
            skip: skip,
            limit: limit,
          );
      final body = response.data;
      if (body == null) throw const AppError.server();
      final result = <PendingDeliveryPeriod, PendingDeliveryBucket>{};
      for (final bucket in body.buckets) {
        final period = PendingDeliveryPeriod.values
            .where((p) => p.key == bucket.key)
            .firstOrNull;
        if (period == null) continue;
        result[period] = (
          // The bucket's date is a calendar date (generated `Date`).
          date: bucket.date?.toDateTime(),
          total: bucket.total,
          items: bucket.items.map(PendingDeliveryLine.fromResponse).toList(),
        );
      }
      return result;
    } on DioException catch (e) {
      final mapped = e.error;
      throw mapped is AppError ? mapped : mapDioException(e);
    }
  }
}
