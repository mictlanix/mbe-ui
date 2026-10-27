import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';

api.CustomerPaymentResponse _payment({
  int? verifier,
  int? cashSession = 812,
  int? paymentCharge = 5,
  String? reference = 'SPEI 98123',
  int currency = 0,
  int method = 3,
  int paymentType = 2,
}) => appSerializers.deserializeWith(api.CustomerPaymentResponse.serializer, {
  'customer_payment_id': 18342,
  'customer': 77,
  'amount': '1250.00',
  'currency': currency,
  'method': method,
  'payment_charge': paymentCharge,
  'reference': reference,
  'date': '2026-10-27T10:14:00',
  'facility': 3,
  'cash_session': cashSession,
  'payment_type': paymentType,
  'verifier': verifier,
  'unapplied': '250.00',
})!;

api.ApplicationResponse _application({bool cancelled = false}) =>
    appSerializers.deserializeWith(api.ApplicationResponse.serializer, {
      'sales_order_payment_id': 9,
      'sales_order': 5512,
      'customer_payment': 18342,
      'amount': '1000.00',
      'amount_change': '0.00',
      'applier': 4,
      'date': '2026-10-27T10:15:00',
      'cancelled': cancelled,
    })!;

void main() {
  group('CustomerPayment.fromResponse', () {
    test('carries every field', () {
      final p = CustomerPayment.fromResponse(_payment(verifier: 9));

      expect(p.customerPaymentId, 18342);
      expect(p.customerId, 77);
      expect(p.amount, '1250.00');
      expect(p.currency, Currency.mxn);
      expect(p.methodCode, 3);
      expect(p.paymentOptionId, 5);
      expect(p.reference, 'SPEI 98123');
      expect(p.date, DateTime(2026, 10, 27, 10, 14));
      expect(p.facilityId, 3);
      expect(p.cashSessionId, 812);
      expect(p.type, PaymentType.creditPayment);
      expect(p.verifierId, 9);
      expect(p.unapplied, '250.00');
    });

    test('keeps optional fields null for a migrated payment', () {
      final p = CustomerPayment.fromResponse(
        _payment(cashSession: null, paymentCharge: null, reference: null),
      );

      expect(p.cashSessionId, isNull);
      expect(p.paymentOptionId, isNull);
      expect(p.reference, isNull);
    });

    test('isVerified follows the verifier', () {
      expect(CustomerPayment.fromResponse(_payment()).isVerified, isFalse);
      expect(
        CustomerPayment.fromResponse(_payment(verifier: 9)).isVerified,
        isTrue,
      );
    });

    test('maps a foreign currency', () {
      final p = CustomerPayment.fromResponse(_payment(currency: 1));
      expect(p.currency, Currency.usd);
    });
  });

  group('PaymentApplication.fromResponse', () {
    test('carries every field and renames cancelled to reversed', () {
      final a = PaymentApplication.fromResponse(_application(cancelled: true));

      expect(a.id, 9);
      expect(a.saleId, 5512);
      expect(a.amount, '1000.00');
      expect(a.change, '0.00');
      expect(a.applierId, 4);
      expect(a.date, DateTime(2026, 10, 27, 10, 15));
      expect(a.reversed, isTrue);
    });

    test('a live application is not reversed', () {
      expect(PaymentApplication.fromResponse(_application()).reversed, isFalse);
    });
  });
}
