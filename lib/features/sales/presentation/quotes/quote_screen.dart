import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_header_panel.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/sales_quotes_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_quote_write_scope.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The quote screen (spec 040): **one** step — unlike the register's Venta/
/// Cobro/Entrega or the order workspace's Venta/Entrega, a quote has no
/// second step to advance to. Reached at `/sales/quotes/new` and
/// `/sales/quotes/:quoteId`, top-level sibling routes mirroring
/// `OrderWorkspaceScreen`'s own shape (full-screen, no shell).
///
/// Naming a customer is this screen's own first move, not a screen of its
/// own — `CaptureStep.excludeGenericCustomer` keeps the walk-in customer out
/// of reach, and withholds product capture until a real one is attached
/// (FR-005, FR-007, FR-009).
///
/// Installs the nested `ProviderScope` the shared capture surface reads
/// through (contracts/quote-capture-host.md §1) — all **four** seam
/// providers together, so this screen's writes, unconfirmed edits and
/// confirm failures are never held open, shut, or painted by the register's
/// or the order workspace's own, and vice versa (FR-041, FR-042). Unlike
/// `OrderWorkspaceScreen`, there is no fifth, step-controller override — a
/// quote has no step machine to give one.
class QuoteScreen extends ConsumerWidget {
  const QuoteScreen({super.key, this.quoteId});

  /// `null` for `/sales/quotes/new` — a fresh quote, opened lazily by the
  /// first customer attach (FR-006). Non-null for `/sales/quotes/:quoteId`
  /// — an existing quote to load.
  final int? quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        saleEditorProvider.overrideWith(
          (ref) => ref.watch(quoteEditorControllerProvider(quoteId).notifier),
        ),
        saleWritesScopeProvider.overrideWithValue(salesQuoteWritesScope),
        saleConfirmErrorProvider.overrideWith((ref) => null),
        // No step to return to — unlike the register's and the order
        // workspace's own overrides of this provider, a quote confirm
        // failure simply paints the banner in place; the whole screen is
        // already the one step there is.
        saleConfirmFailureProvider.overrideWith((ref) {
          return (error) =>
              ref.read(saleConfirmErrorProvider.notifier).state = error;
        }),
      ],
      child: _QuoteScreenBody(quoteId: quoteId),
    );
  }
}

class _QuoteScreenBody extends ConsumerStatefulWidget {
  const _QuoteScreenBody({required this.quoteId});

  final int? quoteId;

  @override
  ConsumerState<_QuoteScreenBody> createState() => _QuoteScreenBodyState();
}

class _QuoteScreenBodyState extends ConsumerState<_QuoteScreenBody> {
  /// Whether the `/sales/quotes/new` → `/sales/quotes/<id>` URL rewrite has
  /// already run for this instance — mirrors
  /// `order_workspace_screen.dart`'s own `_rewrittenUrl`.
  bool _rewrittenUrl = false;

  /// Whether a convert, a duplicate or a cancel is in flight — each shows
  /// a spinner and refuses to fire twice, mirroring
  /// `order_workspace_screen.dart`'s own `_cancelling`.
  bool _converting = false;
  bool _duplicating = false;
  bool _cancelling = false;

  /// Once a quote exists under a `/new` mount, the URL is rewritten to its
  /// real id — mirrors `OrderWorkspaceScreen._maybeRewriteUrl`.
  void _maybeRewriteUrl(Sale quote) {
    if (widget.quoteId != null || _rewrittenUrl) return;
    _rewrittenUrl = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GoRouter.of(context).replace('/sales/quotes/${quote.id}');
    });
  }

  Future<void> _confirm() async {
    try {
      await ref.read(saleEditorProvider).confirm();
    } on AppError catch (e) {
      if (mounted) ref.read(saleConfirmFailureProvider)(e);
    }
  }

  /// FR-025–FR-031: converts a confirmed, unexpired quote into a
  /// back-office order. Routed through the seam's own confirm-failure path
  /// on refusal (draft, cancelled, expired, no point of sale) — the same
  /// banner `_confirm` renders to, since this screen has only the one place
  /// to show it.
  Future<void> _convert() async {
    setState(() => _converting = true);
    try {
      final orderId = await ref
          .read(quoteEditorControllerProvider(widget.quoteId).notifier)
          .convert();
      if (mounted) context.go('/sales/orders/$orderId');
    } on AppError catch (e) {
      if (mounted) ref.read(saleConfirmFailureProvider)(e);
    } finally {
      if (mounted) setState(() => _converting = false);
    }
  }

  /// FR-029, FR-033: a new, independent draft re-priced at today's prices.
  /// Wired here for the expired-refusal case (US2 acceptance scenario 5 —
  /// an expired quote's only way forward); US5 widens *where* this is
  /// offered without touching the wiring itself.
  Future<void> _duplicate() async {
    setState(() => _duplicating = true);
    try {
      final newQuoteId = await ref
          .read(quoteEditorControllerProvider(widget.quoteId).notifier)
          .duplicate();
      if (mounted) context.go('/sales/quotes/$newQuoteId');
    } on AppError catch (e) {
      if (mounted) ref.read(saleConfirmFailureProvider)(e);
    } finally {
      if (mounted) setState(() => _duplicating = false);
    }
  }

  /// FR-032: a draft or confirmed quote is cancellable, offered from this
  /// controller's own `cancel()` rather than the shared `SaleEditor`
  /// surface — no other host has an equivalent action.
  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await ref
          .read(quoteEditorControllerProvider(widget.quoteId).notifier)
          .cancel();
      // Bare, so every live list instance re-fetches under its own
      // already-applied filter (research.md R5) — this screen has no
      // opinion on which filter, if any, is currently shown.
      ref.invalidate(salesQuotesListControllerProvider);
    } on AppError catch (e) {
      if (mounted) ref.read(saleConfirmFailureProvider)(e);
      await ref
          .read(quoteEditorControllerProvider(widget.quoteId).notifier)
          .refresh();
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _confirmCancel(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.salesQuoteCancelDialogTitle),
        content: Text(l10n.salesQuoteCancelDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.salesQuoteCancelDialogKeepEditing),
          ),
          FilledButton(
            key: const Key('sales_quote_cancel_confirm_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.salesQuoteCancelDialogConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _cancel();
  }

  /// This quote's document-level actions, rendered as
  /// `CaptureStep.secondaryAction` — the same slot the order workspace's
  /// own Cancel button uses, which renders regardless of `showAction`
  /// (FR-025, FR-029, FR-032, FR-033). Up to three of these can apply to a
  /// single quote at once (a completed, unexpired quote offers Cancel,
  /// Convert *and* Duplicate together) — unlike the order workspace, which
  /// only ever offers one action here — so this combines them in a `Row`
  /// rather than picking one.
  Widget? _secondaryAction(
    AppLocalizations l10n,
    Sale? quote,
    bool canUpdate,
    bool canCreateOrders,
    bool canCreateQuotes,
  ) {
    if (quote == null) return null;
    final canCancel =
        canUpdate &&
        (quote.status == SaleStatus.draft ||
            quote.status == SaleStatus.completed);
    final cancelButton = canCancel
        ? TextButton(
            key: const Key('sales_quote_cancel_button'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _cancelling ? null : () => _confirmCancel(l10n),
            child: _cancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.salesQuoteCancelAction),
          )
        : null;

    // FR-033: every quote is duplicable, in every state — no longer only
    // the expired-refusal's own recovery (T047's original placement; US5
    // widens it here to a general-purpose action).
    final duplicateButton = canCreateQuotes
        ? TextButton(
            key: const Key('sales_quote_duplicate_button'),
            onPressed: _duplicating ? null : _duplicate,
            child: _duplicating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.salesQuoteDuplicateAction),
          )
        : null;

    final convertButton =
        quote.status == SaleStatus.completed &&
            !quote.hasExpired &&
            canCreateOrders
        ? FilledButton(
            key: const Key('sales_quote_convert_button'),
            onPressed: _converting ? null : _convert,
            child: _converting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.salesQuoteConvertAction),
          )
        : null;

    final actions = [?cancelButton, ?duplicateButton, ?convertButton];
    if (actions.isEmpty) return null;
    if (actions.length == 1) return actions.single;
    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  @override
  Widget build(BuildContext context) {
    final quoteAsync = ref.watch(quoteEditorControllerProvider(widget.quoteId));
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(SystemObject.salesQuotes, AccessRight.update);
    final canCreateOrders = access.can(SystemObject.salesOrders, AccessRight.create);
    final canCreateQuotes = access.can(SystemObject.salesQuotes, AccessRight.create);

    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        leading: IconButton(
          key: const Key('sales_quote_screen_back'),
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/sales/quotes'),
        ),
        title: Text(l10n.salesQuotesMenuTitle),
      ),
      body: quoteAsync.when(
        data: (quote) {
          if (quote != null) _maybeRewriteUrl(quote);
          return CaptureStep(
            sale: quote,
            // FR-003: the action is absent, not greyed, for a read-only
            // user — `null` here does exactly that regardless of what
            // SaleTotalsBar's own line-count/write-pending rule would
            // otherwise allow.
            onContinue: canUpdate ? _confirm : null,
            continueLabel: l10n.salesQuoteConfirmAction,
            showFulfillmentSelector: false,
            excludeGenericCustomer: true,
            showWarehouse: false,
            // FR-021, FR-023: gone once confirmed, not greyed out.
            showAction: quote?.isEditable ?? true,
            secondaryAction: _secondaryAction(
              l10n,
              quote,
              canUpdate,
              canCreateOrders,
              canCreateQuotes,
            ),
            headerExtra: quote == null
                ? null
                : QuoteHeaderPanel(sale: quote),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorBanner(
              error: toAppError(error),
              onDismiss: () => ref.invalidate(
                quoteEditorControllerProvider(widget.quoteId),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
