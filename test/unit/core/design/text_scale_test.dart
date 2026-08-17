import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/text_scale.dart';

void main() {
  group('ComposedTextScaler (spec 027 research R1)', () {
    test('at TextSizeLevel.normal, composing with any platform scaler is the identity', () {
      for (final platform in [
        TextScaler.noScaling,
        const TextScaler.linear(1.3),
        const TextScaler.linear(0.85),
      ]) {
        final composed = ComposedTextScaler(platform: platform, level: TextSizeLevel.normal);
        for (final fontSize in [12.0, 14.0, 20.0, 32.0]) {
          expect(composed.scale(fontSize), platform.scale(fontSize));
        }
      }
    });

    test('at a non-default level, composes level.factor onto the platform scaler', () {
      const platform = TextScaler.linear(1.3);
      for (final level in TextSizeLevel.values) {
        final composed = ComposedTextScaler(platform: platform, level: level);
        for (final fontSize in [12.0, 14.0, 20.0]) {
          expect(composed.scale(fontSize), platform.scale(fontSize * level.factor));
        }
      }
    });

    test('never replaces the platform scaler — an OS-scaled user keeps that scaling', () {
      // A user on a 1.5x system who picks the smallest app level (0.9x)
      // must not end up smaller than an unscaled 1.0x system would render.
      const osScaled = TextScaler.linear(1.5);
      final composed = ComposedTextScaler(platform: osScaled, level: TextSizeLevel.small);
      expect(composed.scale(14), greaterThan(TextScaler.noScaling.scale(14)));
    });
  });

  group('TextSizeLevel', () {
    test('exactly four levels, normal is the identity factor', () {
      expect(TextSizeLevel.values.length, 4);
      expect(TextSizeLevel.normal.factor, 1.0);
    });

    test('factors are strictly increasing small < normal < large < extraLarge', () {
      expect(TextSizeLevel.small.factor, lessThan(TextSizeLevel.normal.factor));
      expect(TextSizeLevel.normal.factor, lessThan(TextSizeLevel.large.factor));
      expect(TextSizeLevel.large.factor, lessThan(TextSizeLevel.extraLarge.factor));
    });
  });
}
