import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'label.freezed.dart';

/// A named tag attachable to products — full detail entity for the Labels
/// catalog (data-model.md §2), mapped from `LabelResponse`. The lightweight
/// `LabelItem` (id/name) remains the product form's multi-picker and
/// products-list filter item type, unaffected by this entity.
@freezed
class Label with _$Label {
  const factory Label({
    required int labelId,
    required String name,
    String? comment,
  }) = _Label;

  factory Label.fromResponse(LabelResponse response) {
    return Label(
      labelId: response.labelId,
      name: response.name,
      comment: response.comment,
    );
  }
}
