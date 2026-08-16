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
    required this.currentId,
    this.currentSerial,
    required this.onSelected,
    required this.onStartNew,
  });

  final int pointSale;

  /// The sale in hand: its id, and its folio once mbe-api has assigned one
  /// (FR-040). Both are shown, each labelled — see [_OpenSaleRow]. `null`
  /// before the cashier has started a sale, when the chip carries only the
  /// count of what is open.
  final int? currentId;
  final int? currentSerial;

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
          // The list arrives grouped by status, so a heading goes in wherever
          // the status changes. Saying it once per section beats repeating it
          // on every row: what the cashier needs is which pile a sale is in,
          // and the pile is now visible from its position.
          for (final (index, sale) in sales.indexed) ...[
            if (index == 0 || sales[index - 1].status != sale.status)
              _StatusHeading(status: sale.status),
            MenuItemButton(
              key: Key('open_sale_${sale.id}'),
              onPressed: () => onSelected(sale),
              child: _OpenSaleRow(sale: sale),
            ),
          ],
        const Divider(height: 1),
        MenuItemButton(
          key: const Key('open_sales_new_button'),
          leadingIcon: const Icon(Icons.add),
          onPressed: onStartNew,
          child: Text(l10n.posNewSaleAction),
        ),
      ],
      builder: (context, controller, child) => ActionChip(
        avatar: const Icon(Icons.receipt_long_outlined, size: 18),
        label: Text(_chipLabel(l10n, context, sales.length)),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  /// The sale in hand, labelled the same way the menu rows are: its id, its
  /// folio once assigned, and how many other sales are still open.
  ///
  /// On a phone the count drops — it is repeated inside the menu this chip
  /// opens, and spelling it out here costs width the step indicator needs
  /// (US5, SC-007). The folio stays: it is the number on the customer's
  /// ticket, so it is the one worth the space.
  String _chipLabel(AppLocalizations l10n, BuildContext context, int openCount) {
    final reference = [
      if (currentId case final id?) l10n.posOpenSaleId(id),
      if (currentSerial case final serial?) l10n.posOpenSaleSerial(serial),
    ].join(' · ');

    final count = l10n.posOpenSalesCount(openCount);
    // Nothing started yet: the chip is purely the way in to the open sales,
    // so it says how many there are.
    if (reference.isEmpty) return openCount == 0 ? l10n.posNoOpenSales : count;
    if (openCount == 0 || LayoutBreakpoints.isCompact(context)) return reference;
    return '$reference · $count';
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
                // Both identifiers, each labelled, rather than one bare
                // number whose meaning depends on whether the sale happens to
                // have been confirmed yet: the id is what every sale has, the
                // folio only appears once mbe-api assigns one (FR-040). A
                // list mixing six-digit ids with five-digit folios is
                // unreadable without saying which is which.
                Text(l10n.posOpenSaleId(sale.id)),
                if (sale.serial case final serial?)
                  Text(
                    l10n.posOpenSaleSerial(serial),
                    style: theme.textTheme.labelSmall,
                  ),
                // `customerName` alone used to be read here, which is the
                // per-document override — null on every ordinary sale — so
                // this line was simply absent for almost every entry. It
                // degraded quietly rather than showing a dash, which is why
                // it outlived the same bug on the sales list
                // (mictlanix/mbe-api#172, fixed by #173).
                if (posSaleCustomerLabel(sale) case final name
                    when name != '—')
                  Text(
                    name,
                    style: theme.textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(MoneyFormatters.currency(sale.total)),
        ],
      ),
    );
  }
}

/// The heading over one status section — why every sale beneath it is still
/// open, and therefore where selecting one will land the cashier
/// (contracts/pos-screen.md §5). Said once per section rather than on every
/// row.
class _StatusHeading extends StatelessWidget {
  const _StatusHeading({required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SizedBox(
            width: 360,
            child: Text(
              key: Key('open_sales_heading_${status.name}'),
              _statusLabel(l10n, status),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n, SaleStatus status) => switch (status) {
    SaleStatus.draft => l10n.posOpenSaleDraft,
    SaleStatus.completed => l10n.posOpenSaleUnpaid,
    SaleStatus.paid => l10n.posOpenSaleUndelivered,
    SaleStatus.cancelled => '',
  };
}
