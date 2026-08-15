import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/sale_workability.dart';

/// The six status/balance combinations `saleIsWorkable` decides between
/// (spec 023 data-model §3), and the one that needs the register's
/// open-sales set rather than the row alone.
OpenSale _sale({
  required SaleStatus status,
  String balance = '0',
  int id = 1,
}) => OpenSale(
  id: id,
  customerName: 'Acme',
  total: '100.00',
  balance: balance,
  status: status,
  date: DateTime(2026, 8, 10),
);

void main() {
  group('saleIsWorkable', () {
    test('a draft is always workable', () {
      expect(
        saleIsWorkable(_sale(status: SaleStatus.draft), resumableIds: const {}),
        isTrue,
      );
    });

    test('a cancelled sale is never workable, even with a balance', () {
      expect(
        saleIsWorkable(
          _sale(status: SaleStatus.cancelled, balance: '100.00'),
          resumableIds: const {},
        ),
        isFalse,
      );
    });

    test('a completed sale with a non-zero balance is workable', () {
      expect(
        saleIsWorkable(
          _sale(status: SaleStatus.completed, balance: '50.00'),
          resumableIds: const {},
        ),
        isTrue,
      );
    });

    test('a completed sale with a zero balance falls back to the resumable set', () {
      final sale = _sale(id: 7, status: SaleStatus.completed, balance: '0.00');
      expect(saleIsWorkable(sale, resumableIds: {7}), isTrue);
      expect(saleIsWorkable(sale, resumableIds: const {}), isFalse);
    });

    test('a paid sale with a non-zero balance is workable — it still owes money', () {
      expect(
        saleIsWorkable(
          _sale(status: SaleStatus.paid, balance: '25.00'),
          resumableIds: const {},
        ),
        isTrue,
      );
    });

    test(
      'a zero-balance paid sale is workable only when the resumable set says so',
      () {
        final sale = _sale(id: 9, status: SaleStatus.paid, balance: '0');
        expect(saleIsWorkable(sale, resumableIds: {9}), isTrue);
        expect(saleIsWorkable(sale, resumableIds: const {}), isFalse);
      },
    );

    test(
      'an unresolved (empty) resumable set makes a zero-balance paid sale '
      'provisionally not workable, never a doomed Edit',
      () {
        final sale = _sale(id: 3, status: SaleStatus.paid, balance: '0.00');
        expect(saleIsWorkable(sale, resumableIds: const {}), isFalse);
      },
    );

    test('"0.00" and "0" both count as a zero balance', () {
      final zeroDecimal = _sale(id: 5, status: SaleStatus.completed, balance: '0.00');
      final zeroPlain = _sale(id: 5, status: SaleStatus.completed, balance: '0');
      expect(saleIsWorkable(zeroDecimal, resumableIds: const {}), isFalse);
      expect(saleIsWorkable(zeroPlain, resumableIds: const {}), isFalse);
    });
  });
}
