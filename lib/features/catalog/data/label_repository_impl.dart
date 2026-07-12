import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';

final labelRepositoryProvider = Provider<LabelRepository>((ref) {
  return LabelRepositoryImpl(ref.watch(dioProvider));
});

/// All labels loaded once, cached by Riverpod for the widget subtree that
/// watches it (form open and products list). Invalidated on provider disposal.
final allLabelsProvider = FutureProvider<List<LabelItem>>((ref) async {
  final repo = ref.watch(labelRepositoryProvider);
  final result = await repo.list(limit: 100);
  return result.items;
});

class LabelRepositoryImpl implements LabelRepository {
  LabelRepositoryImpl(Dio dio) : _api = LabelsApi(dio, standardSerializers);

  final LabelsApi _api;

  @override
  Future<LabelListResult> list({
    String? search,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _api.listLabelsApiV1LabelsGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;

      if (result == null) throw const AppError.server();

      final labelItemsList = result.items.map(LabelItem.fromResponse).toList();
      labelItemsList.sort((a, b) => a.name.compareTo(b.name));
      return LabelListResult(items: labelItemsList, total: result.total);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
