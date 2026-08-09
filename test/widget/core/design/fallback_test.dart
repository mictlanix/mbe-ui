import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/design.dart';

/// FR-024: a control rendered outside the product's own theme (a bare
/// `ThemeData()`, e.g. an isolated widget test) falls back to sensible
/// values rather than failing.
void main() {
  test('theme.spacing/.shapes/.elevations/.density/.typeRoles never throw '
      'on a bare ThemeData with no design extensions', () {
    final bare = ThemeData();

    expect(() => bare.spacing, returnsNormally);
    expect(() => bare.shapes, returnsNormally);
    expect(() => bare.elevations, returnsNormally);
    expect(() => bare.density, returnsNormally);
    expect(() => bare.typeRoles, returnsNormally);
  });

  test('fallback values are the documented const defaults, not zeros', () {
    final bare = ThemeData();

    expect(bare.spacing.lg, 24);
    expect(bare.shapes.lg, 16);
    expect(
      bare.elevations.raised.surfaceColor,
      bare.colorScheme.surfaceContainerLow,
    );
    expect(bare.density.minTargetSize, greaterThanOrEqualTo(40));
    expect(bare.typeRoles.sectionHeading, isNotNull);
  });
}
