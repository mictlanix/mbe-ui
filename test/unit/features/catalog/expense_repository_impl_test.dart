import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/expense_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('ExpenseRepositoryImpl.list', () {
    test('200 maps expense (display field) to Expense.name', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_expenseJson(id: 1, expense: 'Rent', comment: 'Monthly')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.items.single.name, 'Rent');
      expect(result.items.single.comment, 'Monthly');
      expect(result.total, 1);
    });

    test('forwards the search query param', () async {
      String? capturedSearch;
      final repository = _repositoryWith((options) async {
        capturedSearch = options.queryParameters['search'] as String?;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(search: 'Rent');

      expect(capturedSearch, 'Rent');
    });
  });

  group('ExpenseRepositoryImpl.get', () {
    test('200 maps to an Expense', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_expenseJson(id: 1, expense: 'Rent')),
          200,
          headers: _jsonHeaders,
        ),
      );

      final expense = await repository.get(expenseId: 1);

      expect(expense.expenseId, 1);
      expect(expense.name, 'Rent');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Expense not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(expenseId: 999),
        throwsA(const AppError.notFound('Expense not found')),
      );
    });
  });

  group('ExpenseRepositoryImpl.create', () {
    test('201 returns the created Expense', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_expenseJson(id: 1, expense: 'Fuel')),
          201,
          headers: _jsonHeaders,
        ),
      );

      final expense = await repository.create(name: 'Fuel');

      expect(expense.name, 'Fuel');
    });

    test('422 duplicate name maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'name'],
                'msg': 'Name already in use',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(name: 'Fuel'),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('ExpenseRepositoryImpl.update', () {
    test('200 returns the updated Expense', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_expenseJson(id: 1, expense: 'Fuel Updated')),
          200,
          headers: _jsonHeaders,
        ),
      );

      final expense = await repository.update(
        expenseId: 1,
        name: 'Fuel Updated',
      );

      expect(expense.name, 'Fuel Updated');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Expense not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(expenseId: 999, name: 'Anything'),
        throwsA(const AppError.notFound('Expense not found')),
      );
    });
  });

  group('ExpenseRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(expenseId: 1), completes);
    });

    test('a still-referenced rejection surfaces the server message', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Expense is used by an expense ticket'}),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(expenseId: 1),
        throwsA(
          const AppError.server(
            statusCode: 400,
            message: 'Expense is used by an expense ticket',
          ),
        ),
      );
    });
  });
}

Map<String, Object?> _expenseJson({
  required int id,
  required String expense,
  String? comment,
}) => {'expense_id': id, 'expense': expense, 'comment': comment};

ExpenseRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return ExpenseRepositoryImpl(dio);
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
