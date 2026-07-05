import 'package:flutter/widgets.dart';

/// Centralized `LayoutBuilder`/`MediaQuery` width breakpoints (constitution
/// §VI), based on Material 3 window size classes. The **Expanded** tier is
/// the primary target for v1; **Compact** is reserved for a future phone
/// tier.
class LayoutBreakpoints {
  const LayoutBreakpoints._();

  /// Below this width: Compact (phone) tier.
  static const double compact = 600;

  /// Below this width (and >= [compact]): Medium tier. >= this width (and
  /// < [large]): Expanded (desktop/web) tier.
  static const double expanded = 840;

  /// At/above this width: Large tier (wide desktop / 4K). Used to unlock the
  /// three-column product form (data-model.md).
  static const double large = 1200;

  static LayoutTier tierOf(double width) {
    if (width < compact) return LayoutTier.compact;
    if (width < expanded) return LayoutTier.medium;
    if (width < large) return LayoutTier.expanded;
    return LayoutTier.large;
  }

  static LayoutTier tierOfContext(BuildContext context) {
    return tierOf(MediaQuery.sizeOf(context).width);
  }

  static bool isCompact(BuildContext context) =>
      tierOfContext(context) == LayoutTier.compact;

  /// True at the Expanded tier **or wider** (i.e. also Large) — desktop/web.
  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;

  /// True at the Large tier (wide desktop / 4K).
  static bool isLarge(BuildContext context) =>
      tierOfContext(context) == LayoutTier.large;
}

enum LayoutTier { compact, medium, expanded, large }
