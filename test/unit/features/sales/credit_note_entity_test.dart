import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';

api.CreditNoteResponse _response({
  String amount = '27.0000',
  String remaining = '3',
}) => api.CreditNoteResponse(
  (b) => b
    ..creditNoteId = 990
    ..customer = 10653
    ..salesOrder = 343533
    ..customerRefund = 9605
    ..customerPayment = 300743
    ..facility = 8
    ..amount = amount
    ..refunded = '0.000000'
    ..refundedToCustomer = false
    ..remaining = remaining
    ..cashSession = null
    ..date = DateTime(2026, 9, 29, 12, 55, 20),
);

void main() {
  test('fromResponse carries the server figures exactly as sent (FR-015)', () {
    final note = CreditNote.fromResponse(
      _response(amount: '27.0000', remaining: '3'),
    );

    expect(note.id, 990);
    expect(note.customerId, 10653);
    expect(note.salesOrderId, 343533);
    expect(note.customerRefundId, 9605);
    expect(note.customerPaymentId, 300743);
    // Issued is the backing payment's amount (mbe-api spec 034 FR-001).
    expect(note.issued, '27.0000');
    expect(note.remaining, '3');
    expect(note.date, DateTime(2026, 9, 29, 12, 55, 20));
  });

  group('isOpen', () {
    test('is false for "0" and "0.000000"', () {
      expect(
        CreditNote.fromResponse(_response(remaining: '0')).isOpen,
        isFalse,
      );
      expect(
        CreditNote.fromResponse(_response(remaining: '0.000000')).isOpen,
        isFalse,
      );
    });

    test('is true when something is left', () {
      expect(
        CreditNote.fromResponse(_response(remaining: '0.01')).isOpen,
        isTrue,
      );
    });
  });
}
