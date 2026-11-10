import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_fixtures.dart';
import 'problem_test_env.dart';

/// Spec 058 SC-001 / SC-003: every code the app localizes renders in both
/// languages, every code an endpoint the app calls can return is among them,
/// and a missing, mistyped or unknown value never fails: it only means "no
/// localized message, fall back".
void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  ApiProblem problemFor(api.ErrorCode code, Map<String, Object?> params) =>
      ApiProblem(codeName: code.name, code: code, params: params);

  /// The codes whose message needs a param. With none, they have no message;
  /// every other code is a fixed sentence.
  const needParams = {
    'customer.credit_hold',
    'customer.credit_limit_exceeded',
    'customer.credit_limit_reached',
    'delivery_order.quantity_exceeds_remaining',
    'facility.other_facility',
    'image.too_large',
    'product.lookup_too_many',
    'product_price.references_not_found',
    'refund.line_invoiced',
    'resource.already_exists',
    'resource.not_found',
    'sales_order.below_min_quantity',
    'supplier_agreement.end_before_start',
    'taxpayer_certificate.holder_mismatch',
    'taxpayer_issuer.unknown',
  };

  test(
    'every localized code has a fixture, and every fixture is localized',
    () {
      expect(problemFixtures.keys.toSet(), localizedErrorCodes);
    },
  );

  test('every localized code renders a real message in both languages', () {
    final broken = <String>[];
    for (final entry in problemFixtures.entries) {
      final problem = problemFor(entry.key, entry.value);
      for (final (lang, l10n, fmt) in [
        ('en', env.en, env.fmtEn),
        ('es', env.es, env.fmtEs),
      ]) {
        final text = localizeProblem(problem, l10n, fmt);
        if (text == null ||
            text.trim().isEmpty ||
            text.contains(RegExp(r'[{}]')) ||
            text.contains('null')) {
          broken.add('${entry.key.name} [$lang]: $text');
        }
      }
    }
    expect(broken, isEmpty);
  });

  test('Spanish is not the English text for any code', () {
    final same = <String>[];
    for (final entry in problemFixtures.entries) {
      final problem = problemFor(entry.key, entry.value);
      final en = localizeProblem(problem, env.en, env.fmtEn);
      final es = localizeProblem(problem, env.es, env.fmtEs);
      if (en == es) same.add(entry.key.name);
    }
    expect(same, isEmpty, reason: 'untranslated: $same');
  });

  test('every code an endpoint the app calls can return is localized '
      '(code-scope.tsv)', () {
    final lines = File(
      'specs/058-localized-api-errors/contracts/code-scope.tsv',
    ).readAsLinesSync();
    final missing = <String>[];
    var checked = 0;
    for (final line in lines.skip(1)) {
      final cells = line.split('\t');
      if (cells.length < 5 || cells[0] != 'code' || cells[4] != 'IN') continue;
      checked++;
      final code = ApiProblem.fromBody({'code': cells[1]})!.code;
      if (code == null || !localizedErrorCodes.contains(code)) {
        missing.add(cells[1]);
      }
    }
    expect(checked, 96);
    expect(missing, isEmpty);
  });

  test('a code that needs params has no message without them', () {
    for (final entry in problemFixtures.entries) {
      final wire = _wireName(entry.key);
      final text = localizeProblem(
        problemFor(entry.key, const {}),
        env.en,
        env.fmtEn,
      );
      if (needParams.contains(wire)) {
        expect(text, isNull, reason: '$wire needs params');
      } else {
        expect(text, isNotNull, reason: '$wire has a fixed message');
      }
    }
  });

  test('a missing or mistyped param never fails, only means no message', () {
    for (final entry in problemFixtures.entries) {
      for (final key in entry.value.keys) {
        final without = {...entry.value}..remove(key);
        final mistyped = {...entry.value, key: <String, Object?>{}};
        for (final params in [without, mistyped]) {
          final text = localizeProblem(
            problemFor(entry.key, params),
            env.es,
            env.fmtEs,
          );
          expect(
            text == null || text.isNotEmpty,
            isTrue,
            reason: '${entry.key.name} with $params',
          );
        }
      }
    }
  });

  test('an unknown or absent code has no message', () {
    expect(
      localizeProblem(
        const ApiProblem(codeName: 'future.not_yet_invented'),
        env.es,
        env.fmtEs,
      ),
      isNull,
    );
    expect(
      localizeProblem(
        ApiProblem.fromBody({'code': 'future.not_yet_invented'})!,
        env.en,
        env.fmtEn,
      ),
      isNull,
    );
  });
}

/// `customerPeriodCreditHold` → `customer.credit_hold`.
String _wireName(api.ErrorCode code) {
  final parts = code.name.split('Period');
  String snake(String camel) => camel.replaceAllMapped(
    RegExp('[A-Z]'),
    (m) => '_${m.group(0)!.toLowerCase()}',
  );
  return '${snake(parts[0])}.${snake(parts[1]).replaceFirst('_', '')}';
}
