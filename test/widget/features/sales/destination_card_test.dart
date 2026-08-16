import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_card.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_counter_row.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

/// `DestinationCard`'s own contract (spec 026 contracts/delivery-surface.md
/// §4): a collapsible, independently-expanding card whose header packs a
/// badge, an identity block and counts on one line, with a remove action the
/// counter row (§3) never carries.
void main() {
  final sale = testSale(
    lines: [
      testLine(id: 5, productName: 'Varilla', quantity: '10'),
      testLine(id: 6, productName: 'Cemento', quantity: '20'),
    ],
  );

  Destination destination({
    int id = 500,
    String? addressSummary = 'Calle Morelos 118',
    String? contactName = 'Ana Ruiz',
    String? contactPhone = '55 1234 5678',
    DateTime? date,
    List<DestinationLine> lines = const [],
  }) => Destination(
    id: id,
    fulfillmentType: FulfillmentType.delivery,
    addressSummary: addressSummary,
    contactName: contactName,
    contactPhone: contactPhone,
    date: date ?? DateTime(2026, 8, 6),
    status: DeliveryOrderStatus.draft,
    lines: lines,
  );

  List<LineDistribution> buildDistribution(List<Destination> destinations) =>
      distributionFor(sale: sale, destinations: destinations);

  Future<void> pumpCard(
    WidgetTester tester,
    Destination d, {
    String badge = 'D1',
    VoidCallback? onRemove,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DestinationCard(
            destination: d,
            badge: badge,
            distribution: buildDistribution([d]),
            onRemove: onRemove,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the collapsed header (FR-013)', () {
    testWidgets('shows the badge, the address, the recipient/phone/date and '
        'the counts on one line', (tester) async {
      final d = destination(
        lines: [
          const DestinationLine(
            id: 900,
            salesOrderDetail: 5,
            product: 11,
            productCode: 'P-11',
            productName: 'Varilla',
            quantity: '6',
          ),
        ],
      );
      await pumpCard(tester, d);

      expect(find.text('D1'), findsOneWidget);
      expect(find.text('Calle Morelos 118'), findsOneWidget);
      expect(find.textContaining('Ana Ruiz'), findsOneWidget);
      expect(find.textContaining('55 1234 5678'), findsOneWidget);
      expect(find.text('1 líneas · 6 uds.'), findsOneWidget);
    });

    testWidgets('falls back to the pending-address wording when the join '
        'has no address', (tester) async {
      await pumpCard(tester, destination(addressSummary: null));
      expect(find.text('Dirección pendiente'), findsOneWidget);
    });
  });

  group('expansion is independent per card (research R5, FR-014)', () {
    testWidgets('tapping the header expands it to list every sale line',
        (tester) async {
      await pumpCard(tester, destination());

      expect(find.text('Varilla'), findsNothing);
      await tester.tap(find.byKey(const Key('destination_card_500')));
      await tester.pumpAndSettle();

      expect(find.text('Varilla'), findsOneWidget);
      expect(find.text('Cemento'), findsOneWidget);
    });

    testWidgets('expanding one card does not change the other, and the list '
        'does not reorder', (tester) async {
      final d1 = destination(id: 500, addressSummary: 'Destino uno');
      final d2 = destination(id: 501, addressSummary: 'Destino dos');
      final distribution = buildDistribution([d1, d2]);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Column(
              children: [
                DestinationCard(destination: d1, badge: 'D1', distribution: distribution),
                DestinationCard(destination: d2, badge: 'D2', distribution: distribution),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('destination_card_500')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('destination_card_500')),
          matching: find.text('Varilla'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('destination_card_501')),
          matching: find.text('Varilla'),
        ),
        findsNothing,
      );
      // Both cards still render in their original order.
      final order = tester.getTopLeft(find.byKey(const Key('destination_card_500')));
      final secondOrder = tester.getTopLeft(find.byKey(const Key('destination_card_501')));
      expect(order.dy, lessThan(secondOrder.dy));
    });
  });

  group('the remove action (FR-011, FR-015)', () {
    testWidgets('is present on an addressed card', (tester) async {
      await pumpCard(tester, destination(), onRemove: () {});
      expect(find.byKey(const Key('destination_remove_500')), findsOneWidget);
    });

    testWidgets('is absent from the counter row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DestinationCounterRow(distribution: buildDistribution(const [])),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });
}
