import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group(
    'AddressRepositoryImpl.list (046-catalog-improvements research R9)',
    () {
      test(
        'forwards status when given, and maps each address status',
        () async {
          late RequestOptions sent;
          final repository = _repositoryWith((options) async {
            sent = options;
            return ResponseBody.fromString(
              jsonEncode({
                'items': [_addressJson(status: 1)],
                'total': 1,
              }),
              200,
              headers: _jsonHeaders,
            );
          });

          final result = await repository.list(
            search: 'centro',
            status: EntityStatus.active,
          );

          expect(sent.queryParameters['status'], EntityStatus.active.value);
          expect(sent.queryParameters['search'], 'centro');
          expect(result.items.single.status, EntityStatus.inactive);
        },
      );

      test('omitting status sends no status filter, as before', () async {
        late RequestOptions sent;
        final repository = _repositoryWith((options) async {
          sent = options;
          return ResponseBody.fromString(
            jsonEncode({'items': <Object>[], 'total': 0}),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.list();

        expect(sent.queryParameters.containsKey('status'), isFalse);
      });
    },
  );
}

Map<String, Object?> _addressJson({int status = 0}) => {
  'address_id': 10,
  'nickname': 'Matriz',
  'type': 3,
  'street': 'Calle 1',
  'exterior_number': '2',
  'interior_number': null,
  'postal_code': '06500',
  'neighborhood': 'Centro',
  'locality': null,
  'borough': 'Cuauhtémoc',
  'state': 'CDMX',
  'city': null,
  'country': 'México',
  'url_address': null,
  'comment': null,
  'status': status,
};

AddressRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return AddressRepositoryImpl(dio);
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
