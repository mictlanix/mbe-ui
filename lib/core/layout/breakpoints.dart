import 'package:flutter/widgets.dart';

/// Centralized `LayoutBuilder`/`MediaQuery` width breakpoints (constitution
/// §VI), based on Material 3 window size classes. The **Expanded** tier is
/// the primary target for v1; **Compact** is reserved for a future phone
/// tier.
class LayoutBreakpoints {
  const LayoutBreakpoints._();

  /// Below this width: Compact (phone) tier.
  static const double compact = 600;

  /// Below this width (and >= [compact]): Medium tier. >= this width:
  /// Expanded (desktop/web) tier.
  static const double expanded = 840;

  static LayoutTier tierOf(double width) {
    if (width < compact) return LayoutTier.compact;
    if (width < expanded) return LayoutTier.medium;
    return LayoutTier.expanded;
  }

  static LayoutTier tierOfContext(BuildContext context) {
    return tierOf(MediaQuery.sizeOf(context).width);
  }

  static bool isCompact(BuildContext context) =>
      tierOfContext(context) == LayoutTier.compact;

  static bool isExpanded(BuildContext context) =>
      tierOfContext(context) == LayoutTier.expanded;
}

enum LayoutTier { compact, medium, expanded }
