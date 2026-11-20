import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A trip status's localized name (spec 075 data-model "Enums").
String itineraryStatusLabel(AppLocalizations l10n, ItineraryStatus status) =>
    switch (status) {
      ItineraryStatus.open => l10n.itineraryStatusOpen,
      ItineraryStatus.departed => l10n.itineraryStatusDeparted,
      ItineraryStatus.closed => l10n.itineraryStatusClosed,
      ItineraryStatus.cancelled => l10n.itineraryStatusCancelled,
    };

/// A stop outcome's localized name.
String stopOutcomeLabel(AppLocalizations l10n, StopOutcome outcome) =>
    switch (outcome) {
      StopOutcome.pending => l10n.itineraryStopOutcomePending,
      StopOutcome.delivered => l10n.itineraryStopOutcomeDelivered,
      StopOutcome.partiallyDelivered =>
        l10n.itineraryStopOutcomePartiallyDelivered,
      StopOutcome.failed => l10n.itineraryStopOutcomeFailed,
    };

/// A shortfall reason's localized name.
String shortfallReasonLabel(AppLocalizations l10n, ShortfallReason reason) =>
    switch (reason) {
      ShortfallReason.customerRefused => l10n.itineraryReasonCustomerRefused,
      ShortfallReason.nobodyPresent => l10n.itineraryReasonNobodyPresent,
      ShortfallReason.wrongAddress => l10n.itineraryReasonWrongAddress,
      ShortfallReason.damagedGoods => l10n.itineraryReasonDamagedGoods,
      ShortfallReason.other => l10n.itineraryReasonOther,
    };

/// A trip status's tone (spec 077): neutral (open), info (on the road),
/// success (closed) and error (cancelled).
StatusLook itineraryStatusLook(ItineraryStatus status) => switch (status) {
  ItineraryStatus.open => (StatusTone.neutral, null),
  ItineraryStatus.departed => (StatusTone.info, Icons.local_shipping_outlined),
  ItineraryStatus.closed => (StatusTone.success, null),
  ItineraryStatus.cancelled => (StatusTone.error, null),
};

/// A stop outcome's tone: neutral (pending), success (delivered), warning
/// (partially delivered) and error (failed).
StatusLook stopOutcomeLook(StopOutcome outcome) => switch (outcome) {
  StopOutcome.pending => (StatusTone.neutral, null),
  StopOutcome.delivered => (StatusTone.success, null),
  StopOutcome.partiallyDelivered => (StatusTone.warning, null),
  StopOutcome.failed => (StatusTone.error, null),
};

/// The trip's status chip, shared by the list and the trip screen. Never
/// truncated: give it the width its label needs.
class ItineraryStatusChip extends StatelessWidget {
  const ItineraryStatusChip({super.key, required this.status});

  final ItineraryStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = itineraryStatusLook(status);
    return StatusChip<ItineraryStatus>(
      key: Key('itinerary_status_chip_${status.name}'),
      value: status,
      label: itineraryStatusLabel(l10n, status),
      tone: tone,
      icon: icon,
    );
  }
}

/// A stop's outcome chip.
class StopOutcomeChip extends StatelessWidget {
  const StopOutcomeChip({super.key, required this.outcome});

  final StopOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = stopOutcomeLook(outcome);
    return StatusChip<StopOutcome>(
      key: Key('stop_outcome_chip_${outcome.name}'),
      value: outcome,
      label: stopOutcomeLabel(l10n, outcome),
      tone: tone,
      icon: icon,
    );
  }
}
