import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';

/// A kardex movement for tests: a warehouse receipt with its document unless
/// overridden.
KardexMovement aKardexMovement({
  int id = 9001,
  DateTime? date,
  int sourceType = 4,
  int reference = 57,
  String quantityIn = '5',
  String quantityOut = '0',
  String balance = '15',
  KardexDocumentRef? document = const KardexDocumentRef(
    type: 4,
    id: 57,
    facilityId: 2,
    serial: 31,
  ),
}) => KardexMovement(
  id: id,
  date: date ?? DateTime(2026, 11, 10, 9, 30),
  sourceType: sourceType,
  reference: reference,
  quantityIn: Decimal.parse(quantityIn),
  quantityOut: Decimal.parse(quantityOut),
  balance: Decimal.parse(balance),
  document: document,
);

/// A kardex for tests: one movement over the last 30 days to 2026-11-17
/// unless overridden.
Kardex aKardex({
  int productId = 7,
  int warehouseId = 3,
  DateTime? from,
  DateTime? to,
  String opening = '10',
  List<KardexMovement>? movements,
  String totalIn = '5',
  String totalOut = '0',
  String closing = '15',
}) => Kardex(
  productId: productId,
  warehouseId: warehouseId,
  from: from ?? DateTime(2026, 10, 19),
  to: to ?? DateTime(2026, 11, 17),
  opening: Decimal.parse(opening),
  movements: movements ?? [aKardexMovement()],
  totalIn: Decimal.parse(totalIn),
  totalOut: Decimal.parse(totalOut),
  closing: Decimal.parse(closing),
);
