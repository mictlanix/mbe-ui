import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/kardex_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _rowJson({
  int id = 9001,
  int source = 4,
  int reference = 57,
  Object? document,
  String quantityOut = '0',
  String balance = '15.5',
}) => {
  'lot_serial_tracking_id': id,
  'date': '2026-11-10T09:30:00.000',
  'source': source,
  'source_name': 'warehouse_receipt',
  'document': document,
  'reference': reference,
  'quantity_in': '5.5',
  'quantity_out': quantityOut,
  'balance': balance,
};

Map<String, Object?> _kardexJson({Object? rows}) => {
  'product': 7,
  'warehouse': 3,
  'from': '2026-10-19',
  'to': '2026-11-17',
  'opening': '10',
  'rows': rows,
  'total_in': '5.5',
  'total_out': '12',
  'closing': '-6.5',
};

void main() {
  test('read sends the product, the warehouse and the two dates', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok(_kardexJson());
    });

    await repository.read(
      productId: 7,
      warehouseId: 3,
      from: DateTime(2026, 10, 19),
      to: DateTime(2026, 11, 17, 23, 59),
    );

    expect(requests.single.path, '/api/v1/kardex');
    expect(requests.single.queryParameters.map((k, v) => MapEntry(k, '$v')), {
      'product': '7',
      'warehouse': '3',
      'from': '2026-10-19',
      'to': '2026-11-17',
    });
  });

  test('read maps the header, the totals, and null rows to empty', () async {
    final repository = _repositoryWith((options) async => _ok(_kardexJson()));

    final kardex = await _read(repository);

    expect(kardex.productId, 7);
    expect(kardex.warehouseId, 3);
    expect(kardex.from, DateTime(2026, 10, 19));
    expect(kardex.to, DateTime(2026, 11, 17));
    expect(kardex.opening, Decimal.parse('10'));
    expect(kardex.totalIn, Decimal.parse('5.5'));
    expect(kardex.totalOut, Decimal.parse('12'));
    expect(kardex.closing, Decimal.parse('-6.5'));
    expect(kardex.movements, isEmpty);
  });

  test(
    'a row maps with its document, without one, and with reference 0',
    () async {
      final repository = _repositoryWith(
        (options) async => _ok(
          _kardexJson(
            rows: [
              _rowJson(
                document: {'type': 4, 'id': 57, 'facility': 2, 'serial': 31},
              ),
              _rowJson(id: 9002, source: 6, reference: 88),
              _rowJson(
                id: 9003,
                source: 1,
                reference: 0,
                quantityOut: '3',
                balance: '-2',
              ),
            ],
          ),
        ),
      );

      final rows = (await _read(repository)).movements;

      final first = rows[0];
      expect(first.id, 9001);
      expect(first.date, DateTime(2026, 11, 10, 9, 30));
      expect(first.sourceType, 4);
      expect(first.reference, 57);
      expect(first.quantityIn, Decimal.parse('5.5'));
      expect(first.quantityOut, Decimal.zero);
      expect(first.balance, Decimal.parse('15.5'));
      expect(
        first.document,
        const KardexDocumentRef(type: 4, id: 57, facilityId: 2, serial: 31),
      );
      expect(rows[1].sourceType, 6);
      expect(rows[1].reference, 88);
      expect(rows[1].document, isNull);
      expect(rows[2].reference, 0);
      expect(rows[2].document, isNull);
      expect(rows[2].quantityOut, Decimal.parse('3'));
      expect(rows[2].balance, Decimal.parse('-2'));
    },
  );

  test(
    'a range refusal becomes a coded AppError that keeps its params',
    () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': 'Range too long',
            'code': 'kardex.range_too_long',
            'params': {'max_days': 366},
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        _read(repository),
        throwsA(
          isA<AppError>()
              .having(
                (e) => e.problem?.code,
                'code',
                api.ErrorCode.kardexPeriodRangeTooLong,
              )
              .having((e) => e.problem?.params['max_days'], 'params', 366),
        ),
      );
    },
  );
}

Future<Kardex> _read(KardexRepositoryImpl repository) => repository.read(
  productId: 7,
  warehouseId: 3,
  from: DateTime(2026, 10, 19),
  to: DateTime(2026, 11, 17),
);

ResponseBody _ok(Object body) =>
    ResponseBody.fromString(jsonEncode(body), 200, headers: _jsonHeaders);

KardexRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return KardexRepositoryImpl(dio);
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
