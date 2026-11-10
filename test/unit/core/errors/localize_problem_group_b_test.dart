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

  test('delivery quantities go through the quantity formatter', () {
    const params = {
      'sales_order_line_id': 5,
      'remaining': '2',
      'requested': '3',
    };
    expect(
      es(api.ErrorCode.deliveryOrderPeriodQuantityExceedsRemaining, params),
      'Pediste 3, pero en esa partida solo quedan 2 por entregar.',
    );
    expect(
      en(api.ErrorCode.deliveryOrderPeriodQuantityExceedsRemaining, params),
      'You asked for 3, but only 2 are left to deliver on that line.',
    );
    expect(
      en(api.ErrorCode.deliveryOrderPeriodQuantityExceedsRemaining, {
        'requested': '3',
      }),
      isNull,
    );
  });

  group('image.too_large', () {
    test('renders whole megabytes and rounds partial ones up to kilobytes', () {
      expect(
        en(api.ErrorCode.imagePeriodTooLarge, {'max_bytes': 5242880}),
        'The image is too large. The maximum is 5 MB.',
      );
      expect(
        es(api.ErrorCode.imagePeriodTooLarge, {'max_bytes': 1572864}),
        'La imagen es demasiado grande. El máximo es 1,536 KB.',
      );
    });

    test('a missing size has no message', () {
      expect(en(api.ErrorCode.imagePeriodTooLarge), isNull);
    });
  });

  test('facility.other_facility names the record kind with its gender', () {
    expect(
      es(api.ErrorCode.facilityPeriodOtherFacility, {
        'resource': 'sales_order',
      }),
      'Este pedido pertenece a otra sucursal, y no tienes acceso a otras '
      'sucursales.',
    );
    expect(
      es(api.ErrorCode.facilityPeriodOtherFacility, {
        'resource': 'customer_payment',
        'required': [
          {'system_object': 101, 'right': 2},
        ],
      }),
      'Este pago pertenece a otra sucursal, y no tienes acceso a otras '
      'sucursales.',
    );
    expect(
      en(api.ErrorCode.facilityPeriodOtherFacility, {
        'resource': 'sales_order',
      }),
      "This order belongs to another facility, and you don't have access to "
      'other facilities.',
    );
    expect(en(api.ErrorCode.facilityPeriodOtherFacility), isNull);
  });

  test('plain refusals read in both languages', () {
    expect(
      es(api.ErrorCode.deliveryOrderPeriodSalesOrderUnpaid),
      'La venta debe estar pagada o ser a crédito antes de poder entregarse.',
    );
    expect(
      en(api.ErrorCode.documentPeriodNotEditable, {'status': 'COMPLETED'}),
      "This document is completed or cancelled and can't be edited.",
    );
    expect(
      es(api.ErrorCode.lockPeriodBusy, {'resource': 'warehouse'}),
      'Alguien más está actualizando esto en este momento. Inténtalo de nuevo '
      'en un momento.',
    );
    expect(
      en(api.ErrorCode.emailPeriodNotConfigured),
      "Email isn't set up on the server.",
    );
  });
}
