import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/presentation/capture/customer_bar.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';

import '../widget/features/sales/pos_test_harness.dart';
import 'golden_harness.dart';

/// Golden coverage for the spec 023 capture-surface restyle (contracts/
/// capture-surface.md §§1, 4, 5): the customer band's `facts` face, the
/// line item and the totals footer, each at the two-width/two-theme
/// convention (spec 022 FR-020). `goldenWideWidth` (1024 px) doubles as the
/// FR-037a tablet-landscape check for the line item — `sale_line_row_test
/// .dart` already asserts no overflow there; this file is the visual
/// counterpart.
///
/// The line item switches widget at `goldenNarrowWidth` (400 px, below
/// `LayoutBreakpoints.compact`): `SaleLineCard`, not `SaleLineRow` — the
/// same choice `capture_step.dart`'s own `_lines` makes, so the golden shows
/// what the app actually renders at that width rather than an arrangement
/// no cashier would see.
class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockWarehouseRepository2 extends Mock implements WarehouseRepository {}

void main() {
  setUpAll(loadGoldenFonts);

  late MockCustomerRepository customerRepository;
  late MockCustomerPaymentRepository paymentRepository;
  late MockWarehouseRepository2 warehouseRepository;

  setUp(() {
    customerRepository = MockCustomerRepository();
    paymentRepository = MockCustomerPaymentRepository();
    warehouseRepository = MockWarehouseRepository2();

    when(
      () => customerRepository.get(customerId: any(named: 'customerId')),
    ).thenAnswer(
      (_) async => Customer(
        customerId: 7,
        code: 'C-7',
        name: 'PÚBLICO EN GENERAL',
        creditLimit: '5000.00',
        creditDays: 30,
        priceList: const PriceListRef(id: 1, name: 'Mostrador'),
        status: EntityStatus.active,
      ),
    );
    when(
      () => paymentRepository.outstandingBalanceFor(
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer((_) async => '0.00');
    when(
      () => warehouseRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => WarehouseListResult(
        items: [
          Warehouse(
            warehouseId: 3,
            facilityId: 9,
            facilityName: 'Main Store',
            code: 'WH-3',
            name: 'Main Warehouse',
            status: EntityStatus.active,
          ),
        ],
        total: 1,
      ),
    );
  });

  testWidgets('CustomerBar, facts face', (tester) async {
    await expectGoldenMatrix(
      tester,
      'pos_customer_bar',
      (brightness, width) => SizedBox(width: width, child: CustomerBar(sale: testSale())),
      overrides: [
        customerRepositoryProvider.overrideWithValue(customerRepository),
        customerPaymentRepositoryProvider.overrideWithValue(paymentRepository),
      ],
    );
  });

  testWidgets('the line item — SaleLineCard below 600 px, SaleLineRow above', (
    tester,
  ) async {
    await expectGoldenMatrix(
      tester,
      'pos_sale_line',
      (brightness, width) => SizedBox(
        width: width,
        child: width < 600
            ? SaleLineCard(line: testLine(), facilityId: 9)
            : SaleLineRow(line: testLine(), facilityId: 9),
      ),
      overrides: [warehouseRepositoryProvider.overrideWithValue(warehouseRepository)],
    );
  });

  testWidgets('SaleTotalsBar, labelled groups with the primary action', (
    tester,
  ) async {
    await expectGoldenMatrix(
      tester,
      'pos_sale_totals_bar',
      (brightness, width) => SizedBox(
        width: width,
        child: SaleTotalsBar(
          sale: testSale(lines: [testLine()]),
          onContinue: () {},
          confirming: false,
          compact: width < 600,
        ),
      ),
    );
  });
}
