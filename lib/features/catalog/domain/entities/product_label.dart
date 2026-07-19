import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'product_label.freezed.dart';

/// A label attached to a product, read from `ProductResponse.labels`
/// (data-model.md "ProductLabel"). Display only — assignment is done
/// via [ProductFormState.labelIds] on create/update.
@freezed
class ProductLabel with _$ProductLabel {
  const factory ProductLabel({required int labelId, required String name}) =
      _ProductLabel;

  factory ProductLabel.fromResponse(LabelResponse r) =>
      ProductLabel(labelId: r.labelId, name: r.name);
}
