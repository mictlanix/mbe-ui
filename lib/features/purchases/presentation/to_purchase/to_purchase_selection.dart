import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_filter.dart';

part 'to_purchase_selection.g.dart';

/// A Por comprar group by its key: an order can be created only from a group
/// with a supplier.
typedef ToPurchaseGroupKey = ({int supplierId, int facilityId});

/// The group "Crear orden" acts on (spec 080 research R5), or null.
///
/// Keyed by Por comprar's filter, so a page or filter change starts with
/// nothing selected. It also clears whenever the groups reload, which every
/// create causes (the actions invalidate Por comprar): a selection never
/// outlives the group it was made on.
@riverpod
class ToPurchaseSelection extends _$ToPurchaseSelection {
  @override
  ToPurchaseGroupKey? build(ToPurchaseFilter filter) {
    ref.listen(toPurchaseControllerProvider(filter.facilityId), (_, _) {
      if (state != null) state = null;
    });
    return null;
  }

  /// Selects [group], replacing any other.
  void select(ToPurchaseGroupKey group) => state = group;

  void clear() => state = null;
}
