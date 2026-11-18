import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/stock_repository.dart';

final stockRepositoryProvider = Provider<StockRepository>(
  (ref) => StockRepositoryImpl(ref.watch(dioProvider)),
);

/// `StockRepository` backed by the generated `StockApi` (spec 071,
/// contracts/repository.md).
class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl(Dio dio) : _api = api.StockApi(dio, appSerializers);

  final api.StockApi _api;

  @override
  Future<StockPage> list({
    required int warehouseId,
    String q = '',
    required bool includeZero,
    required int skip,
    required int limit,
  }) async {
    try {
      final result = (await _api.listStockApiV1StockGet(
        warehouse: warehouseId,
        q: q.isEmpty ? null : q,
        includeZero: includeZero,
        skip: skip,
        limit: limit,
      )).data;
      if (result == null) throw const AppError.server();
      return StockPage(
        items: result.items.map(_row).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ProductStock> product(int productId) async {
    try {
      final result = (await _api.getProductStockApiV1StockProductsProductGet(
        product: productId,
      )).data;
      if (result == null) throw const AppError.server();
      return ProductStock(
        productId: result.product,
        warehouses: result.warehouses?.map(_row).toList() ?? [],
        inTransit: [
          for (final t in result.inTransit ?? <api.InTransitStock>[])
            InTransitStock(
              facilityId: t.facility,
              warehouseId: t.warehouse,
              onHand: Decimal.parse(t.onHand),
            ),
        ],
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

StockRow _row(api.StockRow r) => StockRow(
  productId: r.product,
  productCode: r.productCode ?? '',
  productName: r.productName ?? '',
  warehouseId: r.warehouse,
  onHand: Decimal.parse(r.onHand),
  reserved: Decimal.parse(r.reserved),
  available: Decimal.parse(r.available),
  incoming: Decimal.parse(r.incoming),
);

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
