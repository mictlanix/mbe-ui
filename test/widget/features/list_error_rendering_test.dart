import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards SC-008 (017-ui-consistency-filters): no list screen renders a raw
/// exception by interpolating it into a per-entity `l10n.<entity>LoadError(e)`
/// string. Every list screen (and the pricing screen / taxpayer certificates
/// section, which render the same four states without being a paginated
/// catalog list) now goes through `CatalogListStateView` / `ListFailedView`,
/// which maps errors through `ErrorBanner` instead (FR-031,
/// contracts/list-state-views.md §2).
///
/// The per-entity `l10n.<entity>LoadError` keys themselves are left in place
/// (contracts/list-state-views.md §2) — only their raw-exception call sites
/// are what this test forbids.
void main() {
  test('no lib/features file interpolates a raw error via LoadError(e)', () {
    final offenders = <String>[];
    final libFeatures = Directory('lib/features');

    for (final entity in libFeatures.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('LoadError(e)')) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Raw exception interpolation via LoadError(e) found at: $offenders',
    );
  });
}
