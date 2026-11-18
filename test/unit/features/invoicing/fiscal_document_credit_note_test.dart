import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';

import 'fiscal_document_fixtures.dart';

void main() {
  group('credit-note getters (spec 073 R8)', () {
    test('isCreditNote is type 100 only', () {
      expect(aCreditNote().isCreditNote, isTrue);
      expect(aDocument().isCreditNote, isFalse);
      expect(aDocument(typeCode: 4).isCreditNote, isFalse);
    });

    test('a credit note that relates its invoice edits and reopens like an '
        'invoice', () {
      for (final status in FiscalDocumentStatus.values) {
        final note = aCreditNote(status: status);
        final invoice = aDocument(status: status);
        expect(
          note.isEditableDraft,
          invoice.isEditableDraft,
          reason: '$status isEditableDraft',
        );
        expect(note.canReopen, invoice.canReopen, reason: '$status canReopen');
      }
      expect(aCreditNote().isEditableDraft, isTrue);
      expect(
        aCreditNote(status: FiscalDocumentStatus.sealed).canReopen,
        isTrue,
      );
    });

    test('a credit note with no relation is never editable or reopenable', () {
      for (final status in FiscalDocumentStatus.values) {
        final note = aCreditNote(status: status, withRelation: false);
        expect(note.isEditableDraft, isFalse, reason: '$status');
        expect(note.canReopen, isFalse, reason: '$status');
      }
    });

    test('a credit note whose only relation is not type 01 has no credited '
        'invoice and is read-only', () {
      final note = aDocument(
        typeCode: 100,
        relations: [aRelation(type: InvoiceRelationType.substitution)],
      );
      expect(note.creditedInvoice, isNull);
      expect(note.isEditableDraft, isFalse);
    });

    test('other types stay read-only', () {
      final payment = aDocument(typeCode: 4);
      expect(payment.isEditableDraft, isFalse);
      expect(
        aDocument(typeCode: 4, status: FiscalDocumentStatus.sealed).canReopen,
        isFalse,
      );
    });

    test('canIssueCreditNote is an issued invoice only', () {
      for (final status in FiscalDocumentStatus.values) {
        expect(
          aDocument(status: status).canIssueCreditNote,
          status == FiscalDocumentStatus.issued,
          reason: '$status',
        );
        expect(aCreditNote(status: status).canIssueCreditNote, isFalse);
      }
    });

    test('creditedInvoice is the type-01 relation of a credit note', () {
      final note = aDocument(
        typeCode: 100,
        relations: [
          aRelation(id: 1, documentId: 30, type: null),
          aRelation(id: 2, documentId: 12),
        ],
      );
      expect(note.creditedInvoice?.documentId, 12);
      expect(aCreditNote(withRelation: false).creditedInvoice, isNull);
      // An invoice never has one, even with a 01 relation row.
      expect(aDocument(relations: [aRelation()]).creditedInvoice, isNull);
    });

    test('needsPaymentForm is a credit-note draft on form 99', () {
      expect(aCreditNote(paymentForm: 99).needsPaymentForm, isTrue);
      expect(aCreditNote(paymentForm: 3).needsPaymentForm, isFalse);
      expect(
        aCreditNote(
          paymentForm: 99,
          status: FiscalDocumentStatus.sealed,
        ).needsPaymentForm,
        isFalse,
      );
      expect(aDocument(paymentForm: 99).needsPaymentForm, isFalse);
    });
  });
}
