import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/new_itinerary_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'delivery_itinerary_harness.dart';

/// Spec 075 FR-005, research R15, US1 scenario 4: "Nuevo itinerario".
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<Future<int?> Function()> launch(
    WidgetTester tester,
    FakeItineraryActions actions,
  ) async {
    final results = <int?>[];
    var pending = Future<int?>.value();
    Future<void> open(BuildContext context) async {
      pending = showNewItineraryDialog(context);
      results.add(await pending);
    }

    // Returned lazily so a test reads the dialog's answer after it closed.
    await pumpDialogHost(
      tester,
      open: open,
      actions: actions,
      access: itineraryAccess(rights: itineraryWriter),
    );
    return () => pending;
  }

  testWidgets('everything is optional: it creates with nothing filled, and '
      'opens the new trip', (tester) async {
    final actions = FakeItineraryActions(newId: 59);
    final result = await launch(tester, actions);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('new_itinerary_dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('new_itinerary_submit')));
    await tester.pumpAndSettle();

    expect(actions.calls.single, startsWith('create'));
    expect(actions.calls.single, contains('vehicle=null'));
    expect(actions.calls.single, contains('operator=null'));
    expect(actions.calls.single, contains('warehouse=null'));
    expect(await result(), 59);
    expect(find.byKey(const Key('new_itinerary_dialog')), findsNothing);
  });

  testWidgets('says that a blank warehouse uses the point of sale\'s', (
    tester,
  ) async {
    await launch(tester, FakeItineraryActions());
    await tester.pumpAndSettle();

    expect(find.text(l10n.itineraryWarehouseHint), findsOneWidget);
    expect(find.text(l10n.itineraryFieldWarehouse), findsWidgets);
  });

  testWidgets('a refused vehicle keeps the dialog open and names the trip '
      'that holds it', (tester) async {
    final actions = FakeItineraryActions(
      error: const AppError.server(
        statusCode: 409,
        problem: ApiProblem(
          codeName: 'vehicle.open_itinerary_exists',
          code: api.ErrorCode.vehiclePeriodOpenItineraryExists,
          params: {'vehicle_id': 4, 'itinerary_id': 54},
        ),
      ),
    );
    await launch(tester, actions);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('new_itinerary_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('new_itinerary_dialog')), findsOneWidget);
    expect(
      find.text(l10n.apiErrorVehicleOpenItineraryExists('54')),
      findsOneWidget,
    );
  });

  testWidgets('a picker the user can\'t read is left out', (tester) async {
    final results = <int?>[];
    await pumpDialogHost(
      tester,
      open: (context) async =>
          results.add(await showNewItineraryDialog(context)),
      actions: FakeItineraryActions(),
      access: itineraryAccess(
        rights: itineraryWriter,
        vehiclesRead: false,
        operatorsRead: false,
        warehousesRead: false,
      ),
    );

    expect(find.byKey(const Key('new_itinerary_vehicle')), findsNothing);
    expect(find.byKey(const Key('new_itinerary_operator')), findsNothing);
    expect(find.byKey(const Key('new_itinerary_warehouse')), findsNothing);
    expect(find.byKey(const Key('new_itinerary_date')), findsOneWidget);
  });

  testWidgets('Cancelar closes it without creating', (tester) async {
    final actions = FakeItineraryActions();
    final result = await launch(tester, actions);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.cancelButton));
    await tester.pumpAndSettle();

    expect(actions.calls, isEmpty);
    expect(await result(), isNull);
  });
}
