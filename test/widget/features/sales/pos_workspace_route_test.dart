import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/app_navigation.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

const _registerPointSale = 3;

Customer _customer({int id = 7}) => Customer(
  customerId: id,
  code: 'C-$id',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// spec 023 contracts/pos-workspace.md §1, §6 — routing, the `/new` → real-id
/// URL rewrite, the unreachable-sale panel, and the Back button's
/// discard-if-empty behaviour.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late MockCashSessionRepository cashSessions;
  late MockPointSaleRepository pointSales;
  late MockPaymentMethodOptionRepository paymentMethodOptions;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    cashSessions = MockCashSessionRepository();
    pointSales = MockPointSaleRepository();
    paymentMethodOptions = MockPaymentMethodOptionRepository();

    when(() => cashSessions.getCurrent()).thenAnswer(
      (_) async => const CurrentSession(state: SessionState.open),
    );
    when(() => customers.get(customerId: any(named: 'customerId')))
        .thenAnswer((_) async => _customer());
    when(() => payments.outstandingBalanceFor(customerId: any(named: 'customerId')))
        .thenAnswer((_) async => '0');
    when(
      () => paymentMethodOptions.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const PaymentMethodOptionPage(items: [], total: 0));
    when(() => pointSales.get(pointSaleId: any(named: 'pointSaleId'))).thenAnswer(
      (_) async => const PointSale(
        pointSaleId: _registerPointSale,
        facilityId: 9,
        facilityName: 'Matriz',
        code: 'PS-1',
        name: 'Caja 1',
        warehouseId: 1,
        warehouseName: 'Principal',
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
  });

  /// [privileges] is empty by default — these tests are about routing, not
  /// RBAC, and every screen under test renders without one. The list's own
  /// "Nueva venta" action is the exception: it is absent without `pos`
  /// create, so the test that drives it asks for that privilege explicitly.
  List<Override> overrides({
    int? registerPointSaleId = _registerPointSale,
    List<Privilege> privileges = const [],
  }) => [
    authNotifierProvider.overrideWith(
      () => _FixedAuthNotifier(
        AuthState.authenticated(
          token: 't',
          user: User(
            userId: 'cashier-1',
            email: 'cashier@example.com',
            administrator: false,
            status: EntityStatus.active,
            sessionVersion: 1,
            settings: registerPointSaleId == null
                ? null
                : UserSettings(pointSaleId: registerPointSaleId),
            privileges: privileges,
          ),
        ),
      ),
    ),
    salesOrderOverride(salesOrders),
    warehouseOverride(warehouses),
    customerRepositoryProvider.overrideWithValue(customers),
    customerPaymentOverride(payments),
    cashSessionRepositoryProvider.overrideWithValue(cashSessions),
    pointSaleRepositoryProvider.overrideWithValue(pointSales),
    paymentMethodOptionRepositoryProvider.overrideWithValue(paymentMethodOptions),
  ];

  group('/sales/pos/new — nothing is created until the first action', () {
    testWidgets('mounts with no sale and calls open() zero times', (
      tester,
    ) async {
      final (router, _) = await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/new',
        overrides: overrides(),
      );

      verifyNever(() => salesOrders.open());
      expect(router.state.uri.path, '/sales/pos/new');
    });

    testWidgets(
      'the first action opens the sale and rewrites the URL to /sales/pos/<id>',
      (tester) async {
        when(() => salesOrders.open()).thenAnswer((_) async => testSale(id: 99));

        final (router, container) = await pumpPosRouted(
          tester,
          initialLocation: '/sales/pos/new',
          overrides: overrides(),
        );

        await container.read(posSaleControllerProvider.notifier).ensureOpen();
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/sales/pos/99');
        verify(() => salesOrders.open()).called(1);
      },
    );
  });

  group('/sales/pos/:saleId — loads the existing sale, never opens a new one', () {
    testWidgets('calls getById with that id, and never open()', (tester) async {
      when(() => salesOrders.getById(saleId: 42))
          .thenAnswer((_) async => testSale(id: 42));

      final (router, _) = await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/42',
        overrides: overrides(),
      );

      expect(router.state.uri.path, '/sales/pos/42');
      verify(() => salesOrders.getById(saleId: 42)).called(1);
      verifyNever(() => salesOrders.open());
    });
  });

  group('an unreachable sale (contracts/pos-workspace.md §1.2)', () {
    testWidgets('an unknown sale (404) renders the unreachable panel, opening no sale', (
      tester,
    ) async {
      when(() => salesOrders.getById(saleId: 999))
          .thenThrow(const AppError.notFound());

      await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/999',
        overrides: overrides(),
      );

      expect(find.byKey(const Key('pos_sale_unreachable')), findsOneWidget);
      verifyNever(() => salesOrders.open());
    });

    testWidgets('a cancelled sale renders the unreachable panel', (tester) async {
      when(() => salesOrders.getById(saleId: 5))
          .thenAnswer((_) async => testSale(id: 5, status: SaleStatus.cancelled));

      await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/5',
        overrides: overrides(),
      );

      expect(find.byKey(const Key('pos_sale_unreachable')), findsOneWidget);
    });

    testWidgets('a sale belonging to another register renders the unreachable panel', (
      tester,
    ) async {
      when(() => salesOrders.getById(saleId: 6)).thenAnswer(
        (_) async => testSale(id: 6, pointSale: 999),
      );

      await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/6',
        overrides: overrides(registerPointSaleId: _registerPointSale),
      );

      expect(find.byKey(const Key('pos_sale_unreachable')), findsOneWidget);
    });
  });

  group('Back discards an empty draft (contracts/pos-workspace.md §6)', () {
    testWidgets('cancels the empty draft, then returns to the list', (
      tester,
    ) async {
      when(() => salesOrders.open())
          .thenAnswer((_) async => testSale(id: 77, lines: const []));
      when(() => salesOrders.cancel(saleId: 77)).thenAnswer((_) async {});
      when(
        () => salesOrders.listSales(
          pointSale: any(named: 'pointSale'),
          status: any(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const OpenSalePage(items: [], total: 0));

      final (router, container) = await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos',
        overrides: overrides(),
      );

      router.push('/sales/pos/new');
      await tester.pumpAndSettle();

      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/sales/pos/77');

      await tester.tap(find.byKey(const Key('pos_workspace_back')));
      await tester.pumpAndSettle();

      verify(() => salesOrders.cancel(saleId: 77)).called(1);
      expect(router.state.uri.path, '/sales/pos');
    });
  });

  group('returning to the list refreshes it (FR-009)', () {
    /// The list stays mounted underneath a pushed workspace, so its providers
    /// are never disposed and re-read on the way back — every route into the
    /// workspace has to invalidate them itself once the cashier returns.
    testWidgets(
      'a sale recorded from "Nueva venta" re-queries the list on the way back',
      (tester) async {
        stubListSales(salesOrders, page: const OpenSalePage(items: [], total: 0));
        // A sale with lines: the Back path only cancels an *empty* draft, so
        // this is one that was actually recorded.
        when(() => salesOrders.open())
            .thenAnswer((_) async => testSale(id: 77, lines: [testLine()]));
        when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
            .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

        final (router, container) = await pumpPosRouted(
          tester,
          initialLocation: '/sales/pos',
          overrides: overrides(
            privileges: const [
              Privilege(systemObject: SystemObject.pos, rawValue: 1),
            ],
          ),
        );
        verify(
          () => salesOrders.listSales(
            pointSale: any(named: 'pointSale'),
            status: any(named: 'status'),
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            search: any(named: 'search'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(1);

        // The list's own primary action, not a synthetic `router.push` — the
        // button is the path that was missing the refresh.
        await tester.tap(find.byKey(const Key('pos_sales_new_sale_button')));
        await tester.pumpAndSettle();
        await container.read(posSaleControllerProvider.notifier).ensureOpen();
        await tester.pumpAndSettle();
        expect(router.state.uri.path, '/sales/pos/77');

        await tester.tap(find.byKey(const Key('pos_workspace_back')));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/sales/pos');
        verify(
          () => salesOrders.listSales(
            pointSale: any(named: 'pointSale'),
            status: any(named: 'status'),
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            search: any(named: 'search'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(1);
      },
    );
  });

  group(
    'layout: no rail, no bounded width, one footer band '
    '(contracts/pos-workspace.md §2, §3)',
    () {
      testWidgets('no AppNavigation rail is present', (tester) async {
        when(() => salesOrders.getById(saleId: 10))
            .thenAnswer((_) async => testSale(id: 10, lines: [testLine()]));
        when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
            .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

        await pumpPosRouted(
          tester,
          initialLocation: '/sales/pos/10',
          overrides: overrides(),
          surface: const Size(1440, 900),
        );

        expect(find.byType(AppNavigation), findsNothing);
        expect(find.byType(NavigationDrawer), findsNothing);
      });

      testWidgets(
        'the capture surface spans the full window width — nothing bounds '
        'or centres it',
        (tester) async {
          when(() => salesOrders.getById(saleId: 11))
              .thenAnswer((_) async => testSale(id: 11, lines: [testLine()]));
          when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
              .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

          const width = 1440.0;
          await pumpPosRouted(
            tester,
            initialLocation: '/sales/pos/11',
            overrides: overrides(),
            surface: const Size(width, 900),
          );

          final totalsBarWidth = tester.getSize(find.byType(SaleTotalsBar)).width;
          expect(
            totalsBarWidth,
            width,
            reason:
                'the footer band is a direct, unbounded child of the '
                'workspace body — it should span the same width the '
                'Scaffold itself renders at, not a narrower centred column',
          );
        },
      );

      testWidgets(
        'the primary action lives inside SaleTotalsBar — one footer band, '
        'not two',
        (tester) async {
          when(() => salesOrders.getById(saleId: 12))
              .thenAnswer((_) async => testSale(id: 12, lines: [testLine()]));
          when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
              .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));

          await pumpPosRouted(
            tester,
            initialLocation: '/sales/pos/12',
            overrides: overrides(),
            surface: const Size(1440, 900),
          );

          expect(
            find.descendant(
              of: find.byType(SaleTotalsBar),
              matching: find.byKey(const Key('pos_continue_to_payment')),
            ),
            findsOneWidget,
          );
        },
      );
    },
  );

  // Asserted against the **real** header and footer, not a stand-in: these are
  // presentation decisions on private widgets, and the only honest way to hold
  // them is through the screen that owns them.
  group('the header step track (spec 023 FR-005, mock frame 2a)', () {
    Future<void> pumpWorkspace(WidgetTester tester) async {
      when(() => salesOrders.getById(saleId: 20))
          .thenAnswer((_) async => testSale(id: 20, lines: [testLine()]));
      when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
          .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));
      await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/20',
        overrides: overrides(),
        surface: const Size(1440, 900),
      );
    }

    testWidgets('one stadium track holding a pill per step, and no chevrons '
        'between them', (tester) async {
      await pumpWorkspace(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      final track = find.byKey(const Key('pos_step_indicator'));
      expect(track, findsOneWidget);
      expect(
        tester.widget<Container>(track).decoration,
        isA<ShapeDecoration>().having(
          (d) => d.shape,
          'shape',
          isA<StadiumBorder>(),
        ),
      );

      // A counter-pickup sale is two steps (FR-005) — the third is not merely
      // unhighlighted, it is absent.
      expect(
        find.descendant(of: track, matching: find.text('1 · ${l10n.posStepVenta}')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: track, matching: find.text('2 · ${l10n.posStepCobro}')),
        findsOneWidget,
      );
      expect(find.text('3 · ${l10n.posStepEntrega}'), findsNothing);

      // The whole point of the restyle: the order is stated by the numbering,
      // not by an arrow between each pair.
      expect(
        find.descendant(of: track, matching: find.byIcon(Icons.chevron_right)),
        findsNothing,
      );
    });

    testWidgets('the current step is the filled chip — and the only one '
        'carrying an icon', (tester) async {
      await pumpWorkspace(tester);
      final theme = Theme.of(
        tester.element(find.byKey(const Key('pos_step_indicator'))),
      );

      // Venta is where a loaded draft opens, so its pill is the filled one.
      final filled = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(const Key('pos_step_indicator')),
              matching: find.byType(Container),
            ),
          )
          .where(
            (c) =>
                c.decoration is ShapeDecoration &&
                (c.decoration! as ShapeDecoration).color ==
                    theme.colorScheme.secondaryContainer,
          );
      expect(filled, hasLength(1));
      expect(
        find.descendant(
          of: find.byKey(const Key('pos_step_indicator')),
          matching: find.byIcon(Icons.edit_note),
        ),
        findsOneWidget,
      );
    });
  });

  group('the Venta pill — return-to-capture (spec 036 FR-005/FR-008, US2)', () {
    Future<ProviderContainer> pumpOnCobro(
      WidgetTester tester, {
      required int saleId,
      required List<SalePayment> payments_,
    }) async {
      when(() => salesOrders.getById(saleId: saleId))
          .thenAnswer((_) async => testSale(id: saleId, lines: [testLine()]));
      when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
          .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));
      when(() => payments.listForOrder(saleId: saleId))
          .thenAnswer((_) async => payments_);

      final (_, container) = await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/$saleId',
        overrides: overrides(),
        surface: const Size(1440, 900),
      );
      // The initial resume lands a draft counter-pickup sale on Venta
      // (asserted above) — jumped forward here the same way advancing
      // through the capture step would, without simulating that whole flow.
      container.read(posStepControllerProvider.notifier).jumpTo(PosStep.cobro);
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets(
      'a draft sale on Cobro with no payment yet exposes the pill, and it '
      'returns to Venta',
      (tester) async {
        final container = await pumpOnCobro(
          tester,
          saleId: 30,
          payments_: const [],
        );

        final pill = find.byKey(const Key('pos_step_pill_return_to_venta'));
        expect(pill, findsOneWidget);

        await tester.tap(pill);
        await tester.pumpAndSettle();

        expect(
          container.read(posStepControllerProvider).current,
          PosStep.venta,
        );
      },
    );

    testWidgets(
      'a sale with at least one non-cancelled payment does not expose the '
      'pill',
      (tester) async {
        await pumpOnCobro(
          tester,
          saleId: 31,
          payments_: [
            SalePayment(
              id: 900,
              customerPayment: 900,
              amount: '50.00',
              methodCode: 1,
              currency: Currency.mxn,
              changeAmount: '0',
              cancelled: false,
              paymentDate: DateTime(2026, 8, 20),
            ),
          ],
        );

        expect(
          find.byKey(const Key('pos_step_pill_return_to_venta')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'a sale whose only payment was cancelled still exposes the pill',
      (tester) async {
        final container = await pumpOnCobro(
          tester,
          saleId: 32,
          payments_: [
            SalePayment(
              id: 901,
              customerPayment: 901,
              amount: '50.00',
              methodCode: 1,
              currency: Currency.mxn,
              changeAmount: '0',
              cancelled: true,
              paymentDate: DateTime(2026, 8, 20),
            ),
          ],
        );

        expect(
          find.byKey(const Key('pos_step_pill_return_to_venta')),
          findsOneWidget,
        );
        // Unused beyond keeping the analyzer quiet about an unread container
        // in this particular case — the other two tests read it.
        expect(container, isNotNull);
      },
    );
  });

  group('the footer band (spec 023 contracts/capture-surface.md §5)', () {
    testWidgets('the counts are ruled off from the money, and the action names '
        'the step it moves to', (tester) async {
      when(() => salesOrders.getById(saleId: 21))
          .thenAnswer((_) async => testSale(id: 21, lines: [testLine()]));
      when(() => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100))
          .thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));
      await pumpPosRouted(
        tester,
        initialLocation: '/sales/pos/21',
        overrides: overrides(),
        surface: const Size(1440, 900),
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.byKey(const Key('pos_totals_divider')), findsOneWidget);

      final action = find.byKey(const Key('pos_continue_to_payment'));
      expect(tester.widget(action), isA<FloatingActionButton>());
      // Just the step's name and the arrow — not a sentence.
      expect(
        find.descendant(of: action, matching: find.text(l10n.posStepCobro)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: action, matching: find.byIcon(Icons.arrow_forward)),
        findsOneWidget,
      );
    });
  });
}
