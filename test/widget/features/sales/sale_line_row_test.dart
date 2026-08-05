import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

Warehouse _warehouse(int id, String name) => Warehouse(
  warehouseId: id,
  facilityId: 9,
  facilityName: 'Main Store',
  code: 'WH-$id',
  name: name,
  status: EntityStatus.active,
);

void main() {
  late MockWarehouseRepository warehouseRepository;

  setUp(() {
    warehouseRepository = MockWarehouseRepository();
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
        items: [_warehouse(3, 'Main Warehouse'), _warehouse(4, 'Overflow')],
        total: 2,
      ),
    );
  });

  Future<void> pumpRow(
    WidgetTester tester, {
    bool enabled = true,
    String quantity = '2',
    Map<int, List<WarehouseStock>> stock = const {},
  }) async {
    await pumpPos(
      tester,
      SaleLineRow(
        line: testLine(quantity: quantity),
        facilityId: 9,
        enabled: enabled,
      ),
      overrides: [
        warehouseOverride(warehouseRepository),
        productStockCacheProvider.overrideWith((ref) => stock),
      ],
    );
  }

  group('in-place edit affordances (FR-023)', () {
    testWidgets('every editable field is present and enabled, including the '
        'tax rate — no field is read-only on a draft', (tester) async {
      await pumpRow(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      for (final label in [
        l10n.posLineQuantityLabel,
        l10n.posLinePriceLabel,
        l10n.posLineDiscountLabel,
        l10n.posLineTaxLabel,
      ]) {
        final field = tester.widget<TextField>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(TextField),
          ),
        );
        expect(field.enabled, isTrue, reason: '$label should be editable');
      }
    });

    testWidgets('quantity has increment and decrement controls', (tester) async {
      await pumpRow(tester);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('the warehouse picker offers the facility\'s warehouses', (
      tester,
    ) async {
      await pumpRow(tester);
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    });

    testWidgets('a confirmed sale renders every control disabled (FR-041)', (
      tester,
    ) async {
      await pumpRow(tester, enabled: false);

      for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(field.enabled, isFalse);
      }
      final add = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.add), matching: find.byType(IconButton)),
      );
      expect(add.onPressed, isNull);
    });
  });

  group('shortfall warning (FR-025, FR-026)', () {
    testWidgets('no warning when availability covers the ordered quantity', (
      tester,
    ) async {
      await pumpRow(
        tester,
        quantity: '2',
        stock: const {
          11: [
            WarehouseStock(warehouse: 3, onHand: '10', available: '10'),
          ],
        },
      );
      expect(find.byIcon(Icons.warning_amber), findsNothing);
    });

    testWidgets('a partial shortfall warns and offers to reduce the quantity', (
      tester,
    ) async {
      await pumpRow(
        tester,
        quantity: '5',
        stock: const {
          11: [
            WarehouseStock(warehouse: 3, onHand: '2', available: '2'),
          ],
        },
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      expect(find.text(l10n.posLineShortfall('2')), findsOneWidget);
      expect(find.text(l10n.posLineAdjustToAvailable), findsOneWidget);
    });

    testWidgets('no availability at all is distinguished from a partial '
        'shortfall (FR-026)', (tester) async {
      await pumpRow(
        tester,
        quantity: '1',
        stock: const {
          11: [
            WarehouseStock(warehouse: 3, onHand: '0', available: '0'),
          ],
        },
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.text(l10n.posLineNoStock), findsOneWidget);
      expect(find.text(l10n.posLineShortfall('0')), findsNothing);
    });

    testWidgets('a product never looked up in this session shows no warning — '
        'advisory only, never invented', (tester) async {
      await pumpRow(tester, quantity: '999');
      expect(find.byIcon(Icons.warning_amber), findsNothing);
    });
  });
}
