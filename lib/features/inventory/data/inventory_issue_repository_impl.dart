import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_issue_repository.dart';

final inventoryIssueRepositoryProvider = Provider<InventoryIssueRepository>(
  (ref) => InventoryIssueRepositoryImpl(ref.watch(dioProvider)),
);

/// `InventoryIssueRepository` backed by the generated `InventoryIssuesApi`
/// (spec 068 R6).
class InventoryIssueRepositoryImpl implements InventoryIssueRepository {
  InventoryIssueRepositoryImpl(Dio dio)
    : _api = api.InventoryIssuesApi(dio, appSerializers);

  final api.InventoryIssuesApi _api;

  @override
  Future<InventoryIssuePage> list({
    InventoryDocumentStatus? status,
    int? warehouseId,
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await _api.listInventoryIssuesApiV1InventoryIssuesGet(
        status: status?.name,
        warehouse: warehouseId,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return InventoryIssuePage(
        items: result.items.map(_summary).toList(),
        total: result.total,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<InventoryIssue> get(int id) => _issue(
    () => _api.getInventoryIssueApiV1InventoryIssuesIssueIdGet(issueId: id),
  );

  @override
  Future<InventoryIssue> create({required int warehouseId, String? comment}) =>
      _issue(
        () => _api.createInventoryIssueApiV1InventoryIssuesPost(
          issueCreate: api.IssueCreate((b) {
            b.warehouse = warehouseId;
            b.comment = comment;
          }),
        ),
      );

  @override
  Future<InventoryIssue> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
    bool clearComment = false,
  }) => _issue(
    () => _api.updateInventoryIssueApiV1InventoryIssuesIssueIdPut(
      issueId: id,
      issueUpdate: api.IssueUpdate((b) {
        b.warehouse = warehouseId;
        // simplified: a cleared note goes as "" because the generated client
        // drops a null field. The live check for receipts (spec 067) showed
        // the server stores "" and `_toIssue` shows it as no note; should a
        // stored "" ever matter, fall back to a raw `dio.put` with
        // {"comment": null} deserialized with appSerializers.
        b.comment = clearComment ? '' : comment;
      }),
    ),
  );

  @override
  Future<InventoryIssue> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  }) => _issue(
    () => _api.addInventoryIssueLineApiV1InventoryIssuesIssueIdLinesPost(
      issueId: id,
      lineAdd: api.LineAdd((b) {
        b.product = productId;
        _setQuantity(b.quantity, quantity);
      }),
    ),
  );

  @override
  Future<InventoryIssue> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  }) => _issue(
    () =>
        _api.updateInventoryIssueLineApiV1InventoryIssuesIssueIdLinesLineIdPut(
          issueId: id,
          lineId: lineId,
          lineUpdate: api.LineUpdate((b) => _setQuantity(b.quantity, quantity)),
        ),
  );

  @override
  Future<InventoryIssue> removeLine(int id, int lineId) => _issue(
    () => _api
        .removeInventoryIssueLineApiV1InventoryIssuesIssueIdLinesLineIdDelete(
          issueId: id,
          lineId: lineId,
        ),
  );

  @override
  Future<InventoryIssue> confirm(int id) => _issue(
    () => _api.confirmInventoryIssueApiV1InventoryIssuesIssueIdConfirmPost(
      issueId: id,
    ),
  );

  @override
  Future<InventoryIssue> cancel(int id) => _issue(
    () => _api.cancelInventoryIssueApiV1InventoryIssuesIssueIdCancelPost(
      issueId: id,
    ),
  );

  Future<InventoryIssue> _issue(
    Future<Response<api.InventoryIssueResponse>> Function() call,
  ) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return _toIssue(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// The wire carries quantities as decimal strings (`Quantity5`): the String
/// arm, key `0`, as everywhere else.
void _setQuantity(api.Quantity5Builder builder, Decimal value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value.toString()});
}

/// A `paid` status never occurs on an issue, so it is a mapping error
/// rather than a guess.
InventoryDocumentStatus _status(api.DocumentStatus status) {
  if (status == api.DocumentStatus.draft) return InventoryDocumentStatus.draft;
  if (status == api.DocumentStatus.completed) {
    return InventoryDocumentStatus.completed;
  }
  if (status == api.DocumentStatus.cancelled) {
    return InventoryDocumentStatus.cancelled;
  }
  throw AppError.server(message: 'Unexpected issue status: ${status.name}');
}

InventoryIssueSummary _summary(api.InventoryIssueSummary s) =>
    InventoryIssueSummary(
      id: s.inventoryIssueId,
      facilityId: s.facility,
      warehouseId: s.warehouse,
      serial: s.serial,
      status: _status(s.status),
      creatorId: s.creator,
      createdAt: s.creationTime,
      warehouseName: s.warehouseName,
      facilityName: s.facilityName,
      creatorName: s.creatorName,
    );

InventoryIssue _toIssue(api.InventoryIssueResponse r) => InventoryIssue(
  id: r.inventoryIssueId,
  facilityId: r.facility,
  warehouseId: r.warehouse,
  serial: r.serial,
  status: _status(r.status),
  creatorId: r.creator,
  createdAt: r.creationTime,
  supplierReturnId: r.supplierReturn,
  comment: (r.comment ?? '').isEmpty ? null : r.comment,
  updaterId: r.updater,
  modifiedAt: r.modificationTime,
  lines: r.lines?.map(_line).toList() ?? [],
);

InventoryIssueLine _line(api.InventoryIssueLineResponse l) =>
    InventoryIssueLine(
      id: l.issueDetailId,
      productId: l.product,
      productCode: l.productCode,
      productName: l.productName,
      quantity: Decimal.parse(l.quantity),
    );

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
