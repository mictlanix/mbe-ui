import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/merge_preview.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_comparison_provider.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_state.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/merge_comparison_table.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/merge_related_records_summary.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/merge_review_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Minimum typed length before a picker searches (legacy screen used 3;
/// research.md §2/§3), avoiding overly broad result sets.
const _minSearchLength = 3;

/// Number of suggestions requested per search (legacy screen used ~15;
/// research.md §2).
const _suggestionLimit = 15;

/// Fuses two products found to be duplicates into one (spec.md
/// specs/008-merge-products). Route `/products/merge`, gated by
/// `can(SystemObject.productsMerge, AccessRight.create)` in the router.
class MergeProductsScreen extends ConsumerWidget {
  const MergeProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mergeProductsControllerProvider);
    final controller = ref.read(mergeProductsControllerProvider.notifier);
    final productRepository = ref.read(productRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    // The comparison must have actually loaded before a merge can be
    // confirmed (FR-011): an operator must never acknowledge a deletion
    // against data that failed to arrive. `null` while the review step isn't
    // showing at all, in which case `canSubmit` is false anyway.
    final comparison = state.reviewReady
        ? ref.watch(
            mergeComparisonProvider(
              canonicalId: state.canonical!.productId,
              duplicateId: state.duplicate!.productId,
            ),
          )
        : null;
    final canSubmit = state.canSubmit && (comparison?.hasValue ?? false);

    // Informational only (FR-006): its failure is deliberately absent from
    // `canSubmit` — an operator who can see both records well enough to
    // confirm shouldn't be blocked because a count didn't load.
    final preview = state.reviewReady
        ? ref.watch(
            mergePreviewProvider(
              canonicalId: state.canonical!.productId,
              duplicateId: state.duplicate!.productId,
            ),
          )
        : null;

    // A one-shot flag (mirrors `ProductFormState.saved`/`deleted`) — a bare
    // `submission is AsyncData` can't distinguish "just succeeded" from
    // "never submitted", since idle state starts as `AsyncData(null)` too
    // (FR-010).
    if (state.merged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.mergeSuccess)));
        context.go('/products');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mergeProductsTitle),
        leading: IconButton(
          key: const Key('merge_back_button'),
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.mergeBackTooltip,
          onPressed: () => context.go('/products'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveFormGrid(
          // A single, width-capped column — this form's two pickers read
          // best stacked, not paired side by side (constitution §VI).
          maxColumns: 1,
          children: [
            if (state.submission.hasError)
              FormGridChild(
                span: FormGridSpan.full,
                ErrorBanner(
                  key: const Key('merge_error_banner'),
                  error: state.submission.error! as AppError,
                ),
              ),
            FormGridChild(
              span: FormGridSpan.full,
              CatalogEntityPicker<ProductListItem>(
                key: const Key('merge_canonical_field'),
                label: l10n.mergeProductLabel,
                displayStringForOption: (item) => item.name,
                optionsBuilder: (query) => _search(productRepository, query),
                onSelected: controller.canonicalSelected,
                optionImageUrl: (item) => item.photo,
                optionSubtitle: (item) => _optionSubtitle(l10n, item),
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              CatalogEntityPicker<ProductListItem>(
                key: const Key('merge_duplicate_field'),
                label: l10n.duplicatedLabel,
                displayStringForOption: (item) => item.name,
                optionsBuilder: (query) => _search(productRepository, query),
                onSelected: controller.duplicateSelected,
                optionImageUrl: (item) => item.photo,
                optionSubtitle: (item) => _optionSubtitle(l10n, item),
              ),
            ),
            if (state.validationMessageCode case final code?)
              FormGridChild(
                span: FormGridSpan.full,
                Text(
                  _localizeValidation(l10n, code),
                  key: const Key('merge_validation_message'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            // The review step (specs/016 FR-001): once the pair is valid and
            // distinct, the operator sees both records in full before the
            // destructive confirmation, rather than trusting two lines of
            // typeahead text.
            if (state.reviewReady && comparison != null)
              FormGridChild(
                span: FormGridSpan.full,
                _MergeReviewStep(
                  comparison: comparison,
                  preview: preview,
                  onSwap: controller.swap,
                ),
              ),
            // The acknowledgment names the record about to be destroyed and
            // gates the submit button (specs/016 FR-007). It resets whenever
            // either selection changes, so it can never refer to a product
            // the operator didn't actually confirm (FR-008).
            if (state.reviewReady)
              FormGridChild(
                span: FormGridSpan.full,
                CheckboxListTile(
                  key: const Key('merge_acknowledge_checkbox'),
                  value: state.acknowledged,
                  onChanged: (_) => controller.acknowledgeToggled(),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.mergeAcknowledgeLabel(state.duplicate!.name),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            FormGridChild(
              span: FormGridSpan.full,
              FilledButton(
                key: const Key('merge_submit_button'),
                onPressed: canSubmit
                    ? () => _confirmMerge(
                        context,
                        l10n,
                        controller,
                        state,
                        preview?.valueOrNull?.total,
                      )
                    : null,
                child: state.submission.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.mergeButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirms the permanent, irreversible merge (FR-007) before calling
  /// [MergeProductsController.submit]. Mirrors
  /// `product_detail_screen._confirmDelete`'s dialog shape.
  Future<void> _confirmMerge(
    BuildContext context,
    AppLocalizations l10n,
    MergeProductsController controller,
    MergeProductsState state,
    int? relatedTotal,
  ) async {
    final canonical = state.canonical!;
    final duplicate = state.duplicate!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mergeConfirmTitle),
        // Restates both records by name *and* code (specs/016 FR-009) — two
        // products similar enough to be merged are often distinguishable
        // only by code.
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              l10n.mergeConfirmMessage(
                canonical.name,
                canonical.code,
                duplicate.name,
                duplicate.code,
              ),
            ),
            // A separate line rather than a placeholder inside the sentence
            // above, so a pending or failed preview simply drops it instead
            // of forcing a blank or zero into the copy (FR-009).
            if (relatedTotal != null)
              Text(
                l10n.mergeConfirmTotalLine(relatedTotal),
                key: const Key('merge_confirm_total_line'),
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('merge_confirm_cancel_button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('merge_confirm_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.mergeButton),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.submit();
  }
}

/// The review step's body: the kept/deleted panels, the swap control, and the
/// field-by-field comparison, driven by the full product records
/// (specs/016-product-merge-review US1, US2, US3).
///
/// Renders the three states of the comparison fetch explicitly — a partial or
/// stale comparison is never shown, because the whole point of this step is
/// that the operator can trust what is on screen (FR-011).
class _MergeReviewStep extends StatelessWidget {
  const _MergeReviewStep({
    required this.comparison,
    required this.preview,
    required this.onSwap,
  });

  final AsyncValue<MergeComparison> comparison;
  final AsyncValue<MergePreview>? preview;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return comparison.when(
      loading: () => const Padding(
        key: Key('merge_comparison_loading'),
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ErrorBanner(
        key: const Key('merge_comparison_error_banner'),
        error: error is AppError
            ? error
            : AppError.server(message: error.toString()),
      ),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeReviewPanels(
            kept: data.kept,
            deleted: data.deleted,
            onSwap: onSwap,
          ),
          const SizedBox(height: 16),
          MergeComparisonTable(kept: data.kept, deleted: data.deleted),
          // The blast-radius summary slots in when (and only when) its own
          // fetch succeeds. Loading shows a placeholder; a failure renders
          // nothing at all — no banner, no zero-filled rows (Story 5 #4).
          ...switch (preview) {
            AsyncData(:final value) => [
              const SizedBox(height: 16),
              MergeRelatedRecordsSummary(preview: value),
            ],
            AsyncLoading() => const [
              SizedBox(height: 16),
              Padding(
                key: Key('merge_related_loading'),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ],
            _ => const <Widget>[],
          },
        ],
      ),
    );
  }
}

/// Shared `optionsBuilder` for both pickers (FR-002): searches the full
/// catalog — `status: null` applies no state filter, matching the
/// legacy merge-suggestion behavior of surfacing products in any state
/// (spec.md Clarifications) — once at least [_minSearchLength] characters
/// have been typed (research.md §2).
Future<List<ProductListItem>> _search(
  ProductRepository repository,
  String query,
) async {
  final trimmed = query.trim();
  if (trimmed.length < _minSearchLength) return const [];
  final result = await repository.list(
    search: trimmed,
    status: null,
    limit: _suggestionLimit,
  );
  return result.items;
}

/// Suggestion-row subtitle: code, model, and SKU (spec 008 FR-003) — all
/// three are searchable (`_search` above) and displayable now that
/// `ProductListItem` carries `sku`
/// ([mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76),
/// research.md §3). Blank/missing parts are omitted rather than shown as
/// empty separators.
///
/// Each value is prefixed with its field name, matching the review panels
/// (`merge_review_panel.dart`). This catalog frequently carries the same
/// string in all three fields (`292699 · 292699 · 292699`), which without
/// prefixes tells the operator nothing about *which* identifier they matched
/// on — and picking the wrong product here is what the whole review step
/// downstream exists to catch.
String? _optionSubtitle(AppLocalizations l10n, ProductListItem item) {
  final parts = [
    '${l10n.mergeFieldCode}: ${item.code}',
    if (item.model case final model? when model.isNotEmpty)
      '${l10n.mergeFieldModel}: $model',
    if (item.sku case final sku? when sku.isNotEmpty)
      '${l10n.mergeFieldSku}: $sku',
  ];
  return parts.join(' · ');
}

/// Localizes a [MergeValidationCode] for [MergeProductsState.validationMessageCode].
String _localizeValidation(AppLocalizations l10n, String code) {
  switch (code) {
    case MergeValidationCode.bothRequired:
      return l10n.mergeBothRequiredMessage;
    case MergeValidationCode.sameProduct:
      return l10n.mergeSameProductMessage;
    default:
      return code;
  }
}
