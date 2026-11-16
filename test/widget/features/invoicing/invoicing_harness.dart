import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/files/file_saver.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_batch_repository.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_screen.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';
import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';

class MockFiscalDocuments extends Mock implements FiscalDocumentRepository {}

class MockSalesOrders extends Mock implements SalesOrderRepository {}

class MockCustomers extends Mock implements CustomerRepository {}

class MockProducts extends Mock implements ProductRepository {}

class MockSatCatalogs extends Mock implements SatCatalogRepository {}

class MockTaxpayerBatches extends Mock implements TaxpayerBatchRepository {}

class MockFacilities extends Mock implements FacilityRepository {}

class FakeFileSaver implements FileSaver {
  @override
  Future<bool> save({required bytes, required String filename}) async => true;
}

/// The detail screen of one fiscal document with every repository mocked, for
/// the editor widget tests (spec 066 US3–US6).
class InvoiceHarness {
  final documents = MockFiscalDocuments();
  final orders = MockSalesOrders();
  final customers = MockCustomers();
  final products = MockProducts();
  final sat = MockSatCatalogs();
  final batches = MockTaxpayerBatches();
  final facilities = MockFacilities();

  /// The access an editor has by default: read and update on FiscalDocuments,
  /// create on StandaloneFiscalDocuments, and read on SalesOrders.
  static Override access({
    int fiscalDocuments = 6,
    bool standalone = true,
    bool ordersRead = true,
    bool taxpayersRead = false,
    bool issuedLocationUpdate = false,
    bool customersRead = true,
    bool administrator = false,
  }) => accessControlProvider.overrideWithValue(
    AccessControlService(
      AuthState.authenticated(
        token: 't',
        user: User(
          userId: 'd',
          email: 'd@example.com',
          administrator: administrator,
          status: EntityStatus.active,
          sessionVersion: 1,
          privileges: [
            if (fiscalDocuments != 0)
              Privilege(
                systemObject: SystemObject.fiscalDocuments,
                rawValue: fiscalDocuments,
              ),
            if (standalone)
              const Privilege(
                systemObject: SystemObject.standaloneFiscalDocuments,
                rawValue: 1,
              ),
            if (ordersRead)
              const Privilege(
                systemObject: SystemObject.salesOrders,
                rawValue: 2,
              ),
            if (taxpayersRead)
              const Privilege(
                systemObject: SystemObject.taxpayers,
                rawValue: 2,
              ),
            if (issuedLocationUpdate)
              const Privilege(
                systemObject: SystemObject.issuedLocationId,
                rawValue: 4,
              ),
            if (customersRead)
              const Privilege(
                systemObject: SystemObject.customers,
                rawValue: 2,
              ),
          ],
        ),
      ),
    ),
  );

  Future<void> pump(
    WidgetTester tester, {
    FiscalDocument? document,
    Override? who,
    Size surface = const Size(1400, 1000),
  }) async {
    final current = document ?? aDocument();
    when(() => documents.getById(any())).thenAnswer((_) async => current);
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        who ?? access(),
        fiscalDocumentRepositoryProvider.overrideWithValue(documents),
        salesOrderRepositoryProvider.overrideWithValue(orders),
        customerRepositoryProvider.overrideWithValue(customers),
        productRepositoryProvider.overrideWithValue(products),
        satCatalogRepositoryProvider.overrideWithValue(sat),
        taxpayerBatchRepositoryProvider.overrideWithValue(batches),
        facilityRepositoryProvider.overrideWithValue(facilities),
        fileSaverProvider.overrideWithValue(FakeFileSaver()),
        documentSourceProvider.overrideWithValue(FakeDocumentSource()),
        documentOutputProvider.overrideWithValue(FakeDocumentOutput()),
        inputDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
        customerDisplayNameProvider.overrideWith(
          (ref, id) async => 'Cliente $id',
        ),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => 'Sucursal $id',
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/invoicing/fiscal-documents/${current.id}',
      routes: [
        GoRoute(
          path: '/invoicing/fiscal-documents',
          builder: (_, _) => const Scaffold(body: Text('list')),
        ),
        GoRoute(
          path: '/invoicing/fiscal-documents/:id',
          builder: (_, s) => FiscalDocumentDetailScreen(
            fiscalDocumentId: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

Finder key(String k) => find.byKey(Key(k));
