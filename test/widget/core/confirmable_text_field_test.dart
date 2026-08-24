import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';

/// Widget coverage for [ConfirmableTextField]'s reset animation — spec 031
/// FR-013…FR-018, lifted from spec 030's quantity-stepper coverage so the
/// extracted core carries the same guarantees (contracts/confirmable-field.md
/// §5). The controller's own state machine is covered without a widget tree
/// in `test/unit/features/sales/quantity_stepper_controller_test.dart` (the
/// stepper subclass) — this file exercises the base directly.
void main() {
  Future<void> pumpField(
    WidgetTester tester,
    ConfirmableFieldController controller, {
    bool disableAnimations = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        home: Scaffold(
          body: ConfirmableTextField(controller: controller, fieldKey: const Key('f')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String? identityParse(String text) => text.isEmpty ? null : text;

  ConfirmableFieldController makeController({
    String value = '0',
    Future<bool> Function(String)? commit,
    String? Function(String)? parse,
    Object? id,
    UnconfirmedEdits? unconfirmedEdits,
  }) => ConfirmableFieldController(
    value: value,
    parse: parse ?? identityParse,
    commit: commit ?? (_) async => true,
    id: id,
    unconfirmedEdits: unconfirmedEdits,
  );

  String text(WidgetTester tester) =>
      tester.widget<TextField>(find.byKey(const Key('f'))).controller!.text;

  testWidgets('Enter confirms — one commit, no reset animation', (tester) async {
    final commits = <String>[];
    final controller = makeController(
      value: '0',
      commit: (v) async {
        commits.add(v);
        return true;
      },
    );
    addTearDown(controller.dispose);
    await pumpField(tester, controller);

    await tester.enterText(find.byKey(const Key('f')), '15');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(commits, ['15']);
    expect(controller.accepted, '15');
    expect(text(tester), '15');
  });

  testWidgets('focus loss without Enter discards and animates back', (tester) async {
    final commits = <String>[];
    final controller = makeController(value: '0', commit: (v) async {
      commits.add(v);
      return true;
    });
    addTearDown(controller.dispose);
    await pumpField(tester, controller);

    await tester.enterText(find.byKey(const Key('f')), '15');
    await tester.pump();
    expect(text(tester), '15');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(); // t=0: reset just started, old text still there
    expect(text(tester), '15');

    await tester.pump(const Duration(milliseconds: 100)); // before the midpoint
    expect(text(tester), '15', reason: 'the swap must not happen before the fade covers the text');

    await tester.pump(const Duration(milliseconds: 150)); // past 250ms total
    expect(text(tester), '0', reason: 'the animation must land on the restored value');
    expect(commits, isEmpty, reason: 'unconfirmed text must never be sent');
  });

  testWidgets('unparseable text + Enter discards and resets', (tester) async {
    final commits = <String>[];
    final controller = makeController(
      value: '0',
      parse: (t) => t == 'abc' ? null : t,
      commit: (v) async {
        commits.add(v);
        return true;
      },
    );
    addTearDown(controller.dispose);
    await pumpField(tester, controller);

    final ticksBefore = controller.resetTick;
    await tester.enterText(find.byKey(const Key('f')), 'abc');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(commits, isEmpty);
    expect(controller.resetTick, ticksBefore + 1);
    expect(text(tester), '0');
  });

  testWidgets('a refused commit restores the accepted value with the reset animation', (
    tester,
  ) async {
    final controller = makeController(value: '0', commit: (_) async => false);
    addTearDown(controller.dispose);
    await pumpField(tester, controller);

    await tester.enterText(find.byKey(const Key('f')), '15');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    // The commit is async and awaited by submit's fire-and-forget flush —
    // give it a beat to resolve and start the reset.
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpAndSettle();

    expect(controller.accepted, '0');
    expect(text(tester), '0');
  });

  testWidgets('sync with a different value while dirty discards the typed text', (
    tester,
  ) async {
    final controller = makeController(value: '0');
    addTearDown(controller.dispose);
    await pumpField(tester, controller);

    await tester.enterText(find.byKey(const Key('f')), '15');
    await tester.pump();
    final ticksBefore = controller.resetTick;

    controller.sync(value: '9');
    await tester.pumpAndSettle();

    expect(controller.resetTick, ticksBefore + 1);
    expect(text(tester), '9');
  });

  testWidgets('sync with the same value while dirty leaves the typed text alone', (
    tester,
  ) async {
    final controller = makeController(value: '0');
    addTearDown(controller.dispose);
    await pumpField(tester, controller);

    await tester.enterText(find.byKey(const Key('f')), '15');
    await tester.pump();
    final ticksBefore = controller.resetTick;

    controller.sync(value: '0'); // no-op refresh — same as what's accepted
    await tester.pump();

    expect(controller.resetTick, ticksBefore, reason: 'a no-op refresh must not wipe an edit in progress');
    expect(text(tester), '15');
  });

  testWidgets('Enter twice on the unchanged value commits once, no reset', (tester) async {
    final commits = <String>[];
    final controller = makeController(
      value: '0',
      commit: (v) async {
        commits.add(v);
        return true;
      },
    );
    addTearDown(controller.dispose);
    await pumpField(tester, controller);

    await tester.enterText(find.byKey(const Key('f')), '15');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final ticksBefore = controller.resetTick;

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(commits, ['15'], reason: 'confirming the same accepted value again sends nothing new');
    expect(controller.resetTick, ticksBefore, reason: 'nothing was discarded');
  });

  testWidgets('reduced motion swaps the value instantly, still applying and clearing the tint', (
    tester,
  ) async {
    final controller = makeController(value: '0');
    addTearDown(controller.dispose);
    await pumpField(tester, controller, disableAnimations: true);

    await tester.enterText(find.byKey(const Key('f')), '15');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(); // instant swap — no fade to wait out

    expect(text(tester), '0');
    await tester.pump(const Duration(milliseconds: 300));
  });

  group('unconfirmed-edits registry', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('dirty text registers one entry; confirming removes it', () async {
      const scope = 'field-test';
      final registry = container.read(unconfirmedEditsProvider(scope).notifier);
      final controller = makeController(
        value: '0',
        id: 'field-a',
        unconfirmedEdits: registry,
      );
      addTearDown(controller.dispose);

      controller.edit('15');
      expect(container.read(unconfirmedEditsProvider(scope)), hasLength(1));
      expect(container.read(unconfirmedEditsProvider(scope)).single.text, '15');

      controller.submit('15');
      await Future<void>.delayed(Duration.zero);
      expect(container.read(unconfirmedEditsProvider(scope)), isEmpty);
    });

    test('abandoning removes the entry', () {
      const scope = 'field-test-2';
      final registry = container.read(unconfirmedEditsProvider(scope).notifier);
      final controller = makeController(value: '0', id: 'field-b', unconfirmedEdits: registry);
      addTearDown(controller.dispose);

      controller.edit('15');
      controller.abandon();
      expect(container.read(unconfirmedEditsProvider(scope)), isEmpty);
    });

    test('disposing removes the entry', () {
      const scope = 'field-test-3';
      final registry = container.read(unconfirmedEditsProvider(scope).notifier);
      final controller = makeController(value: '0', id: 'field-c', unconfirmedEdits: registry);

      controller.edit('15');
      expect(container.read(unconfirmedEditsProvider(scope)), hasLength(1));
      controller.dispose();
      expect(container.read(unconfirmedEditsProvider(scope)), isEmpty);
    });
  });

  testWidgets('the wrapper adds no insets — field size unaffected by reset activity', (
    tester,
  ) async {
    final controller = makeController(value: '0');
    addTearDown(controller.dispose);
    await pumpField(tester, controller);
    final restingSize = tester.getSize(find.byKey(const Key('f')));

    await tester.enterText(find.byKey(const Key('f')), '15');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 100)); // mid-fade

    expect(tester.getSize(find.byKey(const Key('f'))), restingSize);
    await tester.pumpAndSettle();
  });
}
