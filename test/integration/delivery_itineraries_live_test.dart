import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';

/// Spec 075's repository calls against a live mbe-api (quickstart.md, task
/// T035): the Itinerarios list and its filters, a trip's detail with the
/// names mbe-api#343 added, the print documents, and, with `MBE_WRITE=true`,
/// the whole flow: create, the one-open-trip-per-vehicle refusal, header
/// edit, stops, loading (whole, partial, adjust, release), the unavailable
/// quantity refusal, departure, closing one stop with an **uploaded PNG** and
/// the last with a **drawn-signature PNG** (the multipart call is verified
/// here before it is trusted, constitution §III, research R12), the shortfall
/// rules, the trip closing itself, and cancelling.
///
///   flutter test test/integration/delivery_itineraries_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env \
///     [--dart-define=MBE_WRITE=true]
///
/// Account: `MBE_POS_*`, the administrator (Delivery Itineraries, 87, and
/// Delivery Orders, 71). Needs mbe-api at or after #344 with migration 036.
///
/// Fixtures are discovered at run time: an active vehicle with no open trip,
/// an active operator, and **two delivery-type orders En preparación at the
/// account's facility with something open**. Make them in the POS (a sale with
/// delivery destinations), confirm them on "Órdenes de entrega" and approve
/// them if approval is on. A write case whose fixture is missing is skipped
/// with the reason, not failed. The facility must have an in-transit
/// location, or departure answers `facility.no_in_transit_location`, recorded
/// as a skipped step.
///
/// **Each write run consumes its two orders** (one delivered, one partially
/// delivered with a child order for the remainder) and leaves on the tenant:
/// one closed trip, one cancelled trip and one cancelled-before-loading trip,
/// each tagged `QA075 <n>` in its comment. Run writes only against dev.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _canRun = _username != '' && _password != '';

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

/// A real PNG of [width] × [height], drawn the way the signature pad draws:
/// black strokes on white, through `dart:ui`.
Future<Uint8List> _drawnPng(int width, int height) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  canvas.drawPath(
    ui.Path()
      ..moveTo(60, height * 0.6)
      ..lineTo(width * 0.4, height * 0.3)
      ..lineTo(width * 0.7, height * 0.7),
    ui.Paint()
      ..color = const ui.Color(0xFF000000)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 6,
  );
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

/// Half of [d], to the server's four decimals.
Decimal _half(Decimal d) =>
    (d / Decimal.fromInt(2)).toDecimal(scaleOnInfinitePrecision: 4);

bool _isPdf(Uint8List b) =>
    b.length > 4 && b[0] == 0x25 && b[1] == 0x50 && b[2] == 0x44;

void main() {
  late Dio dio;
  late DeliveryItineraryRepositoryImpl itineraries;
  late DeliveryOrderAdminRepositoryImpl orders;
  late VehicleRepositoryImpl vehicles;
  late VehicleOperatorRepositoryImpl operators;
  late DocumentSourceImpl documents;
  final steps = <_Step>[];

  Future<void> step(String name, Future<String?> Function() body) async {
    try {
      final note = await body();
      steps.add(_Step(name, true, note ?? ''));
    } on Object catch (e, st) {
      steps.add(_Step(name, false, '$e\n$st'));
    }
  }

  void skipped(String name, String why) =>
      steps.add(_Step(name, true, 'SKIPPED: $why'));

  setUpAll(() async {
    if (!_canRun) return;
    dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final auth = AuthRepositoryImpl(dio);
    final token = await auth.login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    itineraries = DeliveryItineraryRepositoryImpl(dio);
    orders = DeliveryOrderAdminRepositoryImpl(dio);
    vehicles = VehicleRepositoryImpl(dio);
    operators = VehicleOperatorRepositoryImpl(dio);
    documents = DocumentSourceImpl(dio);
  });

  test(
    'Itinerarios against a live mbe-api',
    () async {
      // ---- Read-only ---------------------------------------------------
      ItinerarySummary? anyTrip;
      await step(
        'list: newest first, one page, names from the server',
        () async {
          final page = await itineraries.list(skip: 0, limit: 20);
          if (page.items.isEmpty) return 'no trips on the tenant';
          anyTrip = page.items.first;
          final ids = page.items.map((t) => t.id).toList();
          expect(
            ids,
            [...ids]..sort((a, b) => b.compareTo(a)),
            reason: 'newest first',
          );
          final named = page.items.where((t) => t.vehicleId != null);
          for (final t in named) {
            expect(
              t.vehicleName,
              isNotNull,
              reason: 'trip ${t.id} vehicle name (#343)',
            );
          }
          return '${page.items.length} of ${page.total}';
        },
      );

      await step('list: the status filter narrows to that status', () async {
        for (final status in ItineraryStatus.values) {
          final page = await itineraries.list(
            status: status,
            skip: 0,
            limit: 20,
          );
          expect(
            page.items.every((t) => t.status == status),
            isTrue,
            reason: 'status ${status.name}',
          );
        }
        return null;
      });

      await step('list: vehicle and warehouse filters narrow it', () async {
        final t = anyTrip;
        if (t == null) return 'SKIPPED: no trips';
        if (t.vehicleId != null) {
          final byVehicle = await itineraries.list(
            vehicleId: t.vehicleId,
            skip: 0,
            limit: 50,
          );
          expect(
            byVehicle.items.every((x) => x.vehicleId == t.vehicleId),
            isTrue,
          );
          expect(byVehicle.items.any((x) => x.id == t.id), isTrue);
        }
        if (t.warehouseId != null) {
          final byWarehouse = await itineraries.list(
            warehouseId: t.warehouseId,
            skip: 0,
            limit: 50,
          );
          expect(
            byWarehouse.items.every((x) => x.warehouseId == t.warehouseId),
            isTrue,
          );
        }
        return null;
      });

      await step(
        'get: a trip with a stored order carries the #343 fields',
        () async {
          final page = await itineraries.list(skip: 0, limit: 50);
          for (final summary in page.items) {
            final trip = await itineraries.getById(summary.id);
            final stop = trip.stops
                .where((s) => s.deliveryOrderId != null)
                .firstOrNull;
            if (stop == null) continue;
            expect(stop.deliveryOrderIds, contains(stop.deliveryOrderId));
            expect(
              stop.customerName,
              isNotNull,
              reason: 'trip ${trip.id} stop ${stop.sequence} customer',
            );
            for (final line in stop.lines) {
              expect(line.productCode, isNotEmpty);
              expect(line.productName, isNotEmpty);
              expect(line.deliveryOrderId, isNonZero);
            }
            return 'trip ${trip.id}, stop ${stop.sequence}, order ${stop.deliveryOrderId}';
          }
          return 'SKIPPED: no trip has a stop with a stored order (legacy data only)';
        },
      );

      await step(
        'get: an unknown trip is not_found with its resource',
        () async {
          try {
            await itineraries.getById(999999999);
          } on AppError catch (e) {
            expect(e, isA<NotFoundError>());
            expect(_code(e), 'resource.not_found');
            return null;
          }
          fail('expected not found');
        },
      );

      await step('print: a departed or closed trip returns two PDFs', () async {
        for (final status in [
          ItineraryStatus.closed,
          ItineraryStatus.departed,
        ]) {
          final page = await itineraries.list(
            status: status,
            skip: 0,
            limit: 5,
          );
          for (final t in page.items) {
            if (t.status == ItineraryStatus.closed && t.departedAt == null) {
              continue;
            }
            final ticket = await documents.fetch(
              DocumentRef(
                kind: DocumentKind.itineraryTicket,
                recordId: t.id,
                title: 'ticket',
              ),
            );
            final notes = await documents.fetch(
              DocumentRef(
                kind: DocumentKind.itineraryDeliveryNotes,
                recordId: t.id,
                title: 'notes',
              ),
            );
            expect(_isPdf(ticket.bytes), isTrue);
            expect(_isPdf(notes.bytes), isTrue);
            return 'trip ${t.id}: ${ticket.filename}, ${notes.filename}';
          }
        }
        return 'SKIPPED: no departed or closed trip';
      });

      await step(
        'print: an Abierto trip is refused with itinerary.not_departed',
        () async {
          final page = await itineraries.list(
            status: ItineraryStatus.open,
            skip: 0,
            limit: 1,
          );
          if (page.items.isEmpty) return 'SKIPPED: no Abierto trip';
          try {
            await documents.fetch(
              DocumentRef(
                kind: DocumentKind.itineraryTicket,
                recordId: page.items.first.id,
                title: 'ticket',
              ),
            );
          } on AppError catch (e) {
            expect(_code(e), 'itinerary.not_departed');
            return null;
          }
          fail('expected a refusal');
        },
      );

      // ---- Write flow ----------------------------------------------------
      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        await _writeFlow(
          itineraries: itineraries,
          orders: orders,
          vehicles: vehicles,
          operators: operators,
          documents: documents,
          step: step,
          skipped: skipped,
        );
      }

      // ---- Report -------------------------------------------------------
      final out = StringBuffer('\n== Itinerarios live run ==\n');
      for (final s in steps) {
        out.writeln(
          '${s.ok ? 'PASS' : 'FAIL'}  ${s.name}'
          '${s.detail.isEmpty ? '' : '  [${s.detail.split('\n').first}]'}',
        );
      }
      // ignore: avoid_print
      print(out);
      final failed = steps.where((s) => !s.ok).toList();
      expect(
        failed,
        isEmpty,
        reason: [
          for (final f in failed) '${f.name}: ${f.detail}',
        ].join('\n---\n'),
      );
    },
    skip: _canRun ? null : 'needs --dart-define=MBE_POS_USERNAME/PASSWORD',
    timeout: const Timeout(Duration(minutes: 15)),
  );
}

/// An order with something open on at least one of its lines.
class _Fixture {
  _Fixture(this.order);
  final DeliveryOrder order;
  DeliveryOrderLine get line =>
      order.lines.firstWhere((l) => l.open > Decimal.zero);
}

Future<void> _writeFlow({
  required DeliveryItineraryRepositoryImpl itineraries,
  required DeliveryOrderAdminRepositoryImpl orders,
  required VehicleRepositoryImpl vehicles,
  required VehicleOperatorRepositoryImpl operators,
  required DocumentSourceImpl documents,
  required Future<void> Function(String, Future<String?> Function()) step,
  required void Function(String, String) skipped,
}) async {
  // ---- Fixtures ----
  int? vehicleId;
  int? operatorId;
  final fixtures = <_Fixture>[];

  await step(
    'fixtures: a vehicle with no open trip, and an operator',
    () async {
      final page = await vehicles.list(
        status: EntityStatus.active,
        skip: 0,
        limit: 50,
      );
      for (final v in page.items) {
        final open = await itineraries.list(
          status: ItineraryStatus.open,
          vehicleId: v.vehicleId,
          skip: 0,
          limit: 1,
        );
        if (open.total == 0) {
          vehicleId = v.vehicleId;
          break;
        }
      }
      final ops = await operators.list(
        status: EntityStatus.active,
        skip: 0,
        limit: 5,
      );
      operatorId = ops.items.firstOrNull?.vehicleOperatorId;
      return 'vehicle $vehicleId, operator $operatorId';
    },
  );

  await step(
    'fixtures: two delivery orders En preparación with something open',
    () async {
      final page = await orders.list(
        statuses: [DeliveryOrderStatus.inPreparation],
        type: FulfillmentType.delivery,
        skip: 0,
        limit: 30,
      );
      for (final summary in page.items) {
        final order = await orders.getById(summary.id);
        if (order.lines.any((l) => l.open > Decimal.zero)) {
          fixtures.add(_Fixture(order));
        }
        if (fixtures.length == 2) break;
      }
      return fixtures.map((f) => f.order.id).join(', ');
    },
  );

  if (vehicleId == null || operatorId == null || fixtures.length < 2) {
    skipped(
      'every write case',
      'needs an active vehicle with no open trip, an active operator and two '
          'delivery orders En preparación with something open',
    );
    return;
  }
  final a = fixtures[0];
  final b = fixtures[1];

  Itinerary? trip;
  late ItineraryStop stopA;
  late ItineraryStop stopB;

  await step('create: an empty trip with the vehicle and operator', () async {
    trip = await itineraries.create(
      date: DateTime.now(),
      vehicleId: vehicleId,
      operatorId: operatorId,
      comment: 'QA075 1',
    );
    expect(trip!.status, ItineraryStatus.open);
    expect(trip!.stops, isEmpty);
    expect(trip!.vehicleName, isNotNull, reason: '#343 vehicle name');
    expect(trip!.operatorName, isNotNull, reason: '#343 operator name');
    return 'trip ${trip!.id}';
  });
  if (trip == null) return;
  final id = trip!.id;

  await step('create: a second trip on the same vehicle is refused', () async {
    try {
      await itineraries.create(vehicleId: vehicleId, comment: 'QA075 2');
    } on AppError catch (e) {
      expect(_code(e), 'vehicle.open_itinerary_exists');
      expect(e.problem!.intParam('itinerary_id'), id);
      return null;
    }
    fail('expected vehicle.open_itinerary_exists');
  });

  await step('updateHeader: the comment changes, the rest stays', () async {
    final updated = await itineraries.updateHeader(
      id,
      comment: 'QA075 1 edited',
    );
    expect(updated.comment, 'QA075 1 edited');
    expect(updated.vehicleId, vehicleId);
    return null;
  });

  await step(
    'addStop: the stop keeps its order, customer and ship-to (#343)',
    () async {
      trip = await itineraries.addStop(id, deliveryOrderId: a.order.id);
      stopA = trip!.stops.single;
      expect(stopA.deliveryOrderId, a.order.id);
      expect(stopA.customerName, isNotNull);
      expect(stopA.lines, isEmpty);
      return 'stop ${stopA.id}';
    },
  );

  await step(
    'commitWholeOrder: every open line is loaded, with names (#343)',
    () async {
      trip = await itineraries.commitWholeOrder(
        id,
        stopA.id,
        deliveryOrderId: a.order.id,
      );
      stopA = trip!.stops.single;
      final openLines = a.order.lines
          .where((l) => l.open > Decimal.zero)
          .toList();
      expect(stopA.lines, hasLength(openLines.length));
      for (final line in stopA.lines) {
        final source = openLines.firstWhere(
          (l) => l.id == line.deliveryOrderLineId,
        );
        expect(line.committed, source.open);
        expect(line.productName, source.productName);
        expect(line.deliveryOrderId, a.order.id);
      }
      return '${stopA.lines.length} lines';
    },
  );

  await step(
    'addStop + commitLine: half of one line, the rest stays open',
    () async {
      trip = await itineraries.addStop(id, deliveryOrderId: b.order.id);
      stopB = trip!.stops.firstWhere((s) => s.deliveryOrderId == b.order.id);
      final line = b.line;
      final half = _half(line.open);
      trip = await itineraries.commitLine(
        id,
        stopB.id,
        deliveryOrderLineId: line.id,
        quantity: half,
      );
      stopB = trip!.stops.firstWhere((s) => s.id == stopB.id);
      expect(stopB.lines.single.committed, half);
      final order = await orders.getById(b.order.id);
      final after = order.lines.firstWhere((l) => l.id == line.id);
      expect(
        after.open,
        line.open - half,
        reason: 'open went down by what was loaded',
      );
      return 'loaded $half of ${line.open}';
    },
  );

  await step('commitLine: above what is open is refused', () async {
    final line = b.line;
    try {
      await itineraries.commitLine(
        id,
        stopB.id,
        deliveryOrderLineId: line.id,
        quantity: line.open + Decimal.fromInt(1000),
      );
    } on AppError catch (e) {
      // The line already carries a load, so the server may answer either of
      // the line-level refusals.
      expect(
        _code(e),
        anyOf(
          'delivery_order_line.quantity_unavailable',
          'delivery_order_line.nothing_to_load',
        ),
      );
      return _code(e);
    }
    fail('expected a refusal');
  });

  await step(
    'adjustCommitment then releaseCommitment, then load it again',
    () async {
      final line = b.line;
      trip = await itineraries.adjustCommitment(
        id,
        stopB.id,
        stopB.lines.single.id,
        quantity: line.open,
      );
      stopB = trip!.stops.firstWhere((s) => s.id == stopB.id);
      expect(stopB.lines.single.committed, line.open);
      trip = await itineraries.releaseCommitment(
        id,
        stopB.id,
        stopB.lines.single.id,
      );
      stopB = trip!.stops.firstWhere((s) => s.id == stopB.id);
      expect(stopB.lines, isEmpty);
      trip = await itineraries.commitLine(
        id,
        stopB.id,
        deliveryOrderLineId: line.id,
        quantity: line.open,
      );
      stopB = trip!.stops.firstWhere((s) => s.id == stopB.id);
      expect(stopB.lines.single.committed, line.open);
      return null;
    },
  );

  await step(
    'depart: sent quantities are fixed and the orders go En tránsito',
    () async {
      try {
        trip = await itineraries.depart(id);
      } on AppError catch (e) {
        if (_code(e) == 'facility.no_in_transit_location') {
          return 'SKIPPED: the facility has no in-transit location';
        }
        rethrow;
      }
      expect(trip!.status, ItineraryStatus.departed);
      expect(trip!.departedAt, isNotNull);
      stopA = trip!.stops.firstWhere((s) => s.deliveryOrderId == a.order.id);
      stopB = trip!.stops.firstWhere((s) => s.deliveryOrderId == b.order.id);
      for (final line in [...stopA.lines, ...stopB.lines]) {
        expect(line.sent, line.committed);
      }
      for (final order in [a.order, b.order]) {
        expect(
          (await orders.getById(order.id)).status,
          DeliveryOrderStatus.inTransit,
        );
      }
      return null;
    },
  );

  if (trip?.status != ItineraryStatus.departed) {
    skipped(
      'closing, printing and cancelling a departed trip',
      'the trip did not depart',
    );
    return;
  }

  await step('print: the departed trip returns both documents', () async {
    for (final kind in [
      DocumentKind.itineraryTicket,
      DocumentKind.itineraryDeliveryNotes,
    ]) {
      final doc = await documents.fetch(
        DocumentRef(kind: kind, recordId: id, title: 't'),
      );
      expect(_isPdf(doc.bytes), isTrue);
    }
    return null;
  });

  await step('closeStop: a shortfall without a reason is refused', () async {
    try {
      await itineraries.closeStop(
        id,
        stopB.id,
        StopClosure(
          receiverName: 'QA075',
          receiverIdShown: 'INE QA075',
          lines: [
            for (final l in stopB.lines)
              StopClosureLine(lineId: l.id, delivered: _half(l.sent)),
          ],
          proof: ProofImage(
            bytes: await _drawnPng(1024, 384),
            filename: 'firma.png',
          ),
        ),
      );
    } on AppError catch (e) {
      expect(_code(e), 'itinerary.stop_shortfall_needs_reason');
      return null;
    }
    fail('expected itinerary.stop_shortfall_needs_reason');
  });

  await step(
    'closeStop (uploaded PNG): everything delivered, the stop is Entregada',
    () async {
      trip = await itineraries.closeStop(
        id,
        stopA.id,
        StopClosure(
          receiverName: 'QA075 recibe',
          receiverIdShown: 'INE QA075',
          lines: [
            for (final l in stopA.lines)
              StopClosureLine(lineId: l.id, delivered: l.sent),
          ],
          proof: ProofImage(
            bytes: await _drawnPng(640, 480),
            filename: 'nota-qa075.png',
          ),
        ),
      );
      stopA = trip!.stops.firstWhere((s) => s.id == stopA.id);
      expect(stopA.outcome, StopOutcome.delivered);
      expect(stopA.arrivedAt, isNotNull);
      expect(stopA.proofId, isNotNull);
      expect(
        trip!.status,
        ItineraryStatus.departed,
        reason: 'one stop is still pending',
      );
      expect(
        (await orders.getById(a.order.id)).status,
        DeliveryOrderStatus.delivered,
      );
      return null;
    },
  );

  await step(
    'closeStop (drawn signature PNG): a shortfall closes partially, and the trip closes itself',
    () async {
      trip = await itineraries.closeStop(
        id,
        stopB.id,
        StopClosure(
          receiverName: 'QA075 firma',
          receiverIdShown: 'INE QA075',
          lines: [
            for (final l in stopB.lines)
              StopClosureLine(
                lineId: l.id,
                delivered: _half(l.sent),
                reason: ShortfallReason.damagedGoods,
              ),
          ],
          proof: ProofImage(
            bytes: await _drawnPng(1024, 384),
            filename: 'firma.png',
          ),
        ),
      );
      stopB = trip!.stops.firstWhere((s) => s.id == stopB.id);
      expect(stopB.outcome, StopOutcome.partiallyDelivered);
      expect(stopB.lines.first.reason, ShortfallReason.damagedGoods);
      expect(stopB.lines.first.returned, isNot(Decimal.zero));
      expect(trip!.status, ItineraryStatus.closed);
      expect(trip!.returnedAt, isNotNull);
      expect(
        (await orders.getById(b.order.id)).status,
        DeliveryOrderStatus.partiallyDelivered,
      );
      return null;
    },
  );

  await step('closeStop: closing a resolved stop again is refused', () async {
    try {
      await itineraries.closeStop(
        id,
        stopA.id,
        StopClosure(
          receiverName: 'QA075',
          receiverIdShown: 'INE QA075',
          lines: [
            for (final l in stopA.lines)
              StopClosureLine(lineId: l.id, delivered: l.sent),
          ],
          proof: ProofImage(
            bytes: await _drawnPng(640, 480),
            filename: 'otra.png',
          ),
        ),
      );
    } on AppError catch (e) {
      expect(
        _code(e),
        anyOf('itinerary.stop_already_resolved', 'itinerary.not_departed'),
      );
      return _code(e);
    }
    fail('expected a refusal');
  });

  await step('print: the closed trip still returns both documents', () async {
    for (final kind in [
      DocumentKind.itineraryTicket,
      DocumentKind.itineraryDeliveryNotes,
    ]) {
      final doc = await documents.fetch(
        DocumentRef(kind: kind, recordId: id, title: 't'),
      );
      expect(_isPdf(doc.bytes), isTrue);
    }
    return null;
  });

  await step(
    'cancel: an Abierto trip is cancelled, and a cancelled one will not print',
    () async {
      final cancelled = await itineraries.create(comment: 'QA075 3');
      final result = await itineraries.cancel(cancelled.id);
      expect(result.status, ItineraryStatus.cancelled);
      try {
        await documents.fetch(
          DocumentRef(
            kind: DocumentKind.itineraryTicket,
            recordId: cancelled.id,
            title: 't',
          ),
        );
      } on AppError catch (e) {
        expect(
          _code(e),
          anyOf('itinerary.cancelled', 'itinerary.not_departed'),
        );
        return _code(e);
      }
      fail('expected a refusal');
    },
  );
}
