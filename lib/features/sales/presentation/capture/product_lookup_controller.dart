import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';

part 'product_lookup_controller.g.dart';

/// Backs [ProductSearchField] (FR-020, FR-021) — an autodispose family keyed
/// by [pattern] and [warehouse], so each keystroke's request is its own
/// short-lived provider rather than accumulating state across searches.
/// `customer` is not part of the key: it is read from the current
/// [Sale.customer] at call time, since pricing follows whichever customer is
/// on the sale right now, not a separate dimension the search field controls.
///
/// `dependencies: [saleEditor]` (spec 038 research) — without it, Riverpod
/// has no reason to re-scope this provider under a nested `ProviderScope`
/// override, so it would resolve `saleEditorProvider` against the *root*
/// container regardless of where the calling widget sits (`OrderScreen`'s
/// own override included), silently opening/writing to the register's sale
/// from the order screen instead of the order.
@Riverpod(dependencies: [saleEditor])
Future<List<ProductLookupResult>> productLookupController(
  Ref ref,
  String pattern, {
  int? warehouse,
}) async {
  final trimmed = pattern.trim();
  if (trimmed.isEmpty) return const [];
  // Pricing is per customer and the customer is the sale's, so a lookup is
  // one of the actions that opens the sale when none is started yet.
  final sale = await ref.read(saleEditorProvider).ensureOpen();
  return ref
      .watch(salesOrderRepositoryProvider)
      .productLookup(pattern: trimmed, customer: sale.customer, warehouse: warehouse);
}
