import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';

void main() {
  group('paymentMethodIcon', () {
    test('maps the common tenders to their tile icons', () {
      expect(paymentMethodIcon(PaymentMethod.cash.code), Icons.payments_outlined);
      expect(
        paymentMethodIcon(PaymentMethod.creditCard.code),
        Icons.credit_score_outlined,
      );
      expect(
        paymentMethodIcon(PaymentMethod.debitCard.code),
        Icons.credit_card_outlined,
      );
      expect(
        paymentMethodIcon(PaymentMethod.eft.code),
        Icons.account_balance_outlined,
      );
    });

    test('maps one code from every other group in the table', () {
      expect(paymentMethodIcon(PaymentMethod.check.code), Icons.receipt_long_outlined);
      expect(
        paymentMethodIcon(PaymentMethod.electronicPurse.code),
        Icons.account_balance_wallet_outlined,
      );
      expect(
        paymentMethodIcon(PaymentMethod.electronicMoney.code),
        Icons.account_balance_wallet_outlined,
      );
      expect(
        paymentMethodIcon(PaymentMethod.foodVouchers.code),
        Icons.restaurant_outlined,
      );
      expect(paymentMethodIcon(PaymentMethod.giving.code), Icons.swap_horiz);
      expect(
        paymentMethodIcon(PaymentMethod.advancePayments.code),
        Icons.schedule_outlined,
      );
    });

    test('falls back to the plain payments glyph for an unrecognized code', () {
      expect(paymentMethodIcon(9999), Icons.payments_outlined);
    });
  });
}
