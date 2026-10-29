import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/data/wire_value_setters.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_refund_repository.dart';

final customerRefundRepositoryProvider = Provider<CustomerRefundRepository>((
  ref,
) {
  return CustomerRefundRepositoryImpl(ref.watch(dioProvider));
});

/// `CustomerRefundRepository` backed by the generated `CustomerRefundsApi`.
class CustomerRefundRepositoryImpl implements CustomerRefundRepository {
  CustomerRefundRepositoryImpl(Dio dio)
    : _api = api.CustomerRefundsApi(dio, appSerializers);

  final api.CustomerRefundsApi _api;

  @override
  Future<RefundListResult> list({
    RefundStatus? status,
    int? customerId,
    int? salesOrderId,
    required int skip,
    required int limit,
  }) => _call(() async {
    final response = await _api.listCustomerRefundsApiV1CustomerRefundsGet(
      customer: customerId,
      salesOrder: salesOrderId,
      status: status?.wireName,
      skip: skip,
      limit: limit,
    );
    final result = response.data;
    if (result == null) throw const AppError.server();
    return RefundListResult(
      items: result.items.map(CustomerRefundSummary.fromResponse).toList(),
      total: result.total,
    );
  });

  @override
  Future<CustomerRefund> getById(int id) => _refund(
    () => _api.getCustomerRefundApiV1CustomerRefundsCustomerRefundIdGet(
      customerRefundId: id,
    ),
  );

  @override
  Future<CustomerRefund> open(int salesOrderId) => _refund(
    () => _api.openCustomerRefundApiV1CustomerRefundsPost(
      customerRefundCreate: api.CustomerRefundCreate(
        (b) => b..salesOrder = salesOrderId,
      ),
    ),
  );

  @override
  Future<CustomerRefund> updateLine(
    int refundId,
    int lineId, {
    String? quantity,
    int? warehouseId,
  }) => _refund(
    () => _api
        .updateCustomerRefundLineApiV1CustomerRefundsCustomerRefundIdLinesLineIdPut(
          customerRefundId: refundId,
          lineId: lineId,
          customerRefundLineUpdate: api.CustomerRefundLineUpdate((b) {
            if (quantity != null) setQuantity3(b.quantity, quantity);
            if (warehouseId != null) b.warehouse = warehouseId;
          }),
        ),
  );

  @override
  Future<CustomerRefund> confirm(int refundId, RefundPayout payout) => _refund(
    () => _api
        .confirmCustomerRefundApiV1CustomerRefundsCustomerRefundIdConfirmPost(
          customerRefundId: refundId,
          customerRefundConfirm: api.CustomerRefundConfirm(
            (b) => b..payout = payout.toApi(),
          ),
        ),
  );

  @override
  Future<CustomerRefund> cancel(int refundId) => _refund(
    () =>
        _api.cancelCustomerRefundApiV1CustomerRefundsCustomerRefundIdCancelPost(
          customerRefundId: refundId,
        ),
  );

  Future<CustomerRefund> _refund(
    Future<Response<api.CustomerRefundResponse>> Function() request,
  ) => _call(() async {
    final data = (await request()).data;
    if (data == null) throw const AppError.server();
    return CustomerRefund.fromResponse(data);
  });

  Future<T> _call<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      final mapped = e.error;
      throw mapped is AppError ? mapped : mapDioException(e);
    }
  }
}
