import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreement_dialog.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreements_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A supplier's Agreements section (spec 050 FR-003, FR-015, FR-016) — a
/// divider-delimited **child collection** rendered inside the supplier
/// detail, loaded through its own endpoint rather than the supplier's
/// (research §R2). Add and per-row Edit (which hosts Delete) open
/// [showSupplierAgreementDialog]; both are hidden unless the screen is
/// editable and the user has Update on suppliers (FR-013).
///
/// In create mode ([supplierId] `null`) the supplier has no id to load
/// agreements for, so the section shows a note instead and never touches the
/// provider.
class SupplierAgreementsSection extends ConsumerWidget {
  const SupplierAgreementsSection({
    super.key,
    required this.supplierId,
    required this.readOnly,
  });

  final int? supplierId;

  /// The parent supplier screen's own read-only flag — passed straight
  /// through so this section's mutation controls follow the same visibility
  /// rule as every other one on that screen.
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = supplierId;
    final canEdit =
        !readOnly &&
        ref
            .watch(accessControlProvider)
            .can(SystemObject.suppliers, AccessRight.update);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          children: [
            Text(
              l10n.supplierAgreementsSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            if (id != null && canEdit)
              FilledButton.icon(
                key: const Key('add_agreement_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.addAgreementButton),
                onPressed: () =>
                    showSupplierAgreementDialog(context, supplierId: id),
              ),
          ],
        ),
        if (id == null)
          Text(
            l10n.supplierAgreementsAfterSaveNote,
            key: const Key('supplier_agreements_after_save_note'),
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          _AgreementsList(supplierId: id, canEdit: canEdit),
      ],
    );
  }
}

class _AgreementsList extends ConsumerWidget {
  const _AgreementsList({required this.supplierId, required this.canEdit});

  final int supplierId;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementsAsync = ref.watch(
      supplierAgreementsControllerProvider(supplierId),
    );
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);

    return agreementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ListFailedView(
        error: toAppError(e),
        retryLabel: l10n.retryButton,
        onRetry: () =>
            ref.invalidate(supplierAgreementsControllerProvider(supplierId)),
      ),
      data: (agreements) => agreements.isEmpty
          ? Text(l10n.supplierAgreementsEmpty)
          : DataTableView<SupplierAgreement>(
              key: const Key('supplier_agreements_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.supplierAgreementColumnStart,
                  text: (a) => fmt.display.date(a.start),
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.supplierAgreementColumnEnd,
                  text: (a) => fmt.display.date(a.end),
                  size: ColumnSize.S,
                ),
                // Dropped on the compact tier, where three columns do not
                // fit (research R12).
                if (!compact)
                  DataTableColumn.text(
                    label: l10n.supplierAgreementColumnNotes,
                    text: (a) => (a.comment == null || a.comment!.isEmpty)
                        ? emptyValuePlaceholder
                        : a.comment!,
                    size: ColumnSize.L,
                  ),
              ],
              rows: agreements,
              rowActionsBuilder: canEdit
                  ? (context, a) => buildCatalogRowActions(
                      editTooltip: l10n.editActionTooltip,
                      editKey: Key('edit_agreement_${a.supplierAgreementId}'),
                      onEdit: () => showSupplierAgreementDialog(
                        context,
                        supplierId: supplierId,
                        existing: a,
                      ),
                    )
                  : null,
              shrinkWrap: true,
              margin: EdgeInsets.zero,
            ),
    );
  }
}
