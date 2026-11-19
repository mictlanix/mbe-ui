import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';

/// Wire-shaped JSON for the itinerary responses (spec 075), for the
/// repository tests that feed it through the real serializers, and entity
/// builders for the controller, action and widget tests.

Map<String, Object?> itineraryLineJson({
  int id = 7001,
  int orderLine = 900,
  int order = 1532,
  String code = 'CLA-25',
  String name = 'Clavo 2½"',
  String? unit = 'kg',
  String committed = '25.0000',
  String sent = '0.0000',
  String delivered = '0.0000',
  String returned = '0.0000',
  int? reason,
}) => {
  'deliveries_itinerary_detail_id': id,
  'delivery_order_detail': orderLine,
  'delivery_order': order,
  'product_code': code,
  'product_name': name,
  'unit_of_measurement': unit == null
      ? null
      : {'id': 'KGM', 'name': 'Kilogramo', 'symbol': unit},
  'committed_quantity': committed,
  'sent_quantity': sent,
  'delivered_quantity': delivered,
  'returned_quantity': returned,
  'reason_code': reason,
  'comment': null,
};

Map<String, Object?> itineraryStopJson({
  int id = 501,
  int sequence = 1,
  int outcome = 0,
  int? order = 1532,
  List<int>? orders,
  String? customer = 'Abarrotes La Central',
  String? shipTo = 'Mercado 2, Local L-14',
  String? arrival,
  List<Map<String, Object?>>? lines,
}) => {
  'deliveries_itinerary_stop_id': id,
  'sequence': sequence,
  'arrival_time': arrival,
  'outcome': outcome,
  'proof_of_delivery': null,
  'comment': null,
  'delivery_order': order,
  'delivery_orders': orders ?? [?order],
  'customer_display_name': customer,
  'ship_to_label': shipTo,
  'lines': lines ?? [itineraryLineJson()],
};

Map<String, Object?> itineraryJson({
  int id = 58,
  String date = '2026-11-18',
  int? vehicle = 4,
  int? operator = 9,
  int? warehouse = 3,
  int status = 0,
  String? departure,
  String? returned,
  String? comment,
  List<Map<String, Object?>>? stops,
  List<String>? warnings,
}) => {
  'deliveries_itinerary_id': id,
  'date': date,
  'vehicle': vehicle,
  'vehicle_name': vehicle == null ? null : 'Torton · MBE-114',
  'vehicle_operator': operator,
  'vehicle_operator_name': operator == null ? null : 'Juan Rivas',
  'warehouse': warehouse,
  'warehouse_name': warehouse == null ? null : 'Bodega Norte',
  'status': status,
  'departure_time': departure,
  'return_time': returned,
  'comment': comment,
  'stops': stops ?? [itineraryStopJson()],
  'warnings': warnings ?? <String>[],
};

Map<String, Object?> itinerarySummaryJson({
  int id = 58,
  int status = 0,
  int? vehicle = 4,
}) => {
  'deliveries_itinerary_id': id,
  'date': '2026-11-18',
  'vehicle': vehicle,
  'vehicle_name': vehicle == null ? null : 'Torton · MBE-114',
  'vehicle_operator': 9,
  'vehicle_operator_name': 'Juan Rivas',
  'warehouse': 3,
  'warehouse_name': 'Bodega Norte',
  'status': status,
  'departure_time': null,
  'return_time': null,
};

ItineraryLine fakeItineraryLine({
  int id = 7001,
  int orderLineId = 900,
  int orderId = 1532,
  String code = 'CLA-25',
  String name = 'Clavo 2½"',
  String? unit = 'kg',
  String committed = '25',
  String sent = '0',
  String delivered = '0',
  String returned = '0',
  ShortfallReason? reason,
}) => ItineraryLine(
  id: id,
  deliveryOrderLineId: orderLineId,
  deliveryOrderId: orderId,
  productCode: code,
  productName: name,
  unitSymbol: unit,
  committed: Decimal.parse(committed),
  sent: Decimal.parse(sent),
  delivered: Decimal.parse(delivered),
  returned: Decimal.parse(returned),
  reason: reason,
);

ItineraryStop fakeItineraryStop({
  int id = 501,
  int sequence = 1,
  StopOutcome outcome = StopOutcome.pending,
  int? orderId = 1532,
  List<int>? orderIds,
  String? customer = 'Abarrotes La Central',
  String? shipTo = 'Mercado 2, Local L-14',
  DateTime? arrivedAt,
  List<ItineraryLine>? lines,
}) => ItineraryStop(
  id: id,
  sequence: sequence,
  outcome: outcome,
  arrivedAt: arrivedAt,
  deliveryOrderId: orderId,
  deliveryOrderIds: orderIds ?? [?orderId],
  customerName: customer,
  shipToLabel: shipTo,
  lines: lines ?? [fakeItineraryLine()],
);

Itinerary fakeItinerary({
  int id = 58,
  ItineraryStatus status = ItineraryStatus.open,
  int? vehicleId = 4,
  int? operatorId = 9,
  int? warehouseId = 3,
  DateTime? departedAt,
  DateTime? returnedAt,
  String? comment,
  List<ItineraryStop>? stops,
}) => Itinerary(
  id: id,
  date: DateTime(2026, 11, 18),
  vehicleId: vehicleId,
  vehicleName: vehicleId == null ? null : 'Torton · MBE-114',
  vehicleOperatorId: operatorId,
  operatorName: operatorId == null ? null : 'Juan Rivas',
  warehouseId: warehouseId,
  warehouseName: warehouseId == null ? null : 'Bodega Norte',
  status: status,
  departedAt: departedAt,
  returnedAt: returnedAt,
  comment: comment,
  stops: stops ?? [fakeItineraryStop()],
);

ItinerarySummary fakeItinerarySummary({
  int id = 58,
  ItineraryStatus status = ItineraryStatus.open,
  int? vehicleId = 4,
}) => ItinerarySummary(
  id: id,
  date: DateTime(2026, 11, 18),
  vehicleId: vehicleId,
  vehicleName: vehicleId == null ? null : 'Torton · MBE-114',
  vehicleOperatorId: 9,
  operatorName: 'Juan Rivas',
  warehouseId: 3,
  warehouseName: 'Bodega Norte',
  status: status,
);
