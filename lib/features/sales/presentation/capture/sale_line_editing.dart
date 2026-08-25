import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/quantity_stepper.dart';
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

  /// The scope this line's writes and unconfirmed edits register against —
  /// `posWritesScope` for the register, `salesOrderWritesScope` for the
  /// back-office order screen (spec 029 FR-038). Read once here rather than
  /// inline at each call site below, since [quantityStepper] and
  /// [discountField] are both `late final` and would otherwise each read it
  /// twice.
  late final String _writesScope = ref.read(saleWritesScopeProvider);

  // Fields hold display-formatted text (FR-022) — two-decimal prices and
  // rates as the percentages their labels claim. [syncFields] converts back
  // whenever the server's copy changes underneath. Quantity is no longer one
  // of these — [quantityStepper] owns it (spec 030).
  //
  /// The debounced quantity control (spec 030 FR-001…FR-016), shared with the
  /// delivery destination card. Floored at one unit — a line is removed with
  /// [removeLine], never stepped to zero — and uncapped: stock is a
  /// non-blocking warning on this surface ([shortfall]), never a bound.
  /// [onCommit] is [_commitQuantity], which does **not** set [_busy] (FR-004)
  /// but does share every other field's write queue ([_enqueue], research
  /// R6) so two writes for this line are never in flight together.
  late final quantityStepper = QuantityStepperController(
    value: line.quantity,
    min: '1',
    onCommit: _commitQuantity,
    // spec 031 FR-004: a stepped-but-not-yet-sent quantity holds the gate
    // for the whole of its ~400 ms coalescing window, not just the request
    // that eventually follows it — otherwise a tap-then-continue could still
    // advance on the pre-tap total, the bug this feature exists to remove.
    pendingWrites: ref.read(pendingWritesProvider(_writesScope).notifier),
    // spec 031 FR-024, FR-030: typed-but-unconfirmed quantity text raises
    // the same step-boundary question the discount field does — the rule
    // lives once in the shared base, so both fields get it without either
    // one asking for it specially.
    unconfirmedEdits: ref.read(unconfirmedEditsProvider(_writesScope).notifier),
  );

  /// Read-only (FR-038c): a line's price comes from the customer's price list
  /// and is never typed over here. The controller stays because the price is
  /// still *displayed* in a field, and still has to follow the server's copy.
  late final priceField = TextEditingController(
    text: ref.read(formattersProvider).field.price(line.price),
  );

  /// The discount, typed as a percentage but stored as a `0 ≤ r ≤ 1` rate.
  /// Spec 031 FR-013…FR-018: confirmed only by Enter, discarded — visibly,
  /// with the same acknowledgement the quantity stepper uses — on focus
  /// loss, on unparseable text, and on a server refusal, sharing
  /// [ConfirmableFieldController] rather than reimplementing the rule.
  late final discountField = ConfirmableFieldController(
    value: line.discountRate,
    parse: (text) => ref.read(formattersProvider).field.parseRate(text),
    commit: _commitDiscount,
    // spec 031 FR-024, FR-030: registers so the step's own continue action
    // can find this field's unconfirmed text and ask about it, rather than
    // the field silently discarding or the step silently advancing.
    unconfirmedEdits: ref.read(unconfirmedEditsProvider(_writesScope).notifier),
  );

  /// The per-line comment (spec 029 FR-020, `showComment` on the host
  /// widget) — same confirm-or-visibly-discard rule as [discountField],
  /// shared rather than reimplemented. Rendered only when the host opts in;
  /// the register never builds this controller's field, so it never
  /// registers with the write-gating scope either.
  late final commentField = ConfirmableFieldController(
    value: line.comment ?? '',
    parse: (text) => text,
    commit: _commitComment,
    unconfirmedEdits: ref.read(unconfirmedEditsProvider(_writesScope).notifier),
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

  /// Serializes every write this line makes — quantity included — so two
  /// never land in flight together (spec 030 research R6). Without it,
  /// `PosSaleController.updateLine` replacing the *whole sale* on each
  /// response would let the later one silently revert the earlier: `_busy`
  /// used to prevent that by inerting the whole line for every write, which
  /// is exactly the freeze this feature removes from the quantity path.
  Future<void> _writes = Future<void>.value();

  Future<R> _enqueue<R>(Future<R> Function() action) {
    final result = _writes.then((_) => action());
    _writes = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// True while a **non-quantity** edit is in flight; those controls stay
  /// inert until it settles, as before this feature. The quantity stepper is
  /// deliberately not gated by this (FR-004) — its own controller stays live
  /// through its own commits, and [_enqueue] is what keeps its writes from
  /// racing with these.
  bool get enabled => lineEnabled && !_busy;

  /// Re-renders every field from the line's authoritative values.
  ///
  /// [discountField] takes the raw wire value, not a formatted string — it
  /// is a [ConfirmableFieldController] now, and its own `sync` is what
  /// decides whether an external change should discard unconfirmed typed
  /// text (spec 031 FR-018), the same rule [quantityStepper] already has.
  ///
  /// [commentField] is deliberately **not** synced here: it is a `late
  /// final` that only initializes if a host widget with `showComment: true`
  /// actually reads it, and syncing it unconditionally would initialize it
  /// on every POS line too, registering a comment field the register never
  /// renders. A host that opts in syncs (and disposes) it itself.
  void syncFields() {
    final fmt = ref.read(formattersProvider);
    quantityStepper.sync(value: line.quantity);
    priceField.text = fmt.field.price(line.price);
    discountField.sync(value: line.discountRate);
  }

  @override
  void dispose() {
    quantityStepper.dispose();
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
      await _enqueue(
        () => ref
            .read(saleEditorProvider)
            .updateLine(
              lineId: line.id,
              quantity: quantity,
              discountRate: discountRate,
              taxRate: taxRate,
              warehouse: warehouse,
            ),
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

  /// [quantityStepper]'s `onCommit` (spec 030 research R3): performs the
  /// write, queued behind every other pending write for this line, and
  /// reports whether it stuck rather than throwing — a caught `AppError`
  /// becomes `false`, which is what makes the controller restore the last
  /// accepted quantity and animate the reset (FR-013). Deliberately does not
  /// touch [_busy]: the quantity control stays live through its own writes
  /// (FR-004).
  Future<bool> _commitQuantity(String value) async {
    try {
      await _enqueue(
        () => ref
            .read(saleEditorProvider)
            .updateLine(lineId: line.id, quantity: value),
      );
      return true;
    } on Object {
      return false;
    }
  }

  /// [discountField]'s `commit` (spec 031 FR-019, mirroring [_commitQuantity]'s
  /// shape): performs the write, queued behind every other pending write for
  /// this line, and reports whether it stuck rather than throwing — `false`
  /// is what makes the controller restore the line's own discount and
  /// animate the reset (FR-017), instead of the silent `syncFields()`
  /// rewrite this replaces. Unlike [_commitQuantity], this **does** toggle
  /// [_busy]: the line's other controls still go inert for the duration of a
  /// discount write, exactly as before this feature (FR-019).
  Future<bool> _commitDiscount(String rate) async {
    setState(() => _busy = true);
    try {
      await _enqueue(
        () => ref
            .read(saleEditorProvider)
            .updateLine(lineId: line.id, discountRate: rate),
      );
      return true;
    } on Object {
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// [commentField]'s `commit` (spec 029 FR-020) — same shape as
  /// [_commitDiscount]. Only ever called from a host that opted into
  /// `showComment: true`.
  Future<bool> _commitComment(String value) async {
    setState(() => _busy = true);
    try {
      await _enqueue(
        () => ref
            .read(saleEditorProvider)
            .updateLine(lineId: line.id, comment: value.isEmpty ? null : value),
      );
      return true;
    } on Object {
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
      ref.read(saleEditorProvider).removeLine(line.id);

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
