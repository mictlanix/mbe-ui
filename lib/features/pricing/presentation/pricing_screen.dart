import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/product_price_row.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The standalone per-product pricing screen (spec 011 US2, FR-007..FR-013):
/// see and edit one product's price on every price list. Reached only from
/// the product detail screen's "view pricing" shortcut
/// (`/products/:productId/pricing`), which arrives already scoped to one
/// product. Gated by `can(SystemObject.pricing, AccessRight.read)` in the
/// router; row editing further requires `update` (FR-012). Not a record
/// catalog — rows are inline-editable prices, not navigable records, so
/// §VI's row-click/Edit-icon contract does not apply here (spec FR-020a,
/// contracts/routes.md).
///
/// **This is no longer `/pricing` itself.** Spec 033 replaced the
/// product-picker flow this screen used to *also* serve at `/pricing` with
/// `PricingGridScreen`; this screen kept only its pushed, single-product
/// mode (spec 033 research.md §R1, FR-028a).
class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({
    super.key,
    required this.initialProductId,
    this.initialProductDisplayText,
  });

  final int initialProductId;
  final String? initialProductDisplayText;

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(pricingControllerProvider.notifier)
          .selectProduct(
            productId: widget.initialProductId,
            displayText: widget.initialProductDisplayText ?? '',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pricingControllerProvider);
    final controller = ref.read(pricingControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(SystemObject.pricing, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: state.productId == null
                ? Center(child: Text(l10n.pricingSelectProductPrompt))
                : state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? ListFailedView(
                    error: state.error!,
                    retryLabel: l10n.retryButton,
                    onRetry: controller.retry,
                  )
                : state.rows.isEmpty
                ? ListEmptyView(message: l10n.pricingNoPriceListsEmptyState)
                : _PricingTable(rows: state.rows, canUpdate: canUpdate),
          ),
        ],
      ),
    );

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
    final fmt = ref.watch(formattersProvider);
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
              : Text(fmt.display.currency(row.price!.price)),
        ),
        DataTableColumn(
          label: l10n.columnLowProfit,
          numeric: true,
          fixedWidth: 140,
          // fmt.display.percent renders '—' for a null value itself
          // (spec 028 FR-008), so the ternary this cell used to need is gone.
          cellBuilder: (context, row) =>
              Text(fmt.display.percent(row.price?.lowProfit)),
        ),
        DataTableColumn(
          label: l10n.columnHighProfit,
          numeric: true,
          fixedWidth: 140,
          // Same em-dash simplification as lowProfit above.
          cellBuilder: (context, row) =>
              Text(fmt.display.percent(row.price?.highProfit)),
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
