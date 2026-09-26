import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';

/// `listOpen` through the **real** generated client rather than a mocked
/// repository, because that is where the open-sales selector broke: a local
/// `DateTime` passed as `date_from` used to make built_value's
/// `Iso8601DateTimeSerializer` throw while the query string was being built,
/// so the request was abandoned before dio ever sent it. Every widget test
/// mocks `SalesOrderRepository`, so none of them could see that.
///
/// Since spec 043 (mictlanix/mbe-ui#176), `appSerializers`'s
/// `WallClockDateTimeSerializer` accepts a local `DateTime` and writes it as
/// mbe-api's own wall-clock convention — a plain string with no offset — so
/// the regression this file guards against is that a *future* change
/// reintroduces the throw, not that today's code has it.
const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('listOpen query parameters', () {
    test("wireDate's output reaches the wire as its own wall-clock string — "
        'the request is actually sent', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({'items': <Object?>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listOpen(
        pointSale: 3,
        status: SaleStatus.draft,
        // `listOpen` trusts its caller to have encoded the date — the
        // production caller is `_startOfToday()`, which is exactly this.
        dateFrom: wireDate(DateTime(2026, 8, 7)),
      );

      expect(requests, hasLength(1));
      final query = requests.single.queryParameters;
      expect(query['point_sale'], 3);
      expect(query['status'], 'draft');
      expect(
        query['date_from'],
        '2026-08-07T00:00:00.000',
        reason: 'the wall-clock date the register means, with no offset — '
            'the literal string mbe-api always receives regardless of host '
            'timezone, since WallClockDateTimeSerializer formats a value\'s '
            'own fields rather than converting through the host\'s clock '
            '(FR-003, FR-004)',
      );
    });

    test('a local DateTime reaches the wire as its own wall clock — the '
        'guard that would have caught the selector silently making no '
        'requests at all', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({'items': <Object?>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listOpen(
        pointSale: 3,
        status: SaleStatus.draft,
        // Exactly what `DateTime(y, m, d)` produces — no longer refused.
        dateFrom: DateTime(2026, 8, 7),
      );

      expect(requests, hasLength(1));
      expect(
        requests.single.queryParameters['date_from'],
        '2026-08-07T00:00:00.000',
        reason: 'a local DateTime used to make built_value serialize-time '
            'throw an ArgumentError, silently dropping the request before '
            'dio ever sent it (research R5); it must now reach the wire '
            'with no offset instead (FR-003)',
      );
    });

    test('omitting the date sends no date_from at all', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({'items': <Object?>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listOpen(pointSale: 3, status: SaleStatus.paid);

      expect(requests.single.queryParameters.containsKey('date_from'), isFalse);
    });
  });

  group('listSales query parameters', () {
    test('a single-day range spans that whole day — `date_to` at plain '
        'midnight selects nothing', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({'items': <Object?>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listSales(
        pointSale: 18,
        dateFrom: DateTime(2026, 8, 10),
        dateTo: DateTime(2026, 8, 10),
      );

      final query = requests.single.queryParameters;
      expect(query['date_from'], '2026-08-10T00:00:00.000');
      expect(
        query['date_to'],
        '2026-08-10T23:59:59.999',
        reason: 'mbe-api compares date_to against the sale\'s full timestamp, '
            'inclusively — encoding it as midnight made the default '
            '"today" filter answer total: 0 for a register that had traded',
      );
    });

    test(
      'origin: pointOfSale reaches the wire as origin=0 — spec 041 (amended): '
      'the register\'s list filters inclusively, so a sale with no recorded '
      'origin is left out here too',
      () async {
        final requests = <RequestOptions>[];
        final repository = _repositoryWith((options) async {
          requests.add(options);
          return ResponseBody.fromString(
            jsonEncode({'items': <Object?>[], 'total': 0}),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.listSales(
          pointSale: 18,
          origin: SaleOrigin.pointOfSale,
        );

        final query = requests.single.queryParameters;
        expect(query['origin'], 0);
        expect(
          query.containsKey('exclude_origin'),
          isFalse,
          reason: 'the register\'s list narrows inclusively; exclusion is the '
              'back-office list\'s mechanism, not this one\'s',
        );
      },
    );

    test(
      'omitting origin sends neither origin nor exclude_origin at all',
      () async {
        final requests = <RequestOptions>[];
        final repository = _repositoryWith((options) async {
          requests.add(options);
          return ResponseBody.fromString(
            jsonEncode({'items': <Object?>[], 'total': 0}),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.listSales(pointSale: 18);

        final query = requests.single.queryParameters;
        expect(query.containsKey('exclude_origin'), isFalse);
        expect(query.containsKey('origin'), isFalse);
      },
    );
  });
}

SalesOrderRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return SalesOrderRepositoryImpl(dio);
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
