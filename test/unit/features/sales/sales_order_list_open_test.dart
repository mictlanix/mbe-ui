import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';

/// `listOpen` through the **real** generated client rather than a mocked
/// repository, because that is where the open-sales selector broke: a local
/// `DateTime` passed as `date_from` makes built_value's
/// `Iso8601DateTimeSerializer` throw while the query string is being built, so
/// the request is abandoned before dio ever sends it. Every widget test mocks
/// `SalesOrderRepository`, so none of them can see that.
const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('listOpen query parameters', () {
    test('a UTC-flagged date reaches the wire as a plain ISO instant — the '
        'request is actually sent', () async {
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
        DateTime(2026, 8, 7).toUtc().toIso8601String(),
        reason: 'the instant that is local midnight — mbe-api#228 converts '
            'the offset back to the wall-clock date the register means. '
            'Computed, not hard-coded, so the expectation holds on a CI host '
            'in any timezone',
      );
    });

    test('a local DateTime is refused outright — the guard that would have '
        'caught the selector silently making no requests at all', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'items': <Object?>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        ),
      );

      expect(
        () => repository.listOpen(
          pointSale: 3,
          status: SaleStatus.draft,
          // Exactly what `DateTime(y, m, d)` produces.
          dateFrom: DateTime(2026, 8, 7),
        ),
        throwsA(isA<ArgumentError>()),
        reason: 'built_value serializes UTC only; this must never reach '
            'production as a silently dropped request',
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
      expect(query['date_from'], DateTime(2026, 8, 10).toUtc().toIso8601String());
      expect(
        query['date_to'],
        DateTime(2026, 8, 10, 23, 59, 59, 999).toUtc().toIso8601String(),
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
