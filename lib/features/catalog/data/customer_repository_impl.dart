import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart'
    as domain;
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(dioProvider));
});

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(Dio dio)
    : _api = CustomersApi(dio, standardSerializers);

  final CustomersApi _api;

  @override
  Future<CustomerPage> list({
    String? search,
    EntityStatus? status,
    int? priceList,
    int? salesperson,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listCustomersApiV1CustomersGet(
        search: search,
        status: status?.toApi(),
        priceList: priceList,
        salesperson: salesperson,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return CustomerPage(
        items: result.items.map(domain.CustomerListItem.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Customer> get({required int customerId}) async {
    try {
      final response = await _api.getCustomerApiV1CustomersCustomerIdGet(
        customerId: customerId,
      );
      final customer = response.data;
      if (customer == null) throw const AppError.server();
      return Customer.fromResponse(customer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Customer> create({
    required String code,
    required String name,
    required int priceList,
    String? zone,
    String? creditLimit,
    int? creditDays,
    bool? shipping,
    bool? shippingRequiredDocument,
    int? salesperson,
    String? comment,
  }) async {
    try {
      final response = await _api.createCustomerApiV1CustomersPost(
        customerCreate: CustomerCreate((b) {
          b
            ..code = code
            ..name = name
            ..priceList = priceList
            ..zone = zone
            ..creditDays = creditDays
            ..shipping = shipping
            ..shippingRequiredDocument = shippingRequiredDocument
            ..salesperson = salesperson
            ..comment = comment;
          if (creditLimit != null) _setCreditLimit(b.creditLimit, creditLimit);
        }),
      );
      final customer = response.data;
      if (customer == null) throw const AppError.server();
      return Customer.fromResponse(customer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Customer> update({
    required int customerId,
    String? code,
    String? name,
    int? priceList,
    String? zone,
    String? creditLimit,
    int? creditDays,
    bool? shipping,
    bool? shippingRequiredDocument,
    int? salesperson,
    EntityStatus? status,
    String? comment,
  }) async {
    try {
      final response = await _api.updateCustomerApiV1CustomersCustomerIdPut(
        customerId: customerId,
        customerUpdate: CustomerUpdate((b) {
          if (code != null) b.code = code;
          if (name != null) b.name = name;
          if (priceList != null) b.priceList = priceList;
          if (zone != null) b.zone = zone;
          if (creditDays != null) b.creditDays = creditDays;
          if (shipping != null) b.shipping = shipping;
          if (shippingRequiredDocument != null) {
            b.shippingRequiredDocument = shippingRequiredDocument;
          }
          if (salesperson != null) b.salesperson = salesperson;
          if (status != null) b.status = status.toApi();
          if (comment != null) b.comment = comment;
          if (creditLimit != null) {
            _setCreditLimit1(b.creditLimit, creditLimit);
          }
        }),
      );
      final customer = response.data;
      if (customer == null) throw const AppError.server();
      return Customer.fromResponse(customer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int customerId}) async {
    try {
      await _api.deleteCustomerApiV1CustomersCustomerIdDelete(
        customerId: customerId,
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

/// `creditLimit` is `anyOf: [number, string]`; always send the String arm —
/// `AnyOf2<String, num>(values: {0: value})` — same proven construction as
/// Supplier's (research.md §4).
void _setCreditLimit(CreditLimitBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setCreditLimit1(CreditLimit1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
