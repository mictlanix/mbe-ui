import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';

/// What a [CompactField] offers to do when tapped, drawn on its trailing edge
/// (spec 037 FR-016e). A converted field has no outlined box left to say it is
/// editable, so the affordance carries that on its own.
enum CompactFieldAffordance {
  /// Nothing — a read-only value, or a field whose value already fills the
  /// column (the date fields, whose formatted date-time an affordance pushes
  /// into an ellipsis at the compact tier).
  none,

  /// Opens a menu in place.
  dropdown,

  /// Opens a picker elsewhere.
  picker,
}

/// A caption over a dense value or control, with optional supporting text
/// beneath — the shape spec 037 standardises the order header stack on
/// (FR-016, FR-016a; data-model.md §4).
///
/// It replaces the labelled outlined box for every field that is not typed
/// into. That box is an affordance for typing, and dressing a read-only value
/// or a picker launcher as one both misleads and costs roughly twice the
/// height: research R5 found a `ResponsiveFormGrid` run is as tall as its
/// tallest child, so one surviving box pins its whole row.
///
/// Deliberately **not** sized: it fills whatever width its parent gives it, so
/// a `DropdownButton` inside it needs `isExpanded: true` rather than a fixed
/// width. `CustomerBar`'s own terms control carried a hard-coded 132px for a
/// dropdown auto-sizing quirk; carried into a grid cell narrower than that,
/// the fixed width overflows instead of shrinking (research R7).
class CompactField extends StatelessWidget {
  const CompactField({
    super.key,
    required this.label,
    required this.child,
    this.supportingText,
    this.affordance = CompactFieldAffordance.none,
    this.enabled = true,
    this.onTap,
    this.fillWidth = false,
  });

  /// Rendered through `typeRoles.metricLabel` — sentence case, never
  /// uppercased (FR-016d). One caption rule for every field on the screen.
  final String label;

  /// The value or control. A `Text` for a read-only value; a dropdown, picker
  /// or field for an editable one.
  final Widget child;

  /// The slot the terms control uses for its credit limit and its "no credit
  /// line" hint. Same treatment as [label].
  final String? supportingText;

  final CompactFieldAffordance affordance;

  /// Dims the caption and the affordance to the disabled convention, and
  /// suppresses [onTap]. The child governs its own enabled rendering.
  final bool enabled;

  /// For a field whose child is not itself tappable — a picker launcher whose
  /// child is a plain `Text`. A child that handles its own gestures (a
  /// dropdown) leaves this null.
  final VoidCallback? onTap;

  /// Whether the value row fills the width its parent gives it.
  ///
  /// `false` (the default) shrink-wraps, which is what the header row's `Wrap`
  /// needs — an expanding row there claims the whole line and puts every field
  /// on one of its own.
  ///
  /// `true` is for a **bounded** parent — a grid cell, or a `SizedBox` — where
  /// the child must be held to the space left after the affordance. A child
  /// that reports no natural width of its own (a text field, which will happily
  /// take everything offered) otherwise overruns the icon beside it, and the
  /// overflow only shows up once larger text makes the field wider still.
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final captionColor = enabled
        ? theme.colorScheme.onSurfaceVariant
        : theme.disabledColor;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.typeRoles.metricLabel.copyWith(color: captionColor),
        ),
        SizedBox(height: spacing.xxs),
        // Shrink-wrapped, not `Expanded`: this field is laid out both inside a
        // fixed-width grid cell *and* inside the header row's `Wrap`, where an
        // expanding row would claim the whole line and put every field on one
        // of its own. `Flexible` still lets the value ellipsize when the cell
        // is narrower than its content.
        Row(
          mainAxisSize: fillWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (fillWidth) Expanded(child: child) else Flexible(child: child),
            if (_icon != null) ...[
              SizedBox(width: spacing.xs),
              Icon(_icon, size: 16, color: captionColor),
            ],
          ],
        ),
        if (supportingText != null) ...[
          SizedBox(height: spacing.xxs),
          Text(
            supportingText!,
            style: theme.typeRoles.metricLabel.copyWith(color: captionColor),
          ),
        ],
      ],
    );

    if (onTap == null || !enabled) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: theme.shapes.xsRadius,
      child: content,
    );
  }

  IconData? get _icon => switch (affordance) {
    CompactFieldAffordance.none => null,
    CompactFieldAffordance.dropdown => Icons.arrow_drop_down,
    CompactFieldAffordance.picker => Icons.chevron_right,
  };
}
