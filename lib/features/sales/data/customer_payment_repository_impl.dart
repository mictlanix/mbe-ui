import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';

final customerPaymentRepositoryProvider = Provider<CustomerPaymentRepository>((ref) {
  return CustomerPaymentRepositoryImpl(ref.watch(dioProvider));
});

/// `CustomerPaymentRepository` backed by the generated `CustomerPaymentsApi`
/// plus `SalesOrdersApi`'s own payments listing (contracts/mbe-api-pos.md
/// §1, §3) — the listing lives on the sales-order side, which is why this
/// impl holds both clients.
class CustomerPaymentRepositoryImpl implements CustomerPaymentRepository {
  CustomerPaymentRepositoryImpl(Dio dio)
    : _payments = api.CustomerPaymentsApi(dio, api.standardSerializers),
      _salesOrders = api.SalesOrdersApi(dio, api.standardSerializers);

  final api.CustomerPaymentsApi _payments;
  final api.SalesOrdersApi _salesOrders;

  @override
  Future<int> createPayment({
    required int customer,
    required String amount,
    required int method,
    Currency? currency,
    int? paymentCharge,
    String? reference,
  }) async {
    try {
      final response = await _payments.createCustomerPaymentApiV1CustomerPaymentsPost(
        customerPaymentCreate: api.CustomerPaymentCreate((b) {
          b
            ..customer = customer
            ..method = _methodToApi(method)
            ..currency = currency == null ? null : currencyToApi(currency)
            ..paymentCharge = paymentCharge
            ..reference = reference;
          _setAmount(b.amount, amount);
        }),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.customerPaymentId;
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> applyPayment({
    required int customerPaymentId,
    required int salesOrder,
    required String amount,
    String? amountChange,
  }) async {
    try {
      await _payments
          .applyCustomerPaymentApiV1CustomerPaymentsCustomerPaymentIdApplicationsPost(
            customerPaymentId: customerPaymentId,
            applicationCreate: api.ApplicationCreate((b) {
              b.salesOrder = salesOrder;
              _setAmount(b.amount, amount);
              if (amountChange != null) _setAmountChange(b.amountChange, amountChange);
            }),
          );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> reverseApplication({
    required int customerPaymentId,
    required int applicationId,
    required String reason,
  }) async {
    try {
      await _payments
          .reverseCustomerPaymentApplicationApiV1CustomerPaymentsCustomerPaymentIdApplicationsApplicationIdReversePost(
            customerPaymentId: customerPaymentId,
            applicationId: applicationId,
            reversalRequest: api.ReversalRequest((b) => b.reason = reason),
          );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<List<SalePayment>> listForOrder({required int saleId}) async {
    try {
      final response = await _salesOrders
          .listSalesOrderPaymentsApiV1SalesOrdersSalesOrderIdPaymentsGet(
            salesOrderId: saleId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.map(SalePayment.fromResponse).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}

/// `amount`/`amount_change` are `anyOf: [string, num]`, same as the sales
/// order's decimals — the String arm, key `0` (see
/// `sales_order_repository_impl.dart` for the full note).
void _setAmount(api.AmountBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setAmountChange(api.AmountChangeBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

/// The generated `api.PaymentMethod`'s members are named after their wire
/// numbers (`number1`, `number28`, ...) — the inverse of
/// `sale_payment.dart`'s `_methodCodeFromApi`.
api.PaymentMethod _methodToApi(int code) => api.PaymentMethod.valueOf('number$code');
