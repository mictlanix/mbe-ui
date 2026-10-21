import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/warehouse_picker_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';

import 'pos_test_harness.dart';
import 'session_override.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

/// spec 047 T044 (constitution §V): at the largest text size, the surfaces this
/// spec added or changed — the payment step with its change card and
/// reference dialog, and the warehouse pop-up — must not clip or overflow at a
/// supported desktop width. The platform scale stands in for the user's
/// extra-large level: the app composes the two multiplicatively, and setting it
/// here also reaches dialogs, which sit above the test's widget tree.
void main() {
  const desktop = Size(1280, 800);

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  void useExtraLargeText(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue =
        TextSizeLevel.extraLarge.factor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  group('payment step', () {
    late MockCustomerPaymentRepository paymentRepository;
    late MockPaymentMethodOptionRepository optionRepository;
    final sale = testSale(status: SaleStatus.completed, balance: '116.00');

    setUp(() {
      paymentRepository = MockCustomerPaymentRepository();
      optionRepository = MockPaymentMethodOptionRepository();
      when(
        () => paymentRepository.listForOrder(saleId: any(named: 'saleId')),
      ).thenAnswer((_) async => []);
      when(
        () => paymentRepository.createPayment(
          customer: any(named: 'customer'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          currency: any(named: 'currency'),
          paymentCharge: any(named: 'paymentCharge'),
          reference: any(named: 'reference'),
        ),
      ).thenAnswer((_) async => 500);
      when(
        () => paymentRepository.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => optionRepository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaymentMethodOptionPage(
          items: [
            PaymentMethodOption(
              paymentMethodOptionId: 1,
              facilityId: 9,
              facilityName: 'Matriz',
              name: 'Efectivo',
              numberOfPayments: 1,
              displayOnTicket: true,
              paymentMethod: 1,
              status: EntityStatus.active,
            ),
            PaymentMethodOption(
              paymentMethodOptionId: 2,
              facilityId: 9,
              facilityName: 'Matriz',
              name: 'Tarjeta de crédito',
              numberOfPayments: 1,
              displayOnTicket: true,
              paymentMethod: 4,
              status: EntityStatus.active,
              requiresReference: true,
            ),
          ],
          total: 2,
        ),
      );
    });

    Future<void> pumpStep(WidgetTester tester) => pumpPos(
      tester,
      PaymentStep(sale: sale, onClose: () {}),
      surface: desktop,
      overrides: [
        customerPaymentOverride(paymentRepository),
        openSessionOverride(),
        paymentMethodOptionRepositoryProvider.overrideWithValue(
          optionRepository,
        ),
      ],
    );

    testWidgets('the change card fits after a cash overpayment', (
      tester,
    ) async {
      useExtraLargeText(tester);
      await pumpStep(tester);

      await tester.enterText(
        find.byKey(const Key('payment_amount_field')),
        '150.00',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment_option_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('payment_change_card')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the reference dialog fits', (tester) async {
      useExtraLargeText(tester);
      await pumpStep(tester);

      await tester.tap(find.byKey(const Key('payment_option_2')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('payment_reference_dialog')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the warehouse pop-up fits', (tester) async {
    useExtraLargeText(tester);
    Warehouse warehouse(int id, String name) => Warehouse(
      warehouseId: id,
      facilityId: 9,
      facilityName: 'Main Store',
      code: 'WH-$id',
      name: name,
      status: EntityStatus.active,
    );
    await pumpPos(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showWarehousePicker(
            context,
            facilityId: 9,
            warehouses: [
              warehouse(3, 'Principal'),
              warehouse(4, 'Almacén central de materiales de construcción'),
            ],
            selected: 3,
            stock: const ProductStock(
              warehouses: [
                WarehouseStock(warehouse: 3, onHand: '10', available: '10'),
                WarehouseStock(warehouse: 4, onHand: '2', available: '2'),
              ],
            ),
            quantity: Decimal.fromInt(5),
            productName: 'Cemento gris 50 kg',
          ),
          child: const Text('open'),
        ),
      ),
      surface: desktop,
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('warehouse_picker_dialog')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
