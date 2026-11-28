import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The most decimals a quantity takes (FR-015).
const _quantityMaxScale = 4;

/// The most decimals a unit price takes (FR-015).
const _priceMaxScale = 7;

/// The Mexican IVA rates every line can pick from (research R8).
final _standardTaxRates = [
  Decimal.zero,
  Decimal.parse('0.08'),
  Decimal.parse('0.16'),
];

/// The IVA options for a line whose rate is [current]: 0, 8 % and 16 %, plus
/// [current] when it is none of them, ascending (research R8). The line's
/// own rate is always offered, so showing it never rewrites it.
List<Decimal> taxRateOptions(Decimal current) =>
    {..._standardTaxRates, current}.toList()..sort();

/// "Editar partida" (spec 080 FR-015, research R8): the warehouse, quantity,
/// unit price and IVA of [line] on draft [orderId]. Only the changed fields
/// are sent, so an untouched price goes back unrounded (it isn't sent at
/// all). `true` once saved; every refusal (such as an in-transit warehouse)
/// shows inline and keeps the dialog open.
///
/// The detail screen gates ✎ on PurchasesOrders (20) update and Warehouses
/// (4) read, on a draft.
Future<bool> showOrderLineDialog(
  BuildContext context, {
  required int orderId,
  required PurchaseOrderLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _LineDialog(orderId: orderId, line: line),
    ) ??
    false;

class _LineDialog extends ConsumerStatefulWidget {
  const _LineDialog({required this.orderId, required this.line});

  final int orderId;
  final PurchaseOrderLine line;

  @override
  ConsumerState<_LineDialog> createState() => _LineDialogState();
}

class _LineDialogState extends ConsumerState<_LineDialog> {
  late final String _initialQuantity = ref
      .read(formattersProvider)
      .field
      .quantity(widget.line.quantity.toString());
  late final _quantity = TextEditingController(text: _initialQuantity);

  /// The price at full precision: the price formatter's text when it holds
  /// the whole value, else every decimal the line has (research R8), so the
  /// field never shows a rounded price.
  late final String _initialPrice = () {
    final price = widget.line.price;
    final formatted = ref.read(formattersProvider).field.price('$price');
    return Decimal.tryParse(formatted) == price ? formatted : '$price';
  }();
  late final _price = TextEditingController(text: _initialPrice);
  late Decimal _taxRate = widget.line.taxRate;

  /// The warehouse the user picked; `null` keeps the line's.
  Warehouse? _warehouse;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  Decimal? get _quantityValue {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  Decimal? get _priceValue {
    final parsed = ref.read(formattersProvider).field.parsePrice(_price.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  /// Greater than 0, with at most 4 decimals.
  bool get _validQuantity {
    final value = _quantityValue;
    return value != null &&
        value > Decimal.zero &&
        value.scale <= _quantityMaxScale;
  }

  /// 0 or more, with at most 7 decimals.
  bool get _validPrice {
    final value = _priceValue;
    return value != null &&
        value >= Decimal.zero &&
        value.scale <= _priceMaxScale;
  }

  // A field counts as changed only once its text differs from the prefill,
  // so an untouched value is never sent back (rounded or not).
  bool get _quantityChanged =>
      _quantity.text != _initialQuantity &&
      _quantityValue != widget.line.quantity;

  bool get _priceChanged =>
      _price.text != _initialPrice && _priceValue != widget.line.price;

  bool get _taxRateChanged => _taxRate != widget.line.taxRate;

  bool get _warehouseChanged =>
      _warehouse != null && _warehouse!.warehouseId != widget.line.warehouseId;

  bool _hasUnsavedChanges() =>
      _quantity.text != _initialQuantity ||
      _price.text != _initialPrice ||
      _taxRateChanged ||
      _warehouseChanged;

  bool get _canSave =>
      !_busy &&
      _validQuantity &&
      _validPrice &&
      (_quantityChanged ||
          _priceChanged ||
          _taxRateChanged ||
          _warehouseChanged);

  Future<void> _save() async {
    if (!_canSave) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .updateLine(
          widget.orderId,
          widget.line.id,
          quantity: _quantityChanged ? _quantityValue : null,
          warehouseId: _warehouseChanged ? _warehouse!.warehouseId : null,
          price: _priceChanged ? _priceValue : null,
          taxRate: _taxRateChanged ? _taxRate : null,
        );
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final line = widget.line;
    final lineWarehouse = line.warehouseId;
    final lineWarehouseName = lineWarehouse == null
        ? null
        : (ref.watch(warehouseDisplayNameProvider(lineWarehouse)).value ??
              '#$lineWarehouse');

    return ResponsiveDialog(
      key: const Key('order_line_dialog'),
      title: l10n.purchaseOrderEditLineTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text('${line.productCode} ${line.productName}'),
          // Every warehouse, unscoped: an order isn't facility-scoped
          // (FR-003). In-transit ones can't be hidden; the server's refusal
          // shows (spec edge case).
          CatalogEntityPicker<Warehouse>(
            key: const Key('order_line_warehouse'),
            label: l10n.purchaseOrderFieldWarehouse,
            enabled: !_busy,
            displayStringForOption: (w) => w.name,
            optionSubtitle: (w) => w.facilityName,
            optionsBuilder: (search) => inventoryFilterWarehouseOptions(
              ref.read(warehouseRepositoryProvider),
              search,
            ),
            onSelected: (w) => setState(() {
              _warehouse = w;
              _refusal = null;
            }),
            initialDisplayText: _warehouse?.name ?? lineWarehouseName,
          ),
          TextField(
            key: const Key('order_line_quantity'),
            controller: _quantity,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.purchaseOrderFieldQuantity,
              errorText: _validQuantity
                  ? null
                  : l10n.purchaseOrderQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            key: const Key('order_line_price'),
            controller: _price,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.purchaseOrderFieldPrice,
              helperText: l10n.purchaseOrderFieldPriceHelper,
              errorText: _validPrice ? null : l10n.purchaseOrderPriceInvalid,
            ),
            onChanged: (_) => setState(() {}),
          ),
          DropdownButtonFormField<Decimal>(
            key: const Key('order_line_tax'),
            initialValue: _taxRate,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.purchaseOrderFieldTax),
            items: [
              for (final rate in taxRateOptions(line.taxRate))
                DropdownMenuItem(
                  key: Key('order_line_tax_$rate'),
                  value: rate,
                  child: Text(
                    l10n.purchaseOrderTaxRateOption(
                      fmt.field.rate(rate.toString()),
                    ),
                  ),
                ),
            ],
            onChanged: _busy
                ? null
                : (rate) => setState(() {
                    _taxRate = rate ?? _taxRate;
                    _refusal = null;
                  }),
          ),
          if (_refusal != null)
            ErrorBanner(key: const Key('order_line_refusal'), error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('order_line_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
