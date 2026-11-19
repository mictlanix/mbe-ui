import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';

import 'fiscal_document_fixtures.dart';

void main() {
  group('payment receipt getters (spec 074 R12)', () {
    test('isPaymentReceipt is type 200 only', () {
      expect(aPaymentReceipt().isPaymentReceipt, isTrue);
      expect(aDocument().isPaymentReceipt, isFalse);
      expect(aCreditNote().isPaymentReceipt, isFalse);
      expect(aDocument(typeCode: 4).isPaymentReceipt, isFalse);
    });

    test('a receipt edits and reopens like an invoice, in every state', () {
      for (final status in FiscalDocumentStatus.values) {
        final receipt = aPaymentReceipt(status: status);
        final invoice = aDocument(status: status);
        expect(
          receipt.isEditableDraft,
          invoice.isEditableDraft,
          reason: '$status isEditableDraft',
        );
        expect(
          receipt.canReopen,
          invoice.canReopen,
          reason: '$status canReopen',
        );
      }
    });

    test('only an issued invoice can start a credit note, never a receipt', () {
      expect(
        aPaymentReceipt(status: FiscalDocumentStatus.issued).canIssueCreditNote,
        isFalse,
      );
    });

    test('assigned and unassigned follow the paid invoices', () {
      final receipt = aPaymentReceipt(
        paymentAmount: Decimal.parse('11600.00'),
        paidInvoices: [
          aPaidInvoice(amount: '8000.00'),
          aPaidInvoice(relationId: 32, amount: '3600.00'),
        ],
      );
      expect(receipt.assignedAmount, Decimal.parse('11600.00'));
      expect(receipt.unassignedAmount, Decimal.zero);

      final partial = aPaymentReceipt(
        paymentAmount: Decimal.parse('11600.00'),
        paidInvoices: [aPaidInvoice(amount: '9000.00')],
      );
      expect(partial.unassignedAmount, Decimal.parse('2600.00'));
    });

    test('unassigned is unknown while the payment amount is', () {
      final receipt = aDocument(typeCode: 200, paymentAmount: null);
      expect(receipt.unassignedAmount, isNull);
      expect(receipt.assignedAmount, Decimal.zero);
    });

    test('the no-proposal banner is for a payment-backed draft with no '
        'paid invoices only', () {
      expect(aPaymentReceipt(paysInvoice: false).showsNoProposalBanner, isTrue);
      expect(aPaymentReceipt().showsNoProposalBanner, isFalse);
      expect(
        aPaymentReceipt(
          paysInvoice: false,
          customerPaymentId: null,
        ).showsNoProposalBanner,
        isFalse,
      );
      expect(
        aPaymentReceipt(
          paysInvoice: false,
          status: FiscalDocumentStatus.sealed,
        ).showsNoProposalBanner,
        isFalse,
      );
      expect(aDocument().showsNoProposalBanner, isFalse);
    });

    test('needsPaymentForm covers a receipt draft stored on form 99', () {
      expect(aPaymentReceipt(paymentForm: 99).needsPaymentForm, isTrue);
      expect(aPaymentReceipt().needsPaymentForm, isFalse);
      expect(
        aPaymentReceipt(
          paymentForm: 99,
          status: FiscalDocumentStatus.sealed,
        ).needsPaymentForm,
        isFalse,
      );
      // An invoice on 99 is not flagged: only credit notes and receipts are.
      expect(aDocument().needsPaymentForm, isFalse);
    });

    test('the ordering bank is the reference, on a receipt only', () {
      expect(aPaymentReceipt(reference: 'Banco Ext').orderingBank, 'Banco Ext');
      expect(aDocument(reference: 'R-1').orderingBank, isNull);
    });

    test('a paid invoice labels its folio, or #id without a serial', () {
      expect(aPaidInvoice().folioLabel, 'A5238');
      expect(aPaidInvoice(serial: null).folioLabel, '#12');
      expect(aPaidInvoice(series: null, serial: 9).folioLabel, '9');
    });
  });
}
