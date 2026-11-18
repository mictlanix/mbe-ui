import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kardex.freezed.dart';

/// The ledger of one product in one warehouse over a date range.
@freezed
abstract class Kardex with _$Kardex {
  const factory Kardex({
    required int productId,
    required int warehouseId,

    /// Dates, as `DateTime` at midnight.
    required DateTime from,
    required DateTime to,
    required Decimal opening,
    required List<KardexMovement> movements,
    required Decimal totalIn,
    required Decimal totalOut,
    required Decimal closing,
  }) = _Kardex;
}

/// One movement of the ledger. The server's `source_name` is not kept: it is
/// server text, so the label comes from [sourceType] (research R5).
@freezed
abstract class KardexMovement with _$KardexMovement {
  const factory KardexMovement({
    required int id,

    /// Wall-clock time (spec 043).
    required DateTime date,

    /// The transaction type number.
    required int sourceType,

    /// The source document's id; 0 means none.
    required int reference,
    required Decimal quantityIn,
    required Decimal quantityOut,
    required Decimal balance,
    KardexDocumentRef? document,
  }) = _KardexMovement;
}

/// The document a movement came from, as the server resolved it.
@freezed
abstract class KardexDocumentRef with _$KardexDocumentRef {
  const factory KardexDocumentRef({
    required int type,
    required int id,
    int? facilityId,
    int? serial,
  }) = _KardexDocumentRef;
}
