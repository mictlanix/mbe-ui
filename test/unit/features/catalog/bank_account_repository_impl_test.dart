import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/bank_account_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('BankAccountRepositoryImpl.list', () {
    test('forwards search/skip/limit and maps items and total', () async {
      late RequestOptions sent;
      final repository = _repositoryWith((options) async {
        sent = options;
        return ResponseBody.fromString(
          jsonEncode({
            'items': [_bankAccountJson()],
            'total': 7,
          }),
          200,
          headers: _jsonHeaders,
        );
      });

      final result = await repository.list(search: 'bbva', skip: 20, limit: 10);

      expect(sent.queryParameters['search'], 'bbva');
      expect(sent.queryParameters['skip'], 20);
      expect(sent.queryParameters['limit'], 10);
      expect(result.total, 7);
      expect(result.items.single.bankAccountId, 31);
      expect(result.items.single.label, 'BBVA · 0123456789');
    });
  });

  group('BankAccountRepositoryImpl.create', () {
    test('sends the fields and maps the created account', () async {
      late RequestOptions sent;
      final repository = _repositoryWith((options) async {
        sent = options;
        return ResponseBody.fromString(
          jsonEncode(_bankAccountJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      final account = await repository.create(
        bankName: 'BBVA',
        accountNumber: '0123456789',
        reference: 'Main',
        routingNumber: '012345678901234567',
        comment: 'Payroll',
      );

      final body = sent.data is String
          ? jsonDecode(sent.data as String) as Map<String, Object?>
          : sent.data as Map<String, Object?>;
      expect(body['bank_name'], 'BBVA');
      expect(body['account_number'], '0123456789');
      expect(body['reference'], 'Main');
      expect(body['routing_number'], '012345678901234567');
      expect(body['comment'], 'Payroll');
      expect(account.bankAccountId, 31);
    });

    test('a DioException maps to AppError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 503),
      );

      await expectLater(
        () => repository.create(bankName: 'BBVA', accountNumber: '1'),
        throwsA(const AppError.server(statusCode: 503)),
      );
    });
  });
}

Map<String, Object?> _bankAccountJson() => {
  'bank_account_id': 31,
  'bank_name': 'BBVA',
  'account_number': '0123456789',
  'reference': null,
  'routing_number': null,
  'comment': null,
};

BankAccountRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return BankAccountRepositoryImpl(dio);
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
