import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A delivery order status's localized name (spec 061 C11).
String deliveryOrderStatusLabel(
  AppLocalizations l10n,
  DeliveryOrderStatus status,
) => switch (status) {
  DeliveryOrderStatus.draft => l10n.deliveryOrderStatusDraft,
  DeliveryOrderStatus.pendingApproval =>
    l10n.deliveryOrderStatusPendingApproval,
  DeliveryOrderStatus.approved => l10n.deliveryOrderStatusApproved,
  DeliveryOrderStatus.readyForPickup => l10n.deliveryOrderStatusReadyForPickup,
  DeliveryOrderStatus.pickedUp => l10n.deliveryOrderStatusPickedUp,
  DeliveryOrderStatus.inPreparation => l10n.deliveryOrderStatusInPreparation,
  DeliveryOrderStatus.inTransit => l10n.deliveryOrderStatusInTransit,
  DeliveryOrderStatus.delivered => l10n.deliveryOrderStatusDelivered,
  DeliveryOrderStatus.partiallyDelivered =>
    l10n.deliveryOrderStatusPartiallyDelivered,
  DeliveryOrderStatus.failed => l10n.deliveryOrderStatusFailed,
  DeliveryOrderStatus.cancelled => l10n.deliveryOrderStatusCancelled,
};

/// A delivery order type's localized name: "Entrega" or "Recoge en tienda".
String deliveryOrderTypeLabel(AppLocalizations l10n, FulfillmentType type) =>
    switch (type) {
      FulfillmentType.delivery => l10n.deliveryOrderTypeDelivery,
      FulfillmentType.counterPickup => l10n.deliveryOrderTypePickup,
    };

/// A status's tone, by the C11 groups (spec 077 contracts/status-tones.md):
/// neutral (draft), warning (needs someone's attention or went partly), info
/// (moving along), success (handed over) and error (failed or cancelled).
StatusLook deliveryOrderStatusLook(DeliveryOrderStatus status) =>
    switch (status) {
      DeliveryOrderStatus.draft => (StatusTone.neutral, Icons.edit_note),
      DeliveryOrderStatus.pendingApproval ||
      DeliveryOrderStatus.partiallyDelivered => (StatusTone.warning, null),
      DeliveryOrderStatus.approved ||
      DeliveryOrderStatus.readyForPickup ||
      DeliveryOrderStatus.inPreparation => (StatusTone.info, null),
      DeliveryOrderStatus.inTransit => (
        StatusTone.info,
        Icons.local_shipping_outlined,
      ),
      DeliveryOrderStatus.pickedUp ||
      DeliveryOrderStatus.delivered => (StatusTone.success, null),
      DeliveryOrderStatus.failed ||
      DeliveryOrderStatus.cancelled => (StatusTone.error, null),
    };

/// The order's status chip, shared by the list and the detail screen. Never
/// truncated: give it the width its label needs.
class DeliveryOrderStatusChip extends StatelessWidget {
  const DeliveryOrderStatusChip({super.key, required this.status});

  final DeliveryOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = deliveryOrderStatusLook(status);
    return StatusChip<DeliveryOrderStatus>(
      key: Key('delivery_order_status_chip_${status.name}'),
      value: status,
      label: deliveryOrderStatusLabel(l10n, status),
      tone: tone,
      icon: icon,
    );
  }
}
