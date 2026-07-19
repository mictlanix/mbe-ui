import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';

/// Read-only label lookup, consumed by the label multi-picker on the product
/// form and the label filter on the products list (data-model.md
/// "LabelRepository", contracts/mbe-api-master-data-pickers.md).
abstract class LabelRepository {
  Future<LabelListResult> list({String? search, int skip = 0, int limit = 100});
}

class LabelListResult {
  const LabelListResult({required this.items, required this.total});
  final List<LabelItem> items;
  final int total;
}
