import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';

void main() {
  group('FiscalDocumentKind', () {
    test('has the seven codes the API exchanges, in sort order', () {
      expect(
        [for (final k in FiscalDocumentKind.values) k.code],
        [0, 1, 2, 3, 100, 101, 200],
      );
      expect(FiscalDocumentKind.values.first, FiscalDocumentKind.invoice);
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
  });
}
