import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/presentation/capture/fulfillment_mode_selector.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

/// The hand-rolled replacement for `SegmentedButton` (contracts/
/// capture-surface.md §2): it must still *behave* like one — one choice at a
/// time, the chosen segment filled and marked — while taking the height
/// `SegmentedButton` refused to.
void main() {
  late MockCustomerRepository customers;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    customers = MockCustomerRepository();
  });

  Future<void> pumpSelector(
    WidgetTester tester, {
    bool enabled = true,
    bool stretch = false,
    int customer = 7,
  }) => pumpPos(
    tester,
    FulfillmentModeSelector(
      sale: testSale(customer: customer),
      enabled: enabled,
      stretch: stretch,
    ),
    overrides: [customerRepositoryProvider.overrideWithValue(customers)],
  );

  group('the track', () {
    testWidgets('is exactly an extended FAB tall, in a stadium', (tester) async {
      await pumpSelector(tester);

      final track = find.byKey(const Key('pos_fulfillment_selector'));
      expect(
        tester.getSize(track).height,
        // The footer's own action is a `FloatingActionButton.extended`; the
        // two bracket the capture surface and must agree.
        fulfillmentModeSelectorHeight,
      );
      expect(
        tester.widget<Container>(track).decoration,
        isA<ShapeDecoration>().having(
          (d) => d.shape,
          'shape',
          isA<StadiumBorder>(),
        ),
      );
    });

    testWidgets('every segment fills the track — the fill runs edge to edge, '
        'which is what the old control could not do', (tester) async {
      await pumpSelector(tester);

      final heights = {
        for (final mode in FulfillmentMode.values)
          mode: tester
              .getSize(find.byKey(Key('pos_fulfillment_${mode.name}')))
              .height,
      };
      // All three agree...
      expect(heights.values.toSet(), hasLength(1), reason: '$heights');
      // ...and each fills the track's interior — the full height less the
      // 1 px stadium border top and bottom, which the segments sit inside.
      expect(heights.values.first, fulfillmentModeSelectorHeight - 2);
    });

    testWidgets('hugs its labels by default — the wide-tier layout measures '
        'it with an unbounded width', (tester) async {
      await pumpSelector(tester);

      final track = tester.getSize(
        find.byKey(const Key('pos_fulfillment_selector')),
      );
      // Narrower than the surface it was given, which is the whole point of
      // hugging: beside the customer band there is room for both.
      expect(track.width, lessThan(tester.view.physicalSize.width));

      // The three segments are their own widths, not equal shares.
      final widths = {
        for (final mode in FulfillmentMode.values)
          mode: tester
              .getSize(find.byKey(Key('pos_fulfillment_${mode.name}')))
              .width,
      };
      expect(widths.values.toSet().length, greaterThan(1), reason: '$widths');
    });

    testWidgets('stretched, it fills the width and divides it evenly — no '
        'dead space beside it when stacked', (tester) async {
      await pumpSelector(tester, stretch: true);

      final trackWidth = tester
          .getSize(find.byKey(const Key('pos_fulfillment_selector')))
          .width;
      final surface = tester
          .getSize(find.byType(FulfillmentModeSelector))
          .width;
      expect(trackWidth, surface);

      final widths = {
        for (final mode in FulfillmentMode.values)
          mode: tester
              .getSize(find.byKey(Key('pos_fulfillment_${mode.name}')))
              .width,
      };
      // Equal shares of the interior: the full width less the stadium's 1 px
      // border either side and the two 1 px dividers between the segments.
      expect(widths.values.toSet(), hasLength(1), reason: '$widths');
      expect(widths.values.reduce((a, b) => a + b), trackWidth - 2 - 2);
    });

    testWidgets('shows all three modes (FR-017)', (tester) async {
      await pumpSelector(tester);

      expect(find.text(l10n.posFulfillmentCounter), findsOneWidget);
      expect(find.text(l10n.posFulfillmentDelivery), findsOneWidget);
      expect(find.text(l10n.posFulfillmentMixed), findsOneWidget);
    });
  });

  group('it still behaves like a segmented button', () {
    testWidgets('the selected segment is the filled one, and the only one — '
        'marked with a check in place of its own icon', (tester) async {
      await pumpSelector(tester);
      final theme = Theme.of(
        tester.element(find.byKey(const Key('pos_fulfillment_selector'))),
      );

      // Counter pickup is the default (FR-017).
      final filled = tester
          .widgetList<Material>(
            find.descendant(
              of: find.byKey(const Key('pos_fulfillment_selector')),
              matching: find.byType(Material),
            ),
          )
          .where((m) => m.color == theme.colorScheme.secondaryContainer);
      expect(filled, hasLength(1));

      expect(find.byIcon(Icons.check), findsOneWidget);
      // The chosen segment trades its own icon for the check, exactly as
      // `SegmentedButton.showSelectedIcon` does.
      expect(find.byIcon(Icons.store_outlined), findsNothing);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
      expect(find.byIcon(Icons.call_split), findsOneWidget);
    });

    testWidgets('choosing a delivery mode moves the selection', (tester) async {
      final container = await pumpPos(
        tester,
        FulfillmentModeSelector(sale: testSale()),
        overrides: [customerRepositoryProvider.overrideWithValue(customers)],
      );

      // Counter pickup needs no address and no permission check, so going
      // back to it is the move that settles synchronously.
      container
          .read(posStepControllerProvider.notifier)
          .setMode(FulfillmentMode.delivery);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.local_shipping_outlined), findsNothing);

      await tester.tap(
        find.byKey(const Key('pos_fulfillment_counterPickup')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.store_outlined), findsNothing);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets(
      // spec 036 FR-015: only the generic "Público en General" customer is
      // refused — checked against `posDefaultCustomerId` (1 in tests, no
      // `--dart-define` set), not a per-customer flag.
      'the generic customer is told why, and the mode does not move '
      '(FR-015)',
      (tester) async {
        await pumpSelector(tester, customer: 1);
        await tester.tap(find.byKey(const Key('pos_fulfillment_delivery')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('pos_delivery_refusal')), findsOneWidget);
        // Still on counter pickup: its icon is still the check.
        expect(find.byIcon(Icons.store_outlined), findsNothing);
      },
    );

    testWidgets(
      // spec 036 FR-015: every other customer — including one that would
      // previously have been refused via a `shipping: false` flag — is never
      // shown the refusal message. (The mode actually moving once the write
      // succeeds is already covered by the "asks for no address" test below,
      // which mocks the repository the real update goes through; this test
      // isolates just the gate itself.)
      'an ordinary customer is never shown the refusal message',
      (tester) async {
        await pumpSelector(tester, customer: 42);
        await tester.tap(find.byKey(const Key('pos_fulfillment_delivery')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('pos_delivery_refusal')), findsNothing);
      },
    );

    testWidgets('a read-only sale refuses every segment (FR-041)', (
      tester,
    ) async {
      await pumpSelector(tester, enabled: false);

      for (final mode in FulfillmentMode.values) {
        final inkWell = tester.widget<InkWell>(
          find.byKey(Key('pos_fulfillment_${mode.name}')),
        );
        expect(inkWell.onTap, isNull, reason: mode.name);
      }
    });
  });

  group('choosing delivery or mixed (FR-056, amended 2026-08-23)', () {
    testWidgets('asks for no address — writes fulfillmentIntent alone and '
        'moves the selection directly', (tester) async {
      final salesOrder = MockSalesOrderRepository();
      when(() => salesOrder.open()).thenAnswer((_) async => testSale());
      when(
        () => salesOrder.updateHeader(
          saleId: any(named: 'saleId'),
          customer: any(named: 'customer'),
          paymentTerms: any(named: 'paymentTerms'),
          currency: any(named: 'currency'),
          shipTo: any(named: 'shipTo'),
          contact: any(named: 'contact'),
          customerName: any(named: 'customerName'),
          fulfillmentIntent: any(named: 'fulfillmentIntent'),
        ),
      ).thenAnswer((_) async => testSale());

      final container = await pumpPos(
        tester,
        Consumer(
          builder: (context, ref, _) {
            ref.watch(posSaleControllerProvider);
            return FulfillmentModeSelector(sale: testSale());
          },
        ),
        overrides: [
          customerRepositoryProvider.overrideWithValue(customers),
          salesOrderOverride(salesOrder),
        ],
      );
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pos_fulfillment_delivery')));
      await tester.pumpAndSettle();

      // No dialog — the customer's addresses are never even read for this.
      expect(find.byType(AlertDialog), findsNothing);
      verify(
        () => salesOrder.updateHeader(
          saleId: any(named: 'saleId'),
          customer: null,
          paymentTerms: null,
          currency: null,
          shipTo: null,
          contact: null,
          customerName: null,
          fulfillmentIntent: FulfillmentMode.delivery,
        ),
      ).called(1);
      // Delivery is now the selected segment, so it shows the check in place
      // of its own icon (`_ModeSegmentButton`'s `showSelectedIcon` swap) —
      // counter pickup, no longer selected, shows its own icon again.
      expect(find.byIcon(Icons.store_outlined), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_outlined), findsNothing);
    });
  });
}
