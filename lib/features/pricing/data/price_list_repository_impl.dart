import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list_delete_preview.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';

final priceListRepositoryProvider = Provider<PriceListRepository>((ref) {
  return PriceListRepositoryImpl(ref.watch(dioProvider));
});

/// Resolves a price list id to its display name — for a list screen's facet
/// filter picker on a cold load (a shared link/bookmark/refresh carrying
/// only `priceList=<id>` in the URL, 017-ui-consistency-filters
/// data-model.md §4). `null` on any failure (e.g. the id no longer exists),
/// so a caller falls back to displaying the raw id rather than blocking the
/// list.
final priceListDisplayNameProvider = FutureProvider.family<String?, int>((
  ref,
  priceListId,
) async {
  try {
    final priceList = await ref
        .watch(priceListRepositoryProvider)
        .get(priceListId: priceListId);
    return priceList.name;
  } catch (_) {
    return null;
  }
});

/// `PriceListRepository` backed by the generated `mbe_api_client`
/// `PriceListsApi` (contracts/mbe-api-pricing.md §1).
class PriceListRepositoryImpl implements PriceListRepository {
  PriceListRepositoryImpl(Dio dio)
    : _api = PriceListsApi(dio, standardSerializers);

  final PriceListsApi _api;

  @override
  Future<PriceListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listPriceListsApiV1PriceListsGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return PriceListResult(
        items: result.items.map(PriceList.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PriceList> get({required int priceListId}) async {
    try {
      final response = await _api.getPriceListApiV1PriceListsPriceListIdGet(
        priceListId: priceListId,
      );
      final priceList = response.data;
      if (priceList == null) throw const AppError.server();
      return PriceList.fromResponse(priceList);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PriceList> create({
    required String name,
  }) async {
    try {
      final response = await _api.createPriceListApiV1PriceListsPost(
        priceListCreate: PriceListCreate((b) {
          b.name = name;
        }),
      );
      final priceList = response.data;
      if (priceList == null) throw const AppError.server();
      return PriceList.fromResponse(priceList);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PriceList> update({
    required int priceListId,
    String? name,
  }) async {
    try {
      final response = await _api.updatePriceListApiV1PriceListsPriceListIdPut(
        priceListId: priceListId,
        priceListUpdate: PriceListUpdate((b) {
          if (name != null) b.name = name;
          // Update-side wrapper classes are distinct from create-side ones
          // for the same field (research.md §4) — HighProfitMargin1/
          // LowProfitMargin1, not HighProfitMargin/LowProfitMargin.
        }),
      );
      final priceList = response.data;
      if (priceList == null) throw const AppError.server();
      return PriceList.fromResponse(priceList);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int priceListId, int? replacement}) async {
    try {
      await _api.deletePriceListApiV1PriceListsPriceListIdDelete(
        priceListId: priceListId,
        replacement: replacement,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PriceListDeletePreview> deletePreview({
    required int priceListId,
  }) async {
    try {
      final response = await _api
          .previewPriceListDeleteApiV1PriceListsPriceListIdDeletePreviewGet(
            priceListId: priceListId,
          );
      final preview = response.data;
      if (preview == null) throw const AppError.server();
      return PriceListDeletePreview.fromResponse(preview);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
