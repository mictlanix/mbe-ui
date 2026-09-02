import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_option_form.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_option_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 15),
  ],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 2),
  ],
);

final _option = PaymentMethodOption(
  paymentMethodOptionId: 1,
  facilityId: 9,
  facilityName: 'Main Store',
  warehouseId: 3,
  warehouseName: 'Main Warehouse',
  name: 'Cash tender',
  numberOfPayments: 1,
  displayOnTicket: true,
  paymentMethod: 1,
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockPaymentMethodOptionRepository repository;
  late MockFacilityRepository facilityRepository;
  late MockWarehouseRepository warehouseRepository;

  setUp(() {
    repository = MockPaymentMethodOptionRepository();
    facilityRepository = MockFacilityRepository();
    warehouseRepository = MockWarehouseRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? paymentMethodOptionId,
    bool forceReadOnly = false,
  }) async {
    if (paymentMethodOptionId != null) {
      when(
        () => repository.get(paymentMethodOptionId: paymentMethodOptionId),
      ).thenAnswer((_) async => _option);
    }

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          paymentMethodOptionRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          warehouseRepositoryProvider.overrideWithValue(warehouseRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PaymentMethodOptionForm(
              paymentMethodOptionId: paymentMethodOptionId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('create mode', () {
    testWidgets('shows an empty form with Save and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(
        find.byKey(const Key('delete_payment_method_option_button')),
        findsNothing,
      );
    });
  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'read-only view has no editable fields or delete affordance, and the '
      'edit toggle appears in the record action area — this form has no '
      'AppBar of its own at all now (spec 035)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          paymentMethodOptionId: 1,
          forceReadOnly: true,
        );

        final nameField = tester.widget<TextFormField>(
          find.byKey(const Key('name_field')),
        );
        expect(nameField.enabled, isFalse);
        expect(
          find.byKey(const Key('delete_payment_method_option_button')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('edit_payment_method_option_button')),
          findsOneWidget,
        );
        expect(find.byType(AppBar), findsNothing);
      },
    );

    testWidgets('a user without update privilege gets no edit toggle', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _readOnlyUser,
        paymentMethodOptionId: 1,
        forceReadOnly: true,
      );

      expect(
        find.byKey(const Key('edit_payment_method_option_button')),
        findsNothing,
      );
    });

    testWidgets('the optional warehouse field shows the resolved name '
        '(FR-004)', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        paymentMethodOptionId: 1,
        forceReadOnly: true,
      );

      // The read-only CatalogEntityPicker renders a disabled TextFormField —
      // read its content via the underlying EditableText's controller, since
      // TextFormField.initialValue is constructor-only (not a public field).
      final editable = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('warehouse_field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(editable.controller.text, 'Main Warehouse');
    });

    testWidgets('the payment method dropdown shows the resolved label', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        paymentMethodOptionId: 1,
        forceReadOnly: true,
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.paymentMethodCash), findsOneWidget);
    });
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _readOnlyUser,
        paymentMethodOptionId: 1,
      );

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('name_field')),
      );
      expect(nameField.enabled, isFalse);
      expect(
        find.byKey(const Key('delete_payment_method_option_button')),
        findsNothing,
      );
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a still-referenced rejection leaves the form in place',
      (tester) async {
        when(() => repository.delete(paymentMethodOptionId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Payment method option is referenced by a sale',
          ),
        );

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          paymentMethodOptionId: 1,
        );

        expect(
          find.byKey(const Key('delete_payment_method_option_button')),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const Key('delete_payment_method_option_button')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_payment_method_option_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('name_field')), findsOneWidget);
      },
    );

    testWidgets(
      'a server rejection is surfaced on the form without discarding input '
      '(FR-023-style precedent)',
      (tester) async {
        when(
          () => repository.create(
            facilityId: any(named: 'facilityId'),
            warehouseId: any(named: 'warehouseId'),
            name: any(named: 'name'),
            numberOfPayments: any(named: 'numberOfPayments'),
            displayOnTicket: any(named: 'displayOnTicket'),
            paymentMethod: any(named: 'paymentMethod'),
            commission: any(named: 'commission'),
            status: any(named: 'status'),
          ),
        ).thenThrow(
          AppError.validation([
            const FieldError(
              loc: ['name'],
              msg: 'Name already in use for this facility',
              type: 'value_error',
            ),
          ]),
        );

        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            paymentMethodOptionRepositoryProvider.overrideWithValue(
              repository,
            ),
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            warehouseRepositoryProvider.overrideWithValue(
              warehouseRepository,
            ),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: PaymentMethodOptionForm()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Selecting the facility from the Autocomplete overlay (and the
        // payment method from the dropdown) is brittle to drive through
        // their respective widgets in a test — seed both directly on the
        // controller, same as the warehouse form's facility-picker
        // precedent.
        container
            .read(paymentMethodOptionFormControllerProvider.notifier)
            .facilitySelected(9, 'Main Store');
        container
            .read(paymentMethodOptionFormControllerProvider.notifier)
            .paymentMethodChanged(1);
        await tester.enterText(
          find.byKey(const Key('name_field')),
          'Duplicate',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_button')));
        await tester.pumpAndSettle();

        expect(find.text('Duplicate'), findsOneWidget);
        expect(
          find.text('Name already in use for this facility'),
          findsOneWidget,
        );
      },
    );
  });

  group('in-panel Edit toggle (spec 035 FR-027/FR-028)', () {
    testWidgets(
      'pressing Edit on a read-only form makes it editable in place — no '
      'navigation, since there is no route to navigate to anymore',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          paymentMethodOptionId: 1,
          forceReadOnly: true,
        );

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('name_field')))
              .enabled,
          isFalse,
        );

        await tester.tap(
          find.byKey(const Key('edit_payment_method_option_button')),
        );
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('name_field')))
              .enabled,
          isTrue,
        );
        expect(find.byKey(const Key('save_button')), findsOneWidget);
      },
    );
  });

  group('isDirty (spec 035 FR-032, data-model.md §3)', () {
    testWidgets('false immediately after a create-mode form mounts', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final key = GlobalKey<PaymentMethodOptionFormPanelState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            paymentMethodOptionRepositoryProvider.overrideWithValue(
              repository,
            ),
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            warehouseRepositoryProvider.overrideWithValue(
              warehouseRepository,
            ),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PaymentMethodOptionForm(key: key)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);
    });

    testWidgets('false until loading finishes, then true after a field edit', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final key = GlobalKey<PaymentMethodOptionFormPanelState>();
      when(
        () => repository.get(paymentMethodOptionId: 1),
      ).thenAnswer((_) async => _option);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            paymentMethodOptionRepositoryProvider.overrideWithValue(
              repository,
            ),
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            warehouseRepositoryProvider.overrideWithValue(
              warehouseRepository,
            ),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PaymentMethodOptionForm(
                key: key,
                paymentMethodOptionId: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);

      await tester.enterText(find.byKey(const Key('name_field')), 'Cash');
      await tester.pump();

      expect(key.currentState!.isDirty(), isTrue);
    });
  });
}
