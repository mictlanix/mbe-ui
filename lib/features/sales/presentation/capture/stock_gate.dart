import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';

/// The outcome of checking a sale's lines against the cached stock (spec 047
/// FR-008..FR-011a, data-model.md Stock gate).
class StockGate {
  const StockGate({
    this.shortLineIds = const {},
    this.unknownLineIds = const {},
    this.blocks = false,
  });

  /// Lines in a (product, warehouse) pair whose summed quantity exceeds what
  /// the warehouse has available.
  final Set<int> shortLineIds;

  /// Lines whose stock could not be checked. A warning only, never a block.
  final Set<int> unknownLineIds;

  /// True only for a draft sale with at least one short line. There is no
  /// override.
  final bool blocks;
}

/// Judges every stock-tracked line of [sale] against [cache]. Quantities are
/// summed per (product, warehouse) across lines, so two lines of one product
/// cannot each fit while together exceeding the stock.
StockGate evaluateStock(Sale sale, Map<int, ProductStock> cache) =>
    evaluateLines(sale.lines, cache, draft: sale.status == SaleStatus.draft);

/// [evaluateStock] over a bare list of lines, for a caller that has no [Sale]
/// (a single line judged on its own).
StockGate evaluateLines(
  List<SaleLine> lines,
  Map<int, ProductStock> cache, {
  bool draft = true,
}) {
  final totals = <(int, int?), Decimal>{};
  for (final line in lines) {
    if (!(cache[line.product]?.checked ?? true)) continue;
    final key = (line.product, line.warehouse);
    totals[key] =
        (totals[key] ?? Decimal.zero) +
        (Decimal.tryParse(line.quantity) ?? Decimal.zero);
  }

  final short = <int>{};
  final unknown = <int>{};
  for (final line in lines) {
    final stock = cache[line.product];
    if (stock == null) {
      unknown.add(line.id);
      continue;
    }
    if (!stock.checked) continue;
    WarehouseStock? row;
    for (final w in stock.warehouses) {
      if (w.warehouse == line.warehouse) row = w;
    }
    if (row == null) {
      unknown.add(line.id);
      continue;
    }
    final available = Decimal.tryParse(row.available) ?? Decimal.zero;
    final ordered = totals[(line.product, line.warehouse)]!;
    if (available.sign <= 0 || ordered > available) short.add(line.id);
  }
  return StockGate(
    shortLineIds: short,
    unknownLineIds: unknown,
    blocks: draft && short.isNotEmpty,
  );
}
