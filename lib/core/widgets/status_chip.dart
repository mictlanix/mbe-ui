import 'package:flutter/material.dart';

/// The shared status-indicator chip (spec 022 FR-018), replacing the two
/// near-identical `Chip` constructions in `EntityStatusCell` and
/// `CashSessionStatusChip` (`labelStyle`/`visualDensity` restated
/// identically in both). Domain-specific colour mapping — which status maps
/// to which `ColorScheme` pair — stays in each caller's own file; this
/// widget only owns the chip's shared structural presentation, sourced from
/// `ChipThemeData` rather than restated per call site.
///
/// Generic over [T] (the status enum) purely so `StatusChip<EntityStatus>`
/// and `StatusChip<CashSessionStatus>` are distinguishable by type in tests
/// (`SC-010`) — [value] itself isn't read during build.
class StatusChip<T> extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.value,
    required this.label,
    required this.colors,
  });

  final T value;
  final String label;

  /// Resolves this status's `(background, foreground)` pair against the
  /// active [ColorScheme]. Kept as a callback rather than plain `Color`
  /// fields so each caller's own `switch` — the actual domain knowledge —
  /// stays in that caller's file, not duplicated here.
  final (Color, Color) Function(ColorScheme scheme) colors;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = colors(scheme);
    return Chip(
      label: Text(label),
      backgroundColor: background,
      labelStyle: TextStyle(color: foreground),
      visualDensity: VisualDensity.compact,
    );
  }
}
