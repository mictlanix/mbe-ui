import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/component_themes.dart';
import 'package:mbe_ui/core/design/density.dart';
import 'package:mbe_ui/core/design/elevations.dart';
import 'package:mbe_ui/core/design/shapes.dart';
import 'package:mbe_ui/core/design/spacing.dart';
import 'package:mbe_ui/core/design/type_roles.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

/// Assembles a tier-resolved `ThemeData` from a brand-derived `base`
/// (research R1). `ThemeData`'s component sub-themes are plain fields — they
/// cannot vary per-`BuildContext` on their own — so tier resolution has to
/// happen once, above the app's `Navigator`, and be re-applied as a derived
/// theme. [DesignTheme.forTier] is that derivation: it reads `base`'s
/// [ColorScheme]/[TextTheme] (already brand-resolved) and attaches the five
/// tier/platform-resolved product-token extensions on top.
///
/// Memoized per `(base, tier)` — `ThemeData` has full structural equality,
/// so a brand-config change naturally produces a cache miss (a new `base`)
/// while a tier-only change (a resize) hits the cache. In the common case of
/// one stable `base` per brightness, this caps out at 2 brightnesses × 4
/// tiers = 8 live instances.
class DesignTheme {
  const DesignTheme._();

  static final _cache = <(ThemeData, LayoutTier), ThemeData>{};

  static ThemeData forTier(ThemeData base, LayoutTier tier) {
    final key = (base, tier);
    final cached = _cache[key];
    if (cached != null) return cached;

    final spacing = Spacing.forTier(tier);
    const shapes = Shapes.standard();
    final elevations = Elevations.resolve(base.colorScheme);
    final density = Density.resolve();
    final typeRoles = TypeRoles.resolve(base.textTheme, tier);

    final withExtensions = base.copyWith(
      extensions: [
        ...base.extensions.values,
        spacing,
        shapes,
        elevations,
        density,
        typeRoles,
      ],
    );
    final resolved = applyComponentThemes(
      withExtensions,
      scheme: base.colorScheme,
      spacing: spacing,
      shapes: shapes,
      elevations: elevations,
      density: density,
      typeRoles: typeRoles,
    );
    _cache[key] = resolved;
    return resolved;
  }
}
