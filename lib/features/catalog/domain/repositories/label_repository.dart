import 'package:mbe_ui/features/catalog/domain/entities/label.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';

/// Label lookup and full CRUD management (data-model.md "LabelRepository",
/// contracts/mbe-api-master-data-pickers.md, contracts/mbe-api-catalogs.md §2).
/// `list` is also consumed by the product form's label multi-picker and the
/// products list's label filter (specs/002, specs/009) — unaffected by the
/// CRUD additions below (spec 012).
abstract class LabelRepository {
  Future<LabelListResult> list({String? search, int skip = 0, int limit = 100});

  /// Full-detail listing for the Labels catalog screen itself (spec 012
  /// FR-001), as opposed to [list]'s lightweight `LabelItem` used by the
  /// product form's picker/filter. Both hit the same `GET /labels` endpoint.
  Future<LabelPage> listDetailed({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  Future<Label> get({required int labelId});

  Future<Label> create({required String name, String? comment});

  Future<Label> update({
    required int labelId,
    String? name,
    String? comment,
  });

  Future<void> delete({required int labelId});
}

class LabelListResult {
  const LabelListResult({required this.items, required this.total});
  final List<LabelItem> items;
  final int total;
}

class LabelPage {
  const LabelPage({required this.items, required this.total});
  final List<Label> items;
  final int total;
}
