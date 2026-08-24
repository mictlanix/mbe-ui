import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

/// Spec 031 US3 (FR-024…FR-031): pressing the Venta step's continue action
/// with unconfirmed text anywhere on the step must ask — keep, discard, or
/// keep editing — rather than silently discarding or silently advancing.
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

  void stubConfirm(MockSalesOrderRepository repo, Sale confirmed) {
    when(
      () => repo.confirm(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => confirmed);
  }

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

  Future<ProviderContainer> pumpCapture(
    WidgetTester tester,
    MockSalesOrderRepository salesOrder,
  ) async {
    final container = await pumpPos(
      tester,
      Consumer(
        builder: (context, ref, _) {
          final sale = ref.watch(posSaleControllerProvider).valueOrNull;
          return CaptureStep(sale: sale);
        },
      ),
      overrides: [
        warehouseOverride(warehouseRepository),
        salesOrderOverride(salesOrder),
      ],
      surface: const Size(1400, 900),
    );
    await container.read(posSaleControllerProvider.notifier).ensureOpen();
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tapContinue(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
    await tester.pump();
  }

  testWidgets('unconfirmed text at the step boundary raises the question '
      'instead of silently discarding or advancing', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    when(() => salesOrder.open()).thenAnswer((_) async => testSale(lines: [testLine()]));
    stubUpdateLine(salesOrder, (_) async => testSale(lines: [testLine()]));

    final container = await pumpCapture(tester, salesOrder);
    await tester.enterText(find.byKey(const Key('sale_line_discount_5')), '15');
    await tester.pump();

    await tapContinue(tester);
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    expect(find.text(l10n.posUnconfirmedChangesTitle), findsOneWidget);
    expect(find.text(l10n.posUnconfirmedChangesBody), findsOneWidget);
    expect(find.text(l10n.posUnconfirmedChangesKeep), findsOneWidget);
    expect(find.text(l10n.posUnconfirmedChangesDiscard), findsOneWidget);
    expect(find.text(l10n.posUnconfirmedChangesKeepEditing), findsOneWidget);
    expect(
      container.read(posStepControllerProvider).current,
      PosStep.venta,
      reason: 'the sale must not advance while the question is unanswered',
    );

    // Close the dialog before the test ends — an open route left mounted
    // past teardown can bleed timers/animations into the next test.
    await tester.tap(find.text(l10n.posUnconfirmedChangesKeepEditing));
    await tester.pumpAndSettle();
  });

  testWidgets('keep commits the typed value exactly as Enter would, then '
      'advances (FR-026)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    when(() => salesOrder.open()).thenAnswer((_) async => testSale(lines: [testLine()]));
    stubUpdateLine(salesOrder, (_) async => testSale(lines: [testLine(discountRate: '0.15')]));
    stubConfirm(salesOrder, testSale(lines: [testLine(discountRate: '0.15')]));

    final container = await pumpCapture(tester, salesOrder);
    await tester.enterText(find.byKey(const Key('sale_line_discount_5')), '15');
    await tester.pump();
    await tapContinue(tester);
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
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
    expect(container.read(posStepControllerProvider).current, PosStep.cobro);
  });

  testWidgets('keep, refused: the sale stays on Venta and the field restores '
      '(FR-026)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    when(() => salesOrder.open()).thenAnswer((_) async => testSale(lines: [testLine()]));
    stubUpdateLine(salesOrder, (_) async => throw StateError('refused'));

    final container = await pumpCapture(tester, salesOrder);
    await tester.enterText(find.byKey(const Key('sale_line_discount_5')), '15');
    await tester.pump();
    await tapContinue(tester);
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
    await tester.pumpAndSettle();

    expect(container.read(posStepControllerProvider).current, PosStep.venta);
    expect(
      tester.widget<TextField>(find.byKey(const Key('sale_line_discount_5'))).controller!.text,
      '0',
    );
  });

  testWidgets('discard drops the typed text, plays the acknowledgement, and '
      'advances (FR-027)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    when(() => salesOrder.open()).thenAnswer((_) async => testSale(lines: [testLine()]));
    stubUpdateLine(salesOrder, (_) async => testSale(lines: [testLine()]));
    stubConfirm(salesOrder, testSale(lines: [testLine()]));

    final container = await pumpCapture(tester, salesOrder);
    await tester.enterText(find.byKey(const Key('sale_line_discount_5')), '15');
    await tester.pump();
    await tapContinue(tester);
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    await tester.tap(find.text(l10n.posUnconfirmedChangesDiscard));
    await tester.pumpAndSettle();

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
    expect(
      tester.widget<TextField>(find.byKey(const Key('sale_line_discount_5'))).controller!.text,
      '0',
    );
    expect(container.read(posStepControllerProvider).current, PosStep.cobro);
  });

  testWidgets('keep editing leaves the sale on Venta with the typed text '
      'intact (FR-028)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    when(() => salesOrder.open()).thenAnswer((_) async => testSale(lines: [testLine()]));
    stubUpdateLine(salesOrder, (_) async => testSale(lines: [testLine()]));

    final container = await pumpCapture(tester, salesOrder);
    await tester.enterText(find.byKey(const Key('sale_line_discount_5')), '15');
    await tester.pump();
    await tapContinue(tester);
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    await tester.tap(find.text(l10n.posUnconfirmedChangesKeepEditing));
    await tester.pumpAndSettle();

    expect(container.read(posStepControllerProvider).current, PosStep.venta);
    expect(
      tester.widget<TextField>(find.byKey(const Key('sale_line_discount_5'))).controller!.text,
      '15',
      reason: 'keep editing is not itself a discard',
    );
  });

  testWidgets('a cashier who confirms every edit never sees the dialog '
      '(SC-013)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    when(() => salesOrder.open()).thenAnswer((_) async => testSale(lines: [testLine()]));
    stubUpdateLine(salesOrder, (_) async => testSale(lines: [testLine(discountRate: '0.15')]));
    stubConfirm(salesOrder, testSale(lines: [testLine(discountRate: '0.15')]));

    final container = await pumpCapture(tester, salesOrder);
    await tester.enterText(find.byKey(const Key('sale_line_discount_5')), '15');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tapContinue(tester);
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    expect(find.text(l10n.posUnconfirmedChangesTitle), findsNothing);
    expect(container.read(posStepControllerProvider).current, PosStep.cobro);
  });

  testWidgets('two lines with unconfirmed discounts raise one dialog; keep '
      'commits both (FR-030)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    when(
      () => salesOrder.open(),
    ).thenAnswer((_) async => testSale(lines: [testLine(id: 5), testLine(id: 6)]));
    stubUpdateLine(salesOrder, (_) async => testSale(lines: [testLine(id: 5), testLine(id: 6)]));
    stubConfirm(salesOrder, testSale(lines: [testLine(id: 5), testLine(id: 6)]));

    final container = await pumpCapture(tester, salesOrder);
    // Driven through each field's own `onChanged` rather than
    // `tester.enterText` twice: focusing the second field would blur the
    // first, which discards its typed text by the ordinary rule (FR-031) —
    // the very thing this test needs to hold off on both lines at once, to
    // exercise the registry with more than one entry (FR-030).
    tester
        .widget<TextField>(find.byKey(const Key('sale_line_discount_5')))
        .onChanged!('10');
    await tester.pump();
    tester
        .widget<TextField>(find.byKey(const Key('sale_line_discount_6')))
        .onChanged!('20');
    await tester.pump();

    await tapContinue(tester);
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    expect(find.text(l10n.posUnconfirmedChangesTitle), findsOneWidget);

    await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
    await tester.pumpAndSettle();

    verify(
      () => salesOrder.updateLine(
        saleId: any(named: 'saleId'),
        lineId: 5,
        quantity: null,
        price: null,
        discountRate: '0.1',
        taxRate: null,
        warehouse: null,
        comment: null,
      ),
    ).called(1);
    verify(
      () => salesOrder.updateLine(
        saleId: any(named: 'saleId'),
        lineId: 6,
        quantity: null,
        price: null,
        discountRate: '0.2',
        taxRate: null,
        warehouse: null,
        comment: null,
      ),
    ).called(1);
    expect(container.read(posStepControllerProvider).current, PosStep.cobro);
  });

  testWidgets('the field still reports unconfirmed text inside the '
      "continue action's own callback (research R4's measured premise)", (
    tester,
  ) async {
    final salesOrder = MockSalesOrderRepository();
    when(() => salesOrder.open()).thenAnswer((_) async => testSale(lines: [testLine()]));
    stubUpdateLine(salesOrder, (_) async => testSale(lines: [testLine()]));

    final container = await pumpCapture(tester, salesOrder);
    await tester.enterText(find.byKey(const Key('sale_line_discount_5')), '15');
    await tester.pump();

    // Tapping the button does not itself discard the typed text — verified
    // directly against the registry the continue action reads, at the
    // moment the tap lands.
    await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
    expect(
      container.read(unconfirmedEditsProvider(posWritesScope)),
      isNotEmpty,
      reason: 'the button press must not have discarded the typed text first',
    );
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    await tester.tap(find.text(l10n.posUnconfirmedChangesKeepEditing));
    await tester.pumpAndSettle();
  });
}
