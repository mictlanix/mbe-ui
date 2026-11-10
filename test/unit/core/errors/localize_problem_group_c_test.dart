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

  test('the cost price list refusals explain themselves', () {
    expect(
      es(api.ErrorCode.priceListPeriodCostReadOnly),
      'Los precios de la lista de costos no se pueden editar aquí.',
    );
    expect(
      en(api.ErrorCode.priceListPeriodCostNotDeletable),
      "The cost list can't be deleted.",
    );
  });

  test('product.lookup_too_many shows the limit', () {
    expect(
      es(api.ErrorCode.productPeriodLookupTooMany, {'max': 1200}),
      'Demasiados productos a la vez. El máximo es 1,200.',
    );
    expect(en(api.ErrorCode.productPeriodLookupTooMany), isNull);
  });

  group('product_price.references_not_found', () {
    test('uses the plural noun with its gender', () {
      expect(
        es(api.ErrorCode.productPricePeriodReferencesNotFound, {
          'resource': 'price_list',
          'ids': [3, 4],
        }),
        'Algunas de las listas de precios de este cambio ya no existen. '
        'Recarga e inténtalo de nuevo.',
      );
      expect(
        es(api.ErrorCode.productPricePeriodReferencesNotFound, {
          'resource': 'product',
        }),
        'Algunos de los productos de este cambio ya no existen. '
        'Recarga e inténtalo de nuevo.',
      );
      expect(
        en(api.ErrorCode.productPricePeriodReferencesNotFound, {
          'resource': 'product',
        }),
        'Some of the products in this change no longer exist. '
        'Reload and try again.',
      );
    });

    test('a missing resource has no message', () {
      expect(en(api.ErrorCode.productPricePeriodReferencesNotFound), isNull);
    });
  });

  group('refund.line_invoiced', () {
    test('names the invoice folio when the server sends one', () {
      expect(
        es(api.ErrorCode.refundPeriodLineInvoiced, {
          'product_code': 'PT-001',
          'invoice': 'A-123',
        }),
        'PT-001 está en la factura A-123. Cancela o ajusta esa factura antes '
        'de devolverlo.',
      );
    });

    test('says "a live invoice" when it has no folio', () {
      expect(
        en(api.ErrorCode.refundPeriodLineInvoiced, {'product_code': 'PT-001'}),
        'PT-001 is on a live invoice. Cancel or adjust that invoice before '
        'refunding it.',
      );
    });

    test('a missing product code has no message', () {
      expect(en(api.ErrorCode.refundPeriodLineInvoiced), isNull);
    });
  });

  test('refund and quote refusals read in both languages', () {
    expect(
      es(api.ErrorCode.refundPeriodNothingRefundable),
      'No queda nada por devolver en este pedido.',
    );
    expect(
      en(api.ErrorCode.refundPeriodOrderNotPaid),
      "This order isn't paid. Cancel it instead of refunding it.",
    );
    expect(es(api.ErrorCode.quotePeriodExpired), 'Esta cotización ya venció.');
  });
}
