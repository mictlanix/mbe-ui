import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_delete_preview_provider.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_form_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/widgets/price_list_delete_summary.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// What the delete review dialog reports back on success
/// (specs/034-price-list-retirement-ui data-model.md §4.3): how many
/// customers actually moved, and to which list — `null` when none did, so
/// the caller's snackbar can tell the two cases apart (FR-017). `null`
/// itself (rather than this record) means the dialog was cancelled/closed
/// with nothing submitted.
typedef PriceListDeleteOutcome = ({int movedCount, String? replacementName});

/// Opens the price list retirement review dialog (FR-001). Returns the
/// [PriceListDeleteOutcome] on a successful deletion, `null` on cancel/close.
Future<PriceListDeleteOutcome?> showPriceListDeleteDialog(
  BuildContext context, {
  required PriceList priceList,
}) {
  return showDialog<PriceListDeleteOutcome>(
    context: context,
    // The dialog IS the review (spec.md Overview) — dismissing it by tapping
    // outside or the system back gesture would lose that review with no
    // explicit act; only the Cancel/Close button does (contracts
    // /price-list-delete-dialog.md §2).
    barrierDismissible: false,
    builder: (_) => PriceListDeleteDialog(priceList: priceList),
  );
}

/// The price list retirement review dialog
/// (specs/034-price-list-retirement-ui, contracts/price-list-delete-dialog.md).
///
/// Requests the deletion preview when it opens (FR-001) and renders one of
/// seven states derived from it plus the submission's own progress — never a
/// hand-tracked state enum (data-model.md §4.1): loading, clean, priced,
/// assigned, blocked, previewFailed, and a refused overlay on whichever of
/// those preceded it.
class PriceListDeleteDialog extends ConsumerStatefulWidget {
  const PriceListDeleteDialog({super.key, required this.priceList});

  final PriceList priceList;

  @override
  ConsumerState<PriceListDeleteDialog> createState() =>
      _PriceListDeleteDialogState();
}

class _PriceListDeleteDialogState
    extends ConsumerState<PriceListDeleteDialog> {
  // Per-widget input state with the dialog's own lifetime (constitution
  // §II) — not a provider, since nothing outside this dialog reads it.
  bool _acknowledged = false;
  PriceList? _replacement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final formState = ref.watch(priceListFormControllerProvider);
    final previewAsync = ref.watch(
      priceListDeletePreviewProvider(priceListId: widget.priceList.priceListId),
    );

    final preview = previewAsync.valueOrNull;
    final previewLoading = previewAsync.isLoading && !previewAsync.hasValue;
    final previewFailed = previewAsync.hasError;
    final isEmpty = preview?.isEmpty ?? false;
    final isBlocked = preview?.isBlocked ?? false;
    final movedCount = preview?.movedCount ?? 0;
    final destroyedCount = preview?.destroyedCount ?? 0;
    final submitting = formState.submitting;

    // Data-model.md §4.1's `assigned` row: required only when the report
    // actually shows customers assigned and the list isn't blocked (I1 —
    // never required, and never even shown, once blocked: FR-018's "only
    // action offered is to close").
    final replacementRequired = movedCount > 0 && !isBlocked;
    final showReplacementPicker =
        (replacementRequired || previewFailed) && !isBlocked;
    final showAcknowledge =
        !isBlocked && ((!previewLoading && !isEmpty) || previewFailed);

    final canConfirm =
        !previewLoading &&
        !isBlocked &&
        !submitting &&
        (!showAcknowledge || _acknowledged) &&
        (!replacementRequired || _replacement != null);

    final confirmLabel = destroyedCount > 0
        ? l10n.priceListDeleteConfirmPrices(
            destroyedCount,
            fmt.display.count(destroyedCount),
          )
        : (movedCount > 0
              ? l10n.priceListDeleteConfirmCustomers(
                  movedCount,
                  fmt.display.count(movedCount),
                )
              : l10n.priceListDeleteConfirm);

    Future<void> onConfirm() async {
      final controller = ref.read(priceListFormControllerProvider.notifier);
      final chosenReplacement = _replacement;
      final success = await controller.delete(
        replacement: chosenReplacement?.priceListId,
      );
      if (!context.mounted) return;
      if (success) {
        Navigator.of(context).pop<PriceListDeleteOutcome>((
          movedCount: movedCount,
          replacementName: chosenReplacement?.name,
        ));
      }
      // On failure, formState.error is already set by the controller and
      // this widget rebuilds reactively (ref.watch above) — the dialog
      // simply stays open with the refusal banner shown (FR-019).
    }

    void onCancel() => Navigator.of(context).pop<PriceListDeleteOutcome>(null);

    void onViewCustomers() {
      Navigator.of(context).pop<PriceListDeleteOutcome>(null);
      context.go('/customers?priceList=${widget.priceList.priceListId}');
    }

    return PopScope(
      // Blocks the system back gesture/escape key unconditionally — the
      // review must be dismissed by an explicit Cancel/Close tap, not an
      // incidental one (contracts §2). `Navigator.pop` calls above are
      // direct pops and are unaffected by this.
      canPop: false,
      child: AlertDialog(
        key: const Key('price_list_delete_dialog'),
        title: Text(l10n.deletePriceListConfirmTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isBlocked) ...[
                  Text(
                    l10n.priceListDeleteLead(
                      widget.priceList.name,
                      widget.priceList.priceListId,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (formState.error != null) ...[
                  ErrorBanner(error: _refusalError(l10n, formState)),
                  const SizedBox(height: 16),
                ],
                if (isBlocked) ...[
                  _BlockedBanner(l10n: l10n),
                  const SizedBox(height: 16),
                ],
                if (previewFailed) ...[
                  _PreviewFailedNote(l10n: l10n),
                  const SizedBox(height: 16),
                ],
                if (previewLoading)
                  const _LoadingSkeleton()
                else if (isEmpty)
                  _CleanNote(l10n: l10n)
                else if (preview != null)
                  PriceListDeleteSummary(
                    preview: preview,
                    onViewCustomers: movedCount > 0 ? onViewCustomers : null,
                  ),
                if (showReplacementPicker) ...[
                  const SizedBox(height: 16),
                  _ReplacementPicker(
                    excludedPriceListId: widget.priceList.priceListId,
                    required: replacementRequired,
                    previewFailed: previewFailed,
                    movedCount: movedCount,
                    fmt: fmt,
                    chosen: _replacement,
                    onChanged: (p) => setState(() => _replacement = p),
                  ),
                ],
                if (showAcknowledge) ...[
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    key: const Key('price_list_delete_acknowledge'),
                    value: _acknowledged,
                    onChanged: submitting
                        ? null
                        : (_) => setState(
                            () => _acknowledged = !_acknowledged,
                          ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.priceListDeleteAcknowledge),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: submitting ? null : onCancel,
            child: Text(
              isBlocked ? l10n.priceListDeleteClose : l10n.cancelButton,
            ),
          ),
          if (!isBlocked)
            FilledButton(
              key: const Key('price_list_delete_confirm'),
              onPressed: canConfirm ? onConfirm : null,
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(confirmLabel),
            ),
        ],
      ),
    );
  }
}

/// Wraps the controller's error code/detail into an [AppError] `ErrorBanner`
/// can render, mirroring `PriceListDetailScreen`'s own composition
/// (research.md R10) — a localized generic line, then the server's own
/// sentence via `errorDetail`/`serverMessage`, exactly as `409`'s
/// "Still referenced by customer.price_list (12) — remove those records
/// first" reaches the operator verbatim (FR-019).
AppError _refusalError(AppLocalizations l10n, PriceListFormState formState) {
  return AppError.validation([
    FieldError(
      loc: const [],
      msg: _localizeDeleteError(l10n, formState.error!),
      type: 'error',
    ),
    if (formState.errorDetail != null)
      FieldError(loc: const [], msg: formState.errorDetail!, type: 'error'),
  ]);
}

String _localizeDeleteError(AppLocalizations l10n, String code) {
  switch (code) {
    case PriceListFormErrorCode.deletePermissionDenied:
      return l10n.priceListDeletePermissionDeniedError;
    case PriceListFormErrorCode.deleteFailed:
    default:
      return l10n.priceListDeleteFailedError;
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('price_list_delete_loading'),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _CleanNote extends StatelessWidget {
  const _CleanNote({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('price_list_delete_clean_note'),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.priceListDeleteCleanNote,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedBanner extends StatelessWidget {
  const _BlockedBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('price_list_delete_blocked_banner'),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.priceListDeleteBlockedBanner,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewFailedNote extends StatelessWidget {
  const _PreviewFailedNote({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('price_list_delete_preview_failed_note'),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.priceListDeletePreviewFailedNote,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// The replacement price list picker (FR-009, FR-010, FR-011, FR-020) — a
/// `CatalogEntityPicker<PriceList>` over the price list catalog, excluding
/// the list being deleted, with a helper line whose text depends on whether
/// a replacement is required, chosen, or merely optional because the
/// preview never resolved (contracts/price-list-delete-dialog.md §4.1).
class _ReplacementPicker extends ConsumerWidget {
  const _ReplacementPicker({
    required this.excludedPriceListId,
    required this.required,
    required this.previewFailed,
    required this.movedCount,
    required this.fmt,
    required this.chosen,
    required this.onChanged,
  });

  final int excludedPriceListId;
  final bool required;
  final bool previewFailed;
  final int movedCount;
  final AppFormatters fmt;
  final PriceList? chosen;
  final ValueChanged<PriceList?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(priceListRepositoryProvider);

    final String helperText;
    if (chosen != null && !previewFailed) {
      helperText = l10n.priceListDeleteReplacementChosenHelper(
        movedCount,
        fmt.display.count(movedCount),
        chosen!.name,
      );
    } else if (previewFailed) {
      helperText = l10n.priceListDeleteReplacementOptionalHelper;
    } else {
      helperText = l10n.priceListDeleteReplacementRequiredHelper;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<PriceList>(
          key: const Key('price_list_delete_replacement'),
          label: required
              ? l10n.priceListDeleteReplacementLabel
              : l10n.priceListDeleteReplacementLabelOptional,
          displayStringForOption: (p) => p.name,
          initialDisplayText: chosen?.name,
          optionsBuilder: (search) async {
            final result = await repository.list(
              search: search.isEmpty ? null : search,
            );
            // The list being retired is never its own replacement (FR-010).
            return result.items.where(
              (p) => p.priceListId != excludedPriceListId,
            );
          },
          onSelected: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(
            helperText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
