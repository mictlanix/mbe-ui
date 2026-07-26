import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/merge_comparison_table.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Product _product({
  int productId = 1,
  String code = 'SKU-001',
  String? sku = 'SKU-001',
  String? model = 'M1',
  String? brand = 'Acme',
  String uom = 'Piece',
  String taxRate = '0.16',
  EntityStatus status = EntityStatus.active,
}) => Product(
  productId: productId,
  code: code,
  name: 'Widget',
  sku: sku,
  brand: brand,
  model: model,
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: uom,
  taxRate: taxRate,
  taxIncluded: false,
  priceType: 0,
  currency: 0,
  minOrderQty: 1,
  stockable: false,
  perishable: false,
  seriable: false,
  purchasable: false,
  salable: false,
  invoiceable: false,
  stockRequired: false,
  status: status,
);

/// Resolves an [AppLocalizations] so [buildComparisonRows] can be exercised
/// directly, without standing up the whole merge screen.
Future<AppLocalizations> _l10n(WidgetTester tester) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return l10n;
}

void main() {
  group('buildComparisonRows', () {
    testWidgets('covers every compared field', (tester) async {
      final l10n = await _l10n(tester);
      final rows = buildComparisonRows(l10n, _product(), _product());

      expect(rows.map((r) => r.label), [
        l10n.mergeFieldId,
        l10n.mergeFieldCode,
        l10n.mergeFieldSku,
        l10n.mergeFieldModel,
        l10n.mergeFieldBrand,
        l10n.mergeFieldUom,
        l10n.mergeFieldTaxRate,
        l10n.mergeFieldStatus,
      ]);
    });

    testWidgets('two identical products produce no flagged rows', (
      tester,
    ) async {
      final l10n = await _l10n(tester);
      final rows = buildComparisonRows(l10n, _product(), _product());

      expect(rows.where((r) => r.differs), isEmpty);
      expect(rows, hasLength(8), reason: 'all rows still render (Edge Cases)');
    });

    testWidgets('flags exactly the field that differs, one at a time', (
      tester,
    ) async {
      final l10n = await _l10n(tester);
      final base = _product();

      final cases = <String, Product>{
        l10n.mergeFieldId: _product(productId: 99),
        l10n.mergeFieldCode: _product(code: 'OTHER'),
        l10n.mergeFieldSku: _product(sku: 'OTHER'),
        l10n.mergeFieldModel: _product(model: 'M2'),
        l10n.mergeFieldBrand: _product(brand: 'Globex'),
        l10n.mergeFieldUom: _product(uom: 'Box'),
        l10n.mergeFieldTaxRate: _product(taxRate: '0.08'),
        l10n.mergeFieldStatus: _product(status: EntityStatus.inactive),
      };

      for (final entry in cases.entries) {
        final rows = buildComparisonRows(l10n, base, entry.value);
        final flagged = rows.where((r) => r.differs).map((r) => r.label);
        expect(
          flagged,
          [entry.key],
          reason: 'changing ${entry.key} must flag that row and only it',
        );
      }
    });

    testWidgets('renders a dash for absent optional values and treats two '
        'absent values as matching', (tester) async {
      final l10n = await _l10n(tester);
      final rows = buildComparisonRows(
        l10n,
        _product(sku: null, brand: null),
        _product(sku: '', brand: null),
      );

      final sku = rows.firstWhere((r) => r.label == l10n.mergeFieldSku);
      // null and '' both read as "no value" on screen, so flagging them as a
      // difference would be noise the operator can't act on.
      expect(sku.kept, '—');
      expect(sku.deleted, '—');
      expect(sku.differs, isFalse);
    });
  });

  group('row chrome', () {
    Future<void> pumpTable(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MergeComparisonTable(
                kept: _product(),
                deleted: _product(productId: 2, brand: 'Globex'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    BoxDecoration decorationOf(WidgetTester tester, String label) {
      return tester
              .widget<Container>(
                find
                    .descendant(
                      of: find.byKey(Key('merge_row_$label')),
                      matching: find.byType(Container),
                    )
                    .first,
              )
              .decoration!
          as BoxDecoration;
    }

    testWidgets('separates rows with a horizontal border, except the last', (
      tester,
    ) async {
      await pumpTable(tester);

      expect(decorationOf(tester, 'Code').border, isNotNull);
      // The final row would otherwise double up against the table's own
      // bottom border.
      expect(decorationOf(tester, 'Status').border, isNull);
    });

    testWidgets('highlights a row on pointer hover and clears it on exit', (
      tester,
    ) async {
      await pumpTable(tester);

      final before = decorationOf(tester, 'Code').color;

      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.byKey(const Key('merge_row_Code')))),
      );
      await tester.pumpAndSettle();
      final hovered = decorationOf(tester, 'Code').color;

      expect(hovered, isNotNull);
      expect(hovered, isNot(before));

      await tester.sendEventToBinding(pointer.hover(Offset.zero));
      await tester.pumpAndSettle();
      expect(decorationOf(tester, 'Code').color, before);
    });

    testWidgets('hover layers over a differing row rather than replacing its '
        'flag tint', (tester) async {
      await pumpTable(tester);

      // Brand differs between the two fixtures, so this row is tinted.
      final flagged = decorationOf(tester, 'Brand').color;
      expect(flagged, isNotNull);

      final pointer = TestPointer(2, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(
          tester.getCenter(find.byKey(const Key('merge_row_Brand'))),
        ),
      );
      await tester.pumpAndSettle();

      expect(decorationOf(tester, 'Brand').color, isNot(flagged));
      // The DIFFERS badge must survive hover — hovering a flagged row must
      // never read as un-flagging it.
      expect(
        find.descendant(
          of: find.byKey(const Key('merge_row_Brand')),
          matching: find.byKey(const Key('merge_diff_badge')),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('MergeComparisonTable badges only the differing rows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MergeComparisonTable(
              kept: _product(),
              deleted: _product(productId: 2, brand: 'Globex'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // id + brand differ; the other six match.
    expect(find.byKey(const Key('merge_diff_badge')), findsNWidgets(2));
  });
}
