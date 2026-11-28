import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_email_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 US4 (T028, FR-027, FR-028): the purchase order email dialog.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  final order = anOrder(id: 5531, status: InventoryDocumentStatus.completed);
  final buyer = PurchasesHarness.user(
    requestRights: 0,
    orderRights: 15,
    suppliersRead: true,
  );
  final supplier = Supplier(
    supplierId: 12,
    code: 'FN',
    name: 'Ferretera del Norte',
    creditLimit: '0',
    creditDays: 0,
    contacts: const [
      Contact(contactId: 1, name: 'Ventas', email: 'ventas@fn.mx'),
      Contact(contactId: 2, name: 'Jorge Luna', email: 'j.luna@fn.mx'),
    ],
  );

  Finder field(String k) =>
      find.descendant(of: key(k), matching: find.byType(EditableText));

  /// Pumps the order and opens the dialog over it.
  Future<void> open(WidgetTester tester, {User? who}) async {
    await h.pumpOrder(tester, order, who: who ?? buyer);
    final context = tester.element(find.byType(Scaffold).first);
    showPurchaseOrderEmailDialog(context, order);
    await tester.pumpAndSettle();
  }

  void serveSupplier() => when(
    () => h.suppliers.get(supplierId: 12),
  ).thenAnswer((_) async => supplier);

  void stubSend(Future<OrderEmailReceipt> Function() answer) => when(
    () => h.orders.email(
      5531,
      recipients: any(named: 'recipients'),
      message: any(named: 'message'),
    ),
  ).thenAnswer((_) => answer());

  testWidgets('offers the supplier contacts as suggestions, none selected', (
    tester,
  ) async {
    serveSupplier();
    await open(tester);

    expect(find.text(l10n.purchaseOrderEmailTitle('5531')), findsOneWidget);
    expect(key('purchase_order_email_suggestions'), findsOneWidget);
    expect(key('purchase_order_email_chip_ventas@fn.mx'), findsOneWidget);
    expect(key('purchase_order_email_chip_j.luna@fn.mx'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(key('purchase_order_email_chip_ventas@fn.mx'))
          .selected,
      isFalse,
    );
    expect(find.text(l10n.salesQuoteEmailLimitHint), findsOneWidget);
    // Nothing selected yet: Enviar waits for a recipient.
    expect(find.text(l10n.salesQuoteEmailSendAction), findsOneWidget);
  });

  testWidgets('without read on Suppliers there are no suggestions, only the '
      'hint, and typing still works', (tester) async {
    await open(
      tester,
      who: PurchasesHarness.user(requestRights: 0, orderRights: 15),
    );

    expect(key('purchase_order_email_no_suggestions'), findsOneWidget);
    verifyNever(() => h.suppliers.get(supplierId: any(named: 'supplierId')));

    await tester.enterText(
      field('purchase_order_email_other_field'),
      'compras@fn.mx',
    );
    await tester.tap(key('purchase_order_email_add_button'));
    await tester.pumpAndSettle();

    expect(key('purchase_order_email_chip_compras@fn.mx'), findsOneWidget);
    expect(find.text(l10n.salesQuoteEmailCounter(1)), findsOneWidget);
  });

  testWidgets('a typed invalid address says so and is not added', (
    tester,
  ) async {
    serveSupplier();
    await open(tester);

    await tester.enterText(
      field('purchase_order_email_other_field'),
      'no-es-correo',
    );
    await tester.tap(key('purchase_order_email_add_button'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.salesQuoteEmailInvalidAddress), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(2));
  });

  testWidgets('at ten recipients the limit is shown and adding stops', (
    tester,
  ) async {
    serveSupplier();
    await open(tester);

    for (var i = 0; i < 10; i++) {
      await tester.enterText(
        field('purchase_order_email_other_field'),
        'r$i@fn.mx',
      );
      await tester.tap(key('purchase_order_email_add_button'));
      await tester.pumpAndSettle();
    }

    expect(find.text(l10n.salesQuoteEmailLimitReached), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(key('purchase_order_email_add_button'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('the message counts up to 1000', (tester) async {
    serveSupplier();
    await open(tester);

    expect(
      find.text(l10n.purchaseOrderEmailMessageCounter('0')),
      findsOneWidget,
    );
    await tester.enterText(field('purchase_order_email_message'), 'Hola');
    await tester.pumpAndSettle();
    expect(
      find.text(l10n.purchaseOrderEmailMessageCounter('4')),
      findsOneWidget,
    );

    await tester.enterText(field('purchase_order_email_message'), 'x' * 1200);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(field('purchase_order_email_message'))
          .controller
          .text
          .length,
      1000,
    );
  });

  testWidgets('sending closes the dialog with the recipients count', (
    tester,
  ) async {
    serveSupplier();
    stubSend(
      () async => OrderEmailReceipt(
        recipients: const ['ventas@fn.mx', 'j.luna@fn.mx'],
        sentAt: DateTime(2026, 11, 27, 10),
      ),
    );
    await open(tester);

    await tester.tap(key('purchase_order_email_chip_ventas@fn.mx'));
    await tester.tap(key('purchase_order_email_chip_j.luna@fn.mx'));
    await tester.enterText(
      field('purchase_order_email_message'),
      'Favor de confirmar.',
    );
    await tester.pumpAndSettle();
    await tester.tap(key('purchase_order_email_send'));
    await tester.pumpAndSettle();

    verify(
      () => h.orders.email(
        5531,
        recipients: ['ventas@fn.mx', 'j.luna@fn.mx'],
        message: 'Favor de confirmar.',
      ),
    ).called(1);
    expect(key('purchase_order_email_dialog'), findsNothing);
    expect(find.text(l10n.purchaseOrderEmailSentSnack(2)), findsOneWidget);
  });

  for (final (code, codeName, message) in [
    (
      api.ErrorCode.emailPeriodSendFailed,
      'email.send_failed',
      (AppLocalizations l) => l.apiErrorEmailSendFailed,
    ),
    (
      api.ErrorCode.emailPeriodNotConfigured,
      'email.not_configured',
      (AppLocalizations l) => l.apiErrorEmailNotConfigured,
    ),
    (
      api.ErrorCode.purchaseOrderPeriodNotConfirmed,
      'purchase_order.not_confirmed',
      (AppLocalizations l) => l.apiErrorPurchaseOrderNotConfirmed,
    ),
  ]) {
    testWidgets('$codeName shows its own message and keeps the input', (
      tester,
    ) async {
      serveSupplier();
      stubSend(() async => throw aRefusal(code, codeName));
      await open(tester);

      await tester.tap(key('purchase_order_email_chip_ventas@fn.mx'));
      await tester.enterText(field('purchase_order_email_message'), 'Hola');
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_order_email_send'));
      await tester.pumpAndSettle();

      expect(key('purchase_order_email_dialog'), findsOneWidget);
      expect(key('purchase_order_email_refusal'), findsOneWidget);
      expect(find.textContaining(message(l10n)), findsOneWidget);
      expect(find.textContaining('SERVER TEXT'), findsNothing);
      expect(
        tester
            .widget<FilterChip>(key('purchase_order_email_chip_ventas@fn.mx'))
            .selected,
        isTrue,
      );
      expect(find.text('Hola'), findsOneWidget);
    });
  }

  testWidgets('closing after purchase_order.not_confirmed reloads the order', (
    tester,
  ) async {
    serveSupplier();
    stubSend(
      () async => throw aRefusal(
        api.ErrorCode.purchaseOrderPeriodNotConfirmed,
        'purchase_order.not_confirmed',
      ),
    );
    await open(tester);
    clearInteractions(h.orders);

    await tester.tap(key('purchase_order_email_chip_ventas@fn.mx'));
    await tester.pumpAndSettle();
    await tester.tap(key('purchase_order_email_send'));
    await tester.pumpAndSettle();
    await tester.tap(key('purchase_order_email_cancel'));
    await tester.pumpAndSettle();

    verify(() => h.orders.get(5531)).called(1);
  });
}
