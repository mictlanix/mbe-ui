import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

const _sur = SupplierListItem(
  supplierId: 14,
  code: 'P-014',
  name: 'Aceros del Sur',
);

/// Spec 080 US5 (T030), FR-011 and research R7: "Editar encabezado", opened
/// from a draft order's detail.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    h = PurchasesHarness();
    when(
      () => h.suppliers.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const SupplierListResult(items: [_sur], total: 1),
    );
  });

  final buyer = PurchasesHarness.user(
    requestRights: 0,
    orderRights: 15,
    suppliersRead: true,
  );

  final dated = anOrder(
    estimatedReceiptDate: DateTime(2030, 12, 5),
  ).copyWith(comment: 'Entregar en andén 2');

  Future<void> open(WidgetTester tester, PurchaseOrder order) async {
    await h.pumpOrder(tester, order, who: buyer);
    await tester.tap(key('purchase_order_edit_header'));
    await tester.pumpAndSettle();
  }

  void answerUpdate(PurchaseOrder result) => when(
    () => h.orders.updateHeader(
      any(),
      supplierId: any(named: 'supplierId'),
      estimatedReceiptDate: any(named: 'estimatedReceiptDate'),
      clearDate: any(named: 'clearDate'),
      comment: any(named: 'comment'),
      clearComment: any(named: 'clearComment'),
    ),
  ).thenAnswer((_) async => result);

  Future<void> save(WidgetTester tester) async {
    await tester.tap(key('purchase_order_header_submit'));
    await tester.pumpAndSettle();
  }

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('purchase_order_header_submit'));

  testWidgets('is prefilled, and Guardar waits for a change', (tester) async {
    await open(tester, dated);

    expect(key('purchase_order_header_dialog'), findsOneWidget);
    expect(
      find.descendant(
        of: key('purchase_order_header_supplier'),
        matching: find.text('Ferretera del Norte'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: key('purchase_order_header_delivery'),
        matching: find.text('2030-12-05'),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(key('purchase_order_header_comment'))
          .controller!
          .text,
      'Entregar en andén 2',
    );
    expect(submit(tester).onPressed, isNull);
  });

  testWidgets('changing only the supplier sends only the supplier', (
    tester,
  ) async {
    answerUpdate(dated.copyWith(supplierId: 14, supplierName: _sur.name));
    await open(tester, dated);

    await tester.enterText(
      find.descendant(
        of: key('purchase_order_header_supplier'),
        matching: find.byType(TextField),
      ),
      'Sur',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('P-014 — Aceros del Sur').last);
    await tester.pumpAndSettle();
    await save(tester);

    verify(() => h.orders.updateHeader(310, supplierId: 14)).called(1);
    expect(key('purchase_order_header_dialog'), findsNothing);
    expect(find.text('Aceros del Sur'), findsOneWidget);
  });

  testWidgets('changing only the notes sends only the notes', (tester) async {
    answerUpdate(dated.copyWith(comment: 'Por la tarde'));
    await open(tester, dated);

    await tester.enterText(
      key('purchase_order_header_comment'),
      'Por la tarde',
    );
    await tester.pumpAndSettle();
    await save(tester);

    verify(() => h.orders.updateHeader(310, comment: 'Por la tarde')).called(1);
  });

  testWidgets('picking a date sends only the date', (tester) async {
    answerUpdate(anOrder());
    await open(tester, anOrder());

    await tester.tap(key('purchase_order_header_delivery'));
    await tester.pumpAndSettle();
    final ok = MaterialLocalizations.of(
      tester.element(find.byType(DatePickerDialog)),
    ).okButtonLabel;
    await tester.tap(find.text(ok));
    await tester.pumpAndSettle();
    await save(tester);

    final now = DateTime.now();
    verify(
      () => h.orders.updateHeader(
        310,
        estimatedReceiptDate: DateTime(now.year, now.month, now.day),
      ),
    ).called(1);
  });

  testWidgets('clearing the notes asks for them to be cleared', (tester) async {
    answerUpdate(anOrder());
    await open(tester, dated);

    await tester.enterText(key('purchase_order_header_comment'), '  ');
    await tester.pumpAndSettle();
    await save(tester);

    verify(() => h.orders.updateHeader(310, clearComment: true)).called(1);
  });

  testWidgets('clearing the date asks for it to be cleared', (tester) async {
    answerUpdate(anOrder());
    await open(tester, dated);

    await tester.tap(key('purchase_order_header_delivery_clear'));
    await tester.pumpAndSettle();
    expect(key('purchase_order_header_delivery_clear'), findsNothing);
    await save(tester);

    verify(() => h.orders.updateHeader(310, clearDate: true)).called(1);
  });

  testWidgets("the date picker can't go before today, even from a past "
      'date', (tester) async {
    await open(tester, anOrder(estimatedReceiptDate: DateTime(2025, 1, 10)));

    await tester.tap(key('purchase_order_header_delivery'));
    await tester.pumpAndSettle();

    final picker = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(picker.firstDate, today);
    expect(picker.initialDate, today);
  });

  testWidgets("notes over 500 characters can't be saved", (tester) async {
    await open(tester, dated);

    await tester.enterText(key('purchase_order_header_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('purchase_order_header_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('a refusal stays in the dialog, localized', (tester) async {
    when(
      () => h.orders.updateHeader(
        any(),
        supplierId: any(named: 'supplierId'),
        estimatedReceiptDate: any(named: 'estimatedReceiptDate'),
        clearDate: any(named: 'clearDate'),
        comment: any(named: 'comment'),
        clearComment: any(named: 'clearComment'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.purchaseOrderPeriodNoSupplier,
        'purchase_order.no_supplier',
      ),
    );
    await open(tester, dated);

    await tester.enterText(key('purchase_order_header_comment'), 'Otra nota');
    await tester.pumpAndSettle();
    await save(tester);

    expect(key('purchase_order_header_dialog'), findsOneWidget);
    expect(
      find.descendant(
        of: key('purchase_order_header_refusal'),
        matching: find.text(l10n.apiErrorPurchaseOrderNoSupplier),
      ),
      findsOneWidget,
    );
    expect(find.text('SERVER TEXT'), findsNothing);
    expect(submit(tester).onPressed, isNotNull);
  });
}
