import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart'
    hide CashSessionStatus, DenominationCount;
import 'package:mbe_api_client/mbe_api_client.dart' as gen show DenominationCount;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/denomination_count.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';

final cashSessionRepositoryProvider = Provider<CashSessionRepository>((ref) {
  return CashSessionRepositoryImpl(ref.watch(dioProvider));
});

class CashSessionRepositoryImpl implements CashSessionRepository {
  CashSessionRepositoryImpl(Dio dio) : _api = CashSessionsApi(dio, standardSerializers);

  final CashSessionsApi _api;

  @override
  Future<CurrentSession> getCurrent() async {
    try {
      final response = await _api.getCurrentSessionApiV1CashSessionsCurrentGet();
      final result = response.data;
      if (result == null) throw const AppError.server();
      return CurrentSession.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<CashSessionListResult> list({
    int? cashDrawerId,
    int? cashierId,
    CashSessionStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listCashSessionsApiV1CashSessionsGet(
        cashDrawer: cashDrawerId,
        cashier: cashierId,
        status: status?.toApi(),
        dateFrom: dateFrom,
        dateTo: dateTo,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return CashSessionListResult(
        items: result.items.map(CashSession.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<CashSession> open({int? cashDrawerId, required String openingAmount}) async {
    try {
      final response = await _api.openCashSessionApiV1CashSessionsPost(
        cashSessionOpen: CashSessionOpen((b) {
          b.cashDrawer = cashDrawerId;
          _setOpeningAmount(b.openingAmount, openingAmount);
        }),
      );
      final cashSession = response.data;
      if (cashSession == null) throw const AppError.server();
      return CashSession.fromResponse(cashSession);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<CashSession> get({required int cashSessionId}) async {
    try {
      final response = await _api.getCashSessionApiV1CashSessionsCashSessionIdGet(
        cashSessionId: cashSessionId,
      );
      final cashSession = response.data;
      if (cashSession == null) throw const AppError.server();
      return CashSession.fromResponse(cashSession);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<CashSession> close({
    required int cashSessionId,
    required List<DenominationCount> counts,
  }) async {
    try {
      final response = await _api
          .closeCashSessionApiV1CashSessionsCashSessionIdClosePost(
            cashSessionId: cashSessionId,
            cashSessionClose: CashSessionClose((b) {
              b.counts = ListBuilder(
                counts.map(
                  (c) => gen.DenominationCount((cb) {
                    _setDenomination(cb.denomination, c.denomination);
                    cb.quantity = c.quantity;
                  }),
                ),
              );
            }),
          );
      final cashSession = response.data;
      if (cashSession == null) throw const AppError.server();
      return CashSession.fromResponse(cashSession);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}

/// `opening_amount` is `anyOf: [string, num]`; this project always sends the
/// String arm via `AnyOf2<String, num>(values: {0: value})` — String as the
/// *first* type parameter, key `0` (mirrors the proven `_setHighProfitMargin`/
/// `_setCommission` precedents in the pricing/catalog repositories; the
/// reverse order throws a type mismatch at runtime, verified there against a
/// live serialization round-trip).
void _setOpeningAmount(OpeningAmountBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

/// Same `anyOf: [string, num]` shape as `opening_amount`, same shim.
void _setDenomination(DenominationBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
