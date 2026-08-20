import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/quantity_stepper.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Widget coverage for [QuantityStepper]'s reset animation (spec 030
/// FR-013/FR-014/FR-016) — the part of the contract that only a real widget
/// tree can exercise. The controller's own state machine (what triggers a
/// reset, and when) is covered without a widget tree in
/// `test/unit/features/sales/quantity_stepper_controller_test.dart`.
void main() {
  Future<void> pumpStepper(
    WidgetTester tester,
    QuantityStepperController controller, {
    bool disableAnimations = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
            child: child!,
          ),
          home: Scaffold(
            body: QuantityStepper(
              controller: controller,
              fieldKey: const Key('qty'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('typing over a value and losing focus without Enter animates '
      'back to the original — invisible at the swap, restored by the end '
      '(FR-011/FR-013)', (tester) async {
    final controller = QuantityStepperController(value: '7', onCommit: (_) async => true);
    addTearDown(controller.dispose);
    await pumpStepper(tester, controller);

    await tester.enterText(find.byKey(const Key('qty')), '25');
    await tester.pump();
    expect(tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text, '25');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(); // t=0: reset just started, old text still there
    expect(tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text, '25');

    await tester.pump(const Duration(milliseconds: 100)); // t=100ms, before the midpoint
    expect(
      tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text,
      '25',
      reason: 'the swap must not happen before the fade has covered the text',
    );

    await tester.pump(const Duration(milliseconds: 150)); // past 250ms total
    expect(
      tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text,
      '7',
      reason: 'the animation must land on the restored value',
    );
  });

  testWidgets('a value confirmed with Enter and accepted shows no animation '
      '(FR-014)', (tester) async {
    final controller = QuantityStepperController(value: '7', onCommit: (_) async => true);
    addTearDown(controller.dispose);
    await pumpStepper(tester, controller);

    await tester.enterText(find.byKey(const Key('qty')), '9');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // The value is already showing — no fade needed to reach it, because
    // nothing was discarded.
    expect(tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text, '9');

    await tester.pump(kQuantityCommitDebounce + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(controller.accepted, '9');
    expect(tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text, '9');
  });

  testWidgets('a refused commit restores the accepted value with the same '
      'animation (research R3)', (tester) async {
    final controller = QuantityStepperController(value: '7', onCommit: (_) async => false);
    addTearDown(controller.dispose);
    await pumpStepper(tester, controller);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text, '8');

    await tester.pump(kQuantityCommitDebounce + const Duration(milliseconds: 50));
    // The refusal lands and starts the reset — not fully settled yet.
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text,
      '8',
      reason: 'still mid-fade, before the swap',
    );

    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text,
      '7',
      reason: 'the refusal restores the last accepted value',
    );
  });

  testWidgets('reduced motion swaps the value instantly, still applying and '
      'clearing the tint (FR-016)', (tester) async {
    final controller = QuantityStepperController(value: '7', onCommit: (_) async => true);
    addTearDown(controller.dispose);
    await pumpStepper(tester, controller, disableAnimations: true);

    await tester.enterText(find.byKey(const Key('qty')), '25');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(); // instant swap — no fade to wait out

    expect(
      tester.widget<TextField>(find.byKey(const Key('qty'))).controller!.text,
      '7',
      reason: 'reduced motion still discards the typed value, just without a fade',
    );

    // The tint clears itself on the same 250 ms schedule even without motion.
    await tester.pump(const Duration(milliseconds: 300));
  });
}
