import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/form_error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_controller.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_labels.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Copies lines of the invoice that credit note [creditNote] credits onto it
/// (spec 073 C29, FR-004). The clerk checks the lines and sets each quantity,
/// which can't pass the invoiced one; the server takes one line per request,
/// so they are sent in the invoice's order and the run stops at the first
/// refusal (research R1).
///
/// Answers how many lines were added, `0` when none, however the dialog was
/// left: lines added before a refusal stay added.
Future<int> showCopyInvoiceLinesDialog(
  BuildContext context,
  FiscalDocument creditNote,
) async {
  var added = 0;
  await showResponsiveDialog<void>(
    context,
    builder: (_) => _CopyInvoiceLinesDialog(
      creditNote: creditNote,
      onAdded: (count) => added += count,
    ),
  );
  return added;
}

class _CopyInvoiceLinesDialog extends ConsumerStatefulWidget {
  const _CopyInvoiceLinesDialog({
    required this.creditNote,
    required this.onAdded,
  });

  final FiscalDocument creditNote;
  final void Function(int count) onAdded;

  @override
  ConsumerState<_CopyInvoiceLinesDialog> createState() =>
      _CopyInvoiceLinesDialogState();
}

class _CopyInvoiceLinesDialogState
    extends ConsumerState<_CopyInvoiceLinesDialog> {
  /// The quantity field of each invoice line, made when first needed.
  final _quantities = <int, TextEditingController>{};
  final _checked = <int>{};

  /// Lines a refused run had already added: shown as such, never sent twice.
  final _added = <int>{};
  bool _busy = false;
  String? _refusal;

  int get _invoiceId => widget.creditNote.creditedInvoice!.documentId;

  @override
  void dispose() {
    for (final c in _quantities.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(InvoiceLine line) =>
      _quantities.putIfAbsent(
        line.id,
        () => TextEditingController(
          text: ref
              .read(formattersProvider)
              .field
              .quantity(line.quantity.toString()),
        ),
      );

  Decimal? _quantityOf(InvoiceLine line) {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_controller(line).text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  /// Null when the quantity is acceptable, otherwise the text for under it.
  String? _error(AppLocalizations l10n, InvoiceLine line) {
    final quantity = _quantityOf(line);
    if (quantity == null || quantity <= Decimal.zero) {
      return l10n.fiscalDocumentCopyInvoiceLineQtyPositive;
    }
    if (quantity > line.quantity) {
      return l10n.fiscalDocumentCopyInvoiceLineMax(
        ref.read(formattersProvider).display.quantity(line.quantity.toString()),
      );
    }
    return null;
  }

  List<InvoiceLine> _selected(FiscalDocument invoice) => [
    for (final line in invoice.lines)
      if (_checked.contains(line.id)) line,
  ];

  bool _canSubmit(AppLocalizations l10n, FiscalDocument invoice) {
    final selected = _selected(invoice);
    return !_busy &&
        selected.isNotEmpty &&
        selected.every((line) => _error(l10n, line) == null);
  }

  Future<void> _submit(AppLocalizations l10n, FiscalDocument invoice) async {
    if (!_canSubmit(l10n, invoice)) return;
    final navigator = Navigator.of(context);
    final fmt = ref.read(formattersProvider);
    final sent = _selected(invoice);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final result = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .copyInvoiceLines(widget.creditNote.id, [
          for (final line in sent)
            (lineId: line.id, quantity: _quantityOf(line)!),
        ]);
    // Counted whether or not the dialog is still up: the lines are on the
    // credit note either way.
    widget.onAdded(result.added);
    if (!mounted) return;
    final error = result.error;
    if (error == null) {
      navigator.pop();
      return;
    }
    final failed = sent.firstWhere((line) => line.id == result.failedLineId);
    final landed = sent.take(result.added).map((line) => line.id);
    setState(() {
      _busy = false;
      _added.addAll(landed);
      _checked.removeAll(landed);
      _refusal = l10n.fiscalDocumentCopyInvoiceLineFailed(
        failed.productCode?.isNotEmpty == true
            ? failed.productCode!
            : failed.productName,
        error is NetworkError
            ? l10n.fiscalDocumentUnknownResult
            : error.userMessage(l10n, fmt) ?? l10n.fiscalDocumentLoadFailed,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final invoice = ref.watch(fiscalDocumentDetailProvider(_invoiceId));
    final credited = widget.creditNote.creditedInvoice!;
    final folio = credited.serial == null
        ? '#$_invoiceId'
        : '${credited.series ?? ''}${credited.serial}';
    final loaded = invoice.value;

    final Widget content;
    if (invoice.hasError && loaded == null) {
      content = ListFailedView(
        error: toAppError(invoice.error),
        retryLabel: l10n.retryButton,
        onRetry: () => ref.invalidate(fiscalDocumentDetailProvider(_invoiceId)),
      );
    } else if (loaded == null) {
      content = const Center(child: CircularProgressIndicator());
    } else if (loaded.lines.isEmpty) {
      content = KeyedSubtree(
        key: const Key('copy_invoice_lines_empty'),
        child: ListEmptyView(message: l10n.fiscalDocumentCopyInvoiceLinesEmpty),
      );
    } else {
      content = _Lines(
        lines: loaded.lines,
        controller: _controller,
        checked: _checked,
        added: _added,
        busy: _busy,
        errorOf: (line) => _error(l10n, line),
        onChecked: (line, value) => setState(() {
          value ? _checked.add(line.id) : _checked.remove(line.id);
        }),
        onChanged: () => setState(() {}),
      );
    }

    final count = loaded == null ? 0 : _selected(loaded).length;
    return ResponsiveDialog(
      key: const Key('copy_invoice_lines_dialog'),
      title: l10n.fiscalDocumentCopyInvoiceLinesTitle(folio),
      dismissible: !_busy,
      maxWidth: 840,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.fiscalDocumentCopyInvoiceLinesIntro),
          if (_refusal != null)
            FormErrorBanner(
              key: const Key('copy_invoice_lines_refusal'),
              headline: _refusal!,
            ),
          content,
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('copy_invoice_lines_cancel'),
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('copy_invoice_lines_submit'),
        label: l10n.fiscalDocumentCopyInvoiceLinesSubmit(count),
        busy: _busy,
        onPressed: loaded != null && _canSubmit(l10n, loaded)
            ? () => _submit(l10n, loaded)
            : null,
      ),
    );
  }
}

/// The invoice's lines: a table row each on a wide screen, a two-line card on
/// a phone.
class _Lines extends ConsumerWidget {
  const _Lines({
    required this.lines,
    required this.controller,
    required this.checked,
    required this.added,
    required this.busy,
    required this.errorOf,
    required this.onChecked,
    required this.onChanged,
  });

  final List<InvoiceLine> lines;
  final TextEditingController Function(InvoiceLine line) controller;
  final Set<int> checked;
  final Set<int> added;
  final bool busy;
  final String? Function(InvoiceLine line) errorOf;
  final void Function(InvoiceLine line, bool value) onChecked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);

    String quantity(InvoiceLine l) =>
        fmt.display.quantity(l.quantity.toString());
    String money(InvoiceLine l) => fmt.display.currency(l.price.toString());
    String discount(InvoiceLine l) => l.discountRate > Decimal.zero
        ? fmt.display.percent(l.discountRate.toString())
        : '—';

    Widget quantityField(InvoiceLine line) => TextField(
      key: Key('copy_invoice_line_qty_${line.id}'),
      controller: controller(line),
      enabled: checked.contains(line.id) && !busy,
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        labelText: compact ? l10n.fiscalDocumentLineFieldQuantity : null,
      ),
      onChanged: (_) => onChanged(),
    );

    Widget error(InvoiceLine line) {
      final text = checked.contains(line.id) ? errorOf(line) : null;
      if (text == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsetsDirectional.only(top: spacing.xs),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            text,
            key: Key('copy_invoice_line_error_${line.id}'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }

    Widget check(InvoiceLine line) => Checkbox(
      key: Key('copy_invoice_line_check_${line.id}'),
      value: checked.contains(line.id),
      onChanged: busy || added.contains(line.id)
          ? null
          : (v) => onChecked(line, v ?? false),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.sm,
        children: [
          for (final line in lines)
            Card(
              key: Key('copy_invoice_line_${line.id}'),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        check(line),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.productName),
                              Text(
                                '${l10n.fiscalDocumentInvoiceQuantity} '
                                '${quantity(line)} · ${money(line)} · '
                                '${invoiceTaxRateLabel(l10n, line.taxRate)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (added.contains(line.id))
                          Text(l10n.fiscalDocumentCopyInvoiceLineAdded),
                      ],
                    ),
                    if (checked.contains(line.id)) ...[
                      SizedBox(height: spacing.sm),
                      quantityField(line),
                      error(line),
                    ],
                  ],
                ),
              ),
            ),
        ],
      );
    }

    const checkWidth = 48.0;
    const codeWidth = 96.0;
    const numberWidth = 88.0;
    const fieldWidth = 112.0;
    Widget numberCell(String text) => SizedBox(
      width: numberWidth,
      child: Text(text, textAlign: TextAlign.end),
    );
    Widget band(List<Widget> cells, {Key? key}) => Padding(
      key: key,
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: spacing.md,
        children: cells,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle.merge(
          style: theme.textTheme.labelMedium,
          child: band([
            const SizedBox(width: checkWidth),
            SizedBox(
              width: codeWidth,
              child: Text(l10n.fiscalDocumentLineFieldCode),
            ),
            Expanded(child: Text(l10n.fiscalDocumentLineDescription)),
            SizedBox(
              width: numberWidth,
              child: Text(
                l10n.fiscalDocumentInvoiceQuantity,
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: numberWidth,
              child: Text(
                l10n.fiscalDocumentLinePrice,
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: numberWidth,
              child: Text(
                l10n.fiscalDocumentLineDiscount,
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: numberWidth,
              child: Text(l10n.fiscalDocumentLineTax),
            ),
            SizedBox(
              width: fieldWidth,
              child: Text(
                l10n.fiscalDocumentLineQuantity,
                textAlign: TextAlign.end,
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        for (final line in lines)
          Column(
            key: Key('copy_invoice_line_${line.id}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The checkbox, the text cells and the quantity field are one
              // control band: the text and the field share a baseline.
              Padding(
                key: Key('copy_invoice_line_band_${line.id}'),
                padding: EdgeInsets.symmetric(vertical: spacing.xs),
                child: Row(
                  spacing: spacing.md,
                  children: [
                    SizedBox(width: checkWidth, child: check(line)),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        spacing: spacing.md,
                        children: [
                          SizedBox(
                            width: codeWidth,
                            child: Text(
                              line.productCode ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              line.productName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          numberCell(quantity(line)),
                          numberCell(money(line)),
                          numberCell(discount(line)),
                          SizedBox(
                            width: numberWidth,
                            child: Text(
                              invoiceTaxRateLabel(l10n, line.taxRate),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: added.contains(line.id)
                                ? Text(
                                    l10n.fiscalDocumentCopyInvoiceLineAdded,
                                    textAlign: TextAlign.end,
                                  )
                                : quantityField(line),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              error(line),
              const Divider(height: 1),
            ],
          ),
      ],
    );
  }
}
