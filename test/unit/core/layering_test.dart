import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Constitution §I / spec 022 Verbatim Constraint: nothing in `lib/features/`
/// or `lib/core/` may import `lib/app/`. Regression-tested here rather than
/// left as a one-time audit, since every later phase of spec 022 depends on
/// it staying true.
void main() {
  test('lib/features/ and lib/core/ never import lib/app/', () {
    final offenders = <String>[];
    for (final dir in ['lib/features', 'lib/core']) {
      final root = Directory(dir);
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final contents = entity.readAsStringSync();
        if (contents.contains("import 'package:mbe_ui/app/")) {
          offenders.add(entity.path);
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'lib/features/ and lib/core/ must not import lib/app/ '
          '(constitution §I): ${offenders.join(', ')}',
    );
  });
}
