import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/pos_resume_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';

/// Where a resumed sale reopens, derived from what the sale itself records
/// (FR-057, contracts/pos-screen.md §5) rather than from screen state.
const _facilityAddress = 500;

Sale _sale({
  required SaleStatus status,
  int? shipTo,
  FulfillmentMode? fulfillmentIntent,
}) => Sale(
  id: 42,
  facility: 9,
  pointSale: 3,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  shipTo: shipTo,
  fulfillmentIntent: fulfillmentIntent,
  promiseDate: DateTime(2026, 8, 5),
  status: status,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  balance: '0',
);

void main() {
  group('the step a sale reopens at', () {
    test('a draft reopens on Venta', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.draft),
        facilityAddressId: _facilityAddress,
      );
      expect(target.step, PosStep.venta);
    });

    test('a confirmed but unpaid sale reopens on Cobro', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.completed),
        facilityAddressId: _facilityAddress,
      );
      expect(target.step, PosStep.cobro);
    });

    test('a paid counter sale reopens on Cobro — nothing is owed, and the '
        'screen offers a new sale from there', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.paid, shipTo: _facilityAddress),
        facilityAddressId: _facilityAddress,
      );
      expect(target.step, PosStep.cobro);
      expect(target.mode, FulfillmentMode.counterPickup);
    });

    test('a paid delivery sale reopens on Entrega — it still owes its '
        'distribution', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.paid, shipTo: 777),
        facilityAddressId: _facilityAddress,
      );
      expect(target.step, PosStep.entrega);
      expect(target.mode, FulfillmentMode.delivery);
    });

    test('a cancelled sale reopens read-only on Venta rather than crashing — '
        'the selector never offers one, but a stale link might', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.cancelled),
        facilityAddressId: _facilityAddress,
      );
      expect(target.step, PosStep.venta);
    });
  });

  group('the mode a sale reopens in (FR-057)', () {
    test('shipTo equal to the facility address means counter pickup', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.draft, shipTo: _facilityAddress),
        facilityAddressId: _facilityAddress,
      );
      expect(target.mode, FulfillmentMode.counterPickup);
    });

    test('any other shipTo means delivery', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.draft, shipTo: 777),
        facilityAddressId: _facilityAddress,
      );
      expect(target.mode, FulfillmentMode.delivery);
    });

    test('no shipTo at all is counter pickup — nothing has been chosen yet', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.draft),
        facilityAddressId: _facilityAddress,
      );
      expect(target.mode, FulfillmentMode.counterPickup);
    });
  });

  group('a recorded fulfilmentIntent is trusted over the shipTo heuristic '
      '(mbe-api#170/#171)', () {
    test('mixed survives a resume — the bug the address alone could not fix',
        () {
      // A mixed sale writes the customer's address, byte-identical to a
      // pure-delivery one — the whole reason the address heuristic could
      // never recover `mixed`. `fulfillmentIntent` is the fix.
      final target = resumeTargetFor(
        _sale(
          status: SaleStatus.paid,
          shipTo: 777,
          fulfillmentIntent: FulfillmentMode.mixed,
        ),
        facilityAddressId: _facilityAddress,
      );
      expect(target.mode, FulfillmentMode.mixed);
      expect(target.step, PosStep.entrega, reason: 'mixed still owes its distribution');
    });

    test('a recorded counterPickup is trusted even without shipTo agreeing '
        'yet', () {
      final target = resumeTargetFor(
        _sale(
          status: SaleStatus.draft,
          shipTo: 777, // Not yet reflecting the choice — irrelevant here.
          fulfillmentIntent: FulfillmentMode.counterPickup,
        ),
        facilityAddressId: _facilityAddress,
      );
      expect(target.mode, FulfillmentMode.counterPickup);
    });

    test('a null intent falls back to the address heuristic, as before '
        '#170', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.draft, shipTo: 777),
        facilityAddressId: _facilityAddress,
      );
      // shipTo (777) differs from the facility address (500), so the
      // fallback heuristic reads this as delivery — exactly today's
      // pre-#170 behaviour, and the ceiling that heuristic could never see
      // past (it cannot tell this apart from a mixed sale with the same
      // shipTo, which is the bug #170 filed).
      expect(target.mode, FulfillmentMode.delivery);
    });
  });

  group('the mode a sale reopens in, without a facility address to hand '
      '(FR-057)', () {
    test('a draft still resolves to Venta without the facility address — it '
        'never affected that answer', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.draft, shipTo: 777),
        facilityAddressId: null,
      );
      expect(target.step, PosStep.venta);
    });

    test('an unpaid sale still resolves to Cobro without it', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.completed, shipTo: 777),
        facilityAddressId: null,
      );
      expect(target.step, PosStep.cobro);
    });

    test('an unknown facility address never promotes a sale to delivery — a '
        'slow *or failed* lookup must not land a counter sale on the wrong '
        'step', () {
      final target = resumeTargetFor(
        _sale(status: SaleStatus.paid, shipTo: 777),
        facilityAddressId: null,
      );
      expect(target.mode, FulfillmentMode.counterPickup);
      expect(
        target.step,
        PosStep.cobro,
        reason: 'without the facility address it cannot be known to be a '
            'delivery sale, so Entrega is not asserted',
      );
    });
  });
}
