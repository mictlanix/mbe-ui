import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sales_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/pos_workspace_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Shared fixtures and pump helper for the POS widget tests. Kept in one
/// place so a change to `Sale`'s required fields lands once, not in four
/// test files.
class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

Sale testSale({
  int id = 42,
  int? serial,
  SaleStatus status = SaleStatus.draft,
  PaymentTerms paymentTerms = PaymentTerms.immediate,
  String total = '116.00',
  String balance = '116.00',
  List<SaleLine> lines = const [],
  int? shipTo,
  int pointSale = 3,
}) => Sale(
  id: id,
  serial: serial,
  facility: 9,
  pointSale: pointSale,
  salesperson: 100,
  customer: 7,
  customerName: 'Público en general',
  // Null by default: a counter sale, which is what most fixtures want.
  // Pass a delivery address to make it a delivery sale (FR-057).
  shipTo: shipTo,
  paymentTerms: paymentTerms,
  currency: Currency.mxn,
  exchangeRate: '1',
  promiseDate: DateTime(2026, 8, 5),
  status: status,
  lines: lines,
  subtotal: '100.00',
  taxTotal: '16.00',
  total: total,
  balance: balance,
);

SaleLine testLine({
  int id = 5,
  String quantity = '2',
  String price = '50.00',
  String discountRate = '0',
  String taxRate = '0.16',
  int? warehouse = 3,
  String? unit,
}) => SaleLine(
  id: id,
  product: 11,
  productCode: 'P-11',
  productName: 'Widget',
  unit: unit,
  quantity: quantity,
  cost: '40.00',
  price: price,
  discountRate: discountRate,
  taxRate: taxRate,
  taxIncluded: false,
  warehouse: warehouse,
  subtotal: '100.00',
  taxTotal: '16.00',
  total: '116.00',
);

/// Pumps [child] inside a localized `MaterialApp` with the POS providers
/// overridden. Returns the container so a test can read controllers back.
Future<ProviderContainer> pumpPos(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Size surface = const Size(1200, 2400),
}) async {
  // Tall by default so a step's whole content is laid out and every control
  // is built — these tests assert on enabled/disabled state, not on what
  // happens to be scrolled into view.
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        // Pinned to match `app.dart`'s own fixed `es-MX` (constitution §V) —
        // without it the test tree resolves to the first supported locale
        // and asserts against strings the app never renders.
        locale: const Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// [pumpPosRouted]'s return: the `GoRouter` (to inspect `router.state.uri.path`
/// or drive further navigation) and the `ProviderContainer` backing it (to
/// drive a provider directly — `container.read(posSaleControllerProvider
/// .notifier).ensureOpen()` — the way `pos_lazy_open_test.dart` already
/// drives a lazy-opened sale without a full product-search simulation).
typedef PosRoutedHarness = (GoRouter router, ProviderContainer container);

/// Pumps a `MaterialApp.router` wired with the three real POS routes
/// (`/sales/pos`, `/sales/pos/new`, `/sales/pos/:saleId` — mirroring
/// `app_router.dart`'s own wiring) against the real `PosSalesListScreen` /
/// `PosWorkspaceScreen`, for tests that exercise actual navigation between
/// them — the `/new` → `/sales/pos/<id>` URL rewrite, Back returning to the
/// list, a deep link to an unreachable sale — rather than a bare widget pump
/// (spec 023 research R15).
Future<PosRoutedHarness> pumpPosRouted(
  WidgetTester tester, {
  List<Override> overrides = const [],
  String initialLocation = '/sales/pos',
  Size surface = const Size(1200, 2400),
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/sales/pos',
        // `AppShell` always wraps a shell branch's content in its own
        // `Scaffold` (app_shell.dart) — reproduced here since this route
        // builds the bare screen with nothing else providing one.
        builder: (context, state) => Scaffold(
          body: PosSalesListScreen(query: ListQuery.fromUri(state.uri)),
        ),
      ),
      GoRoute(
        path: '/sales/pos/new',
        builder: (context, state) => const PosWorkspaceScreen(),
      ),
      GoRoute(
        path: '/sales/pos/:saleId',
        builder: (context, state) =>
            PosWorkspaceScreen(saleId: int.parse(state.pathParameters['saleId']!)),
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
  return (router, container);
}

/// A phone, for the US5 compact-tier tests — below `LayoutBreakpoints.compact`
/// (600) so every `isCompact` branch is the one under test.
const phoneSurface = Size(390, 844);

/// SC-007: at phone width nothing on the POS may ask the cashier to scroll
/// sideways. Single-line text fields are exempt — their `EditableText` scrolls
/// horizontally by construction to keep the caret visible, which is not the
/// page scrolling and is not what SC-007 is about.
void expectNoHorizontalScroll(WidgetTester tester) {
  final horizontal = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable &&
        (widget.axisDirection == AxisDirection.left ||
            widget.axisDirection == AxisDirection.right),
  );
  final insideTextFields = find.descendant(
    of: find.byType(EditableText),
    matching: horizontal,
  );
  expect(
    horizontal.evaluate().length,
    insideTextFields.evaluate().length,
    reason: 'every horizontal scrollable should belong to a text field',
  );
}

/// A row for the sales list / open-sales selector (spec 023 data-model §1).
/// `balance` defaults to `0` for a paid sale and to [total] otherwise, since
/// that is what every real sale answers with.
OpenSale testOpenSale({
  int id = 42,
  SaleStatus status = SaleStatus.draft,
  int? serial,
  String customerName = 'Público en general',
  String total = '116.00',
  String? balance,
  DateTime? date,
}) => OpenSale(
  id: id,
  serial: serial,
  customerName: customerName,
  total: total,
  balance: balance ?? (status == SaleStatus.paid ? '0' : total),
  status: status,
  date: date ?? DateTime(2026, 8, 5, 10),
);

/// A page of [testOpenSale] rows, `total` defaulting to the item count — for
/// the common case of a fixture page that isn't testing pagination itself.
OpenSalePage testSalesPage(List<OpenSale> items, {int? total}) =>
    OpenSalePage(items: items, total: total ?? items.length);

/// Stubs `SalesOrderRepository.listSales` to answer [page] for any query —
/// the `pos_sales_list_screen_test.dart` default; a test asserting on the
/// *arguments* `listSales` was called with should stub it directly instead.
void stubListSales(MockSalesOrderRepository repository, {required OpenSalePage page}) {
  when(
    () => repository.listSales(
      pointSale: any(named: 'pointSale'),
      status: any(named: 'status'),
      dateFrom: any(named: 'dateFrom'),
      dateTo: any(named: 'dateTo'),
      search: any(named: 'search'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => page);
}

Override salesOrderOverride(SalesOrderRepository repository) =>
    salesOrderRepositoryProvider.overrideWithValue(repository);

Override customerPaymentOverride(CustomerPaymentRepository repository) =>
    customerPaymentRepositoryProvider.overrideWithValue(repository);

Override warehouseOverride(WarehouseRepository repository) =>
    warehouseRepositoryProvider.overrideWithValue(repository);
