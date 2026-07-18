import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_formatters.dart';
import 'package:mbe_ui/features/pricing/presentation/product_price_row.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The pricing tool (US2, FR-007..FR-013): pick a product, see and edit its
/// price on every price list. Gated by `can(SystemObject.pricing,
/// AccessRight.read)` in the router; row editing further requires `update`
/// (FR-012). Not a record catalog — rows are inline-editable prices, not
/// navigable records, so §VI's row-click/Edit-icon contract does not apply
/// here (spec FR-020a, contracts/routes.md).
///
/// [standalone] renders this as a pushed, full-screen route (its own
/// `Scaffold`/`AppBar`/back button) with the product picker hidden and
/// [initialProductId] locked in, instead of the `/pricing` shell-branch
/// content — used by the product detail screen's "view pricing" shortcut
/// (`/products/:productId/pricing`), which arrives already scoped to one
/// product and has no reason to let it be changed from here.
class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({
    super.key,
    this.initialProductId,
    this.initialProductDisplayText,
    this.standalone = false,
  });

  final int? initialProductId;
  final String? initialProductDisplayText;
  final bool standalone;

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  @override
  void initState() {
    super.initState();
    final productId = widget.initialProductId;
    if (productId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(pricingControllerProvider.notifier)
            .selectProduct(
              productId: productId,
              displayText: widget.initialProductDisplayText ?? '',
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pricingControllerProvider);
    final controller = ref.read(pricingControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(SystemObject.pricing, AccessRight.update);
    final productRepo = ref.read(productRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.standalone)
            SizedBox(
              width: 400,
              child: CatalogEntityPicker<ProductListItem>(
                key: const Key('pricing_product_picker'),
                label: l10n.pricingProductPickerLabel,
                displayStringForOption: (item) =>
                    '${item.code} — ${item.name}',
                optionsBuilder: (query) async {
                  if (query.isEmpty) return const [];
                  final result = await productRepo.list(search: query);
                  return result.items;
                },
                onSelected: (item) => controller.selectProduct(
                  productId: item.productId,
                  displayText: '${item.code} — ${item.name}',
                ),
                initialDisplayText: state.productDisplayText,
              ),
            ),
          if (!widget.standalone) const SizedBox(height: 16),
          Expanded(
            child: state.productId == null
                ? Center(child: Text(l10n.pricingSelectProductPrompt))
                : state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(child: Text(l10n.pricingLoadError(state.error!)))
                : state.rows.isEmpty
                ? Center(child: Text(l10n.pricingNoPriceListsEmptyState))
                : _PricingTable(rows: state.rows, canUpdate: canUpdate),
          ),
        ],
      ),
    );

    if (!widget.standalone) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.productDisplayText ?? l10n.pricingMenuTitle),
      ),
      body: body,
    );
  }
}

class _PricingTable extends ConsumerWidget {
  const _PricingTable({required this.rows, required this.canUpdate});

  final List<ProductPriceRow> rows;
  final bool canUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return DataTableView<ProductPriceRow>(
      key: const Key('pricing_table'),
      columns: [
        DataTableColumn.text(
          label: l10n.columnPriceList,
          text: (row) => row.priceList.name,
          size: ColumnSize.L,
        ),
        DataTableColumn(
          label: l10n.columnPrice,
          numeric: true,
          fixedWidth: 140,
          cellBuilder: (context, row) => row.price == null
              ? Text(
                  l10n.pricingPriceNotSet,
                  key: Key('price_not_set_${row.priceList.priceListId}'),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                )
              : Text(PricingFormatters.currency(row.price!.price)),
        ),
        DataTableColumn(
          label: l10n.columnLowProfit,
          numeric: true,
          fixedWidth: 140,
          cellBuilder: (context, row) => Text(
            row.price == null
                ? '—'
                : PricingFormatters.percent(row.price!.lowProfit),
          ),
        ),
        DataTableColumn(
          label: l10n.columnHighProfit,
          numeric: true,
          fixedWidth: 140,
          cellBuilder: (context, row) => Text(
            row.price == null
                ? '—'
                : PricingFormatters.percent(row.price!.highProfit),
          ),
        ),
        if (canUpdate)
          DataTableColumn(
            label: '',
            fixedWidth: 100,
            cellBuilder: (context, row) => IconButton(
              key: Key('edit_price_button_${row.priceList.priceListId}'),
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editPriceTooltip,
              visualDensity: VisualDensity.compact,
              onPressed: () => _openEditDialog(context, ref, row),
            ),
          ),
      ],
      rows: rows,
    );
  }

  Future<void> _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    ProductPriceRow row,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final priceController = TextEditingController(text: row.price?.price ?? '');
    final lowController = TextEditingController(
      text: row.price?.lowProfit ?? '',
    );
    final highController = TextEditingController(
      text: row.price?.highProfit ?? '',
    );
    Map<String, String> fieldErrors = const {};

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(row.priceList.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('price_edit_price_field'),
                controller: priceController,
                decoration: InputDecoration(
                  labelText: l10n.columnPrice,
                  errorText: fieldErrors['price'] != null
                      ? l10n.pricingInvalidAmountError
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                key: const Key('price_edit_low_profit_field'),
                controller: lowController,
                decoration: InputDecoration(
                  labelText: l10n.columnLowProfit,
                  errorText: fieldErrors['lowProfit'] != null
                      ? l10n.pricingInvalidAmountError
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                key: const Key('price_edit_high_profit_field'),
                controller: highController,
                decoration: InputDecoration(
                  labelText: l10n.columnHighProfit,
                  errorText: fieldErrors['highProfit'] != null
                      ? l10n.pricingInvalidAmountError
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancelPriceEditTooltip),
            ),
            FilledButton(
              key: const Key('price_edit_save_button'),
              onPressed: () async {
                final errors = await ref
                    .read(pricingControllerProvider.notifier)
                    .saveRow(
                      priceListId: row.priceList.priceListId,
                      edit: PricingRowEditState(
                        price: priceController.text,
                        lowProfit: lowController.text,
                        highProfit: highController.text,
                      ),
                    );
                if (errors.isEmpty) {
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                } else {
                  setState(() => fieldErrors = errors);
                }
              },
              child: Text(l10n.savePriceTooltip),
            ),
          ],
        ),
      ),
    );
  }
}
