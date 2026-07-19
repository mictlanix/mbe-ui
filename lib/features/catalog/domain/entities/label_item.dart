import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'label_item.freezed.dart';

/// A label used for both the multi-picker on the product form and the filter
/// dropdown on the products list (data-model.md "LabelItem").
@freezed
class LabelItem with _$LabelItem {
  const factory LabelItem({required int labelId, required String name}) =
      _LabelItem;

  factory LabelItem.fromResponse(LabelResponse r) =>
      LabelItem(labelId: r.labelId, name: r.name);
}
