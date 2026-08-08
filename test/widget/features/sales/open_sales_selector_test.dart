import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/open_sales_selector.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

OpenSale _openSale({
  required int id,
  required SaleStatus status,
  int? serial,
  String customerName = 'Acme',
  String total = '116.00',
  DateTime? date,
}) => OpenSale(
  id: id,
  serial: serial,
  customerName: customerName,
  total: total,
  balance: status == SaleStatus.paid ? '0' : total,
  status: status,
  date: date ?? DateTime(2026, 8, 5, 10),
);

Destination _destination({required String claimed}) => Destination(
  id: 900,
  fulfillmentType: FulfillmentType.delivery,
  status: DeliveryOrderStatus.draft,
  lines: [
    DestinationLine(
      id: 1,
      salesOrderDetail: 5,
      product: 11,
      productCode: 'P-11',
      productName: 'Widget',
      quantity: claimed,
    ),
  ],
);

void main() {
  late MockSalesOrderRepository salesOrders;
  late MockDeliveryOrderRepository deliveries;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    deliveries = MockDeliveryOrderRepository();
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => []);
  });

  void stubStatuses({
    List<OpenSale> draft = const [],
    List<OpenSale> completed = const [],
    List<OpenSale> paid = const [],
  }) {
    for (final entry in {
      SaleStatus.draft: draft,
      SaleStatus.completed: completed,
      SaleStatus.paid: paid,
    }.entries) {
      when(
        () => salesOrders.listOpen(
          pointSale: any(named: 'pointSale'),
          status: entry.key,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => OpenSalePage(items: entry.value, total: entry.value.length),
      );
    }
  }

  Future<void> pumpSelector(
    WidgetTester tester, {
    void Function(OpenSale)? onSelected,
  }) async {
    await pumpPos(
      tester,
      OpenSalesSelector(
        pointSale: 3,
        currentReference: '00282127',
        onSelected: onSelected ?? (_) {},
        onStartNew: () {},
      ),
      overrides: [
        salesOrderOverride(salesOrders),
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
      ],
    );
    await tester.tap(find.byKey(const Key('open_sales_selector')));
    await tester.pumpAndSettle();
  }

  group('what the selector lists (US3 scenario 1)', () {
    testWidgets('drafts and unpaid sales, with reference, customer and total', (
      tester,
    ) async {
      stubStatuses(
        draft: [_openSale(id: 1, status: SaleStatus.draft)],
        completed: [
          _openSale(id: 2, status: SaleStatus.completed, serial: 282127),
        ],
      );

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_1')), findsOneWidget);
      expect(find.byKey(const Key('open_sale_2')), findsOneWidget);
      expect(find.text('#282127'), findsOneWidget, reason: 'folio once assigned');
      expect(find.text('#1'), findsOneWidget, reason: 'id before confirmation');
      expect(find.text('Acme'), findsWidgets);
      expect(find.text(r'$116.00'), findsWidgets);
      expect(find.text(l10n.posOpenSaleDraft), findsOneWidget);
      expect(find.text(l10n.posOpenSaleUnpaid), findsOneWidget);
    });

    testWidgets('newest first', (tester) async {
      stubStatuses(
        draft: [
          _openSale(id: 1, status: SaleStatus.draft, date: DateTime(2026, 8, 5, 9)),
        ],
        completed: [
          _openSale(
            id: 2,
            status: SaleStatus.completed,
            date: DateTime(2026, 8, 5, 17),
          ),
        ],
      );

      await pumpSelector(tester);

      final newer = tester.getTopLeft(find.byKey(const Key('open_sale_2')));
      final older = tester.getTopLeft(find.byKey(const Key('open_sale_1')));
      expect(newer.dy, lessThan(older.dy));
    });

    testWidgets('an empty register says so rather than showing a blank menu', (
      tester,
    ) async {
      stubStatuses();
      await pumpSelector(tester);
      expect(find.text(l10n.posNoOpenSales), findsOneWidget);
    });
  });

  group("mbe-api's status filter is not exclusive", () {
    testWidgets('a paid sale returned by the `completed` query is listed once, '
        'not twice — duplicate keys crash the menu', (tester) async {
      // Exactly what a live backend answers: `status=completed` includes
      // everything confirmed, so a paid sale comes back from that query *and*
      // from the `paid` one.
      final settled = _openSale(id: 337446, status: SaleStatus.paid);
      stubStatuses(completed: [settled], paid: [settled]);
      when(() => salesOrders.getById(saleId: 337446)).thenAnswer(
        (_) async => testSale(
          id: 337446,
          status: SaleStatus.paid,
          lines: [testLine(id: 5, quantity: '10')],
        ),
      );
      // Nothing distributed, so it genuinely belongs in the list — once.
      when(
        () => deliveries.listForSale(salesOrder: 337446),
      ).thenAnswer((_) async => []);

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_337446')), findsOneWidget);
      expect(find.text(l10n.posOpenSaleUndelivered), findsOneWidget);
      expect(
        find.text(l10n.posOpenSaleUnpaid),
        findsNothing,
        reason: 'a paid sale owes nothing and must not read as unpaid',
      );
    });

    testWidgets('a settled counter sale leaking into the `completed` query is '
        'not listed at all', (tester) async {
      final settled = _openSale(id: 42, status: SaleStatus.paid);
      stubStatuses(completed: [settled], paid: [settled]);
      // Fully distributed: finished, so neither branch should keep it.
      when(() => salesOrders.getById(saleId: 42)).thenAnswer(
        (_) async => testSale(
          id: 42,
          status: SaleStatus.paid,
          lines: [testLine(id: 5, quantity: '10')],
        ),
      );
      when(
        () => deliveries.listForSale(salesOrder: 42),
      ).thenAnswer((_) async => [_destination(claimed: '10')]);

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_42')), findsNothing);
      expect(find.text(l10n.posNoOpenSales), findsOneWidget);
    });

    testWidgets('the same sale caught by two concurrent queries mid-transition '
        'is still listed once', (tester) async {
      // A draft confirmed between the first and second query answers both.
      stubStatuses(
        draft: [_openSale(id: 7, status: SaleStatus.draft)],
        completed: [_openSale(id: 7, status: SaleStatus.completed)],
      );

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_7')), findsOneWidget);
    });
  });

  group('paid sales (FR-058)', () {
    testWidgets('a paid delivery sale with an unfinished distribution is '
        'listed', (tester) async {
      stubStatuses(paid: [_openSale(id: 3, status: SaleStatus.paid)]);
      when(
        () => salesOrders.getById(saleId: 3),
      ).thenAnswer(
        (_) async => testSale(
          id: 3,
          status: SaleStatus.paid,
          lines: [testLine(id: 5, quantity: '10')],
        ),
      );
      // Only 4 of 10 have a destination.
      when(
        () => deliveries.listForSale(salesOrder: 3),
      ).thenAnswer((_) async => [_destination(claimed: '4')]);

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_3')), findsOneWidget);
      expect(find.text(l10n.posOpenSaleUndelivered), findsOneWidget);
    });

    testWidgets('a fully distributed paid sale is finished and is not listed', (
      tester,
    ) async {
      stubStatuses(paid: [_openSale(id: 3, status: SaleStatus.paid)]);
      when(
        () => salesOrders.getById(saleId: 3),
      ).thenAnswer(
        (_) async => testSale(
          id: 3,
          status: SaleStatus.paid,
          lines: [testLine(id: 5, quantity: '10')],
        ),
      );
      when(
        () => deliveries.listForSale(salesOrder: 3),
      ).thenAnswer((_) async => [_destination(claimed: '10')]);

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_3')), findsNothing);
      expect(find.text(l10n.posNoOpenSales), findsOneWidget);
    });

    testWidgets('a paid counter sale with no lines is not listed', (tester) async {
      stubStatuses(paid: [_openSale(id: 3, status: SaleStatus.paid)]);
      when(
        () => salesOrders.getById(saleId: 3),
      ).thenAnswer((_) async => testSale(id: 3, status: SaleStatus.paid));

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_3')), findsNothing);
    });
  });

  group('selecting one', () {
    testWidgets('hands the chosen sale back to the caller', (tester) async {
      stubStatuses(completed: [_openSale(id: 2, status: SaleStatus.completed)]);
      OpenSale? chosen;

      await pumpSelector(tester, onSelected: (sale) => chosen = sale);
      await tester.tap(find.byKey(const Key('open_sale_2')));
      await tester.pumpAndSettle();

      expect(chosen?.id, 2);
    });

    testWidgets('offers starting a new sale alongside the open ones '
        '(US3 scenario 3)', (tester) async {
      stubStatuses(draft: [_openSale(id: 1, status: SaleStatus.draft)]);
      await pumpSelector(tester);
      expect(find.byKey(const Key('open_sales_new_button')), findsOneWidget);
    });
  });
}
