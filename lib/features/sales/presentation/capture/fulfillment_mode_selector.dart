import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_address_picker.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The three-chip Tienda/Domicilio/Mixta control (FR-017), always visible,
/// defaulting to counter pickup.
///
/// Choosing Domicilio or Mixta is guarded twice:
///
/// - the customer must be permitted to receive deliveries, else the reason is
///   shown and the mode is not changed (FR-019);
/// - the sale's **main delivery address** must be named before capture
///   continues (FR-056), picked from the customer's own addresses or created
///   inline, then written to `Sale.shipTo`.
///
/// `shipTo` is what makes the mode survive a reload (FR-057, research §4):
/// the screen holds no persisted mode of its own.
class FulfillmentModeSelector extends ConsumerStatefulWidget {
  const FulfillmentModeSelector({super.key, required this.sale, this.enabled = true});

  final Sale sale;
  final bool enabled;

  @override
  ConsumerState<FulfillmentModeSelector> createState() =>
      _FulfillmentModeSelectorState();
}

class _FulfillmentModeSelectorState extends ConsumerState<FulfillmentModeSelector> {
  AppError? _error;
  String? _refusal;
  bool _busy = false;

  Future<void> _select(FulfillmentMode mode) async {
    setState(() {
      _error = null;
      _refusal = null;
    });

    if (mode == FulfillmentMode.counterPickup) {
      ref.read(posStepControllerProvider.notifier).setMode(mode);
      return;
    }

    // FR-019 — a customer not permitted deliveries cannot use either
    // delivery mode, and is told why rather than silently refused.
    final customer = await ref.read(
      saleCustomerControllerProvider(widget.sale.customer).future,
    );
    if (!mounted) return;
    if (!customer.shipping) {
      setState(() => _refusal = AppLocalizations.of(context)!.posDeliveryNotPermitted);
      return;
    }

    // FR-056 — naming the main delivery address is part of choosing the mode,
    // not a later step.
    final addressId = await showCustomerAddressPicker(
      context,
      customerId: widget.sale.customer,
    );
    if (addressId == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(posSaleControllerProvider.notifier)
          .updateHeader(shipTo: addressId);
      if (mounted) ref.read(posStepControllerProvider.notifier).setMode(mode);
    } on AppError catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final step = ref.watch(posStepControllerProvider);
    final enabled = widget.enabled && !_busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<FulfillmentMode>(
          segments: [
            ButtonSegment(
              value: FulfillmentMode.counterPickup,
              label: Text(l10n.posFulfillmentCounter),
              icon: const Icon(Icons.store_outlined),
            ),
            ButtonSegment(
              value: FulfillmentMode.delivery,
              label: Text(l10n.posFulfillmentDelivery),
              icon: const Icon(Icons.local_shipping_outlined),
            ),
            ButtonSegment(
              value: FulfillmentMode.mixed,
              label: Text(l10n.posFulfillmentMixed),
              icon: const Icon(Icons.call_split),
            ),
          ],
          selected: {step.mode},
          onSelectionChanged: enabled ? (s) => _select(s.first) : null,
        ),
        if (_refusal != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _refusal!,
              key: const Key('pos_delivery_refusal'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ErrorBanner(
              error: _error!,
              onDismiss: () => setState(() => _error = null),
            ),
          ),
      ],
    );
  }
}
