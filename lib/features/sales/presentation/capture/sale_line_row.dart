import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One line, expanded tier (FR-022, FR-023): product, warehouse picker with
/// availability, quantity stepper, unit, in-place price/discount/tax-rate
/// edit, line total, delete, and the non-blocking shortfall warning (FR-025,
/// FR-026). Read-only once `Sale.isEditable` is false (FR-041) — the caller
/// passes `enabled: false` rather than this row deciding on its own.
class SaleLineRow extends ConsumerStatefulWidget {
  const SaleLineRow({
    super.key,
    required this.line,
    required this.facilityId,
    this.enabled = true,
  });

  final SaleLine line;
  final int facilityId;
  final bool enabled;

  @override
  ConsumerState<SaleLineRow> createState() => _SaleLineRowState();
}

class _SaleLineRowState extends ConsumerState<SaleLineRow> {
  // Fields hold display-formatted text (FR-022) — trimmed quantities, two-decimal
  // prices, and rates as the percentages their labels claim. `_sync` converts
  // back whenever the server's copy changes underneath.
  late final _quantity = TextEditingController(
    text: formatQuantity(widget.line.quantity),
  );
  late final _price = TextEditingController(text: formatPrice(widget.line.price));
  late final _discountRate = TextEditingController(
    text: formatRateAsPercent(widget.line.discountRate),
  );
  late final _taxRate = TextEditingController(
    text: formatRateAsPercent(widget.line.taxRate),
  );
  bool _busy = false;

  @override
  void didUpdateWidget(covariant SaleLineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line != widget.line) _sync();
  }

  /// Re-renders every field from the line's authoritative values.
  void _sync() {
    _quantity.text = formatQuantity(widget.line.quantity);
    _price.text = formatPrice(widget.line.price);
    _discountRate.text = formatRateAsPercent(widget.line.discountRate);
    _taxRate.text = formatRateAsPercent(widget.line.taxRate);
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _discountRate.dispose();
    _taxRate.dispose();
    super.dispose();
  }

  Future<void> _update({
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
  }) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(posSaleControllerProvider.notifier)
          .updateLine(
            lineId: widget.line.id,
            quantity: quantity,
            price: price,
            discountRate: discountRate,
            taxRate: taxRate,
            warehouse: warehouse,
          );
    } on Object {
      // Rejected — restore the fields to the last accepted values
      // (contracts/pos-screen.md §6); PosSaleController already left `state`
      // unchanged, so re-rendering from the line is enough.
      _sync();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Discount and tax are typed as percentages but stored as `0 ≤ r ≤ 1`
  /// rates. A non-numeric entry is refused outright rather than sent.
  Future<void> _updateRate({String? discountRate, String? taxRate}) async {
    final rawDiscount = discountRate == null ? null : parsePercentAsRate(discountRate);
    final rawTax = taxRate == null ? null : parsePercentAsRate(taxRate);
    if ((discountRate != null && rawDiscount == null) ||
        (taxRate != null && rawTax == null)) {
      _sync();
      return;
    }
    await _update(discountRate: rawDiscount, taxRate: rawTax);
  }

  Future<void> _remove() =>
      ref.read(posSaleControllerProvider.notifier).removeLine(widget.line.id);

  void _step(int delta) {
    final next = Decimal.parse(_quantity.text) + Decimal.fromInt(delta);
    if (next.sign <= 0) return;
    final text = next.toString();
    _quantity.text = text;
    _update(quantity: text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final line = widget.line;
    final enabled = widget.enabled && !_busy;
    final stockCache = ref.watch(productStockCacheProvider)[line.product];
    final shortfall = _shortfall(l10n, line, stockCache);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '${line.productCode} — ${line.productName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(flex: 2, child: _warehousePicker(enabled)),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: enabled ? _remove : null,
                  tooltip: l10n.posRemoveLineTooltip,
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: enabled ? () => _step(-1) : null,
                ),
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _quantity,
                    enabled: enabled,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLineQuantityLabel),
                    onSubmitted: (v) => _update(quantity: v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: enabled ? () => _step(1) : null,
                ),
                // FR-022's unit column (mbe-api#145). Absent for a product
                // with no unit on file, rather than a placeholder.
                if (line.unit != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      line.unit!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: _price,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLinePriceLabel),
                    onSubmitted: (v) => _update(price: v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _discountRate,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLineDiscountLabel),
                    onSubmitted: (v) => _updateRate(discountRate: v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _taxRate,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLineTaxLabel),
                    onSubmitted: (v) => _updateRate(taxRate: v),
                  ),
                ),
                const SizedBox(width: 8),
                Text(MoneyFormatters.currency(line.total)),
              ],
            ),
            if (shortfall != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shortfall,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    if (enabled)
                      TextButton(
                        onPressed: () => _update(quantity: _availableQuantity(stockCache)),
                        child: Text(l10n.posLineAdjustToAvailable),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _warehousePicker(bool enabled) {
    final l10n = AppLocalizations.of(context)!;
    final warehouses = ref.watch(facilityWarehousesControllerProvider(widget.facilityId));
    return warehouses.when(
      data: (list) => DropdownButtonFormField<int>(
        initialValue: widget.line.warehouse,
        decoration: InputDecoration(labelText: l10n.posLineWarehouseLabel),
        items: [
          for (final w in list)
            DropdownMenuItem(
              value: w.warehouseId,
              // FR-022: the chosen warehouse's availability for this product,
              // shown alongside the name so switching warehouses is an
              // informed choice rather than a guess. Blank for a warehouse
              // this product was never looked up in — advisory, never invented.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(w.name, overflow: TextOverflow.ellipsis)),
                  if (_availabilityIn(w.warehouseId) case final available?) ...[
                    const SizedBox(width: 8),
                    Text(
                      available,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
        onChanged: enabled
            ? (value) {
                if (value != null) _update(warehouse: value);
              }
            : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  /// The cached availability entry for [warehouseId], or `null` when this
  /// product was never looked up in that warehouse this session.
  WarehouseStock? _stockIn(int? warehouseId) {
    if (warehouseId == null) return null;
    final cache = ref.read(productStockCacheProvider)[widget.line.product];
    if (cache == null) return null;
    for (final entry in cache) {
      if (entry.warehouse == warehouseId) return entry;
    }
    return null;
  }

  /// The availability figure shown beside a warehouse in the picker
  /// (FR-022), trimmed for display; `null` when nothing is known.
  String? _availabilityIn(int warehouseId) {
    final stock = _stockIn(warehouseId);
    return stock == null ? null : formatQuantity(stock.available);
  }

  /// FR-025/FR-026: a non-blocking warning when the ordered quantity exceeds
  /// (or has no) availability in the line's chosen warehouse, per the
  /// stock snapshot cached at the moment the product was last looked up.
  String? _shortfall(
    AppLocalizations l10n,
    SaleLine line,
    List<WarehouseStock>? stockCache,
  ) {
    if (stockCache == null || line.warehouse == null) return null;
    final entry = _stockIn(line.warehouse);
    if (entry == null) return null;
    final available = Decimal.tryParse(entry.available) ?? Decimal.zero;
    final ordered = Decimal.tryParse(line.quantity) ?? Decimal.zero;
    if (available.sign <= 0) return l10n.posLineNoStock;
    if (ordered > available) return l10n.posLineShortfall(formatQuantity(entry.available));
    return null;
  }

  String _availableQuantity(List<WarehouseStock>? stockCache) =>
      _stockIn(widget.line.warehouse)?.available ?? '0';
}
