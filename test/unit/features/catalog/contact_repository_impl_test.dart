import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _contactJson({
  int contactId = 21,
  String name = 'Ana López',
  String mobile = '5544332211',
  Object? phone = '5555555555',
}) => {
  'contact_id': contactId,
  'name': name,
  'job_title': 'Almacén',
  'phone': phone,
  'mobile': mobile,
  'email': 'ana@example.com',
};

void main() {
  group('ContactRepositoryImpl.list', () {
    test('maps the paged response onto entities', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_contactJson(), _contactJson(contactId: 22, name: 'Beto')],
            'total': 2,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final contacts = await repository.list(search: 'ana');

      expect(contacts, hasLength(2));
      expect(contacts.first.contactId, 21);
      expect(contacts.first.name, 'Ana López');
      expect(contacts.last.name, 'Beto');
    });

    test('forwards search/skip/limit as query parameters', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({'items': <Object>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(search: 'ana', skip: 20, limit: 10);

      expect(captured!.queryParameters['search'], 'ana');
      expect(captured!.queryParameters['skip'], 20);
      expect(captured!.queryParameters['limit'], 10);
    });

    test('an empty mobile normalizes to null so callers have one "absent" to '
        'test', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_contactJson(mobile: '', phone: null)],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final contact = (await repository.list()).single;

      expect(contact.mobile, isNull);
      expect(contact.phone, isNull);
      expect(contact.preferredPhone, isNull);
      expect(contact.displayLabel, 'Ana López');
    });

    test('displayLabel prefers the mobile over the phone', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_contactJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final contact = (await repository.list()).single;

      expect(contact.preferredPhone, '5544332211');
      expect(contact.displayLabel, 'Ana López · 5544332211');
    });
  });

  group('ContactRepositoryImpl.create', () {
    test('sends the captured fields and maps the created contact back',
        () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_contactJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      final created = await repository.create(
        name: 'Ana López',
        jobTitle: 'Almacén',
        mobile: '5544332211',
      );

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['name'], 'Ana López');
      expect(sentBody['job_title'], 'Almacén');
      expect(sentBody['mobile'], '5544332211');
      expect(created.contactId, 21);
    });

    test('a rejected create maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'name'],
                'msg': 'field required',
                'type': 'value_error.missing',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(name: ''),
        throwsA(isA<ValidationError>()),
      );
    });
  });
}

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

ContactRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return ContactRepositoryImpl(dio);
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
