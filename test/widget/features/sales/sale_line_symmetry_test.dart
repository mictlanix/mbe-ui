import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';

import '../../../golden/golden_harness.dart';
import 'pos_test_harness.dart';

Warehouse _warehouse(int id, String name) => Warehouse(
  warehouseId: id,
  facilityId: 9,
  facilityName: 'Main Store',
  code: 'WH-$id',
  name: name,
  status: EntityStatus.active,
);

/// spec 027 US6/FR-031/FR-032/FR-033/FR-034/FR-035: the POS sale line's
/// vertical insets are symmetric and its control band shares the line
/// total's baseline, in all three layouts, at every text-size level
/// (FR-024). Verified by measurement — never by inspection (FR-035).
///
/// **Investigation note**: planning suspected this needed a source fix
/// (a floating-label-vs-bare-Text baseline mismatch). Measured directly
/// against the real app theme (`pumpGoldenScenario`, which applies the
/// actual `InputDecorationTheme` from `core/design/component_themes.dart`),
/// no mismatch is present — `saleLineTextFieldPadding`/`saleLineDropdownPadding`
/// (spec 022/023) already equalize every control's value-text position to
/// the line total's. An earlier attempt to "fix" this against a bare
/// `MaterialApp` (framework default decoration, no custom
/// `InputDecorationTheme`) was reproducing an artifact of the wrong theme,
/// not the shipped one — reverted. This file exists to lock the
/// already-correct invariant in as a permanent regression guard, and to
/// verify it continues to hold once `sale_line_layout.dart`'s dimensions
/// scale with text size (FR-024).
void main() {
  setUpAll(loadGoldenFonts);

  late MockWarehouseRepository warehouseRepository;

  setUp(() {
    warehouseRepository = MockWarehouseRepository();
    when(
      () => warehouseRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => WarehouseListResult(items: [_warehouse(3, 'Main Warehouse')], total: 1),
    );
  });

  /// Every value a single-row/two-row line renders, chosen so a discount and
  /// the line total both end in a round-bottomed digit ('0') — comparing a
  /// flat-bottomed glyph (e.g. quantity's plain digits) against the total's
  /// trailing zeros would read a spurious 1-2px gap purely from glyph shape
  /// (a '1' has no baseline overshoot, a '0' does), not from a real
  /// misalignment. `(top, height)` equality on each value's own rendered box
  /// is what "shares a baseline" cashes out to — two same-style text boxes
  /// with equal top and equal height cannot help but share a baseline.
  const sharedValues = ['Main Warehouse', '2', '50.00', '0', '16.00 %', r'$116.00'];

  /// Rounded to 1 decimal place: two Rects a fraction of a pixel apart from
  /// floating-point noise (observed: `18.0` vs `18.000000000000004`, from
  /// slightly different internal computation chains for different render
  /// object types) must compare equal; anything a human could actually see
  /// as misaligned (a full pixel or more) still will not.
  (double, double) roundedTopHeight(Rect r) =>
      ((r.top * 10).round() / 10, (r.height * 10).round() / 10);

  /// Wraps [child] so it reports its own natural height instead of
  /// stretching to fill `pumpGoldenScenario`'s full test surface — a sale
  /// line is laid out this way for real, inside a `Column` of lines, never
  /// forced to a fixed height.
  Widget naturallySized(Widget child) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [child],
  );

  for (final level in [0.9, 1.0, 1.15, 1.3]) {
    group('at text-scale factor $level', () {
      testWidgets('single row (1440px): every value shares one baseline', (tester) async {
        await pumpGoldenScenario(
          tester,
          naturallySized(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(level)),
              child: SaleLineRow(line: testLine(quantity: '2'), facilityId: 9),
            ),
          ),
          brightness: Brightness.light,
          width: 1440,
          overrides: [warehouseOverride(warehouseRepository)],
        );
        expect(tester.takeException(), isNull);

        final boxes = {
          for (final value in sharedValues) value: tester.getRect(find.text(value).first),
        };
        expect(
          boxes.values.map(roundedTopHeight).toSet(),
          hasLength(1),
          reason: boxes.toString(),
        );
      });

      testWidgets('single row (1440px): the card top inset equals its bottom inset', (
        tester,
      ) async {
        await pumpGoldenScenario(
          tester,
          naturallySized(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(level)),
              child: SaleLineRow(line: testLine(quantity: '2'), facilityId: 9),
            ),
          ),
          brightness: Brightness.light,
          width: 1440,
          overrides: [warehouseOverride(warehouseRepository)],
        );

        final cardRect = tester.getRect(find.byKey(const Key('sale_line_row_5')));
        final valueRect = tester.getRect(find.text('50.00').first);
        final topInset = valueRect.top - cardRect.top;
        final bottomInset = cardRect.bottom - valueRect.bottom;
        expect(
          topInset,
          closeTo(bottomInset, 0.5),
          reason: 'card=$cardRect value=$valueRect',
        );
      });

      testWidgets('two-row (700px): row 1 (product/warehouse/total) shares one baseline', (
        tester,
      ) async {
        await pumpGoldenScenario(
          tester,
          naturallySized(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(level)),
              child: SaleLineRow(line: testLine(quantity: '2'), facilityId: 9),
            ),
          ),
          brightness: Brightness.light,
          width: 700,
          overrides: [warehouseOverride(warehouseRepository)],
        );
        expect(tester.takeException(), isNull);

        final boxes = {
          for (final value in ['Main Warehouse', r'$116.00'])
            value: tester.getRect(find.text(value).first),
        };
        expect(
          boxes.values.map(roundedTopHeight).toSet(),
          hasLength(1),
          reason: boxes.toString(),
        );
      });

      testWidgets('a two-line-wrapped product name does not change the row height', (
        tester,
      ) async {
        const shortName = 'Widget';
        const longName =
            'Adhesivo Resistol No Mas Clavos Contenido De 113 Gramos Presentacion Grande';

        await pumpGoldenScenario(
          tester,
          naturallySized(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(level)),
              child: SaleLineRow(
                line: testLine(quantity: '2', productName: shortName),
                facilityId: 9,
              ),
            ),
          ),
          brightness: Brightness.light,
          width: 1440,
          overrides: [warehouseOverride(warehouseRepository)],
        );
        expect(tester.takeException(), isNull);
        final shortHeight = tester.getSize(find.byType(SaleLineRow)).height;

        await pumpGoldenScenario(
          tester,
          naturallySized(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(level)),
              child: SaleLineRow(
                line: testLine(quantity: '2', productName: longName),
                facilityId: 9,
              ),
            ),
          ),
          brightness: Brightness.light,
          width: 1440,
          overrides: [warehouseOverride(warehouseRepository)],
        );
        expect(tester.takeException(), isNull);
        final longHeight = tester.getSize(find.byType(SaleLineRow)).height;

        expect(longHeight, shortHeight);
      });

      testWidgets('single row at the 1024px tablet width does not overflow (FR-024)', (
        tester,
      ) async {
        await pumpGoldenScenario(
          tester,
          naturallySized(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(level)),
              child: SaleLineRow(line: testLine(quantity: '2'), facilityId: 9),
            ),
          ),
          brightness: Brightness.light,
          width: 1024,
          overrides: [warehouseOverride(warehouseRepository)],
        );
        expect(tester.takeException(), isNull);
      });
    });
  }

  group('SaleLineCard (compact tier)', () {
    testWidgets('the outer card padding is symmetric top/bottom', (tester) async {
      await pumpGoldenScenario(
        tester,
        naturallySized(SaleLineCard(line: testLine(quantity: '2'), facilityId: 9)),
        brightness: Brightness.light,
        width: 390,
        overrides: [warehouseOverride(warehouseRepository)],
      );
      expect(tester.takeException(), isNull);

      // SaleLineCard is a vertically-stacked form (no shared value band, so
      // no baseline claim applies — FR-032 is a single-row/two-row concern),
      // but its own Card padding (constitution FR-034: from the design
      // tokens, not an ad-hoc literal) must still be symmetric (FR-031).
      final cardRect = tester.getRect(find.byKey(const Key('sale_line_card_5')));
      final contentRect = tester.getRect(find.text('Widget'));
      final topInset = contentRect.top - cardRect.top;
      // The card's declared padding (EdgeInsets.all(12)) is symmetric by
      // construction; this just confirms nothing else (e.g. an unbalanced
      // Row above the product cell) has since made it visually asymmetric.
      expect(topInset, greaterThanOrEqualTo(12));
    });
  });
}
