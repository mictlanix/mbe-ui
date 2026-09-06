import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';

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
    this.editable = false,
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

  /// Whether this field can be changed — drawn as a dashed rule beneath the
  /// value, the one mark that says "editable" now the outlined box is gone
  /// (FR-016e).
  ///
  /// A rule rather than a trailing icon, for two reasons. An icon consumes
  /// horizontal space in a column already sized to its content — which is what
  /// pushed the formatted date-time into an ellipsis at the compact tier — and
  /// beside a dropdown's own arrow it reads as a second, competing affordance.
  /// An underline costs no width and never doubles up.
  final bool editable;

  /// Dims the caption and the rule to the disabled convention, and suppresses
  /// [onTap]. The child governs its own enabled rendering.
  final bool enabled;

  /// For a field whose child is not itself tappable — a picker launcher whose
  /// child is a plain `Text`. A child that handles its own gestures (a
  /// dropdown, a text field) leaves this null.
  final VoidCallback? onTap;

  /// Whether the value row fills the width its parent gives it.
  ///
  /// `false` (the default) shrink-wraps, which is what the header row's `Wrap`
  /// needs — an expanding row there claims the whole line and puts every field
  /// on one of its own.
  ///
  /// `true` is for a **bounded** parent — a grid cell, or a `ConstrainedBox` —
  /// where the child must be held to the space it is given. A child that
  /// reports no natural width of its own (a text field, which will happily take
  /// everything offered) otherwise overruns its column.
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final captionColor = enabled
        ? theme.colorScheme.onSurfaceVariant
        : theme.disabledColor;

    // FR-016d's one value rule. `fieldInput` is the design system's own role
    // for a value in a field — `bodyMedium` on desktop, `bodyLarge` on touch
    // tiers — so every value in the stack reads at one size and grows together.
    //
    // A `DefaultTextStyle` covers plain `Text` children. It does **not** reach
    // a `TextField`, which resolves its own style from the theme: that is why
    // the bare `CatalogEntityPicker` sets this same role on its field directly,
    // and without it the salesperson value rendered 16px against everything
    // else's 14 — a 24px row beside 20px ones.
    Widget valueRow = DefaultTextStyle.merge(
      style: theme.typeRoles.fieldInput.copyWith(
        color: enabled ? theme.colorScheme.onSurface : theme.disabledColor,
      ),
      child: Row(
        mainAxisSize: fillWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (fillWidth) Expanded(child: child) else Flexible(child: child),
        ],
      ),
    );

    if (editable && enabled) {
      valueRow = CustomPaint(
        foregroundPainter: _DashedRulePainter(theme.colorScheme.outline),
        child: Padding(
          // Room for the rule to sit clear of the text's descenders.
          padding: EdgeInsets.only(bottom: spacing.xxs),
          child: valueRow,
        ),
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.typeRoles.metricLabel.copyWith(color: captionColor),
        ),
        SizedBox(height: spacing.xxs),
        valueRow,
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
}

/// The dashed rule under an editable value. Drawn rather than composed from a
/// border because Flutter's `BorderSide` has no dash pattern, and the app
/// ships no dashed-border dependency.
class _DashedRulePainter extends CustomPainter {
  const _DashedRulePainter(this.color);

  final Color color;

  static const _dash = 2.0;
  static const _gap = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    // Half a pixel up, so the 1px stroke lands on the pixel rather than
    // straddling two and rendering soft.
    final y = size.height - 0.5;
    for (var x = 0.0; x < size.width; x += _dash + _gap) {
      final end = x + _dash > size.width ? size.width : x + _dash;
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRulePainter oldDelegate) =>
      oldDelegate.color != color;
}
