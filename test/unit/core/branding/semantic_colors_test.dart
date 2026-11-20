import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/branding/semantic_colors.dart';

void main() {
  final light = ColorScheme.fromSeed(seedColor: const Color(0xFFECAB03));
  final dark = ColorScheme.fromSeed(
    seedColor: const Color(0xFFECAB03),
    brightness: Brightness.dark,
  );

  group('SemanticColors.fromScheme', () {
    test('takes the accent family from the scheme\'s tertiary roles', () {
      final c = SemanticColors.fromScheme(light);
      expect(c.accent, light.tertiary);
      expect(c.onAccent, light.onTertiary);
      expect(c.accentContainer, light.tertiaryContainer);
      expect(c.onAccentContainer, light.onTertiaryContainer);
    });

    test(
      'uses the shared neutral success and warning tones per brightness',
      () {
        final l = SemanticColors.fromScheme(light);
        final d = SemanticColors.fromScheme(dark);
        expect(l.success, const Color(0xFF1B6B3A));
        expect(l.successContainer, const Color(0xFFC9EFD3));
        expect(l.warning, const Color(0xFF855300));
        expect(l.warningContainer, const Color(0xFFFFDDB3));
        expect(d.success, const Color(0xFF7FD69A));
        expect(d.successContainer, const Color(0xFF0F4A26));
        expect(d.warning, const Color(0xFFFFB95E));
        expect(d.warningContainer, const Color(0xFF5A3A00));
      },
    );

    test('on-success / on-warning are white on light, dark ink on dark', () {
      expect(SemanticColors.fromScheme(light).onSuccess, Colors.white);
      expect(SemanticColors.fromScheme(light).onWarning, Colors.white);
      expect(
        SemanticColors.fromScheme(dark).onSuccess,
        const Color(0xFF00210D),
      );
      expect(
        SemanticColors.fromScheme(dark).onWarning,
        const Color(0xFF2A1700),
      );
    });
  });

  group('SemanticColors.withAccent', () {
    test('keeps the brand\'s own accent family', () {
      final c = SemanticColors.withAccent(
        Brightness.light,
        accent: const Color(0xFFD7190F),
        onAccent: Colors.white,
        accentContainer: const Color(0xFFFFDAD4),
        onAccentContainer: const Color(0xFF4A0500),
      );
      expect(c.accent, const Color(0xFFD7190F));
      expect(c.accentContainer, const Color(0xFFFFDAD4));
    });
  });

  group('ThemeExtension plumbing', () {
    final a = SemanticColors.fromScheme(light);
    final b = SemanticColors.fromScheme(dark);

    test('lerp at 0 and 1 returns the endpoints', () {
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
    });

    test('lerp with null returns this', () {
      expect(a.lerp(null, 0.5), same(a));
    });

    test('copyWith replaces only the named field', () {
      final c = a.copyWith(success: Colors.black);
      expect(c.success, Colors.black);
      expect(c.warning, a.warning);
      expect(c.accent, a.accent);
    });

    test('equal values compare equal', () {
      expect(SemanticColors.fromScheme(light), a);
      expect(SemanticColors.fromScheme(light).hashCode, a.hashCode);
      expect(a, isNot(b));
    });
  });

  group('ThemeData.semanticColors', () {
    test('returns the registered extension', () {
      final registered = SemanticColors.fromScheme(dark);
      final theme = ThemeData(extensions: [registered]);
      expect(theme.semanticColors, same(registered));
    });

    test('falls back to scheme-derived values when none is registered', () {
      final theme = ThemeData(colorScheme: light);
      expect(theme.semanticColors, SemanticColors.fromScheme(light));
    });
  });
}
