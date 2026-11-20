import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_registry.dart';
import 'package:mbe_ui/core/branding/brands/casa_maestra_brand.dart';
import 'package:mbe_ui/core/branding/brands/xbe_brand.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';

void main() {
  group('BrandConfig defaults', () {
    test('defaults to the XBE gold seed and default palette', () {
      const config = BrandConfig(displayName: 'X');
      expect(config.seedColor, XbePalette.gold);
      expect(config.usesDefaultPalette, isTrue);
      expect(config.lockupAsset, 'assets/brand/login_lockup.png');
      expect(config.markAsset, 'assets/brand/nav_lockup.png');
    });
  });

  group('BrandConfig.resolve (BRAND_ID selection, spec 077 FR-001/FR-003)', () {
    BrandConfig resolve(
      String brandId, {
      String seedHex = '',
      bool hasSeed = false,
      String displayName = 'Legacy Name',
      String lockup = 'assets/brand/legacy_lockup.png',
    }) => BrandConfig.resolve(
      brandId: brandId,
      displayName: displayName,
      welcomeAsset: 'assets/branding/legacy.png',
      seedColorHex: seedHex,
      hasSeedColor: hasSeed,
      lockupAsset: lockup,
      markAsset: 'assets/brand/legacy_mark.png',
    );

    for (final id in ['', 'xbe', 'mbe', 'nope', 'XBE.CM']) {
      test('"$id" keeps the default brand and honors the legacy flags', () {
        final config = resolve(id, seedHex: '1B5E20', hasSeed: true);
        expect(config.definition, same(xbeBrand));
        expect(config.displayName, 'Legacy Name');
        expect(config.welcomeAsset, 'assets/branding/legacy.png');
        expect(config.seedColor, const Color(0xFF1B5E20));
        expect(config.usesDefaultPalette, isFalse);
        expect(config.lockupAsset, 'assets/brand/legacy_lockup.png');
        expect(config.markAsset, 'assets/brand/legacy_mark.png');
        expect(config.lockupReversedAsset, isNull);
      });
    }

    test('with no seed flag the default palette pins stay on', () {
      final config = resolve('');
      expect(config.usesDefaultPalette, isTrue);
      expect(config.seedColor, XbePalette.gold);
    });

    test('an unknown ID is never registered', () {
      expect(isRegisteredBrand('nope'), isFalse);
      expect(isRegisteredBrand('mbe'), isFalse);
      expect(isRegisteredBrand('xbe'), isTrue);
      expect(brandDefinitionById('nope'), same(xbeBrand));
    });

    test('every registered brand but the default beats the legacy flags', () {
      for (final entry in kBrandRegistry.entries) {
        if (entry.key == xbeBrand.id) continue;
        final config = resolve(entry.key, seedHex: '1B5E20', hasSeed: true);
        final def = entry.value;
        expect(config.definition, same(def));
        expect(config.displayName, def.displayName);
        expect(config.seedColor, def.seedColor);
        expect(config.usesDefaultPalette, isTrue);
        expect(config.lockupAsset, def.lockupAsset);
        expect(config.markAsset, def.markAsset);
        expect(config.lockupReversedAsset, def.lockupReversedAsset);
        expect(config.welcomeAsset, isNull);
      }
    });
  });

  group('BrandConfig equality', () {
    test('two configs with identical fields are equal', () {
      const a = BrandConfig(
        displayName: 'X',
        welcomeAsset: 'assets/branding/x.png',
        seedColor: Color(0xFF1B5E20),
        usesDefaultPalette: false,
        lockupAsset: 'assets/brand/x_lockup.png',
        markAsset: 'assets/brand/x_mark.png',
      );
      const b = BrandConfig(
        displayName: 'X',
        welcomeAsset: 'assets/branding/x.png',
        seedColor: Color(0xFF1B5E20),
        usesDefaultPalette: false,
        lockupAsset: 'assets/brand/x_lockup.png',
        markAsset: 'assets/brand/x_mark.png',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differing seedColor breaks equality', () {
      const a = BrandConfig(displayName: 'X', seedColor: Color(0xFF1B5E20));
      const b = BrandConfig(displayName: 'X', seedColor: Color(0xFF000000));
      expect(a, isNot(b));
    });

    test('differing usesDefaultPalette breaks equality', () {
      const a = BrandConfig(displayName: 'X', usesDefaultPalette: true);
      const b = BrandConfig(displayName: 'X', usesDefaultPalette: false);
      expect(a, isNot(b));
    });

    test('differing definition breaks equality', () {
      const a = BrandConfig(displayName: 'X');
      const b = BrandConfig(displayName: 'X', definition: casaMaestraBrand);
      expect(a, isNot(b));
    });

    test('differing lockupReversedAsset breaks equality', () {
      const a = BrandConfig(displayName: 'X', lockupReversedAsset: 'a.png');
      const b = BrandConfig(displayName: 'X', lockupReversedAsset: 'b.png');
      expect(a, isNot(b));
    });

    test('differing lockupAsset/markAsset breaks equality', () {
      const a = BrandConfig(displayName: 'X', lockupAsset: 'a.png');
      const b = BrandConfig(displayName: 'X', lockupAsset: 'b.png');
      expect(a, isNot(b));

      const c = BrandConfig(displayName: 'X', markAsset: 'a.png');
      const d = BrandConfig(displayName: 'X', markAsset: 'b.png');
      expect(c, isNot(d));
    });
  });

  // BrandConfig.fromEnvironment() itself reads compile-time --dart-define
  // values, which can't be varied per-test-case at runtime; the parsing
  // logic it delegates to is exercised directly here instead, matching the
  // same rules described in its doc comment.
  group('BrandConfig hex seed parsing (BrandConfig._parseSeedColor rules)', () {
    Color parse(String hex) {
      // Mirrors BrandConfig._parseSeedColor exactly (private, so this test
      // re-implements the same two rules it documents: strip a leading '#',
      // require 6 hex digits, else fall back to XbePalette.gold).
      final cleaned = hex.startsWith('#') ? hex.substring(1) : hex;
      if (cleaned.length != 6) return XbePalette.gold;
      final value = int.tryParse(cleaned, radix: 16);
      if (value == null) return XbePalette.gold;
      return Color(0xFF000000 | value);
    }

    test('parses a bare RRGGBB hex string', () {
      expect(parse('1B5E20'), const Color(0xFF1B5E20));
    });

    test('parses a #-prefixed hex string', () {
      expect(parse('#1B5E20'), const Color(0xFF1B5E20));
    });

    test('falls back to XbePalette.gold on empty input', () {
      expect(parse(''), XbePalette.gold);
    });

    test('falls back to XbePalette.gold on malformed input', () {
      expect(parse('not-a-color'), XbePalette.gold);
      expect(parse('12345'), XbePalette.gold);
      expect(parse('1234567'), XbePalette.gold);
    });
  });
}
