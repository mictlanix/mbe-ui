import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';

void main() {
  group('PaymentMethod.fromCode', () {
    test('resolves every confirmed member by its code (research §5)', () {
      const expected = {
        0: PaymentMethod.na,
        1: PaymentMethod.cash,
        2: PaymentMethod.check,
        3: PaymentMethod.eft,
        4: PaymentMethod.creditCard,
        5: PaymentMethod.electronicPurse,
        6: PaymentMethod.electronicMoney,
        8: PaymentMethod.foodVouchers,
        12: PaymentMethod.giving,
        27: PaymentMethod.toTheSatisfactionOfTheCreditor,
        28: PaymentMethod.debitCard,
        29: PaymentMethod.serviceCard,
        30: PaymentMethod.advancePayments,
        99: PaymentMethod.toBeDefined,
        1001: PaymentMethod.governmentFunding,
      };

      for (final entry in expected.entries) {
        expect(
          PaymentMethod.fromCode(entry.key),
          entry.value,
          reason: 'code ${entry.key}',
        );
      }
    });

    test('the codes are non-contiguous — gaps are NOT accidentally mapped', () {
      // A sample of the gaps between the confirmed members (7, 9-11, 13-26).
      for (final gap in [7, 9, 10, 11, 13, 20, 26]) {
        expect(PaymentMethod.fromCode(gap), isNull, reason: 'gap $gap');
      }
    });

    test('an unmapped code falls back to null (caller renders the raw value)', () {
      expect(PaymentMethod.fromCode(9999), isNull);
    });

    test('every PaymentMethod.values member round-trips through its own code', () {
      for (final method in PaymentMethod.values) {
        expect(PaymentMethod.fromCode(method.code), method);
      }
    });

    test('the provisional 1001 GovernmentFunding member is present', () {
      // research §5: a non-SAT mbe extension, kept with a // FIXME marker for
      // easy removal — this test only asserts it currently resolves.
      expect(PaymentMethod.fromCode(1001), PaymentMethod.governmentFunding);
    });
  });
}
