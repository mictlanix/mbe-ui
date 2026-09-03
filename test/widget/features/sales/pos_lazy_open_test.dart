import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_lookup_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// A register nobody has touched must not create a sale.
///
/// `open()` is a `POST` that leaves a draft behind for good, so calling it to
/// merely *render* the screen meant every reload, every navigation back and
/// every hot restart littered the register — 12 of one day's 21 drafts were
/// empty on a live account. The draft is now opened by the first action that
/// needs one.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();

    when(() => salesOrders.open()).thenAnswer((_) async => testSale());
    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
  });

  Future<ProviderContainer> pumpRegister(WidgetTester tester) {
    return pumpPos(
      tester,
      Consumer(
        builder: (context, ref, _) => CaptureStep(
          sale: ref.watch(posSaleControllerProvider).valueOrNull,
        ),
      ),
      overrides: [
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
      ],
    );
  }

  group('an untouched register', () {
    testWidgets('opens no sale at all', (tester) async {
      await pumpRegister(tester);

      verifyNever(() => salesOrders.open());
    });

    testWidgets('still invites a scan — that is what starts the sale', (
      tester,
    ) async {
      await pumpRegister(tester);

      expect(find.text(l10n.posNoLinesHint), findsOneWidget);
      expect(
        find.text(l10n.posProductSearchLabel),
        findsOneWidget,
        reason: 'the search field is the way in and must not wait for a sale',
      );
    });

    testWidgets(
      'still shows the header, seeded with the walk-in customer — and opens '
      'no sale to do it',
      (tester) async {
        await pumpRegister(tester);

        // The band and the mode track render from the first frame now, on
        // `posDefaultCustomerId` — the customer mbe-api would raise the sale
        // against anyway. Before this they waited for a sale, so the whole
        // header appeared the instant the first scan landed and shoved the
        // search field and lines down with it.
        expect(find.text('PÚBLICO EN GENERAL'), findsOneWidget);
        expect(find.text(l10n.posFulfillmentCounter), findsOneWidget);

        // The point of the whole file: rendering that header is not an
        // action, so nothing is created to render it.
        verifyNever(() => salesOrders.open());
      },
    );

    testWidgets('reads zeros, not blanks, for the sale that does not exist', (
      tester,
    ) async {
      await pumpRegister(tester);

      // The band opens reporting facts, not searching — the picker is a face
      // the cashier asks for.
      expect(find.byKey(const Key('pos_customer_picker')), findsNothing);
      // The footer shows the same figures a sale opened a moment later
      // starts on, so it does not grow a stats row mid-flow.
      expect(find.text(l10n.posTotalsTotalLabel.toUpperCase()), findsOneWidget);
      expect(find.text(r'$0.00'), findsWidgets);
    });

    testWidgets('cannot be confirmed', (tester) async {
      await pumpRegister(tester);

      expect(
        tester
            .widget<FloatingActionButton>(
              find.byKey(const Key('pos_continue_to_payment')),
            )
            .onPressed,
        isNull,
      );
    });
  });

  group('the first action opens the sale', () {
    testWidgets('the search field survives the sale appearing — the header '
        'grows above it mid-search, and losing its State would drop the '
        'product it just found', (tester) async {
      final container = await pumpRegister(tester);
      // spec 023: typing now debounces into a real lookup (not only on
      // Enter), so the field needs a stub even though this test's own
      // interest is in the field's State surviving the sale appearing, not
      // in the lookup's result.
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async => const <ProductLookupResult>[]);

      // Whatever the cashier has typed stands in for the in-flight search
      // this list-reshuffle used to discard.
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('pos_product_search_field')),
          matching: find.byType(TextField),
        ),
        'CLASTDCC4MS',
      );
      await tester.pumpAndSettle();

      // The sale appears, so the customer bar and mode selector slot in above.
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();

      // The customer band shows facts by default (spec 023's redesign) —
      // the picker itself is reached via Buscar, covered elsewhere.
      expect(find.byKey(const Key('pos_customer_facts')), findsOneWidget);
      expect(
        find.text('CLASTDCC4MS'),
        findsOneWidget,
        reason: 'the same field, not a fresh one — its State carried through',
      );
    });

    testWidgets('adding a line opens it once, then reuses it', (tester) async {
      final container = await pumpRegister(tester);
      final notifier = container.read(posSaleControllerProvider.notifier);

      when(
        () => salesOrders.addLine(
          saleId: any(named: 'saleId'),
          product: any(named: 'product'),
          quantity: any(named: 'quantity'),
          price: any(named: 'price'),
          discountRate: any(named: 'discountRate'),
          taxRate: any(named: 'taxRate'),
          warehouse: any(named: 'warehouse'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => testSale(lines: [testLine()]));

      await notifier.addLine(product: 11, quantity: '1');
      await notifier.addLine(product: 12, quantity: '1');
      await tester.pumpAndSettle();

      verify(() => salesOrders.open()).called(1);
      expect(container.read(posSaleControllerProvider).valueOrNull, isNotNull);
    });

    testWidgets('so does a product lookup — pricing needs the customer, and '
        'the customer is the sale\'s', (tester) async {
      final container = await pumpRegister(tester);
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async => const <ProductLookupResult>[]);

      await container.read(
        productLookupControllerProvider('clavo').future,
      );

      verify(() => salesOrders.open()).called(1);
      verify(() => salesOrders.productLookup(
            pattern: 'clavo',
            customer: 7,
            warehouse: any(named: 'warehouse'),
          )).called(1);
    });

    testWidgets('finishing a sale returns the register to empty rather than '
        'opening another', (tester) async {
      final container = await pumpRegister(tester);
      final notifier = container.read(posSaleControllerProvider.notifier);

      await notifier.ensureOpen();
      expect(container.read(posSaleControllerProvider).valueOrNull, isNotNull);

      await notifier.startNew();
      await tester.pumpAndSettle();

      expect(container.read(posSaleControllerProvider).valueOrNull, isNull);
      verify(() => salesOrders.open()).called(1);
    });
  });
}
