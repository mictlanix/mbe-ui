import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Cargar línea" (spec 075 FR-010): the stop's order lines that still have
/// something to load, one chosen at a time, with a quantity that defaults to
/// what is open and may not exceed it.
///
/// A refusal such as `delivery_order_line.quantity_unavailable` shows inline
/// and keeps the dialog open: the quantity may have changed since the order
/// was read. Answers the write's outcome, or `null` when the user backed out.
Future<ItineraryActionResult?> showLoadLineDialog(
  BuildContext context, {
  required int itineraryId,
  required int stopId,
  required int deliveryOrderId,
}) => showResponsiveDialog<ItineraryActionResult>(
  context,
  builder: (context) => _LoadLineDialog(
    itineraryId: itineraryId,
    stopId: stopId,
    deliveryOrderId: deliveryOrderId,
  ),
);

class _LoadLineDialog extends ConsumerStatefulWidget {
  const _LoadLineDialog({
    required this.itineraryId,
    required this.stopId,
    required this.deliveryOrderId,
  });

  final int itineraryId;
  final int stopId;
  final int deliveryOrderId;

  @override
  ConsumerState<_LoadLineDialog> createState() => _LoadLineDialogState();
}

class _LoadLineDialogState extends ConsumerState<_LoadLineDialog> {
  final _quantity = TextEditingController();
  DeliveryOrderLine? _line;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  void _choose(DeliveryOrderLine line) {
    final fmt = ref.read(formattersProvider);
    setState(() {
      _line = line;
      _refusal = null;
      // The default is everything still open.
      _quantity.text = fmt.field.quantity(line.open.toString());
    });
  }

  /// The typed quantity: above 0 and at most what is open on the chosen line.
  Decimal? get _valid {
    final line = _line;
    if (line == null) return null;
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    final value = parsed == null ? null : Decimal.tryParse(parsed);
    if (value == null || value <= Decimal.zero || value > line.open) {
      return null;
    }
    return value;
  }

  Future<void> _load() async {
    final value = _valid;
    final line = _line;
    if (_busy || value == null || line == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(deliveryItineraryActionsProvider.notifier)
        .commitLine(
          widget.itineraryId,
          widget.stopId,
          deliveryOrderLineId: line.id,
          quantity: value,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop((error: null));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final order = ref.watch(itineraryOrderProvider(widget.deliveryOrderId));
    // Lines with nothing open aren't offered (FR-010).
    final lines = [
      for (final line in order.value?.lines ?? const <DeliveryOrderLine>[])
        if (line.open > Decimal.zero) line,
    ];
    final selected = _line;
    final typed = _quantity.text.trim().isNotEmpty;

    return ResponsiveDialog(
      key: const Key('itinerary_load_line_dialog'),
      title: l10n.itineraryLoadLineTitle(widget.deliveryOrderId),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (order.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (lines.isEmpty)
            Text(
              l10n.itineraryLoadLineEmpty,
              key: const Key('itinerary_load_line_empty'),
            )
          else
            RadioGroup<int>(
              groupValue: selected?.id,
              onChanged: (id) {
                if (_busy || id == null) return;
                _choose(lines.firstWhere((l) => l.id == id));
              },
              child: Column(
                children: [
                  for (final line in lines)
                    RadioListTile<int>(
                      key: Key('itinerary_load_line_${line.id}'),
                      value: line.id,
                      enabled: !_busy,
                      title: Text('${line.productCode}  ${line.productName}'),
                      secondary: Text(
                        l10n.itineraryLoadLinePending(
                          fmt.display.quantity(line.open.toString()),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (selected != null)
            TextField(
              key: const Key('itinerary_load_line_quantity'),
              controller: _quantity,
              enabled: !_busy,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.itineraryQuantityLabel,
                helperText: l10n.itineraryQuantityMax(
                  fmt.display.quantity(selected.open.toString()),
                ),
                errorText: typed && _valid == null
                    ? l10n.itineraryQuantityInvalid
                    : null,
                errorMaxLines: 3,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _load(),
            ),
          if (_refusal != null) ItineraryRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('itinerary_load_line_submit'),
        label: l10n.itineraryLoadLineConfirm,
        busy: _busy,
        onPressed: _valid == null ? null : _load,
      ),
    );
  }
}
