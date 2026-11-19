import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_header_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/sales/delivery_itinerary_fixtures.dart';
import 'delivery_itinerary_harness.dart';

class _MockVehicles extends Mock implements VehicleRepository {}

const _hino = Vehicle(
  vehicleId: 7,
  licensePlate: 'XYZ-9',
  name: 'Hino 300',
  nickname: 'Hino',
  tonsCapacity: 3,
  status: EntityStatus.active,
);

/// Spec 075 FR-006, research R16 (mbe-api#345): "Editar encabezado".
void main() {
  late AppLocalizations l10n;
  late MockDeliveryItineraryRepository repository;
  late _MockVehicles vehicles;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(ItineraryStatus.open);
  });

  setUp(() {
    repository = MockDeliveryItineraryRepository();
    vehicles = _MockVehicles();
    when(
      () => vehicles.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const VehicleListResult(items: [_hino], total: 1),
    );
  });

  void holdsVehicle(int tripId) =>
      when(
        () => repository.list(
          status: ItineraryStatus.open,
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          vehicleId: 7,
          operatorId: any(named: 'operatorId'),
          warehouseId: any(named: 'warehouseId'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => ItineraryPage(
          items: [fakeItinerarySummary(id: tripId, vehicleId: 7)],
          total: 1,
        ),
      );

  Future<List<ItineraryActionResult?>> open(
    WidgetTester tester,
    FakeItineraryActions actions, {
    Itinerary? trip,
  }) async {
    final results = <ItineraryActionResult?>[];
    await pumpDialogHost(
      tester,
      open: (context) async => results.add(
        await showItineraryHeaderDialog(context, trip: trip ?? fakeItinerary()),
      ),
      repository: repository,
      actions: actions,
      access: itineraryAccess(rights: itineraryWriter),
      overrides: [vehicleRepositoryProvider.overrideWithValue(vehicles)],
    );
    return results;
  }

  Future<void> pickVehicle(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('itinerary_header_vehicle')),
        matching: find.byType(TextField),
      ),
      'Hino',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hino · XYZ-9'));
    await tester.pumpAndSettle();
  }

  testWidgets('the dispatch warehouse is not editable', (tester) async {
    await open(tester, FakeItineraryActions());

    expect(find.byKey(const Key('itinerary_header_dialog')), findsOneWidget);
    expect(find.text(l10n.itineraryFieldWarehouse), findsNothing);
    expect(find.byKey(const Key('itinerary_header_vehicle')), findsOneWidget);
    expect(find.byKey(const Key('itinerary_header_operator')), findsOneWidget);
    expect(find.byKey(const Key('itinerary_header_comment')), findsOneWidget);
  });

  testWidgets('Guardar needs a change, and sends only what changed', (
    tester,
  ) async {
    final actions = FakeItineraryActions();
    await open(tester, actions);

    FilledButton submit() => tester.widget<FilledButton>(
      find.byKey(const Key('itinerary_header_submit')),
    );
    expect(submit().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('itinerary_header_comment')),
      'Salida temprana',
    );
    await tester.pump();
    expect(submit().onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('itinerary_header_submit')));
    await tester.pumpAndSettle();

    expect(actions.calls.single, contains('comment=Salida temprana'));
    expect(actions.calls.single, contains('vehicle=null'));
    expect(actions.calls.single, contains('operator=null'));
  });

  testWidgets('a vehicle held by another open trip keeps the dialog open and '
      'does not call updateHeader', (tester) async {
    holdsVehicle(54);
    final actions = FakeItineraryActions();
    await open(tester, actions);

    await pickVehicle(tester);
    await tester.tap(find.byKey(const Key('itinerary_header_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('itinerary_header_dialog')), findsOneWidget);
    expect(
      find.text(l10n.apiErrorVehicleOpenItineraryExists('54')),
      findsOneWidget,
    );
    expect(actions.calls, isEmpty);
  });

  testWidgets('the same trip holding the vehicle does not block', (
    tester,
  ) async {
    holdsVehicle(58);
    final actions = FakeItineraryActions();
    await open(tester, actions);

    await pickVehicle(tester);
    await tester.tap(find.byKey(const Key('itinerary_header_submit')));
    await tester.pumpAndSettle();

    expect(actions.calls.single, contains('vehicle=7'));
    expect(find.byKey(const Key('itinerary_header_dialog')), findsNothing);
  });

  testWidgets('a failed check does not block the save', (tester) async {
    when(
      () => repository.list(
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        vehicleId: any(named: 'vehicleId'),
        operatorId: any(named: 'operatorId'),
        warehouseId: any(named: 'warehouseId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(const AppError.network());
    final actions = FakeItineraryActions();
    await open(tester, actions);

    await pickVehicle(tester);
    await tester.tap(find.byKey(const Key('itinerary_header_submit')));
    await tester.pumpAndSettle();

    expect(actions.calls.single, contains('vehicle=7'));
  });
}
