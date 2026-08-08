import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/pos_resume_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';

/// Where a resumed sale reopens, derived from what the sale itself records
/// (FR-057, contracts/pos-screen.md §5) rather than from screen state.
const _facilityAddress = 500;

Sale _sale({required SaleStatus status, int? shipTo}) => Sale(
  id: 42,
  facility: 9,
  pointSale: 3,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  shipTo: shipTo,
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
