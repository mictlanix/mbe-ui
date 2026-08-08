import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

SaleLine _line({required int id, required String quantity, String name = 'Widget'}) =>
    SaleLine(
      id: id,
      product: id * 10,
      productCode: 'P-$id',
      productName: name,
      quantity: quantity,
      cost: '10',
      price: '20',
      discountRate: '0',
      taxRate: '0.16',
      taxIncluded: false,
      warehouse: 3,
      subtotal: '0',
      taxTotal: '0',
      total: '0',
    );

Sale _sale(List<SaleLine> lines) => Sale(
  id: 42,
  facility: 9,
  pointSale: 3,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  promiseDate: DateTime(2026, 8, 5),
  status: SaleStatus.paid,
  lines: lines,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  balance: '0',
);

Destination _destination({
  required int id,
  required Map<int, String> claims,
  FulfillmentType type = FulfillmentType.delivery,
}) => Destination(
  id: id,
  fulfillmentType: type,
  status: DeliveryOrderStatus.draft,
  lines: [
    for (final entry in claims.entries)
      DestinationLine(
        id: id * 100 + entry.key,
        salesOrderDetail: entry.key,
        product: entry.key * 10,
        productCode: 'P-${entry.key}',
        productName: 'Widget',
        quantity: entry.value,
      ),
  ],
);

void main() {
  group('a line nothing has claimed yet', () {
    test('sits entirely at the counter', () {
      final result = distributionFor(
        sale: _sale([_line(id: 1, quantity: '10')]),
        destinations: const [],
      );

      final line = result.single;
      expect(line.ordered, '10');
      expect(line.distributed, '0');
      expect(line.draftQuantity, '0');
      expect(line.atCounter, '10');
      expect(line.isFullyDistributed, isFalse);
      expect(line.isOverClaimed, isFalse);
      expect(line.claimable, '10');
    });
  });

  group('splitting one line across two destinations (SC-005)', () {
    test('each destination\'s share is reported separately and the remainder '
        'is what is left', () {
      final result = distributionFor(
        sale: _sale([_line(id: 1, quantity: '10')]),
        destinations: [
          _destination(id: 100, claims: {1: '4'}),
          _destination(id: 200, claims: {1: '3'}),
        ],
      );

      final line = result.single;
      expect(line.perDestination, {100: '4', 200: '3'});
      expect(line.distributed, '7');
      expect(line.atCounter, '3');
      expect(line.isFullyDistributed, isFalse);
    });

    test('a line fully split across destinations leaves nothing at the '
        'counter', () {
      final result = distributionFor(
        sale: _sale([_line(id: 1, quantity: '10')]),
        destinations: [
          _destination(id: 100, claims: {1: '6'}),
          _destination(id: 200, claims: {1: '4'}),
        ],
      );

      expect(result.single.atCounter, '0');
      expect(result.single.isFullyDistributed, isTrue);
      expect(result.single.claimable, '0');
    });
  });

  test('the in-progress draft counts against the remainder before it is '
      'submitted', () {
    final result = distributionFor(
      sale: _sale([_line(id: 1, quantity: '10')]),
      destinations: [_destination(id: 100, claims: {1: '4'})],
      draft: {1: '2'},
    );

    final line = result.single;
    expect(line.distributed, '4');
    expect(line.draftQuantity, '2');
    expect(line.atCounter, '4');
  });

  test('a draft claiming more than remains is flagged rather than silently '
      'accepted', () {
    final result = distributionFor(
      sale: _sale([_line(id: 1, quantity: '10')]),
      destinations: [_destination(id: 100, claims: {1: '8'})],
      draft: {1: '5'},
    );

    final line = result.single;
    expect(line.isOverClaimed, isTrue);
    expect(line.atCounter, '-3');
    expect(line.claimable, '2', reason: 'only 2 were still available');
  });

  test('every line of a multi-line sale is reported, in order', () {
    final result = distributionFor(
      sale: _sale([
        _line(id: 1, quantity: '10', name: 'Cement'),
        _line(id: 2, quantity: '5', name: 'Rebar'),
      ]),
      destinations: [_destination(id: 100, claims: {2: '5'})],
    );

    expect(result.map((d) => d.saleLineId), [1, 2]);
    expect(result.first.productName, 'Cement');
    expect(result.first.atCounter, '10');
    expect(result.last.atCounter, '0');
  });

  test('a counter-pickup destination distributes just as much as a delivery '
      'one — the remainder is accounted for, not outstanding (FR-036)', () {
    final result = distributionFor(
      sale: _sale([_line(id: 1, quantity: '10')]),
      destinations: [
        _destination(id: 100, claims: {1: '6'}),
        _destination(
          id: 200,
          claims: {1: '4'},
          type: FulfillmentType.counterPickup,
        ),
      ],
    );

    expect(result.single.isFullyDistributed, isTrue);
  });

  test('quantities at mbe-api\'s full stored scale compare correctly — the '
      'arithmetic is decimal, never string equality', () {
    final result = distributionFor(
      sale: _sale([_line(id: 1, quantity: '10.0000')]),
      destinations: [_destination(id: 100, claims: {1: '2.5000'})],
      draft: {1: '7.50'},
    );

    expect(isZeroAmount(result.single.atCounter), isTrue);
    expect(result.single.isFullyDistributed, isTrue);
  });

  group('the SC-005 invariant', () {
    test('Σ perDestination + draftQuantity + atCounter == ordered, for every '
        'line, across a mixed set of claims', () {
      final result = distributionFor(
        sale: _sale([
          _line(id: 1, quantity: '10'),
          _line(id: 2, quantity: '7.5'),
          _line(id: 3, quantity: '100'),
        ]),
        destinations: [
          _destination(id: 100, claims: {1: '4', 2: '2.5'}),
          _destination(id: 200, claims: {1: '3', 3: '40'}),
        ],
        draft: {1: '1', 3: '25'},
      );

      for (final line in result) {
        final total = addAmounts(
          addAmounts(line.distributed, line.draftQuantity),
          line.atCounter,
        );
        expect(
          compareAmounts(total, line.ordered),
          0,
          reason: 'line ${line.saleLineId}: $total != ${line.ordered}',
        );
      }
    });
  });

  group('isDistributionComplete (FR-030, FR-035)', () {
    List<LineDistribution> withRemainder() => distributionFor(
      sale: _sale([_line(id: 1, quantity: '10')]),
      destinations: [_destination(id: 100, claims: {1: '6'})],
    );

    test('delivery mode is incomplete while anything is left over', () {
      expect(isDistributionComplete(withRemainder(), isMixed: false), isFalse);
    });

    test('mixed mode accepts the remainder — it goes to the counter', () {
      expect(isDistributionComplete(withRemainder(), isMixed: true), isTrue);
    });

    test('delivery mode is complete once everything is distributed', () {
      final complete = distributionFor(
        sale: _sale([_line(id: 1, quantity: '10')]),
        destinations: [_destination(id: 100, claims: {1: '10'})],
      );
      expect(isDistributionComplete(complete, isMixed: false), isTrue);
    });

    test('an over-claim blocks closing in either mode', () {
      final over = distributionFor(
        sale: _sale([_line(id: 1, quantity: '10')]),
        destinations: [_destination(id: 100, claims: {1: '12'})],
      );
      expect(isDistributionComplete(over, isMixed: false), isFalse);
      expect(isDistributionComplete(over, isMixed: true), isFalse);
    });
  });
}
