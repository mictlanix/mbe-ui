import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';

final salesOrderRepositoryProvider = Provider<SalesOrderRepository>((ref) {
  return SalesOrderRepositoryImpl(ref.watch(dioProvider));
});

/// `SalesOrderRepository` backed by the generated `mbe_api_client`
/// `SalesOrdersApi` (contracts/mbe-api-pos.md §1).
class SalesOrderRepositoryImpl implements SalesOrderRepository {
  SalesOrderRepositoryImpl(Dio dio) : _api = api.SalesOrdersApi(dio, api.standardSerializers);

  final api.SalesOrdersApi _api;

  @override
  Future<Sale> open() async {
    try {
      final response = await _api.createSalesOrderApiV1SalesOrdersPost(
        salesOrderCreate: api.SalesOrderCreate(),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> getById({required int saleId}) async {
    try {
      final response = await _api.getSalesOrderApiV1SalesOrdersSalesOrderIdGet(
        salesOrderId: saleId,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> updateHeader({
    required int saleId,
    int? customer,
    PaymentTerms? paymentTerms,
    Currency? currency,
    int? shipTo,
    int? contact,
    String? customerName,
    FulfillmentMode? fulfillmentIntent,
    DateTime? promiseDate,
    int? salesperson,
    Priority? priority,
    String? comment,
    String? recipient,
  }) async {
    try {
      final response = await _api.updateSalesOrderApiV1SalesOrdersSalesOrderIdPut(
        salesOrderId: saleId,
        salesOrderUpdate: api.SalesOrderUpdate((b) {
          b
            ..customer = customer
            ..paymentTerms = paymentTerms?.toApi()
            ..currency = currency == null ? null : currencyToApi(currency)
            ..shipTo = shipTo
            ..contact = contact
            ..customerName = customerName
            ..fulfillmentIntent = fulfillmentIntent?.toApi()
            ..promiseDate = promiseDate
            ..salesperson = salesperson
            // Deliberately no `dueDate` here: it is derived server-side and
            // `SalesOrderUpdate` has no such field to set.
            ..priority = priority?.toApi()
            ..comment = comment
            ..recipient = recipient;
        }),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> addLine({
    required int saleId,
    required int product,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  }) async {
    try {
      final response = await _api.addSalesOrderLineApiV1SalesOrdersSalesOrderIdLinesPost(
        salesOrderId: saleId,
        salesOrderLineCreate: api.SalesOrderLineCreate((b) {
          b
            ..product = product
            ..warehouse = warehouse
            ..comment = comment;
          if (quantity != null) _setQuantity(b.quantity, quantity);
          if (price != null) _setPrice1(b.price, price);
          if (discountRate != null) {
            _setDiscountRate(b.discountRate, discountRate);
          }
          if (taxRate != null) _setTaxRate1(b.taxRate, taxRate);
        }),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> updateLine({
    required int saleId,
    required int lineId,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  }) async {
    try {
      final response = await _api
          .updateSalesOrderLineApiV1SalesOrdersSalesOrderIdLinesLineIdPut(
            salesOrderId: saleId,
            lineId: lineId,
            salesOrderLineUpdate: api.SalesOrderLineUpdate((b) {
              b
                ..warehouse = warehouse
                ..comment = comment;
              if (quantity != null) _setQuantity(b.quantity, quantity);
              if (price != null) _setPrice1(b.price, price);
              if (discountRate != null) {
                _setDiscountRate1(b.discountRate, discountRate);
              }
              if (taxRate != null) _setTaxRate1(b.taxRate, taxRate);
            }),
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> removeLine({required int saleId, required int lineId}) async {
    try {
      final response = await _api
          .removeSalesOrderLineApiV1SalesOrdersSalesOrderIdLinesLineIdDelete(
            salesOrderId: saleId,
            lineId: lineId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> confirm({required int saleId}) async {
    try {
      final response = await _api
          .confirmSalesOrderApiV1SalesOrdersSalesOrderIdConfirmPost(
            salesOrderId: saleId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromResponse(result);
    } on DioException catch (e) {
      throw _toConfirmError(e);
    }
  }

  @override
  Future<void> cancel({required int saleId}) async {
    try {
      await _api.cancelSalesOrderApiV1SalesOrdersSalesOrderIdCancelPost(
        salesOrderId: saleId,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<List<ProductLookupResult>> productLookup({
    required String pattern,
    required int customer,
    int? warehouse,
  }) async {
    try {
      final response = await _api
          .lookupProductsApiV1SalesOrdersProductLookupGet(
            pattern: pattern,
            customer: customer,
            warehouse: warehouse,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.map(ProductLookupResult.fromResponse).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<OpenSalePage> listOpen({
    required int pointSale,
    required SaleStatus status,
    DateTime? dateFrom,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _api.listSalesOrdersApiV1SalesOrdersGet(
        pointSale: pointSale,
        status: status.wireName,
        dateFrom: dateFrom,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return OpenSalePage(
        items: result.items.map(OpenSale.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<OpenSalePage> listSales({
    required int pointSale,
    SaleStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listSalesOrdersApiV1SalesOrdersGet(
        pointSale: pointSale,
        status: status?.wireName,
        dateFrom: dateFrom == null ? null : wireDate(dateFrom),
        dateTo: dateTo == null ? null : wireDateEnd(dateTo),
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return OpenSalePage(
        items: result.items.map(OpenSale.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<OpenSalePage> listOrders({
    bool mine = false,
    int? facility,
    int? salesperson,
    SaleStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listSalesOrdersApiV1SalesOrdersGet(
        mine: mine,
        facility: facility,
        salesperson: salesperson,
        status: status?.wireName,
        dateFrom: dateFrom == null ? null : wireDate(dateFrom),
        dateTo: dateTo == null ? null : wireDateEnd(dateTo),
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return OpenSalePage(
        items: result.items.map(OpenSale.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// Midnight of [local]'s date, flagged UTC — the only encoding that both
/// serializes (built_value's `Iso8601DateTimeSerializer` throws
/// `ArgumentError` on a local `DateTime`) and selects the intended rows
/// (mbe-api ignores the offset and reads the value as local wall-clock time —
/// verified against a live backend: `…T18:00:00Z` and `…T18:00:00` select the
/// same rows, where `…T12:00:00` selects more). Extracted from
/// `open_sales_selector_controller.dart`'s `_startOfToday`, which now defers
/// to this for the same reasoning (spec 023 research R3, R6).
DateTime wireDate(DateTime local) => DateTime.utc(local.year, local.month, local.day);

/// The last instant of [local]'s date — the `date_to` counterpart to
/// [wireDate], which is only ever right for `date_from`.
///
/// mbe-api compares `date_to` against the sale's *full timestamp*, inclusively
/// — it does not truncate it to a calendar day (spec 023 research U2, settled
/// live: `date_to=…T15:27:35` keeps the 15:27:35 sale, `…T15:27:34` drops it).
/// So a range whose end is plain midnight selects `[00:00:00, 00:00:00]`, an
/// empty window that answers `total: 0` for any day with actual trading on it.
DateTime wireDateEnd(DateTime local) =>
    DateTime.utc(local.year, local.month, local.day, 23, 59, 59, 999);

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}

/// Confirmation refusals carry more than a headline (FR-039,
/// contracts/pos-screen.md §6): mbe-api answers a 409 with
/// `{"detail": {"message": "Insufficient stock", "lines": ["`PRODUCT` requires
/// stock but no warehouse is set", ...]}}` — verified against a live backend.
/// `mapDioException` keeps only `message`, which would leave the cashier
/// knowing something is wrong but not which line, so the per-line reasons are
/// appended here. Every other endpoint keeps the plain [_toAppError] mapping.
AppError _toConfirmError(DioException error) {
  final data = error.response?.data;
  if (data is Map) {
    final detail = data['detail'];
    if (detail is Map) {
      final message = detail['message'];
      final lines = detail['lines'];
      if (message is String) {
        final reasons = lines is List
            ? lines.map((line) => line.toString()).toList()
            : const <String>[];
        return AppError.server(
          statusCode: error.response?.statusCode,
          message: [message, ...reasons].join('\n'),
        );
      }
    }
  }
  return _toAppError(error);
}

/// `quantity`/`price`/`discount_rate`/`tax_rate` are all `anyOf: [string,
/// num]` in mbe-api's schema; this project always sends the String arm via
/// `AnyOf2<String, num>(values: {0: value})` (String first, key `0` —
/// mirrors the proven `_setCommission`/`_setOpeningAmount` precedents in
/// sibling repositories, verified there against a live serialization
/// round-trip). Each generated wrapper type is distinct
/// (`Quantity`/`Price1`/`DiscountRate`/`DiscountRate1`/`TaxRate1`), so each
/// gets its own tiny setter rather than one generic function.
void _setQuantity(api.QuantityBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setPrice1(api.Price1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setDiscountRate(api.DiscountRateBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setDiscountRate1(api.DiscountRate1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setTaxRate1(api.TaxRate1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
