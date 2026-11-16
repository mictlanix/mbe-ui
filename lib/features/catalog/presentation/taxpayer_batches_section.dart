import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design_theme_extensions.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/features/catalog/presentation/fiscal_document_kind_label.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_batch_dialog.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_batches_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A Taxpayer Issuer's folio Series section (spec 065 US1–US4) — a
/// divider-delimited **child collection** rendered inside the issuer detail,
/// loaded through its own endpoint, never a standalone list screen. Rows are
/// sorted by document type, then series. A row tap opens the series
/// read-only; the Edit icon opens it editable; "Nuevo" adds one. Delete lives
/// inside the dialog, never on the row (constitution §VI).
///
/// Every mutating control follows the parent screen's own read-only flag
/// ([readOnly]) **and** the Taxpayers right, so a View render of the issuer
/// never exposes one, even to a privileged user (research R3).
class TaxpayerBatchesSection extends ConsumerWidget {
  const TaxpayerBatchesSection({
    super.key,
    required this.rfc,
    required this.readOnly,
  });

  final String rfc;

  /// The parent issuer screen's own read-only flag (`forceReadOnly ||
  /// !canUpdate`), passed straight through like the Certificates section's.
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(taxpayerBatchesControllerProvider(rfc));
    final access = ref.watch(accessControlProvider);
    final l10n = AppLocalizations.of(context)!;
    final loaded = batchesAsync.whenOrNull(data: (batches) => batches);
    // "Nuevo" waits for the list, like the other linked-record sections.
    final canAdd =
        !readOnly &&
        loaded != null &&
        access.can(SystemObject.taxpayers, AccessRight.create);
    final canEdit =
        !readOnly && access.can(SystemObject.taxpayers, AccessRight.update);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Theme.of(context).spacing.xs,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                loaded == null || loaded.isEmpty
                    ? l10n.taxpayerBatchesSectionTitle
                    : l10n.taxpayerBatchesSectionTitleWithCount(loaded.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (canAdd)
              TextButton.icon(
                key: const Key('add_taxpayer_batch_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.linkedRecordNewAction),
                onPressed: () => showTaxpayerBatchDialog(
                  context,
                  rfc: rfc,
                  parentReadOnly: readOnly,
                ),
              ),
          ],
        ),
        batchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListFailedView(
            error: toAppError(e),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(taxpayerBatchesControllerProvider(rfc)),
          ),
          data: (batches) => batches.isEmpty
              ? _MutedNote(
                  l10n.taxpayerBatchesEmpty,
                  key: const Key('taxpayer_batches_empty'),
                )
              : _BatchesTable(
                  rfc: rfc,
                  batches: batches,
                  readOnly: readOnly,
                  canEdit: canEdit,
                ),
        ),
      ],
    );
  }
}

class _BatchesTable extends StatelessWidget {
  const _BatchesTable({
    required this.rfc,
    required this.batches,
    required this.readOnly,
    required this.canEdit,
  });

  final String rfc;
  final List<TaxpayerBatch> batches;
  final bool readOnly;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compact = LayoutBreakpoints.isCompact(context);

    return DataTableView<TaxpayerBatch>(
      key: const Key('taxpayer_batches_table'),
      columns: [
        DataTableColumn.text(
          label: l10n.taxpayerBatchColumnSeries,
          text: (b) => b.series,
          size: ColumnSize.S,
        ),
        DataTableColumn.text(
          label: l10n.taxpayerBatchColumnType,
          text: (b) => taxpayerBatchTypeLabel(l10n, b),
          size: ColumnSize.M,
        ),
        // Dropped on the compact tier: secondary text, one tap away in the
        // dialog.
        if (!compact)
          DataTableColumn.text(
            label: l10n.taxpayerBatchColumnTemplate,
            text: (b) => b.template.name,
            size: ColumnSize.L,
          ),
        DataTableColumn(
          label: l10n.taxpayerBatchColumnInUse,
          fixedWidth: compact ? 72 : 96,
          cellBuilder: (context, b) => b.inUse
              ? Tooltip(
                  message: l10n.taxpayerBatchColumnInUse,
                  child: Icon(
                    Icons.lock_outline,
                    key: Key('taxpayer_batch_in_use_${b.taxpayerBatchId}'),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
      rows: batches,
      // A row tap opens the series read-only (constitution §VI).
      onRowTap: (b) => showTaxpayerBatchDialog(
        context,
        rfc: rfc,
        existing: b,
        parentReadOnly: readOnly,
      ),
      rowActionsBuilder: canEdit
          ? (context, b) => buildCatalogRowActions(
              editTooltip: l10n.editActionTooltip,
              editKey: Key('edit_taxpayer_batch_${b.taxpayerBatchId}'),
              onEdit: () => showTaxpayerBatchDialog(
                context,
                rfc: rfc,
                existing: b,
                startInEdit: true,
                parentReadOnly: readOnly,
              ),
            )
          : null,
      shrinkWrap: true,
      margin: EdgeInsets.zero,
    );
  }
}

/// The empty-state line the linked-record sections use: small, muted, with
/// a little air above and below.
class _MutedNote extends StatelessWidget {
  const _MutedNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
