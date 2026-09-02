// Repo-wide invariant (017-ui-consistency-filters T032, SC-001): after the
// US1 conversion, no record detail screen may render a non-empty
// `AppBar.actions` — the read-only-to-edit toggle and every other record
// action now live exclusively in `RecordFormActions`, in the form body.
//
// Every screen is pumped in create mode (no id) as an administrator, which
// short-circuits every RBAC check to full access (AccessControlService),
// so no per-object privilege needs to be enumerated. Secondary FK-picker
// repositories are overridden with bare, unstubbed mocks — their methods
// are only invoked lazily via user interaction (typing into a
// CatalogEntityPicker) or already tolerate an unstubbed/error result
// (e.g. `allLabelsProvider` degrades to an empty list) — never during the
// initial pump this test performs.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_detail_screen.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/address_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/product_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuer_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';


class MockLabelRepository extends Mock implements LabelRepository {}

class MockSupplierRepository extends Mock implements SupplierRepository {}


class MockEmployeeRepository extends Mock implements EmployeeRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockSatCatalogRepository extends Mock implements SatCatalogRepository {}

class MockTaxpayerIssuerRepository extends Mock
    implements TaxpayerIssuerRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockUserRepository extends Mock implements UserRepository {}

const _admin = User(
  userId: 'admin',
  email: 'admin@example.com',
  administrator: true,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

AccessControlService _adminAccess() =>
    AccessControlService(AuthState.authenticated(token: 't', user: _admin));

void main() {
  Future<void> expectEmptyAppBarActions(
    WidgetTester tester,
    Widget screen,
    List<Override> overrides,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          accessControlProvider.overrideWithValue(_adminAccess()),
          ...overrides,
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: screen),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(
      appBar.actions,
      anyOf(isNull, isEmpty),
      reason: '${screen.runtimeType} renders a non-empty AppBar.actions',
    );
  }

  group(
    'no record detail screen renders a non-empty AppBar.actions (SC-001)',
    () {
      testWidgets('FacilityDetailScreen', (tester) async {
        await expectEmptyAppBarActions(tester, const FacilityDetailScreen(), [
          facilityRepositoryProvider.overrideWithValue(
            MockFacilityRepository(),
          ),
          addressRepositoryProvider.overrideWithValue(MockAddressRepository()),
          satCatalogRepositoryProvider.overrideWithValue(
            MockSatCatalogRepository(),
          ),
          taxpayerIssuerRepositoryProvider.overrideWithValue(
            MockTaxpayerIssuerRepository(),
          ),
        ]);
      });

      testWidgets('ProductDetailScreen', (tester) async {
        await expectEmptyAppBarActions(tester, const ProductDetailScreen(), [
          productRepositoryProvider.overrideWithValue(MockProductRepository()),
          labelRepositoryProvider.overrideWithValue(MockLabelRepository()),
          satCatalogRepositoryProvider.overrideWithValue(
            MockSatCatalogRepository(),
          ),
          supplierRepositoryProvider.overrideWithValue(
            MockSupplierRepository(),
          ),
        ]);
      });

      testWidgets('TaxpayerIssuerDetailScreen', (tester) async {
        await expectEmptyAppBarActions(
          tester,
          const TaxpayerIssuerDetailScreen(),
          [
            taxpayerIssuerRepositoryProvider.overrideWithValue(
              MockTaxpayerIssuerRepository(),
            ),
            satCatalogRepositoryProvider.overrideWithValue(
              MockSatCatalogRepository(),
            ),
          ],
        );
      });

      testWidgets('UserDetailScreen', (tester) async {
        await expectEmptyAppBarActions(tester, const UserDetailScreen(), [
          userRepositoryProvider.overrideWithValue(MockUserRepository()),
          employeeRepositoryProvider.overrideWithValue(
            MockEmployeeRepository(),
          ),
        ]);
      });
    },
  );

  // pricing_screen_test.dart's `edit_price_button_1` is a pricing-table row
  // action inside a per-product price list, not a record's own edit toggle
  // — it is intentionally NOT covered here (contracts/record-form-actions.md
  // §6).
}
