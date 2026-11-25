import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/domain/repositories/commission_repository.dart';

final commissionRepositoryProvider = Provider<CommissionRepository>(
  (ref) => CommissionRepositoryImpl(ref.watch(dioProvider)),
);

/// `CommissionRepository` backed by the generated `CommissionsApi`
/// (spec 078).
class CommissionRepositoryImpl implements CommissionRepository {
  CommissionRepositoryImpl(Dio dio)
    : _api = api.CommissionsApi(dio, appSerializers);

  final api.CommissionsApi _api;

  @override
  Future<List<CommissionPeriodSummary>> listPeriods() => _call(() async {
    final response = await _api
        .listCommissionPeriodsApiV1CommissionsPeriodsGet();
    return _body(response).map(_summary).toList();
  });

  @override
  Future<CommissionPeriod> getPeriod(CommissionMonth month, {int? agentId}) =>
      _call(() async {
        final response = await _api
            .readCommissionPeriodApiV1CommissionsPeriodsYearMonthGet(
              year: month.year,
              month: month.month,
              salesperson: agentId,
            );
        return _period(_body(response), agentId);
      });

  @override
  Future<CommissionPeriodSummary> closePeriod(CommissionMonth month) =>
      _call(() async {
        final response = await _api
            .closeCommissionPeriodApiV1CommissionsPeriodsYearMonthClosePost(
              year: month.year,
              month: month.month,
            );
        return _afterAction(_body(response));
      });

  @override
  Future<CommissionPeriodSummary> reopenPeriod(CommissionMonth month) =>
      _call(() async {
        final response = await _api
            .reopenCommissionPeriodApiV1CommissionsPeriodsYearMonthReopenPost(
              year: month.year,
              month: month.month,
            );
        return _afterAction(_body(response));
      });

  @override
  Future<CommissionPeriodSummary> payPeriod(CommissionMonth month) =>
      _call(() async {
        final response = await _api
            .payCommissionPeriodApiV1CommissionsPeriodsYearMonthPayPost(
              year: month.year,
              month: month.month,
            );
        return _afterAction(_body(response));
      });

  @override
  Future<List<CommissionLabel>> listLabels() => _call(() async {
    final response = await _api.listCommissionLabelsApiV1CommissionsLabelsGet();
    return _body(response).map(_label).toList();
  });

  @override
  Future<CommissionLabel> createLabel({
    required String name,
    required Decimal rate,
    String? comment,
  }) => _call(() async {
    final response = await _api.createCommissionLabelApiV1CommissionsLabelsPost(
      commissionLabelCreate: api.CommissionLabelCreate((b) {
        b.name = name;
        b.commissionRate.anyOf = _decimalArm(rate);
        b.comment = comment;
      }),
    );
    return _label(_body(response));
  });

  @override
  Future<CommissionLabel> updateLabel(
    int id, {
    String? name,
    Decimal? rate,
    String? comment,
  }) => _call(() async {
    final response = await _api
        .updateCommissionLabelApiV1CommissionsLabelsCommissionIdPut(
          commissionId: id,
          commissionLabelUpdate: api.CommissionLabelUpdate((b) {
            b.name = name;
            if (rate != null) b.commissionRate.anyOf = _decimalArm(rate);
            b.comment = comment;
          }),
        );
    return _label(_body(response));
  });

  @override
  Future<void> deleteLabel(int id) => _call(
    () => _api.deleteCommissionLabelApiV1CommissionsLabelsCommissionIdDelete(
      commissionId: id,
    ),
  );

  @override
  Future<List<CommissionParticipation>> listParticipations() => _call(() async {
    final response = await _api
        .listCommissionParticipationsApiV1CommissionsParticipationsGet();
    return _body(response).map(_participation).toList();
  });

  @override
  Future<CommissionParticipation> createParticipation(String name) =>
      _call(() async {
        final response = await _api
            .createCommissionParticipationApiV1CommissionsParticipationsPost(
              commissionParticipationBody: api.CommissionParticipationBody(
                (b) => b.name = name,
              ),
            );
        return _participation(_body(response));
      });

  @override
  Future<CommissionParticipation> updateParticipation(
    int id,
    String name,
  ) => _call(() async {
    final response = await _api
        .updateCommissionParticipationApiV1CommissionsParticipationsParticipationIdPut(
          participationId: id,
          commissionParticipationBody: api.CommissionParticipationBody(
            (b) => b.name = name,
          ),
        );
    return _participation(_body(response));
  });

  @override
  Future<void> deleteParticipation(int id) => _call(
    () => _api
        .deleteCommissionParticipationApiV1CommissionsParticipationsParticipationIdDelete(
          participationId: id,
        ),
  );

  @override
  Future<List<CommissionAgent>> listAgents() => _call(() async {
    final response = await _api.listCommissionAgentsApiV1CommissionsAgentsGet();
    return _body(response).map(_agent).toList();
  });

  @override
  Future<CommissionAgent> createAgent(
    int employeeId,
    CommissionScheme scheme,
  ) => _call(() async {
    final response = await _api.createCommissionAgentApiV1CommissionsAgentsPost(
      commissionAgentCreate: api.CommissionAgentCreate((b) {
        b.employee = employeeId;
        b.scheme = _apiScheme(scheme);
      }),
    );
    return _agent(_body(response));
  });

  @override
  Future<CommissionAgent> updateAgent(
    int employeeId,
    CommissionScheme scheme,
  ) => _call(() async {
    final response = await _api
        .updateCommissionAgentApiV1CommissionsAgentsEmployeePut(
          employee: employeeId,
          commissionAgentUpdate: api.CommissionAgentUpdate(
            (b) => b.scheme = _apiScheme(scheme),
          ),
        );
    return _agent(_body(response));
  });

  @override
  Future<void> deleteAgent(int employeeId) => _call(
    () => _api.deleteCommissionAgentApiV1CommissionsAgentsEmployeeDelete(
      employee: employeeId,
    ),
  );

  @override
  Future<List<CommissionAgentRate>> listAgentRates({
    int? agentId,
    int? labelId,
  }) => _call(() async {
    final response = await _api
        .listCommissionAgentRatesApiV1CommissionsAgentRatesGet(
          salesperson: agentId,
          commission: labelId,
        );
    return _body(response).map(_agentRate).toList();
  });

  @override
  Future<CommissionAgentRate> createAgentRate({
    required int agentId,
    required int labelId,
    required int participationId,
    required Decimal share,
  }) => _call(() async {
    final response = await _api
        .createCommissionAgentRateApiV1CommissionsAgentRatesPost(
          commissionAgentRateCreate: api.CommissionAgentRateCreate((b) {
            b.salesperson = agentId;
            b.commission = labelId;
            b.commissionParticipation = participationId;
            b.participationRate.anyOf = _decimalArm(share);
          }),
        );
    return _agentRate(_body(response));
  });

  @override
  Future<CommissionAgentRate> updateAgentRate(
    int id,
    Decimal share,
  ) => _call(() async {
    final response = await _api
        .updateCommissionAgentRateApiV1CommissionsAgentRatesCommissionSalespersonIdPut(
          commissionSalespersonId: id,
          commissionAgentRateUpdate: api.CommissionAgentRateUpdate(
            (b) => b.participationRate.anyOf = _decimalArm(share),
          ),
        );
    return _agentRate(_body(response));
  });

  @override
  Future<void> deleteAgentRate(int id) => _call(
    () => _api
        .deleteCommissionAgentRateApiV1CommissionsAgentRatesCommissionSalespersonIdDelete(
          commissionSalespersonId: id,
        ),
  );

  @override
  Future<CommissionProductLabelPage> listProductLabels({
    int? labelId,
    int? productId,
    required int skip,
    required int limit,
  }) => _call(() async {
    final response = await _api
        .listCommissionProductLabelsApiV1CommissionsProductLabelsGet(
          commission: labelId,
          product: productId,
          skip: skip,
          limit: limit,
        );
    final page = _body(response);
    return CommissionProductLabelPage(
      items: page.items.map(_productLabel).toList(),
      total: page.total,
    );
  });

  @override
  Future<CommissionProductLabel> setProductLabel(int productId, int labelId) =>
      _call(() async {
        final response = await _api
            .setCommissionProductLabelApiV1CommissionsProductLabelsProductPut(
              product: productId,
              commissionProductLabelSet: api.CommissionProductLabelSet(
                (b) => b.commission = labelId,
              ),
            );
        return _productLabel(_body(response));
      });

  @override
  Future<void> removeProductLabel(int productId) => _call(
    () => _api
        .deleteCommissionProductLabelApiV1CommissionsProductLabelsProductDelete(
          product: productId,
        ),
  );
}

/// Runs [request], mapping a `DioException` to the `AppError` the
/// interceptor built (or `mapDioException`).
Future<T> _call<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    final mapped = e.error;
    throw mapped is AppError ? mapped : mapDioException(e);
  }
}

T _body<T>(Response<T> response) {
  final data = response.data;
  if (data == null) throw const AppError.server();
  return data;
}

/// Rates cross the wire as decimal strings: the String arm, key `0`.
AnyOf2<String, num> _decimalArm(Decimal value) =>
    AnyOf2<String, num>(values: {0: value.toString()});

api.CommissionScheme _apiScheme(CommissionScheme scheme) =>
    scheme == CommissionScheme.partialPayments
    ? api.CommissionScheme.number2
    : api.CommissionScheme.number1;

CommissionPeriodStatus _status(String wire) => switch (wire) {
  'closed' => CommissionPeriodStatus.closed,
  'paid' => CommissionPeriodStatus.paid,
  _ => CommissionPeriodStatus.open,
};

CommissionPeriodSummary _afterAction(api.CommissionPeriodResponse r) =>
    CommissionPeriodSummary(
      month: CommissionMonth(year: r.year, month: r.month),
      status: _status(r.status.name),
      total: Decimal.zero,
      closedAt: r.closedAt,
      paidAt: r.paidAt,
      reopenedAt: r.reopenedAt,
      closedBy: r.closedBy,
      paidBy: r.paidBy,
      reopenedBy: r.reopenedBy,
    );

CommissionPeriodSummary _summary(api.CommissionPeriodSummary s) =>
    CommissionPeriodSummary(
      month: CommissionMonth(year: s.year, month: s.month),
      status: _status(s.status.name),
      total: Decimal.parse(s.total),
      closedAt: s.closedAt,
      paidAt: s.paidAt,
      reopenedAt: s.reopenedAt,
      closedBy: s.closedBy,
      paidBy: s.paidBy,
      reopenedBy: s.reopenedBy,
    );

CommissionPeriod _period(api.CommissionPeriodDetail d, int? agentId) =>
    CommissionPeriod(
      month: CommissionMonth(year: d.year, month: d.month),
      status: _status(d.status.name),
      closedAt: d.closedAt,
      paidAt: d.paidAt,
      reopenedAt: d.reopenedAt,
      closedBy: d.closedBy,
      paidBy: d.paidBy,
      reopenedBy: d.reopenedBy,
      isFinal: d.final_,
      totals: d.totals.map(_total).toList(),
      lines: d.lines.map(_line).toList(),
      agentId: agentId,
    );

CommissionTotal _total(api.CommissionTotalResponse t) => CommissionTotal(
  agentId: t.salesperson,
  labelId: t.label,
  labelName: t.labelName,
  lines: t.lines,
  commission: Decimal.parse(t.commission),
);

CommissionLine _line(api.CommissionLineResponse l) => CommissionLine(
  movement: l.movement.name == 'refund'
      ? CommissionMovement.refund
      : CommissionMovement.sale,
  scheme: CommissionScheme.fromWire(l.scheme),
  salesOrderId: l.salesOrder,
  salesOrderDetailId: l.salesOrderDetail,
  customerRefundDetailId: l.customerRefundDetail,
  orderDate: l.orderDate,
  paidDate: l.paidDate,
  customerId: l.customer,
  customerName: l.customerName,
  productId: l.product,
  productName: l.productName,
  labelId: l.label,
  labelName: l.labelName,
  labelRate: Decimal.parse(l.labelRate),
  agentId: l.salesperson,
  orderSalespersonId: l.orderSalesperson,
  customerSalespersonId: l.customerSalesperson,
  participationId: l.participation,
  participationName: l.participationName,
  participationRate: Decimal.parse(l.participationRate),
  rate: Decimal.parse(l.rate),
  price: Decimal.parse(l.price),
  quantity: Decimal.parse(l.quantity),
  total: Decimal.parse(l.total),
  fullCommission: Decimal.parse(l.fullCommission),
  share: l.share == null ? null : Decimal.parse(l.share!),
  commission: Decimal.parse(l.commission),
);

CommissionLabel _label(api.CommissionLabelResponse l) => CommissionLabel(
  id: l.commissionId,
  name: l.name,
  rate: Decimal.parse(l.commissionRate),
  comment: l.comment,
);

CommissionParticipation _participation(api.CommissionParticipationResponse p) =>
    CommissionParticipation(id: p.commissionParticipationId, name: p.name);

CommissionAgent _agent(api.CommissionAgentResponse a) => CommissionAgent(
  employeeId: a.employee,
  name: a.name,
  scheme: CommissionScheme.fromWire(a.scheme),
);

CommissionAgentRate _agentRate(api.CommissionAgentRateResponse r) =>
    CommissionAgentRate(
      id: r.commissionSalespersonId,
      agentId: r.salesperson,
      labelId: r.commission,
      participationId: r.commissionParticipation,
      share: Decimal.parse(r.participationRate),
    );

CommissionProductLabel _productLabel(api.CommissionProductLabelResponse p) =>
    CommissionProductLabel(
      productId: p.product,
      productCode: p.productCode,
      productName: p.productName,
      labelId: p.commission,
    );
