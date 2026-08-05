import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One line, expanded tier (FR-022, FR-023): product, warehouse picker with
/// availability, quantity stepper, in-place price/discount/tax-rate edit,
/// line total, delete, and the non-blocking shortfall warning (FR-025,
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
  late final _quantity = TextEditingController(text: widget.line.quantity);
  late final _price = TextEditingController(text: widget.line.price);
  late final _discountRate = TextEditingController(text: widget.line.discountRate);
  late final _taxRate = TextEditingController(text: widget.line.taxRate);
  bool _busy = false;

  @override
  void didUpdateWidget(covariant SaleLineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line.quantity != widget.line.quantity) {
      _quantity.text = widget.line.quantity;
    }
    if (oldWidget.line.price != widget.line.price) _price.text = widget.line.price;
    if (oldWidget.line.discountRate != widget.line.discountRate) {
      _discountRate.text = widget.line.discountRate;
    }
    if (oldWidget.line.taxRate != widget.line.taxRate) _taxRate.text = widget.line.taxRate;
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
      // Rejected — restore the field to the last accepted value
      // (contracts/pos-screen.md §6); PosSaleController already left `state`
      // unchanged, so resetting the controller text is enough.
      _quantity.text = widget.line.quantity;
      _price.text = widget.line.price;
      _discountRate.text = widget.line.discountRate;
      _taxRate.text = widget.line.taxRate;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
                    onSubmitted: (v) => _update(discountRate: v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _taxRate,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLineTaxLabel),
                    onSubmitted: (v) => _update(taxRate: v),
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
          for (final w in list) DropdownMenuItem(value: w.warehouseId, child: Text(w.name)),
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

  /// FR-025/FR-026: a non-blocking warning when the ordered quantity exceeds
  /// (or has no) availability in the line's chosen warehouse, per the
  /// stock snapshot cached at the moment the product was last looked up.
  String? _shortfall(AppLocalizations l10n, SaleLine line, List<dynamic>? stockCache) {
    if (stockCache == null || line.warehouse == null) return null;
    final entry = stockCache
        .cast<dynamic>()
        .firstWhere((s) => s.warehouse == line.warehouse, orElse: () => null);
    if (entry == null) return null;
    final available = Decimal.tryParse(entry.available as String) ?? Decimal.zero;
    final ordered = Decimal.tryParse(line.quantity) ?? Decimal.zero;
    if (available.sign <= 0) return l10n.posLineNoStock;
    if (ordered > available) return l10n.posLineShortfall(available.toString());
    return null;
  }

  String _availableQuantity(List<dynamic>? stockCache) {
    final entry = stockCache
        ?.cast<dynamic>()
        .firstWhere((s) => s.warehouse == widget.line.warehouse, orElse: () => null);
    return (entry?.available as String?) ?? '0';
  }
}
