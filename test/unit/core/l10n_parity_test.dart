import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards FR-036 (017-ui-consistency-filters): every new/changed user-facing
/// string must land in both supported locales. `flutter gen-l10n` doesn't
/// enforce key parity itself — a key present only in `app_en.arb` compiles
/// fine and silently falls back to English at runtime.
Set<String> _keysOf(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  test('app_en.arb and app_es.arb declare the same set of keys', () {
    final enKeys = _keysOf('lib/l10n/app_en.arb');
    final esKeys = _keysOf('lib/l10n/app_es.arb');

    final onlyInEn = enKeys.difference(esKeys);
    final onlyInEs = esKeys.difference(enKeys);

    expect(
      onlyInEn,
      isEmpty,
      reason: 'Keys present in app_en.arb but missing from app_es.arb: $onlyInEn',
    );
    expect(
      onlyInEs,
      isEmpty,
      reason: 'Keys present in app_es.arb but missing from app_en.arb: $onlyInEs',
    );
  });
}
