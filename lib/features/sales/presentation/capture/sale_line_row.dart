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
/// availability, quantity stepper carrying the unit, the price read-only
/// (FR-038c), an editable discount, a tax rate chosen from the product's own
/// or none (FR-038b), line total, delete, and the non-blocking shortfall
/// warning (FR-025, FR-026). Read-only once `Sale.isEditable` is false
/// (FR-041) — the caller passes `enabled: false` rather than this row
/// deciding on its own.
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
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Card(
      key: Key('sale_line_row_${line.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      // Outlined, like the customer band: the lines are the surface the
      // cashier reads down, and an edge is what separates one from the next.
      shape: RoundedRectangleBorder(
        borderRadius: theme.shapes.mdRadius,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = SaleLineColumns.of(constraints.maxWidth);
                return saleLineLayoutFor(constraints.maxWidth) ==
                        SaleLineLayout.singleRow
                    ? _singleRow(context, l10n, line, enabled, spacing, columns)
                    : _twoRow(context, l10n, line, enabled, spacing, columns);
              },
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

  Widget _thumbnail() => const ProductPhoto(photoUrl: null, size: 40);

  /// Name prominent over the code as a secondary line — not `'code — name'`
  /// in one string (FR-039). The thumbnail sits beside it since both rows
  /// show it in the same leading position.
  ///
  /// The name gets **two** lines and reserves both whether it needs them or
  /// not: the product cell is the row's flexible column, so it is the one
  /// that actually runs out of room, and reserving the space keeps every line
  /// in the list the same height rather than making rows jump between one and
  /// two lines of name.
  Widget _productCell(BuildContext context, SaleLine line) {
    final theme = Theme.of(context);
    final nameStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      height: 1.2,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _thumbnail(),
        SizedBox(width: theme.spacing.xs),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2 * (nameStyle.fontSize ?? 14) * (nameStyle.height ?? 1),
                child: Text(
                  line.productName,
                  style: nameStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
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

  /// One text style for every control in the band (FR-038a). The band used to
  /// mix `bodySmall` fields with a `bodyMedium`-ish dropdown; a row of controls
  /// that all do the same job should not be set in two sizes.
  TextStyle? get _fieldStyle => Theme.of(context).textTheme.bodyMedium;

  Widget _warehouseCell(AppLocalizations l10n) => warehousePicker(
    decoration: _fieldDecoration(l10n.posLineWarehouseLabel, dropdown: true),
    style: _fieldStyle,
  );

  Widget _taxCell(AppLocalizations l10n) => taxRatePicker(
    decoration: _fieldDecoration(l10n.posLineTaxLabel, dropdown: true),
    style: _fieldStyle,
  );

  /// The price, shown but not writable (FR-038c). It keeps the field shape so
  /// the band stays one row of same-sized boxes, and keeps the price where the
  /// cashier already looks for it — but it takes no focus and no keystrokes.
  /// A price that needs adjusting is adjusted through the discount, which is
  /// what the discount is for.
  Widget _priceCell(AppLocalizations l10n) => TextField(
    controller: priceField,
    readOnly: true,
    canRequestFocus: false,
    mouseCursor: SystemMouseCursors.basic,
    textAlign: TextAlign.end,
    style: _fieldStyle?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    decoration: _fieldDecoration(l10n.posLinePriceLabel),
  );

  /// A compact −/field/+ stepper, at the same height as every other control
  /// in the band ([saleLineFieldHeight]).
  ///
  /// The product's SAT unit rides in the field's **label** — `Cant. (Pza)` —
  /// rather than in a column of its own. A unit is one short symbol, and
  /// giving it 56 px of the row bought nothing that the quantity's own label
  /// could not carry for free; the width it frees is what pays for the wider
  /// warehouse, price, discount and tax columns. `Cant.` alone when the
  /// product has no unit on file (mbe-api#145 leaves it null for those).
  Widget _quantityStepper(AppLocalizations l10n, bool enabled) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _stepperButton(Icons.remove, enabled ? () => step(-1) : null, l10n.posLineDecreaseQuantity),
      Expanded(
        // The stepper's own `Row` would otherwise give the field its intrinsic
        // height, leaving it shorter than the band it sits in — the two
        // buttons beside it are what stop the field from filling on its own.
        child: SizedBox(
          height: saleLineFieldHeight,
          child: TextField(
            controller: quantityField,
            enabled: enabled,
            textAlign: TextAlign.center,
            style: _fieldStyle,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _fieldDecoration(
              line.unit == null
                  ? l10n.posLineQuantityLabel
                  : l10n.posLineQuantityWithUnitLabel(line.unit!),
            ),
            onSubmitted: (v) => update(quantity: v),
          ),
        ),
      ),
      _stepperButton(Icons.add, enabled ? () => step(1) : null, l10n.posLineIncreaseQuantity),
    ],
  );

  /// `tapTargetSize: shrinkWrap` is what actually makes the 32 px
  /// `constraints` below hold: without it Material adds its 48 px minimum
  /// tap target around the button, which is why an earlier, apparently
  /// generous column still overflowed with `padding`/`constraints` already
  /// overridden. Dropping below the 48 px target is deliberate and confined
  /// to this arrangement — the single row is only ever laid out at
  /// [saleLineSingleRowMinWidth] and above, where the input is a pointer
  /// (contracts/capture-surface.md §6); the phone tier renders
  /// `SaleLineCard`, whose steppers keep Material's full touch target.
  Widget _stepperButton(IconData icon, VoidCallback? onPressed, String tooltip) => IconButton(
    icon: Icon(icon, size: 18),
    tooltip: tooltip,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
    visualDensity: VisualDensity.compact,
    style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    onPressed: onPressed,
  );

  /// One decoration for every control in the band, so they come out the same
  /// height *and* on the same baseline rather than each landing wherever its own
  /// content puts it (FR-038a).
  ///
  /// [dropdown] is the whole difference: a dense dropdown's inner box is 4 px
  /// taller than a dense text field's, so it takes 2 px less padding on each
  /// side to reach the same [saleLineFieldHeight] — see
  /// [saleLineDropdownPadding].
  InputDecoration _fieldDecoration(String label, {bool dropdown = false}) =>
      InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: dropdown
              ? saleLineDropdownPadding
              : saleLineTextFieldPadding,
        ),
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
    style: _fieldStyle,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: _fieldDecoration(label),
    onSubmitted: onSubmitted,
  );

  /// A control sized to the band: [width] wide, [saleLineFieldHeight] tall,
  /// centred in the row's own [saleLineRowHeight] so all five controls share
  /// one top and one bottom edge.
  Widget _band({required double width, required Widget child}) => SizedBox(
    width: width,
    height: saleLineFieldHeight,
    child: child,
  );

  Widget _totalCell(SaleLine line) => Text(
    MoneyFormatters.currency(line.total),
    textAlign: TextAlign.right,
    style: Theme.of(context).typeRoles.money,
  );

  /// Removing a line is the one irreversible thing this row does, so it carries
  /// the error colour the rest of the product already gives destructive actions
  /// (`RecordFormActions`' delete button). Disabled it fades with everything
  /// else — a control that cannot fire should not advertise danger.
  Widget _deleteButton(AppLocalizations l10n, bool enabled) => IconButton(
    icon: const Icon(Icons.delete_outline),
    style: IconButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.error,
    ),
    onPressed: enabled ? removeLine : null,
    tooltip: l10n.posRemoveLineTooltip,
  );

  // ── Layouts ───────────────────────────────────────────────────────────

  /// contracts/capture-surface.md §4.2 — product flex (min 222 by
  /// construction of [saleLineSingleRowMinWidth], carrying the 40 px
  /// thumbnail); every other column sized by [SaleLineColumns] for this row's
  /// own width, with `spacing.xs` gaps throughout. The whole band is
  /// [saleLineRowHeight] tall and every control in it is
  /// [saleLineFieldHeight] tall (FR-038a).
  Widget _singleRow(
    BuildContext context,
    AppLocalizations l10n,
    SaleLine line,
    bool enabled,
    Spacing spacing,
    SaleLineColumns columns,
  ) {
    final gap = SizedBox(width: spacing.xs);
    return SizedBox(
      height: saleLineRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _productCell(context, line)),
          gap,
          _band(width: columns.warehouse, child: _warehouseCell(l10n)),
          gap,
          _band(
            width: columns.quantity,
            child: _quantityStepper(l10n, enabled),
          ),
          gap,
          _band(width: columns.price, child: _priceCell(l10n)),
          gap,
          _band(
            width: columns.discount,
            child: _rateField(
              controller: discountField,
              enabled: enabled,
              label: l10n.posLineDiscountLabel,
              onSubmitted: (v) => updateRate(discountRate: v),
            ),
          ),
          gap,
          _band(width: columns.tax, child: _taxCell(l10n)),
          gap,
          SizedBox(width: columns.total, child: _totalCell(line)),
          _deleteButton(l10n, enabled),
        ],
      ),
    );
  }

  /// contracts/capture-surface.md §4.3 — row 1: thumbnail, product,
  /// warehouse, total, delete; row 2: quantity, price, discount, tax. Nothing
  /// dropped, nothing read-only that was editable in the single row; the unit
  /// travels in the quantity label here too, and the price is read-only here
  /// as well (FR-038c).
  Widget _twoRow(
    BuildContext context,
    AppLocalizations l10n,
    SaleLine line,
    bool enabled,
    Spacing spacing,
    SaleLineColumns columns,
  ) {
    final gap = SizedBox(width: spacing.xs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: saleLineRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _productCell(context, line)),
              gap,
              _band(width: columns.warehouse, child: _warehouseCell(l10n)),
              gap,
              SizedBox(width: columns.total, child: _totalCell(line)),
              _deleteButton(l10n, enabled),
            ],
          ),
        ),
        SizedBox(height: spacing.xxs),
        SizedBox(
          height: saleLineFieldHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _band(
                width: columns.quantity,
                child: _quantityStepper(l10n, enabled),
              ),
              gap,
              Expanded(child: _priceCell(l10n)),
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
              Expanded(child: _taxCell(l10n)),
            ],
          ),
        ),
      ],
    );
  }
}
