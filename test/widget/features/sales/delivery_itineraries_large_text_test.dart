import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/close_stop_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_detail_screen.dart';

import '../../../unit/features/sales/delivery_itinerary_fixtures.dart';
import 'delivery_itinerary_harness.dart';

/// Spec 075 T037, quickstart step 13 (constitution §V): at the largest text
/// size, the list, the trip screen with a closed stop's table, and the close
/// dialog must not clip or overflow at a supported desktop width. The platform
/// scale stands in for the user's extra-large level: the app composes the two
/// multiplicatively, and setting it here also reaches dialogs, which sit above
/// the test's widget tree.
void main() {
  const desktop = Size(1280, 800);

  void useExtraLargeText(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue =
        TextSizeLevel.extraLarge.factor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  setUpAll(() => registerFallbackValue(ItineraryStatus.open));

  testWidgets('the list does not overflow', (tester) async {
    useExtraLargeText(tester);
    final repository = MockDeliveryItineraryRepository();
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
    ).thenAnswer(
      (_) async => ItineraryPage(
        items: [
          fakeItinerarySummary(id: 58),
          fakeItinerarySummary(id: 57, status: ItineraryStatus.departed),
          fakeItinerarySummary(id: 56, status: ItineraryStatus.cancelled),
        ],
        total: 3,
      ),
    );

    await pumpItineraryApp(
      tester,
      location: '/sales/delivery-itineraries',
      routes: [
        GoRoute(
          path: '/sales/delivery-itineraries',
          builder: (_, state) => Scaffold(
            body: DeliveryItinerariesListScreen(
              query: ListQuery.fromUri(state.uri),
            ),
          ),
        ),
      ],
      repository: repository,
      access: itineraryAccess(rights: itineraryWriter),
      surface: desktop,
    );

    expect(find.byKey(const Key('delivery_itineraries_table')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the trip screen with a closed stop\'s table does not '
      'overflow', (tester) async {
    useExtraLargeText(tester);
    final trip = fakeItinerary(
      status: ItineraryStatus.departed,
      departedAt: DateTime(2026, 11, 18, 7, 4),
      comment: 'Salida temprana por la zona industrial',
      stops: [
        fakeItineraryStop(
          id: 501,
          sequence: 1,
          outcome: StopOutcome.delivered,
          arrivedAt: DateTime(2026, 11, 18, 13, 48),
          lines: [
            fakeItineraryLine(committed: '25', sent: '25', delivered: '25'),
          ],
        ),
        fakeItineraryStop(
          id: 502,
          sequence: 2,
          orderId: 1540,
          customer: 'Materiales Herrera',
          shipTo: 'Av. Juárez 120, Centro, Puebla',
          outcome: StopOutcome.partiallyDelivered,
          arrivedAt: DateTime(2026, 11, 18, 14, 20),
          lines: [
            fakeItineraryLine(
              id: 7002,
              code: 'CEM-50',
              name: 'Cemento gris 50 kg',
              unit: 'bulto',
              committed: '6',
              sent: '6',
              delivered: '4',
              returned: '2',
              reason: ShortfallReason.damagedGoods,
            ),
          ],
        ),
        fakeItineraryStop(
          id: 503,
          sequence: 3,
          orderId: 1544,
          customer: 'Ferretería Soto',
          lines: [fakeItineraryLine(id: 7003, committed: '40', sent: '40')],
        ),
      ],
    );

    await pumpItineraryApp(
      tester,
      location: '/sales/delivery-itineraries/58',
      routes: [
        GoRoute(
          path: '/sales/delivery-itineraries/:itineraryId',
          builder: (_, state) => DeliveryItineraryDetailScreen(
            itineraryId: int.tryParse(state.pathParameters['itineraryId']!),
          ),
        ),
      ],
      trip: trip,
      access: itineraryAccess(rights: itineraryWriter),
      surface: desktop,
    );

    expect(find.byKey(const Key('itinerary_stop_lines_502')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the close dialog does not overflow', (tester) async {
    useExtraLargeText(tester);
    final stop = fakeItineraryStop(
      id: 502,
      sequence: 2,
      orderId: 1540,
      customer: 'Materiales Herrera',
      lines: [
        fakeItineraryLine(
          id: 7001,
          code: 'CEM-50',
          name: 'Cemento gris 50 kg',
          unit: 'bulto',
          committed: '6',
          sent: '6',
        ),
        fakeItineraryLine(
          id: 7002,
          code: 'ARE-01',
          name: 'Arena m³',
          unit: 'm³',
          committed: '2',
          sent: '2',
        ),
      ],
    );
    await pumpDialogHost(
      tester,
      open: (context) async => showCloseStopDialog(
        context,
        trip: fakeItinerary(status: ItineraryStatus.departed),
        stop: stop,
      ),
      actions: FakeItineraryActions(),
      access: itineraryAccess(rights: itineraryWriter),
      surface: desktop,
    );
    // A shortfall adds the reason dropdown: the widest the form gets.
    await tester.enterText(
      find.byKey(const Key('itinerary_close_delivered_7001')),
      '4',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('itinerary_close_reason_7001')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
