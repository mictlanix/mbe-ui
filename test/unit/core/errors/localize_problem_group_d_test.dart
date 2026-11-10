import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_test_env.dart';

void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  String? en(api.ErrorCode code, [Map<String, Object?> params = const {}]) =>
      localizeProblem(
        ApiProblem(codeName: 'x', code: code, params: params),
        env.en,
        env.fmtEn,
      );
  String? es(api.ErrorCode code, [Map<String, Object?> params = const {}]) =>
      localizeProblem(
        ApiProblem(codeName: 'x', code: code, params: params),
        env.es,
        env.fmtEs,
      );

  test('sales_order.below_min_quantity shows the minimum', () {
    expect(
      es(api.ErrorCode.salesOrderPeriodBelowMinQuantity, {
        'product_id': 7,
        'min_order_qty': 12,
      }),
      'Un producto está por debajo de su pedido mínimo de 12.',
    );
    expect(en(api.ErrorCode.salesOrderPeriodBelowMinQuantity), isNull);
  });

  test('supplier_agreement.end_before_start formats both dates', () {
    const params = {'start': '2026-01-01', 'end': '2025-12-31'};
    expect(
      en(api.ErrorCode.supplierAgreementPeriodEndBeforeStart, params),
      'The end date (2025-12-31) is before the start date (2026-01-01).',
    );
    expect(
      es(api.ErrorCode.supplierAgreementPeriodEndBeforeStart, params),
      'La fecha de fin (2025-12-31) es anterior a la de inicio (2026-01-01).',
    );
    expect(
      en(api.ErrorCode.supplierAgreementPeriodEndBeforeStart, {
        'start': 'someday',
        'end': '2025-12-31',
      }),
      isNull,
    );
  });

  test('taxpayer refusals name the taxpayers', () {
    expect(
      es(api.ErrorCode.taxpayerCertificatePeriodHolderMismatch, {
        'certificate_taxpayer': 'ACME SA',
        'taxpayer': 'BETA SA',
      }),
      'El certificado es de ACME SA, no de BETA SA.',
    );
    expect(
      en(api.ErrorCode.taxpayerIssuerPeriodUnknown, {
        'taxpayer': 'XAXX010101000',
      }),
      "The issuer XAXX010101000 isn't registered.",
    );
  });

  test('user and warehouse refusals read in both languages', () {
    expect(
      es(api.ErrorCode.userPeriodNoPointOfSale),
      'Tu usuario no tiene un punto de venta asignado.',
    );
    expect(
      en(api.ErrorCode.warehousePeriodRequired, {'resource': 'purchase_order'}),
      'Choose a warehouse. Your point of sale has none.',
    );
    expect(
      es(api.ErrorCode.salesOrderPeriodPaidCannotCancel),
      'Un pedido pagado no se puede cancelar. Haz una devolución.',
    );
  });

  group('refusals that list the lines at fault', () {
    ApiProblem dict(api.ErrorCode code, List<String> items) =>
        ApiProblem(codeName: 'x', code: code, detailItems: items);

    test("today's dict: headline, then the server's line for each item", () {
      final problem = dict(api.ErrorCode.salesOrderPeriodZeroPricedLines, [
        '`A-1` has no price',
        '`B-2` has no price',
      ]);

      expect(
        localizeProblem(problem, env.es, env.fmtEs),
        'Algunas partidas no tienen precio:\n'
        '`A-1` has no price\n'
        '`B-2` has no price',
      );
      expect(
        localizeProblem(problem, env.en, env.fmtEn),
        'Some lines have no price:\n`A-1` has no price\n`B-2` has no price',
      );
    });

    test('phase 3: parts with a code this client does not know show their '
        'product code', () {
      const problem = ApiProblem(
        codeName: 'x',
        code: api.ErrorCode.salesOrderPeriodInsufficientStock,
        parts: [
          ApiProblemPart(
            codeName: 'future.line',
            params: {'product_code': 'A-1'},
          ),
          ApiProblemPart(
            codeName: 'future.line',
            params: {'product_code': 'B-2'},
          ),
        ],
      );

      expect(
        localizeProblem(problem, env.es, env.fmtEs),
        'Algunas partidas no tienen existencia suficiente:\nA-1\nB-2',
      );
    });

    test('phase 3: a part with a known code is localized', () {
      const problem = ApiProblem(
        codeName: 'x',
        code: api.ErrorCode.salesOrderPeriodMissingDeliveryDetails,
        parts: [
          ApiProblemPart(
            codeName: 'sales_order.no_lines',
            code: api.ErrorCode.salesOrderPeriodNoLines,
          ),
        ],
      );

      expect(
        localizeProblem(problem, env.en, env.fmtEn),
        'Delivery details are missing:\n'
        'Add at least one line before confirming.',
      );
    });

    test('no items at all is just the headline', () {
      expect(
        localizeProblem(
          dict(api.ErrorCode.salesOrderPeriodInsufficientStock, const []),
          env.en,
          env.fmtEn,
        ),
        "Some lines don't have enough stock",
      );
    });

    test('both shapes list the same lines in the same order', () {
      const parts = ApiProblem(
        codeName: 'x',
        code: api.ErrorCode.salesOrderPeriodZeroPricedLines,
        parts: [
          ApiProblemPart(params: {'product_code': 'A-1'}),
          ApiProblemPart(params: {'product_code': 'B-2'}),
        ],
      );
      final items = dict(api.ErrorCode.salesOrderPeriodZeroPricedLines, [
        'A-1',
        'B-2',
      ]);

      expect(
        localizeProblem(parts, env.en, env.fmtEn),
        localizeProblem(items, env.en, env.fmtEn),
      );
    });
  });
}
