import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

import 'pos_test_harness.dart';

/// Spec 031 US2 (FR-013…FR-018): the sale line's discount field commits only
/// on Enter, and discards visibly — with the same acknowledgement the
/// quantity stepper uses — on focus loss, on unparseable text, and on a
/// server refusal, on both the wide row and the compact card.
void main() {
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
    ).thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));
  });

  void stubUpdateLine(
    MockSalesOrderRepository repo,
    Future<Sale> Function(Invocation) answer,
  ) {
    when(
      () => repo.updateLine(
        saleId: any(named: 'saleId'),
        lineId: any(named: 'lineId'),
        quantity: any(named: 'quantity'),
        price: any(named: 'price'),
        discountRate: any(named: 'discountRate'),
        taxRate: any(named: 'taxRate'),
        warehouse: any(named: 'warehouse'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer(answer);
  }

  final discountKey = const Key('sale_line_discount_5');

  Future<ProviderContainer> pumpLine(
    WidgetTester tester,
    MockSalesOrderRepository salesOrder, {
    bool compact = false,
  }) async {
    final container = await pumpPos(
      tester,
      Consumer(
        builder: (context, ref, _) {
          ref.watch(posSaleControllerProvider);
          return compact
              ? SaleLineCard(line: testLine(), facilityId: 9)
              : SaleLineRow(line: testLine(), facilityId: 9);
        },
      ),
      overrides: [
        warehouseOverride(warehouseRepository),
        salesOrderOverride(salesOrder),
      ],
      surface: compact ? const Size(390, 900) : const Size(1400, 900),
    );
    await container.read(posSaleControllerProvider.notifier).ensureOpen();
    await tester.pumpAndSettle();
    return container;
  }

  String discountText(WidgetTester tester) =>
      tester.widget<TextField>(find.byKey(discountKey)).controller!.text;

  for (final compact in [false, true]) {
    final tier = compact ? 'compact card' : 'wide row';

    group(tier, () {
      testWidgets('Enter confirms the typed discount — one write, no reset', (
        tester,
      ) async {
        final salesOrder = MockSalesOrderRepository();
        when(() => salesOrder.open()).thenAnswer((_) async => testSale());
        stubUpdateLine(salesOrder, (_) async => testSale());

        await pumpLine(tester, salesOrder, compact: compact);
        await tester.enterText(find.byKey(discountKey), '15');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        verify(
          () => salesOrder.updateLine(
            saleId: any(named: 'saleId'),
            lineId: 5,
            quantity: null,
            price: null,
            discountRate: '0.15',
            taxRate: null,
            warehouse: null,
            comment: null,
          ),
        ).called(1);
        expect(discountText(tester), '15');
      });

      testWidgets('losing focus without Enter discards — no write, the field '
          "returns to the line's own value", (tester) async {
        final salesOrder = MockSalesOrderRepository();
        when(() => salesOrder.open()).thenAnswer((_) async => testSale());
        stubUpdateLine(salesOrder, (_) async => testSale());

        await pumpLine(tester, salesOrder, compact: compact);
        await tester.enterText(find.byKey(discountKey), '15');
        await tester.pump();
        expect(discountText(tester), '15');

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump(); // t=0: reset just started
        expect(discountText(tester), '15', reason: 'not yet swapped');

        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        expect(discountText(tester), '0');
        verifyNever(
          () => salesOrder.updateLine(
            saleId: any(named: 'saleId'),
            lineId: any(named: 'lineId'),
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        );
      });

      testWidgets('unparseable text discards with the acknowledgement — no '
          'write', (tester) async {
        final salesOrder = MockSalesOrderRepository();
        when(() => salesOrder.open()).thenAnswer((_) async => testSale());
        stubUpdateLine(salesOrder, (_) async => testSale());

        await pumpLine(tester, salesOrder, compact: compact);
        await tester.enterText(find.byKey(discountKey), 'abc');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(discountText(tester), '0');
        verifyNever(
          () => salesOrder.updateLine(
            saleId: any(named: 'saleId'),
            lineId: any(named: 'lineId'),
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        );
      });

      testWidgets('a refused confirmed discount restores visibly, instead of '
          'the old silent rewrite (FR-017)', (tester) async {
        final salesOrder = MockSalesOrderRepository();
        when(() => salesOrder.open()).thenAnswer((_) async => testSale());
        stubUpdateLine(salesOrder, (_) async => throw const AppError.server());

        await pumpLine(tester, salesOrder, compact: compact);
        await tester.enterText(find.byKey(discountKey), '15');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(discountText(tester), '0');
      });

      testWidgets('a confirmed value reformats immediately, even while the '
          'field is still focused (research: gating the resync on focus '
          'rather than on unconfirmed text left a confirmed value showing '
          'raw keystrokes until the cashier tabbed away)', (tester) async {
        final salesOrder = MockSalesOrderRepository();
        when(() => salesOrder.open()).thenAnswer((_) async => testSale());
        stubUpdateLine(salesOrder, (_) async => testSale());

        await pumpLine(tester, salesOrder, compact: compact);
        // "15.00" and "15" are the same rate, but only the second is how the
        // field displays it (`AppFormatters.rate` drops trailing zeros) —
        // this only reveals the gap discount surfaces and quantity does not,
        // since quantity's own typed digits already coincide with its
        // formatted display.
        await tester.enterText(find.byKey(discountKey), '15.00');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(
          discountText(tester),
          '15',
          reason: 'confirmed and reformatted without the field ever losing focus',
        );
      });

      testWidgets('Enter twice on the unchanged accepted value writes once, '
          'no reset', (tester) async {
        final salesOrder = MockSalesOrderRepository();
        when(() => salesOrder.open()).thenAnswer((_) async => testSale());
        var calls = 0;
        stubUpdateLine(salesOrder, (_) {
          calls++;
          return Future.value(testSale());
        });

        await pumpLine(tester, salesOrder, compact: compact);
        await tester.enterText(find.byKey(discountKey), '15');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(calls, 1);

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(calls, 1, reason: 'confirming the same value again sends nothing new');
      });
    });
  }

  testWidgets('the discount field keeps its band position and appearance '
      '(FR-021)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    when(() => salesOrder.open()).thenAnswer((_) async => testSale());
    stubUpdateLine(salesOrder, (_) async => testSale());

    await pumpLine(tester, salesOrder);
    final field = tester.widget<ConfirmableTextField>(
      find.ancestor(of: find.byKey(discountKey), matching: find.byType(ConfirmableTextField)),
    );
    expect(field.textAlign, TextAlign.end);
    expect(field.keyboardType, const TextInputType.numberWithOptions(decimal: true));
  });
}
