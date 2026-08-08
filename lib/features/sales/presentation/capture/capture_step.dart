import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
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
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
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
  AppError? _confirmError;
  bool _confirming = false;

  Future<void> _addLine(ProductLookupResult result, int? defaultWarehouse) async {
    ref.read(productStockCacheProvider.notifier).update(
      (cache) => {...cache, result.product: result.stock},
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

  Future<void> _confirm() async {
    setState(() {
      _confirming = true;
      _confirmError = null;
    });
    try {
      await ref.read(posSaleControllerProvider.notifier).confirm();
      if (mounted) ref.read(posStepControllerProvider.notifier).advanceToCobro();
    } on AppError catch (e) {
      setState(() => _confirmError = e);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
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

    final header = <Widget>[
      if (_confirmError != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: ErrorBanner(
            error: _confirmError!,
            onDismiss: () => setState(() => _confirmError = null),
          ),
        ),
      if (!enabled)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Text(l10n.posSaleReadOnlyBanner),
        ),
      // Both describe a sale, so they wait for one. Scanning creates it.
      if (sale != null) ...[
        Padding(
          padding: const EdgeInsets.all(12),
          child: CustomerBar(sale: sale, enabled: enabled),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FulfillmentModeSelector(sale: sale, enabled: enabled),
        ),
      ],
      Padding(
        // Keyed because this list changes shape underneath it: the customer
        // bar and mode selector appear above the search field the moment the
        // first lookup opens the sale. Matched by position instead, the
        // field's State would be destroyed mid-search and the product it
        // found would never be added — verified live, where the first scan
        // of a sale silently added nothing and the second worked.
        key: const Key('pos_product_search_field'),
        padding: const EdgeInsets.all(12),
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
                  ..._lines(sale, enabled, compact: true),
              ],
            ),
          )
        else ...[
          ...header,
          Expanded(
            child: sale == null || sale.lines.isEmpty
                ? Center(child: Text(l10n.posNoLinesHint))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: _lines(sale, enabled, compact: false),
                  ),
          ),
        ],
        if (sale != null) SaleTotalsBar(sale: sale),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            // A pinned bottom action is a thumb target on a phone, so it
            // takes the full width there rather than hugging one corner.
            width: compact ? double.infinity : null,
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: const Key('pos_continue_to_payment'),
                onPressed:
                    (enabled && (sale?.lineCount ?? 0) > 0 && !_confirming)
                    ? _confirm
                    : null,
                child: _confirming
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.posContinueToPayment),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// [SaleLineCard] on a phone, [SaleLineRow] anywhere wider — the same line,
  /// stacked or strung out (T098/T099).
  List<Widget> _lines(Sale sale, bool enabled, {required bool compact}) => [
    for (final line in sale.lines)
      if (compact)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
