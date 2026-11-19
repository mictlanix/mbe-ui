import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/add_stop_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'delivery_itinerary_harness.dart';

class _MockOrders extends Mock implements DeliveryOrderAdminRepository {}

DeliveryOrderSummary _order(int id, String customer) => DeliveryOrderSummary(
  id: id,
  facilityId: 4,
  serial: 1000 + id,
  customerId: 7,
  priority: 0,
  status: DeliveryOrderStatus.inPreparation,
  type: FulfillmentType.delivery,
  date: DateTime(2026, 11, 18),
  customerName: customer,
  shipToLabel: 'Calle 5 #$id',
);

/// Spec 075 FR-008, research R5: "Agregar parada".
void main() {
  late AppLocalizations l10n;
  late _MockOrders orders;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(DeliveryOrderStatus.inPreparation);
    registerFallbackValue(FulfillmentType.delivery);
  });

  setUp(() {
    orders = _MockOrders();
  });

  void listReturns(List<DeliveryOrderSummary> items, {int? total}) =>
      when(
        () => orders.list(
          statuses: any(named: 'statuses'),
          customer: any(named: 'customer'),
          facility: any(named: 'facility'),
          type: any(named: 'type'),
          salesOrder: any(named: 'salesOrder'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            DeliveryOrderPage(items: items, total: total ?? items.length),
      );

  Future<List<ItineraryActionResult?>> open(
    WidgetTester tester,
    FakeItineraryActions actions, {
    Set<int> existing = const {},
  }) async {
    final results = <ItineraryActionResult?>[];
    await pumpDialogHost(
      tester,
      open: (context) async => results.add(
        await showAddStopDialog(
          context,
          itineraryId: 58,
          existingOrderIds: existing,
        ),
      ),
      actions: actions,
      access: itineraryAccess(rights: itineraryWriter),
      overrides: [
        deliveryOrderAdminRepositoryProvider.overrideWithValue(orders),
      ],
    );
    return results;
  }

  testWidgets('only delivery orders in preparation are requested', (
    tester,
  ) async {
    listReturns([_order(1544, 'Ferretería Soto')]);

    await open(tester, FakeItineraryActions());

    final call = verify(
      () => orders.list(
        statuses: captureAny(named: 'statuses'),
        customer: any(named: 'customer'),
        facility: any(named: 'facility'),
        type: captureAny(named: 'type'),
        salesOrder: any(named: 'salesOrder'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    )..called(1);
    expect(call.captured[0], [DeliveryOrderStatus.inPreparation]);
    expect(call.captured[1], FulfillmentType.delivery);
    expect(find.text('Ferretería Soto'), findsOneWidget);
  });

  testWidgets('orders already on the trip are hidden', (tester) async {
    listReturns([_order(1532, 'Abarrotes La Central'), _order(1544, 'Soto')]);

    await open(tester, FakeItineraryActions(), existing: {1532});

    expect(find.text('Abarrotes La Central'), findsNothing);
    expect(find.text('Soto'), findsOneWidget);
  });

  testWidgets('searching by folio asks the server, digits only', (
    tester,
  ) async {
    listReturns([_order(1544, 'Soto')]);
    await open(tester, FakeItineraryActions());

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('itinerary_add_stop_search')),
        matching: find.byType(TextField),
      ),
      '15a4',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    verify(
      () => orders.list(
        statuses: any(named: 'statuses'),
        customer: any(named: 'customer'),
        facility: any(named: 'facility'),
        type: any(named: 'type'),
        salesOrder: any(named: 'salesOrder'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: '154',
        skip: 0,
        limit: 20,
      ),
    ).called(1);
  });

  testWidgets('nothing in preparation shows the empty state', (tester) async {
    listReturns(const []);

    await open(tester, FakeItineraryActions());

    expect(find.text(l10n.itineraryAddStopEmpty), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('itinerary_add_stop_submit')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('choosing an order and confirming adds it as a stop', (
    tester,
  ) async {
    listReturns([_order(1544, 'Soto'), _order(1547, 'Lara')]);
    final actions = FakeItineraryActions();
    final results = await open(tester, actions);

    await tester.tap(find.text('Lara'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('itinerary_add_stop_submit')));
    await tester.pumpAndSettle();

    expect(actions.calls.single, 'addStop 1547');
    expect(results.single?.error, isNull);
    expect(find.byKey(const Key('itinerary_add_stop_dialog')), findsNothing);
  });

  testWidgets('a refusal shows inline and keeps the dialog open', (
    tester,
  ) async {
    listReturns([_order(1544, 'Soto')]);
    final actions = FakeItineraryActions(
      error: const AppError.server(
        statusCode: 409,
        problem: ApiProblem(
          codeName: 'delivery_order.not_in_preparation',
          code: api.ErrorCode.deliveryOrderPeriodNotInPreparation,
          params: {'status': 6},
        ),
      ),
    );
    await open(tester, actions);

    await tester.tap(find.text('Soto'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('itinerary_add_stop_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('itinerary_add_stop_dialog')), findsOneWidget);
    expect(
      find.text(l10n.apiErrorDeliveryOrderNotInPreparation),
      findsOneWidget,
    );
  });
}
