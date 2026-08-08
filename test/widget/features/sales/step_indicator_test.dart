import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

/// The step indicator is `PosScreen`'s private header band, so this asserts
/// on the property that drives it — `PosStepState.stepCount` — plus the
/// labels it renders, through a stand-in that reads the same provider the
/// real band does. That keeps FR-005's "two steps for a counter-pickup sale"
/// covered without exporting a private widget purely to test it.
class _StepIndicator extends ConsumerWidget {
  const _StepIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final step = ref.watch(posStepControllerProvider);
    final labels = [
      l10n.posStepVenta,
      l10n.posStepCobro,
      l10n.posStepEntrega,
    ].take(step.stepCount).toList();
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) Text('${i + 1}·${labels[i]}'),
      ],
    );
  }
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  testWidgets('a counter-pickup sale shows exactly two steps (FR-005)', (
    tester,
  ) async {
    final container = await pumpPos(tester, const _StepIndicator());
    container.read(posStepControllerProvider.notifier)
        .setMode(FulfillmentMode.counterPickup);
    await tester.pumpAndSettle();

    expect(find.text('1·${l10n.posStepVenta}'), findsOneWidget);
    expect(find.text('2·${l10n.posStepCobro}'), findsOneWidget);
    expect(find.text('3·${l10n.posStepEntrega}'), findsNothing);
  });

  testWidgets('the default mode is counter pickup, so a fresh sale opens with '
      'two steps and no delivery step', (tester) async {
    await pumpPos(tester, const _StepIndicator());

    expect(find.text('3·${l10n.posStepEntrega}'), findsNothing);
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('a delivery sale gains the third step (FR-018)', (tester) async {
    final container = await pumpPos(tester, const _StepIndicator());
    container.read(posStepControllerProvider.notifier)
        .setMode(FulfillmentMode.delivery);
    await tester.pumpAndSettle();

    expect(find.text('3·${l10n.posStepEntrega}'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(3));
  });

  testWidgets('a mixed sale gains the third step too', (tester) async {
    final container = await pumpPos(tester, const _StepIndicator());
    container.read(posStepControllerProvider.notifier)
        .setMode(FulfillmentMode.mixed);
    await tester.pumpAndSettle();

    expect(find.text('3·${l10n.posStepEntrega}'), findsOneWidget);
  });

  testWidgets('switching back to counter pickup removes the delivery step '
      'again (FR-018)', (tester) async {
    final container = await pumpPos(tester, const _StepIndicator());
    final notifier = container.read(posStepControllerProvider.notifier);

    notifier.setMode(FulfillmentMode.delivery);
    await tester.pumpAndSettle();
    expect(find.text('3·${l10n.posStepEntrega}'), findsOneWidget);

    notifier.setMode(FulfillmentMode.counterPickup);
    await tester.pumpAndSettle();
    expect(find.text('3·${l10n.posStepEntrega}'), findsNothing);
  });
}
