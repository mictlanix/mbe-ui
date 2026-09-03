import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/presentation/widgets/quantity_stepper.dart';

/// Unit coverage for [QuantityStepperController] — the state machine every
/// host (`SaleLineRow`, `SaleLineCard`, `DestinationCard`) shares (spec 030
/// research R1/R2). Covers FR-001…FR-016 and the `sync` precedence table
/// from research R7, independently of any widget tree.
void main() {
  group('stepping and debounce (US1)', () {
    test('a burst of taps within the debounce window sends once, with the '
        'final value (FR-003)', () async {
      final commits = <String>[];
      final controller = QuantityStepperController(
        value: '1',
        onCommit: (v) async {
          commits.add(v);
          return true;
        },
      );
      addTearDown(controller.dispose);

      for (var i = 0; i < 5; i++) {
        controller.step(1);
      }
      expect(controller.displayed, '6');

      await Future<void>.delayed(kQuantityCommitDebounce + const Duration(milliseconds: 100));

      expect(commits, ['6']);
    });

    // spec 036 SC-008: the quantity-commit debounce is deployment-configurable
    // (`quantityCommitDebounceProvider`, read by `sale_line_editing.dart` and
    // `destination_card.dart`) — this proves the `debounce` constructor param
    // those hosts feed it actually changes when the commit fires, rather than
    // the shared [kQuantityCommitDebounce] default always winning.
    test(
      'a custom debounce commits at its own delay, not kQuantityCommitDebounce',
      () async {
        const overriddenDebounce = Duration(milliseconds: 700);
        final commits = <String>[];
        final controller = QuantityStepperController(
          value: '1',
          debounce: overriddenDebounce,
          onCommit: (v) async {
            commits.add(v);
            return true;
          },
        );
        addTearDown(controller.dispose);

        controller.step(1);

        // Past the shared default (400ms) but short of the overridden one:
        // nothing should have committed yet.
        await Future<void>.delayed(kQuantityCommitDebounce + const Duration(milliseconds: 100));
        expect(commits, isEmpty);

        await Future<void>.delayed(
          overriddenDebounce - kQuantityCommitDebounce + const Duration(milliseconds: 100),
        );
        expect(commits, ['2']);
      },
    );

    test('step never crosses the floor (FR-007/FR-008)', () {
      final controller = QuantityStepperController(
        value: '1',
        min: '1',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      expect(controller.canDecrement, isFalse);
      controller.step(-1);
      expect(controller.displayed, '1');
    });

    test('step never crosses the ceiling (FR-007/FR-008)', () {
      final controller = QuantityStepperController(
        value: '5',
        max: '5',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      expect(controller.canIncrement, isFalse);
      controller.step(1);
      expect(controller.displayed, '5');
    });

    test('a value landing while a commit is in flight is applied after it, '
        'never overlapping (FR-004/FR-006)', () async {
      final commits = <String>[];
      final inFlight = Completer<bool>();
      var calls = 0;
      final controller = QuantityStepperController(
        value: '1',
        onCommit: (v) async {
          calls++;
          commits.add(v);
          if (calls == 1) return inFlight.future;
          return true;
        },
      );
      addTearDown(controller.dispose);

      controller.step(1); // pending '2'
      final firstFlush = controller.flush(); // starts the in-flight commit of '2'

      // A second step lands mid-flight.
      controller.step(1); // pending '3', scheduled behind the in-flight one
      await controller.flush(); // in-flight already running; this must not overlap it

      expect(calls, 1, reason: 'the second flush must not start a second commit '
          'while the first is still in flight');

      inFlight.complete(true);
      await firstFlush;
      // The tail recursion inside `_flush` picks up the newer pending value.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(commits, ['2', '3']);
      expect(controller.accepted, '3');
    });

    test('dispose fires a still-pending commit rather than dropping it '
        '(FR-005)', () async {
      String? sent;
      final controller = QuantityStepperController(
        value: '1',
        onCommit: (v) async {
          sent = v;
          return true;
        },
      );

      controller.step(1); // pending '2', not yet flushed
      controller.dispose();

      await Future<void>.delayed(Duration.zero);
      expect(sent, '2');
    });

    test('sync leaves the displayed value alone while a commit is pending '
        '(research R7)', () {
      final controller = QuantityStepperController(
        value: '1',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      controller.step(1); // pending '2'
      controller.sync(value: '9'); // a discount edit refetched the sale mid-burst

      expect(controller.displayed, '2');
      expect(controller.accepted, '9');
    });

    test('sync adopts the server value when nothing is pending or typed', () {
      final controller = QuantityStepperController(
        value: '1',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      final ticksBefore = controller.resetTick;
      controller.sync(value: '9');

      expect(controller.displayed, '9');
      expect(controller.resetTick, ticksBefore, reason: 'an ordinary update never animates');
    });
  });

  group('confirming and discarding a typed value (US2)', () {
    test('submit with a valid, in-range value confirms it like a step '
        '(FR-010)', () async {
      final commits = <String>[];
      final controller = QuantityStepperController(
        value: '1',
        onCommit: (v) async {
          commits.add(v);
          return true;
        },
      );
      addTearDown(controller.dispose);

      controller.edit('9');
      controller.submit('9');
      expect(controller.displayed, '9');

      await controller.flush();
      expect(commits, ['9']);
    });

    test('submit with unparseable text discards and resets (FR-012)', () async {
      final controller = QuantityStepperController(
        value: '7',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      final ticksBefore = controller.resetTick;
      controller.edit('abc');
      controller.submit('abc');

      expect(controller.displayed, '7');
      expect(controller.resetTick, ticksBefore + 1);

      await controller.flush(); // nothing pending — no commit should fire
    });

    test('submit outside the ceiling discards and resets (FR-012)', () {
      final controller = QuantityStepperController(
        value: '3',
        max: '5',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      final ticksBefore = controller.resetTick;
      controller.submit('10');

      expect(controller.displayed, '3');
      expect(controller.resetTick, ticksBefore + 1);
    });

    test('abandon with unconfirmed text discards and resets (FR-011)', () {
      final controller = QuantityStepperController(
        value: '7',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      final ticksBefore = controller.resetTick;
      controller.edit('25');
      expect(controller.displayed, '25');

      controller.abandon();

      expect(controller.displayed, '7');
      expect(controller.resetTick, ticksBefore + 1);
    });

    test('abandon with nothing typed is a no-op', () {
      final controller = QuantityStepperController(
        value: '7',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      final ticksBefore = controller.resetTick;
      controller.abandon();
      expect(controller.resetTick, ticksBefore);
    });

    test('canDecrement/canIncrement never parse unconfirmed text — an '
        'emptied or partial field must not throw (regression: cashier '
        'clearing the field crashed the app)', () {
      final controller = QuantityStepperController(
        value: '7',
        min: '1',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      for (final draft in ['', '-', '.', 'abc']) {
        controller.edit(draft);
        expect(controller.displayed, draft);
        expect(() => controller.canDecrement, returnsNormally);
        expect(() => controller.canIncrement, returnsNormally);
        // Both reflect the last accepted value (7), not the unparseable
        // draft — stepping ignores the draft too (FR-015).
        expect(controller.canDecrement, isTrue);
        expect(controller.canIncrement, isTrue);
      }
    });

    test('a step taken with unconfirmed text present steps from the '
        'accepted value, not the typed one (FR-015)', () {
      final controller = QuantityStepperController(
        value: '7',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      controller.edit('25');
      controller.step(1);

      expect(controller.displayed, '8');
    });

    test('sync discards unconfirmed typed text that disagrees with the new '
        'server value, and resets (research R7)', () {
      final controller = QuantityStepperController(
        value: '7',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      final ticksBefore = controller.resetTick;
      controller.edit('25');
      controller.sync(value: '9');

      expect(controller.displayed, '9');
      expect(controller.resetTick, ticksBefore + 1);
    });

    test('a refused commit restores the accepted value and resets '
        '(research R3)', () async {
      final controller = QuantityStepperController(
        value: '7',
        onCommit: (_) async => false,
      );
      addTearDown(controller.dispose);

      final ticksBefore = controller.resetTick;
      controller.step(1);
      await controller.flush();

      expect(controller.displayed, '7');
      expect(controller.resetTick, ticksBefore + 1);
    });

    test('an accepted commit does not animate (FR-014)', () async {
      final controller = QuantityStepperController(
        value: '7',
        onCommit: (_) async => true,
      );
      addTearDown(controller.dispose);

      final ticksBefore = controller.resetTick;
      controller.step(1);
      await controller.flush();

      expect(controller.accepted, '8');
      expect(controller.resetTick, ticksBefore);
    });
  });
}
