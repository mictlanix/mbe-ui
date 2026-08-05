import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The three-chip Tienda/Domicilio/Mixta control (FR-017), always visible,
/// defaulting to counter pickup. In this phase (US1) only Tienda is wired —
/// selecting it sets `PosStepController.mode` back to counter pickup.
/// Domicilio/Mixta render but are inert (disabled) until US2 (T067) adds the
/// customer-shipping check, the main-address requirement (FR-056) and the
/// `Sale.shipTo` write.
class FulfillmentModeSelector extends ConsumerWidget {
  const FulfillmentModeSelector({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final step = ref.watch(posStepControllerProvider);
    return SegmentedButton<FulfillmentMode>(
      segments: [
        ButtonSegment(
          value: FulfillmentMode.counterPickup,
          label: Text(l10n.posFulfillmentCounter),
          icon: Icon(Icons.store_outlined),
        ),
        ButtonSegment(
          value: FulfillmentMode.delivery,
          label: Text(l10n.posFulfillmentDelivery),
          icon: Icon(Icons.local_shipping_outlined),
          enabled: false,
        ),
        ButtonSegment(
          value: FulfillmentMode.mixed,
          label: Text(l10n.posFulfillmentMixed),
          icon: Icon(Icons.call_split),
          enabled: false,
        ),
      ],
      selected: {step.mode},
      onSelectionChanged: enabled
          ? (selection) =>
                ref.read(posStepControllerProvider.notifier).setMode(selection.first)
          : null,
    );
  }
}
