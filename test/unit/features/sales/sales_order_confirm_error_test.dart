import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';

import '../../core/errors/problem_test_env.dart';

/// Spec 058 FR-019: a confirm that mbe-api refuses with a list of lines
/// (zero-priced, out of stock, missing delivery details) is read in both of
/// its shapes: today's dict `detail`, and the string `detail` plus `errors[]`
/// parts its announced phase 3 sends. Both must end up listing the same lines.
const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  Future<AppError> confirmRefusedWith(
    Map<String, Object?> body,
    int status,
  ) async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: _jsonHeaders,
      ),
    );
    try {
      await repository.confirm(saleId: 42);
    } on AppError catch (e) {
      return e;
    }
    fail('expected the confirm to be refused');
  }

  test("today's dict: the English fallback joins the headline and the lines, "
      'and the problem rides along', () async {
    final error = await confirmRefusedWith({
      'status': 409,
      'code': 'sales_order.zero_priced_lines',
      'detail': {
        'message': 'Zero-priced lines',
        'lines': ['`A-1` has no price', '`B-2` has no price'],
      },
    }, 409);

    expect(
      error,
      isA<ServerError>()
          .having((e) => e.statusCode, 'statusCode', 409)
          .having(
            (e) => e.message,
            'message',
            'Zero-priced lines\n`A-1` has no price\n`B-2` has no price',
          ),
    );
    expect(error.problem!.code, api.ErrorCode.salesOrderPeriodZeroPricedLines);
    expect(
      error.userMessage(env.es, env.fmtEs),
      'Algunas partidas no tienen precio:\n'
      '`A-1` has no price\n'
      '`B-2` has no price',
    );
  });

  test(
    'missing delivery details are listed too (they were dropped before)',
    () async {
      final error = await confirmRefusedWith({
        'status': 409,
        'code': 'sales_order.missing_delivery_details',
        'detail': {
          'message': 'Missing delivery details',
          'missing': ['destination', 'promise date'],
        },
      }, 409);

      expect(
        (error as ServerError).message,
        'Missing delivery details\ndestination\npromise date',
      );
      expect(
        error.userMessage(env.en, env.fmtEn),
        'Delivery details are missing:\ndestination\npromise date',
      );
    },
  );

  test(
    'phase 3: a string detail with errors[] parts lists the same lines',
    () async {
      final error = await confirmRefusedWith({
        'status': 409,
        'code': 'sales_order.zero_priced_lines',
        'detail': 'Zero-priced lines',
        'errors': [
          {
            'code': 'future.line_unpriced',
            'params': {'product_code': 'A-1'},
          },
          {
            'code': 'future.line_unpriced',
            'params': {'product_code': 'B-2'},
          },
        ],
      }, 409);

      expect(error, isA<ServerError>());
      expect(error.problem!.parts, hasLength(2));
      expect(
        error.userMessage(env.en, env.fmtEn),
        'Some lines have no price:\nA-1\nB-2',
      );
    },
  );

  test('a dict without a code gives today\'s joined message and no '
      'localized text', () async {
    final error = await confirmRefusedWith({
      'detail': {
        'message': 'Insufficient stock',
        'lines': ['`A-1` requires stock but no warehouse is set'],
      },
    }, 409);

    expect(
      (error as ServerError).message,
      'Insufficient stock\n`A-1` requires stock but no warehouse is set',
    );
    expect(error.problem, isNull);
    expect(error.localizedMessage(env.es, env.fmtEs), isNull);
  });

  test('a credit refusal on confirm is still a CreditHoldError', () async {
    final error = await confirmRefusedWith({
      'status': 422,
      'code': 'customer.credit_limit_exceeded',
      'detail': 'Over the credit limit',
      'params': {
        'customer_id': 7,
        'outstanding': '18450.00',
        'limit': '15000.00',
      },
    }, 422);

    expect(error, isA<CreditHoldError>());
    expect(error.userMessage(env.es, env.fmtEs), contains(r'$18,450.00'));
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
