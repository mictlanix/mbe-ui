import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/shapes.dart';

void main() {
  group('Shapes', () {
    const s = Shapes.standard();

    test(
      'radii are non-negative and ascending: none <= xs <= sm <= md <= lg <= xl',
      () {
        final radii = [s.none, s.xs, s.sm, s.md, s.lg, s.xl];
        for (final r in radii) {
          expect(r, greaterThanOrEqualTo(0));
        }
        for (var i = 1; i < radii.length; i++) {
          expect(radii[i], greaterThanOrEqualTo(radii[i - 1]));
        }
      },
    );

    test(
      'card radius is 16, overriding Flutter\'s 12 default (Verbatim Constraint)',
      () {
        expect(s.lg, 16);
      },
    );

    test('full is a StadiumBorder, not a BorderRadius', () {
      expect(Shapes.full, isA<StadiumBorder>());
    });

    test('*Radius getters wrap the corresponding field', () {
      expect(s.lgRadius, BorderRadius.circular(s.lg));
      expect(s.noneRadius, BorderRadius.circular(0));
    });
  });
}
