import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';

/// Which brand asset to render.
enum BrandLogoStyle { lockup, mark }

/// The surface the logo sits on — selects the correct ink (contracts/
/// brand-assets.md's Variant selection rule). Only the two variants this
/// app actually places the logo against are supported: [neutral] (the
/// login branding pane's dark surface and the nav header's neutral warm
/// surface in both light and dark theme — both render the full-color
/// asset, matching the brand guide's own light-mode nav mockup) and
/// [brandFill] (a solid brand-color background, e.g. a filled button),
/// which needs the single-ink white variant. Grayscale-on-light-background
/// and print/PDF variants exist in the brand guide as separate SVG assets
/// but have no in-app placement in this app (spec 019 Assumptions) — not
/// implemented here, to avoid a `flutter_svg` dependency and dead code
/// (research R4).
enum BrandLogoBackground { neutral, brandFill }

/// Renders the brand lockup or mark from `BrandConfig.lockupAsset`/
/// `BrandConfig.markAsset`, enforcing the brand guide's minimum-size and
/// clear-space rules (contracts/brand-tokens.md; FR-003/004).
///
/// Exactly one of [width] or [height] must be provided — the other
/// dimension is derived from the asset's natural aspect ratio, matching how
/// the brand guide itself sizes each placement (login lockup: width-driven;
/// nav header mark: height-driven).
class BrandLogo extends ConsumerWidget {
  const BrandLogo({
    super.key,
    required this.style,
    this.width,
    this.height,
    this.background = BrandLogoBackground.neutral,
  }) : assert(
         (width == null) != (height == null),
         'Provide exactly one of width or height.',
       );

  final BrandLogoStyle style;
  final double? width;
  final double? height;
  final BrandLogoBackground background;

  double get _minWidth => style == BrandLogoStyle.lockup
      ? XbePalette.lockupMinWidth
      : XbePalette.markMinWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Minimum-size enforcement (FR-003/004): a placement that cannot honor
    // its documented minimum renders nothing rather than an illegibly
    // small logo. Only checkable up front in width-mode; the one
    // height-mode caller (the nav header) always requests a height whose
    // known asset aspect ratio already clears the width floor comfortably,
    // and this app has no collapsed-nav state that would request smaller.
    if (width != null && width! < _minWidth) {
      return const SizedBox.shrink();
    }

    final brand = ref.watch(brandConfigProvider);
    final assetPath = style == BrandLogoStyle.lockup
        ? brand.lockupAsset
        : brand.markAsset;

    Widget image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );

    if (background == BrandLogoBackground.brandFill) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: image,
      );
    }

    // Clear space (FR-003): documented for the width-driven lockup
    // placement (login) — 8% of rendered width, kept free of other
    // content. The height-driven mark placement (nav header) has no
    // documented clear-space rule.
    final clearSpace = width != null
        ? width! * XbePalette.clearSpaceRatio
        : 0.0;
    return Padding(padding: EdgeInsets.all(clearSpace), child: image);
  }
}

/// Decorative low-opacity mark placement (FR-010; contracts/brand-tokens.md
/// watermark rows) — positioned by the caller so it never sits behind
/// readable text. Uses the mark asset, white-tinted at 7% opacity on dark
/// surfaces or left full-color at 6% opacity on light surfaces (no
/// dedicated white-mark raster exists, so the white tint is produced with a
/// [ColorFilter] instead of a separate asset).
class BrandWatermark extends ConsumerWidget {
  const BrandWatermark({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandConfigProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget image = Image.asset(
      brand.markAsset,
      width: width,
      fit: BoxFit.contain,
    );
    if (isDark) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: image,
      );
    }

    return Opacity(
      opacity: isDark
          ? XbePalette.watermarkOpacityDark
          : XbePalette.watermarkOpacityLight,
      child: image,
    );
  }
}
