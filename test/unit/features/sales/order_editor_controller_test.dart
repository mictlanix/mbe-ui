import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

Sale _sale({int id = 42}) => Sale(
  id: id,
  facility: 9,
  pointSale: 3,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  promiseDate: DateTime(2026, 8, 20),
  status: SaleStatus.draft,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  balance: '0',
  date: DateTime(2026, 8, 20),
  dueDate: DateTime(2026, 8, 20),
  priority: Priority.normal,
);

void main() {
  late MockSalesOrderRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockSalesOrderRepository();
    container = ProviderContainer(
      overrides: [salesOrderRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('OrderEditorController', () {
    test('build(null) issues no request — a new order writes nothing on '
        'mount (FR-015, SC-005)', () async {
      final result = await container.read(
        orderEditorControllerProvider(null).future,
      );

      expect(result, isNull);
      verifyNever(() => repository.open());
      verifyNever(() => repository.getById(saleId: any(named: 'saleId')));
    });

    test('build(id) loads the existing order', () async {
      when(() => repository.getById(saleId: 42)).thenAnswer((_) async => _sale());

      final result = await container.read(
        orderEditorControllerProvider(42).future,
      );

      expect(result?.id, 42);
    });

    test('the first addLine opens the order, then adds the line', () async {
      final opened = _sale(id: 100);
      final withLine = _sale(id: 100);
      when(() => repository.open()).thenAnswer((_) async => opened);
      when(
        () => repository.addLine(
          saleId: 100,
          product: 11,
          quantity: any(named: 'quantity'),
          price: any(named: 'price'),
          discountRate: any(named: 'discountRate'),
          taxRate: any(named: 'taxRate'),
          warehouse: any(named: 'warehouse'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => withLine);

      final notifier = container.read(orderEditorControllerProvider(null).notifier);
      await notifier.addLine(product: 11, quantity: '1');

      verify(() => repository.open()).called(1);
      expect(
        container.read(orderEditorControllerProvider(null)).value?.id,
        100,
      );
    });

    test('a refused mutation leaves state at its last accepted value and '
        'rethrows (FR-028)', () async {
      when(() => repository.getById(saleId: 7)).thenAnswer((_) async => _sale(id: 7));
      when(
        () => repository.updateLine(
          saleId: 7,
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
          price: any(named: 'price'),
          discountRate: any(named: 'discountRate'),
          taxRate: any(named: 'taxRate'),
          warehouse: any(named: 'warehouse'),
          comment: any(named: 'comment'),
        ),
      ).thenThrow(Exception('refused'));

      await container.read(orderEditorControllerProvider(7).future);
      final notifier = container.read(orderEditorControllerProvider(7).notifier);

      await expectLater(
        () => notifier.updateLine(lineId: 1, quantity: '5'),
        throwsA(isA<Exception>()),
      );
      expect(
        container.read(orderEditorControllerProvider(7)).value?.id,
        7,
        reason: 'state stays at the last accepted value, not blanked',
      );
    });
  });
}
