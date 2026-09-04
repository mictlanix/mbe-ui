import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 15)],
);

const _existingWithSalesperson = Customer(
  customerId: 1,
  code: 'CUST-001',
  name: 'Acme Corp',
  creditLimit: '1000.50',
  creditDays: 30,
  priceList: PriceListRef(id: 1, name: 'Retail'),
  salesperson: EmployeeRef(id: 2, name: 'Jane Doe'),
  status: EntityStatus.active,
);

const _existingNoSalesperson = Customer(
  customerId: 2,
  code: 'CUST-002',
  name: 'Beta LLC',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Retail'),
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockCustomerRepository repository;
  late MockPriceListRepository priceListRepository;
  late MockEmployeeRepository employeeRepository;

  setUp(() {
    repository = MockCustomerRepository();
    priceListRepository = MockPriceListRepository();
    employeeRepository = MockEmployeeRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? customerId,
    Customer existing = _existingWithSalesperson,
    bool forceReadOnly = false,
  }) async {
    if (customerId != null) {
      when(
        () => repository.get(customerId: customerId),
      ).thenAnswer((_) async => existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerRepositoryProvider.overrideWithValue(repository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomerForm(
              customerId: customerId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('create mode', () {
    testWidgets('shows an empty form with Save and no Delete', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('code_field')), findsOneWidget);
      expect(find.byKey(const Key('price_list_field')), findsOneWidget);
      expect(find.byKey(const Key('salesperson_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_customer_button')), findsNothing);
      // Create mode has no customer loaded yet, so the disabled toggle
      // (edit-only) must not render.
      expect(find.byKey(const Key('customer_disabled_switch')), findsNothing);
    });

    // spec 036 FR-013: the two shipping toggles are gone entirely.
    testWidgets('renders no shipping-related toggle', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('shipping_switch')), findsNothing);
      expect(
        find.byKey(const Key('shipping_required_document_switch')),
        findsNothing,
      );
    });

    // spec 036 FR-012: `code` sits immediately after `credit days`, not at
    // the top of the form.
    testWidgets('places code_field after credit_days_field', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      final creditDaysTop = tester
          .getTopLeft(find.byKey(const Key('credit_days_field')))
          .dy;
      final codeTop = tester.getTopLeft(find.byKey(const Key('code_field'))).dy;
      expect(
        codeTop,
        greaterThanOrEqualTo(creditDaysTop),
        reason: 'code_field must not render above credit_days_field',
      );
    });

  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'renders the price-list and salesperson names, with the edit toggle '
      'in the record action area — this form has no AppBar of its own at '
      'all now (spec 035)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          customerId: 1,
          forceReadOnly: true,
        );

        final priceListField = tester.widget<TextFormField>(
          find.descendant(
            of: find.byKey(const Key('price_list_field')),
            matching: find.byType(TextFormField),
          ),
        );
        expect(priceListField.initialValue, 'Retail');
        final salespersonField = tester.widget<TextFormField>(
          find.descendant(
            of: find.byKey(const Key('salesperson_field')),
            matching: find.byType(TextFormField),
          ),
        );
        expect(salespersonField.initialValue, 'Jane Doe');
        expect(find.byKey(const Key('save_button')), findsNothing);
        expect(find.byKey(const Key('delete_customer_button')), findsNothing);
        expect(find.byKey(const Key('edit_customer_button')), findsOneWidget);

        expect(find.byType(AppBar), findsNothing);
      },
    );

    testWidgets(
      'a customer with no salesperson shows the "none assigned" fallback '
      '(FR-021)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          customerId: 2,
          existing: _existingNoSalesperson,
          forceReadOnly: true,
        );

        final salespersonField = tester.widget<TextFormField>(
          find.descendant(
            of: find.byKey(const Key('salesperson_field')),
            matching: find.byType(TextFormField),
          ),
        );
        expect(salespersonField.initialValue, 'None assigned');
      },
    );
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, customerId: 1);

      final codeField = tester.widget<TextFormField>(
        find.byKey(const Key('code_field')),
      );
      expect(codeField.enabled, isFalse);
      expect(find.byKey(const Key('delete_customer_button')), findsNothing);
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a server rejection leaves the form in place',
      (tester) async {
        when(() => repository.delete(customerId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Customer has existing sales orders',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, customerId: 1);

        expect(find.byKey(const Key('delete_customer_button')), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const Key('delete_customer_button')),
        );
        await tester.tap(find.byKey(const Key('delete_customer_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_customer_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('code_field')), findsOneWidget);
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
          customerId: 1,
          forceReadOnly: true,
        );

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('code_field')))
              .enabled,
          isFalse,
        );

        await tester.tap(find.byKey(const Key('edit_customer_button')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('code_field')))
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
      final key = GlobalKey<CustomerFormPanelState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerRepositoryProvider.overrideWithValue(repository),
            priceListRepositoryProvider.overrideWithValue(
              priceListRepository,
            ),
            employeeRepositoryProvider.overrideWithValue(employeeRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CustomerForm(key: key)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);
    });

    testWidgets('false until loading finishes, then true after a field edit', (
      tester,
    ) async {
      final key = GlobalKey<CustomerFormPanelState>();
      when(
        () => repository.get(customerId: 1),
      ).thenAnswer((_) async => _existingWithSalesperson);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerRepositoryProvider.overrideWithValue(repository),
            priceListRepositoryProvider.overrideWithValue(
              priceListRepository,
            ),
            employeeRepositoryProvider.overrideWithValue(employeeRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CustomerForm(key: key, customerId: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);

      await tester.enterText(find.byKey(const Key('code_field')), 'CUST-999');
      await tester.pump();

      expect(key.currentState!.isDirty(), isTrue);
    });
  });
}
