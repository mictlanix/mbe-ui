import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';

/// Brand colors that are only correct as a **foreground** (text/icon) on a
/// surface, where the matching `ColorScheme` role would fail contrast.
///
/// Gold `primary` is correct as a *fill* — its contrast is measured against
/// the dark `onPrimary` ink it carries — but lands under 2:1 against a light
/// surface when used as text or icon color. The brand guide is explicit about
/// this ("el oro puro no alcanza contraste como texto sobre blanco") and spec
/// 019 `contracts/brand-tokens.md` § "Color role contract" makes the
/// demotion to [XbePalette.goldInk] a MUST.
///
/// This lives on `ThemeData` rather than being read from [XbePalette] at each
/// call site so that widgets keep sourcing every color from
/// `Theme.of(context)` — and so a deployment that overrode the seed can never
/// inherit XBE's toasted gold (FR-007).
@immutable
class BrandInk extends ThemeExtension<BrandInk> {
  const BrandInk({required this.primary});

  /// Contrast-safe stand-in for [ColorScheme.primary] as a text/icon color.
  final Color primary;

  /// The undemoted case: `primary` is already accessible as a foreground.
  /// True for dark mode (gold on the warm-dark ramp) and for any
  /// seed-overriding deployment, whose `primary` is whatever
  /// `ColorScheme.fromSeed` derived — an accessible tone by construction.
  factory BrandInk.fromScheme(ColorScheme scheme) =>
      BrandInk(primary: scheme.primary);

  /// Only the XBE default palette pins bright gold to `primary`, so only it
  /// needs the light-mode demotion.
  factory BrandInk.forBrand(BrandConfig brand, ColorScheme scheme) {
    final pinnedGoldOnLight =
        brand.usesDefaultPalette && scheme.brightness == Brightness.light;
    return pinnedGoldOnLight
        ? const BrandInk(primary: XbePalette.goldInk)
        : BrandInk.fromScheme(scheme);
  }

  @override
  BrandInk copyWith({Color? primary}) =>
      BrandInk(primary: primary ?? this.primary);

  @override
  BrandInk lerp(BrandInk? other, double t) => other == null
      ? this
      : BrandInk(primary: Color.lerp(primary, other.primary, t)!);
}

extension BrandInkTheme on ThemeData {
  /// Falls back to the raw scheme when no [BrandInk] is registered — a widget
  /// test pumping a bare `ThemeData` gets undemoted `primary` rather than a
  /// null-check crash.
  BrandInk get brandInk =>
      extension<BrandInk>() ?? BrandInk.fromScheme(colorScheme);
}
