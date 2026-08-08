import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/open_sales_selector_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The register's unfinished sales (FR-004, US3 scenario 1): reference,
/// customer and total, newest first, with a count of how many are open.
///
/// Collapses to a chip that opens a menu, so it costs one control in the
/// header band rather than a list competing with the step content.
class OpenSalesSelector extends ConsumerWidget {
  const OpenSalesSelector({
    super.key,
    required this.pointSale,
    required this.currentReference,
    required this.onSelected,
    required this.onStartNew,
  });

  final int pointSale;

  /// What the header shows for the sale in hand — its folio once assigned,
  /// its provisional id before that (FR-040).
  final String currentReference;

  final ValueChanged<OpenSale> onSelected;
  final VoidCallback onStartNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final openSales = ref.watch(openSalesSelectorControllerProvider(pointSale));
    final sales = openSales.valueOrNull ?? const <OpenSale>[];

    return MenuAnchor(
      key: const Key('open_sales_selector'),
      menuChildren: [
        if (sales.isEmpty)
          MenuItemButton(
            onPressed: null,
            child: Text(l10n.posNoOpenSales),
          )
        else
          for (final sale in sales)
            MenuItemButton(
              key: Key('open_sale_${sale.id}'),
              onPressed: () => onSelected(sale),
              child: _OpenSaleRow(sale: sale),
            ),
        const Divider(height: 1),
        MenuItemButton(
          key: const Key('open_sales_new_button'),
          leadingIcon: const Icon(Icons.add),
          onPressed: onStartNew,
          child: Text(l10n.posNewSaleAction),
        ),
      ],
      // On a phone the chip carries the reference alone: the open-sales count
      // is repeated inside the menu it opens, and spelling it out here costs
      // width the step indicator needs (US5, SC-007).
      builder: (context, controller, child) => ActionChip(
        avatar: const Icon(Icons.receipt_long_outlined, size: 18),
        label: Text(
          sales.isEmpty || LayoutBreakpoints.isCompact(context)
              ? '#$currentReference'
              : '#$currentReference · ${l10n.posOpenSalesCount(sales.length)}',
        ),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

class _OpenSaleRow extends StatelessWidget {
  const _OpenSaleRow({required this.sale});

  final OpenSale sale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      width: 360,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('#${sale.serial ?? sale.id}'),
                Text(
                  sale.customerName ?? '',
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _statusLabel(l10n, sale.status),
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(width: 12),
          Text(MoneyFormatters.currency(sale.total)),
        ],
      ),
    );
  }

  /// Why the sale is still open, which is what tells the cashier where
  /// selecting it will land them (contracts/pos-screen.md §5).
  String _statusLabel(AppLocalizations l10n, SaleStatus status) => switch (status) {
    SaleStatus.draft => l10n.posOpenSaleDraft,
    SaleStatus.completed => l10n.posOpenSaleUnpaid,
    SaleStatus.paid => l10n.posOpenSaleUndelivered,
    SaleStatus.cancelled => '',
  };
}
