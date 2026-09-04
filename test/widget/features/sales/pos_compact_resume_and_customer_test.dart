import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/open_sales_selector.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

const _cashier = User(
  userId: 'cajero',
  email: 'cajero@example.com',
  administrator: true,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

Customer _customer({int id = 7}) => Customer(
  customerId: id,
  code: 'C-$id',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

OpenSale _openSale({required int id, required SaleStatus status}) => OpenSale(
  id: id,
  customerName: 'FERRETERÍA LOS PINOS DEL VALLE',
  total: '1160.00',
  balance: status == SaleStatus.paid ? '0' : '1160.00',
  status: status,
  date: DateTime(2026, 8, 5, 10),
);

/// The former `PosHeaderBand`'s selector-plus-step-indicator row, now
/// composed inline in `PosWorkspaceScreen`'s app bar title rather than a
/// standalone widget. Reimplemented here rather than exported purely for a
/// test — the same choice `step_indicator_test.dart` already made for the
/// step indicator alone; this adds the selector beside it, which is what
/// this test is actually about (do the two fit together at phone width).
class _HeaderRowStandIn extends ConsumerWidget {
  const _HeaderRowStandIn({
    required this.sale,
    required this.onSaleSelected,
    required this.onStartNew,
  });

  final Sale sale;
  final ValueChanged<OpenSale> onSaleSelected;
  final VoidCallback onStartNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final step = ref.watch(posStepControllerProvider);
    final labels = [
      l10n.posStepVenta,
      l10n.posStepCobro,
      l10n.posStepEntrega,
    ].take(step.stepCount).toList();

    return Row(
      children: [
        OpenSalesSelector(
          pointSale: sale.pointSale,
          currentId: sale.provisionalReference,
          currentSerial: sale.serial,
          onSelected: onSaleSelected,
          onStartNew: onStartNew,
        ),
        const Spacer(),
        if (LayoutBreakpoints.isCompact(context))
          Text(
            key: const Key('pos_step_progress'),
            l10n.posStepProgress(step.current.index + 1, step.stepCount),
            style: theme.textTheme.titleSmall,
          )
        else
          Row(
            key: const Key('pos_step_indicator'),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < labels.length; i++)
                Text('${i + 1}·${labels[i]}'),
            ],
          ),
      ],
    );
  }
}

/// US3 and US4 at 390 px (T105): resuming an open sale and creating a
/// customer without leaving it are both reachable on a phone, with nothing
/// pushing the page sideways (SC-007).
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockDeliveryOrderRepository deliveries;
  late MockPriceListRepository priceLists;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late MockCashSessionRepository sessions;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    deliveries = MockDeliveryOrderRepository();
    priceLists = MockPriceListRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    sessions = MockCashSessionRepository();

    when(() => sessions.getCurrent()).thenAnswer(
      (_) async => const CurrentSession(state: SessionState.open),
    );

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => []);
    when(
      () => priceLists.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const PriceListResult(
        items: [
          PriceList(
            priceListId: 2,
            name: 'Mayoreo',
          ),
        ],
        total: 1,
      ),
    );
    for (final status in SaleStatus.values) {
      when(
        () => salesOrders.listOpen(
          pointSale: any(named: 'pointSale'),
          status: status,
          dateFrom: any(named: 'dateFrom'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const OpenSalePage(items: [], total: 0),
      );
    }
  });

  List<Override> overrides() => [
    salesOrderOverride(salesOrders),
    warehouseOverride(warehouses),
    customerRepositoryProvider.overrideWithValue(customers),
    customerPaymentOverride(payments),
    priceListRepositoryProvider.overrideWithValue(priceLists),
    deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
    // The header band embeds `PosGateScreen`, which draws nothing for a
    // healthy session but still has to ask.
    cashSessionRepositoryProvider.overrideWithValue(sessions),
    accessControlProvider.overrideWithValue(
      AccessControlService(
        const AuthState.authenticated(token: 't', user: _cashier),
      ),
    ),
  ];

  group('resuming an open sale on a phone (US3)', () {
    testWidgets('the header band collapses the stepper to "Paso N de M" so '
        'the selector still fits beside it', (tester) async {
      when(
        () => salesOrders.listOpen(
          pointSale: any(named: 'pointSale'),
          status: SaleStatus.draft,
          dateFrom: any(named: 'dateFrom'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => OpenSalePage(
          items: [_openSale(id: 1, status: SaleStatus.draft)],
          total: 1,
        ),
      );

      await pumpPos(
        tester,
        _HeaderRowStandIn(
          sale: testSale(),
          onSaleSelected: (_) {},
          onStartNew: () {},
        ),
        surface: phoneSurface,
        overrides: overrides(),
      );

      expect(find.byKey(const Key('pos_step_progress')), findsOneWidget);
      expect(find.text(l10n.posStepProgress(1, 2)), findsOneWidget);
      expect(find.byKey(const Key('pos_step_indicator')), findsNothing);
      expectNoHorizontalScroll(tester);
    });

    testWidgets('the open-sales menu opens and each sale is selectable, with '
        'no sideways scrolling', (tester) async {
      when(
        () => salesOrders.listOpen(
          pointSale: any(named: 'pointSale'),
          status: SaleStatus.draft,
          dateFrom: any(named: 'dateFrom'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => OpenSalePage(
          items: [_openSale(id: 1, status: SaleStatus.draft)],
          total: 1,
        ),
      );
      OpenSale? chosen;

      await pumpPos(
        tester,
        OpenSalesSelector(
          pointSale: 3,
          currentId: 337471,
          currentSerial: 282127,
          onSelected: (sale) => chosen = sale,
          onStartNew: () {},
        ),
        surface: phoneSurface,
        overrides: overrides(),
      );

      // The chip keeps both identifiers but drops the open-sales count here —
      // that count would cost width the step indicator needs, and the menu
      // this chip opens repeats it anyway.
      expect(
        find.text(
          '${l10n.posOpenSaleId(337471)} · ${l10n.posOpenSaleSerial(282127)}',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('open_sales_selector')));
      await tester.pumpAndSettle();
      expectNoHorizontalScroll(tester);

      await tester.tap(find.byKey(const Key('open_sale_1')));
      await tester.pumpAndSettle();
      expect(chosen?.id, 1);
    });
  });

  group('creating a customer inline on a phone (US4)', () {
    testWidgets('the form opens full-screen and every field is reachable by '
        'scrolling down', (tester) async {
      final sale = testSale(lines: [testLine()]);
      when(() => salesOrders.open()).thenAnswer((_) async => sale);

      final container = await pumpPos(
        tester,
        Consumer(
          builder: (context, ref, _) => ref
              .watch(posSaleControllerProvider)
              .when(
                data: (value) => CaptureStep(sale: value),
                loading: () => const SizedBox.shrink(),
                error: (error, _) => Text('$error'),
              ),
        ),
        surface: phoneSurface,
        overrides: overrides(),
      );
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pos_new_customer_code')), findsOneWidget);
      expect(find.byKey(const Key('pos_new_customer_name')), findsOneWidget);
      expectNoHorizontalScroll(tester);

      await tester.dragUntilVisible(
        find.byKey(const Key('pos_new_customer_save')),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pos_new_customer_save')), findsOneWidget);
      expectNoHorizontalScroll(tester);
    });

    testWidgets('backing out of the form returns to the sale with its lines '
        'intact — nothing was discarded to make room', (tester) async {
      final sale = testSale(lines: [testLine()]);
      when(() => salesOrders.open()).thenAnswer((_) async => sale);

      final container = await pumpPos(
        tester,
        Consumer(
          builder: (context, ref, _) => ref
              .watch(posSaleControllerProvider)
              .when(
                data: (value) => CaptureStep(sale: value),
                loading: () => const SizedBox.shrink(),
                error: (error, _) => Text('$error'),
              ),
        ),
        surface: phoneSurface,
        overrides: overrides(),
      );
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pos_new_customer_close')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pos_new_customer_code')), findsNothing);
      // Scoped to the footer: the single line's own total is the same
      // $116.00 as the sale's (`testLine`'s default), so an unscoped finder
      // matches both as soon as the line card is laid out.
      expect(
        find.descendant(
          of: find.byKey(const Key('pos_totals_footer')),
          matching: find.text(r'$116.00'),
        ),
        findsOneWidget,
      );
      verifyNever(
        () => salesOrders.updateHeader(
          saleId: any(named: 'saleId'),
          customer: any(named: 'customer'),
        ),
      );
      expectNoHorizontalScroll(tester);
    });
  });
}
