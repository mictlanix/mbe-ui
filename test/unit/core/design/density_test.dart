import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/density.dart';

void main() {
  group('Density', () {
    test('touch platforms get standard density and a 48dp target floor', () {
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.fuchsia,
      ]) {
        final d = Density.forPlatform(platform);
        expect(d.visualDensity, VisualDensity.standard);
        expect(d.minTargetSize, 48);
      }
    });

    test('pointer platforms get compact density and a 40dp target floor', () {
      for (final platform in [
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      ]) {
        final d = Density.forPlatform(platform);
        expect(d.visualDensity, VisualDensity.compact);
        expect(d.minTargetSize, 40);
      }
    });

    test('minTargetSize never drops below the 40dp accessibility floor', () {
      for (final platform in TargetPlatform.values) {
        expect(
          Density.forPlatform(platform).minTargetSize,
          greaterThanOrEqualTo(40),
        );
      }
    });

    test(
      'touch density has no table row heights -- tables render as card lists there',
      () {
        final touch = Density.forPlatform(TargetPlatform.android);
        expect(touch.tableHeadingRowHeight, isNull);
        expect(touch.tableDataRowHeight, isNull);
      },
    );

    test('pointer density defines table row heights', () {
      final pointer = Density.forPlatform(TargetPlatform.macOS);
      expect(pointer.tableHeadingRowHeight, isNotNull);
      expect(pointer.tableDataRowHeight, isNotNull);
    });
  });
}
