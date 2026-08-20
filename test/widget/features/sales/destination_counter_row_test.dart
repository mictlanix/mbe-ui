import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_counter_row.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

/// `DestinationCounterRow`'s own contract (spec 030 US4,
/// contracts/delivery-surface.md §3): expandable like `DestinationCard`, its
/// header and its expanded body reading from one computed figure so the two
/// can never disagree (FR-027/FR-028), and never offering an edit, remove,
/// stepper or claim-all control (FR-023, FR-029) — it is not a destination
/// the cashier composed.
void main() {
  final sale = testSale(
    lines: [
      testLine(id: 5, productName: 'Varilla', quantity: '10'),
      testLine(id: 6, productName: 'Cemento', quantity: '20'),
    ],
  );

  Destination counterDestination({required List<DestinationLine> lines}) => Destination(
    id: 600,
    fulfillmentType: FulfillmentType.counterPickup,
    status: DeliveryOrderStatus.draft,
    lines: lines,
  );

  Future<void> pumpRow(
    WidgetTester tester, {
    Destination? counterDestination,
    required List<Destination> destinations,
  }) async {
    final distribution = distributionFor(sale: sale, destinations: destinations);
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DestinationCounterRow(
              counterDestination: counterDestination,
              distribution: distribution,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> expand(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('destination_counter_row')));
    await tester.pumpAndSettle();
  }

  group('expansion (FR-025)', () {
    testWidgets('starts collapsed', (tester) async {
      await pumpRow(tester, destinations: const []);
      expect(find.byKey(const Key('counter_line_5')), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('tapping the header expands it, listing every sale line, '
        'zeros included (FR-026)', (tester) async {
      await pumpRow(tester, destinations: const []);
      await expand(tester);

      expect(find.byKey(const Key('counter_line_5')), findsOneWidget);
      expect(find.byKey(const Key('counter_line_6')), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });
  });

  group('the two sources (research R11)', () {
    testWidgets('the preview-only source: nothing assigned anywhere, so the '
        'whole order sits at the counter', (tester) async {
      await pumpRow(tester, destinations: const []);
      await expand(tester);

      expect(find.text('10'), findsOneWidget); // line 5, unclaimed
      expect(find.text('20'), findsOneWidget); // line 6, unclaimed
    });

    testWidgets('the recorded-destination-only source: the counter\'s own '
        'lines, nothing left over', (tester) async {
      final destination = counterDestination(
        lines: const [
          DestinationLine(
            id: 900,
            salesOrderDetail: 5,
            product: 11,
            productCode: 'P-11',
            productName: 'Varilla',
            quantity: '10',
          ),
        ],
      );
      // Everything else is claimed by a delivery destination — nothing left
      // unassigned.
      final delivery = Destination(
        id: 500,
        fulfillmentType: FulfillmentType.delivery,
        shipTo: 11,
        status: DeliveryOrderStatus.draft,
        lines: const [
          DestinationLine(
            id: 901,
            salesOrderDetail: 6,
            product: 11,
            productCode: 'P-11',
            productName: 'Cemento',
            quantity: '20',
          ),
        ],
      );

      await pumpRow(
        tester,
        counterDestination: destination,
        destinations: [destination, delivery],
      );
      await expand(tester);

      expect(find.byKey(const Key('counter_line_5')), findsOneWidget);
      expect(find.byKey(const Key('counter_line_6')), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('both sources contributing to the same line sum together '
        '(the resumed-mixed-sale case today under-reports)', (tester) async {
      // The recorded counter destination already holds 4 of line 5's 10
      // units; the remaining 6 are still unassigned to anything.
      final destination = counterDestination(
        lines: const [
          DestinationLine(
            id: 900,
            salesOrderDetail: 5,
            product: 11,
            productCode: 'P-11',
            productName: 'Varilla',
            quantity: '4',
          ),
        ],
      );

      await pumpRow(tester, counterDestination: destination, destinations: [destination]);
      await expand(tester);

      // 4 (recorded) + 6 (still unassigned) = 10 — the whole line.
      expect(find.byKey(const Key('counter_line_5')), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });
  });

  testWidgets('the header counts equal the sum of the expanded body '
      '(FR-027/FR-028)', (tester) async {
    final destination = counterDestination(
      lines: const [
        DestinationLine(
          id: 900,
          salesOrderDetail: 5,
          product: 11,
          productCode: 'P-11',
          productName: 'Varilla',
          quantity: '3',
        ),
      ],
    );
    await pumpRow(tester, counterDestination: destination, destinations: [destination]);

    // Header, collapsed: line 5 has 3 (recorded) + 7 (unassigned) = 10;
    // line 6 has 0 (recorded) + 20 (unassigned) = 20. Two non-zero lines,
    // 30 units total.
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    expect(find.text(l10n.posDestinationCounts(2, '30')), findsOneWidget);

    await expand(tester);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('never offers a stepper, claim-all, edit or remove control', (
    tester,
  ) async {
    await pumpRow(tester, destinations: const []);
    await expand(tester);

    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.byIcon(Icons.remove), findsNothing);
    expect(find.byIcon(Icons.keyboard_double_arrow_left), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
