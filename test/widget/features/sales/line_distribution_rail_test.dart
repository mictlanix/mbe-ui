import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/line_distribution_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

/// `LineDistributionPanel`'s own contract (spec 026
/// contracts/delivery-surface.md §5.1–§5.2): a header stating how much is
/// being shown, and one row per sale line whose chips carry the same badge
/// letters a `DestinationCard` shows in its own header (research R8), with
/// an outstanding line marked by more than colour alone (FR-034).
void main() {
  final sale = testSale(
    lines: [
      testLine(id: 5, productName: 'Varilla', quantity: '10'),
      testLine(id: 6, productName: 'Cemento', quantity: '20'),
    ],
  );

  const d1 = Destination(
    id: 500,
    fulfillmentType: FulfillmentType.delivery,
    addressSummary: 'Destino uno',
    status: DeliveryOrderStatus.draft,
    lines: [
      DestinationLine(
        id: 900,
        salesOrderDetail: 5,
        product: 11,
        productCode: 'P-11',
        productName: 'Varilla',
        quantity: '6',
      ),
    ],
  );

  const d2 = Destination(
    id: 501,
    fulfillmentType: FulfillmentType.delivery,
    addressSummary: 'Destino dos',
    status: DeliveryOrderStatus.draft,
    lines: [
      DestinationLine(
        id: 901,
        salesOrderDetail: 6,
        product: 12,
        productCode: 'P-12',
        productName: 'Cemento',
        quantity: '20',
      ),
    ],
  );

  final badges = {d1.id: 'D1', d2.id: 'D2'};

  Future<void> pumpPanel(
    WidgetTester tester,
    List<Destination> destinations, {
    bool isMixed = false,
    Destination? counterDestination,
  }) async {
    final distribution = distributionFor(sale: sale, destinations: destinations);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LineDistributionPanel(
            distribution: distribution,
            badges: badges,
            destinationGroupCount: destinations.length,
            isMixed: isMixed,
            counterDestination: counterDestination,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the header (FR-035)', () {
    testWidgets('states how many lines and destinations are shown',
        (tester) async {
      await pumpPanel(tester, [d1, d2]);
      expect(find.text('2 líneas · 2 destinos'), findsOneWidget);
    });
  });

  group('the rows agree with the cards\' badges (research R8, FR-032)', () {
    testWidgets('each row carries a chip per destination holding some of it',
        (tester) async {
      await pumpPanel(tester, [d1, d2]);

      final varilla = find.byKey(const Key('distribution_row_5'));
      expect(varilla, findsOneWidget);
      expect(
        find.descendant(of: varilla, matching: find.text('D1 6')),
        findsOneWidget,
      );

      final cemento = find.byKey(const Key('distribution_row_6'));
      expect(
        find.descendant(of: cemento, matching: find.text('D2 20')),
        findsOneWidget,
      );
    });

    testWidgets('a line nobody has claimed yet shows no destination chip',
        (tester) async {
      await pumpPanel(tester, [d1]);
      final cemento = find.byKey(const Key('distribution_row_6'));
      expect(find.descendant(of: cemento, matching: find.textContaining('D')), findsNothing);
    });
  });

  group('an outstanding line is marked by more than colour (FR-034)', () {
    testWidgets('a pure-delivery sale with a remainder shows a warning icon '
        'inside that row', (tester) async {
      await pumpPanel(tester, [d1]); // Cemento (line 6) is entirely unclaimed.

      final cemento = find.byKey(const Key('distribution_row_6'));
      expect(
        find.descendant(of: cemento, matching: find.byIcon(Icons.warning_amber_outlined)),
        findsOneWidget,
      );
    });

    testWidgets('a mixed sale with the same remainder shows no warning icon '
        '— it is the counter\'s legitimate share', (tester) async {
      await pumpPanel(tester, [d1], isMixed: true);

      final cemento = find.byKey(const Key('distribution_row_6'));
      expect(
        find.descendant(of: cemento, matching: find.byIcon(Icons.warning_amber_outlined)),
        findsNothing,
      );
      expect(
        find.descendant(of: cemento, matching: find.text('Tienda 20')),
        findsOneWidget,
      );
    });
  });

  group('the pinned foot (contract §5.3, FR-036–FR-038)', () {
    Future<void> pumpFoot(
      WidgetTester tester, {
      String assigned = '6',
      String total = '26',
      String? outstandingMessage,
      VoidCallback? onClose,
      bool closing = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LineDistributionFoot(
              assigned: assigned,
              total: total,
              outstandingMessage: outstandingMessage,
              onClose: onClose,
              closing: closing,
            ),
          ),
        ),
      );
      // `pumpAndSettle` never returns while the spinner's animation runs —
      // one `pump` is enough to lay everything out.
      await tester.pump();
    }

    testWidgets('states the assigned-units total against the sale total',
        (tester) async {
      await pumpFoot(tester, assigned: '6', total: '26');
      expect(find.text('6 / 26 unidades asignadas'), findsOneWidget);
    });

    testWidgets('a disabled finish action shows the outstanding notice above '
        'it', (tester) async {
      await pumpFoot(
        tester,
        outstandingMessage: 'Falta asignar: Cemento (20)',
        onClose: null,
      );
      expect(find.byKey(const Key('delivery_outstanding_notice')), findsOneWidget);
      expect(find.text('Falta asignar: Cemento (20)'), findsOneWidget);

      final button = tester.widget<FilledButton>(
        find.byKey(const Key('delivery_close_button')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('an enabled finish action shows no outstanding notice',
        (tester) async {
      await pumpFoot(tester, onClose: () {});
      expect(find.byKey(const Key('delivery_outstanding_notice')), findsNothing);

      final button = tester.widget<FilledButton>(
        find.byKey(const Key('delivery_close_button')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows a spinner while closing', (tester) async {
      await pumpFoot(tester, onClose: () {}, closing: true);
      expect(
        find.descendant(
          of: find.byKey(const Key('delivery_close_button')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });
  });
}
