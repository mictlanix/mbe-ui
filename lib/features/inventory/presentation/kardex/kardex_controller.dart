import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/kardex_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_selection.dart';

part 'kardex_controller.g.dart';

/// One product's kardex in one warehouse over a range (spec 071 US3), keyed
/// by the screen's [KardexSelection]. It reads only a `ready` selection: an
/// incomplete one or an invalid range makes no request and holds `null`
/// (research R4). A failure keeps the repository's `AppError`.
@riverpod
class KardexController extends _$KardexController {
  @override
  Future<Kardex?> build(KardexSelection selection) async {
    if (selection.state != KardexSelectionState.ready) return null;
    return ref
        .read(kardexRepositoryProvider)
        .read(
          productId: selection.productId!,
          warehouseId: selection.warehouseId!,
          from: selection.from,
          to: selection.to,
        );
  }
}

/// "{code} {name}" for the Kardex's selection strip and product picker, or
/// `null` when the product can't be read (a missing Products right, a
/// deleted product or a failed request): the screen then shows `#id`.
@riverpod
Future<String?> kardexProductLabel(Ref ref, int productId) async {
  try {
    final product = await ref
        .watch(productRepositoryProvider)
        .get(productId: productId);
    return '${product.code} ${product.name}';
  } catch (_) {
    return null;
  }
}
