import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/l10n/app_localizations_en.dart';
import 'package:mbe_ui/l10n/app_localizations_es.dart';

void main() {
  group('PaymentType.fromApi', () {
    test('maps every generated value to its type', () {
      expect(PaymentType.fromApi(api.PaymentType.number0), PaymentType.na);
      expect(
        PaymentType.fromApi(api.PaymentType.number1),
        PaymentType.immediate,
      );
      expect(
        PaymentType.fromApi(api.PaymentType.number2),
        PaymentType.creditPayment,
      );
      expect(
        PaymentType.fromApi(api.PaymentType.number3),
        PaymentType.paymentInAdvance,
      );
      expect(
        PaymentType.fromApi(api.PaymentType.number4),
        PaymentType.creditNote,
      );
      expect(PaymentType.fromApi(api.PaymentType.number5), PaymentType.expense);
    });

    test('covers all six generated members, so none is unmapped', () {
      expect(api.PaymentType.values, hasLength(PaymentType.values.length));
      for (final value in api.PaymentType.values) {
        expect(() => PaymentType.fromApi(value), returnsNormally);
      }
    });
  });

  group('PaymentType.hasTicket (spec 055 R5)', () {
    test('only a credit payment and a payment in advance have a ticket', () {
      expect(PaymentType.values.where((t) => t.hasTicket), [
        PaymentType.creditPayment,
        PaymentType.paymentInAdvance,
      ]);
    });
  });

  group('paymentTypeLabel (FR-017)', () {
    test('uses the legacy system words in Spanish', () {
      final es = AppLocalizationsEs();
      expect(PaymentType.values.map((t) => paymentTypeLabel(es, t)).toList(), [
        'N/A',
        'Contado',
        'Pago de crédito',
        'Pago anticipado',
        'Nota de crédito',
        'Gasto',
      ]);
    });

    test('has an English label for every type', () {
      final en = AppLocalizationsEn();
      for (final type in PaymentType.values) {
        expect(paymentTypeLabel(en, type), isNotEmpty);
      }
    });
  });

  group('currencyCodeLabel (R9)', () {
    test('covers the three currencies', () {
      expect(currencyCodeLabel(Currency.mxn), 'MXN');
      expect(currencyCodeLabel(Currency.usd), 'USD');
      expect(currencyCodeLabel(Currency.eur), 'EUR');
    });
  });
}
