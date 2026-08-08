import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
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

class MockFacilityRepository extends Mock implements FacilityRepository {}

/// The facility the fixtures' sales belong to. Its own address is 500, so a
/// `shipTo` of 500 is counter pickup and anything else is a delivery.
const _facilityAddress = 500;
const _deliveryAddress = 777;

Facility _facility() => const Facility(
  facilityId: 9,
  code: 'MTZ',
  name: 'Matriz',
  type: FacilityType.store,
  locationId: '01',
  locationLabel: 'Centro',
  addressId: _facilityAddress,
  addressLabel: 'Av. Reforma 1',
  taxpayerRfc: 'XXXX000000XXX',
  status: EntityStatus.active,
);

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
  late MockFacilityRepository facilities;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    deliveries = MockDeliveryOrderRepository();
    facilities = MockFacilityRepository();
    when(
      () => facilities.get(facilityId: any(named: 'facilityId')),
    ).thenAnswer((_) async => _facility());
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
          dateFrom: any(named: 'dateFrom'),
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
        currentId: 337471,
        currentSerial: 282127,
        onSelected: onSelected ?? (_) {},
        onStartNew: () {},
      ),
      overrides: [
        salesOrderOverride(salesOrders),
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
        facilityRepositoryProvider.overrideWithValue(facilities),
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

      // Every sale shows its id; the folio is a second, labelled line that
      // appears only once mbe-api has assigned one (FR-040).
      expect(find.text(l10n.posOpenSaleId(1)), findsOneWidget);
      expect(find.text(l10n.posOpenSaleId(2)), findsOneWidget);
      expect(
        find.text(l10n.posOpenSaleSerial(282127)),
        findsOneWidget,
        reason: 'the confirmed sale shows its folio alongside its id',
      );
      expect(
        find.text('#282127'),
        findsNothing,
        reason: 'the folio is labelled, never a bare number whose meaning '
            'depends on whether the sale was confirmed',
      );
      expect(find.text('Acme'), findsWidgets);
      expect(find.text(r'$116.00'), findsWidgets);
    });

    testWidgets('the status is a heading over each section, not a label on '
        'every row', (tester) async {
      stubStatuses(
        draft: [
          _openSale(id: 1, status: SaleStatus.draft),
          _openSale(id: 2, status: SaleStatus.draft),
        ],
        completed: [_openSale(id: 3, status: SaleStatus.completed)],
      );

      await pumpSelector(tester);

      // One heading per section, however many sales it holds.
      expect(find.text(l10n.posOpenSaleDraft), findsOneWidget);
      expect(find.text(l10n.posOpenSaleUnpaid), findsOneWidget);
      expect(
        find.byKey(const Key('open_sales_heading_draft')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('open_sales_heading_completed')),
        findsOneWidget,
      );
      // No section that has no sales in it.
      expect(find.text(l10n.posOpenSaleUndelivered), findsNothing);

      // Each heading sits above its own sales.
      final draftHeading = tester
          .getTopLeft(find.byKey(const Key('open_sales_heading_draft')))
          .dy;
      final unpaidHeading = tester
          .getTopLeft(find.byKey(const Key('open_sales_heading_completed')))
          .dy;
      for (final id in [1, 2]) {
        final row = tester.getTopLeft(find.byKey(Key('open_sale_$id'))).dy;
        expect(row, greaterThan(draftHeading));
        expect(row, lessThan(unpaidHeading));
      }
      expect(
        tester.getTopLeft(find.byKey(const Key('open_sale_3'))).dy,
        greaterThan(unpaidHeading),
      );
    });

    testWidgets('a draft shows no folio line at all — it has not been '
        'assigned one yet', (tester) async {
      stubStatuses(draft: [_openSale(id: 337482, status: SaleStatus.draft)]);

      await pumpSelector(tester);

      // Scoped to the row: the chip above it carries a folio of its own.
      final row = find.byKey(const Key('open_sale_337482'));
      expect(
        find.descendant(of: row, matching: find.text(l10n.posOpenSaleId(337482))),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: row,
          matching: find.textContaining(
            l10n.posOpenSaleSerial(0).split(' ').first,
          ),
        ),
        findsNothing,
        reason: 'no folio label when there is no folio',
      );
    });

    testWidgets('the chip labels the sale in hand the same way, and says how '
        'many others are open', (tester) async {
      stubStatuses(draft: [_openSale(id: 1, status: SaleStatus.draft)]);

      await pumpSelector(tester);

      expect(
        find.text(
          '${l10n.posOpenSaleId(337471)} · ${l10n.posOpenSaleSerial(282127)}'
          ' · ${l10n.posOpenSalesCount(1)}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a sale with no folio yet gets an id-only chip', (tester) async {
      stubStatuses();

      await pumpPos(
        tester,
        OpenSalesSelector(
          pointSale: 3,
          currentId: 337482,
          onSelected: (_) {},
          onStartNew: () {},
        ),
        overrides: [
          salesOrderOverride(salesOrders),
          deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
          facilityRepositoryProvider.overrideWithValue(facilities),
        ],
      );

      expect(find.text(l10n.posOpenSaleId(337482)), findsOneWidget);
    });

    testWidgets('grouped by status — capturing, then owed money, then owed a '
        'delivery — however the dates fall', (tester) async {
      // The draft is the *oldest* here, so a flat newest-first ordering would
      // put it last. Grouping by what the cashier can do about it wins.
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
        paid: [
          _openSale(id: 3, status: SaleStatus.paid, date: DateTime(2026, 8, 5, 18)),
        ],
      );
      when(() => salesOrders.getById(saleId: 3)).thenAnswer(
        (_) async => testSale(
          id: 3,
          status: SaleStatus.paid,
          shipTo: _deliveryAddress,
          lines: [testLine(id: 5, quantity: '10')],
        ),
      );
      when(
        () => deliveries.listForSale(salesOrder: 3),
      ).thenAnswer((_) async => [_destination(claimed: '4')]);

      await pumpSelector(tester);

      final capturing = tester.getTopLeft(find.byKey(const Key('open_sale_1')));
      final owedMoney = tester.getTopLeft(find.byKey(const Key('open_sale_2')));
      final owedDelivery = tester.getTopLeft(find.byKey(const Key('open_sale_3')));
      expect(capturing.dy, lessThan(owedMoney.dy));
      expect(owedMoney.dy, lessThan(owedDelivery.dy));
    });

    testWidgets('newest first within a status group — ids are sequential, so '
        'the most recent draft is the top one', (tester) async {
      stubStatuses(
        draft: [
          _openSale(id: 337435, status: SaleStatus.draft),
          _openSale(id: 337482, status: SaleStatus.draft),
          _openSale(id: 337449, status: SaleStatus.draft),
        ],
      );

      await pumpSelector(tester);

      final rows = [337482, 337449, 337435]
          .map((id) => tester.getTopLeft(find.byKey(Key('open_sale_$id'))).dy)
          .toList();
      expect(rows, orderedEquals([...rows]..sort()));
    });

    testWidgets('an empty register says so rather than showing a blank menu', (
      tester,
    ) async {
      stubStatuses();
      await pumpSelector(tester);
      expect(find.text(l10n.posNoOpenSales), findsOneWidget);
    });
  });

  group('scoping to the trading day', () {
    testWidgets('every status is asked for from midnight today, not from the '
        'beginning of the register\'s history', (tester) async {
      stubStatuses(draft: [_openSale(id: 1, status: SaleStatus.draft)]);

      await pumpSelector(tester);

      final midnight = DateTime.now();
      for (final status in SaleStatus.values.where(
        (s) => s != SaleStatus.cancelled,
      )) {
        final captured = verify(
          () => salesOrders.listOpen(
            pointSale: 3,
            status: status,
            dateFrom: captureAny(named: 'dateFrom'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).captured.single as DateTime?;

        expect(captured, isNotNull, reason: '$status must be date-scoped');
        expect(
          captured,
          DateTime.utc(midnight.year, midnight.month, midnight.day),
          reason: "today's local date, but UTC-flagged: built_value refuses to "
              'serialize a local DateTime, and mbe-api reads the value as '
              'wall-clock time anyway',
        );
        expect(
          captured!.isUtc,
          isTrue,
          reason: 'a local DateTime throws before the request is ever sent',
        );
      }
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
          shipTo: _deliveryAddress,
          lines: [testLine(id: 5, quantity: '10')],
        ),
      );
      // A delivery sale with nothing distributed, so it genuinely belongs in
      // the list — once.
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
          shipTo: _deliveryAddress,
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
          shipTo: _deliveryAddress,
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

    testWidgets('a paid counter sale is finished, however little of it was '
        'ever "distributed" — the register would fill with them otherwise', (
      tester,
    ) async {
      // The live case: paid, has lines, no ship_to, and no delivery orders at
      // all. Asking only "is everything distributed?" answers "no" forever.
      stubStatuses(paid: [_openSale(id: 337446, status: SaleStatus.paid)]);
      when(() => salesOrders.getById(saleId: 337446)).thenAnswer(
        (_) async => testSale(
          id: 337446,
          status: SaleStatus.paid,
          lines: [testLine(id: 5, quantity: '10')],
        ),
      );
      when(
        () => deliveries.listForSale(salesOrder: 337446),
      ).thenAnswer((_) async => []);

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_337446')), findsNothing);
      expect(find.text(l10n.posNoOpenSales), findsOneWidget);
      verifyNever(() => deliveries.listForSale(salesOrder: 337446));
    });

    testWidgets('counter pickup recorded explicitly as the facility\'s own '
        'address is finished too', (tester) async {
      stubStatuses(paid: [_openSale(id: 4, status: SaleStatus.paid)]);
      when(() => salesOrders.getById(saleId: 4)).thenAnswer(
        (_) async => testSale(
          id: 4,
          status: SaleStatus.paid,
          shipTo: _facilityAddress,
          lines: [testLine(id: 5, quantity: '10')],
        ),
      );
      when(
        () => deliveries.listForSale(salesOrder: 4),
      ).thenAnswer((_) async => []);

      await pumpSelector(tester);

      expect(find.byKey(const Key('open_sale_4')), findsNothing);
      verifyNever(() => deliveries.listForSale(salesOrder: 4));
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
