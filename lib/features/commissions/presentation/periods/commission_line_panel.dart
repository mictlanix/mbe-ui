import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/record_sheet.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_employee_name.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A scheme's localized name (spec 078).
String commissionSchemeLabel(AppLocalizations l10n, CommissionScheme scheme) =>
    switch (scheme) {
      CommissionScheme.fullyPaid => l10n.commissionSchemeFullyPaid,
      CommissionScheme.partialPayments => l10n.commissionSchemePartialPayments,
    };

/// Opens [line] read-only in the shared side panel (spec 078 FR-005a,
/// research R8).
///
/// Not a record surface (§VI): a month line has no record of its own, so
/// there is no Edit, no View toggle and nothing to discard. Every value comes
/// from [line], so it opens for every row. Reading it needs SystemObject 112
/// (`commissionsBySalesPerson`) read, the right the month screen already
/// required.
Future<void> showCommissionLinePanel(
  BuildContext context,
  CommissionLine line,
) => showRecordSheet(
  context,
  title: AppLocalizations.of(
    context,
  )!.commissionLineTitle('${line.salesOrderId}'),
  isDirty: () => false,
  form: (_) => CommissionLinePanel(line: line),
);

/// The read-only body of [showCommissionLinePanel]. Rates go through
/// `formatters.percent` (read-only, research R12), money through `currency`.
class CommissionLinePanel extends ConsumerWidget {
  const CommissionLinePanel({super.key, required this.line});

  final CommissionLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final share = line.share;

    FormGridChild field(String name, Widget value) => FormGridChild(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: theme.textTheme.labelSmall),
          value,
        ],
      ),
    );
    FormGridChild text(String id, String name, String value) =>
        field(name, Text(value, key: Key('commission_line_$id')));

    return Padding(
      key: Key('commission_line_panel_${line.salesOrderDetailId}'),
      padding: EdgeInsets.all(spacing.screenMargin),
      child: ResponsiveFormGrid(
        maxColumns: 2,
        spacing: spacing.fieldGapHorizontal,
        alignment: AlignmentDirectional.centerStart,
        children: [
          text(
            'movement',
            l10n.commissionLineFieldMovement,
            line.movement == CommissionMovement.refund
                ? l10n.commissionRefund
                : l10n.commissionLineFieldSale,
          ),
          text(
            'scheme',
            l10n.commissionLineFieldScheme,
            commissionSchemeLabel(l10n, line.scheme),
          ),
          text(
            'order_date',
            l10n.commissionLineFieldOrderDate,
            fmt.display.date(line.orderDate),
          ),
          text(
            'paid_date',
            l10n.commissionLineFieldPaidDate,
            fmt.display.date(line.paidDate),
          ),
          text('customer', l10n.commissionLineFieldCustomer, line.customerName),
          text('product', l10n.commissionLineFieldProduct, line.productName),
          text(
            'label',
            l10n.commissionLineFieldLabel,
            line.labelName ?? l10n.commissionNoLabel,
          ),
          text(
            'label_rate',
            l10n.commissionLineFieldLabelRate,
            fmt.display.percent(line.labelRate.toString()),
          ),
          text(
            'participation',
            l10n.commissionLineFieldParticipation,
            line.participationName,
          ),
          text(
            'agent_share',
            l10n.commissionLineFieldAgentShare,
            fmt.display.percent(line.participationRate.toString()),
          ),
          text(
            'effective_rate',
            l10n.commissionLineFieldEffectiveRate,
            fmt.display.percent(line.rate.toString()),
          ),
          text(
            'price',
            l10n.commissionLineFieldPrice,
            fmt.display.currency(line.price.toString()),
          ),
          text(
            'quantity',
            l10n.commissionLineFieldQuantity,
            fmt.display.quantity(line.quantity.toString()),
          ),
          text(
            'amount',
            l10n.commissionLineFieldAmount,
            fmt.display.currency(line.total.toString()),
          ),
          text(
            'full_commission',
            l10n.commissionLineFieldFullCommission,
            fmt.display.currency(line.fullCommission.toString()),
          ),
          // Scheme 2 (partial payments) sales only: the share of the full
          // commission this payment earns.
          if (share != null)
            text(
              'paid_percent',
              l10n.commissionLineFieldPaidPercent,
              fmt.display.percent(share.toString()),
            ),
          text(
            'month_commission',
            l10n.commissionLineFieldMonthCommission,
            fmt.display.currency(line.commission.toString()),
          ),
          field(
            l10n.commissionLineFieldOrderSalesperson,
            CommissionEmployeeName(employeeId: line.orderSalespersonId),
          ),
          field(
            l10n.commissionLineFieldCustomerSalesperson,
            CommissionEmployeeName(employeeId: line.customerSalespersonId),
          ),
        ],
      ),
    );
  }
}
