import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Everything a sale line does, minus how it is laid out: the
/// display-formatted field controllers, the server round-trip behind every
/// edit, the warehouse picker and the stock-shortfall warning.
///
/// `SaleLineRow` (expanded tier) and `SaleLineCard` (compact tier, US5/FR-053)
/// differ **only** in arrangement — one wide row of controls versus a stacked
/// card — so the behaviour lives here once rather than in both.
mixin SaleLineEditing<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// The line being edited, and the facility whose warehouses may hold it.
  SaleLine get line;
  int get facilityId;

  /// False once `Sale.isEditable` is (FR-041) — decided by the caller, never
  /// by the line itself.
  bool get lineEnabled;

  // Fields hold display-formatted text (FR-022) — trimmed quantities,
  // two-decimal prices, and rates as the percentages their labels claim.
  // [syncFields] converts back whenever the server's copy changes underneath.
  late final quantityField = TextEditingController(
    text: formatQuantity(line.quantity),
  );
  late final priceField = TextEditingController(text: formatPrice(line.price));
  late final discountField = TextEditingController(
    text: formatRateAsPercent(line.discountRate),
  );
  late final taxField = TextEditingController(
    text: formatRateAsPercent(line.taxRate),
  );

  bool _busy = false;

  /// True while an edit is in flight; controls stay inert until it settles.
  bool get enabled => lineEnabled && !_busy;

  /// Re-renders every field from the line's authoritative values.
  void syncFields() {
    quantityField.text = formatQuantity(line.quantity);
    priceField.text = formatPrice(line.price);
    discountField.text = formatRateAsPercent(line.discountRate);
    taxField.text = formatRateAsPercent(line.taxRate);
  }

  @override
  void dispose() {
    quantityField.dispose();
    priceField.dispose();
    discountField.dispose();
    taxField.dispose();
    super.dispose();
  }

  Future<void> update({
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
            lineId: line.id,
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
      syncFields();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Discount and tax are typed as percentages but stored as `0 ≤ r ≤ 1`
  /// rates. A non-numeric entry is refused outright rather than sent.
  Future<void> updateRate({String? discountRate, String? taxRate}) async {
    final rawDiscount = discountRate == null
        ? null
        : parsePercentAsRate(discountRate);
    final rawTax = taxRate == null ? null : parsePercentAsRate(taxRate);
    if ((discountRate != null && rawDiscount == null) ||
        (taxRate != null && rawTax == null)) {
      syncFields();
      return;
    }
    await update(discountRate: rawDiscount, taxRate: rawTax);
  }

  Future<void> removeLine() =>
      ref.read(posSaleControllerProvider.notifier).removeLine(line.id);

  void step(int delta) {
    final next = Decimal.parse(quantityField.text) + Decimal.fromInt(delta);
    if (next.sign <= 0) return;
    final text = next.toString();
    quantityField.text = text;
    update(quantity: text);
  }

  Widget warehousePicker() {
    final l10n = AppLocalizations.of(context)!;
    final warehouses = ref.watch(
      facilityWarehousesControllerProvider(facilityId),
    );
    final canEdit = enabled;
    return warehouses.when(
      data: (list) => DropdownButtonFormField<int>(
        initialValue: line.warehouse,
        isExpanded: true,
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
        onChanged: canEdit
            ? (value) {
                if (value != null) update(warehouse: value);
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
    final cache = ref.read(productStockCacheProvider)[line.product];
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
  /// (or has no) availability in the line's chosen warehouse, per the stock
  /// snapshot cached at the moment the product was last looked up. `null`
  /// when there is nothing to warn about.
  String? shortfall(AppLocalizations l10n) {
    final cached = ref.watch(productStockCacheProvider)[line.product];
    if (cached == null || line.warehouse == null) return null;
    final entry = _stockIn(line.warehouse);
    if (entry == null) return null;
    final available = Decimal.tryParse(entry.available) ?? Decimal.zero;
    final ordered = Decimal.tryParse(line.quantity) ?? Decimal.zero;
    if (available.sign <= 0) return l10n.posLineNoStock;
    if (ordered > available) {
      return l10n.posLineShortfall(formatQuantity(entry.available));
    }
    return null;
  }

  /// What "adjust to available" sets the quantity to (FR-026).
  String get availableQuantity => _stockIn(line.warehouse)?.available ?? '0';
}
