import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_selection.dart';

void main() {
  final today = DateTime(2026, 11, 17);

  KardexSelection range(DateTime from, DateTime to) =>
      KardexSelection(productId: 1, warehouseId: 2, from: from, to: to);

  KardexSelection ofDays(int days) {
    final from = DateTime(2025, 1, 1);
    return range(from, DateTime(2025, 1, 1 + days - 1));
  }

  group('default range', () {
    test('is today - 29 days through today, 30 days inclusive', () {
      final s = KardexSelection.initial(today: today);
      expect(s.from, DateTime(2026, 10, 19));
      expect(s.to, today);
      expect(s.to.difference(s.from).inDays + 1, 30);
      expect(s.productId, isNull);
      expect(s.warehouseId, isNull);
    });

    test('drops the time of day of today', () {
      final s = KardexSelection.initial(today: DateTime(2026, 11, 17, 15, 30));
      expect(s.to, DateTime(2026, 11, 17));
    });
  });

  group('state', () {
    test('missing product is incomplete', () {
      final s = KardexSelection.initial(
        today: today,
      ).copyWith(warehouseId: () => 2);
      expect(s.state, KardexSelectionState.incomplete);
    });

    test('missing warehouse is incomplete', () {
      final s = KardexSelection.initial(
        today: today,
      ).copyWith(productId: () => 1);
      expect(s.state, KardexSelectionState.incomplete);
    });

    test('to before from is reversed', () {
      final s = range(DateTime(2026, 11, 17), DateTime(2026, 11, 16));
      expect(s.state, KardexSelectionState.reversed);
    });

    test('one day range is ready', () {
      final d = DateTime(2026, 11, 17);
      expect(range(d, d).state, KardexSelectionState.ready);
    });

    test('365 days is ready', () {
      expect(ofDays(365).state, KardexSelectionState.ready);
    });

    test('366 days is ready (both ends inclusive)', () {
      expect(ofDays(366).state, KardexSelectionState.ready);
      expect(kardexMaxRangeDays, 366);
    });

    test('367 days is tooLong', () {
      expect(ofDays(367).state, KardexSelectionState.tooLong);
    });

    test('default range with both ids is ready', () {
      final s = KardexSelection.initial(
        today: today,
      ).copyWith(productId: () => 1, warehouseId: () => 2);
      expect(s.state, KardexSelectionState.ready);
    });

    test('incomplete wins over reversed and tooLong', () {
      final s = KardexSelection(
        from: DateTime(2026, 11, 17),
        to: DateTime(2026, 11, 1),
      );
      expect(s.state, KardexSelectionState.incomplete);
      final long = KardexSelection(
        warehouseId: 2,
        from: DateTime(2020, 1, 1),
        to: DateTime(2026, 1, 1),
      );
      expect(long.state, KardexSelectionState.incomplete);
    });

    test('reversed wins over tooLong', () {
      // Reversed can never also be too long, but the order must hold.
      final s = range(DateTime(2026, 11, 17), DateTime(2020, 1, 1));
      expect(s.state, KardexSelectionState.reversed);
    });
  });

  group('URL', () {
    test('round trip', () {
      final s = range(DateTime(2026, 1, 5), DateTime(2026, 2, 9));
      final uri = s.toUri('/inventory/kardex');
      expect(uri.path, '/inventory/kardex');
      expect(uri.queryParameters, {
        'product': '1',
        'warehouse': '2',
        'from': '2026-01-05',
        'to': '2026-02-09',
      });
      expect(KardexSelection.fromUri(uri, today: today), s);
    });

    test('toUri omits missing ids', () {
      final uri = KardexSelection.initial(
        today: today,
      ).toUri('/inventory/kardex');
      expect(uri.queryParameters.containsKey('product'), isFalse);
      expect(uri.queryParameters.containsKey('warehouse'), isFalse);
    });

    test('empty query falls back to defaults', () {
      final s = KardexSelection.fromUri(
        Uri.parse('/inventory/kardex'),
        today: today,
      );
      expect(s, KardexSelection.initial(today: today));
    });

    test('garbage dates fall back to defaults without throwing', () {
      final s = KardexSelection.fromUri(
        Uri.parse('/inventory/kardex?from=abc&to=2026-13-45&product=1'),
        today: today,
      );
      final d = KardexSelection.initial(today: today);
      expect(s.from, d.from);
      expect(s.to, d.to);
      expect(s.productId, 1);
    });

    test('non-numeric product is treated as missing', () {
      final s = KardexSelection.fromUri(
        Uri.parse('/inventory/kardex?product=abc&warehouse=2'),
        today: today,
      );
      expect(s.productId, isNull);
      expect(s.warehouseId, 2);
      expect(s.state, KardexSelectionState.incomplete);
    });

    test('empty ids are treated as missing', () {
      final s = KardexSelection.fromUri(
        Uri.parse('/inventory/kardex?product=&warehouse='),
        today: today,
      );
      expect(s.productId, isNull);
      expect(s.warehouseId, isNull);
    });
  });

  group('equality', () {
    test('equal values are equal with the same hashCode', () {
      final a = range(DateTime(2026, 1, 1), DateTime(2026, 1, 2));
      final b = range(DateTime(2026, 1, 1), DateTime(2026, 1, 2));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.copyWith(productId: () => 3), isNot(a));
    });
  });
}
