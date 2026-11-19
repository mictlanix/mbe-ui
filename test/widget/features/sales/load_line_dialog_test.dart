import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/load_line_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/sales/delivery_itinerary_fixtures.dart';
import 'delivery_itinerary_harness.dart';

/// Spec 075 FR-010, FR-011: "Cargar línea" and the quantity prompt (✎).
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  final order = fakeDeliveryOrder(
    id: 1540,
    lines: [
      fakeOrderLine(id: 910, code: 'CEM-50', name: 'Cemento gris', open: '4'),
      fakeOrderLine(id: 911, code: 'ARE-01', name: 'Arena m³', open: '2'),
      // Nothing left to load: not offered.
      fakeOrderLine(id: 912, code: 'VAR-38', name: 'Varilla', open: '0'),
    ],
  );

  Future<List<ItineraryActionResult?>> openLoadLine(
    WidgetTester tester,
    FakeItineraryActions actions,
  ) async {
    final results = <ItineraryActionResult?>[];
    await pumpDialogHost(
      tester,
      open: (context) async => results.add(
        await showLoadLineDialog(
          context,
          itineraryId: 58,
          stopId: 501,
          deliveryOrderId: 1540,
        ),
      ),
      actions: actions,
      access: itineraryAccess(rights: itineraryWriter),
      orders: {1540: order},
    );
    return results;
  }

  FilledButton submit(WidgetTester tester, String key) =>
      tester.widget<FilledButton>(find.byKey(Key(key)));

  testWidgets('lines with nothing open are not offered', (tester) async {
    await openLoadLine(tester, FakeItineraryActions());

    expect(find.byKey(const Key('itinerary_load_line_910')), findsOneWidget);
    expect(find.byKey(const Key('itinerary_load_line_911')), findsOneWidget);
    expect(find.byKey(const Key('itinerary_load_line_912')), findsNothing);
  });

  testWidgets('choosing a line defaults the quantity to what is open', (
    tester,
  ) async {
    await openLoadLine(tester, FakeItineraryActions());
    expect(
      submit(tester, 'itinerary_load_line_submit').onPressed,
      isNull,
      reason: 'nothing chosen yet',
    );

    await tester.tap(find.byKey(const Key('itinerary_load_line_910')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('itinerary_load_line_quantity')),
          )
          .controller!
          .text,
      '4',
    );
    expect(submit(tester, 'itinerary_load_line_submit').onPressed, isNotNull);
  });

  testWidgets('a quantity above what is open is refused in the field', (
    tester,
  ) async {
    await openLoadLine(tester, FakeItineraryActions());
    await tester.tap(find.byKey(const Key('itinerary_load_line_910')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('itinerary_load_line_quantity')),
      '4.5',
    );
    await tester.pump();

    expect(find.text(l10n.itineraryQuantityInvalid), findsOneWidget);
    expect(submit(tester, 'itinerary_load_line_submit').onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('itinerary_load_line_quantity')),
      '0',
    );
    await tester.pump();
    expect(submit(tester, 'itinerary_load_line_submit').onPressed, isNull);
  });

  testWidgets('confirming loads the chosen quantity of that line', (
    tester,
  ) async {
    final actions = FakeItineraryActions();
    final results = await openLoadLine(tester, actions);
    await tester.tap(find.byKey(const Key('itinerary_load_line_910')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('itinerary_load_line_quantity')),
      '2',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('itinerary_load_line_submit')));
    await tester.pumpAndSettle();

    expect(actions.calls.single, 'commitLine 501 910 2');
    expect(results.single?.error, isNull);
  });

  testWidgets('an order with nothing to load says so', (tester) async {
    final results = <ItineraryActionResult?>[];
    await pumpDialogHost(
      tester,
      open: (context) async => results.add(
        await showLoadLineDialog(
          context,
          itineraryId: 58,
          stopId: 501,
          deliveryOrderId: 1540,
        ),
      ),
      actions: FakeItineraryActions(),
      access: itineraryAccess(rights: itineraryWriter),
      orders: {
        1540: fakeDeliveryOrder(
          id: 1540,
          lines: [fakeOrderLine(id: 910, open: '0')],
        ),
      },
    );

    expect(find.byKey(const Key('itinerary_load_line_empty')), findsOneWidget);
  });

  group('the quantity prompt', () {
    final line = fakeItineraryLine(id: 7001, committed: '6');

    Future<List<ItineraryActionResult?>> openAdjust(
      WidgetTester tester,
      FakeItineraryActions actions, {
      Decimal? pending,
    }) async {
      final results = <ItineraryActionResult?>[];
      await pumpDialogHost(
        tester,
        open: (context) async => results.add(
          await showAdjustQuantityDialog(
            context,
            itineraryId: 58,
            stopId: 501,
            line: line,
            pending: pending,
          ),
        ),
        actions: actions,
        access: itineraryAccess(rights: itineraryWriter),
      );
      return results;
    }

    testWidgets('starts at what is loaded, and the maximum is open plus '
        'loaded', (tester) async {
      await openAdjust(
        tester,
        FakeItineraryActions(),
        pending: Decimal.parse('4'),
      );

      final field = tester.widget<TextField>(
        find.byKey(const Key('itinerary_adjust_quantity')),
      );
      expect(field.controller!.text, '6');
      expect(
        find.text(l10n.itineraryQuantityMaxBreakdown('10', '4', '6')),
        findsOneWidget,
      );
    });

    testWidgets('above the maximum is refused, up to it is saved', (
      tester,
    ) async {
      final actions = FakeItineraryActions();
      await openAdjust(tester, actions, pending: Decimal.parse('4'));

      await tester.enterText(
        find.byKey(const Key('itinerary_adjust_quantity')),
        '10.5',
      );
      await tester.pump();
      expect(find.text(l10n.itineraryQuantityInvalid), findsOneWidget);
      expect(submit(tester, 'itinerary_adjust_submit').onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('itinerary_adjust_quantity')),
        '10',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('itinerary_adjust_submit')));
      await tester.pumpAndSettle();

      expect(actions.calls.single, 'adjust 501 7001 10');
    });

    testWidgets('with the order unreadable there is no upper bound here, '
        'only above zero', (tester) async {
      final actions = FakeItineraryActions();
      await openAdjust(tester, actions);

      await tester.enterText(
        find.byKey(const Key('itinerary_adjust_quantity')),
        '99',
      );
      await tester.pump();
      expect(submit(tester, 'itinerary_adjust_submit').onPressed, isNotNull);

      await tester.enterText(
        find.byKey(const Key('itinerary_adjust_quantity')),
        '0',
      );
      await tester.pump();
      expect(submit(tester, 'itinerary_adjust_submit').onPressed, isNull);
    });
  });

  group('the release and remove prompts', () {
    testWidgets('releasing a line confirms, then calls release', (
      tester,
    ) async {
      final actions = FakeItineraryActions();
      await pumpDialogHost(
        tester,
        open: (context) async => showReleaseLineDialog(
          context,
          itineraryId: 58,
          stopId: 501,
          line: fakeItineraryLine(id: 7001),
        ),
        actions: actions,
        access: itineraryAccess(rights: itineraryWriter),
      );

      expect(find.text(l10n.itineraryReleaseTitle('CLA-25')), findsOneWidget);
      await tester.tap(find.byKey(const Key('itinerary_confirm_submit')));
      await tester.pumpAndSettle();

      expect(actions.calls.single, 'release 501 7001');
    });

    testWidgets('removing a stop names what is released, then calls '
        'removeStop', (tester) async {
      final actions = FakeItineraryActions();
      await pumpDialogHost(
        tester,
        open: (context) async => showRemoveStopDialog(
          context,
          itineraryId: 58,
          stop: fakeItineraryStop(id: 502, sequence: 3),
        ),
        actions: actions,
        access: itineraryAccess(rights: itineraryWriter),
      );

      expect(find.text(l10n.itineraryRemoveStopTitle(3)), findsOneWidget);
      expect(find.text(l10n.itineraryRemoveStopBody), findsOneWidget);
      await tester.tap(find.byKey(const Key('itinerary_confirm_submit')));
      await tester.pumpAndSettle();

      expect(actions.calls.single, 'removeStop 502');
    });

    testWidgets('backing out calls nothing', (tester) async {
      final actions = FakeItineraryActions();
      await pumpDialogHost(
        tester,
        open: (context) async => showReleaseLineDialog(
          context,
          itineraryId: 58,
          stopId: 501,
          line: fakeItineraryLine(),
        ),
        actions: actions,
        access: itineraryAccess(rights: itineraryWriter),
      );

      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      expect(actions.calls, isEmpty);
    });
  });
}
