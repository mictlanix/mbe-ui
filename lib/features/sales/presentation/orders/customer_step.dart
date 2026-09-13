import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/presentation/capture/customer_bar.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_step_controller.dart';

/// The Cliente step (spec 039 FR-009…FR-016; contracts/order-workspace.md
/// §3): a back-office order names its customer before anything else can be
/// worked on. Composes the existing [CustomerBar] rather than a new search
/// surface (research R3) — `excludeGenericCustomer` keeps the walk-in
/// customer out of reach (FR-011, FR-012), `startInSearchMode` shows the
/// picker from the first frame rather than a "Buscar" button to reach it
/// (FR-009's "nothing else to fill in"), and `attachFulfillmentIntent`
/// records the intent to deliver in the very same request that opens the
/// draft (FR-014, FR-015).
///
/// [CustomerBar] itself does the actual attach — through [saleEditorProvider],
/// which this step's host has already overridden to the order's own editor
/// (contracts/shared-step-seam.md §5). Advancing to Venta is this step's own
/// job once that succeeds; [CustomerBar] has no notion of what follows it.
class CustomerStep extends ConsumerWidget {
  const CustomerStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: CustomerBar(
            sale: null,
            excludeGenericCustomer: true,
            startInSearchMode: true,
            attachFulfillmentIntent: FulfillmentMode.delivery,
            onAttached: () =>
                ref.read(orderStepControllerProvider.notifier).advanceToVenta(),
          ),
        ),
      ),
    );
  }
}
