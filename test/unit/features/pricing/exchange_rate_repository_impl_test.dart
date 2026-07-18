import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('ExchangeRateRepositoryImpl.list', () {
    test(
      '200 maps int currency codes to Currency, and date correctly',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'items': [_exchangeRateJson()],
              'total': 1,
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final result = await repository.list();

        expect(result.total, 1);
        final rate = result.items.single;
        expect(rate.exchangeRateId, 1);
        expect(rate.base, isNotNull);
        expect(rate.base!.value, 1); // usd
        expect(rate.target!.value, 0); // mxn
        expect(rate.rate, '17.50');
        expect(rate.date, DateTime(2026, 7, 17));
      },
    );

    test('an unrecognized currency code does not crash the list — falls back '
        'to the raw code (data-model.md §4)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              {..._exchangeRateJson(), 'base': 99, 'target': 98},
            ],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      final rate = result.items.single;
      expect(rate.base, isNull);
      expect(rate.rawBase, 99);
      expect(rate.target, isNull);
      expect(rate.rawTarget, 98);
    });

    test('forwards date-range and currency filter params', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(
        dateFrom: DateTime(2026, 1, 1),
        dateTo: DateTime(2026, 12, 31),
        base: 1,
        target: 0,
      );

      expect(captured!.queryParameters['date_from'], '2026-01-01');
      expect(captured!.queryParameters['date_to'], '2026-12-31');
      expect(captured!.queryParameters['base'], 1);
      expect(captured!.queryParameters['target'], 0);
    });
  });

  group('ExchangeRateRepositoryImpl.create — AnyOf write path', () {
    test('201 returns the created ExchangeRate', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_exchangeRateJson()),
          201,
          headers: _jsonHeaders,
        ),
      );

      final rate = await repository.create(
        date: DateTime(2026, 7, 17),
        rate: '17.50',
        base: 1,
        target: 0,
      );

      expect(rate.rate, '17.50');
    });

    test('⚠️ MANDATORY: sends rate as a JSON decimal string via the Rate '
        'wrapper (research.md §4)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_exchangeRateJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        date: DateTime(2026, 7, 17),
        rate: '17.50',
        base: 1,
        target: 0,
      );

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['rate'], '17.50');
      expect(sentBody['rate'], isA<String>());
      expect(sentBody['date'], '2026-07-17');
      expect(sentBody['base'], 1);
      expect(sentBody['target'], 0);
    });

    test('422 maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'rate'],
                'msg': 'Input should be greater than 0',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(
          date: DateTime(2026, 7, 17),
          rate: '0',
          base: 1,
          target: 0,
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('ExchangeRateRepositoryImpl.update — AnyOf write path (Rate1)', () {
    test('⚠️ MANDATORY: sends the updated rate via the distinct Rate1 wrapper '
        'as a JSON decimal string (research.md §4)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_exchangeRateJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(exchangeRateId: 1, rate: '18.00');

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['rate'], '18.00');
      expect(sentBody['rate'], isA<String>());
      expect(sentBody.containsKey('date'), isFalse);
      expect(sentBody.containsKey('base'), isFalse);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Exchange rate not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(exchangeRateId: 999, rate: '1'),
        throwsA(const AppError.notFound('Exchange rate not found')),
      );
    });
  });

  group('ExchangeRateRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(exchangeRateId: 1), completes);
    });
  });
}

Map<String, Object?> _exchangeRateJson() => {
  'exchange_rate_id': 1,
  'date': '2026-07-17',
  'rate': '17.50',
  'base': 1,
  'target': 0,
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

ExchangeRateRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return ExchangeRateRepositoryImpl(dio);
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
