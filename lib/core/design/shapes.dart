import 'package:flutter/material.dart';

/// Named corner-radius scale (spec 022 FR-005), data-model.md §2. Delivered
/// as a `ThemeExtension` because Flutter has no `ShapeScheme` on `ThemeData`
/// (research R3) — component sub-themes consume these values directly.
///
/// Tier-invariant: unlike [Spacing], shape does not vary by form factor, so
/// there is a single canonical instance ([Shapes.standard]) rather than a
/// `forTier` factory.
@immutable
class Shapes extends ThemeExtension<Shapes> {
  const Shapes.standard() : none = 0, xs = 4, sm = 8, md = 12, lg = 16, xl = 28;

  const Shapes({
    required this.none,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  /// Table cells, dividers, full-bleed surfaces.
  final double none;

  /// Filled text field, snackbar.
  final double xs;

  /// Chips, badges, menu items.
  final double sm;

  /// Inner containers (Flutter's own `Card` default).
  final double md;

  /// Cards and panels — `16`, the brand guide's dominant radius (Verbatim
  /// Constraint), overriding Flutter's `md` (`12`) default for this role.
  final double lg;

  /// Dialogs, side sheets, bottom sheets.
  final double xl;

  /// Buttons, nav indicators, filter pills. A `ShapeBorder`, not a radius —
  /// never converted to one, and not a `BorderRadius`-typed field like the
  /// rest of this class.
  static const ShapeBorder full = StadiumBorder();

  BorderRadius get noneRadius => BorderRadius.circular(none);
  BorderRadius get xsRadius => BorderRadius.circular(xs);
  BorderRadius get smRadius => BorderRadius.circular(sm);
  BorderRadius get mdRadius => BorderRadius.circular(md);
  BorderRadius get lgRadius => BorderRadius.circular(lg);
  BorderRadius get xlRadius => BorderRadius.circular(xl);

  @override
  Shapes copyWith({
    double? none,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return Shapes(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  Shapes lerp(Shapes? other, double t) {
    if (other == null) return this;
    double l(double a, double b) => a + (b - a) * t;
    return Shapes(
      none: l(none, other.none),
      xs: l(xs, other.xs),
      sm: l(sm, other.sm),
      md: l(md, other.md),
      lg: l(lg, other.lg),
      xl: l(xl, other.xl),
    );
  }
}
