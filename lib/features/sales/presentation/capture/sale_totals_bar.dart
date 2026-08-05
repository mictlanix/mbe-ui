import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Always-visible summary (FR-028): line count, unit count, subtotal,
/// discount, tax and grand total, all read directly from [Sale] — never
/// recomputed locally (research.md §1).
class SaleTotalsBar extends StatelessWidget {
  const SaleTotalsBar({super.key, required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unitCount = sale.lines.fold(
      Decimal.zero,
      (sum, line) => sum + (Decimal.tryParse(line.quantity) ?? Decimal.zero),
    );
    final discount = subtractAmounts(
      addAmounts(sale.subtotal, sale.taxTotal),
      sale.total,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          _stat(context, l10n.posTotalsCounts(sale.lineCount, unitCount.toString())),
          _stat(context, l10n.posTotalsSubtotal(MoneyFormatters.currency(sale.subtotal))),
          if (!isZeroAmount(discount))
            _stat(context, l10n.posTotalsDiscount(MoneyFormatters.currency(discount))),
          _stat(context, l10n.posTotalsTax(MoneyFormatters.currency(sale.taxTotal))),
          Text(
            l10n.posTotalsTotal(MoneyFormatters.currency(sale.total)),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.bodyMedium);
}
