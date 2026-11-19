import 'package:built_collection/built_collection.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_count_repository.dart';

final inventoryCountRepositoryProvider = Provider<InventoryCountRepository>(
  (ref) => InventoryCountRepositoryImpl(ref.watch(dioProvider)),
);

/// `InventoryCountRepository` backed by the generated `InventoryCountsApi`
/// (spec 070, contracts/repository.md).
class InventoryCountRepositoryImpl implements InventoryCountRepository {
  InventoryCountRepositoryImpl(Dio dio)
    : _api = api.InventoryCountsApi(dio, appSerializers);

  final api.InventoryCountsApi _api;

  @override
  Future<InventoryCountPage> list({
    InventoryDocumentStatus? status,
    int? warehouseId,
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await _api.listInventoryCountsApiV1InventoryCountsGet(
        status: status?.name,
        warehouse: warehouseId,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return InventoryCountPage(
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
  Future<InventoryCount> get(int id) => _count(
    () => _api.getInventoryCountApiV1InventoryCountsCountIdGet(countId: id),
  );

  @override
  Future<InventoryCount> create({required int warehouseId, String? comment}) =>
      _count(
        () => _api.createInventoryCountApiV1InventoryCountsPost(
          countCreate: api.CountCreate((b) {
            b.warehouse = warehouseId;
            b.comment = comment;
          }),
        ),
      );

  @override
  Future<InventoryCount> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
  }) => _count(
    () => _api.updateInventoryCountApiV1InventoryCountsCountIdPut(
      countId: id,
      countUpdate: api.CountUpdate((b) {
        b.warehouse = warehouseId;
        // simplified: a cleared note goes as "" because the generated client
        // drops a null field, as in the issues repository; `_toCount` shows
        // "" as no note. Should a stored "" ever matter, fall back to a raw
        // `dio.put` with {"comment": null}.
        b.comment = comment ?? '';
      }),
    ),
  );

  @override
  Future<InventoryCountLinesChange> setLines(
    int id,
    List<CountLineInput> items,
  ) {
    assert(
      items.isNotEmpty && items.length <= 2000,
      'A line batch holds 1 to 2,000 items',
    );
    return _change(
      () => _api
          .setInventoryCountLineChangesApiV1InventoryCountsCountIdLineChangesPut(
            countId: id,
            countLinesSet: api.CountLinesSet(
              (b) => b.lines = ListBuilder(items.map(_lineSet)),
            ),
          ),
    );
  }

  @override
  Future<InventoryCountLinesChange> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  }) => _change(
    () => _api
        .updateInventoryCountLineChangeApiV1InventoryCountsCountIdLineChangesLineIdPut(
          countId: id,
          lineId: lineId,
          countLineUpdate: api.CountLineUpdate(
            (b) => _setQuantity(b.quantity, quantity),
          ),
        ),
  );

  @override
  Future<InventoryCountLinesChange> removeLine(int id, int lineId) => _change(
    () => _api
        .removeInventoryCountLineChangeApiV1InventoryCountsCountIdLineChangesLineIdDelete(
          countId: id,
          lineId: lineId,
        ),
  );

  @override
  Future<CountConfirmResult> confirm(
    int id, {
    required bool includeUncounted,
  }) async {
    try {
      final result =
          (await _api
                  .confirmInventoryCountApiV1InventoryCountsCountIdConfirmPost(
                    countId: id,
                    countConfirm: api.CountConfirm(
                      (b) => b.includeUncounted = includeUncounted,
                    ),
                  ))
              .data;
      if (result == null) throw const AppError.server();
      return CountConfirmResult(
        count: InventoryCount(
          id: result.inventoryCountId,
          facilityId: result.facility,
          warehouseId: result.warehouse,
          serial: result.serial,
          status: _status(result.status),
          creatorId: result.creator,
          createdAt: result.creationTime,
          comment: _comment(result.comment),
          updaterId: result.updater,
          updatedAt: result.modificationTime,
          lines: result.lines?.map(_line).toList() ?? [],
        ),
        warnings: CountWarnings(
          negativeAvailable: [
            for (final n
                in result.negativeAvailable ?? <api.NegativeAvailable>[])
              NegativeAvailableItem(
                productId: n.product,
                productCode: n.productCode ?? '',
                counted: Decimal.parse(n.counted),
                reserved: Decimal.parse(n.reserved),
                available: Decimal.parse(n.available),
              ),
          ],
          correctedByOtherCounts: [
            for (final c
                in result.correctedByOtherCounts ??
                    <api.CorrectedByOtherCount>[])
              CorrectedByOtherCountItem(
                productId: c.product,
                productCode: c.productCode ?? '',
                otherCountId: c.inventoryCountId,
                otherCountSerial: c.serial,
              ),
          ],
        ),
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<InventoryCount> cancel(int id) => _count(
    () => _api.cancelInventoryCountApiV1InventoryCountsCountIdCancelPost(
      countId: id,
    ),
  );

  Future<InventoryCount> _count(
    Future<Response<api.InventoryCountResponse>> Function() call,
  ) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return _toCount(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  Future<InventoryCountLinesChange> _change(
    Future<Response<api.InventoryCountLinesChanged>> Function() call,
  ) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return InventoryCountLinesChange(
        countId: result.inventoryCountId,
        status: _status(result.status),
        updaterId: result.updater,
        updatedAt: result.modificationTime,
        lineCount: result.lineCount,
        lines: result.lines?.map(_line).toList() ?? [],
        removedLineId: result.removedLineId,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// Exactly one of `product` and `product_code` per item (research R3).
api.CountLineSet _lineSet(CountLineInput input) => api.CountLineSet((b) {
  switch (input) {
    case CountLineByProduct(:final productId):
      b.product = productId;
    case CountLineByCode(:final code):
      b.productCode = code;
  }
  _setQuantity(b.quantity, input.quantity);
});

/// The wire carries quantities as decimal strings (`Quantity2`, the same
/// String-or-number shape as `Quantity5`): the String arm, key `0`.
/// Responses carry plain strings.
void _setQuantity(api.Quantity2Builder builder, Decimal value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value.toString()});
}

/// A `paid` status never occurs on a count, so it is a mapping error rather
/// than a guess.
InventoryDocumentStatus _status(api.DocumentStatus status) {
  if (status == api.DocumentStatus.draft) return InventoryDocumentStatus.draft;
  if (status == api.DocumentStatus.completed) {
    return InventoryDocumentStatus.completed;
  }
  if (status == api.DocumentStatus.cancelled) {
    return InventoryDocumentStatus.cancelled;
  }
  throw AppError.server(message: 'Unexpected count status: ${status.name}');
}

String? _comment(String? comment) => (comment ?? '').isEmpty ? null : comment;

InventoryCountSummary _summary(api.InventoryCountSummary s) =>
    InventoryCountSummary(
      id: s.inventoryCountId,
      facilityId: s.facility,
      warehouseId: s.warehouse,
      serial: s.serial,
      status: _status(s.status),
      creatorId: s.creator,
      createdAt: s.creationTime,
    );

InventoryCount _toCount(api.InventoryCountResponse r) => InventoryCount(
  id: r.inventoryCountId,
  facilityId: r.facility,
  warehouseId: r.warehouse,
  serial: r.serial,
  status: _status(r.status),
  creatorId: r.creator,
  createdAt: r.creationTime,
  comment: _comment(r.comment),
  updaterId: r.updater,
  updatedAt: r.modificationTime,
  lines: r.lines?.map(_line).toList() ?? [],
);

InventoryCountLine _line(api.InventoryCountLineResponse l) =>
    InventoryCountLine(
      id: l.countDetailId,
      productId: l.product,
      productCode: l.productCode ?? '',
      productName: l.productName ?? '',
      quantity: Decimal.parse(l.quantity),
      quantityOnHand: _decimal(l.quantityOnHand),
      difference: _decimal(l.difference),
    );

Decimal? _decimal(String? value) => value == null ? null : Decimal.parse(value);

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
