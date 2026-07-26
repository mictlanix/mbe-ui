import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/merge_review_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Product _product({
  int productId = 1,
  String name = 'Widget',
  String code = 'SKU-001',
  String? sku = 'SKU-001',
  String? model = 'M1',
  String uom = 'Piece',
  EntityStatus status = EntityStatus.active,
}) => Product(
  productId: productId,
  code: code,
  name: name,
  sku: sku,
  brand: 'Acme',
  model: model,
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: uom,
  taxRate: '0.16',
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

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  required Product kept,
  required Product deleted,
}) async {
  tester.view.physicalSize = Size(width, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: MergeReviewPanels(kept: kept, deleted: deleted, onSwap: () {}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Widths spanning both sides of the compact breakpoint (600), including the
/// boundaries themselves and a phone-sized floor.
const _widths = <double>[320, 360, 420, 599, 600, 700, 840, 1000, 1400];

void main() {
  group('responsive layout (FR-012, constitution §VI)', () {
    testWidgets('lays out without overflow across the width range', (
      tester,
    ) async {
      for (final width in _widths) {
        await _pump(
          tester,
          width: width,
          kept: _product(),
          deleted: _product(productId: 2, code: 'SKU-002'),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'panels overflowed or failed to lay out at ${width}px',
        );
      }
    });

    testWidgets('survives long names, codes and unit labels at every width', (
      tester,
    ) async {
      // The real catalog has names like
      // 'BROCA PARA METAL GREENFIELD A.V. 1/64"' plus verbose SAT unit names,
      // which is what actually pushes these rows past their bounds.
      final kept = _product(
        name: 'BROCA PARA METAL GREENFIELD A.V. 1/64" HIGH SPEED STEEL',
        code: 'MUY-LARGO-292697-ABCDEF',
        sku: 'SKU-CON-UN-NOMBRE-INTERMINABLE-0001',
        model: 'MODELO-EXTRA-LARGO-XYZ',
        uom: 'Pieza (unidad de medida con nombre larguísimo)',
      );
      final deleted = _product(
        productId: 2,
        name: 'BROCA PARA METAL GREENFIELD A.V. 1/32" HIGH SPEED STEEL',
        code: 'OTRO-CODIGO-LARGUISIMO-292698',
        sku: 'SKU-ALTERNO-CON-NOMBRE-MUY-LARGO-0002',
        model: 'MODELO-ALTERNO-LARGO-ABC',
        uom: 'Caja (unidad de medida con nombre larguísimo)',
        status: EntityStatus.inactive,
      );

      for (final width in _widths) {
        await _pump(tester, width: width, kept: kept, deleted: deleted);
        expect(
          tester.takeException(),
          isNull,
          reason: 'long content overflowed at ${width}px',
        );
      }
    });

    testWidgets('names each identifier so code, model and SKU are tellable '
        'apart', (tester) async {
      // This catalog routinely repeats the same string across all three
      // fields, so an unlabelled list ('292699 · 292699 · 292699') cannot
      // show the operator *which* identifier differs between the products.
      await _pump(
        tester,
        width: 1200,
        kept: _product(code: '292699', model: '292699', sku: '292699'),
        deleted: _product(
          productId: 2,
          code: '292697',
          model: '292697',
          sku: '292697',
        ),
      );

      expect(
        find.text('Code: 292699 · Model: 292699 · SKU: 292699'),
        findsOneWidget,
      );
      expect(
        find.text('Code: 292697 · Model: 292697 · SKU: 292697'),
        findsOneWidget,
      );
    });

    testWidgets('omits absent identifiers instead of leaving dangling '
        'separators', (tester) async {
      await _pump(
        tester,
        width: 1200,
        kept: _product(code: 'ONLY-CODE', model: null, sku: null),
        deleted: _product(productId: 2, code: 'C2', model: 'M2', sku: null),
      );

      expect(find.text('Code: ONLY-CODE'), findsOneWidget);
      expect(find.text('Code: C2 · Model: M2'), findsOneWidget);
    });

    testWidgets('clips its children to the border radius so the header '
        'cannot paint over the border or the rounded corners', (tester) async {
      await _pump(
        tester,
        width: 1200,
        kept: _product(),
        deleted: _product(productId: 2),
      );

      for (final key in ['merge_kept_panel', 'merge_deleted_panel']) {
        final box = tester.widget<Container>(
          find
              .descendant(
                of: find.byKey(Key(key)),
                matching: find.byType(Container),
              )
              .first,
        );

        // Regression guard: a DecoratedBox here neither insets the child by
        // the border nor clips it, so the full-bleed header spills past the
        // corner radius and paints over the border (observed in-app).
        expect(
          box.clipBehavior,
          isNot(Clip.none),
          reason: '$key must clip its children to the rounded corners',
        );
        final decoration = box.decoration! as BoxDecoration;
        expect(decoration.border, isNotNull);
        expect(decoration.borderRadius, isNotNull);
      }
    });

    testWidgets('stacks below the compact breakpoint and sits side by side '
        'above it', (tester) async {
      final kept = _product();
      final deleted = _product(productId: 2);

      await _pump(tester, width: 420, kept: kept, deleted: deleted);
      final compactKept = tester.getRect(
        find.byKey(const Key('merge_kept_panel')),
      );
      final compactDeleted = tester.getRect(
        find.byKey(const Key('merge_deleted_panel')),
      );
      expect(
        compactDeleted.top,
        greaterThan(compactKept.bottom - 1),
        reason: 'compact width stacks the panels vertically',
      );

      await _pump(tester, width: 1200, kept: kept, deleted: deleted);
      final wideKept = tester.getRect(
        find.byKey(const Key('merge_kept_panel')),
      );
      final wideDeleted = tester.getRect(
        find.byKey(const Key('merge_deleted_panel')),
      );
      expect(
        wideDeleted.left,
        greaterThan(wideKept.right - 1),
        reason: 'wide layout puts the panels side by side',
      );
      expect(
        wideKept.height,
        closeTo(wideDeleted.height, 0.5),
        reason: 'IntrinsicHeight keeps both panels the same height',
      );
    });
  });
}
