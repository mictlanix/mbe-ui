import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_editing.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_layout.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One line, expanded tier (FR-022, FR-023): product, warehouse picker with
/// availability, quantity stepper, unit, in-place price/discount/tax-rate
/// edit, line total, delete, and the non-blocking shortfall warning (FR-025,
/// FR-026). Read-only once `Sale.isEditable` is false (FR-041) — the caller
/// passes `enabled: false` rather than this row deciding on its own.
///
/// One row down to [saleLineSingleRowMinWidth], two rows below that
/// (spec 023 contracts/capture-surface.md §4) — driven by this row's own
/// available width via `LayoutBuilder`, never `MediaQuery`: the same row
/// renders inside a full-width workspace today and could sit inside a
/// narrower container tomorrow. `SaleLineCard` remains the compact tier's
/// arrangement, chosen by the caller as it always was.
///
/// Everything it *does* comes from [SaleLineEditing]; this is the wide
/// arrangement of it. See `SaleLineCard` for the compact one.
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

class _SaleLineRowState extends ConsumerState<SaleLineRow>
    with SaleLineEditing<SaleLineRow> {
  @override
  SaleLine get line => widget.line;

  @override
  int get facilityId => widget.facilityId;

  @override
  bool get lineEnabled => widget.enabled;

  @override
  void didUpdateWidget(covariant SaleLineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line != widget.line) syncFields();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final line = widget.line;
    final enabled = this.enabled;
    final shortfallText = shortfall(l10n);
    final spacing = Theme.of(context).spacing;

    return Card(
      key: Key('sale_line_row_${line.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) =>
                  saleLineLayoutFor(constraints.maxWidth) == SaleLineLayout.singleRow
                  ? _singleRow(context, l10n, line, enabled, spacing)
                  : _twoRow(context, l10n, line, enabled, spacing),
            ),
            if (shortfallText != null)
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
                        shortfallText,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    if (enabled)
                      TextButton(
                        onPressed: () => update(quantity: availableQuantity),
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

  // ── Shared field cells (contracts/capture-surface.md §4.2) ───────────────

  Widget _thumbnail() => const ProductPhoto(photoUrl: null, size: 36);

  /// Name prominent, code as a secondary mono-ish line beneath it — not
  /// `'code — name'` in one string (FR-039). The thumbnail sits beside it
  /// since both rows show it in the same leading position.
  Widget _productCell(BuildContext context, SaleLine line) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _thumbnail(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.productName,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                line.productCode,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _warehouseCell() => warehousePicker();

  /// A compact −/field/+ stepper. Sized generously (contracts' own 128 px,
  /// not the tighter 104 px first budgeted) after a widget test caught two
  /// `IconButton`s plus the field overflowing a tighter column even with
  /// `constraints`/`padding` both overridden — exactly the "budget, not
  /// measurement" case research R10 flagged.
  Widget _quantityStepper(AppLocalizations l10n, bool enabled) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _stepperButton(Icons.remove, enabled ? () => step(-1) : null, l10n.posLineDecreaseQuantity),
      SizedBox(
        // Wide enough for the floating `Cant.` label, which is broader than
        // the two or three digits the field itself holds — at 44 px the
        // label crowded the value instead of sitting clear of it. Still
        // inside the 128 px column: 28 + 64 + 28 = 120.
        width: 64,
        child: TextField(
          controller: quantityField,
          enabled: enabled,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.posLineQuantityLabel,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (v) => update(quantity: v),
        ),
      ),
      _stepperButton(Icons.add, enabled ? () => step(1) : null, l10n.posLineIncreaseQuantity),
    ],
  );

  /// `tapTargetSize: shrinkWrap` is what actually makes the 28 px
  /// `constraints` below hold: without it Material adds its 48 px minimum
  /// tap target around the button, which is why an earlier, apparently
  /// generous column still overflowed with `padding`/`constraints` already
  /// overridden. Dropping below the 48 px target is deliberate and confined
  /// to this arrangement — the single row is only ever laid out at
  /// [saleLineSingleRowMinWidth] and above, where the input is a pointer
  /// (contracts/capture-surface.md §6); the phone tier renders
  /// `SaleLineCard`, whose steppers keep Material's full touch target.
  Widget _stepperButton(IconData icon, VoidCallback? onPressed, String tooltip) => IconButton(
    icon: Icon(icon, size: 16),
    tooltip: tooltip,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
    visualDensity: VisualDensity.compact,
    style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    onPressed: onPressed,
  );

  /// One line, always: a unit that does not fit its column ellipsizes rather
  /// than wrapping, which would push the whole row taller (`Cubeta` did
  /// exactly that at the column's first 36 px width). Units are still absent
  /// from every payload the POS reads (mbe-api#145), so this renders nothing
  /// today — the column is sized for what it will carry, not for what it
  /// currently does.
  Widget _unitCell(SaleLine line) => line.unit == null
      ? const SizedBox.shrink()
      : Text(
          line.unit!,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

  Widget _rateField({
    required TextEditingController controller,
    required bool enabled,
    required String label,
    required ValueChanged<String> onSubmitted,
  }) => TextField(
    controller: controller,
    enabled: enabled,
    textAlign: TextAlign.end,
    style: Theme.of(context).textTheme.bodySmall,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, isDense: true),
    onSubmitted: onSubmitted,
  );

  Widget _totalCell(SaleLine line) => Text(
    MoneyFormatters.currency(line.total),
    textAlign: TextAlign.right,
    style: Theme.of(context).textTheme.bodyMedium,
  );

  Widget _deleteButton(AppLocalizations l10n, bool enabled) => IconButton(
    icon: const Icon(Icons.delete_outline),
    onPressed: enabled ? removeLine : null,
    tooltip: l10n.posRemoveLineTooltip,
  );

  // ── Layouts ───────────────────────────────────────────────────────────

  /// contracts/capture-surface.md §4.2 — thumbnail 36, product flex (min
  /// 200 by construction of [saleLineSingleRowMinWidth]), warehouse 140,
  /// quantity 128, unit 36, price 84, discount 68, tax 68, total 96,
  /// delete (unconstrained); `spacing.xs` gaps throughout.
  Widget _singleRow(
    BuildContext context,
    AppLocalizations l10n,
    SaleLine line,
    bool enabled,
    Spacing spacing,
  ) {
    final gap = SizedBox(width: spacing.xs);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _productCell(context, line)),
        gap,
        SizedBox(width: 140, child: _warehouseCell()),
        gap,
        SizedBox(width: 128, child: _quantityStepper(l10n, enabled)),
        gap,
        SizedBox(width: 56, child: _unitCell(line)),
        gap,
        SizedBox(
          width: 84,
          child: _rateField(
            controller: priceField,
            enabled: enabled,
            label: l10n.posLinePriceLabel,
            onSubmitted: (v) => update(price: v),
          ),
        ),
        gap,
        SizedBox(
          width: 68,
          child: _rateField(
            controller: discountField,
            enabled: enabled,
            label: l10n.posLineDiscountLabel,
            onSubmitted: (v) => updateRate(discountRate: v),
          ),
        ),
        gap,
        SizedBox(
          width: 68,
          child: _rateField(
            controller: taxField,
            enabled: enabled,
            label: l10n.posLineTaxLabel,
            onSubmitted: (v) => updateRate(taxRate: v),
          ),
        ),
        gap,
        SizedBox(width: 96, child: _totalCell(line)),
        _deleteButton(l10n, enabled),
      ],
    );
  }

  /// contracts/capture-surface.md §4.3 — row 1: thumbnail, product,
  /// warehouse, total, delete; row 2: quantity, unit, price, discount, tax.
  /// Nothing dropped, nothing read-only that was editable in the single row.
  Widget _twoRow(
    BuildContext context,
    AppLocalizations l10n,
    SaleLine line,
    bool enabled,
    Spacing spacing,
  ) {
    final gap = SizedBox(width: spacing.xs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _productCell(context, line)),
            gap,
            SizedBox(width: 140, child: _warehouseCell()),
            gap,
            SizedBox(width: 96, child: _totalCell(line)),
            _deleteButton(l10n, enabled),
          ],
        ),
        SizedBox(height: spacing.xxs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _quantityStepper(l10n, enabled),
            gap,
            SizedBox(width: 56, child: _unitCell(line)),
            gap,
            Expanded(
              child: _rateField(
                controller: priceField,
                enabled: enabled,
                label: l10n.posLinePriceLabel,
                onSubmitted: (v) => update(price: v),
              ),
            ),
            gap,
            Expanded(
              child: _rateField(
                controller: discountField,
                enabled: enabled,
                label: l10n.posLineDiscountLabel,
                onSubmitted: (v) => updateRate(discountRate: v),
              ),
            ),
            gap,
            Expanded(
              child: _rateField(
                controller: taxField,
                enabled: enabled,
                label: l10n.posLineTaxLabel,
                onSubmitted: (v) => updateRate(taxRate: v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
