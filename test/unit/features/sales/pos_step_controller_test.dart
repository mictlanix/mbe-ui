import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  PosStepController notifier() =>
      container.read(posStepControllerProvider.notifier);

  test('starts on Venta, counter pickup, 2 steps', () {
    final state = container.read(posStepControllerProvider);
    expect(state.current, PosStep.venta);
    expect(state.mode, FulfillmentMode.counterPickup);
    expect(state.stepCount, 2);
  });

  group('stepCount', () {
    test('is 2 for counter pickup', () {
      notifier().setMode(FulfillmentMode.counterPickup);
      expect(container.read(posStepControllerProvider).stepCount, 2);
    });

    test('is 3 for delivery', () {
      notifier().setMode(FulfillmentMode.delivery);
      expect(container.read(posStepControllerProvider).stepCount, 3);
    });

    test('is 3 for mixed', () {
      notifier().setMode(FulfillmentMode.mixed);
      expect(container.read(posStepControllerProvider).stepCount, 3);
    });
  });

  group('canConfirm', () {
    test('blocked with no lines', () {
      expect(notifier().canConfirm(lineCount: 0), isFalse);
    });

    test('allowed with at least one line', () {
      expect(notifier().canConfirm(lineCount: 1), isTrue);
    });
  });

  test('advanceToCobro moves the current step to Cobro', () {
    notifier().advanceToCobro();
    expect(container.read(posStepControllerProvider).current, PosStep.cobro);
  });

  group('canLeavePayment', () {
    test('blocked above a zero balance on immediate terms', () {
      expect(
        notifier().canLeavePayment(balance: '10.00', isCreditTerms: false),
        isFalse,
      );
    });

    test('allowed once the balance is exactly zero', () {
      expect(
        notifier().canLeavePayment(balance: '0.00', isCreditTerms: false),
        isTrue,
      );
    });

    test('allowed above a zero balance on credit terms (netD)', () {
      expect(
        notifier().canLeavePayment(balance: '250.00', isCreditTerms: true),
        isTrue,
      );
    });
  });

  group('advanceFromCobro', () {
    test('stays on Cobro for counter pickup — there is no Entrega step', () {
      final n = notifier();
      n.setMode(FulfillmentMode.counterPickup);
      n.advanceToCobro();
      n.advanceFromCobro();
      expect(container.read(posStepControllerProvider).current, PosStep.cobro);
    });

    test('moves to Entrega for delivery', () {
      final n = notifier();
      n.setMode(FulfillmentMode.delivery);
      n.advanceToCobro();
      n.advanceFromCobro();
      expect(container.read(posStepControllerProvider).current, PosStep.entrega);
    });

    test('moves to Entrega for mixed', () {
      final n = notifier();
      n.setMode(FulfillmentMode.mixed);
      n.advanceToCobro();
      n.advanceFromCobro();
      expect(container.read(posStepControllerProvider).current, PosStep.entrega);
    });
  });

  test('reset returns to Venta, counter pickup — what a genuinely new sale '
      'starts from (regression: a finished delivery/mixed sale left its mode '
      'selected on the next one)', () {
    final n = notifier();
    n.jumpTo(PosStep.entrega, mode: FulfillmentMode.mixed);

    n.reset();

    final state = container.read(posStepControllerProvider);
    expect(state.current, PosStep.venta);
    expect(state.mode, FulfillmentMode.counterPickup);
  });
}
