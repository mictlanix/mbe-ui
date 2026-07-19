import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group(
    'SatCatalogRepositoryImpl.listUnitsOfMeasurement (existing, unaffected)',
    () {
      test('200 maps to SatCatalogItems', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'items': [_satJson('KGM', 'Kilogram')],
              'total': 1,
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final result = await repository.listUnitsOfMeasurement();

        expect(result.items.single.code, 'KGM');
        expect(result.items.single.description, 'Kilogram');
      });
    },
  );

  group(
    'SatCatalogRepositoryImpl.listProductServices (existing, unaffected)',
    () {
      test('200 maps to SatCatalogItems', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'items': [_satJson('10101500', 'Live animals')],
              'total': 1,
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final result = await repository.listProductServices();

        expect(result.items.single.code, '10101500');
      });
    },
  );

  group(
    'SatCatalogRepositoryImpl.listPostalCodes (spec 012 research.md §5)',
    () {
      test('200 maps to SatCatalogItems', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'items': [_satJson('06500', 'Ciudad de México')],
              'total': 1,
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final result = await repository.listPostalCodes();

        expect(result.items.single.code, '06500');
        expect(result.items.single.description, 'Ciudad de México');
      });

      test('forwards search/skip/limit as query params', () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode({'items': [], 'total': 0}),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.listPostalCodes(search: '065', skip: 20, limit: 10);

        expect(captured!.queryParameters['search'], '065');
        expect(captured!.queryParameters['skip'], 20);
        expect(captured!.queryParameters['limit'], 10);
      });

      test('5xx maps to AppError.server', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString('', 503),
        );

        await expectLater(
          () => repository.listPostalCodes(),
          throwsA(const AppError.server(statusCode: 503)),
        );
      });
    },
  );

  group(
    'SatCatalogRepositoryImpl.listTaxRegimes (spec 012 research.md §5)',
    () {
      test('200 maps to SatCatalogItems', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'items': [_satJson('601', 'General de Ley Personas Morales')],
              'total': 1,
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final result = await repository.listTaxRegimes();

        expect(result.items.single.code, '601');
      });

      test('forwards search/skip/limit as query params', () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode({'items': [], 'total': 0}),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.listTaxRegimes(search: 'General', skip: 20, limit: 10);

        expect(captured!.queryParameters['search'], 'General');
        expect(captured!.queryParameters['skip'], 20);
        expect(captured!.queryParameters['limit'], 10);
      });
    },
  );
}

Map<String, Object?> _satJson(String id, String description) => {
  'id': id,
  'description': description,
};

SatCatalogRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return SatCatalogRepositoryImpl(dio);
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
