import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/sales_quote_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The quote's own header fields (spec 040 FR-020, FR-022, FR-024) —
/// everything the shared `CustomerBar` does not already show. Rendered
/// through `CaptureStep`'s `headerExtra` slot, the same seam
/// `OrderHeaderPanel` uses for orders.
///
/// Shaped after `OrderHeaderPanel`'s own fact-strip-plus-disclosure design
/// (spec 032 FR-001) for consistency between the two screens: a read-only
/// fact strip — reference, status, date, expiry (this screen's own "promise
/// date") and currency, since none of these five are ever anything but a
/// fact here — with the disclosure control on its trailing edge; the
/// comment, the one field genuinely typed into, sits behind it, closed on
/// arrival (2026-09-26 correction — the original one-row-plus-grid layout
/// mislabelled its own reference field with the status value; currency
/// moved back out of the disclosure once the comment was the only field
/// left there).
///
/// [canEdit] is `can(salesQuotes, update) && sale.isEditable` (constitution
/// §IV, FR-003) — every editable control is absent that gate without it,
/// never merely disabled.
class QuoteHeaderPanel extends ConsumerStatefulWidget {
  const QuoteHeaderPanel({super.key, required this.sale});

  final Sale sale;

  @override
  ConsumerState<QuoteHeaderPanel> createState() => _QuoteHeaderPanelState();
}

class _QuoteHeaderPanelState extends ConsumerState<QuoteHeaderPanel> {
  AppError? _error;

  /// Closed on arrival, per-visit only — mirrors `OrderHeaderPanel`'s own
  /// `_expanded` (spec 032 FR-005).
  bool _expanded = false;

  late final ConfirmableFieldController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = ConfirmableFieldController(
      value: widget.sale.comment ?? '',
      parse: (text) => text,
      commit: _commitComment,
      unconfirmedEdits: ref.read(
        unconfirmedEditsProvider(ref.read(saleWritesScopeProvider)).notifier,
      ),
    );
  }

  @override
  void didUpdateWidget(QuoteHeaderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sale.comment != widget.sale.comment) {
      _commentController.sync(value: widget.sale.comment ?? '');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<bool> _commitComment(String value) async {
    try {
      await ref
          .read(saleEditorProvider)
          .updateHeader(comment: value.isEmpty ? null : value);
      return true;
    } on AppError catch (e) {
      if (mounted) setState(() => _error = e);
      return false;
    }
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final dueDate = widget.sale.dueDate;
    // An expired quote's due date is, by definition, in the past
    // (hasExpired == dueDate < now) — `showDatePicker` asserts its
    // `initialDate` is never before `firstDate`, so `firstDate` must widen
    // to include it rather than assuming "today" is always the earliest
    // relevant date.
    final firstDate = dueDate.isBefore(now) ? dueDate : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    try {
      await ref.read(saleEditorProvider).updateHeader(promiseDate: picked);
    } on AppError catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  String _statusLabel(AppLocalizations l10n, SaleStatus status) => switch (status) {
    SaleStatus.draft => l10n.salesQuoteStatusDraft,
    SaleStatus.completed => l10n.salesQuoteStatusCompleted,
    SaleStatus.cancelled => l10n.salesQuoteStatusCancelled,
    // A quote never reaches `paid` (data-model.md §1) — this arm exists
    // only so the switch is exhaustive.
    SaleStatus.paid => l10n.salesQuoteStatusCompleted,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final sale = widget.sale;
    final access = ref.watch(accessControlProvider);
    final canEdit =
        access.can(SystemObject.salesQuotes, AccessRight.update) &&
        sale.isEditable;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(spacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerRow(context, sale, canEdit),
            // FR-007-equivalent (order_header_panel.dart): the disclosed
            // group reads as a group, not as more of the same row.
            if (_expanded) ...[
              Divider(height: spacing.lg, color: theme.colorScheme.outlineVariant),
              _disclosedGroup(context, canEdit),
            ],
            if (_error != null) ...[
              SizedBox(height: spacing.sm),
              ErrorBanner(
                error: _error!,
                onDismiss: () => setState(() => _error = null),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The panel's one always-visible row (mirrors `OrderHeaderPanel.
  /// _headerRow`): the three facts that cannot be typed into — reference,
  /// status, date — followed by expiry, this screen's own "always relevant"
  /// field (`OrderHeaderPanel`'s equivalent is promise date), with the
  /// disclosure control on the trailing edge. FR-024/FR-037: the expired
  /// marker sits beside the status value, never folded into it.
  Widget _headerRow(BuildContext context, Sale sale, bool canEdit) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Wrap(
            spacing: spacing.lg,
            runSpacing: spacing.sm,
            children: [
              CompactField(
                label: l10n.salesQuoteReferenceLabel,
                child: Text(
                  // FR-022: a draft has no folio yet — the provisional
                  // reference stands in for it, exactly as it does on the
                  // order screen.
                  sale.serial?.toString() ?? '#${sale.provisionalReference}',
                  style: theme.typeRoles.recordId,
                ),
              ),
              CompactField(
                label: l10n.salesQuoteStatusLabel,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_statusLabel(l10n, sale.status)),
                    if (sale.hasExpired) ...[
                      SizedBox(width: spacing.xs),
                      SalesQuoteExpiredMarker(hasExpired: sale.hasExpired),
                    ],
                  ],
                ),
              ),
              CompactField(
                label: l10n.salesQuoteDateLabel,
                child: Text(fmt.display.dateTime(sale.date)),
              ),
              CompactField(
                label: l10n.salesQuoteExpiryLabel,
                editable: canEdit,
                enabled: canEdit,
                onTap: canEdit ? _pickExpiry : null,
                child: Text(fmt.display.dateTime(sale.dueDate)),
              ),
              CompactField(
                label: l10n.salesQuoteCurrencyLabel,
                // A11: no currency selector — read-only always, edit gate
                // or no edit gate.
                child: Text(_currencyLabel(l10n, sale.currency)),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        // Flexible, not fixed: expanding swaps this label for the longer
        // "Menos detalles" (mirrors `OrderHeaderPanel`'s own reasoning).
        Flexible(
          child: TextButton.icon(
            key: const Key('sales_quote_more_details_toggle'),
            onPressed: () => setState(() => _expanded = !_expanded),
            label: Text(
              _expanded ? l10n.salesQuoteFewerDetails : l10n.salesQuoteMoreDetails,
            ),
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            iconAlignment: IconAlignment.end,
          ),
        ),
      ],
    );
  }

  /// The comment — the one field this screen has beyond the always-visible
  /// strip, closed on arrival. Currency moved into the strip itself (it is
  /// never more than a fact here — A11, no selector, edit gate or no edit
  /// gate) once this was the only field left behind the disclosure.
  ///
  /// Mirrors `OrderHeaderPanel`'s own comment field exactly: no
  /// `CompactField` caption — the label lives on the field itself via
  /// `InputDecoration.labelText`, since a genuinely typed-into control reads
  /// as one control, not a fact plus a box stapled under it.
  Widget _disclosedGroup(BuildContext context, bool canEdit) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveFormGrid(
      alignment: AlignmentDirectional.centerStart,
      children: [
        FormGridChild(
          ConfirmableTextField(
            controller: _commentController,
            enabled: canEdit,
            fieldKey: const Key('sales_quote_comment_field'),
            decoration: InputDecoration(labelText: l10n.salesQuoteCommentLabel),
          ),
          span: FormGridSpan.full,
        ),
      ],
    );
  }
}

/// Same shared keys `order_header_panel.dart`'s own `_currencyLabel` reads
/// (`currencyMxnLabel`/`currencyUsdLabel`/`currencyEurLabel`).
String _currencyLabel(AppLocalizations l10n, Currency currency) => switch (currency) {
  Currency.mxn => l10n.currencyMxnLabel,
  Currency.usd => l10n.currencyUsdLabel,
  Currency.eur => l10n.currencyEurLabel,
};
