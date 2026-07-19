import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'supplier.freezed.dart';

/// A vendor a product can be sourced from — full detail entity for the
/// Suppliers catalog (data-model.md §1), mapped from `SupplierResponse`.
/// `creditLimit` is kept as `String` end-to-end (research.md §4) — never
/// parsed to `double`. The lightweight `SupplierListItem` (id/code/name)
/// remains the product form's picker item type, unaffected by this entity.
@freezed
class Supplier with _$Supplier {
  const factory Supplier({
    required int supplierId,
    required String code,
    required String name,
    String? zone,
    required String creditLimit,
    required int creditDays,
    String? comment,
  }) = _Supplier;

  factory Supplier.fromResponse(SupplierResponse response) {
    return Supplier(
      supplierId: response.supplierId,
      code: response.code,
      name: response.name,
      zone: response.zone,
      creditLimit: response.creditLimit,
      creditDays: response.creditDays,
      comment: response.comment,
    );
  }
}
