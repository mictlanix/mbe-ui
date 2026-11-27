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
    'commission_agent.salesperson_not_agent',
    'commission_period.already_closed',
    'commission_period.already_paid',
    'commission_period.later_closed',
    'commission_period.not_closed',
    'commission_period.not_ended',
    'commission_period.paid_cannot_reopen',
    'commission_period.previous_not_closed',
    'customer.credit_hold',
    'customer.credit_limit_exceeded',
    'customer.credit_limit_reached',
    'delivery_order.insufficient_notice',
    'delivery_order.quantity_exceeds_remaining',
    'delivery_order_line.quantity_unavailable',
    'facility.other_facility',
    'fiscal_document.amount_exceeds_balance',
    'fiscal_document.credit_exceeds_invoice',
    'fiscal_document.credit_quantity_exceeds_line',
    'fiscal_document.has_live_documents',
    'fiscal_document.line_missing_sat_key',
    'fiscal_document.line_quantity_not_positive',
    'fiscal_document.quantity_exceeds_invoiceable',
    'fiscal_document.series_missing',
    'fiscal_document.series_not_of_type',
    'fiscal_document.unknown_cancellation_reason',
    'fiscal_document.unknown_usage',
    'fiscal_document.version_not_printable',
    'image.too_large',
    'inventory_document.already_cancelled',
    'inventory_document.insufficient_stock',
    'inventory_document.line_without_quantity',
    'inventory_document.no_lines',
    'inventory_transfer.over_received',
    'itinerary.stop_delivered_exceeds_sent',
    'itinerary.stop_shortfall_needs_reason',
    'kardex.range_too_long',
    'pac.rejected',
    'payment.currency_mismatch',
    'payment.exceeds_order_balance',
    'payment.exceeds_unapplied',
    'product.lookup_too_many',
    'product.not_purchasable',
    'product.not_stockable',
    'purchase_request.lines_on_live_order',
    'product_price.references_not_found',
    'refund.line_invoiced',
    'resource.already_exists',
    'resource.not_found',
    'sales_order.below_min_quantity',
    'supplier_agreement.end_before_start',
    'taxpayer_certificate.holder_mismatch',
    'taxpayer_issuer.unknown',
    'vehicle.open_itinerary_exists',
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
    expect(checked, 225);
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
  // The last `Period` is the dot; an earlier one belongs to the noun
  // (`commission_period.*`).
  final cut = code.name.lastIndexOf('Period');
  final parts = [
    code.name.substring(0, cut),
    code.name.substring(cut + 'Period'.length),
  ];
  String snake(String camel) => camel.replaceAllMapped(
    RegExp('[A-Z]'),
    (m) => '_${m.group(0)!.toLowerCase()}',
  );
  return '${snake(parts[0])}.${snake(parts[1]).replaceFirst('_', '')}';
}
