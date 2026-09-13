import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_step_controller.dart';

/// Minimal local fixture, matching the pattern `open_sale_resolution_test.dart`
/// already uses for `pos_resume_controller.dart`'s own resume logic.
Sale _sale({required SaleStatus status, int customer = 7}) => Sale(
  id: 42,
  facility: 9,
  pointSale: 3,
  salesperson: 100,
  customer: customer,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  promiseDate: DateTime(2026, 9, 12),
  status: status,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  balance: '0',
  date: DateTime(2026, 9, 12),
  dueDate: DateTime(2026, 9, 12),
  priority: Priority.normal,
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  OrderStepController notifier() =>
      container.read(orderStepControllerProvider.notifier);

  test('starts on Cliente', () {
    expect(container.read(orderStepControllerProvider).current, OrderStep.cliente);
  });

  group('forward transitions', () {
    test('advanceToVenta moves to Venta', () {
      notifier().advanceToVenta();
      expect(container.read(orderStepControllerProvider).current, OrderStep.venta);
    });

    test('advanceToEntrega moves to Entrega', () {
      notifier()
        ..advanceToVenta()
        ..advanceToEntrega();
      expect(container.read(orderStepControllerProvider).current, OrderStep.entrega);
    });
  });

  group('returning to an earlier step (FR-006)', () {
    test('returnToVenta succeeds while the order is a draft', () {
      notifier()
        ..advanceToVenta()
        ..advanceToEntrega();
      expect(notifier().canReturnToVenta(isDraft: true), isTrue);
      notifier().returnToVenta();
      expect(container.read(orderStepControllerProvider).current, OrderStep.venta);
    });

    test('returnToVenta is refused once the order is not a draft (spec A2)', () {
      expect(notifier().canReturnToVenta(isDraft: false), isFalse);
    });

    test('returnToCliente succeeds while the order is a draft', () {
      notifier().advanceToVenta();
      expect(notifier().canReturnToCliente(isDraft: true), isTrue);
      notifier().returnToCliente();
      expect(container.read(orderStepControllerProvider).current, OrderStep.cliente);
    });

    test('returnToCliente is refused once the order is not a draft', () {
      expect(notifier().canReturnToCliente(isDraft: false), isFalse);
    });
  });

  test('reset returns to Cliente', () {
    notifier()
      ..advanceToVenta()
      ..advanceToEntrega()
      ..reset();
    expect(container.read(orderStepControllerProvider).current, OrderStep.cliente);
  });

  group('resumeTargetFor (data-model.md §4)', () {
    test('a draft on a real customer resumes on Venta', () {
      final target = notifier().resumeTargetFor(
        _sale(status: SaleStatus.draft),
        isGenericCustomer: false,
      );
      expect(target, OrderStep.venta);
    });

    test('a draft still on the generic customer resumes on Cliente', () {
      final target = notifier().resumeTargetFor(
        _sale(status: SaleStatus.draft, customer: 1),
        isGenericCustomer: true,
      );
      expect(target, OrderStep.cliente);
    });

    test('a completed order resumes on Entrega — only a destination create '
        'could have committed it', () {
      final target = notifier().resumeTargetFor(
        _sale(status: SaleStatus.completed),
        isGenericCustomer: false,
      );
      expect(target, OrderStep.entrega);
    });

    test('a paid order resumes on Entrega', () {
      final target = notifier().resumeTargetFor(
        _sale(status: SaleStatus.paid),
        isGenericCustomer: false,
      );
      expect(target, OrderStep.entrega);
    });

    test('resumeTo applies the target', () {
      notifier().resumeTo(_sale(status: SaleStatus.completed), isGenericCustomer: false);
      expect(container.read(orderStepControllerProvider).current, OrderStep.entrega);
    });
  });
}
