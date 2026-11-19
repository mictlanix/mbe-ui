import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:decimal/decimal.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';

import 'delivery_itinerary_fixtures.dart';

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
  'customer_display_name': 'Ferretería Acme',
  'ship_to_label': shipTo == null ? null : 'Av. Juárez 120, Centro, Puebla',
  'warehouse_name': 'Bodega Norte',
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
    expect(line.customerName, 'Ferretería Acme');
    expect(line.shipToLabel, 'Av. Juárez 120, Centro, Puebla');
    expect(line.warehouseName, 'Bodega Norte');
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
    expect(line.shipToLabel, isNull);
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

  group('spec 075 itineraries', () {
    final png = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
    ]);

    ({DeliveryItineraryRepositoryImpl repo, List<RequestOptions> requests})
    stub({Object? body, int status = 200}) {
      final requests = <RequestOptions>[];
      final repo = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(body ?? itineraryJson()),
          status,
          headers: _jsonHeaders,
        );
      });
      return (repo: repo, requests: requests);
    }

    test('list sends only the facets set, as calendar dates', () async {
      final s = stub(
        body: {
          'items': [itinerarySummaryJson()],
          'total': 1,
        },
      );

      final page = await s.repo.list(
        status: ItineraryStatus.departed,
        dateFrom: DateTime(2026, 11, 1, 13, 45),
        dateTo: DateTime(2026, 11, 18),
        vehicleId: 4,
        operatorId: 9,
        warehouseId: 3,
        skip: 20,
        limit: 20,
      );

      final r = s.requests.single;
      expect(r.method, 'GET');
      expect(r.path, endsWith('/delivery-itineraries'));
      expect(r.queryParameters, {
        'date_from': '2026-11-01',
        'date_to': '2026-11-18',
        'vehicle': 4,
        'vehicle_operator': 9,
        'warehouse': 3,
        'status': 1,
        'skip': 20,
        'limit': 20,
      });
      expect(page.total, 1);
      expect(page.items.single.vehicleName, 'Torton · MBE-114');
      expect(page.items.single.status, ItineraryStatus.open);
    });

    test(
      'getById maps the trip, its stops, lines and the #343 names',
      () async {
        final s = stub(
          body: itineraryJson(
            status: 1,
            departure: '2026-11-18T07:04:00',
            stops: [
              itineraryStopJson(
                id: 502,
                sequence: 2,
                outcome: 2,
                arrival: '2026-11-18T14:20:00',
                lines: [
                  itineraryLineJson(
                    sent: '6.0000',
                    delivered: '4.0000',
                    returned: '2.0000',
                    reason: 3,
                  ),
                ],
              ),
              itineraryStopJson(
                id: 501,
                sequence: 1,
                order: null,
                orders: [1498, 1502],
              ),
            ],
          ),
        );

        final trip = await s.repo.getById(58);

        expect(s.requests.single.path, endsWith('/delivery-itineraries/58'));
        expect(trip.status, ItineraryStatus.departed);
        expect(trip.departedAt, DateTime(2026, 11, 18, 7, 4));
        expect(trip.vehicleName, 'Torton · MBE-114');
        expect(trip.operatorName, 'Juan Rivas');
        expect(trip.warehouseName, 'Bodega Norte');
        // Sorted by sequence, whatever the server's order.
        expect(trip.stops.map((st) => st.sequence), [1, 2]);
        final legacy = trip.stops.first;
        expect(legacy.deliveryOrderId, isNull);
        expect(legacy.deliveryOrderIds, [1498, 1502]);
        final closed = trip.stops.last;
        expect(closed.outcome, StopOutcome.partiallyDelivered);
        expect(closed.arrivedAt, DateTime(2026, 11, 18, 14, 20));
        expect(closed.customerName, 'Abarrotes La Central');
        final line = closed.lines.single;
        expect(line.productName, 'Clavo 2½"');
        expect(line.unitSymbol, 'kg');
        expect(line.sent, Decimal.parse('6'));
        expect(line.delivered, Decimal.parse('4'));
        expect(line.returned, Decimal.parse('2'));
        expect(line.reason, ShortfallReason.damagedGoods);
      },
    );

    test('every status, outcome and reason maps, none by name', () async {
      for (var i = 0; i < ItineraryStatus.values.length; i++) {
        final s = stub(
          body: itineraryJson(status: i, stops: []),
        );
        expect((await s.repo.getById(1)).status, ItineraryStatus.values[i]);
      }
      for (var i = 0; i < StopOutcome.values.length; i++) {
        final s = stub(
          body: itineraryJson(stops: [itineraryStopJson(outcome: i)]),
        );
        expect(
          (await s.repo.getById(1)).stops.single.outcome,
          StopOutcome.values[i],
        );
      }
      for (var i = 0; i < ShortfallReason.values.length; i++) {
        final s = stub(
          body: itineraryJson(
            stops: [
              itineraryStopJson(lines: [itineraryLineJson(reason: i)]),
            ],
          ),
        );
        expect(
          (await s.repo.getById(1)).stops.single.lines.single.reason,
          ShortfallReason.values[i],
        );
      }
    });

    test('an unknown status is a server error, not a default', () async {
      final s = stub(body: itineraryJson(status: 9));
      await expectLater(s.repo.getById(1), throwsA(isA<AppError>()));
    });

    test('the response warnings are dropped', () async {
      final s = stub(
        body: itineraryJson(warnings: ['Operator licence expired']),
      );
      final trip = await s.repo.getById(1);
      expect(trip.toString(), isNot(contains('licence')));
    });

    test('create sends only what was given', () async {
      final s = stub();

      await s.repo.create(
        date: DateTime(2026, 11, 18, 9),
        vehicleId: 4,
        comment: 'x',
      );

      final r = s.requests.single;
      expect(r.method, 'POST');
      expect(r.path, endsWith('/delivery-itineraries'));
      expect(r.data, {'date': '2026-11-18', 'vehicle': 4, 'comment': 'x'});
    });

    test('updateHeader sends only the changed fields', () async {
      final s = stub();

      await s.repo.updateHeader(58, operatorId: 12);

      final r = s.requests.single;
      expect(r.method, 'PUT');
      expect(r.path, endsWith('/delivery-itineraries/58'));
      expect(r.data, {'vehicle_operator': 12});
    });

    test('cancel and depart post to their own routes', () async {
      final s = stub();

      await s.repo.cancel(58);
      await s.repo.depart(58);

      expect(s.requests[0].path, endsWith('/delivery-itineraries/58/cancel'));
      expect(s.requests[1].path, endsWith('/delivery-itineraries/58/depart'));
      expect(s.requests.every((r) => r.method == 'POST'), isTrue);
    });

    test(
      'stops and lines hit their routes with the quantity always sent',
      () async {
        final s = stub();

        await s.repo.addStop(58, deliveryOrderId: 1532);
        await s.repo.commitWholeOrder(58, 501, deliveryOrderId: 1532);
        await s.repo.commitLine(
          58,
          501,
          deliveryOrderLineId: 900,
          quantity: Decimal.parse('12.5'),
        );
        await s.repo.adjustCommitment(
          58,
          501,
          7001,
          quantity: Decimal.parse('3'),
        );
        await s.repo.releaseCommitment(58, 501, 7001);
        await s.repo.removeStop(58, 501);

        final r = s.requests;
        expect(r[0].method, 'POST');
        expect(r[0].path, endsWith('/delivery-itineraries/58/stops'));
        expect(r[0].data, {'delivery_order': 1532});
        expect(r[1].path, endsWith('/stops/501/lines/all'));
        expect(r[1].data, {'delivery_order': 1532});
        expect(r[2].path, endsWith('/stops/501/lines'));
        expect(r[2].data, {'delivery_order_detail': 900, 'quantity': '12.5'});
        expect(r[3].method, 'PUT');
        expect(r[3].path, endsWith('/stops/501/lines/7001'));
        expect(r[3].data, {'quantity': '3'});
        expect(r[4].method, 'DELETE');
        expect(r[4].path, endsWith('/stops/501/lines/7001'));
        expect(r[5].method, 'DELETE');
        expect(r[5].path, endsWith('/delivery-itineraries/58/stops/501'));
      },
    );

    test(
      'closeStop is multipart: fields, a lines JSON and a real file part',
      () async {
        final s = stub();

        await s.repo.closeStop(
          58,
          501,
          StopClosure(
            receiverName: 'Ana',
            receiverIdShown: 'INE 123',
            lines: [
              StopClosureLine(
                lineId: 7001,
                delivered: Decimal.parse('4.5'),
                reason: ShortfallReason.damagedGoods,
              ),
              StopClosureLine(lineId: 7002, delivered: Decimal.parse('2')),
            ],
            proof: ProofImage(bytes: png, filename: 'firma.png'),
          ),
        );

        final r = s.requests.single;
        expect(r.method, 'POST');
        expect(r.path, endsWith('/delivery-itineraries/58/stops/501/close'));
        expect(r.data, isA<FormData>());
        final form = r.data as FormData;
        final fields = {for (final f in form.fields) f.key: f.value};
        expect(fields['receiver_name'], 'Ana');
        expect(fields['receiver_id_shown'], 'INE 123');
        expect(jsonDecode(fields['lines']!), [
          {'line': 7001, 'delivered_quantity': '4.5', 'reason_code': 3},
          {'line': 7002, 'delivered_quantity': '2', 'reason_code': null},
        ]);
        // A file part, not a plain field.
        expect(form.fields.map((f) => f.key), isNot(contains('image')));
        expect(form.files.single.key, 'image');
        expect(form.files.single.value.filename, 'firma.png');
      },
    );

    test('a coded refusal becomes an AppError carrying its code', () async {
      final s = stub(
        status: 409,
        body: {
          'detail': 'This vehicle already has an open itinerary',
          'code': 'vehicle.open_itinerary_exists',
          'params': {'vehicle_id': 4, 'itinerary_id': 54},
        },
      );

      await expectLater(
        s.repo.create(vehicleId: 4),
        throwsA(
          isA<AppError>().having(
            (e) => e.toString(),
            'text',
            contains('vehicle.open_itinerary_exists'),
          ),
        ),
      );
    });

    test('a 422 refusal is mapped too', () async {
      final s = stub(
        status: 422,
        body: {
          'detail': 'Line 7 needs a reason',
          'code': 'itinerary.stop_shortfall_needs_reason',
          'params': {'line_id': 7},
        },
      );

      await expectLater(
        s.repo.closeStop(
          58,
          501,
          StopClosure(
            receiverName: 'A',
            receiverIdShown: 'B',
            lines: const [],
            proof: ProofImage(bytes: png, filename: 'x.png'),
          ),
        ),
        throwsA(isA<AppError>()),
      );
    });
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
