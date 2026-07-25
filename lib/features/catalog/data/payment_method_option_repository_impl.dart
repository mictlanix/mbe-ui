import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';

final paymentMethodOptionRepositoryProvider =
    Provider<PaymentMethodOptionRepository>((ref) {
      return PaymentMethodOptionRepositoryImpl(ref.watch(dioProvider));
    });

/// `PaymentMethodOptionRepository` backed by the generated `mbe_api_client`
/// `PaymentMethodOptionsApi` (contracts/mbe-api-catalogs.md §1). The
/// generated `list` exposes no `search` param — passed through anyway so the
/// call sites don't change once the upstream capability ships (research §15).
class PaymentMethodOptionRepositoryImpl
    implements PaymentMethodOptionRepository {
  PaymentMethodOptionRepositoryImpl(Dio dio)
    : _api = PaymentMethodOptionsApi(dio, standardSerializers);

  final PaymentMethodOptionsApi _api;

  @override
  Future<PaymentMethodOptionPage> list({
    String? search,
    int? facilityId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api
          .listPaymentMethodOptionsApiV1PaymentMethodOptionsGet(
            facility: facilityId,
            status: status?.toApi(),
            skip: skip,
            limit: limit,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return PaymentMethodOptionPage(
        items: result.items.map(PaymentMethodOption.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PaymentMethodOption> get({
    required int paymentMethodOptionId,
  }) async {
    try {
      final response = await _api
          .getPaymentMethodOptionApiV1PaymentMethodOptionsPaymentMethodOptionIdGet(
            paymentMethodOptionId: paymentMethodOptionId,
          );
      final option = response.data;
      if (option == null) throw const AppError.server();
      return PaymentMethodOption.fromResponse(option);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PaymentMethodOption> create({
    required int facilityId,
    int? warehouseId,
    required String name,
    int? numberOfPayments,
    bool? displayOnTicket,
    required int paymentMethod,
    String? commission,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api
          .createPaymentMethodOptionApiV1PaymentMethodOptionsPost(
            paymentMethodOptionCreate: PaymentMethodOptionCreate((b) {
              b
                ..facility = facilityId
                ..warehouse = warehouseId
                ..name = name
                ..numberOfPayments = numberOfPayments
                ..displayOnTicket = displayOnTicket
                ..paymentMethod = paymentMethod
                ..status = status?.toApi();
              if (commission != null) _setCommission(b.commission, commission);
            }),
          );
      final option = response.data;
      if (option == null) throw const AppError.server();
      return PaymentMethodOption.fromResponse(option);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PaymentMethodOption> update({
    required int paymentMethodOptionId,
    int? facilityId,
    int? warehouseId,
    String? name,
    int? numberOfPayments,
    bool? displayOnTicket,
    int? paymentMethod,
    String? commission,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api
          .updatePaymentMethodOptionApiV1PaymentMethodOptionsPaymentMethodOptionIdPut(
            paymentMethodOptionId: paymentMethodOptionId,
            paymentMethodOptionUpdate: PaymentMethodOptionUpdate((b) {
              if (facilityId != null) b.facility = facilityId;
              if (warehouseId != null) b.warehouse = warehouseId;
              if (name != null) b.name = name;
              if (numberOfPayments != null) {
                b.numberOfPayments = numberOfPayments;
              }
              if (displayOnTicket != null) b.displayOnTicket = displayOnTicket;
              if (paymentMethod != null) b.paymentMethod = paymentMethod;
              if (commission != null) {
                _setCommission1(b.commission, commission);
              }
              if (status != null) b.status = status.toApi();
            }),
          );
      final option = response.data;
      if (option == null) throw const AppError.server();
      return PaymentMethodOption.fromResponse(option);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int paymentMethodOptionId}) async {
    try {
      await _api
          .deletePaymentMethodOptionApiV1PaymentMethodOptionsPaymentMethodOptionIdDelete(
            paymentMethodOptionId: paymentMethodOptionId,
          );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}

/// `commission` is `anyOf: [string, num]` in mbe-api's schema; this project
/// always sends the String arm via `AnyOf2<String, num>(values: {0: value})`
/// — String as the *first* type parameter, key `0` (mirrors
/// `exchange_rate_repository_impl.dart`'s proven `_setRate`/`_setRate1`,
/// verified against a live serialization round-trip there).
void _setCommission(CommissionBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setCommission1(Commission1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
