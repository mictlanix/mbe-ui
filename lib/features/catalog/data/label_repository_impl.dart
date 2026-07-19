import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';

final labelRepositoryProvider = Provider<LabelRepository>((ref) {
  return LabelRepositoryImpl(ref.watch(dioProvider));
});

/// All labels loaded once, cached by Riverpod for the widget subtree that
/// watches it (form open and products list). Invalidated on provider disposal
/// and after any create/update/delete in the Labels catalog (FR-014).
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

  @override
  Future<LabelPage> listDetailed({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listLabelsApiV1LabelsGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return LabelPage(
        items: result.items.map(Label.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Label> get({required int labelId}) async {
    try {
      final response = await _api.getLabelApiV1LabelsLabelIdGet(
        labelId: labelId,
      );
      final label = response.data;
      if (label == null) throw const AppError.server();
      return Label.fromResponse(label);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Label> create({required String name, String? comment}) async {
    try {
      final response = await _api.createLabelApiV1LabelsPost(
        labelCreate: LabelCreate((b) {
          b
            ..name = name
            ..comment = comment;
        }),
      );
      final label = response.data;
      if (label == null) throw const AppError.server();
      return Label.fromResponse(label);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Label> update({
    required int labelId,
    String? name,
    String? comment,
  }) async {
    try {
      final response = await _api.updateLabelApiV1LabelsLabelIdPut(
        labelId: labelId,
        labelUpdate: LabelUpdate((b) {
          if (name != null) b.name = name;
          if (comment != null) b.comment = comment;
        }),
      );
      final label = response.data;
      if (label == null) throw const AppError.server();
      return Label.fromResponse(label);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int labelId}) async {
    try {
      await _api.deleteLabelApiV1LabelsLabelIdDelete(labelId: labelId);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
