import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/data/wire_value_setters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sales_quote_summary.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_quote_repository.dart';

final salesQuoteRepositoryProvider = Provider<SalesQuoteRepository>((ref) {
  return SalesQuoteRepositoryImpl(ref.watch(dioProvider));
});

/// `SalesQuoteRepository` backed by the generated `mbe_api_client`
/// `SalesQuotesApi` (spec 040, contracts/sales-quote-repository.md §1).
class SalesQuoteRepositoryImpl implements SalesQuoteRepository {
  SalesQuoteRepositoryImpl(Dio dio) : _api = api.SalesQuotesApi(dio, api.standardSerializers);

  final api.SalesQuotesApi _api;

  @override
  Future<Sale> open({int? customer, int? salesperson}) async {
    try {
      final response = await _api.createSalesQuoteApiV1SalesQuotesPost(
        salesQuoteCreate: api.SalesQuoteCreate((b) {
          b
            ..customer = customer
            ..salesperson = salesperson;
        }),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toQuoteError(e);
    }
  }

  @override
  Future<Sale> getById({required int quoteId}) async {
    try {
      final response = await _api.getSalesQuoteApiV1SalesQuotesSalesQuoteIdGet(
        salesQuoteId: quoteId,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> updateHeader({
    required int quoteId,
    int? customer,
    int? salesperson,
    PaymentTerms? paymentTerms,
    Currency? currency,
    DateTime? dueDate,
    int? contact,
    int? shipTo,
    String? comment,
  }) async {
    try {
      final response = await _api.updateSalesQuoteApiV1SalesQuotesSalesQuoteIdPut(
        salesQuoteId: quoteId,
        salesQuoteUpdate: api.SalesQuoteUpdate((b) {
          b
            ..customer = customer
            ..salesperson = salesperson
            ..paymentTerms = paymentTerms?.toApi()
            ..currency = currency == null ? null : currencyToApi(currency)
            ..dueDate = dueDate
            ..contact = contact
            ..shipTo = shipTo
            ..comment = comment;
        }),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toQuoteError(e);
    }
  }

  @override
  Future<Sale> addLine({
    required int quoteId,
    required int product,
    String? quantity,
    String? price,
    String? priceAdjustment,
    String? discountRate,
    String? comment,
  }) async {
    try {
      final response = await _api.addSalesQuoteLineApiV1SalesQuotesSalesQuoteIdLinesPost(
        salesQuoteId: quoteId,
        salesQuoteLineCreate: api.SalesQuoteLineCreate((b) {
          b
            ..product = product
            ..comment = comment;
          if (quantity != null) setQuantity(b.quantity, quantity);
          if (price != null) setPrice1(b.price, price);
          if (priceAdjustment != null) {
            setPriceAdjustment(b.priceAdjustment, priceAdjustment);
          }
          if (discountRate != null) {
            setDiscountRate(b.discountRate, discountRate);
          }
        }),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> updateLine({
    required int quoteId,
    required int lineId,
    String? quantity,
    String? price,
    String? priceAdjustment,
    String? discountRate,
    String? comment,
  }) async {
    try {
      final response = await _api
          .updateSalesQuoteLineApiV1SalesQuotesSalesQuoteIdLinesLineIdPut(
            salesQuoteId: quoteId,
            lineId: lineId,
            salesQuoteLineUpdate: api.SalesQuoteLineUpdate((b) {
              b.comment = comment;
              if (quantity != null) setQuantity(b.quantity, quantity);
              if (price != null) setPrice1(b.price, price);
              if (priceAdjustment != null) {
                setPriceAdjustment1(b.priceAdjustment, priceAdjustment);
              }
              if (discountRate != null) {
                setDiscountRate1(b.discountRate, discountRate);
              }
            }),
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> removeLine({required int quoteId, required int lineId}) async {
    try {
      final response = await _api
          .removeSalesQuoteLineApiV1SalesQuotesSalesQuoteIdLinesLineIdDelete(
            salesQuoteId: quoteId,
            lineId: lineId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> confirm({required int quoteId}) async {
    try {
      final response = await _api
          .confirmSalesQuoteApiV1SalesQuotesSalesQuoteIdConfirmPost(
            salesQuoteId: quoteId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> cancel({required int quoteId}) async {
    try {
      // Returns the quote directly (contracts/sales-quote-repository.md §1)
      // — unlike `SalesOrderRepositoryImpl.cancel`, there is no read-back
      // here: the quote endpoint's response is not discarded, so there is
      // nothing this call needs a second round trip to recover.
      final response = await _api
          .cancelSalesQuoteApiV1SalesQuotesSalesQuoteIdCancelPost(
            salesQuoteId: quoteId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> duplicate({required int quoteId}) async {
    try {
      final response = await _api
          .duplicateSalesQuoteApiV1SalesQuotesSalesQuoteIdDuplicatePost(
            salesQuoteId: quoteId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Sale.fromQuoteResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Sale> convert({required int quoteId}) async {
    try {
      final response = await _api
          .convertSalesQuoteApiV1SalesQuotesSalesQuoteIdConvertPost(
            salesQuoteId: quoteId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      // The convert endpoint returns a SALES ORDER, not a quote — mapped
      // through `Sale.fromResponse`, the order-shaped factory, never
      // `fromQuoteResponse` (contracts/sales-quote-repository.md §1).
      return Sale.fromResponse(result);
    } on DioException catch (e) {
      throw _toQuoteError(e);
    }
  }

  @override
  Future<SalesQuotePage> listQuotes({
    bool mine = false,
    int? customer,
    int? salesperson,
    SaleStatus? status,
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listSalesQuotesApiV1SalesQuotesGet(
        mine: mine,
        customer: customer,
        salesperson: salesperson,
        status: status?.wireName,
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return SalesQuotePage(
        items: result.items.map(SalesQuoteSummary.fromResponse).toList(),
        total: result.total,
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

/// A refusal on `open`, `updateHeader` or `convert` can answer a **422 with
/// a plain string `detail`** — mbe-api credit-checks on order creation, and
/// `convert` creates one, so the same shape `SalesOrderRepositoryImpl.
/// _toSalesOrderError` guards against reaches this repository too. It also
/// covers FR-030's "no point of sale configured for your user" refusal on
/// `convert`, which arrives the same way. The global interceptor's own
/// mapping (`mapDioException`) reads `detail` only as a `List` (FastAPI's
/// field-level validation shape), so a plain string there maps to
/// `AppError.validation(const [])` — the message silently vanishes, not
/// merely goes unstyled.
///
/// This is the single highest-risk omission this repository could make:
/// without it, the one refusal a back-office user without a point of sale
/// is most likely to hit renders as a bare "validation failed" with no
/// explanation at all (contracts/sales-quote-repository.md §2).
AppError _toQuoteError(DioException error) {
  final data = error.response?.data;
  if (error.response?.statusCode == 422 && data is Map) {
    final detail = data['detail'];
    if (detail is String) return AppError.creditHold(detail);
  }
  return _toAppError(error);
}
