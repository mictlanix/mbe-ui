import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/product_label_dialog.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/product_labels_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_scaffold.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_label_dropdown.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Productos: the products that have a commission label (spec 078 FR-016,
/// research R10). The endpoint has no text search, so the filter row has no
/// search box; the Etiqueta and Producto facets live in the filter drawer.
/// Server-side paging, 20 a page. "+ Asignar etiqueta" and the row's edit
/// are PUTs (Update); removing the label needs Delete, inside the dialog.
class CommissionProductLabelsSection extends ConsumerStatefulWidget {
  const CommissionProductLabelsSection({super.key});

  @override
  ConsumerState<CommissionProductLabelsSection> createState() =>
      _CommissionProductLabelsSectionState();
}

class _CommissionProductLabelsSectionState
    extends ConsumerState<CommissionProductLabelsSection> {
  /// The Producto facet's display text; the controller only keeps its id.
  String? _productName;

  void _openSheet() {
    final l10n = AppLocalizations.of(context)!;
    showCatalogFilterSheet(
      context,
      title: l10n.filtersButton,
      clearAllLabel: l10n.clearAllFilters,
      applyLabel: l10n.applyFilters,
      onClearAll: () {
        setState(() => _productName = null);
        ref.read(productLabelsControllerProvider.notifier).clearFilters();
      },
      builder: (_) => _FiltersPanel(
        productName: _productName,
        onProductName: (name) => _productName = name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    // Commissions (112) Update: assigning a label is a PUT.
    final canUpdate = access.can(
      SystemObject.commissionsBySalesPerson,
      AccessRight.update,
    );
    final controller = ref.read(productLabelsControllerProvider.notifier);
    final state = ref.watch(productLabelsControllerProvider);
    final filterCount =
        (controller.labelId != null ? 1 : 0) +
        (controller.productId != null ? 1 : 0);
    final labelNames = {
      for (final l in ref.watch(commissionLabelsProvider).value ?? const [])
        l.id: l.name,
    };

    return CommissionSettingsScaffold(
      section: CommissionSettingsSection.products,
      actions: [
        if (canUpdate)
          FilledButton(
            key: const Key('commission_assign_label_button'),
            onPressed: () => showCommissionProductLabelDialog(context),
            child: Text(l10n.commissionAssignLabelAction),
          ),
      ],
      filters: [
        Badge.count(
          count: filterCount,
          isLabelVisible: filterCount > 0,
          child: IconButton.outlined(
            key: const Key('commission_products_filter_button'),
            icon: const Icon(Icons.tune),
            tooltip: l10n.filtersTooltip,
            onPressed: _openSheet,
          ),
        ),
      ],
      body: CatalogListStateView<CommissionProductLabel>(
        state: state.whenData(
          (v) => CatalogPage(
            items: v.page.items,
            total: v.page.total,
            pageIndex: v.pageIndex,
            pageSize: commissionProductLabelsPageSize,
          ),
        ),
        isFiltered: filterCount > 0,
        emptyMessage: l10n.commissionProductLabelsEmpty,
        createLabel: canUpdate ? l10n.commissionAssignLabelAction : null,
        onCreate: canUpdate
            ? () => showCommissionProductLabelDialog(context)
            : null,
        clearFiltersLabel: l10n.clearFiltersButton,
        onClearFilters: () {
          setState(() => _productName = null);
          controller.clearFilters();
        },
        retryLabel: l10n.retryButton,
        onRetry: () => ref.invalidate(productLabelsControllerProvider),
        onData: (page) => DataTableView<CommissionProductLabel>(
          key: const Key('commission_product_labels_table'),
          columns: [
            DataTableColumn.text(
              label: l10n.columnCode,
              size: ColumnSize.S,
              text: (p) => p.productCode,
            ),
            DataTableColumn.text(
              label: l10n.commissionProductLabelProduct,
              size: ColumnSize.L,
              text: (p) => p.productName,
            ),
            DataTableColumn.text(
              label: l10n.commissionProductLabelLabel,
              size: ColumnSize.M,
              text: (p) => labelNames[p.labelId] ?? '#${p.labelId}',
            ),
          ],
          rows: page.items,
          pagination: page,
          onPageChanged: controller.setPage,
          rowActionsBuilder: (context, p) => buildCatalogRowActions(
            editTooltip: l10n.editActionTooltip,
            editKey: Key('commission_product_label_edit_${p.productId}'),
            onEdit: canUpdate
                ? () => showCommissionProductLabelDialog(context, existing: p)
                : null,
          ),
        ),
      ),
    );
  }
}

/// The drawer's Etiqueta and Producto facets. Reads the filters from the
/// controller, so it follows every change.
class _FiltersPanel extends ConsumerWidget {
  const _FiltersPanel({required this.productName, required this.onProductName});

  final String? productName;
  final ValueChanged<String?> onProductName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    // Watched for the rebuild; the filters are the controller's.
    ref.watch(productLabelsControllerProvider);
    final controller = ref.read(productLabelsControllerProvider.notifier);
    return Padding(
      padding: EdgeInsets.all(spacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CommissionLabelDropdown(
            key: const Key('commission_products_label_filter'),
            label: l10n.commissionLabelFilterLabel,
            value: controller.labelId,
            allowClear: true,
            onChanged: controller.setLabel,
          ),
          CatalogEntityPicker<ProductListItem>(
            key: const Key('commission_products_product_filter'),
            label: l10n.commissionProductFilterLabel,
            initialDisplayText: controller.productId == null
                ? null
                : productName,
            displayStringForOption: (p) => p.name,
            optionsBuilder: (query) async {
              final trimmed = query.trim();
              if (trimmed.isEmpty) return const [];
              final result = await ref
                  .read(productRepositoryProvider)
                  .list(
                    search: trimmed,
                    status: EntityStatus.active,
                    limit: 10,
                  );
              return result.items;
            },
            onSelected: (p) {
              onProductName(p.name);
              controller.setProduct(p.productId);
            },
            optionImageUrl: (p) => p.photo,
            optionSubtitle: (p) => p.code,
          ),
        ],
      ),
    );
  }
}
