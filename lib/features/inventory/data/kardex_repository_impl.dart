import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mbe_api_client/mbe_api_client.dart' show DateTimeToDate;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/kardex_repository.dart';

final kardexRepositoryProvider = Provider<KardexRepository>(
  (ref) => KardexRepositoryImpl(ref.watch(dioProvider)),
);

/// `KardexRepository` backed by the generated `KardexApi` (spec 071,
/// contracts/repository.md). Built with `appSerializers`, so each row's date
/// is read as wall-clock time (research R13).
class KardexRepositoryImpl implements KardexRepository {
  KardexRepositoryImpl(Dio dio) : _api = api.KardexApi(dio, appSerializers);

  final api.KardexApi _api;

  @override
  Future<Kardex> read({
    required int productId,
    required int warehouseId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final result = (await _api.readKardexApiV1KardexGet(
        product: productId,
        warehouse: warehouseId,
        from: from.toDate(),
        to: to.toDate(),
      )).data;
      if (result == null) throw const AppError.server();
      return Kardex(
        productId: result.product,
        warehouseId: result.warehouse,
        from: result.from.toDateTime(),
        to: result.to.toDateTime(),
        opening: Decimal.parse(result.opening),
        movements: result.rows?.map(_movement).toList() ?? [],
        totalIn: Decimal.parse(result.totalIn),
        totalOut: Decimal.parse(result.totalOut),
        closing: Decimal.parse(result.closing),
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// `source_name` is not mapped: it is server text (research R5).
KardexMovement _movement(api.KardexRow r) => KardexMovement(
  id: r.lotSerialTrackingId,
  date: r.date,
  sourceType: r.source_,
  reference: r.reference,
  quantityIn: Decimal.parse(r.quantityIn),
  quantityOut: Decimal.parse(r.quantityOut),
  balance: Decimal.parse(r.balance),
  document: switch (r.document) {
    null => null,
    final d => KardexDocumentRef(
      type: d.type,
      id: d.id,
      facilityId: d.facility,
      serial: d.serial,
    ),
  },
);

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
