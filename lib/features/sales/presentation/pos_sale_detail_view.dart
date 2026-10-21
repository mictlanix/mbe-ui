import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';
import 'package:mbe_ui/features/sales/presentation/capture/stock_gate.dart';
import 'package:mbe_ui/features/sales/presentation/payment/applied_payments_panel.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sales_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The read-only detail of a fully paid sale (spec 048 FR-010..FR-014,
/// contracts C3): the sale's facts, its lines with the warehouse each is
/// booked from, the totals and the payments applied to it. It offers no edit,
/// payment or cancel action — only the ticket preview.
class PosSaleDetailView extends ConsumerWidget {
  const PosSaleDetailView({super.key, required this.sale});

  final Sale sale;

  /// The payments rail's fixed width at the two-pane tier, as `PaymentStep`.
  static const _railWidth = 360.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final compact = LayoutBreakpoints.isCompact(context);
    final wide = MediaQuery.sizeOf(context).width >= LayoutBreakpoints.large;
    final horizontalInset = EdgeInsets.symmetric(
      horizontal: spacing.screenMargin,
    );

    final facts = Padding(
      padding: horizontalInset.add(EdgeInsets.symmetric(vertical: spacing.sm)),
      child: _Facts(sale: sale),
    );
    final lines = [
      for (final line in sale.lines)
        if (compact)
          Padding(
            padding: horizontalInset,
            child: SaleLineCard(
              key: ValueKey(line.id),
              line: line,
              facilityId: sale.facility,
              enabled: false,
              stockGate: const StockGate(),
            ),
          )
        else
          SaleLineRow(
            key: ValueKey(line.id),
            line: line,
            facilityId: sale.facility,
            enabled: false,
            stockGate: const StockGate(),
          ),
    ];
    final totals = SaleTotalsBar(
      sale: sale,
      compact: compact,
      confirming: false,
      onContinue: null,
      showAction: false,
    );

    return Column(
      key: const Key('pos_sale_detail'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wide)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      facts,
                      Expanded(
                        child: ListView(
                          padding: horizontalInset,
                          children: lines,
                        ),
                      ),
                      totals,
                    ],
                  ),
                ),
                Container(
                  width: _railWidth,
                  decoration: BoxDecoration(
                    color: theme.elevations.raised.surfaceColor,
                    border: Border(
                      left: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: spacing.md),
                    children: [_PaymentsSection(saleId: sale.id)],
                  ),
                ),
              ],
            ),
          )
        else ...[
          Expanded(
            child: ListView(
              children: [
                facts,
                ...lines,
                Padding(
                  padding: horizontalInset.add(
                    EdgeInsets.only(top: spacing.md),
                  ),
                  child: _PaymentsSection(saleId: sale.id),
                ),
              ],
            ),
          ),
          totals,
        ],
      ],
    );
  }
}

class _Facts extends ConsumerWidget {
  const _Facts({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    final auth = ref.watch(authProvider).value;
    final register = auth is AuthAuthenticated
        ? auth.user.settings?.pointSaleName
        : null;

    // The resolved customer's name first: the sale's own `customerName` is
    // only the per-document override (mictlanix/mbe-api#172).
    final customer =
        ref.watch(saleCustomerControllerProvider(sale.customer)).value?.name ??
        sale.customerName ??
        '—';
    // `null` on any failure (e.g. no `employees` read), so the id stands in.
    final salesperson =
        ref.watch(employeeDisplayNameProvider(sale.salesperson)).value ??
        '${sale.salesperson}';

    Widget fact(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.typeRoles.metricLabel),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );

    return Wrap(
      key: const Key('pos_sale_detail_facts'),
      spacing: theme.spacing.lg,
      runSpacing: theme.spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        fact(l10n.posCustomerNameLabel, customer),
        fact(l10n.posSaleDetailDateLabel, fmt.display.dateTime(sale.date)),
        fact(
          l10n.posSaleDetailRegisterLabel,
          register ?? '${sale.pointSale ?? '—'}',
        ),
        fact(l10n.salesOrderSalespersonLabel, salesperson),
        if (canOpenDocument(access, DocumentKind.saleTicket))
          FilledButton.tonalIcon(
            key: const Key('pos_sale_detail_ticket'),
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text(l10n.posSaleViewTicketTooltip),
            onPressed: () => ref
                .read(documentActionsProvider)
                .preview(
                  context,
                  saleTicketRef(l10n, id: sale.id, serial: sale.serial),
                ),
          ),
      ],
    );
  }
}

/// The payments, or why they are not shown. Gated on `customer_payments`
/// read, and the provider is not even watched without it (FR-013); a `403`
/// from the call reads the same way.
class _PaymentsSection extends ConsumerWidget {
  const _PaymentsSection({required this.saleId});

  final int saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final canRead = ref
        .watch(accessControlProvider)
        .can(SystemObject.customerPayments, AccessRight.read);

    final Widget body;
    if (!canRead ||
        _isForbidden(ref.watch(orderPaymentsControllerProvider(saleId)))) {
      body = Padding(
        padding: EdgeInsets.all(spacing.sm),
        child: Text(l10n.posSaleDetailPaymentsForbidden),
      );
    } else {
      body = AppliedPaymentsPanel(
        saleId: saleId,
        enabled: false,
        showChangeAndDate: true,
      );
    }

    return Column(
      key: const Key('pos_sale_detail_payments'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
          child: Text(
            l10n.posAppliedPaymentsTitle,
            style: theme.typeRoles.sectionHeading,
          ),
        ),
        SizedBox(height: spacing.sm),
        body,
      ],
    );
  }

  bool _isForbidden(AsyncValue<Object?> payments) {
    final error = payments.error;
    return error != null &&
        switch (toAppError(error)) {
          ServerError(statusCode: 403) => true,
          _ => false,
        };
  }
}
