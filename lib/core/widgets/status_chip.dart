import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/semantic_colors.dart';

/// What a status means, independent of any one enum (spec 077 FR-014,
/// contracts/status-tones.md). Each tone owns a pair of theme colors and a
/// default icon, so a status is never told apart by hue alone — important
/// because the Casa Maestra brand is red and an error must not read as brand
/// decoration (FR-015).
///
/// - [neutral]: not started or inert (draft, archived, unknown).
/// - [info]: in progress, moving along.
/// - [warning]: waiting on someone, partial, or needing attention.
/// - [success]: finished as intended.
/// - [error]: cancelled, failed or reversed.
/// - [promo]: merchandising only ("Oferta", "Nuevo"); the one tone that uses
///   the brand accent.
enum StatusTone {
  neutral(Icons.circle_outlined),
  info(Icons.timelapse),
  warning(Icons.schedule),
  success(Icons.check_circle_outline),
  error(Icons.cancel_outlined),
  promo(Icons.local_offer_outlined);

  const StatusTone(this.defaultIcon);

  /// The icon shown when the caller does not pick a more specific one.
  final IconData defaultIcon;

  /// The (background, foreground) pair for this tone in [theme].
  (Color, Color) colors(ThemeData theme) {
    final scheme = theme.colorScheme;
    final semantic = theme.semanticColors;
    return switch (this) {
      StatusTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      StatusTone.info => (scheme.primaryContainer, scheme.onPrimaryContainer),
      StatusTone.warning => (
        semantic.warningContainer,
        semantic.onWarningContainer,
      ),
      StatusTone.success => (
        semantic.successContainer,
        semantic.onSuccessContainer,
      ),
      StatusTone.error => (scheme.errorContainer, scheme.onErrorContainer),
      StatusTone.promo => (
        semantic.accentContainer,
        semantic.onAccentContainer,
      ),
    };
  }
}

/// A status's presentation: its [StatusTone] and, when the tone's default icon
/// does not fit, a more specific icon. Each status family maps its enum to one
/// of these in its own file (spec 077 contracts/status-tones.md).
typedef StatusLook = (StatusTone tone, IconData? icon);

/// The shared status-indicator chip (spec 022 FR-018), replacing the two
/// near-identical `Chip` constructions in `EntityStatusCell` and
/// `CashSessionStatusChip`. It always shows an icon and the status word
/// (spec 077 FR-014). Which [StatusTone] a status maps to stays in each
/// caller's own file — the actual domain knowledge — while this widget owns
/// the shared structural presentation, sourced from `ChipThemeData`.
///
/// Generic over [T] (the status enum) purely so `StatusChip<EntityStatus>`
/// and `StatusChip<CashSessionStatus>` are distinguishable by type in tests
/// (`SC-010`) — [value] itself isn't read during build.
class StatusChip<T> extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.value,
    required this.label,
    required this.tone,
    this.icon,
  });

  final T value;
  final String label;

  /// What the status means; picks the colors and the default icon.
  final StatusTone tone;

  /// Overrides the tone's default icon with one that fits this status.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = tone.colors(Theme.of(context));
    return Chip(
      avatar: Icon(icon ?? tone.defaultIcon, size: 16, color: foreground),
      label: Text(label),
      backgroundColor: background,
      labelStyle: TextStyle(color: foreground),
      visualDensity: VisualDensity.compact,
    );
  }
}
