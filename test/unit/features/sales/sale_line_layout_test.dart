import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/presentation/capture/sale_line_layout.dart';

/// spec 040 FR-014, research.md R1: a warehouse-less row (a quote line) must
/// reach single-row layout at its own, lower threshold rather than falling
/// back to the two-row layout at widths where it would otherwise fit
/// comfortably. Pure logic, tested directly — a widget-level pixel
/// measurement close to the boundary is sensitive to unrelated rendering
/// noise (a narrow dropdown's own minimum comfortable width), which is why
/// `sale_line_symmetry_test.dart`'s widget coverage tests baseline-sharing
/// at a comfortable width instead, matching this file's own house
/// convention of separating "does it fit" from "is it aligned".
void main() {
  group('saleLineLayoutFor', () {
    test('a width between the two thresholds is single-row without a '
        'warehouse column and two-row with one', () {
      const width = 800.0;
      expect(width, greaterThan(saleLineSingleRowMinWidthNoWarehouse));
      expect(width, lessThan(saleLineSingleRowMinWidth));

      expect(
        saleLineLayoutFor(width, warehouse: false),
        SaleLineLayout.singleRow,
      );
      expect(saleLineLayoutFor(width), SaleLineLayout.twoRow);
    });

    test('exactly at its own threshold, a warehouse-less row is single-row', () {
      expect(
        saleLineLayoutFor(saleLineSingleRowMinWidthNoWarehouse, warehouse: false),
        SaleLineLayout.singleRow,
      );
    });

    test('just below its own threshold, a warehouse-less row falls back to '
        'two-row, same as a warehoused row does at its own', () {
      expect(
        saleLineLayoutFor(
          saleLineSingleRowMinWidthNoWarehouse - 1,
          warehouse: false,
        ),
        SaleLineLayout.twoRow,
      );
    });

    test('the default (warehouse: true) is unchanged from before this '
        'feature', () {
      expect(
        saleLineLayoutFor(saleLineSingleRowMinWidth),
        SaleLineLayout.singleRow,
      );
      expect(
        saleLineLayoutFor(saleLineSingleRowMinWidth - 1),
        SaleLineLayout.twoRow,
      );
    });
  });

  group('SaleLineColumns.of', () {
    test('a warehouse-less budget reserves no width for the column', () {
      final columns = SaleLineColumns.of(1200, warehouse: false);
      expect(columns.warehouse, 0);
    });

    test('the default (warehouse: true) is unchanged from before this '
        'feature', () {
      final floor = SaleLineColumns.of(saleLineSingleRowMinWidth);
      expect(floor.warehouse, SaleLineColumns.floor.warehouse);
      final comfortable = SaleLineColumns.of(saleLineComfortableWidth);
      expect(comfortable.warehouse, SaleLineColumns.comfortable.warehouse);
    });

    test('every other column still interpolates toward comfortable as width '
        'grows, with or without a warehouse column', () {
      final narrow = SaleLineColumns.of(
        saleLineSingleRowMinWidthNoWarehouse,
        warehouse: false,
      );
      final wide = SaleLineColumns.of(saleLineComfortableWidth, warehouse: false);
      expect(wide.quantity, greaterThan(narrow.quantity));
      expect(wide.price, greaterThan(narrow.price));
      expect(wide.discount, greaterThan(narrow.discount));
      expect(wide.tax, greaterThan(narrow.tax));
      expect(wide.total, greaterThan(narrow.total));
    });
  });
}
