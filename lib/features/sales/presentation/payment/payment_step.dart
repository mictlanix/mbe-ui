import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/payment/applied_payments_panel.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_capture_pane.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_summary_panel.dart';
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
    final spacing = Theme.of(context).spacing;
    final enabled = !draft.submitting;

    final error = draft.error == null
        ? null
        : Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: ErrorBanner(error: draft.error!),
          );

    final capturePane = PaymentCapturePane(sale: sale, enabled: enabled);
    final appliedPayments = AppliedPaymentsPanel(saleId: sale.id, enabled: enabled);
    final summary = PaymentSummaryPanel(sale: sale, onClose: onClose);

    final wide = MediaQuery.sizeOf(context).width >= LayoutBreakpoints.large;

    if (wide) {
      return Padding(
        padding: EdgeInsets.all(spacing.screenMargin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Not scrollable: FR-006 reserves scrolling for the
            // applied-payments list alone at this tier — the capture pane
            // stays put, exactly like the rail's header and summary.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [?error, capturePane],
              ),
            ),
            SizedBox(width: spacing.paneGutter),
            SizedBox(
              width: _railWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.sm),
                    child: Text(
                      l10n.posAppliedPaymentsTitle,
                      style: Theme.of(context).typeRoles.sectionHeading,
                    ),
                  ),
                  Expanded(child: appliedPayments),
                  summary,
                ],
              ),
            ),
          ],
        ),
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
        summary,
      ],
    );
  }
}
