import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest product name a line takes (FR-010).
const _nameMaxLength = 250;

/// The most decimals a quantity takes (FR-012).
const _quantityMaxScale = 2;

/// "Editar partida" (spec 079 FR-010, FR-012 to FR-014, research R6): the
/// line's name, quantity and destination on draft [requestId]. Only the
/// changed fields are sent. `true` once saved; every refusal (such as
/// `warehouse.in_transit_location`) shows inline and keeps the dialog open.
Future<bool> showRequestLineDialog(
  BuildContext context, {
  required int requestId,
  required PurchaseRequestLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _LineDialog(requestId: requestId, line: line),
    ) ??
    false;

class _LineDialog extends ConsumerStatefulWidget {
  const _LineDialog({required this.requestId, required this.line});

  final int requestId;
  final PurchaseRequestLine line;

  @override
  ConsumerState<_LineDialog> createState() => _LineDialogState();
}

class _LineDialogState extends ConsumerState<_LineDialog> {
  late final _name = TextEditingController(text: widget.line.productName);
  late final String _initialQuantity = ref
      .read(formattersProvider)
      .field
      .quantity(widget.line.quantity.toString());
  late final _quantity = TextEditingController(text: _initialQuantity);

  /// The destination the user picked; `null` keeps the line's.
  Warehouse? _destination;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Decimal? get _quantityValue {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  /// Greater than 0, with at most 2 decimals (FR-012).
  bool get _validQuantity {
    final value = _quantityValue;
    return value != null &&
        value > Decimal.zero &&
        value.scale <= _quantityMaxScale;
  }

  String get _trimmedName => _name.text.trim();

  bool get _validName =>
      _trimmedName.isNotEmpty && _trimmedName.length <= _nameMaxLength;

  bool get _nameChanged => _trimmedName != widget.line.productName;

  bool get _quantityChanged => _quantityValue != widget.line.quantity;

  bool get _destinationChanged =>
      _destination != null &&
      _destination!.warehouseId != widget.line.warehouseId;

  bool _hasUnsavedChanges() =>
      _name.text != widget.line.productName ||
      _quantity.text != _initialQuantity ||
      _destinationChanged;

  bool get _canSave =>
      !_busy &&
      _validName &&
      _validQuantity &&
      (_nameChanged || _quantityChanged || _destinationChanged);

  Future<void> _save() async {
    if (!_canSave) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(purchaseRequestActionsProvider.notifier)
        .updateLine(
          widget.requestId,
          widget.line.id,
          quantity: _quantityChanged ? _quantityValue : null,
          productName: _nameChanged ? _trimmedName : null,
          warehouseId: _destinationChanged ? _destination!.warehouseId : null,
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
    final line = widget.line;
    final minimum = line.minOrderQty;
    final lineWarehouse = line.warehouseId;
    final lineWarehouseName = lineWarehouse == null
        ? null
        : (ref.watch(warehouseDisplayNameProvider(lineWarehouse)).value ??
              '#$lineWarehouse');

    return ResponsiveDialog(
      key: const Key('request_line_dialog'),
      title: l10n.purchaseRequestEditLineTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(line.productCode),
          TextField(
            key: const Key('request_line_name'),
            controller: _name,
            enabled: !_busy,
            maxLength: _nameMaxLength,
            // Over-long text stays visible with the counter in error, and
            // "Guardar" stays disabled.
            maxLengthEnforcement: MaxLengthEnforcement.none,
            decoration: InputDecoration(
              labelText: l10n.purchaseRequestFieldName,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            key: const Key('request_line_quantity'),
            controller: _quantity,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.purchaseRequestFieldQuantity,
              // The minimum informs, never blocks (FR-013); a minimum of 0
              // or 1 says nothing, as in `belowMinimum`.
              helperText: minimum != null && minimum > 1
                  ? l10n.purchaseRequestQuantityMinimum(
                      ref.watch(formattersProvider).display.count(minimum),
                    )
                  : null,
              errorText: _validQuantity
                  ? null
                  : l10n.purchaseRequestQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
          ),
          // Every warehouse: a line may go to another facility (FR-014).
          CatalogEntityPicker<Warehouse>(
            key: const Key('request_line_destination'),
            label: l10n.purchaseRequestFieldDestination,
            enabled: !_busy,
            displayStringForOption: (w) => w.name,
            optionSubtitle: (w) => w.facilityName,
            optionsBuilder: (search) => inventoryFilterWarehouseOptions(
              ref.read(warehouseRepositoryProvider),
              search,
            ),
            onSelected: (w) => setState(() {
              _destination = w;
              _refusal = null;
            }),
            initialDisplayText: _destination?.name ?? lineWarehouseName,
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('request_line_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('request_line_submit'),
        label: l10n.purchaseRequestSaveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
