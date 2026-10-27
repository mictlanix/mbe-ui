import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_email_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/unconfirmed_edits_resolver.dart';
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

  /// Opens the quote document, once nothing this screen is still saving or
  /// holding unconfirmed can make it differ from what is on screen (spec 053
  /// FR-005) — `OrderHeaderPanel._viewPedido`'s own rule. The button is
  /// disabled while a write is in flight, so what is left to settle here is
  /// typed-but-unconfirmed text, through the prompt the screen already shows
  /// before it confirms. "Seguir editando" cancels.
  Future<void> _viewDocument() async {
    final title = AppLocalizations.of(
      context,
    )!.documentSalesQuoteTitle(widget.sale.id.toString().padLeft(8, '0'));
    final quoteId = widget.sale.id;
    final proceed = await resolveUnconfirmedEdits(
      context,
      ref,
      ref.read(saleWritesScopeProvider),
    );
    if (!proceed || !mounted) return;
    await ref
        .read(documentActionsProvider)
        .preview(
          context,
          DocumentRef(
            kind: DocumentKind.salesQuote,
            recordId: quoteId,
            title: title,
          ),
        );
  }

  /// Opens the email dialog and acts on how it ended (spec 053 FR-012,
  /// FR-014). Everything the screen needs afterwards is captured first, since
  /// this widget may not outlive the dialog.
  Future<void> _emailQuote() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final editor = ref.read(saleEditorProvider);
    final outcome = await showQuoteEmailDialog(context, quote: widget.sale);
    switch (outcome) {
      case QuoteEmailSent(:final receipt):
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.salesQuoteEmailSentMessage(receipt.recipients.join(', ')),
            ),
          ),
        );
      // The quote is no longer confirmed: re-read it, so the screen shows what
      // the server now holds (and the email action goes away). The screen
      // overrides `saleEditorProvider` with its own controller.
      case QuoteEmailStaleQuote():
        if (editor is QuoteEditorController) await editor.refresh();
      case null:
        break;
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

  String _statusLabel(AppLocalizations l10n, SaleStatus status) =>
      switch (status) {
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
              Divider(
                height: spacing.lg,
                color: theme.colorScheme.outlineVariant,
              ),
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
    final access = ref.watch(accessControlProvider);
    final canViewDocument = canOpenDocument(access, DocumentKind.salesQuote);
    // FR-006: only a confirmed quote is sendable; the server refuses the rest
    // with a 409, so the client does not offer it. Expiry is no obstacle.
    final canEmail =
        access.can(SystemObject.salesQuotes, AccessRight.read) &&
        sale.status == SaleStatus.completed;
    final writesPending =
        ref.watch(pendingWritesProvider(ref.watch(saleWritesScopeProvider))) >
        0;

    final detailsToggle = TextButton.icon(
      key: const Key('sales_quote_more_details_toggle'),
      onPressed: () => setState(() => _expanded = !_expanded),
      label: Text(
        _expanded ? l10n.salesQuoteFewerDetails : l10n.salesQuoteMoreDetails,
      ),
      icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
      iconAlignment: IconAlignment.end,
    );

    return FactStripRow(
      // "Ver cotización", "Enviar por correo" and "Más detalles" must stay
      // on one line (constitution §VI control band): the facts wrap instead.
      trailingMaxShare: 0.6,
      facts: [
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
        // Spec 049 FR-005: a multi-currency control.
        if (ref.watch(multiCurrencyEnabledProvider))
          CompactField(
            label: l10n.salesQuoteCurrencyLabel,
            // A11: no currency selector — read-only always, edit gate
            // or no edit gate.
            child: Text(_currencyLabel(l10n, sale.currency)),
          ),
      ],
      trailing: !canViewDocument && !canEmail
          ? detailsToggle
          : Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: spacing.sm,
              runSpacing: spacing.xs,
              children: LayoutBreakpoints.isCompact(context)
                  // FR-015a: on a phone the two document actions would stack
                  // above the lines, so they sit behind one menu instead.
                  ? [
                      detailsToggle,
                      _actionsMenu(
                        l10n,
                        canViewDocument: canViewDocument,
                        canEmail: canEmail,
                        writesPending: writesPending,
                      ),
                    ]
                  : [
                      if (canViewDocument)
                        // Not a click outside the text fields, as in
                        // `OrderHeaderPanel`'s Ver pedido (FR-009).
                        TextFieldTapRegion(
                          child: OutlinedButton.icon(
                            key: const Key('sales_quote_view_document_button'),
                            // Held while a write is in flight, so the document
                            // cannot be fetched a moment before the edit it
                            // should show has landed.
                            onPressed: writesPending ? null : _viewDocument,
                            icon: const Icon(Icons.description_outlined),
                            label: Text(l10n.salesQuoteViewDocumentAction),
                          ),
                        ),
                      if (canEmail)
                        OutlinedButton.icon(
                          key: const Key('sales_quote_email_button'),
                          onPressed: _emailQuote,
                          icon: const Icon(Icons.email_outlined),
                          label: Text(l10n.salesQuoteEmailAction),
                        ),
                      detailsToggle,
                    ],
            ),
    );
  }

  /// The compact tier's overflow menu (spec 053 FR-015a): the same actions,
  /// gates, disabled state and handlers as the wide tier's buttons.
  Widget _actionsMenu(
    AppLocalizations l10n, {
    required bool canViewDocument,
    required bool canEmail,
    required bool writesPending,
  }) {
    return MenuAnchor(
      menuChildren: [
        if (canViewDocument)
          MenuItemButton(
            key: const Key('sales_quote_view_document_menu_item'),
            leadingIcon: const Icon(Icons.description_outlined, size: 18),
            onPressed: writesPending ? null : _viewDocument,
            child: Text(l10n.salesQuoteViewDocumentAction),
          ),
        if (canEmail)
          MenuItemButton(
            key: const Key('sales_quote_email_menu_item'),
            leadingIcon: const Icon(Icons.email_outlined, size: 18),
            onPressed: _emailQuote,
            child: Text(l10n.salesQuoteEmailAction),
          ),
      ],
      builder: (context, controller, _) => IconButton(
        key: const Key('sales_quote_more_actions_button'),
        icon: const Icon(Icons.more_vert),
        tooltip: l10n.salesQuoteMoreActionsTooltip,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
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
String _currencyLabel(AppLocalizations l10n, Currency currency) =>
    switch (currency) {
      Currency.mxn => l10n.currencyMxnLabel,
      Currency.usd => l10n.currencyUsdLabel,
      Currency.eur => l10n.currencyEurLabel,
    };
