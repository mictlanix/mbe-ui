import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_dialogs.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class _MockSales extends Mock implements SalesOrderRepository {}

/// Records each write and answers [error].
class _FakeActions extends DeliveryOrderActions {
  _FakeActions({this.error});

  AppError? error;
  final calls = <String>[];

  @override
  Future<AppError?> confirm(int id) async {
    calls.add('confirm');
    return error;
  }

  @override
  Future<AppError?> updateLine(
    int id, {
    required int lineId,
    required Decimal quantity,
  }) async {
    calls.add('update $lineId $quantity');
    return error;
  }

  @override
  Future<AppError?> cancel(int id, {required String reason}) async {
    calls.add('cancel $reason');
    return error;
  }

  @override
  Future<AppError?> requeue(int id) async {
    calls.add('requeue');
    return error;
  }

  @override
  Future<AppError?> markReady(int id) async {
    calls.add('ready');
    return error;
  }
}

final _line = DeliveryOrderLine(
  id: 1,
  salesOrderDetailId: 101,
  productId: 1,
  productCode: 'CEM-50',
  productName: 'Cemento gris 50 kg',
  warehouseId: 3,
  quantity: Decimal.fromInt(10),
  committed: Decimal.zero,
  delivered: Decimal.zero,
  returned: Decimal.zero,
  open: Decimal.fromInt(10),
);

final _order = DeliveryOrder(
  id: 9,
  facilityId: 1,
  customerId: 7,
  date: DateTime(2026, 11, 15),
  priority: 0,
  status: DeliveryOrderStatus.draft,
  type: FulfillmentType.delivery,
  createdAt: DateTime(2026, 11, 14),
  modifiedAt: DateTime(2026, 11, 14),
  lines: [_line],
);

Sale _sale() => Sale(
  id: 8841,
  facility: 1,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  status: SaleStatus.completed,
  lines: const [
    SaleLine(
      id: 101,
      product: 1,
      productCode: 'CEM-50',
      productName: 'Cemento gris 50 kg',
      quantity: '12.0000',
      price: '20',
      discountRate: '0',
      taxRate: '0.16',
      taxIncluded: false,
      subtotal: '0',
      taxTotal: '0',
      total: '0',
    ),
  ],
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  date: DateTime(2026, 11, 14),
  dueDate: DateTime(2026, 11, 14),
);

/// Spec 061 T021, T027, T030, T034 and T038: the confirm, requeue and ready
/// dialogs (C5), the cancel dialog (C6) and the line quantity and remove
/// dialogs (C8), on their own.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  /// Pumps a button that opens [open]; its answer lands in the returned list.
  Future<List<Object?>> pumpOpener(
    WidgetTester tester, {
    required Future<Object?> Function(BuildContext context) open,
    required _FakeActions actions,
    SalesOrderRepository? sales,
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final results = <Object?>[];
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          deliveryOrderActionsProvider.overrideWith(() => actions),
          customerDisplayNameProvider.overrideWith(
            (ref, id) async => 'Ferretería López',
          ),
          if (sales != null)
            salesOrderRepositoryProvider.overrideWithValue(sales),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => results.add(await open(context)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  Finder key(String k) => find.byKey(Key(k));

  group('confirm', () {
    testWidgets('success closes with no error', (tester) async {
      final actions = _FakeActions();
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showConfirmDeliveryOrderDialog(context, _order),
      );

      await tester.tap(key('delivery_order_confirm_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['confirm']);
      expect(results.single, (error: null));
    });

    testWidgets('backing out answers null and confirms nothing', (
      tester,
    ) async {
      final actions = _FakeActions();
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showConfirmDeliveryOrderDialog(context, _order),
      );

      await tester.tap(find.text(l10n.deliveryOrderBackButton));
      await tester.pumpAndSettle();

      expect(actions.calls, isEmpty);
      expect(results.single, isNull);
    });

    testWidgets('a refusal other than insufficient notice closes with it', (
      tester,
    ) async {
      const error = AppError.server(
        statusCode: 409,
        problem: ApiProblem(
          codeName: 'delivery_order.not_editable',
          code: api.ErrorCode.deliveryOrderPeriodNotEditable,
        ),
      );
      final results = await pumpOpener(
        tester,
        actions: _FakeActions(error: error),
        open: (context) => showConfirmDeliveryOrderDialog(context, _order),
      );

      await tester.tap(key('delivery_order_confirm_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_confirm_dialog'), findsNothing);
      expect(results.single, (error: error));
    });
  });

  group('line quantity', () {
    Future<bool?> lastResult(List<Object?> results) async =>
        results.isEmpty ? null : results.single as bool;

    testWidgets('is prefilled and shows what the sale ordered', (tester) async {
      final sales = _MockSales();
      when(() => sales.getById(saleId: 8841)).thenAnswer((_) async => _sale());
      await pumpOpener(
        tester,
        actions: _FakeActions(),
        sales: sales,
        open: (context) => showDeliveryOrderLineQuantityDialog(
          context,
          orderId: 9,
          line: _line,
          saleId: 8841,
        ),
      );

      expect(
        tester
            .widget<TextField>(key('delivery_order_line_quantity_field'))
            .controller!
            .text,
        '10',
      );
      expect(find.text(l10n.deliveryOrderLineQuantityOrdered('12')), findsOne);
    });

    testWidgets('0 is invalid and cannot be saved', (tester) async {
      await pumpOpener(
        tester,
        actions: _FakeActions(),
        open: (context) => showDeliveryOrderLineQuantityDialog(
          context,
          orderId: 9,
          line: _line,
        ),
      );

      await tester.enterText(key('delivery_order_line_quantity_field'), '0');
      await tester.pump();

      expect(find.text(l10n.deliveryOrderLineQuantityInvalid), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(key('delivery_order_line_quantity_submit'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('saves the new quantity', (tester) async {
      final actions = _FakeActions();
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showDeliveryOrderLineQuantityDialog(
          context,
          orderId: 9,
          line: _line,
        ),
      );

      await tester.enterText(key('delivery_order_line_quantity_field'), '6.5');
      await tester.pump();
      await tester.tap(key('delivery_order_line_quantity_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['update 1 6.5']);
      expect(await lastResult(results), isTrue);
    });

    testWidgets('quantity_exceeds_remaining shows inline with the server\'s '
        'remaining and keeps the dialog open', (tester) async {
      final actions = _FakeActions(
        error: const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'delivery_order.quantity_exceeds_remaining',
            code: api.ErrorCode.deliveryOrderPeriodQuantityExceedsRemaining,
            params: {'requested': '30', 'remaining': '12'},
          ),
        ),
      );
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showDeliveryOrderLineQuantityDialog(
          context,
          orderId: 9,
          line: _line,
        ),
      );

      await tester.enterText(key('delivery_order_line_quantity_field'), '30');
      await tester.pump();
      await tester.tap(key('delivery_order_line_quantity_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_line_quantity_dialog'), findsOneWidget);
      expect(
        find.text(
          l10n.apiErrorDeliveryOrderQuantityExceedsRemaining('30', '12'),
        ),
        findsOneWidget,
      );
      expect(results, isEmpty);
    });
  });

  group('cancel', () {
    final confirmed = _order.copyWith(
      serial: 1532,
      status: DeliveryOrderStatus.inPreparation,
    );

    FilledButton submit(WidgetTester tester) =>
        tester.widget<FilledButton>(key('delivery_order_cancel_submit'));

    testWidgets('names the folio, customer and date', (tester) async {
      await pumpOpener(
        tester,
        actions: _FakeActions(),
        open: (context) => showCancelDeliveryOrderDialog(context, confirmed),
      );

      expect(find.text(l10n.deliveryOrderCancelTitle('1532')), findsOneWidget);
      expect(
        tester.widget<Text>(key('delivery_order_cancel_summary')).data,
        l10n.deliveryOrderCancelSummary('Ferretería López', '2026-11-15'),
      );
    });

    testWidgets('stays disabled for a blank or whitespace reason', (
      tester,
    ) async {
      await pumpOpener(
        tester,
        actions: _FakeActions(),
        open: (context) => showCancelDeliveryOrderDialog(context, confirmed),
      );

      expect(submit(tester).onPressed, isNull);
      await tester.enterText(key('delivery_order_cancel_reason'), '   \n ');
      await tester.pump();
      expect(submit(tester).onPressed, isNull);
      await tester.enterText(key('delivery_order_cancel_reason'), 'Motivo');
      await tester.pump();
      expect(submit(tester).onPressed, isNotNull);
    });

    testWidgets('sends the trimmed reason and closes with no error', (
      tester,
    ) async {
      final actions = _FakeActions();
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showCancelDeliveryOrderDialog(context, confirmed),
      );

      await tester.enterText(
        key('delivery_order_cancel_reason'),
        '  Cliente canceló  ',
      );
      await tester.pump();
      await tester.tap(key('delivery_order_cancel_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['cancel Cliente canceló']);
      expect(results.single, (error: null));
    });

    testWidgets('state.transition_invalid closes the dialog with it', (
      tester,
    ) async {
      const error = AppError.server(
        statusCode: 409,
        problem: ApiProblem(
          codeName: 'state.transition_invalid',
          code: api.ErrorCode.statePeriodTransitionInvalid,
        ),
      );
      final results = await pumpOpener(
        tester,
        actions: _FakeActions(error: error),
        open: (context) => showCancelDeliveryOrderDialog(context, confirmed),
      );

      await tester.enterText(key('delivery_order_cancel_reason'), 'Motivo');
      await tester.pump();
      await tester.tap(key('delivery_order_cancel_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_cancel_dialog'), findsNothing);
      expect(results.single, (error: error));
    });

    testWidgets('backing out answers null and cancels nothing', (tester) async {
      final actions = _FakeActions();
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showCancelDeliveryOrderDialog(context, confirmed),
      );

      await tester.tap(find.text(l10n.deliveryOrderBackButton));
      await tester.pumpAndSettle();

      expect(actions.calls, isEmpty);
      expect(results.single, isNull);
    });
  });

  group('requeue and ready', () {
    final failed = _order.copyWith(
      serial: 1532,
      status: DeliveryOrderStatus.failed,
    );
    final approved = _order.copyWith(
      serial: 1529,
      status: DeliveryOrderStatus.approved,
      type: FulfillmentType.counterPickup,
    );

    testWidgets('requeue names the folio and customer, then requeues', (
      tester,
    ) async {
      final actions = _FakeActions();
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showRequeueDeliveryOrderDialog(context, failed),
      );

      expect(find.text(l10n.deliveryOrderRequeueTitle('1532')), findsOneWidget);
      expect(
        find.text(l10n.deliveryOrderRequeueBody('Ferretería López')),
        findsOneWidget,
      );
      await tester.tap(key('delivery_order_requeue_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['requeue']);
      expect(results.single, (error: null));
    });

    testWidgets('a not_failed refusal closes the requeue with it', (
      tester,
    ) async {
      const error = AppError.server(
        statusCode: 409,
        problem: ApiProblem(
          codeName: 'delivery_order.not_failed',
          code: api.ErrorCode.deliveryOrderPeriodNotFailed,
        ),
      );
      final results = await pumpOpener(
        tester,
        actions: _FakeActions(error: error),
        open: (context) => showRequeueDeliveryOrderDialog(context, failed),
      );

      await tester.tap(key('delivery_order_requeue_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_requeue_dialog'), findsNothing);
      expect(results.single, (error: error));
    });

    testWidgets('ready names the folio and customer, then marks it', (
      tester,
    ) async {
      final actions = _FakeActions();
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showReadyDeliveryOrderDialog(context, approved),
      );

      expect(find.text(l10n.deliveryOrderReadyTitle('1529')), findsOneWidget);
      expect(
        find.text(l10n.deliveryOrderReadyBody('Ferretería López')),
        findsOneWidget,
      );
      await tester.tap(key('delivery_order_ready_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['ready']);
      expect(results.single, (error: null));
    });
  });
}
