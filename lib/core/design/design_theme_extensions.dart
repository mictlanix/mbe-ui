import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/density.dart';
import 'package:mbe_ui/core/design/elevations.dart';
import 'package:mbe_ui/core/design/shapes.dart';
import 'package:mbe_ui/core/design/spacing.dart';
import 'package:mbe_ui/core/design/type_roles.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

/// `Theme.of(context).spacing` / `.shapes` / `.elevations` / `.density` /
/// `.typeRoles` — the one access rule every screen follows
/// (contracts/design-tokens.md): every token reachable from the active
/// theme, none imported directly at a call site (FR-009).
///
/// Each getter falls back to a sensible `const` default when its extension
/// is absent — a widget test pumping a bare `ThemeData()` gets usable
/// values instead of a null-check crash (FR-024), mirroring the shipped
/// `BrandInkTheme` pattern.
extension DesignThemeExtensions on ThemeData {
  Spacing get spacing =>
      extension<Spacing>() ?? Spacing.forTier(LayoutTier.expanded);

  Shapes get shapes => extension<Shapes>() ?? const Shapes.standard();

  Elevations get elevations =>
      extension<Elevations>() ?? Elevations.resolve(colorScheme);

  Density get density => extension<Density>() ?? Density.resolve();

  TypeRoles get typeRoles =>
      extension<TypeRoles>() ??
      TypeRoles.resolve(textTheme, LayoutTier.expanded);
}
