import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';

part 'delivery_itinerary.freezed.dart';

/// `delivery_itinerary.status` (spec 075 data-model "Enums"). Hand-mapped
/// because the generator emits `number0..number3` with no member names. The
/// mapping is exhaustive: a value this client doesn't know is a server error,
/// never a silent default.
enum ItineraryStatus {
  open(0),
  departed(1),
  closed(2),
  cancelled(3);

  const ItineraryStatus(this.value);

  final int value;

  static ItineraryStatus fromApi(api.ItineraryStatus v) => switch (v.name) {
    'number0' => ItineraryStatus.open,
    'number1' => ItineraryStatus.departed,
    'number2' => ItineraryStatus.closed,
    'number3' => ItineraryStatus.cancelled,
    _ => throw const AppError.server(),
  };

  api.ItineraryStatus toApi() => switch (this) {
    ItineraryStatus.open => api.ItineraryStatus.number0,
    ItineraryStatus.departed => api.ItineraryStatus.number1,
    ItineraryStatus.closed => api.ItineraryStatus.number2,
    ItineraryStatus.cancelled => api.ItineraryStatus.number3,
  };
}

/// `delivery_itinerary_stop.outcome`.
enum StopOutcome {
  pending(0),
  delivered(1),
  partiallyDelivered(2),
  failed(3);

  const StopOutcome(this.value);

  final int value;

  static StopOutcome fromApi(api.StopOutcome v) => switch (v.name) {
    'number0' => StopOutcome.pending,
    'number1' => StopOutcome.delivered,
    'number2' => StopOutcome.partiallyDelivered,
    'number3' => StopOutcome.failed,
    _ => throw const AppError.server(),
  };
}

/// Why a line was delivered short (`reason_code`).
enum ShortfallReason {
  customerRefused(0),
  nobodyPresent(1),
  wrongAddress(2),
  damagedGoods(3),
  other(4);

  const ShortfallReason(this.value);

  final int value;

  static ShortfallReason fromApi(api.ShortfallReason v) => switch (v.name) {
    'number0' => ShortfallReason.customerRefused,
    'number1' => ShortfallReason.nobodyPresent,
    'number2' => ShortfallReason.wrongAddress,
    'number3' => ShortfallReason.damagedGoods,
    'number4' => ShortfallReason.other,
    _ => throw const AppError.server(),
  };
}

/// One row of the itineraries list. The names are server-joined (mbe-api#343);
/// each is null when its id is null.
@freezed
abstract class ItinerarySummary with _$ItinerarySummary {
  const factory ItinerarySummary({
    required int id,
    required DateTime date,
    int? vehicleId,
    String? vehicleName,
    int? vehicleOperatorId,
    String? operatorName,
    int? warehouseId,
    String? warehouseName,
    required ItineraryStatus status,
    DateTime? departedAt,
    DateTime? returnedAt,
  }) = _ItinerarySummary;

  factory ItinerarySummary.fromResponse(api.ItinerarySummary r) =>
      ItinerarySummary(
        id: r.deliveriesItineraryId,
        date: r.date.toDateTime(),
        vehicleId: r.vehicle,
        vehicleName: r.vehicleName,
        vehicleOperatorId: r.vehicleOperator,
        operatorName: r.vehicleOperatorName,
        warehouseId: r.warehouse,
        warehouseName: r.warehouseName,
        status: ItineraryStatus.fromApi(r.status),
        departedAt: r.departureTime,
        returnedAt: r.returnTime,
      );
}

/// One page of [ItinerarySummary].
class ItineraryPage {
  const ItineraryPage({required this.items, required this.total});

  final List<ItinerarySummary> items;
  final int total;
}

/// A trip in full: the summary's fields plus the comment and the stops.
@freezed
abstract class Itinerary with _$Itinerary {
  const Itinerary._();

  const factory Itinerary({
    required int id,
    required DateTime date,
    int? vehicleId,
    String? vehicleName,
    int? vehicleOperatorId,
    String? operatorName,
    int? warehouseId,
    String? warehouseName,
    required ItineraryStatus status,
    DateTime? departedAt,
    DateTime? returnedAt,
    String? comment,
    @Default(<ItineraryStop>[]) List<ItineraryStop> stops,
  }) = _Itinerary;

  /// Maps the response. The response's `warnings` are deliberately dropped:
  /// they're uncoded English (§III), so the licence warning is built from the
  /// operator's expiry instead (research R4).
  factory Itinerary.fromResponse(api.ItineraryResponse r) {
    final stops =
        (r.stops ?? const <api.ItineraryStopResponse>[])
            .map(ItineraryStop.fromResponse)
            .toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));
    return Itinerary(
      id: r.deliveriesItineraryId,
      date: r.date.toDateTime(),
      vehicleId: r.vehicle,
      vehicleName: r.vehicleName,
      vehicleOperatorId: r.vehicleOperator,
      operatorName: r.vehicleOperatorName,
      warehouseId: r.warehouse,
      warehouseName: r.warehouseName,
      status: ItineraryStatus.fromApi(r.status),
      departedAt: r.departureTime,
      returnedAt: r.returnTime,
      comment: r.comment,
      stops: stops,
    );
  }

  /// The lines loaded across every stop.
  int get loadedLineCount => stops.fold(0, (sum, s) => sum + s.lines.length);

  /// Stops with nothing loaded (R7): such a stop would block the trip from
  /// closing, and the server departs with it (mbe-api#346).
  List<ItineraryStop> get emptyStops =>
      stops.where((s) => s.lines.isEmpty).toList();

  bool get canDepart =>
      status == ItineraryStatus.open &&
      loadedLineCount > 0 &&
      emptyStops.isEmpty;

  List<ItineraryStop> get pendingStops =>
      stops.where((s) => s.outcome == StopOutcome.pending).toList();
}

/// One stop of a trip. The order, customer and ship-to come from mbe-api#343;
/// [deliveryOrderId] is null on a legacy stop created before it.
@freezed
abstract class ItineraryStop with _$ItineraryStop {
  const ItineraryStop._();

  const factory ItineraryStop({
    required int id,
    required int sequence,
    required StopOutcome outcome,

    /// Set by the server when the stop is closed.
    DateTime? arrivedAt,
    int? proofId,
    String? comment,
    int? deliveryOrderId,
    @Default(<int>[]) List<int> deliveryOrderIds,
    String? customerName,
    String? shipToLabel,
    @Default(<ItineraryLine>[]) List<ItineraryLine> lines,
  }) = _ItineraryStop;

  factory ItineraryStop.fromResponse(api.ItineraryStopResponse r) =>
      ItineraryStop(
        id: r.deliveriesItineraryStopId,
        sequence: r.sequence,
        outcome: StopOutcome.fromApi(r.outcome),
        arrivedAt: r.arrivalTime,
        proofId: r.proofOfDelivery,
        comment: r.comment,
        deliveryOrderId: r.deliveryOrder,
        deliveryOrderIds: r.deliveryOrders?.toList() ?? const <int>[],
        customerName: r.customerDisplayName,
        shipToLabel: r.shipToLabel,
        lines: (r.lines ?? const <api.ItineraryLineResponse>[])
            .map(ItineraryLine.fromResponse)
            .toList(),
      );

  bool get isPending => outcome == StopOutcome.pending;
}

/// One loaded line of a stop. Quantities arrive as decimal strings and are
/// held as [Decimal], never `double`.
@freezed
abstract class ItineraryLine with _$ItineraryLine {
  const factory ItineraryLine({
    required int id,
    required int deliveryOrderLineId,
    required int deliveryOrderId,
    required String productCode,
    required String productName,
    String? unitSymbol,
    required Decimal committed,
    required Decimal sent,
    required Decimal delivered,
    required Decimal returned,
    ShortfallReason? reason,
    String? comment,
  }) = _ItineraryLine;

  factory ItineraryLine.fromResponse(api.ItineraryLineResponse r) =>
      ItineraryLine(
        id: r.deliveriesItineraryDetailId,
        deliveryOrderLineId: r.deliveryOrderDetail,
        deliveryOrderId: r.deliveryOrder,
        productCode: r.productCode,
        productName: r.productName,
        unitSymbol: r.unitOfMeasurement?.symbol,
        committed: Decimal.parse(r.committedQuantity),
        sent: Decimal.parse(r.sentQuantity),
        delivered: Decimal.parse(r.deliveredQuantity),
        returned: Decimal.parse(r.returnedQuantity),
        reason: r.reasonCode == null
            ? null
            : ShortfallReason.fromApi(r.reasonCode!),
        comment: r.comment,
      );
}

/// The proof of delivery image: an uploaded file, or a drawn signature
/// (`firma.png`).
class ProofImage {
  const ProofImage({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

/// What the close-stop dialog hands the repository.
class StopClosure {
  const StopClosure({
    required this.receiverName,
    required this.receiverIdShown,
    required this.lines,
    required this.proof,
  });

  final String receiverName;
  final String receiverIdShown;
  final List<StopClosureLine> lines;
  final ProofImage proof;
}

/// One line's outcome in a [StopClosure]. [reason] is required when
/// [delivered] is below what was sent.
class StopClosureLine {
  const StopClosureLine({
    required this.lineId,
    required this.delivered,
    this.reason,
  });

  final int lineId;
  final Decimal delivered;
  final ShortfallReason? reason;
}
