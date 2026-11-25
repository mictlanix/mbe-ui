import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

import 'commission_fixtures.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

const _october = CommissionMonth(year: 2026, month: 10);

ResponseBody _ok(Object? json) =>
    ResponseBody.fromString(jsonEncode(json), 200, headers: _jsonHeaders);

ResponseBody _refusal(
  int status,
  String code, {
  Map<String, Object?>? params,
}) => ResponseBody.fromString(
  jsonEncode({'detail': 'Refused', 'code': code, 'params': ?params}),
  status,
  headers: _jsonHeaders,
);

Object? _decoded(Object? data) => data is String ? jsonDecode(data) : data;

void main() {
  test('listPeriods maps every state and keeps the total a Decimal', () async {
    final repository = _repositoryWith(
      (o) async => _ok([
        periodSummaryJson(status: 'paid', total: '1234.50'),
        periodSummaryJson(month: 9, status: 'open', total: '0.00'),
      ]),
    );

    final periods = await repository.listPeriods();

    expect(periods.first.month, _october);
    expect(periods.first.status, CommissionPeriodStatus.paid);
    expect(periods.first.total, d('1234.50'));
    expect(periods.first.closedBy, 4);
    expect(periods.first.closedAt, DateTime(2026, 11, 2, 9));
    expect(periods.first.reopenedBy, isNull);
    expect(periods.last.status, CommissionPeriodStatus.open);
  });

  test('getPeriod omits salesperson unless an agent is chosen', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((o) async {
      requests.add(o);
      return _ok(periodDetailJson(status: 'closed'));
    });

    final all = await repository.getPeriod(_october);
    final one = await repository.getPeriod(_october, agentId: 7);

    expect(requests[0].path, endsWith('/commissions/periods/2026/10'));
    expect(requests[0].queryParameters, isEmpty);
    expect(requests[1].queryParameters, {'salesperson': 7});
    expect(all.agentId, isNull);
    expect(one.agentId, 7);
    expect(all.isFinal, isTrue);
    expect(all.reopenedBy, 5);
    expect(all.paidBy, 6);
    expect(all.totals, hasLength(2));
    expect(all.totals.last.labelId, isNull);
    expect(all.grandTotal, d('200.00'));
  });

  test('a line keeps its rates and quantities as exact Decimals', () async {
    final repository = _repositoryWith(
      (o) async => _ok(
        periodDetailJson(
          lines: [
            lineJson(scheme: 2, share: '0.400000'),
            lineJson(movement: 'refund', label: null),
          ],
        ),
      ),
    );

    final period = await repository.getPeriod(_october);
    final sale = period.lines.first;
    final refund = period.lines.last;

    expect(sale.rate, d('0.025000'));
    expect(sale.rate.toString(), '0.025');
    expect(sale.quantity, d('2.500'));
    expect(sale.share, d('0.4'));
    expect(sale.scheme, CommissionScheme.partialPayments);
    expect(sale.movement, CommissionMovement.sale);
    expect(sale.customerRefundDetailId, isNull);
    expect(sale.orderSalespersonId, 7);
    expect(sale.customerSalespersonId, 8);
    expect(refund.movement, CommissionMovement.refund);
    expect(refund.customerRefundDetailId, 8);
    expect(refund.labelId, isNull);
    expect(refund.share, isNull);
  });

  test(
    'close, reopen and pay post to their routes and map the state',
    () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((o) async {
        requests.add(o);
        return _ok(periodResponseJson());
      });

      final closed = await repository.closePeriod(_october);
      await repository.reopenPeriod(_october);
      await repository.payPeriod(_october);

      expect(requests.map((r) => r.method), ['POST', 'POST', 'POST']);
      expect(requests[0].path, endsWith('/periods/2026/10/close'));
      expect(requests[1].path, endsWith('/periods/2026/10/reopen'));
      expect(requests[2].path, endsWith('/periods/2026/10/pay'));
      expect(closed.month, _october);
      expect(closed.status, CommissionPeriodStatus.closed);
      expect(closed.closedBy, 4);
      expect(closed.reopenedBy, 5);
      expect(closed.paidBy, 6);
    },
  );

  test('a status the client does not know is a server error', () async {
    // The generated status enum rejects an unknown wire value while
    // deserializing, before any mapping runs, so the response surfaces as
    // AppError.server (the private `_status` default to open is a backstop).
    final repository = _repositoryWith(
      (o) async => _ok(periodDetailJson(status: 'archived')),
    );

    await expectLater(repository.getPeriod(_october), throwsA(isA<AppError>()));
  });

  test('labels round trip a rate of 0.025000 as a Decimal string', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((o) async {
      if (o.method != 'GET') bodies.add(_decoded(o.data));
      return _ok(o.method == 'GET' ? [labelJson()] : labelJson());
    });

    final listed = await repository.listLabels();
    final created = await repository.createLabel(
      name: 'Premium',
      rate: d('0.025000'),
      comment: 'Nota',
    );
    await repository.updateLabel(3, rate: d('0.03'));
    await repository.updateLabel(3, name: 'Nuevo');

    expect(listed.single.rate, d('0.025'));
    expect(created.id, 3);
    expect(created.comment, 'Nota');
    expect(bodies[0], {
      'name': 'Premium',
      'commission_rate': '0.025',
      'comment': 'Nota',
    });
    expect(bodies[1], {'commission_rate': '0.03'});
    expect(bodies[2], {'name': 'Nuevo'});
  });

  test('participations list, create, update and delete', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((o) async {
      requests.add(o);
      if (o.method == 'DELETE') return ResponseBody.fromString('', 204);
      return _ok(
        o.method == 'GET' ? [participationJson()] : participationJson(),
      );
    });

    final listed = await repository.listParticipations();
    await repository.createParticipation('CANALIZACION');
    final updated = await repository.updateParticipation(2, 'CANALIZACION');
    await repository.deleteParticipation(2);

    expect(listed.single.id, 2);
    expect(updated.name, 'CANALIZACION');
    expect(_decoded(requests[1].data), {'name': 'CANALIZACION'});
    expect(requests[2].path, endsWith('/participations/2'));
    expect(requests[3].method, 'DELETE');
  });

  test('agents map the scheme both ways and the employee id', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((o) async {
      requests.add(o);
      if (o.method == 'DELETE') return ResponseBody.fromString('', 204);
      return _ok(o.method == 'GET' ? [agentJson()] : agentJson(scheme: 1));
    });

    final listed = await repository.listAgents();
    final created = await repository.createAgent(
      7,
      CommissionScheme.partialPayments,
    );
    await repository.updateAgent(7, CommissionScheme.fullyPaid);
    await repository.deleteAgent(7);

    expect(listed.single.employeeId, 7);
    expect(listed.single.scheme, CommissionScheme.partialPayments);
    expect(created.scheme, CommissionScheme.fullyPaid);
    expect(_decoded(requests[1].data), {'employee': 7, 'scheme': 2});
    expect(requests[2].path, endsWith('/agents/7'));
    expect(_decoded(requests[2].data), {'scheme': 1});
    expect(requests[3].method, 'DELETE');
  });

  test('agent rates filter, write the share as a string and delete', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((o) async {
      requests.add(o);
      if (o.method == 'DELETE') return ResponseBody.fromString('', 204);
      return _ok(o.method == 'GET' ? [agentRateJson()] : agentRateJson());
    });

    final listed = await repository.listAgentRates(agentId: 7, labelId: 3);
    await repository.listAgentRates();
    final created = await repository.createAgentRate(
      agentId: 7,
      labelId: 3,
      participationId: 2,
      share: d('0.025000'),
    );
    await repository.updateAgentRate(41, d('0.5'));
    await repository.deleteAgentRate(41);

    expect(requests[0].queryParameters, {'salesperson': 7, 'commission': 3});
    expect(requests[1].queryParameters, isEmpty);
    expect(listed.single.id, 41);
    expect(listed.single.participationId, 2);
    expect(listed.single.share, d('0.025'));
    expect(created.agentId, 7);
    expect(_decoded(requests[2].data), {
      'salesperson': 7,
      'commission': 3,
      'commission_participation': 2,
      'participation_rate': '0.025',
    });
    expect(_decoded(requests[3].data), {'participation_rate': '0.5'});
    expect(requests[3].path, endsWith('/agent-rates/41'));
    expect(requests[4].method, 'DELETE');
  });

  test('product labels page with skip and limit and filter', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((o) async {
      requests.add(o);
      if (o.method == 'DELETE') return ResponseBody.fromString('', 204);
      if (o.method == 'PUT') return _ok(productLabelJson());
      return _ok({
        'items': [productLabelJson()],
        'total': 41,
      });
    });

    final page = await repository.listProductLabels(
      labelId: 3,
      productId: 5,
      skip: 40,
      limit: 20,
    );
    await repository.listProductLabels(skip: 0, limit: 20);
    final set = await repository.setProductLabel(5, 3);
    await repository.removeProductLabel(5);

    expect(requests[0].queryParameters, {
      'commission': 3,
      'product': 5,
      'skip': 40,
      'limit': 20,
    });
    expect(requests[1].queryParameters, {'skip': 0, 'limit': 20});
    expect(page.total, 41);
    expect(page.items.single.productCode, 'A-100');
    expect(page.items.single.labelId, 3);
    expect(set.productId, 5);
    expect(requests[2].path, endsWith('/product-labels/5'));
    expect(_decoded(requests[2].data), {'commission': 3});
    expect(requests[3].method, 'DELETE');
  });

  test('a 409 refusal reaches AppError with its code and params', () async {
    final repository = _repositoryWith(
      (o) async => _refusal(
        409,
        'commission_period.not_ended',
        params: {'year': 2026, 'month': 12},
      ),
    );

    await expectLater(
      repository.closePeriod(const CommissionMonth(year: 2026, month: 12)),
      throwsA(
        isA<AppError>().having(
          (e) => e.problem?.code,
          'code',
          api.ErrorCode.commissionPeriodPeriodNotEnded,
        ),
      ),
    );
  });

  test('a 422 refusal reaches AppError with its code', () async {
    final repository = _repositoryWith(
      (o) async => _refusal(422, 'commission_agent.salesperson_not_agent'),
    );

    await expectLater(
      repository.createAgentRate(
        agentId: 99,
        labelId: 3,
        participationId: 2,
        share: d('0.5'),
      ),
      throwsA(
        isA<AppError>().having(
          (e) => e.problem?.code,
          'code',
          api.ErrorCode.commissionAgentPeriodSalespersonNotAgent,
        ),
      ),
    );
  });

  test('an empty body is a server error', () async {
    final repository = _repositoryWith(
      (o) async => ResponseBody.fromString('', 200, headers: _jsonHeaders),
    );

    await expectLater(repository.listPeriods(), throwsA(isA<AppError>()));
  });
}

CommissionRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return CommissionRepositoryImpl(dio);
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);

  @override
  void close({bool force = false}) {}
}
