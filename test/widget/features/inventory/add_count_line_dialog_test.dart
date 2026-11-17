import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
import 'inventory_harness.dart';

const _tornillo = ProductListItem(
  productId: 7,
  code: 'A-100',
  name: 'Tornillo 1/4 caja',
  unitOfMeasurementCode: 'H87',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  status: EntityStatus.active,
);

const _taquete = ProductListItem(
  productId: 8,
  code: 'B-220',
  name: 'Taquete 5/16',
  unitOfMeasurementCode: 'H87',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  status: EntityStatus.active,
);

/// Spec 070 US2 (T019): "Agregar producto", opened from a draft's detail.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(EntityStatus.active);
    registerFallbackValue(<CountLineInput>[]);
  });

  setUp(() {
    h = InventoryHarness();
    when(
      () => h.products.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          const ProductListResult(items: [_tornillo, _taquete], total: 2),
    );
  });

  /// Opens the dialog on a draft whose one line is A-100 counted at 8.
  Future<void> open(WidgetTester tester) async {
    await h.pumpCount(tester, aCount());
    await tester.tap(key('inventory_count_add_product'));
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, String name) async {
    await tester.enterText(
      find.descendant(
        of: key('add_count_line_product'),
        matching: find.byType(TextField),
      ),
      'x',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('add_count_line_submit'));

  testWidgets('the picker asks for active, stockable products', (tester) async {
    await open(tester);
    await pick(tester, 'Taquete 5/16');

    verify(
      () => h.products.list(
        search: 'x',
        status: EntityStatus.active,
        stockable: true,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('the button reads "Registrar"', (tester) async {
    await open(tester);
    // Scoped to the dialog: Captura rápida's button reads "Registrar" too.
    expect(
      find.descendant(
        of: key('add_count_line_dialog'),
        matching: find.text(l10n.inventoryCountDialogRecord),
      ),
      findsOneWidget,
    );
    expect(l10n.inventoryCountDialogRecord, 'Registrar');
  });

  testWidgets('a negative quantity is refused, 0 is accepted', (tester) async {
    await open(tester);
    await pick(tester, 'Taquete 5/16');

    await tester.enterText(key('add_count_line_quantity'), '-1');
    await tester.pumpAndSettle();
    expect(find.text(l10n.inventoryCountQuantityInvalid), findsOneWidget);
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('add_count_line_quantity'), '0');
    await tester.pumpAndSettle();
    expect(find.text(l10n.inventoryCountQuantityInvalid), findsNothing);
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('a product already on the count shows the replace note', (
    tester,
  ) async {
    await open(tester);

    await pick(tester, 'Taquete 5/16');
    expect(key('add_count_line_replace_note'), findsNothing);

    await pick(tester, 'Tornillo 1/4 caja');
    expect(key('add_count_line_replace_note'), findsOneWidget);
    expect(find.text(l10n.inventoryCountReplaceNote('8')), findsOneWidget);
    expect(find.text('Ya contado: 8. Se reemplazará.'), findsOneWidget);
  });

  testWidgets('sets one line by product, then closes', (tester) async {
    when(() => h.counts.setLines(412, any())).thenAnswer(
      (_) async => aCount(
        lines: [
          aCountLine(),
          aCountLine(
            id: 1201,
            productId: 8,
            productCode: 'B-220',
            productName: 'Taquete 5/16',
            quantity: '3',
          ),
        ],
      ),
    );
    await open(tester);
    await pick(tester, 'Taquete 5/16');

    await tester.enterText(key('add_count_line_quantity'), '3');
    await tester.pumpAndSettle();
    await tester.tap(key('add_count_line_submit'));
    await tester.pumpAndSettle();

    final sent =
        verify(() => h.counts.setLines(412, captureAny())).captured.single
            as List<CountLineInput>;
    expect(sent, [
      CountLineInput.byProduct(productId: 8, quantity: Decimal.fromInt(3)),
    ]);
    expect(key('add_count_line_dialog'), findsNothing);
    expect(find.text('Taquete 5/16'), findsOneWidget);
  });

  testWidgets('a batch_invalid refusal with one part shows the part\'s '
      'message, and the dialog stays open', (tester) async {
    when(() => h.counts.setLines(412, any())).thenAnswer(
      (_) async => throw const AppError.validation(
        [],
        'SERVER TEXT',
        ApiProblem(
          codeName: 'inventory_count.batch_invalid',
          code: api.ErrorCode.inventoryCountPeriodBatchInvalid,
          parts: [
            ApiProblemPart(
              codeName: 'inventory_count_line.not_stockable',
              code: api.ErrorCode.inventoryCountLinePeriodNotStockable,
              extra: {'index': 0, 'product_code': 'B-220'},
            ),
          ],
          detail: 'SERVER TEXT',
        ),
      ),
    );
    await open(tester);
    await pick(tester, 'Taquete 5/16');

    await tester.enterText(key('add_count_line_quantity'), '3');
    await tester.pumpAndSettle();
    await tester.tap(key('add_count_line_submit'));
    await tester.pumpAndSettle();

    expect(key('add_count_line_dialog'), findsOneWidget);
    expect(key('add_count_line_refusal'), findsOneWidget);
    expect(
      find.text(l10n.apiErrorInventoryCountLineNotStockable),
      findsOneWidget,
    );
    expect(find.text(l10n.apiErrorInventoryCountBatchInvalid), findsNothing);
    expect(find.text('SERVER TEXT'), findsNothing);
  });
}
