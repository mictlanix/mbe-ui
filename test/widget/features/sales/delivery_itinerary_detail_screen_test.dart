import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/sales/delivery_itinerary_fixtures.dart';
import '../../../unit/core/documents/document_fakes.dart';
import 'delivery_itinerary_harness.dart';

/// Spec 075 ui-contract "Trip screen": the Abierto part (US1) and the depart
/// and cancel controls (US2, T025). The En ruta and Cerrado parts (US3) and
/// printing (US5) are added by their own tasks.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  List<RouteBase> routes() => [
    GoRoute(
      path: '/sales/delivery-itineraries',
      builder: (_, _) => const Scaffold(body: Text('list')),
    ),
    GoRoute(
      path: '/sales/delivery-itineraries/:itineraryId',
      builder: (_, state) => DeliveryItineraryDetailScreen(
        itineraryId: int.tryParse(state.pathParameters['itineraryId']!),
      ),
    ),
    GoRoute(
      path: '/sales/delivery-orders/:id',
      builder: (_, s) =>
          Scaffold(body: Text('order-${s.pathParameters['id']}')),
    ),
  ];

  Future<GoRouter> pump(
    WidgetTester tester, {
    Itinerary? trip,
    Set<AccessRight> rights = const {AccessRight.read},
    bool ordersRead = true,
    FakeItineraryActions? actions,
    MockDeliveryItineraryRepository? repository,
    Map<int, dynamic> operators = const {},
    Size surface = const Size(1400, 1400),
    String location = '/sales/delivery-itineraries/58',
    FakeDocumentSource? documents,
  }) => pumpItineraryApp(
    tester,
    routes: routes(),
    location: location,
    access: itineraryAccess(rights: rights, ordersRead: ordersRead),
    trip: trip,
    actions: actions,
    repository: repository,
    orders: {
      1532: fakeDeliveryOrder(
        id: 1532,
        lines: [fakeOrderLine(id: 900, open: '0', committed: '25')],
      ),
      1540: fakeDeliveryOrder(
        id: 1540,
        lines: [fakeOrderLine(id: 910, code: 'CEM-50', open: '4')],
      ),
    },
    operators: operators.cast(),
    surface: surface,
    documents: documents,
  );

  Finder key(String k) => find.byKey(Key(k));

  /// Two stops: one fully loaded, one half loaded.
  Itinerary loadedTrip({ItineraryStatus status = ItineraryStatus.open}) =>
      fakeItinerary(
        status: status,
        comment: 'Salida temprana',
        stops: [
          fakeItineraryStop(
            id: 501,
            sequence: 1,
            lines: [
              fakeItineraryLine(id: 7001, orderLineId: 900, committed: '25'),
            ],
          ),
          fakeItineraryStop(
            id: 502,
            sequence: 2,
            orderId: 1540,
            customer: 'Materiales Herrera',
            shipTo: 'Av. Juárez 120',
            lines: [
              fakeItineraryLine(
                id: 7002,
                orderLineId: 910,
                orderId: 1540,
                code: 'CEM-50',
                name: 'Cemento gris 50 kg',
                unit: 'bulto',
                committed: '6',
              ),
            ],
          ),
        ],
      );

  group('header', () {
    testWidgets('shows the title and the facts the server named', (
      tester,
    ) async {
      await pump(tester, trip: loadedTrip());

      expect(find.text(l10n.itineraryTitle(58)), findsOneWidget);
      final facts = key('itinerary_facts');
      for (final value in [
        '2026-11-18',
        'Torton · MBE-114',
        'Juan Rivas',
        'Bodega Norte',
        'Salida temprana',
      ]) {
        expect(
          find.descendant(of: facts, matching: find.text(value)),
          findsOneWidget,
          reason: value,
        );
      }
      expect(key('itinerary_status_chip_open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a trip with nothing assigned shows dashes, and "Sin '
        'operador"', (tester) async {
      await pump(
        tester,
        trip: fakeItinerary(
          vehicleId: null,
          operatorId: null,
          warehouseId: null,
          stops: const [],
        ),
      );

      final facts = key('itinerary_facts');
      expect(
        find.descendant(
          of: facts,
          matching: find.text(l10n.itineraryNoOperator),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: facts, matching: find.text('—')),
        findsNWidgets(2),
      );
    });

    testWidgets('the AppBar has a title and no actions', (tester) async {
      await pump(tester, trip: loadedTrip(), rights: itineraryWriter);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, isNull);
    });
  });

  group('licence warning', () {
    testWidgets('shows for an expired licence, naming the operator and the '
        'date', (tester) async {
      await pump(
        tester,
        trip: loadedTrip(),
        operators: {9: fakeVehicleOperator(expires: DateTime(2026, 11, 2))},
      );

      expect(key('itinerary_licence_warning'), findsOneWidget);
      expect(
        find.text(l10n.itineraryLicenseExpired('Juan Rivas', '2026-11-02')),
        findsOneWidget,
      );
    });

    testWidgets('does not show for a valid licence', (tester) async {
      await pump(
        tester,
        trip: loadedTrip(),
        operators: {
          9: fakeVehicleOperator(
            expires: DateTime.now().add(const Duration(days: 90)),
          ),
        },
      );

      expect(key('itinerary_licence_warning'), findsNothing);
    });

    testWidgets('is silent when the operator can not be read', (tester) async {
      await pump(tester, trip: loadedTrip());

      expect(key('itinerary_licence_warning'), findsNothing);
    });

    testWidgets('is shown for an Abierto trip only', (tester) async {
      await pump(
        tester,
        trip: loadedTrip(status: ItineraryStatus.departed),
        operators: {9: fakeVehicleOperator(expires: DateTime(2026, 11, 2))},
      );

      expect(key('itinerary_licence_warning'), findsNothing);
    });
  });

  group('rights', () {
    testWidgets('read alone: no edit, stop, load, ✎, 🗑 or menu control', (
      tester,
    ) async {
      await pump(tester, trip: loadedTrip());

      expect(find.byType(DataTable), findsNothing);
      for (final k in [
        'itinerary_edit_header',
        'itinerary_add_stop',
        'itinerary_cancel',
        'itinerary_depart',
        'itinerary_stop_load_all_501',
        'itinerary_stop_load_line_501',
        'itinerary_stop_menu_501',
        'itinerary_line_edit_7001',
        'itinerary_line_release_7001',
      ]) {
        expect(key(k), findsNothing, reason: k);
      }
      // What it can read is still there.
      expect(find.text('CLA-25'), findsOneWidget);
    });

    testWidgets('update: every Abierto control is offered', (tester) async {
      await pump(tester, trip: loadedTrip(), rights: itineraryWriter);

      for (final k in [
        'itinerary_edit_header',
        'itinerary_add_stop',
        'itinerary_cancel',
        'itinerary_depart',
        'itinerary_stop_load_all_501',
        'itinerary_stop_load_line_501',
        'itinerary_stop_menu_501',
        'itinerary_line_edit_7001',
        'itinerary_line_release_7001',
      ]) {
        expect(key(k), findsOneWidget, reason: k);
      }
    });

    testWidgets('picking an order and a line need read on Delivery Orders', (
      tester,
    ) async {
      await pump(
        tester,
        trip: loadedTrip(),
        rights: itineraryWriter,
        ordersRead: false,
      );

      expect(key('itinerary_add_stop'), findsNothing);
      expect(key('itinerary_stop_load_line_501'), findsNothing);
      // "Cargar todo" needs only the order id the stop already has.
      expect(key('itinerary_stop_load_all_501'), findsOneWidget);
    });
  });

  group('stops', () {
    testWidgets('a card names the order, customer, ship-to and its lines', (
      tester,
    ) async {
      await pump(tester, trip: loadedTrip(), rights: itineraryWriter);

      expect(find.text(l10n.itineraryStopTitle(1)), findsOneWidget);
      expect(find.text('Abarrotes La Central'), findsOneWidget);
      expect(find.text('Mercado 2, Local L-14'), findsOneWidget);
      expect(find.text('Materiales Herrera'), findsOneWidget);
      expect(find.text('Cemento gris 50 kg'), findsOneWidget);
      // The unit comes from the server, per line.
      expect(find.text('bulto'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('the order links to its screen with read on Delivery Orders', (
      tester,
    ) async {
      final router = await pump(tester, trip: loadedTrip());

      await tester.tap(key('itinerary_stop_order_501'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/delivery-orders/1532');
    });

    testWidgets('without read on Delivery Orders the order is plain text', (
      tester,
    ) async {
      await pump(tester, trip: loadedTrip(), ordersRead: false);

      expect(find.text(l10n.itineraryStopOrder(1532)), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('pending and loaded quantities are shown, the pending one '
        'from the order', (tester) async {
      await pump(tester, trip: loadedTrip(), rights: itineraryWriter);

      expect(find.text(l10n.itineraryLinePending), findsNWidgets(2));
      expect(find.text(l10n.itineraryLineLoaded), findsNWidgets(2));
      // Order 1540 has 4 open; the loaded line carries 6.
      expect(find.text('4'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('a legacy stop with no order of its own lists the orders of '
        'its lines', (tester) async {
      await pump(
        tester,
        trip: fakeItinerary(
          stops: [
            fakeItineraryStop(
              orderId: null,
              orderIds: [1498, 1502],
              customer: null,
              shipTo: null,
            ),
          ],
        ),
        rights: itineraryWriter,
      );

      expect(find.text(l10n.itineraryStopTitle(1)), findsOneWidget);
      expect(find.text(l10n.itineraryStopOrders('1498, 1502')), findsOneWidget);
      expect(find.text('Clavo 2½"'), findsOneWidget);
    });

    testWidgets('a stop with nothing loaded says so, and has no table', (
      tester,
    ) async {
      await pump(
        tester,
        trip: fakeItinerary(stops: [fakeItineraryStop(lines: const [])]),
        rights: itineraryWriter,
      );

      expect(key('itinerary_stop_empty_501'), findsOneWidget);
      expect(key('itinerary_stop_lines_501'), findsNothing);
      expect(key('itinerary_line_edit_7001'), findsNothing);
    });

    testWidgets('a compact screen shows a card per line, not a table', (
      tester,
    ) async {
      await pump(
        tester,
        trip: loadedTrip(),
        rights: itineraryWriter,
        surface: const Size(420, 1400),
      );

      expect(key('itinerary_line_card_7001'), findsOneWidget);
      expect(key('itinerary_line_edit_7001'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Dar salida', () {
    testWidgets('is disabled with nothing loaded, and says so', (tester) async {
      await pump(
        tester,
        trip: fakeItinerary(stops: [fakeItineraryStop(lines: const [])]),
        rights: itineraryWriter,
      );

      final depart = tester.widget<FilledButton>(key('itinerary_depart'));
      expect(depart.onPressed, isNull);
      expect(
        tester.widget<Text>(key('itinerary_depart_guard')).data,
        l10n.itineraryDepartGuardNothing,
      );
    });

    testWidgets('is disabled while a stop is empty, naming the stop', (
      tester,
    ) async {
      final trip = fakeItinerary(
        stops: [
          fakeItineraryStop(id: 501, sequence: 1),
          fakeItineraryStop(
            id: 502,
            sequence: 3,
            orderId: 1544,
            lines: const [],
          ),
        ],
      );
      await pump(tester, trip: trip, rights: itineraryWriter);

      expect(
        tester.widget<FilledButton>(key('itinerary_depart')).onPressed,
        isNull,
      );
      expect(find.text(l10n.itineraryDepartGuardEmptyStop(3)), findsOneWidget);
    });

    testWidgets('is enabled with everything loaded, and no caption', (
      tester,
    ) async {
      await pump(tester, trip: loadedTrip(), rights: itineraryWriter);

      expect(
        tester.widget<FilledButton>(key('itinerary_depart')).onPressed,
        isNotNull,
      );
      expect(key('itinerary_depart_guard'), findsNothing);
    });

    testWidgets('the confirmation shows vehicle, operator, stops and lines, '
        'then departs', (tester) async {
      final actions = FakeItineraryActions();
      await pump(
        tester,
        trip: loadedTrip(),
        rights: itineraryWriter,
        actions: actions,
      );

      await tester.tap(key('itinerary_depart'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.itineraryDepartVehicleOperator('Torton · MBE-114', 'Juan Rivas'),
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.itineraryDepartCounts(2, 2)), findsOneWidget);
      expect(find.text(l10n.itineraryDepartWarning), findsOneWidget);

      await tester.tap(key('itinerary_confirm_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls.single, 'depart');
    });

    testWidgets('with no operator the confirmation says "Sin operador"', (
      tester,
    ) async {
      await pump(
        tester,
        trip: fakeItinerary(operatorId: null),
        rights: itineraryWriter,
        actions: FakeItineraryActions(),
      );

      await tester.tap(key('itinerary_depart'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.itineraryDepartVehicleOperator(
            'Torton · MBE-114',
            l10n.itineraryNoOperator,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a refusal shows on the screen', (tester) async {
      final actions = FakeItineraryActions(
        error: const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'itinerary.nothing_committed',
            code: api.ErrorCode.itineraryPeriodNothingCommitted,
          ),
        ),
      );
      await pump(
        tester,
        trip: loadedTrip(),
        rights: itineraryWriter,
        actions: actions,
      );

      await tester.tap(key('itinerary_depart'));
      await tester.pumpAndSettle();
      await tester.tap(key('itinerary_confirm_submit'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.apiErrorItineraryNothingCommitted), findsOneWidget);
    });
  });

  group('Cancelar itinerario', () {
    testWidgets('names what is released, then cancels', (tester) async {
      final actions = FakeItineraryActions();
      await pump(
        tester,
        trip: loadedTrip(),
        rights: itineraryWriter,
        actions: actions,
      );

      await tester.tap(key('itinerary_cancel'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.itineraryCancelBody), findsOneWidget);
      await tester.tap(key('itinerary_confirm_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls.single, 'cancel');
    });

    testWidgets('keeping it calls nothing', (tester) async {
      final actions = FakeItineraryActions();
      await pump(
        tester,
        trip: loadedTrip(),
        rights: itineraryWriter,
        actions: actions,
      );

      await tester.tap(key('itinerary_cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.itineraryCancelDismiss));
      await tester.pumpAndSettle();

      expect(actions.calls, isEmpty);
    });
  });

  group('other statuses', () {
    testWidgets('En ruta hides every Abierto control and shows what was '
        'sent', (tester) async {
      await pump(
        tester,
        trip: fakeItinerary(
          status: ItineraryStatus.departed,
          departedAt: DateTime(2026, 11, 18, 7, 4),
          stops: [
            fakeItineraryStop(
              lines: [fakeItineraryLine(committed: '25', sent: '25')],
            ),
          ],
        ),
        rights: itineraryWriter,
      );

      for (final k in [
        'itinerary_edit_header',
        'itinerary_add_stop',
        'itinerary_cancel',
        'itinerary_depart',
        'itinerary_stop_load_all_501',
        'itinerary_stop_menu_501',
        'itinerary_line_edit_7001',
        'itinerary_line_release_7001',
      ]) {
        expect(key(k), findsNothing, reason: k);
      }
      expect(
        find.descendant(
          of: key('itinerary_stop_lines_501'),
          matching: find.text(l10n.itineraryLineSent),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: key('itinerary_stop_lines_501'),
          matching: find.text(l10n.itineraryLinePending),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: key('itinerary_facts'),
          matching: find.text('2026-11-18 07:04'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Cancelado shows its one line and no actions', (tester) async {
      await pump(
        tester,
        trip: fakeItinerary(status: ItineraryStatus.cancelled, stops: const []),
        rights: itineraryWriter,
      );

      expect(key('itinerary_cancelled_note'), findsOneWidget);
      expect(find.text(l10n.itineraryCancelledNote), findsOneWidget);
      for (final k in [
        'itinerary_edit_header',
        'itinerary_add_stop',
        'itinerary_depart',
      ]) {
        expect(key(k), findsNothing, reason: k);
      }
    });
  });

  group('closing stops (US3)', () {
    Itinerary departed({
      StopOutcome first = StopOutcome.pending,
      StopOutcome second = StopOutcome.pending,
    }) => fakeItinerary(
      status: ItineraryStatus.departed,
      departedAt: DateTime(2026, 11, 18, 7, 4),
      stops: [
        fakeItineraryStop(
          id: 501,
          sequence: 1,
          outcome: first,
          arrivedAt: first == StopOutcome.pending
              ? null
              : DateTime(2026, 11, 18, 13, 48),
          lines: [
            fakeItineraryLine(
              id: 7001,
              committed: '25',
              sent: '25',
              delivered: first == StopOutcome.pending ? '0' : '25',
            ),
          ],
        ),
        fakeItineraryStop(
          id: 502,
          sequence: 2,
          orderId: 1540,
          customer: 'Materiales Herrera',
          outcome: second,
          arrivedAt: second == StopOutcome.pending
              ? null
              : DateTime(2026, 11, 18, 14, 20),
          lines: [
            fakeItineraryLine(
              id: 7002,
              orderId: 1540,
              code: 'CEM-50',
              name: 'Cemento gris 50 kg',
              unit: 'bulto',
              committed: '6',
              sent: '6',
              delivered: second == StopOutcome.pending ? '0' : '4',
              returned: second == StopOutcome.pending ? '0' : '2',
              reason: second == StopOutcome.pending
                  ? null
                  : ShortfallReason.damagedGoods,
            ),
          ],
        ),
      ],
    );

    testWidgets('a pending stop offers Cerrar parada only on En ruta with '
        'update', (tester) async {
      await pump(tester, trip: departed(), rights: itineraryWriter);
      expect(key('itinerary_stop_close_501'), findsOneWidget);
      expect(key('itinerary_stop_close_502'), findsOneWidget);
    });

    testWidgets('read alone has no Cerrar parada', (tester) async {
      await pump(tester, trip: departed());
      expect(key('itinerary_stop_close_501'), findsNothing);
    });

    testWidgets('an Abierto trip has none either', (tester) async {
      await pump(tester, trip: loadedTrip(), rights: itineraryWriter);
      expect(key('itinerary_stop_close_501'), findsNothing);
    });

    testWidgets('a closed stop shows its outcome, when it closed, and what '
        'was delivered, returned and why', (tester) async {
      await pump(
        tester,
        trip: departed(
          first: StopOutcome.delivered,
          second: StopOutcome.partiallyDelivered,
        ),
        rights: itineraryWriter,
      );

      expect(key('stop_outcome_chip_delivered'), findsOneWidget);
      expect(key('stop_outcome_chip_partiallyDelivered'), findsOneWidget);
      expect(
        find.text(l10n.itineraryStopClosedAt('2026-11-18 13:48')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.itineraryStopClosedAt('2026-11-18 14:20')),
        findsOneWidget,
      );
      final table = key('itinerary_stop_lines_502');
      for (final label in [
        l10n.itineraryLineSent,
        l10n.itineraryLineDelivered,
        l10n.itineraryLineReturned,
        l10n.itineraryLineReason,
      ]) {
        expect(
          find.descendant(of: table, matching: find.text(label)),
          findsOneWidget,
          reason: label,
        );
      }
      expect(
        find.descendant(
          of: table,
          matching: find.text(l10n.itineraryReasonDamagedGoods),
        ),
        findsOneWidget,
      );
      // Closed stops offer nothing more.
      expect(key('itinerary_stop_close_501'), findsNothing);
      expect(key('itinerary_stop_close_502'), findsNothing);
    });

    testWidgets('a pending stop shows what was sent and the chip "Pendiente"', (
      tester,
    ) async {
      await pump(tester, trip: departed());

      expect(key('stop_outcome_chip_pending'), findsNWidgets(2));
      expect(
        find.descendant(
          of: key('itinerary_stop_lines_501'),
          matching: find.text(l10n.itineraryLineDelivered),
        ),
        findsNothing,
      );
    });

    testWidgets('closing the last stop flips the trip to Cerrado with its '
        'return time, with no reload', (tester) async {
      final closed = fakeItinerary(
        status: ItineraryStatus.closed,
        departedAt: DateTime(2026, 11, 18, 7, 4),
        returnedAt: DateTime(2026, 11, 18, 15, 22),
        stops: [
          fakeItineraryStop(
            id: 501,
            outcome: StopOutcome.delivered,
            arrivedAt: DateTime(2026, 11, 18, 15, 22),
            lines: [
              fakeItineraryLine(committed: '25', sent: '25', delivered: '25'),
            ],
          ),
        ],
      );
      final actions = FakeItineraryActions(returns: closed);
      await pump(
        tester,
        trip: fakeItinerary(
          status: ItineraryStatus.departed,
          departedAt: DateTime(2026, 11, 18, 7, 4),
          stops: [
            fakeItineraryStop(
              id: 501,
              lines: [fakeItineraryLine(committed: '25', sent: '25')],
            ),
          ],
        ),
        rights: itineraryWriter,
        actions: actions,
      );
      expect(key('itinerary_status_chip_departed'), findsOneWidget);

      await tester.tap(key('itinerary_stop_close_501'));
      await tester.pumpAndSettle();
      await tester.enterText(key('itinerary_close_name'), 'Ana');
      await tester.enterText(key('itinerary_close_id'), 'INE 1');
      await tester.tap(find.text(l10n.itineraryCloseProofSignature));
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getTopLeft(key('signature_pad')) + const Offset(30, 30),
      );
      await gesture.moveBy(const Offset(80, 20));
      await gesture.up();
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(key('itinerary_close_submit'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(actions.calls.single, 'closeStop 501');
      expect(key('itinerary_close_dialog'), findsNothing);
      expect(key('itinerary_status_chip_closed'), findsOneWidget);
      expect(
        find.descendant(
          of: key('itinerary_facts'),
          matching: find.text('2026-11-18 15:22'),
        ),
        findsOneWidget,
      );
      expect(key('itinerary_stop_close_501'), findsNothing);
    });

    testWidgets('Cerrado is read-only: no action beyond printing', (
      tester,
    ) async {
      await pump(
        tester,
        trip: fakeItinerary(
          status: ItineraryStatus.closed,
          departedAt: DateTime(2026, 11, 18, 7, 4),
          returnedAt: DateTime(2026, 11, 18, 15, 22),
          stops: [
            fakeItineraryStop(
              outcome: StopOutcome.delivered,
              lines: [fakeItineraryLine(sent: '25', delivered: '25')],
            ),
          ],
        ),
        rights: itineraryWriter,
      );

      for (final k in [
        'itinerary_edit_header',
        'itinerary_add_stop',
        'itinerary_cancel',
        'itinerary_depart',
        'itinerary_stop_close_501',
        'itinerary_stop_menu_501',
        'itinerary_line_edit_7001',
      ]) {
        expect(key(k), findsNothing, reason: k);
      }
    });
  });

  group('printing (US5)', () {
    Itinerary onTheRoad({ItineraryStatus status = ItineraryStatus.departed}) =>
        fakeItinerary(
          status: status,
          departedAt: DateTime(2026, 11, 18, 7, 4),
          stops: [
            fakeItineraryStop(lines: [fakeItineraryLine(sent: '25')]),
          ],
        );

    for (final status in [ItineraryStatus.departed, ItineraryStatus.closed]) {
      testWidgets('both buttons show for ${status.name} with read on 87', (
        tester,
      ) async {
        await pump(tester, trip: onTheRoad(status: status));

        expect(key('itinerary_print_ticket'), findsOneWidget);
        expect(key('itinerary_print_notes'), findsOneWidget);
        expect(find.text(l10n.itineraryActionPrintTicket), findsOneWidget);
        expect(find.text(l10n.itineraryActionPrintNotes), findsOneWidget);
      });
    }

    for (final status in [ItineraryStatus.open, ItineraryStatus.cancelled]) {
      testWidgets('neither button shows for ${status.name}', (tester) async {
        await pump(
          tester,
          trip: fakeItinerary(status: status, stops: const []),
          rights: itineraryWriter,
        );

        expect(key('itinerary_print_ticket'), findsNothing);
        expect(key('itinerary_print_notes'), findsNothing);
      });
    }

    testWidgets('the ticket opens the preview for its kind', (tester) async {
      final documents = FakeDocumentSource();
      await pump(tester, trip: onTheRoad(), documents: documents);

      await tester.tap(key('itinerary_print_ticket'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(documents.fetched.single.kind, DocumentKind.itineraryTicket);
      expect(documents.fetched.single.recordId, 58);
      expect(documents.fetched.single.title, 'Ticket del itinerario · 58');
    });

    testWidgets('the delivery notes open the preview for their kind', (
      tester,
    ) async {
      final documents = FakeDocumentSource();
      await pump(tester, trip: onTheRoad(), documents: documents);

      await tester.tap(key('itinerary_print_notes'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(
        documents.fetched.single.kind,
        DocumentKind.itineraryDeliveryNotes,
      );
      expect(documents.fetched.single.recordId, 58);
    });

    testWidgets('printing changes nothing on the trip', (tester) async {
      final actions = FakeItineraryActions();
      await pump(
        tester,
        trip: onTheRoad(),
        rights: itineraryWriter,
        actions: actions,
      );

      await tester.tap(key('itinerary_print_ticket'));
      await tester.pumpAndSettle();

      expect(actions.calls, isEmpty);
    });
  });

  group('not found and failures', () {
    testWidgets('an unknown trip shows the coded not-found, with a way back', (
      tester,
    ) async {
      final repository = MockDeliveryItineraryRepository();
      when(() => repository.getById(any())).thenThrow(
        const AppError.notFound(
          null,
          ApiProblem(
            codeName: 'resource.not_found',
            code: api.ErrorCode.resourcePeriodNotFound,
            params: {'resource': 'delivery_itinerary'},
          ),
        ),
      );
      await pump(
        tester,
        repository: repository,
        location: '/sales/delivery-itineraries/999',
      );

      expect(key('itinerary_not_found'), findsOneWidget);
      expect(
        find.text(l10n.apiErrorResourceNotFound('masculine', 'itinerario')),
        findsOneWidget,
      );

      await tester.tap(key('itinerary_back_to_list'));
      await tester.pumpAndSettle();
      expect(find.text('list'), findsOneWidget);
    });

    testWidgets('a non-numeric id is not found, not an error', (tester) async {
      await pump(tester, location: '/sales/delivery-itineraries/abc');

      expect(key('itinerary_not_found'), findsOneWidget);
    });

    testWidgets('a load failure offers a retry', (tester) async {
      final repository = MockDeliveryItineraryRepository();
      var calls = 0;
      when(() => repository.getById(58)).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const AppError.network();
        return fakeItinerary();
      });
      await pump(tester, repository: repository);

      expect(key('itinerary_load_failed'), findsOneWidget);
      await tester.tap(key('itinerary_retry_button'));
      await tester.pumpAndSettle();

      expect(key('itinerary_facts'), findsOneWidget);
    });
  });
}
