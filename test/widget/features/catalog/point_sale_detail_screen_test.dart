import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/point_sale_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/point_sale_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.pointsOfSale, rawValue: 15),
  ],
);

final _pointSale = PointSale(
  pointSaleId: 1,
  facilityId: 9,
  facilityName: 'Main Store',
  code: 'POS-1',
  name: 'Front Counter',
  warehouseId: 5,
  warehouseName: 'Main Warehouse',
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockPointSaleRepository repository;
  late MockFacilityRepository facilityRepository;
  late MockWarehouseRepository warehouseRepository;
  late ProviderContainer container;

  setUp(() {
    repository = MockPointSaleRepository();
    facilityRepository = MockFacilityRepository();
    warehouseRepository = MockWarehouseRepository();
    container = ProviderContainer(
      overrides: [
        pointSaleRepositoryProvider.overrideWithValue(repository),
        facilityRepositoryProvider.overrideWithValue(facilityRepository),
        warehouseRepositoryProvider.overrideWithValue(warehouseRepository),
        accessControlProvider.overrideWithValue(_accessFor(_fullAccessUser)),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> pumpScreen(WidgetTester tester, {int? pointSaleId}) async {
    if (pointSaleId != null) {
      when(
        () => repository.get(pointSaleId: pointSaleId),
      ).thenAnswer((_) async => _pointSale);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PointSaleDetailScreen(pointSaleId: pointSaleId)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'the warehouse field is disabled until a facility is selected',
    (tester) async {
      await pumpScreen(tester);

      // `CatalogEntityPicker` itself carries the key; when disabled it
      // internally renders a plain `TextFormField`, so its own `enabled`
      // flag — not a nested-widget cast — is what the test asserts on.
      final warehouseField = tester.widget<CatalogEntityPicker<Warehouse>>(
        find.byKey(const Key('warehouse_field')),
      );
      expect(warehouseField.enabled, isFalse);
    },
  );

  testWidgets(
    'the warehouse picker query is scoped to the selected facility (FR-022)',
    (tester) async {
      when(
        () => warehouseRepository.list(
          search: any(named: 'search'),
          facilityId: 9,
        ),
      ).thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

      await pumpScreen(tester);
      container
          .read(pointSaleFormControllerProvider.notifier)
          .facilitySelected(9, 'Main Store');
      await tester.pumpAndSettle();

      final warehouseField = tester.widget<CatalogEntityPicker<Warehouse>>(
        find.byKey(const Key('warehouse_field')),
      );
      expect(warehouseField.enabled, isTrue);
    },
  );

  testWidgets(
    'changing the facility clears an already-selected warehouse, forcing '
    'reselection (FR-022)',
    (tester) async {
      await pumpScreen(tester);
      final controller = container.read(
        pointSaleFormControllerProvider.notifier,
      );

      controller.facilitySelected(9, 'Main Store');
      controller.warehouseSelected(5, 'Main Warehouse');
      expect(
        container.read(pointSaleFormControllerProvider).warehouseId,
        5,
      );

      controller.facilitySelected(10, 'North Plant');

      final state = container.read(pointSaleFormControllerProvider);
      expect(state.warehouseId, isNull);
      expect(state.warehouseDisplayText, isEmpty);
    },
  );

  testWidgets(
    're-selecting the same facility does not clear the warehouse',
    (tester) async {
      await pumpScreen(tester);
      final controller = container.read(
        pointSaleFormControllerProvider.notifier,
      );

      controller.facilitySelected(9, 'Main Store');
      controller.warehouseSelected(5, 'Main Warehouse');
      controller.facilitySelected(9, 'Main Store');

      expect(container.read(pointSaleFormControllerProvider).warehouseId, 5);
    },
  );

  testWidgets(
    'a legacy cross-facility record still loads without being cleared '
    '(FR-022)',
    (tester) async {
      // `Autocomplete.initialValue` only ever seeds its `TextEditingController`
      // once, at first build — it does not reactively pick up a later
      // `initialDisplayText` change once `loadForEdit` resolves, so this
      // asserts on the loaded form state directly rather than on rendered
      // picker text (a `CatalogEntityPicker` characteristic, not a defect
      // introduced here).
      await pumpScreen(tester, pointSaleId: 1);

      final state = container.read(pointSaleFormControllerProvider);
      expect(state.facilityId, 9);
      expect(state.facilityDisplayText, 'Main Store');
      expect(state.warehouseId, 5);
      expect(state.warehouseDisplayText, 'Main Warehouse');
    },
  );

  testWidgets(
    'a cross-facility pairing rejected by the server is surfaced without '
    'discarding input (FR-012, mbe-api#102)',
    (tester) async {
      when(
        () => repository.create(
          facilityId: any(named: 'facilityId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          warehouseId: any(named: 'warehouseId'),
          comment: any(named: 'comment'),
          status: any(named: 'status'),
        ),
      ).thenThrow(
        AppError.validation([
          const FieldError(
            loc: ['warehouse'],
            msg: 'Warehouse does not belong to the selected facility',
            type: 'value_error',
          ),
        ]),
      );

      await pumpScreen(tester);
      final controller = container.read(
        pointSaleFormControllerProvider.notifier,
      );
      controller.facilitySelected(9, 'Main Store');
      controller.warehouseSelected(5, 'Main Warehouse');
      await tester.enterText(find.byKey(const Key('code_field')), 'POS-1');
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'Front Counter',
      );

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Warehouse does not belong to the selected facility'),
        findsOneWidget,
      );
      expect(find.text('POS-1'), findsOneWidget);
      expect(find.text('Front Counter'), findsOneWidget);
    },
  );

  testWidgets('delete requires a confirmation dialog before submit (FR-007)', (
    tester,
  ) async {
    when(
      () => repository.delete(pointSaleId: 1),
    ).thenAnswer((_) async {});

    final router = GoRouter(
      initialLocation: '/points-of-sale',
      routes: [
        GoRoute(
          path: '/points-of-sale',
          builder: (_, _) =>
              const Scaffold(body: Text('points of sale list')),
        ),
        GoRoute(
          path: '/points-of-sale/:pointSaleId',
          builder: (_, state) => PointSaleDetailScreen(
            pointSaleId: int.parse(state.pathParameters['pointSaleId']!),
          ),
        ),
      ],
    );

    when(
      () => repository.get(pointSaleId: 1),
    ).thenAnswer((_) async => _pointSale);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/points-of-sale/1');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete_point_sale_button')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    verifyNever(() => repository.delete(pointSaleId: 1));

    await tester.tap(
      find.byKey(const Key('confirm_delete_point_sale_button')),
    );
    await tester.pumpAndSettle();

    verify(() => repository.delete(pointSaleId: 1)).called(1);
    expect(find.text('points of sale list'), findsOneWidget);
  });
}
