import 'package:data_table_2/data_table_2.dart' show ColumnSize;
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart'
    show emptyValuePlaceholder;
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The payment a receipt records (spec 074 C37): date, amount, form,
/// operation number, ordering bank, and the customer payment it came from.
class ReceiptPaymentSection extends ConsumerWidget {
  const ReceiptPaymentSection({super.key, required this.document});

  final FiscalDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final canOpenPayment = ref
        .watch(accessControlProvider)
        .can(SystemObject.customerPayments, AccessRight.read);

    Widget fact(String label, String? value, {Key? key}) => CompactField(
      label: label,
      child: Text(
        value == null || value.isEmpty ? emptyValuePlaceholder : value,
        key: key,
      ),
    );

    final amount = document.paymentAmount;
    final sourceId = document.customerPaymentId;
    return Column(
      key: const Key('fiscal_document_receipt_payment'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(
          l10n.fiscalDocumentReceiptPaymentSection,
          style: theme.textTheme.titleMedium,
        ),
        Wrap(
          spacing: spacing.lg,
          runSpacing: spacing.sm,
          children: [
            fact(
              l10n.fiscalDocumentReceiptPaymentDate,
              document.paymentDate == null
                  ? null
                  : fmt.display.date(document.paymentDate),
              key: const Key('fiscal_document_receipt_payment_date'),
            ),
            fact(
              l10n.fiscalDocumentReceiptPaymentAmount,
              amount == null ? null : fmt.display.currency(amount.toString()),
              key: const Key('fiscal_document_receipt_payment_amount_value'),
            ),
            fact(
              l10n.fiscalDocumentReceiptPaymentForm,
              paymentMethodLabel(l10n, document.paymentForm),
              key: const Key('fiscal_document_receipt_payment_form'),
            ),
            fact(
              l10n.fiscalDocumentReceiptOperationNumber,
              document.paymentReference,
              key: const Key('fiscal_document_receipt_operation_number'),
            ),
            fact(
              l10n.fiscalDocumentReceiptOrderingBank,
              document.orderingBank,
              key: const Key('fiscal_document_receipt_ordering_bank'),
            ),
            if (sourceId != null)
              CompactField(
                label: l10n.fiscalDocumentReceiptSourcePayment,
                child: canOpenPayment
                    ? TextButton(
                        key: const Key(
                          'fiscal_document_receipt_source_payment',
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: AlignmentDirectional.centerStart,
                        ),
                        onPressed: () =>
                            context.push('$paymentsPath/$sourceId'),
                        child: Text(
                          l10n.fiscalDocumentReceiptSourcePaymentValue(
                            sourceId,
                          ),
                        ),
                      )
                    : Text(
                        l10n.fiscalDocumentReceiptSourcePaymentValue(sourceId),
                        key: const Key(
                          'fiscal_document_receipt_source_payment',
                        ),
                      ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The invoices a receipt pays (spec 074 C37). Each control is a nullable
/// callback: `null` leaves it out of the tree (never disabled).
class PaidInvoicesSection extends ConsumerWidget {
  const PaidInvoicesSection({
    super.key,
    required this.document,
    this.onAdd,
    this.onEdit,
    this.onRemove,
  });

  final FiscalDocument document;
  final VoidCallback? onAdd;
  final void Function(PaidInvoice paid)? onEdit;
  final void Function(PaidInvoice paid)? onRemove;

  List<Widget> _actions(AppLocalizations l10n, PaidInvoice paid) {
    final edit = onEdit;
    final remove = onRemove;
    if (edit == null || remove == null) return const [];
    return buildCatalogRowActions(
      editTooltip: l10n.fiscalDocumentPaidInvoiceEditTooltip,
      editKey: Key('fiscal_document_paid_invoice_edit_${paid.relationId}'),
      onEdit: () => edit(paid),
      extraActions: [
        CatalogRowAction(
          key: Key('fiscal_document_paid_invoice_remove_${paid.relationId}'),
          icon: Icons.delete_outline,
          tooltip: l10n.fiscalDocumentPaidInvoiceRemoveTooltip,
          onPressed: () => remove(paid),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final paidInvoices = document.paidInvoices;

    String money(Object v) => fmt.display.currency(v.toString());
    Widget link(PaidInvoice p) => TextButton(
      key: Key('fiscal_document_paid_invoice_link_${p.relationId}'),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: AlignmentDirectional.centerStart,
      ),
      onPressed: () => context.push('$fiscalDocumentsPath/${p.invoiceId}'),
      child: Text(p.folioLabel),
    );

    final Widget table;
    if (paidInvoices.isEmpty) {
      table = Text(
        l10n.fiscalDocumentPaidInvoicesEmpty,
        key: const Key('fiscal_document_paid_invoices_empty'),
      );
    } else if (LayoutBreakpoints.isCompact(context)) {
      table = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final p in paidInvoices) ...[
            Padding(
              key: Key('fiscal_document_paid_invoice_${p.relationId}'),
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.xs,
                children: [
                  Row(
                    spacing: spacing.sm,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: link(p),
                        ),
                      ),
                      ..._actions(l10n, p),
                    ],
                  ),
                  Wrap(
                    spacing: spacing.md,
                    runSpacing: spacing.xs,
                    children: [
                      for (final text in [
                        '${l10n.fiscalDocumentPaidInvoicesColumnInstallment} '
                            '${p.installment}',
                        '${l10n.fiscalDocumentPaidInvoicesColumnPreviousBalance} '
                            '${money(p.previousBalance)}',
                        '${l10n.fiscalDocumentPaidInvoicesColumnAmount} '
                            '${money(p.amount)}',
                        '${l10n.fiscalDocumentPaidInvoicesColumnRemaining} '
                            '${money(p.remaining)}',
                      ])
                        Text(text, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      );
    } else {
      table = DataTableView<PaidInvoice>(
        key: const Key('fiscal_document_paid_invoices_table'),
        shrinkWrap: true,
        margin: EdgeInsets.zero,
        rows: paidInvoices,
        rowActionsBuilder: onEdit == null
            ? null
            : (context, p) => _actions(l10n, p),
        columns: [
          DataTableColumn(
            label: l10n.fiscalDocumentPaidInvoicesColumnInvoice,
            size: ColumnSize.S,
            cellBuilder: (context, p) => Align(
              key: Key('fiscal_document_paid_invoice_${p.relationId}'),
              alignment: AlignmentDirectional.centerStart,
              child: link(p),
            ),
          ),
          DataTableColumn.text(
            label: l10n.fiscalDocumentPaidInvoicesColumnUuid,
            size: ColumnSize.L,
            text: (p) => p.stampUuid ?? emptyValuePlaceholder,
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentPaidInvoicesColumnInstallment,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, p) => Text('${p.installment}'),
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentPaidInvoicesColumnPreviousBalance,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, p) => Text(money(p.previousBalance)),
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentPaidInvoicesColumnAmount,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, p) => Text(money(p.amount)),
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentPaidInvoicesColumnRemaining,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, p) => Text(money(p.remaining)),
          ),
        ],
      );
    }

    return Column(
      key: const Key('fiscal_document_paid_invoices'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.fiscalDocumentPaidInvoicesSection,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (onAdd != null)
              Flexible(
                child: OutlinedButton.icon(
                  key: const Key('fiscal_document_add_paid_invoice'),
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.fiscalDocumentAddPaidInvoiceAction),
                ),
              ),
          ],
        ),
        table,
      ],
    );
  }
}

/// Payment amount, what the paid invoices add up to, and what is left to
/// assign (spec 074 C39). It stands where an invoice's totals would be.
class ReceiptPaymentSummary extends ConsumerWidget {
  const ReceiptPaymentSummary({super.key, required this.document});

  final FiscalDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final isDraft = document.status == FiscalDocumentStatus.draft;
    final amount = document.paymentAmount;
    final unassigned = document.unassignedAmount;
    // Draft only: a sealed receipt has been checked by the server already.
    final mismatch =
        isDraft && (unassigned == null || unassigned != Decimal.zero);

    String money(Object? v) =>
        v == null ? emptyValuePlaceholder : fmt.display.currency(v.toString());
    Widget row(String label, String value, {Key? key, TextStyle? style}) => Row(
      key: key,
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style, textAlign: TextAlign.end),
      ],
    );

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        key: const Key('fiscal_document_receipt_summary'),
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing.xs,
          children: [
            row(
              l10n.fiscalDocumentReceiptSummaryPayment,
              money(amount),
              key: const Key('fiscal_document_receipt_summary_payment_amount'),
            ),
            row(
              l10n.fiscalDocumentReceiptSummaryAssigned,
              money(document.assignedAmount),
              key: const Key('fiscal_document_receipt_summary_assigned'),
            ),
            const Divider(height: 1),
            row(
              l10n.fiscalDocumentReceiptSummaryUnassigned,
              money(unassigned),
              key: const Key('fiscal_document_receipt_summary_unassigned'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: mismatch ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
