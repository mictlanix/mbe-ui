import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_itinerary_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';

/// Wiring shared by the spec 075 widget tests, mirroring how the 061 detail
/// screen test sets itself up: a mocktail repository, a rights set for the
/// itinerary (87) and delivery-order (71) objects, a recording stand-in for
/// the actions, and the lookups answered from maps.

class MockDeliveryItineraryRepository extends Mock
    implements DeliveryItineraryRepository {}

/// The access override for a user who is not an administrator. Rights are
/// the [AccessRight]s granted on Delivery Itineraries (87); the others are
/// read on Delivery Orders (71), Vehicles (88), Vehicle Operators (89) and
/// Warehouses (4), each on by default.
Override itineraryAccess({
  Set<AccessRight> rights = const {AccessRight.read},
  bool ordersRead = true,
  bool vehiclesRead = true,
  bool operatorsRead = true,
  bool warehousesRead = true,
}) {
  int raw(Set<AccessRight> r) => r.fold(0, (sum, right) => sum | right.value);
  return accessControlProvider.overrideWithValue(
    AccessControlService(
      AuthState.authenticated(
        token: 't',
        user: User(
          userId: 'd',
          email: 'd@example.com',
          administrator: false,
          status: EntityStatus.active,
          sessionVersion: 1,
          privileges: [
            if (rights.isNotEmpty)
              Privilege(
                systemObject: SystemObject.deliveryItineraries,
                rawValue: raw(rights),
              ),
            if (ordersRead)
              const Privilege(
                systemObject: SystemObject.deliveryOrders,
                rawValue: 2,
              ),
            if (vehiclesRead)
              const Privilege(systemObject: SystemObject.vehicle, rawValue: 2),
            if (operatorsRead)
              const Privilege(
                systemObject: SystemObject.vehicleOperators,
                rawValue: 2,
              ),
            if (warehousesRead)
              const Privilege(
                systemObject: SystemObject.warehouses,
                rawValue: 2,
              ),
          ],
        ),
      ),
    ),
  );
}

/// Rights for a dispatcher who can create and change trips.
const itineraryWriter = {
  AccessRight.create,
  AccessRight.read,
  AccessRight.update,
};

/// Records each write and answers [error]; on success runs [onSuccess] first
/// (to swap what the trip answers), then puts [returns] on the screen, as the
/// real actions do. `calls` holds one readable line per write.
class FakeItineraryActions extends DeliveryItineraryActions {
  FakeItineraryActions({
    this.error,
    this.onSuccess,
    this.returns,
    this.newId = 59,
  });

  AppError? error;
  final void Function()? onSuccess;

  /// The trip a successful write answers; the screen shows it.
  Itinerary? returns;
  int newId;
  final calls = <String>[];

  /// The last closure handed to `closeStop`.
  StopClosure? lastClosure;

  Future<AppError?> _answer(int id, String call) async {
    calls.add(call);
    if (error == null) {
      onSuccess?.call();
      final trip = returns;
      if (trip != null &&
          ref.exists(deliveryItineraryDetailControllerProvider(id))) {
        ref
            .read(deliveryItineraryDetailControllerProvider(id).notifier)
            .replace(trip);
      }
    } else {
      ref.invalidate(deliveryItineraryDetailControllerProvider(id));
    }
    return error;
  }

  @override
  Future<({int? id, AppError? error})> create({
    DateTime? date,
    int? vehicleId,
    int? operatorId,
    int? warehouseId,
    String? comment,
  }) async {
    calls.add(
      'create vehicle=$vehicleId operator=$operatorId warehouse=$warehouseId comment=$comment',
    );
    return error == null ? (id: newId, error: null) : (id: null, error: error);
  }

  @override
  Future<AppError?> updateHeader(
    int id, {
    DateTime? date,
    int? vehicleId,
    int? operatorId,
    String? comment,
  }) => _answer(
    id,
    'updateHeader vehicle=$vehicleId operator=$operatorId comment=$comment',
  );

  @override
  Future<AppError?> addStop(int id, {required int deliveryOrderId}) =>
      _answer(id, 'addStop $deliveryOrderId');

  @override
  Future<AppError?> removeStop(int id, int stopId) =>
      _answer(id, 'removeStop $stopId');

  @override
  Future<AppError?> commitLine(
    int id,
    int stopId, {
    required int deliveryOrderLineId,
    required Decimal quantity,
  }) => _answer(id, 'commitLine $stopId $deliveryOrderLineId $quantity');

  @override
  Future<AppError?> commitWholeOrder(
    int id,
    int stopId, {
    required int deliveryOrderId,
  }) => _answer(id, 'commitWholeOrder $stopId $deliveryOrderId');

  @override
  Future<AppError?> adjust(
    int id,
    int stopId,
    int lineId, {
    required Decimal quantity,
  }) => _answer(id, 'adjust $stopId $lineId $quantity');

  @override
  Future<AppError?> release(int id, int stopId, int lineId) =>
      _answer(id, 'release $stopId $lineId');

  @override
  Future<AppError?> depart(int id) => _answer(id, 'depart');

  @override
  Future<AppError?> cancel(int id) => _answer(id, 'cancel');

  @override
  Future<AppError?> closeStop(int id, int stopId, StopClosure closure) {
    lastClosure = closure;
    return _answer(id, 'closeStop $stopId');
  }
}

/// The detail controller answering [answer], so a test sets the trip
/// directly. The controller's own loading is covered by its unit test.
class FakeItineraryDetail extends DeliveryItineraryDetailController {
  FakeItineraryDetail(this.answer);

  final Future<Itinerary> Function() answer;

  @override
  Future<Itinerary> build(int id) => answer();
}

/// A vehicle operator whose licence expires on [expires].
VehicleOperator fakeVehicleOperator({
  int id = 9,
  String name = 'Juan Rivas',
  required DateTime expires,
}) => VehicleOperator(
  vehicleOperatorId: id,
  driverId: 2,
  driverName: name,
  licenseType: 'E',
  driverLicenseNumber: 'X1',
  issueDate: DateTime(2020, 1, 1),
  expirationDate: expires,
  issuingLocation: 'Puebla',
  status: EntityStatus.active,
  hasLicensePhoto: false,
);

/// Pumps an app whose router has [routes], opened at [location].
///
/// - [orders] answers `itineraryOrderProvider` by order id (null: unreadable);
/// - [operators] answers `vehicleOperatorProvider` by operator id;
/// - [trip] answers the detail of the trip with that id, unless [overrides]
///   already sets the detail controller.
Future<GoRouter> pumpItineraryApp(
  WidgetTester tester, {
  required List<RouteBase> routes,
  required String location,
  Override? access,
  MockDeliveryItineraryRepository? repository,
  FakeItineraryActions? actions,
  Itinerary? trip,
  Map<int, DeliveryOrder?> orders = const {},
  Map<int, VehicleOperator?> operators = const {},
  FakeDocumentSource? documents,
  List<Override> overrides = const [],
  Size surface = const Size(1400, 1400),
  Locale locale = const Locale('es', 'MX'),
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      access ?? itineraryAccess(),
      documentSourceProvider.overrideWithValue(
        documents ?? FakeDocumentSource(),
      ),
      documentOutputProvider.overrideWithValue(FakeDocumentOutput()),
      if (repository != null)
        deliveryItineraryRepositoryProvider.overrideWithValue(repository),
      if (actions != null)
        deliveryItineraryActionsProvider.overrideWith(() => actions),
      if (trip != null)
        deliveryItineraryDetailControllerProvider(
          trip.id,
        ).overrideWith(() => FakeItineraryDetail(() async => trip)),
      itineraryOrderProvider.overrideWith((ref, id) async => orders[id]),
      vehicleOperatorProvider.overrideWith((ref, id) async => operators[id]),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(initialLocation: location, routes: routes);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// A delivery order with the given lines, as the load dialogs read it.
DeliveryOrder fakeDeliveryOrder({
  int id = 1532,
  required List<DeliveryOrderLine> lines,
}) => DeliveryOrder(
  id: id,
  facilityId: 4,
  customerId: 7,
  priority: 0,
  status: DeliveryOrderStatus.inPreparation,
  type: FulfillmentType.delivery,
  createdAt: DateTime(2026, 11, 1),
  modifiedAt: DateTime(2026, 11, 1),
  lines: lines,
);

DeliveryOrderLine fakeOrderLine({
  int id = 900,
  String code = 'CLA-25',
  String name = 'Clavo 2½"',
  String quantity = '25',
  String committed = '0',
  String open = '25',
}) => DeliveryOrderLine(
  id: id,
  productId: id,
  productCode: code,
  productName: name,
  warehouseId: 3,
  quantity: Decimal.parse(quantity),
  committed: Decimal.parse(committed),
  delivered: Decimal.zero,
  returned: Decimal.zero,
  open: Decimal.parse(open),
);

/// A tiny PNG, for proof images.
Uint8List get tinyPng => kTinyPng;

/// Pumps a screen with a single "open" button that calls [open], taps it and
/// settles, so a test starts with the dialog on screen. [open] gets the
/// button's context; keep its result in a variable to assert what the dialog
/// answered.
Future<GoRouter> pumpDialogHost(
  WidgetTester tester, {
  required Future<void> Function(BuildContext context) open,
  Override? access,
  MockDeliveryItineraryRepository? repository,
  FakeItineraryActions? actions,
  Map<int, DeliveryOrder?> orders = const {},
  Map<int, VehicleOperator?> operators = const {},
  List<Override> overrides = const [],
  Size surface = const Size(1400, 1400),
}) async {
  final router = await pumpItineraryApp(
    tester,
    location: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              key: const Key('open'),
              onPressed: () => open(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      // Where a trip opens after "Nuevo itinerario".
      GoRoute(
        path: '/sales/delivery-itineraries/:id',
        builder: (_, s) =>
            Scaffold(body: Text('trip-${s.pathParameters['id']}')),
      ),
    ],
    access: access,
    repository: repository,
    actions: actions,
    orders: orders,
    operators: operators,
    overrides: overrides,
    surface: surface,
  );
  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
  return router;
}
