import 'package:flutter/material.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';

/// How wide a [FormGridChild] is within a [ResponsiveFormGrid].
enum FormGridSpan {
  /// Occupies a single column.
  single,

  /// Occupies the entire row regardless of the current column count — for
  /// multiline fields, section headers, switch lists, and action buttons.
  full,
}

/// A child of [ResponsiveFormGrid] paired with its column [span].
class FormGridChild {
  const FormGridChild(this.child, {this.span = FormGridSpan.single});

  final Widget child;
  final FormGridSpan span;
}

/// Lays [children] out in a responsive 1/2/3-column grid inside a centered,
/// max-width container (constitution §VI; research.md §4). The column count is
/// derived from the centralized [LayoutBreakpoints] tier of the available
/// width: compact → 1, medium/expanded → 2, large → 3. Uses a [Wrap] so the
/// trailing row of an odd child count is left-aligned rather than stretched,
/// and so nothing forces horizontal scrolling.
class ResponsiveFormGrid extends StatelessWidget {
  const ResponsiveFormGrid({
    super.key,
    required this.children,
    this.maxContentWidth = LayoutBreakpoints.large,
    this.spacing = 16,
  });

  final List<FormGridChild> children;
  final double maxContentWidth;
  final double spacing;

  static int columnsForWidth(double width) =>
      switch (LayoutBreakpoints.tierOf(width)) {
        LayoutTier.compact => 1,
        LayoutTier.medium || LayoutTier.expanded => 2,
        LayoutTier.large => 3,
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final inner = constraints.maxWidth;
            final columns = columnsForWidth(inner);
            // Subtract a sub-pixel epsilon so floating-point rounding never
            // pushes the last cell past `inner` and forces an early wrap.
            final cellWidth =
                (inner - spacing * (columns - 1)) / columns - 0.01;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final item in children)
                  SizedBox(
                    width: item.span == FormGridSpan.full || columns == 1
                        ? inner
                        : cellWidth,
                    child: item.child,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
