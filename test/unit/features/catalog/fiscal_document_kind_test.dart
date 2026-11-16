import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/presentation/fiscal_document_kind_label.dart';
import 'package:mbe_ui/l10n/app_localizations_es.dart';

void main() {
  // The API's FiscalDocumentType codes (spec 066 R2): the names follow the
  // codes, not the other way round.
  const expected = {
    0: (FiscalDocumentKind.invoice, 'Factura'),
    1: (FiscalDocumentKind.feeReceipt, 'Recibo de honorarios'),
    2: (FiscalDocumentKind.rentReceipt, 'Recibo de arrendamiento'),
    3: (FiscalDocumentKind.debitNote, 'Nota de cargo'),
    100: (FiscalDocumentKind.creditNote, 'Nota de crédito'),
    101: (FiscalDocumentKind.advancePaymentsApplied, 'Aplicación de anticipos'),
    200: (FiscalDocumentKind.paymentReceipt, 'Recibo de pago'),
  };

  test('each code maps to its kind and Spanish label', () {
    final l10n = AppLocalizationsEs();
    for (final e in expected.entries) {
      final kind = FiscalDocumentKind.fromCode(e.key);
      expect(kind, e.value.$1, reason: 'code ${e.key}');
      expect(kind!.code, e.key);
      expect(fiscalDocumentKindLabel(l10n, kind), e.value.$2);
    }
  });

  test('has the seven codes the API exchanges, in sort order', () {
    expect(
      [for (final k in FiscalDocumentKind.values) k.code],
      [0, 1, 2, 3, 100, 101, 200],
    );
    expect(FiscalDocumentKind.values.first, FiscalDocumentKind.invoice);
    expect(FiscalDocumentKind.values, hasLength(expected.length));
  });

  test('every known code round-trips', () {
    for (final kind in FiscalDocumentKind.values) {
      expect(FiscalDocumentKind.fromCode(kind.code), kind);
    }
  });

  test('an unknown code has no kind', () {
    for (final code in [-1, 4, 7, 99, 102, 999]) {
      expect(FiscalDocumentKind.fromCode(code), isNull, reason: '$code');
    }
  });
}
