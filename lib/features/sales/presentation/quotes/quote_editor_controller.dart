import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/quote_editing.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_quote_write_scope.dart';
import 'package:mbe_ui/features/sales/presentation/tracked_editing.dart';

part 'quote_editor_controller.g.dart';

/// The quote screen's own [SaleEditor] — the twin of `OrderEditorController`,
/// keyed by [quoteId] instead of held as a singleton (spec 040 research.md
/// R3). `autoDispose` is deliberate here for the same reason as the order
/// workspace's own choice: a user opens many quotes in a session and each
/// one's state should die with its route.
///
/// [quoteId] is `null` for a brand-new quote — [build] returns `null` and
/// writes **nothing** (FR-006); the quote is created by whichever action is
/// first, exactly as `PosSaleController.ensureOpen` does for the register.
@riverpod
class QuoteEditorController extends _$QuoteEditorController
    with TrackedEditing, QuoteEditing
    implements SaleEditor {
  @override
  Future<Sale?> build(int? quoteId) async {
    if (quoteId == null) return null;
    return ref.read(salesQuoteRepositoryProvider).getById(quoteId: quoteId);
  }

  @override
  String get writesScope => salesQuoteWritesScope;

  /// Re-fetches the quote without mutating it — mirrors
  /// `OrderEditorController.refresh`, for the stale-draft case: a mutation
  /// refused because the quote is no longer editable re-reads it rather
  /// than leaving stale controls on screen.
  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    final repository = ref.read(salesQuoteRepositoryProvider);
    final refreshed = await repository.getById(quoteId: current.id);
    state = AsyncValue.data(refreshed);
  }

  /// `POST /sales-quotes/{id}/cancel` — this controller's own action; no
  /// shared widget calls it, so it is not on [SaleEditor] (FR-032). Returns
  /// the quote directly — the repository's own `cancel` already does, so
  /// unlike `OrderEditorController.cancel` there is no read-back here.
  Future<void> cancel() => tracked(() async {
    final current = openSale;
    final updated = await ref
        .read(salesQuoteRepositoryProvider)
        .cancel(quoteId: current.id);
    state = AsyncValue.data(updated);
  });

  /// `POST /sales-quotes/{id}/duplicate` — a **different**, independent
  /// draft (FR-033). Returns the new quote's id for the caller to navigate
  /// to; this controller's own `state` is left untouched, since the
  /// duplicate is not the document this instance is keyed on.
  Future<int> duplicate() => tracked(() async {
    final current = openSale;
    final created = await ref
        .read(salesQuoteRepositoryProvider)
        .duplicate(quoteId: current.id);
    return created.id;
  });

  /// `POST /sales-quotes/{id}/convert` — a **sales order** (FR-025–FR-031).
  /// Returns the new order's id for the caller to navigate to; this
  /// controller's own `state` is left untouched, since the resulting
  /// document is not a quote at all.
  Future<int> convert() => tracked(() async {
    final current = openSale;
    final order = await ref
        .read(salesQuoteRepositoryProvider)
        .convert(quoteId: current.id);
    return order.id;
  });
}
