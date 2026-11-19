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

/// A trip status's `(background, foreground)` pair: neutral (open), info
/// (on the road), success (closed) and muted (cancelled).
(Color, Color) itineraryStatusColors(
  ColorScheme scheme,
  ItineraryStatus status,
) => switch (status) {
  ItineraryStatus.open => (scheme.surfaceContainerHighest, scheme.onSurface),
  ItineraryStatus.departed => (
    scheme.primaryContainer,
    scheme.onPrimaryContainer,
  ),
  ItineraryStatus.closed => (
    scheme.secondaryContainer,
    scheme.onSecondaryContainer,
  ),
  ItineraryStatus.cancelled => (
    scheme.surfaceContainerLow,
    scheme.onSurfaceVariant,
  ),
};

/// A stop outcome's pair: neutral (pending), success (delivered), warning
/// (partially delivered) and error (failed).
(Color, Color) stopOutcomeColors(ColorScheme scheme, StopOutcome outcome) =>
    switch (outcome) {
      StopOutcome.pending => (scheme.surfaceContainerHighest, scheme.onSurface),
      StopOutcome.delivered => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      StopOutcome.partiallyDelivered => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      StopOutcome.failed => (scheme.errorContainer, scheme.onErrorContainer),
    };

/// The trip's status chip, shared by the list and the trip screen. Never
/// truncated: give it the width its label needs.
class ItineraryStatusChip extends StatelessWidget {
  const ItineraryStatusChip({super.key, required this.status});

  final ItineraryStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusChip<ItineraryStatus>(
      key: Key('itinerary_status_chip_${status.name}'),
      value: status,
      label: itineraryStatusLabel(l10n, status),
      colors: (scheme) => itineraryStatusColors(scheme, status),
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
    return StatusChip<StopOutcome>(
      key: Key('stop_outcome_chip_${outcome.name}'),
      value: outcome,
      label: stopOutcomeLabel(l10n, outcome),
      colors: (scheme) => stopOutcomeColors(scheme, outcome),
    );
  }
}
