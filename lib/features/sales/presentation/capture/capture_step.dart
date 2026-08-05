import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/customer_bar.dart';
import 'package:mbe_ui/features/sales/presentation/capture/default_warehouse_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/fulfillment_mode_selector.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
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

  final Sale sale;

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
    final enabled = sale.isEditable;
    final defaultWarehouse = ref.watch(
      defaultWarehouseControllerProvider(sale.pointSale),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Padding(
          padding: const EdgeInsets.all(12),
          child: CustomerBar(sale: sale, enabled: enabled),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FulfillmentModeSelector(enabled: enabled),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ProductSearchField(
            enabled: enabled,
            warehouse: defaultWarehouse.value,
            onProductSelected: (result) => _addLine(result, defaultWarehouse.value),
          ),
        ),
        Expanded(
          child: sale.lines.isEmpty
              ? Center(child: Text(l10n.posNoLinesHint))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final line in sale.lines)
                      SaleLineRow(
                        key: ValueKey(line.id),
                        line: line,
                        facilityId: sale.facility,
                        enabled: enabled,
                      ),
                  ],
                ),
        ),
        SaleTotalsBar(sale: sale),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: (enabled && sale.lineCount > 0 && !_confirming) ? _confirm : null,
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
      ],
    );
  }
}
