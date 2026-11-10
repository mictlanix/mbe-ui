import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Spec 058 FR-014 / SC-004: server text reaches a screen only through
/// `AppError.userMessage` (`lib/core/errors/localize_problem.dart`), which
/// prefers a message built from the server's code in the user's language and
/// falls back to the English `detail` only when there is none.
///
/// So no file outside `lib/core/errors/` may read `serverMessage` (the raw
/// English) directly, and no form state may carry a pre-extracted English
/// `errorDetail` again: a form keeps the `AppError` as `errorCause` and builds
/// its text when it shows it, so the text follows the current language.
///
/// A plain `dart:io` source scan, modelled on `formatting_guard_test.dart`.
///
/// **Allowlist** — each entry justified in-line:
/// - `lib/core/errors/` — the one place that may read it: `userMessage`'s own
///   fallback, and `AppError`'s definition.
/// - `lib/generated/` — the generated API client (constitution §III: never
///   hand-edited).
/// - `*.freezed.dart`, `*.g.dart` — generated, and gitignored.
///
/// A line that is only a comment is skipped, so the rule can be explained next
/// to the code it governs.
void main() {
  test('no file outside lib/core/errors/ reads the server\'s raw text', () {
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path;
      if (path.startsWith('lib/core/errors/') ||
          path.startsWith('lib/generated/') ||
          path.endsWith('.freezed.dart') ||
          path.endsWith('.g.dart')) {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//')) continue;
        if (line.contains('serverMessage') || line.contains('errorDetail')) {
          offenders.add('$path:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Show an AppError through `userMessage` (or FormErrorBanner / '
          'ErrorBanner), and keep it in form state as `errorCause`, never as '
          'its English text (spec 058 FR-014):\n${offenders.join('\n')}',
    );
  });

  test('the scan is not vacuous: userMessage itself reads serverMessage', () {
    final source = File(
      'lib/core/errors/localize_problem.dart',
    ).readAsStringSync();
    expect(source, contains('serverMessage'));
  });
}
