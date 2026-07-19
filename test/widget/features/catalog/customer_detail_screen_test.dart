import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
import 'package:mbe_ui/features/catalog/presentation/customer_detail_screen.dart';
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
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
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
  shipping: false,
  shippingRequiredDocument: false,
  salesperson: EmployeeRef(id: 2, name: 'Jane Doe'),
  disabled: false,
);

const _existingNoSalesperson = Customer(
  customerId: 2,
  code: 'CUST-002',
  name: 'Beta LLC',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Retail'),
  shipping: false,
  shippingRequiredDocument: false,
  disabled: false,
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
            body: CustomerDetailScreen(
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
      expect(
        find.byKey(const Key('customer_disabled_switch')),
        findsNothing,
      );
    });
  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'renders the price-list and salesperson names, and the AppBar carries '
      'only the edit toggle (constitution v1.8.0)',
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

        expect(
          find.byKey(const Key('delete_customer_button')),
          findsOneWidget,
        );
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
}
