import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/customer_bar.dart';
import 'package:mbe_ui/features/sales/presentation/capture/default_warehouse_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/fulfillment_mode_selector.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';
import 'package:mbe_ui/features/sales/presentation/pos_confirm.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/features/sales/presentation/unconfirmed_edits_resolver.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The Venta step (contracts/pos-screen.md §3): customer, fulfilment mode,
/// main delivery address, terms and lines. Composes [CustomerBar],
/// [FulfillmentModeSelector], [ProductSearchField], [SaleLineRow] and
/// [SaleTotalsBar]; "Continuar al cobro" is enabled only once at least one
/// line exists (FR-038) and, on success, advances `PosStepController` to
/// `cobro` (§2). A confirm rejected for zero-priced lines or insufficient
/// stock is shown as a banner here and the step stays on Venta (FR-039, §6).
/// The server names each offending line in its refusal — the repository
/// flattens `{"message", "lines"}` into the banner text — so the cashier is
/// told which products are at fault, by name, not merely that something is
/// wrong.
class CaptureStep extends ConsumerStatefulWidget {
  const CaptureStep({super.key, required this.sale});

  /// `null` on a register nobody has started a sale on yet. The search field
  /// still works — scanning is what opens the sale — but everything that
  /// describes a sale (customer, fulfilment mode, totals) has nothing to
  /// describe until then.
  final Sale? sale;

  @override
  ConsumerState<CaptureStep> createState() => _CaptureStepState();
}

class _CaptureStepState extends ConsumerState<CaptureStep> {
  Future<void> _addLine(ProductLookupResult result, int? defaultWarehouse) async {
    ref.read(productStockCacheProvider.notifier).update(
      (cache) => {...cache, result.product: result.stock},
    );
    // The product table's tax rate, cached for the line's tax picker
    // (FR-038b) — the lookup is the only payload that carries it.
    ref.read(productTaxRateCacheProvider.notifier).update(
      (cache) => {...cache, result.product: result.taxRate},
    );
    await ref
        .read(posSaleControllerProvider.notifier)
        .addLine(
          product: result.product,
          quantity: _initialQuantity(result),
          warehouse: defaultWarehouse,
        );
  }

  /// `minOrderQty` pre-fills the quantity (data-model.md §3), but a line's
  /// quantity must be `> 0` (§2) — and most products carry `minOrderQty: 0`,
  /// where mbe-api's own default would create a zero-quantity, zero-total
  /// line that confirmation then refuses (verified against a live backend).
  /// A scan means "one of these", so zero floors to one.
  String _initialQuantity(ProductLookupResult result) =>
      result.minOrderQty > 0 ? '${result.minOrderQty}' : '1';

  /// spec 036 FR-008: advancing to Cobro is a pure client-side step change —
  /// it no longer calls `confirm()` (that now happens just before the first
  /// action that actually needs `completed` status: a payment, a delivery
  /// destination, or leaving Cobro on credit terms — `pos_confirm.dart`).
  /// The sale therefore stays `draft`, and can be returned to and edited,
  /// for as long as the cashier remains on Cobro/Entrega without having
  /// triggered one of those.
  void _advanceToCobro() {
    ref.read(posStepControllerProvider.notifier).advanceToCobro();
  }

  /// What "Continuar al cobro" actually calls (spec 031 FR-024…FR-030):
  /// unconfirmed text anywhere on the step raises a decision before advancing
  /// ever happens, rather than the step silently discarding or silently
  /// committing it. [resolveUnconfirmedEdits] is what makes that decision
  /// (spec 029 research §R12 — extracted so the back-office order screen's
  /// own confirm resolves it identically, on its own scope); this is now
  /// only the step-specific half: proceed to Cobro when it says to.
  Future<void> _onContinuePressed() async {
    final proceed = await resolveUnconfirmedEdits(context, ref, posWritesScope);
    if (proceed && mounted) _advanceToCobro();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sale = widget.sale;
    final enabled = sale?.isEditable ?? true;
    final compact = LayoutBreakpoints.isCompact(context);
    // The register's own point of sale, known from the signed-in user's
    // settings before any sale exists — so the first scan already lands in
    // the right warehouse (FR-024) instead of one resolved a beat too late.
    final pointSale = sale?.pointSale ?? ref.watch(registerPointSaleProvider);
    final defaultWarehouse = pointSale == null
        ? const AsyncValue<int>.loading()
        : ref.watch(defaultWarehouseControllerProvider(pointSale));
    // spec 031 FR-007: additional to every condition below, not instead of
    // any of them — a line write still outstanding must not let the cashier
    // advance on figures the sale does not hold yet (issue #164).
    final writesPending = ref.watch(pendingWritesProvider(posWritesScope)) > 0;
    final spacing = Theme.of(context).spacing;
    // One horizontal margin for every header item, applied once per item
    // rather than each widget also carrying its own — the doubled
    // `EdgeInsets.all(12)` this replaces (the step's own wrapper *and*
    // CustomerBar's Card padding) was what misaligned the customer card's
    // edges against the search field below it (spec 023 research R12).
    final horizontalInset = EdgeInsets.symmetric(horizontal: spacing.screenMargin);
    // spec 036 R1: a `confirm()` failure triggered from payment, delivery, or
    // leaving Cobro on credit terms lands here — the step machine already
    // jumped back to Venta by the time this renders.
    final confirmError = ref.watch(confirmErrorProvider);

    final header = <Widget>[
      if (confirmError != null)
        Padding(
          padding: horizontalInset.add(EdgeInsets.only(top: spacing.xs)),
          child: ErrorBanner(
            error: confirmError,
            onDismiss: () => ref.read(confirmErrorProvider.notifier).state = null,
          ),
        ),
      if (!enabled)
        Padding(
          padding: horizontalInset.add(EdgeInsets.only(top: spacing.xs)),
          child: Text(l10n.posSaleReadOnlyBanner),
        ),
      // Rendered from the first frame, sale or no sale: both fall back to
      // the walk-in customer mbe-api would raise the sale against anyway
      // (`posDefaultCustomerId`), so the step opens as the surface the
      // cashier works on rather than as a bare search field that grows a
      // header the instant the first scan lands — which shoved the field and
      // every line down with it. Neither writes anything before the cashier
      // acts, and both actions that *do* write open the sale themselves
      // (`PosSaleController.updateHeader`), so the anti-empty-draft rule is
      // untouched.
      //
      // Beside each other at ≥ 840 px (contracts/capture-surface.md §2,
      // matching the mock's frame `2a`); phone/tablet-portrait widths keep
      // them stacked, where a three-segment mode control has no room left
      // beside the customer band.
      Padding(
          // Top inset only: the search field below carries its own, and
          // doubling them left a dead band between the two (the mock's own
          // customer row is `12px 24px 0` for the same reason).
          padding: horizontalInset.add(EdgeInsets.only(top: spacing.sm)),
          child: LayoutBreakpoints.isExpanded(context)
              ? Row(
                  // Centred, not top-aligned: the mode control is a single
                  // 56 px pill while the customer band is a taller card, so
                  // `start` pinned it to the band's top edge and read as
                  // misaligned. The mock centres the pair (`align-items:
                  // center`) for exactly this reason.
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: CustomerBar(sale: sale, enabled: enabled)),
                    SizedBox(width: spacing.sm),
                    FulfillmentModeSelector(sale: sale, enabled: enabled),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomerBar(sale: sale, enabled: enabled),
                    SizedBox(height: spacing.sm),
                    // Stretched here and only here: stacked, it is one element
                    // in a column where the band above it and the search field
                    // below both run margin to margin, and a track hugging its
                    // labels leaves dead space against the trailing edge —
                    // most of it at tablet-portrait widths, where the natural
                    // track is far narrower than the column.
                    FulfillmentModeSelector(
                      sale: sale,
                      enabled: enabled,
                      stretch: true,
                    ),
                  ],
                ),
        ),
      Padding(
        // Keyed because this list changes shape underneath it: the customer
        // bar and mode selector appear above the search field the moment the
        // first lookup opens the sale. Matched by position instead, the
        // field's State would be destroyed mid-search and the product it
        // found would never be added — verified live, where the first scan
        // of a sale silently added nothing and the second worked.
        key: const Key('pos_product_search_field'),
        padding: horizontalInset.add(EdgeInsets.symmetric(vertical: spacing.sm)),
        child: ProductSearchField(
          enabled: enabled,
          warehouse: defaultWarehouse.value,
          onProductSelected: (result) => _addLine(result, defaultWarehouse.value),
        ),
      ),
    ];

    // FR-053/SC-007: on a phone the whole capture surface — customer, mode,
    // search and lines — scrolls as one, because none of it fits alongside
    // the rest. Only the totals and the primary action stay put, so the
    // cashier can always see the figure and reach "continue" without
    // scrolling back. Wider tiers keep the fixed header they have room for.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact)
          Expanded(
            child: ListView(
              children: [
                ...header,
                if (sale == null || sale.lines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(l10n.posNoLinesHint)),
                  )
                else
                  ..._lines(sale, enabled, compact: true, inset: horizontalInset),
              ],
            ),
          )
        else ...[
          ...header,
          Expanded(
            child: sale == null || sale.lines.isEmpty
                ? Center(child: Text(l10n.posNoLinesHint))
                : ListView(
                    // The same inset every header item carries, so a line's
                    // edges sit directly under the search field's rather than
                    // 12 px inside them.
                    padding: horizontalInset,
                    children: _lines(sale, enabled, compact: false),
                  ),
          ),
        ],
        // One footer band: the primary action lives inside SaleTotalsBar
        // now, not in a second Padding block beneath it (contracts/
        // pos-workspace.md §3.1) — the extra band was exactly the dead
        // vertical space the workspace exists to reclaim. Rendered
        // unconditionally, same as the button always was — SaleTotalsBar
        // itself skips the stats when there is no sale yet.
        SaleTotalsBar(
          sale: sale,
          compact: compact,
          // spec 036 FR-008: advancing to Cobro is synchronous now (no
          // server round-trip), so there is nothing left for this to show a
          // spinner for.
          confirming: false,
          onContinue: (enabled && (sale?.lineCount ?? 0) > 0 && !writesPending)
              ? _onContinuePressed
              : null,
        ),
      ],
    );
  }

  /// [SaleLineCard] on a phone, [SaleLineRow] anywhere wider — the same line,
  /// stacked or strung out (T098/T099).
  ///
  /// [inset] is the step's own horizontal margin. On a phone the cards are
  /// items in the one scrolling list, so each carries it directly; wider tiers
  /// put it on the lines `ListView` instead.
  List<Widget> _lines(
    Sale sale,
    bool enabled, {
    required bool compact,
    EdgeInsets inset = EdgeInsets.zero,
  }) => [
    for (final line in sale.lines)
      if (compact)
        Padding(
          padding: inset,
          child: SaleLineCard(
            key: ValueKey(line.id),
            line: line,
            facilityId: sale.facility,
            enabled: enabled,
          ),
        )
      else
        SaleLineRow(
          key: ValueKey(line.id),
          line: line,
          facilityId: sale.facility,
          enabled: enabled,
        ),
  ];
}
