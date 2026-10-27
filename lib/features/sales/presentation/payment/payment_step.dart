import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/applied_payments_panel.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_capture_pane.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_change_card.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_summary_panel.dart';
import 'package:mbe_ui/features/sales/presentation/pos_gate_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The Cobro step (contracts/pos-screen.md §3, spec 025 contracts/
/// payment-surface.md): tender amount, method, reference, applied payments
/// and the money summary. At the Large tier (≥ 1200 px) it is two panes — a
/// capture pane and a fixed-width rail; below that it is one column with the
/// summary and the exit action pinned as a footer band (spec 025 research
/// R1). The close action is gated on a zero balance, or on credit terms
/// (FR-049, FR-051), asked of `PaymentSummaryPanel`'s own read of
/// `PosStepController.canLeavePayment` rather than duplicated here.
class PaymentStep extends ConsumerWidget {
  const PaymentStep({super.key, required this.sale, required this.onClose});

  final Sale sale;

  /// Invoked once the balance gate opens and the cashier closes the step —
  /// the host decides what follows (a delivery step, or a finished sale).
  final VoidCallback onClose;

  /// The rail's fixed width at the two-pane tier — what the mock spends on
  /// its applied-payments column, and what `NumberPad.maxPadWidth` already
  /// establishes as a comfortable fixed column in this product (research
  /// R1).
  static const _railWidth = 360.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(paymentControllerProvider);
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final enabled = !draft.submitting;
    // spec 047 FR-004: payments need a valid cash session. `.value` keeps the
    // previous state while a re-read is in flight, so tiles do not flicker.
    final sessionValid =
        ref.watch(currentSessionControllerProvider).value?.isValid ?? false;

    final issueMessage = switch (draft.issue) {
      PaymentIssue.amountRequired => l10n.posPaymentAmountRequired,
      PaymentIssue.overpayNonCash => l10n.posPaymentOverpayNonCash,
      PaymentIssue.sessionInvalid => l10n.posPaymentSessionInvalid,
      null => null,
    };
    final error = draft.error == null && issueMessage == null
        ? null
        : Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: draft.error != null
                ? ErrorBanner(error: draft.error!)
                : Text(
                    issueMessage!,
                    key: const Key('payment_issue_message'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
          );

    final capturePane = PaymentCapturePane(
      sale: sale,
      enabled: enabled && sessionValid,
    );
    final appliedPayments = AppliedPaymentsPanel(
      saleId: sale.id,
      enabled: enabled,
    );
    final summary = PaymentSummaryPanel(sale: sale, onClose: onClose);
    // spec 047 FR-020: above the summary, not inside the draft's own amount
    // area — the draft is already reset for the next tender by now.
    final changeCard = draft.lastChange == null
        ? null
        : Padding(
            padding: EdgeInsets.all(spacing.sm),
            child: PaymentChangeCard(
              amount: draft.lastChange!,
              onDismiss: ref
                  .read(paymentControllerProvider.notifier)
                  .dismissChange,
            ),
          );

    final wide = MediaQuery.sizeOf(context).width >= LayoutBreakpoints.large;

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Not scrollable: FR-006 reserves scrolling for the
          // applied-payments list alone at this tier — the capture pane
          // stays put, exactly like the rail's header and summary.
          //
          // The screen margin is the *pane's* now, not the whole step's: the
          // rail beside it is a full-bleed plane running edge to edge, so an
          // outer padding would leave it floating inside a gutter instead of
          // meeting the window's own edges.
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(spacing.screenMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PosSessionBlockedBanner(),
                  ?error,
                  capturePane,
                ],
              ),
            ),
          ),
          // The mock's own rail (`background:#131319; border-left:1px solid
          // #23232C`): its own surface a step above the canvas the capture
          // pane sits on, with a hairline stating where one ends and the
          // other begins. The `paneGutter` this replaces separated the two
          // by absence — nothing but empty canvas — which is exactly why the
          // rail read as part of the same plane.
          Container(
            width: _railWidth,
            decoration: BoxDecoration(
              color: theme.elevations.raised.surfaceColor,
              border: Border(
                left: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.sm,
                    spacing.md,
                    spacing.sm,
                    spacing.sm,
                  ),
                  child: Text(
                    l10n.posAppliedPaymentsTitle,
                    style: theme.typeRoles.sectionHeading,
                  ),
                ),
                // The mock's `border-bottom` under the rail title — full
                // bleed, so it reads as the rail's own header rule rather
                // than a divider between two list items.
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                SizedBox(height: spacing.sm),
                // The change card scrolls with the applied payments instead of
                // sitting beside the summary as a fixed band: at the largest
                // text size a fixed card overflowed the rail at 800 px tall
                // (spec 047 T044). It still lands right above the summary.
                Expanded(
                  child: ListView(children: [appliedPayments, ?changeCard]),
                ),
                summary,
              ],
            ),
          ),
        ],
      );
    }

    // Below the Large tier: one column, the mock's phone order — balance and
    // methods first, then the applied payments — with the summary and the
    // exit pinned as a footer band rather than scrolling with the rest
    // (research R1, matching `SaleTotalsBar`'s treatment of the capture
    // step's own footer).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(spacing.screenMargin),
            children: [
              const PosSessionBlockedBanner(),
              ?error,
              capturePane,
              Divider(height: spacing.xl * 2),
              Text(
                l10n.posAppliedPaymentsTitle,
                style: Theme.of(context).typeRoles.sectionHeading,
              ),
              SizedBox(height: spacing.sm),
              appliedPayments,
            ],
          ),
        ),
        ?changeCard,
        summary,
      ],
    );
  }
}
