import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'supplier_agreement.freezed.dart';

/// A dated commercial agreement with a supplier (data-model.md), mapped from
/// `SupplierAgreementResponse`. `start`/`end` are calendar dates; the wire
/// `Date` is converted to a `DateTime` at the mapping boundary.
@freezed
abstract class SupplierAgreement with _$SupplierAgreement {
  const factory SupplierAgreement({
    required int supplierAgreementId,
    required int supplierId,
    required DateTime start,
    required DateTime end,
    String? comment,
  }) = _SupplierAgreement;

  factory SupplierAgreement.fromResponse(SupplierAgreementResponse r) =>
      SupplierAgreement(
        supplierAgreementId: r.supplierAgreementId,
        supplierId: r.supplier,
        start: r.start.toDateTime(),
        end: r.end.toDateTime(),
        comment: r.comment,
      );
}
