import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'supplier_list_item.freezed.dart';

/// A supplier search result used as the supplier picker's item type
/// (data-model.md "SupplierListItem").
@freezed
class SupplierListItem with _$SupplierListItem {
  const factory SupplierListItem({
    required int supplierId,
    required String code,
    required String name,
  }) = _SupplierListItem;

  factory SupplierListItem.fromResponse(SupplierResponse r) =>
      SupplierListItem(supplierId: r.supplierId, code: r.code, name: r.name);
}
