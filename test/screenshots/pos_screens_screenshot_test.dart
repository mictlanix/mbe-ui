import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/capture/fulfillment_mode_selector.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sales_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../golden/golden_harness.dart';
import '../widget/features/sales/pos_test_harness.dart';

/// Not a regression test — a **screenshot generator**. Renders the spec 023
/// screens with the real app theme, real fonts and real widgets at the four
/// widths `specs/023-pos-ux-improvements/quickstart.md` asks a human to check
/// (T064), writing PNGs to `shots/`. Run with:
///
/// ```
/// flutter test test/screenshots/ --update-goldens
/// ```
///
/// It exists because T064's manual pass needs a signed-in session against a
/// live backend; this renders the same surfaces without one. It asserts
/// nothing about pixels beyond "this is what it looks like", so a legitimate
/// design change just regenerates the images rather than failing a build.
class MockCashSessionRepository extends Mock implements CashSessionRepository {}

class MockCustomerRepo extends Mock implements CustomerRepository {}

class MockPointSaleRepo extends Mock implements PointSaleRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

const _brand = BrandConfig(displayName: 'Mictlanix Business Essentials');

/// A cashier with the register assigned and the privileges the screens gate
/// on. Overriding auth also keeps the real `AuthInterceptor` (and its
/// secure-storage plugin, absent in a test binary) off the path entirely.
Override authOverride() => authNotifierProvider.overrideWith(
  () => _FixedAuthNotifier(
    AuthState.authenticated(
      token: 't',
      user: User(
        userId: 'cajero1',
        email: 'cajero@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        settings: const UserSettings(pointSaleId: 3),
        privileges: const [
          Privilege(systemObject: SystemObject.salesOrders, rawValue: 4),
          Privilege(systemObject: SystemObject.pos, rawValue: 1),
          Privilege(systemObject: SystemObject.customers, rawValue: 1),
        ],
      ),
    ),
  ),
);

SaleLine _line({
  required int id,
  required String code,
  required String name,
  String? unit,
  String quantity = '1',
  String price = '100.00',
  String discountRate = '0',
  required String subtotal,
  required String taxTotal,
  required String total,
}) => SaleLine(
  id: id,
  product: id,
  productCode: code,
  productName: name,
  unit: unit,
  quantity: quantity,
  cost: '80.00',
  price: price,
  discountRate: discountRate,
  taxRate: '0.16',
  // The live catalog prices tax-inclusive, so the row's price and its total
  // read the same for a quantity of one.
  taxIncluded: true,
  warehouse: 12,
  subtotal: subtotal,
  taxTotal: taxTotal,
  total: total,
);

/// Real rows from the live dev backend's own catalog (point of sale 18,
/// `PV ZUMPANGO (01)`, warehouse 12), pulled via `GET /sales-orders` and
/// `/sales-orders/product-lookup` rather than invented — long names that
/// actually ellipsize, tax-inclusive prices, and `unit: null` because
/// mbe-api#145 has not landed. Amounts are consistent with the
/// `discount = (subtotal + tax) − total` derivation FR-047 uses, so the
/// footer shows what the server would really produce (no discounts on this
/// register's sales, so the Descuentos group is correctly absent — the
/// discount case is covered by `sale_totals_bar_test.dart` instead).
final _lines = [
  _line(
    id: 1071503,
    code: '30733',
    name: 'CLAVO ESTANDAR SIN CABEZA 2 1/2" 30733',
    quantity: '3',
    price: '67.00',
    subtotal: '173.28',
    taxTotal: '27.72',
    total: '201.00',
  ),
  _line(
    id: 1071504,
    code: '7501206631782',
    name: 'CLAVOS PARA CLAVADORA NEUMATICA TRUPER 2" 18269',
    quantity: '1',
    price: '279.00',
    subtotal: '240.52',
    taxTotal: '38.48',
    total: '279.00',
  ),
  _line(
    id: 1071501,
    code: 'CLASTDCC4MS',
    name: 'CLAVO ESTANDAR CON CABEZA 4" (MS)',
    quantity: '4',
    price: '32.00',
    subtotal: '110.34',
    taxTotal: '17.66',
    total: '128.00',
  ),
];

/// Full-bleed variant of `pumpGoldenScenario`: the screens under test *are*
/// the page, so nothing centres or shrink-wraps them.
///
/// Defaults `sharedPreferencesProvider` to an in-memory instance, matching
/// `golden_harness.dart`'s `pumpGoldenScenario` fix (spec 028) —
/// `formattersProvider` reads through `resolvedLocaleProvider`, which needs
/// one. A caller-supplied override for the same provider still wins
/// (Riverpod resolves duplicate overrides last-one-wins).
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  required Size size,
  Brightness brightness = Brightness.dark,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.view.platformDispatcher.textScaleFactorTestValue = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.platformDispatcher.clearTextScaleFactorTestValue);

  final appTheme = AppTheme.of(_brand);
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ...overrides,
      ],
      child: MaterialApp(
        theme: brightness == Brightness.light ? appTheme.light : appTheme.dark,
        debugShowCheckedModeBanner: false,
        locale: const Locale('es', 'MX'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, widget) => Theme(
          data: DesignTheme.forTier(
            Theme.of(context),
            LayoutBreakpoints.tierOfContext(context),
          ),
          child: widget!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> shoot(WidgetTester tester, String name) => expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('shots/$name.png'),
);

void main() {
  setUpAll(loadGoldenFonts);

  late MockSalesOrderRepository salesOrders;
  late MockCashSessionRepository cashSessions;
  late MockWarehouseRepository warehouses;
  late MockCustomerRepo customers;
  late MockCustomerPaymentRepository payments;
  late MockPointSaleRepo pointSales;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    cashSessions = MockCashSessionRepository();
    warehouses = MockWarehouseRepository();
    customers = MockCustomerRepo();
    payments = MockCustomerPaymentRepository();
    pointSales = MockPointSaleRepo();

    // `defaultWarehouseControllerProvider` (the warehouse a new line defaults
    // to, FR-024) resolves through this — unstubbed it reaches the real dio
    // client and its secure-storage-backed auth interceptor.
    when(() => pointSales.get(pointSaleId: any(named: 'pointSaleId'))).thenAnswer(
      (_) async => const PointSale(
        pointSaleId: 18,
        facilityId: 51,
        facilityName: 'CASA MAESTRA ZUMPANGO',
        code: 'PVZU01',
        name: 'PV ZUMPANGO (01)',
        warehouseId: 12,
        warehouseName: 'ZUMPANGO 1 (Materiales)',
        status: EntityStatus.active,
      ),
    );

    for (final status in SaleStatus.values) {
      if (status == SaleStatus.cancelled) continue;
      when(
        () => salesOrders.listOpen(
          pointSale: any(named: 'pointSale'),
          status: status,
          dateFrom: any(named: 'dateFrom'),
        ),
      ).thenAnswer((_) async => const OpenSalePage(items: [], total: 0));
    }
    when(() => cashSessions.getCurrent()).thenAnswer(
      (_) async => const CurrentSession(state: SessionState.open),
    );
    when(
      () => warehouses.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const WarehouseListResult(
        items: [
          Warehouse(
            warehouseId: 12,
            code: 'CMZUAL01',
            name: 'ZUMPANGO 1 (Materiales)',
            facilityId: 51,
            facilityName: 'CASA MAESTRA ZUMPANGO',
            status: EntityStatus.active,
          ),
        ],
        total: 1,
      ),
    );
    // The register's real walk-in customer: no credit line, which is exactly
    // the case §1.3 gates `Crédito` on — the dropdown shows Contado with
    // Crédito unselectable and the reason stated.
    when(() => customers.get(customerId: any(named: 'customerId'))).thenAnswer(
      (_) async => const Customer(
        customerId: 1,
        code: 'ID00001',
        name: 'PÚBLICO EN GENERAL',
        creditLimit: '0.0000',
        creditDays: 0,
        priceList: PriceListRef(id: 1, name: 'Mostrador'),
        shipping: false,
        shippingRequiredDocument: false,
        status: EntityStatus.active,
      ),
    );
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0.00');
  });

  List<Override> captureOverrides() => [
    authOverride(),
    salesOrderOverride(salesOrders),
    warehouseOverride(warehouses),
    customerRepositoryProvider.overrideWithValue(customers),
    customerPaymentOverride(payments),
    pointSaleRepositoryProvider.overrideWithValue(pointSales),
  ];

  /// Built directly rather than through `testSale`, whose `subtotal`/`taxTotal`
  /// are pinned at 100/16 — the footer's discount derivation would then read a
  /// nonsense figure against real line amounts.
  Sale sale() => Sale(
    id: 337496,
    serial: null,
    facility: 51,
    pointSale: 18,
    salesperson: 1,
    customer: 1,
    customerName: 'PÚBLICO EN GENERAL',
    shipTo: null,
    paymentTerms: PaymentTerms.immediate,
    currency: Currency.mxn,
    exchangeRate: '1',
    promiseDate: DateTime(2026, 8, 10),
    status: SaleStatus.draft,
    lines: _lines,
    subtotal: '524.14',
    taxTotal: '83.86',
    total: '608.00',
    balance: '608.00',
  );

  group('the sales list (US1)', () {
    testWidgets('desktop, mixed row states', (tester) async {
      stubListSales(
        salesOrders,
        // The register's own recent sales, as `GET /sales-orders
        // ?point_sale=18` returns them — including the real draft still open
        // from today. One `completed`-with-balance row is added to show the
        // second Edit-eligible state, which this register happens not to
        // have right now.
        page: testSalesPage([
          testOpenSale(
            id: 337496,
            status: SaleStatus.draft,
            customerName: 'PÚBLICO EN GENERAL',
            total: '67.00',
            date: DateTime(2026, 8, 10, 5, 12),
          ),
          testOpenSale(
            id: 337497,
            serial: 19635,
            status: SaleStatus.completed,
            customerName: 'PÚBLICO EN GENERAL',
            total: '608.00',
            date: DateTime(2026, 8, 10, 4, 48),
          ),
          testOpenSale(
            id: 337495,
            serial: 19633,
            status: SaleStatus.paid,
            customerName: 'PÚBLICO EN GENERAL',
            total: '32.00',
            date: DateTime(2026, 8, 8, 13, 55),
          ),
          testOpenSale(
            id: 337494,
            serial: 19632,
            status: SaleStatus.paid,
            customerName: 'PÚBLICO EN GENERAL',
            total: '128.00',
            date: DateTime(2026, 8, 8, 13, 40),
          ),
        ]),
      );
      await pumpScreen(
        tester,
        const PosSalesListScreen(query: ListQuery()),
        size: const Size(1440, 900),
        overrides: [
          authOverride(),
          salesOrderOverride(salesOrders),
          cashSessionRepositoryProvider.overrideWithValue(cashSessions),
        ],
      );
      await shoot(tester, '01_sales_list_1440');
    });
  });

  group('the capture surface (US2–US6)', () {
    testWidgets('desktop 1440 — one row per line, footer flush', (tester) async {
      await pumpScreen(
        tester,
        CaptureStep(sale: sale()),
        size: const Size(1440, 900),
        overrides: captureOverrides(),
      );
      await shoot(tester, '02_capture_1440');
    });

    testWidgets('tablet landscape 1024 — still one row (FR-037a)', (tester) async {
      await pumpScreen(
        tester,
        CaptureStep(sale: sale()),
        size: const Size(1024, 768),
        overrides: captureOverrides(),
      );
      await shoot(tester, '03_capture_1024_tablet');
    });

    testWidgets('800 — two-row fallback', (tester) async {
      await pumpScreen(
        tester,
        CaptureStep(sale: sale()),
        size: const Size(800, 900),
        overrides: captureOverrides(),
      );
      await shoot(tester, '04_capture_800_two_row');
    });

    testWidgets('phone 390 — stacked cards, pinned footer', (tester) async {
      await pumpScreen(
        tester,
        CaptureStep(sale: sale()),
        size: const Size(390, 844),
        overrides: captureOverrides(),
      );
      await shoot(tester, '05_capture_390_phone');
    });

    testWidgets('the customer band mid-search (US3)', (tester) async {
      await pumpScreen(
        tester,
        CaptureStep(sale: sale()),
        size: const Size(1440, 900),
        overrides: captureOverrides(),
      );
      await tester.tap(find.byKey(const Key('pos_customer_search_button')));
      await tester.pumpAndSettle();
      await shoot(tester, '06_customer_band_searching');
    });

    testWidgets('the mode selector alone, first segment selected', (tester) async {
      await pumpScreen(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FulfillmentModeSelector(sale: sale(), enabled: true),
          ),
        ),
        size: const Size(600, 200),
        overrides: captureOverrides(),
      );
      await shoot(tester, '08_mode_selector');
    });

    testWidgets('light theme, desktop', (tester) async {
      await pumpScreen(
        tester,
        CaptureStep(sale: sale()),
        size: const Size(1440, 900),
        brightness: Brightness.light,
        overrides: captureOverrides(),
      );
      await shoot(tester, '07_capture_1440_light');
    });
  });
}
