import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

const _norte = SupplierListItem(
  supplierId: 12,
  code: 'P-012',
  name: 'Ferretera del Norte',
);

/// Spec 080 US2 (T016), FR-010 and research R6: "Nueva orden de compra",
/// opened from the list's button; US5 (T030): clearing a picked date.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    h = PurchasesHarness();
    h.serveOrders(const []);
    when(
      () => h.suppliers.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const SupplierListResult(items: [_norte], total: 1),
    );
  });

  Future<void> open(WidgetTester tester) async {
    await h.pump(
      tester,
      who: PurchasesHarness.user(
        requestRights: 0,
        orderRights: 15,
        suppliersRead: true,
      ),
      location: purchaseOrdersPath,
    );
    await tester.tap(key('purchase_orders_new_button'));
    await tester.pumpAndSettle();
  }

  Finder supplierField() => find.descendant(
    of: key('new_purchase_order_supplier'),
    matching: find.byType(TextField),
  );

  Future<void> pickSupplier(WidgetTester tester) async {
    await tester.enterText(supplierField(), 'Norte');
    await tester.pumpAndSettle();
    await tester.tap(find.text('P-012 — Ferretera del Norte').last);
    await tester.pumpAndSettle();
  }

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('new_purchase_order_submit'));

  testWidgets('the supplier is required', (tester) async {
    await open(tester);

    expect(key('new_purchase_order_dialog'), findsOneWidget);
    expect(submit(tester).onPressed, isNull);

    await pickSupplier(tester);
    expect(submit(tester).onPressed, isNotNull);
    verify(
      () => h.suppliers.list(search: 'Norte', skip: 0, limit: 20),
    ).called(greaterThan(0));
  });

  testWidgets('the delivery date picker starts at today', (tester) async {
    await open(tester);

    await tester.tap(key('new_purchase_order_delivery'));
    await tester.pumpAndSettle();

    final picker = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    final now = DateTime.now();
    expect(picker.firstDate, DateTime(now.year, now.month, now.day));
  });

  testWidgets('a picked date can be cleared again', (tester) async {
    await open(tester);
    expect(key('new_purchase_order_delivery_clear'), findsNothing);

    await tester.tap(key('new_purchase_order_delivery'));
    await tester.pumpAndSettle();
    final ok = MaterialLocalizations.of(
      tester.element(find.byType(DatePickerDialog)),
    ).okButtonLabel;
    await tester.tap(find.text(ok));
    await tester.pumpAndSettle();
    final now = DateTime.now();
    final today =
        '${now.year}-${'${now.month}'.padLeft(2, '0')}-'
        '${'${now.day}'.padLeft(2, '0')}';
    expect(
      find.descendant(
        of: key('new_purchase_order_delivery'),
        matching: find.text(today),
      ),
      findsOneWidget,
    );

    await tester.tap(key('new_purchase_order_delivery_clear'));
    await tester.pumpAndSettle();

    expect(key('new_purchase_order_delivery_clear'), findsNothing);
    expect(
      find.descendant(
        of: key('new_purchase_order_delivery'),
        matching: find.text(today),
      ),
      findsNothing,
    );
  });

  testWidgets("notes over 500 characters can't be submitted", (tester) async {
    await open(tester);
    await pickSupplier(tester);

    await tester.enterText(key('new_purchase_order_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('new_purchase_order_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('success sends the supplier and notes, then opens the new '
      'draft', (tester) async {
    final created = anOrder(id: 401, lines: const []);
    when(
      () => h.orders.create(
        supplierId: any(named: 'supplierId'),
        estimatedReceiptDate: any(named: 'estimatedReceiptDate'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => created);
    h.stubOrder(created);
    await open(tester);
    await pickSupplier(tester);

    await tester.enterText(
      key('new_purchase_order_comment'),
      'Entregar en andén 2',
    );
    await tester.pumpAndSettle();
    await tester.tap(key('new_purchase_order_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.orders.create(supplierId: 12, comment: 'Entregar en andén 2'),
    ).called(1);
    expect(key('new_purchase_order_dialog'), findsNothing);
    expect(find.text(l10n.purchaseOrderTitle('401')), findsOneWidget);
    expect(find.text(l10n.purchaseOrderLinesEmpty), findsOneWidget);
  });

  testWidgets('a refusal stays in the dialog, localized', (tester) async {
    when(
      () => h.orders.create(
        supplierId: any(named: 'supplierId'),
        estimatedReceiptDate: any(named: 'estimatedReceiptDate'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.purchaseOrderPeriodNoSupplier,
        'purchase_order.no_supplier',
      ),
    );
    await open(tester);
    await pickSupplier(tester);

    await tester.tap(key('new_purchase_order_submit'));
    await tester.pumpAndSettle();

    expect(key('new_purchase_order_dialog'), findsOneWidget);
    expect(key('new_purchase_order_refusal'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
    expect(submit(tester).onPressed, isNotNull);
  });
}
