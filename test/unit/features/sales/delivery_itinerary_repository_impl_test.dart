import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _line({
  int order = 31,
  int detail = 900,
  int? serial = 1541,
  int? shipTo = 11,
  String? date = '2026-11-15T09:30:00.000',
  int priority = 2,
  String quantity = '40.0000',
}) => {
  'delivery_order': order,
  'delivery_order_detail': detail,
  'serial': serial,
  'customer': 7,
  'ship_to': shipTo,
  'date': date,
  'priority': priority,
  'product': 5,
  'product_code': 'CEM-50',
  'product_name': 'Cemento gris 50 kg',
  'warehouse': 3,
  'open_quantity': quantity,
};

Map<String, Object?> _bucket(
  String key,
  String? date,
  int total,
  List<Map<String, Object?>> items,
) => {'key': key, 'date': date, 'total': total, 'items': items};

/// Spec 063 R1, C6: the repository sends only `skip` and `limit`, and maps the
/// six buckets with their dates and totals.
void main() {
  test('sends skip and limit and nothing else', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return ResponseBody.fromString(
        jsonEncode({'buckets': <Object>[]}),
        200,
        headers: _jsonHeaders,
      );
    });

    await repository.pendingDeliveries(skip: 20, limit: 20);

    expect(requests.single.method, 'GET');
    expect(requests.single.path, endsWith('/delivery-itineraries/deliveries'));
    expect(requests.single.queryParameters, {'skip': 20, 'limit': 20});
  });

  test('maps all six buckets with their date, total and lines', () async {
    final repository = _repositoryWith(
      (_) async => ResponseBody.fromString(
        jsonEncode({
          'buckets': [
            _bucket('earlier', null, 4, [_line(detail: 1)]),
            _bucket('yesterday', '2026-11-14', 2, []),
            _bucket('today', '2026-11-15', 12, [_line(detail: 2)]),
            _bucket('tomorrow', '2026-11-16', 7, []),
            _bucket('day_after', '2026-11-17', 3, []),
            _bucket('later', null, 9, [_line(detail: 3)]),
          ],
        }),
        200,
        headers: _jsonHeaders,
      ),
    );

    final result = await repository.pendingDeliveries(skip: 0, limit: 20);

    expect(result.keys, PendingDeliveryPeriod.values);
    expect(result[PendingDeliveryPeriod.earlier]!.date, isNull);
    expect(result[PendingDeliveryPeriod.earlier]!.total, 4);
    expect(
      result[PendingDeliveryPeriod.yesterday]!.date,
      DateTime(2026, 11, 14),
    );
    expect(result[PendingDeliveryPeriod.today]!.total, 12);
    expect(
      result[PendingDeliveryPeriod.dayAfter]!.date,
      DateTime(2026, 11, 17),
    );
    expect(result[PendingDeliveryPeriod.later]!.items.single.lineId, 3);
  });

  test('maps a line, quantity kept as the server string', () async {
    final repository = _repositoryWith(
      (_) async => ResponseBody.fromString(
        jsonEncode({
          'buckets': [
            _bucket('today', '2026-11-15', 1, [_line(quantity: '3.2500')]),
          ],
        }),
        200,
        headers: _jsonHeaders,
      ),
    );

    final line = (await repository.pendingDeliveries(
      skip: 0,
      limit: 20,
    ))[PendingDeliveryPeriod.today]!.items.single;

    expect(line.deliveryOrderId, 31);
    expect(line.lineId, 900);
    expect(line.serial, 1541);
    expect(line.customerId, 7);
    expect(line.shipToId, 11);
    expect(line.scheduledDate, DateTime(2026, 11, 15, 9, 30));
    expect(line.priority, 2);
    expect(line.productId, 5);
    expect(line.productCode, 'CEM-50');
    expect(line.productName, 'Cemento gris 50 kg');
    expect(line.warehouseId, 3);
    expect(line.openQuantity, '3.2500');
  });

  test('a line with no serial, ship-to or date maps those to null', () async {
    final repository = _repositoryWith(
      (_) async => ResponseBody.fromString(
        jsonEncode({
          'buckets': [
            _bucket('later', null, 1, [
              _line(serial: null, shipTo: null, date: null),
            ]),
          ],
        }),
        200,
        headers: _jsonHeaders,
      ),
    );

    final line = (await repository.pendingDeliveries(
      skip: 0,
      limit: 20,
    ))[PendingDeliveryPeriod.later]!.items.single;

    expect(line.serial, isNull);
    expect(line.shipToId, isNull);
    expect(line.scheduledDate, isNull);
  });

  test('a bucket key the client does not know is ignored', () async {
    final repository = _repositoryWith(
      (_) async => ResponseBody.fromString(
        jsonEncode({
          'buckets': [
            _bucket('next_year', null, 5, []),
            _bucket('today', '2026-11-15', 1, []),
          ],
        }),
        200,
        headers: _jsonHeaders,
      ),
    );

    final result = await repository.pendingDeliveries(skip: 0, limit: 20);

    expect(result.keys, [PendingDeliveryPeriod.today]);
  });
}

DeliveryItineraryRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return DeliveryItineraryRepositoryImpl(dio);
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
