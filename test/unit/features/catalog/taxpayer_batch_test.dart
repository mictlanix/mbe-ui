import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';

TaxpayerBatchResponse _response({
  int type = 0,
  bool inUse = false,
  void Function(BatchTemplateBuilder)? template,
}) => TaxpayerBatchResponse(
  (b) => b
    ..taxpayerBatchId = 7
    ..taxpayer = 'XAXX010101000'
    ..batch = 'A'
    ..type = type
    ..inUse = inUse
    ..template.replace(
      BatchTemplate((t) {
        t.name = 'Factura';
        template?.call(t);
      }),
    ),
);

void main() {
  group('TaxpayerBatch.fromResponse', () {
    test('maps the series, its kind, the in-use flag and the template', () {
      final batch = TaxpayerBatch.fromResponse(
        _response(
          type: 100,
          inUse: true,
          template: (t) => t
            ..logo = 'logo.png'
            ..headerHeight = 5
            ..footerHeight = 20
            ..extraInfo = ListBuilder<BatchAccount>([
              BatchAccount(
                (a) => a
                  ..bank = 'BBVA'
                  ..account = '0123456789'
                  ..clabe = '012180001234567891'
                  ..currency = 'MXN',
              ),
            ]),
        ),
      );

      expect(batch.taxpayerBatchId, 7);
      expect(batch.taxpayer, 'XAXX010101000');
      expect(batch.series, 'A');
      expect(batch.typeCode, 100);
      expect(batch.kind, FiscalDocumentKind.creditNote);
      expect(batch.inUse, isTrue);
      expect(batch.template.name, 'Factura');
      expect(batch.template.logo, 'logo.png');
      expect(batch.template.headerHeight, 5);
      expect(batch.template.footerHeight, 20);
      expect(batch.template.accounts.single.bank, 'BBVA');
      expect(batch.template.accounts.single.clabe, '012180001234567891');
    });

    test('a missing height or account list takes the API defaults', () {
      final batch = TaxpayerBatch.fromResponse(_response());

      expect(batch.template.headerHeight, 0);
      expect(batch.template.footerHeight, 15);
      expect(batch.template.accounts, isEmpty);
      expect(batch.template.logo, isNull);
    });

    test('accounts keep their order and a missing field becomes empty', () {
      final batch = TaxpayerBatch.fromResponse(
        _response(
          template: (t) => t
            ..extraInfo = ListBuilder<BatchAccount>([
              BatchAccount((a) => a..bank = 'Second'),
              BatchAccount((a) => a..bank = 'First'),
            ]),
        ),
      );

      expect(
        [for (final a in batch.template.accounts) a.bank],
        ['Second', 'First'],
      );
      expect(batch.template.accounts.first.account, '');
    });

    test('an unknown type code has no kind but keeps its code', () {
      final batch = TaxpayerBatch.fromResponse(_response(type: 7));

      expect(batch.kind, isNull);
      expect(batch.typeCode, 7);
    });
  });

  group('TaxpayerBatchAccount.isBlank', () {
    test('is true only when all four fields are empty once trimmed', () {
      expect(const TaxpayerBatchAccount().isBlank, isTrue);
      expect(
        const TaxpayerBatchAccount(bank: '  ', clabe: ' ').isBlank,
        isTrue,
      );
      expect(const TaxpayerBatchAccount(bank: 'BBVA').isBlank, isFalse);
      expect(const TaxpayerBatchAccount(currency: 'MXN').isBlank, isFalse);
    });
  });
}
