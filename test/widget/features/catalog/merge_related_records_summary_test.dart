import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/catalog/domain/entities/merge_preview.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/merge_related_records_summary.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, MergePreview preview) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: MergeRelatedRecordsSummary(preview: preview),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists every category with its count and the server total', (
    tester,
  ) async {
    await _pump(
      tester,
      const MergePreview(
        categories: [
          MergePreviewCategory(key: 'sales_order_detail.product', count: 42),
          MergePreviewCategory(key: 'purchase_order_detail.product', count: 18),
        ],
        total: 60,
      ),
    );

    expect(find.text('Sales order lines'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Purchase order lines'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('merge_related_total'))).data,
      '60',
    );
  });

  testWidgets('separates category rows with a horizontal border, except the '
      'last', (tester) async {
    await _pump(
      tester,
      const MergePreview(
        categories: [
          MergePreviewCategory(key: 'sales_order_detail.product', count: 42),
          MergePreviewCategory(key: 'purchase_order_detail.product', count: 18),
          MergePreviewCategory(key: 'product_price.product', count: 3),
        ],
        total: 63,
      ),
    );

    BoxDecoration decorationOf(String key) =>
        tester
                .widget<Container>(find.byKey(Key('merge_related_row_$key')))
                .decoration!
            as BoxDecoration;

    expect(decorationOf('sales_order_detail.product').border, isNotNull);
    expect(decorationOf('purchase_order_detail.product').border, isNotNull);
    // The total footer already draws its own top border; a bottom border on
    // the last category row would double the rule.
    expect(decorationOf('product_price.product').border, isNull);
  });

  testWidgets('marks price rows as destroyed rather than moved', (
    tester,
  ) async {
    await _pump(
      tester,
      const MergePreview(
        categories: [
          MergePreviewCategory(key: 'product_price.product', count: 3),
          MergePreviewCategory(key: 'sales_order_detail.product', count: 5),
        ],
        total: 8,
      ),
    );

    // Only the price row carries the qualifier — everything else moves.
    expect(
      find.byKey(const Key('merge_related_destroyed_note')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('merge_related_row_product_price.product')),
        matching: find.byKey(const Key('merge_related_destroyed_note')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows an unrecognized category under a humanized label and '
      'still counts it in the total', (tester) async {
    await _pump(
      tester,
      const MergePreview(
        categories: [
          MergePreviewCategory(key: 'sales_order_detail.product', count: 5),
          // A relation mbe-api added after this UI shipped.
          MergePreviewCategory(key: 'warranty_claim_line.product', count: 2),
        ],
        total: 7,
      ),
    );

    expect(find.text('Warranty claim line'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('merge_related_total'))).data,
      '7',
      reason: 'an unlabelled category must not fall out of the total',
    );
  });

  testWidgets('renders nothing when the duplicate carries no references', (
    tester,
  ) async {
    await _pump(tester, const MergePreview(categories: [], total: 0));

    expect(find.byKey(const Key('merge_related_total')), findsNothing);
  });

  group('humanizeCategoryKey', () {
    test('turns a snake_case table into readable text', () {
      expect(
        humanizeCategoryKey('inventory_receipt_detail'),
        'Inventory receipt detail',
      );
      expect(humanizeCategoryKey('warranty_claim_line'), 'Warranty claim line');
      expect(humanizeCategoryKey('widgets'), 'Widgets');
    });

    test('degrades safely on odd input rather than throwing', () {
      expect(humanizeCategoryKey(''), '');
      expect(humanizeCategoryKey('__'), '__');
    });
  });
}
