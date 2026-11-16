import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Subtotal, Descuento (only when above 0), IVA and Total (spec 066 C5).
///
/// The breakdown comes from `invoiceAmounts`, which mirrors the server's
/// arithmetic. A draft has no stored XML, so its total is that estimate and
/// reads "Total (estimado)". A sealed, issued or cancelled document shows the
/// server's own total.
class InvoiceTotals extends ConsumerWidget {
  const InvoiceTotals({super.key, required this.document});

  final FiscalDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final amounts = document.amounts;
    final isDraft = document.status == FiscalDocumentStatus.draft;
    final total = isDraft
        ? amounts.total
        : (document.summary.total ?? amounts.total);

    Widget row(String label, String value, {Key? key, TextStyle? style}) => Row(
      key: key,
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style, textAlign: TextAlign.end),
      ],
    );

    String money(Object value) => fmt.display.currency(value.toString());

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        key: const Key('invoice_totals'),
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing.xs,
          children: [
            row(
              l10n.fiscalDocumentTotalSubtotal,
              money(amounts.subtotal),
              key: const Key('invoice_total_subtotal'),
            ),
            if (amounts.discount > Decimal.zero)
              row(
                l10n.fiscalDocumentTotalDiscount,
                money(amounts.discount),
                key: const Key('invoice_total_discount'),
              ),
            row(
              l10n.fiscalDocumentTotalTax,
              money(amounts.taxes),
              key: const Key('invoice_total_tax'),
            ),
            const Divider(height: 1),
            row(
              isDraft
                  ? l10n.fiscalDocumentTotalEstimated
                  : l10n.fiscalDocumentTotalTotal,
              money(total),
              key: const Key('invoice_total_total'),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
