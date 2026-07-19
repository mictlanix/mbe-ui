import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_state.dart';
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
                optionSubtitle: _optionSubtitle,
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
                optionSubtitle: _optionSubtitle,
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
            FormGridChild(
              span: FormGridSpan.full,
              FilledButton(
                key: const Key('merge_submit_button'),
                onPressed: state.canSubmit
                    ? () => _confirmMerge(context, l10n, controller, state)
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
  ) async {
    final canonicalName = state.canonical!.name;
    final duplicateName = state.duplicate!.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mergeConfirmTitle),
        content: Text(l10n.mergeConfirmMessage(canonicalName, duplicateName)),
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

/// Shared `optionsBuilder` for both pickers (FR-002): searches the full
/// catalog — `deactivated: null` applies no state filter, matching the
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
    deactivated: null,
    limit: _suggestionLimit,
  );
  return result.items;
}

/// Suggestion-row subtitle: code, model, and SKU (FR-003) — all three are
/// searchable (`_search` above) and now displayable, now that
/// `ProductListItem` carries `sku`
/// ([mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76),
/// research.md §3). Blank/missing parts are omitted rather than shown as
/// empty separators.
String? _optionSubtitle(ProductListItem item) {
  final parts = [
    item.code,
    if (item.model case final model? when model.isNotEmpty) model,
    if (item.sku case final sku? when sku.isNotEmpty) sku,
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
