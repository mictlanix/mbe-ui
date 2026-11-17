import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 069 US2 (T018): the prompts the detail screen opens.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
  });

  setUp(() => h = InventoryHarness());

  testWidgets('the dispatch prompt names both warehouses and says the stock '
      'stays in transit until received', (tester) async {
    await h.pumpTransfer(tester, aTransfer());

    await tester.tap(key('inventory_transfer_dispatch'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(key('inventory_transfer_dispatch_body')).data,
      l10n.inventoryTransferDispatchBody('Almacén 3', 'Almacén 4'),
    );
    expect(
      find.textContaining('Quedan en tránsito hasta que Almacén 4'),
      findsOneWidget,
    );
  });

  testWidgets('backing out of the dispatch prompt sends nothing', (
    tester,
  ) async {
    await h.pumpTransfer(tester, aTransfer());

    await tester.tap(key('inventory_transfer_dispatch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.inventoryTransferBack));
    await tester.pumpAndSettle();

    verifyNever(() => h.transfers.dispatch(any()));
    expect(key('inventory_transfer_dispatch_dialog'), findsNothing);
  });

  testWidgets('the quantity prompt is prefilled and Guardar sends the new '
      'quantity', (tester) async {
    when(
      () => h.transfers.updateLine(412, 900, quantity: any(named: 'quantity')),
    ).thenAnswer((_) async => aTransfer(lines: [aTransferLine(quantity: '5')]));
    await h.pumpTransfer(tester, aTransfer());

    await tester.tap(key('inventory_transfer_line_edit_900'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(key('inventory_transfer_line_quantity_field'))
          .controller!
          .text,
      '8',
    );
    await tester.enterText(key('inventory_transfer_line_quantity_field'), '5');
    await tester.pumpAndSettle();
    await tester.tap(key('inventory_transfer_line_quantity_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.transfers.updateLine(412, 900, quantity: Decimal.fromInt(5)),
    ).called(1);
    expect(key('inventory_transfer_line_quantity_dialog'), findsNothing);
    expect(
      tester.widget<Text>(key('inventory_transfer_line_quantity_900')).data,
      '5',
    );
  });

  testWidgets('the remove prompt names the product and removes the line', (
    tester,
  ) async {
    when(
      () => h.transfers.removeLine(412, 900),
    ).thenAnswer((_) async => aTransfer(lines: const []));
    await h.pumpTransfer(tester, aTransfer());

    await tester.tap(key('inventory_transfer_line_remove_900'));
    await tester.pumpAndSettle();
    expect(
      find.text(l10n.inventoryTransferRemoveTitle('Tornillo 1/4 caja')),
      findsOneWidget,
    );
    await tester.tap(key('inventory_transfer_line_remove_submit'));
    await tester.pumpAndSettle();

    verify(() => h.transfers.removeLine(412, 900)).called(1);
    expect(find.text(l10n.inventoryTransferLinesEmpty), findsOneWidget);
  });
}
