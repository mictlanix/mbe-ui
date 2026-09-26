import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Spec 043 FR-006/FR-009 (mictlanix/mbe-ui#176): no file outside the
/// allowlist below may reach for the generated client's raw
/// `standardSerializers` — every data-access path goes through
/// `appSerializers` (`lib/core/network/api_serializers.dart`), the one place
/// that converts mbe-api's naive wall-clock timestamps correctly instead of
/// shifting them with `Iso8601DateTimeSerializer`'s `.toUtc()`. Modeled on
/// `test/unit/core/formatting_guard_test.dart`'s scan pattern.
///
/// **Allowlist**:
/// - `lib/generated/` — the generated OpenAPI client itself declares and
///   exports `standardSerializers`; it must reference its own name.
/// - `lib/core/network/api_serializers.dart` — the one file that builds
///   `appSerializers` from it.
/// - this file — it names `standardSerializers` only to describe what it
///   forbids.
///
/// If you are adding a new exemption, you are almost certainly adding a
/// data-access path that reads timestamps the way the app no longer does.
void main() {
  const selfPath = 'test/unit/core/network/serializers_guard_test.dart';

  bool isAllowed(String path) {
    if (path.startsWith('lib/generated/')) return true;
    if (path == 'lib/core/network/api_serializers.dart') return true;
    if (path == selfPath) return true;
    return false;
  }

  Iterable<File> dartFilesUnder(String dir) sync* {
    final root = Directory(dir);
    if (!root.existsSync()) return;
    for (final entity in root.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) yield entity;
    }
  }

  test('no file outside the allowlist references standardSerializers', () {
    final offenders = <String>[];
    for (final dir in ['lib', 'test']) {
      for (final file in dartFilesUnder(dir)) {
        final path = file.path.replaceAll(r'\', '/');
        if (isAllowed(path)) continue;
        if (file.readAsStringSync().contains('standardSerializers')) {
          offenders.add(path);
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'these files reach for the raw standardSerializers instead of '
          'appSerializers (spec 043 FR-006/FR-009, mictlanix/mbe-ui#176), so '
          'they will read mbe-api\'s timestamps six hours off: '
          '${offenders.join(', ')}',
    );
  });
}
