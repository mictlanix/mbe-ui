import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_step.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_summary_panel.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockDeliveryOrderRepository extends Mock implements DeliveryOrderRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

/// Spec 031 US1 (issue #164): the Venta step's own continue action must be
/// unavailable for the whole of an outstanding line write, and available
/// again the instant the totals it reads catch up. US4 (below) gives the
/// Cobro and Entrega steps the same guarantee.
///
/// These tests drive `PosSaleController` directly rather than through a
/// specific field's UI (the discount field, the warehouse picker) — the gate
/// reads `pendingWritesProvider(posWritesScope)`, which every mutating call
/// registers in identically, so exercising the controller is a more direct
/// assertion of the gate itself (FR-001…FR-009) than coupling this suite to
/// one field's rendering details, which `sale_line_discount_test.dart` (US2)
/// covers on its own terms.
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

  FloatingActionButton continueButton(WidgetTester tester) => tester
      .widget<FloatingActionButton>(find.byKey(const Key('pos_continue_to_payment')));

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

  Future<ProviderContainer> pumpCapture(WidgetTester tester, MockSalesOrderRepository salesOrder) =>
      pumpPos(
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

  testWidgets('disabled while a line write is outstanding, enabled once the '
      'totals it produced are on screen (SC-001, SC-002)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    final initial = testSale(lines: [testLine(discountRate: '0')]);
    when(() => salesOrder.open()).thenAnswer((_) async => initial);
    final completer = Completer<Sale>();
    stubUpdateLine(salesOrder, (_) => completer.future);

    final container = await pumpCapture(tester, salesOrder);
    await container.read(posSaleControllerProvider.notifier).ensureOpen();
    await tester.pumpAndSettle();
    expect(continueButton(tester).onPressed, isNotNull);

    final write = container
        .read(posSaleControllerProvider.notifier)
        .updateLine(lineId: 5, discountRate: '0.15');
    await tester.pump();

    expect(
      continueButton(tester).onPressed,
      isNull,
      reason: 'a line write is outstanding — the totals on screen are stale',
    );

    final settled = initial.copyWith(
      lines: [testLine(discountRate: '0.15')],
      total: '104.40',
      balance: '104.40',
    );
    completer.complete(settled);
    await write;
    await tester.pump();

    expect(
      continueButton(tester).onPressed,
      isNotNull,
      reason: 'the write settled — the same frame the totals updated',
    );
    expect(find.text(r'$104.40'), findsWidgets);
  });

  testWidgets('a refused write leaves the button available again — no '
      'permanent lockout (SC-003)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    final initial = testSale(lines: [testLine()]);
    when(() => salesOrder.open()).thenAnswer((_) async => initial);
    stubUpdateLine(salesOrder, (_) async => throw const AppError.server());

    final container = await pumpCapture(tester, salesOrder);
    await container.read(posSaleControllerProvider.notifier).ensureOpen();
    await tester.pumpAndSettle();

    await container
        .read(posSaleControllerProvider.notifier)
        .updateLine(lineId: 5, discountRate: '0.15')
        .catchError((_) {});
    await tester.pump();

    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('stays disabled until both of two overlapping line writes '
      'settle (SC-004)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    final initial = testSale(lines: [testLine(id: 5), testLine(id: 6)]);
    when(() => salesOrder.open()).thenAnswer((_) async => initial);
    final first = Completer<Sale>();
    final second = Completer<Sale>();
    var call = 0;
    stubUpdateLine(salesOrder, (_) {
      call++;
      return call == 1 ? first.future : second.future;
    });

    final container = await pumpCapture(tester, salesOrder);
    await container.read(posSaleControllerProvider.notifier).ensureOpen();
    await tester.pumpAndSettle();

    final notifier = container.read(posSaleControllerProvider.notifier);
    final w1 = notifier.updateLine(lineId: 5, discountRate: '0.10');
    final w2 = notifier.updateLine(lineId: 6, discountRate: '0.10');
    await tester.pump();
    expect(continueButton(tester).onPressed, isNull);

    first.complete(initial);
    await w1;
    await tester.pump();
    expect(
      continueButton(tester).onPressed,
      isNull,
      reason: 'the second write is still outstanding',
    );

    second.complete(initial);
    await w2;
    await tester.pump();
    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('a value still inside its coalescing window blocks the same '
      'way a request in flight does (FR-004)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    final initial = testSale(lines: [testLine()]);
    when(() => salesOrder.open()).thenAnswer((_) async => initial);
    stubUpdateLine(salesOrder, (_) async => initial);

    final container = await pumpCapture(tester, salesOrder);
    await container.read(posSaleControllerProvider.notifier).ensureOpen();
    await tester.pumpAndSettle();

    // Tap the quantity stepper's own + button — this exercises the real
    // coalescing-window path end to end, through the widget the cashier
    // actually presses, rather than the controller's `step()` directly.
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('sale_line_row_5')),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pump();

    expect(
      continueButton(tester).onPressed,
      isNull,
      reason: 'confirmed but still coalescing — not yet a request, still outstanding',
    );

    // Let the ~400ms debounce fire and the (stubbed, instant) write settle.
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('an outstanding write disables only the continue action — '
      'the rest of the surface stays live (FR-009, SC-005)', (tester) async {
    final salesOrder = MockSalesOrderRepository();
    final initial = testSale(lines: [testLine(id: 5), testLine(id: 6)]);
    when(() => salesOrder.open()).thenAnswer((_) async => initial);
    final completer = Completer<Sale>();
    stubUpdateLine(salesOrder, (_) => completer.future);

    final container = await pumpCapture(tester, salesOrder);
    await container.read(posSaleControllerProvider.notifier).ensureOpen();
    await tester.pumpAndSettle();

    unawaited(
      container
          .read(posSaleControllerProvider.notifier)
          .updateLine(lineId: 5, discountRate: '0.10'),
    );
    await tester.pump();
    expect(continueButton(tester).onPressed, isNull);

    // The other line's + button is still tappable and still animates — this
    // only fails if something disabled the whole surface rather than just
    // the continue action.
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('sale_line_row_6')),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    completer.complete(initial);
    await tester.pumpAndSettle();
  });

  group('Cobro step (US4)', () {
    FloatingActionButton closeButton(WidgetTester tester) => tester
        .widget<FloatingActionButton>(find.byKey(const Key('payment_close_button')));

    Future<ProviderContainer> pumpSummary(
      WidgetTester tester,
      MockSalesOrderRepository salesOrder,
      MockCustomerPaymentRepository paymentRepository,
    ) => pumpPos(
      tester,
      Consumer(
        builder: (context, ref, _) {
          final sale = ref.watch(posSaleControllerProvider).valueOrNull;
          return sale == null
              ? const SizedBox.shrink()
              : PaymentSummaryPanel(sale: sale, onClose: () {});
        },
      ),
      overrides: [
        salesOrderOverride(salesOrder),
        customerPaymentOverride(paymentRepository),
      ],
    );

    testWidgets("the FAB is unavailable while a payment is being applied, "
        'available again with the settled balance (SC-001, SC-002)', (
      tester,
    ) async {
      final salesOrder = MockSalesOrderRepository();
      final paymentRepository = MockCustomerPaymentRepository();
      final initial = testSale(status: SaleStatus.completed, balance: '50.00');
      when(() => salesOrder.open()).thenAnswer((_) async => initial);
      when(
        () => salesOrder.getById(saleId: any(named: 'saleId')),
      ).thenAnswer((_) async => initial.copyWith(balance: '0.00'));
      final completer = Completer<int>();
      when(
        () => paymentRepository.createPayment(
          customer: any(named: 'customer'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          currency: any(named: 'currency'),
          paymentCharge: any(named: 'paymentCharge'),
          reference: any(named: 'reference'),
        ),
      ).thenAnswer((_) => completer.future);
      when(
        () => paymentRepository.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).thenAnswer((_) async {});

      final container = await pumpSummary(tester, salesOrder, paymentRepository);
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();
      expect(closeButton(tester).onPressed, isNull, reason: 'balance is still outstanding');

      final paymentNotifier = container.read(paymentControllerProvider.notifier);
      paymentNotifier.setAmount('50.00');
      paymentNotifier.selectMethod(methodCode: 1);
      final submitted = paymentNotifier.submit(initial);
      await tester.pump();

      expect(
        closeButton(tester).onPressed,
        isNull,
        reason: 'the payment is still being applied',
      );

      completer.complete(1);
      await submitted;
      await tester.pumpAndSettle();

      expect(closeButton(tester).onPressed, isNotNull);
    });

    testWidgets('the FAB is unavailable while a reversal is applying (US4)', (
      tester,
    ) async {
      final salesOrder = MockSalesOrderRepository();
      final paymentRepository = MockCustomerPaymentRepository();
      final initial = testSale(status: SaleStatus.completed, balance: '0.00');
      when(() => salesOrder.open()).thenAnswer((_) async => initial);
      when(
        () => salesOrder.getById(saleId: any(named: 'saleId')),
      ).thenAnswer((_) async => initial.copyWith(balance: '50.00'));
      final completer = Completer<void>();
      when(
        () => paymentRepository.reverseApplication(
          customerPaymentId: any(named: 'customerPaymentId'),
          applicationId: any(named: 'applicationId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) => completer.future);

      final container = await pumpSummary(tester, salesOrder, paymentRepository);
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();
      expect(closeButton(tester).onPressed, isNotNull, reason: 'balance already settled');

      final reversed = container.read(paymentControllerProvider.notifier).reverse(
        saleId: initial.id,
        customerPaymentId: 1,
        applicationId: 1,
        reason: 'test',
      );
      await tester.pump();

      expect(closeButton(tester).onPressed, isNull, reason: 'the reversal is still applying');

      completer.complete();
      await reversed;
      await tester.pumpAndSettle();

      // The reversal reopens the balance (correctly re-blocking the FAB on
      // its own, unrelated condition) — what this asserts is that the write
      // gate itself cleared rather than staying stuck, by exercising the
      // *other* path back to "available": settle the balance too and watch
      // the FAB come back once nothing at all is outstanding.
      expect(
        closeButton(tester).onPressed,
        isNull,
        reason: 'the reversal reopened the balance — a different, legitimate gate',
      );
      when(
        () => salesOrder.getById(saleId: any(named: 'saleId')),
      ).thenAnswer((_) async => initial.copyWith(balance: '0.00'));
      await container.read(posSaleControllerProvider.notifier).refresh();
      await tester.pumpAndSettle();
      expect(
        closeButton(tester).onPressed,
        isNotNull,
        reason: 'nothing outstanding and the balance is settled again',
      );
    });
  });

  group('Entrega step (US4)', () {
    final customer = Customer(
      customerId: 7,
      code: 'C-7',
      name: 'FERRETERÍA LOS PINOS',
      creditLimit: '0',
      creditDays: 0,
      priceList: const PriceListRef(id: 1, name: 'Mostrador'),
      shipping: true,
      shippingRequiredDocument: false,
      status: EntityStatus.active,
      addresses: const [
        AddressListItem(addressId: 11, label: 'Destino uno', type: AddressType.business),
      ],
    );

    Destination fullyAssigned() => const Destination(
      id: 500,
      fulfillmentType: FulfillmentType.delivery,
      shipTo: 11,
      status: DeliveryOrderStatus.draft,
      lines: [
        DestinationLine(
          id: 900,
          salesOrderDetail: 5,
          product: 11,
          productCode: 'P-11',
          productName: 'Widget',
          quantity: '10',
        ),
      ],
    );

    Future<ProviderContainer> pumpEntrega(
      WidgetTester tester,
      MockDeliveryOrderRepository deliveries,
    ) async {
      final customers = MockCustomerRepository();
      when(
        () => customers.get(customerId: any(named: 'customerId')),
      ).thenAnswer((_) async => customer);
      return pumpPos(
        tester,
        DeliveryStep(
          sale: testSale(lines: [testLine(id: 5, quantity: '10')]),
          mode: FulfillmentMode.delivery,
          onClose: () {},
        ),
        overrides: [
          deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
          customerRepositoryProvider.overrideWithValue(customers),
        ],
      );
    }

    testWidgets('the finish action is unavailable while a destination write '
        'is outstanding, available again once it settles (SC-001, SC-002)', (
      tester,
    ) async {
      final deliveries = MockDeliveryOrderRepository();
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer((_) async => [fullyAssigned()]);
      final completer = Completer<Destination>();
      when(
        () => deliveries.updateHeader(
          destinationId: any(named: 'destinationId'),
          shipTo: any(named: 'shipTo'),
          contact: any(named: 'contact'),
          date: any(named: 'date'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) => completer.future);

      final container = await pumpEntrega(tester, deliveries);
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      FloatingActionButton finishButton() => tester.widget<FloatingActionButton>(
        find.ancestor(
          of: find.text(l10n.posFinishSale),
          matching: find.byType(FloatingActionButton),
        ),
      );
      expect(finishButton().onPressed, isNotNull, reason: 'already fully assigned');

      final write = container
          .read(
            deliveryControllerProvider(
              testSale(lines: [testLine(id: 5, quantity: '10')]),
            ).notifier,
          )
          .updateDestination(destinationId: 500, comment: 'note');
      await tester.pump();

      expect(finishButton().onPressed, isNull, reason: 'a destination write is outstanding');

      completer.complete(fullyAssigned());
      await write;
      await tester.pumpAndSettle();

      expect(finishButton().onPressed, isNotNull);
    });
  });
}
