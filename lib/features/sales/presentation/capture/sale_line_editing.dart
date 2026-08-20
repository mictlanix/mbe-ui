import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
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
    text: ref.read(formattersProvider).field.quantity(line.quantity),
  );

  /// Read-only (FR-038c): a line's price comes from the customer's price list
  /// and is never typed over here. The controller stays because the price is
  /// still *displayed* in a field, and still has to follow the server's copy.
  late final priceField = TextEditingController(
    text: ref.read(formattersProvider).field.price(line.price),
  );
  late final discountField = TextEditingController(
    text: ref.read(formattersProvider).field.rate(line.discountRate),
  );

  bool _busy = false;

  /// Bumped every time an edit is refused, and mixed into both pickers' keys.
  ///
  /// A rejected edit leaves `line` exactly as it was, so a picker seeded from
  /// it sees no change in its `initialValue` and goes on displaying the value
  /// the server just refused — `FormField` holds that selection in its own
  /// state, which is why [syncFields]' controller assignments cannot reach it.
  /// Changing the key discards that state, and the rebuilt picker reads the
  /// line again.
  int _rejections = 0;

  /// True while an edit is in flight; controls stay inert until it settles.
  bool get enabled => lineEnabled && !_busy;

  /// Re-renders every field from the line's authoritative values.
  void syncFields() {
    final fmt = ref.read(formattersProvider);
    quantityField.text = fmt.field.quantity(line.quantity);
    priceField.text = fmt.field.price(line.price);
    discountField.text = fmt.field.rate(line.discountRate);
  }

  @override
  void dispose() {
    quantityField.dispose();
    priceField.dispose();
    discountField.dispose();
    super.dispose();
  }

  /// `price` is deliberately absent (FR-038c): the price is read-only on the
  /// capture surface, so nothing here can write one. mbe-api still accepts a
  /// price on `PUT .../lines/{id}` — the repository keeps that parameter — but
  /// this screen no longer offers it.
  Future<void> update({
    String? quantity,
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
            discountRate: discountRate,
            taxRate: taxRate,
            warehouse: warehouse,
          );
    } on Object {
      // Rejected — restore the controls to the last accepted values
      // (contracts/pos-screen.md §6); PosSaleController already left `state`
      // unchanged, so re-reading the line is enough for the text fields, and
      // [_rejections] is what makes the pickers re-read it too.
      syncFields();
      _rejections++;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The discount is typed as a percentage but stored as a `0 ≤ r ≤ 1` rate.
  /// A non-numeric entry is refused outright rather than sent.
  ///
  /// Tax no longer comes through here — it is chosen, not typed (FR-038b); see
  /// [selectTaxRate].
  Future<void> updateRate({required String discountRate}) async {
    final raw = ref.read(formattersProvider).field.parseRate(discountRate);
    if (raw == null) {
      syncFields();
      return;
    }
    await update(discountRate: raw);
  }

  /// The rates a line's tax picker offers (FR-038b): the product table's own
  /// rate and none, ascending.
  ///
  /// The product's rate is whatever the last lookup for this product reported
  /// ([productTaxRateCacheProvider]); with nothing cached — a sale resumed in a
  /// fresh session — the line's own rate stands in, because that is the rate
  /// the server took from the product table when the line was created. The
  /// line's current rate is always in the list even when it is neither of the
  /// two, so the picker always has a value to show rather than asserting: a
  /// line carrying some third rate can be moved to the product's or to zero,
  /// but is never silently rewritten just by rendering.
  ///
  /// The one case this cannot cover is a resumed line already at zero whose
  /// product has not been looked up: its own rate says nothing about the
  /// product's, so only zero is offered until mbe-api exposes the product's
  /// rate on the sale-line payload (the same shape of backend dependency as
  /// the line thumbnail, research R11).
  List<Decimal> get taxRateOptions {
    final current = _rateOf(line.taxRate);
    final cached = ref.watch(productTaxRateCacheProvider)[line.product];
    final fromProduct = cached != null ? _rateOf(cached) : current;
    return {Decimal.zero, current, fromProduct}.toList()..sort();
  }

  /// The picker's current value — always one of [taxRateOptions].
  Decimal get selectedTaxRate => _rateOf(line.taxRate);

  Future<void> selectTaxRate(Decimal rate) => update(taxRate: rate.toString());

  Decimal _rateOf(String raw) => Decimal.tryParse(raw) ?? Decimal.zero;

  /// The line's tax rate as a picker rather than a free-text field (FR-038b),
  /// shared by both layouts. [decoration] lets each tier supply its own
  /// sizing; the label and the items are the same either way.
  Widget taxRatePicker({InputDecoration? decoration, TextStyle? style}) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    return KeyedSubtree(
      key: ValueKey('tax-$_rejections'),
      child: DropdownButtonFormField<Decimal>(
        key: const Key('pos_line_tax_rate_picker'),
        initialValue: selectedTaxRate,
        isExpanded: true,
        style: style,
        decoration:
            decoration ?? InputDecoration(labelText: l10n.posLineTaxLabel),
        items: [
          for (final rate in taxRateOptions)
            DropdownMenuItem(
              value: rate,
              child: Text(fmt.display.percent(rate.toString())),
            ),
        ],
        onChanged: enabled
            ? (value) {
                if (value != null && value != selectedTaxRate) {
                  selectTaxRate(value);
                }
              }
            : null,
      ),
    );
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

  /// [decoration] and [style] let each tier size the picker as its own band
  /// requires; both default to Material's own, which is what the compact card
  /// wants.
  Widget warehousePicker({InputDecoration? decoration, TextStyle? style}) {
    final l10n = AppLocalizations.of(context)!;
    final warehouses = ref.watch(
      facilityWarehousesControllerProvider(facilityId),
    );
    final canEdit = enabled;
    return warehouses.when(
      data: (list) => KeyedSubtree(
        // As for the tax picker: a refused warehouse change must not leave the
        // refused warehouse on screen.
        key: ValueKey('warehouse-$_rejections'),
        child: DropdownButtonFormField<int>(
          initialValue: line.warehouse,
          isExpanded: true,
          style: style,
          decoration:
              decoration ??
              InputDecoration(labelText: l10n.posLineWarehouseLabel),
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
                    Flexible(
                      child: Text(w.name, overflow: TextOverflow.ellipsis),
                    ),
                    if (_availabilityIn(w.warehouseId)
                        case final available?) ...[
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
    return stock == null ? null : ref.read(formattersProvider).field.quantity(stock.available);
  }

  /// FR-025/FR-026: a non-blocking warning when the ordered quantity exceeds
  /// (or has no) availability in the line's chosen warehouse, per the stock
  /// snapshot cached at the moment the product was last looked up. `null`
  /// when there is nothing to warn about.
  String? shortfall(AppLocalizations l10n) {
    final cached = ref.watch(productStockCacheProvider)[line.product];
    final fmt = ref.watch(formattersProvider);
    if (cached == null || line.warehouse == null) return null;
    final entry = _stockIn(line.warehouse);
    if (entry == null) return null;
    final available = Decimal.tryParse(entry.available) ?? Decimal.zero;
    final ordered = Decimal.tryParse(line.quantity) ?? Decimal.zero;
    if (available.sign <= 0) return l10n.posLineNoStock;
    if (ordered > available) {
      return l10n.posLineShortfall(fmt.field.quantity(entry.available));
    }
    return null;
  }

  /// What "adjust to available" sets the quantity to (FR-026).
  String get availableQuantity => _stockIn(line.warehouse)?.available ?? '0';
}
