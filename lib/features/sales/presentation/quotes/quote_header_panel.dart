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
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The quote's own header fields (spec 040 FR-020, FR-022, FR-024) —
/// everything the shared `CustomerBar` does not already show. Rendered
/// through `CaptureStep`'s `headerExtra` slot, the same seam
/// `OrderHeaderPanel` uses for orders.
///
/// Deliberately smaller than `OrderHeaderPanel`: a quote has one editable
/// field beyond payment terms (which `CustomerBar` already owns) plus a
/// comment, so there is no disclosed group to open — everything here is
/// always visible.
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
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
          spacing: spacing.sm,
          children: [
            if (_error != null)
              ErrorBanner(
                error: _error!,
                onDismiss: () => setState(() => _error = null),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    // FR-022: a draft has no folio yet — the provisional
                    // reference stands in for it, exactly as it does on the
                    // order screen.
                    sale.serial?.toString() ??
                        '#${sale.provisionalReference}',
                    style: theme.typeRoles.timestamp,
                  ),
                ),
                if (sale.hasExpired)
                  Icon(
                    Icons.event_busy,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
              ],
            ),
            ResponsiveFormGrid(
              alignment: AlignmentDirectional.centerStart,
              children: [
                FormGridChild(
                  CompactField(
                    label: l10n.salesQuoteReferenceLabel,
                    child: Text(_statusLabel(l10n, sale.status)),
                  ),
                ),
                FormGridChild(
                  CompactField(
                    label: l10n.salesQuoteCurrencyLabel,
                    // A11: no currency selector — read-only always, edit
                    // gate or no edit gate.
                    child: Text(_currencyLabel(l10n, sale.currency)),
                  ),
                ),
                FormGridChild(
                  CompactField(
                    label: l10n.salesQuoteExpiryLabel,
                    editable: canEdit,
                    enabled: canEdit,
                    onTap: canEdit ? _pickExpiry : null,
                    child: Text(fmt.display.dateTime(sale.dueDate)),
                  ),
                ),
                FormGridChild(
                  CompactField(
                    label: l10n.salesQuoteCommentLabel,
                    fillWidth: true,
                    child: ConfirmableTextField(
                      key: const Key('sales_quote_comment_field'),
                      controller: _commentController,
                      enabled: canEdit,
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
