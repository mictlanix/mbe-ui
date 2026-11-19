import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/form_error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The prompts the trip screen opens (spec 075 ui-contract "Dialogs"): the
// quantity of a loaded line, releasing one, removing a stop, departing and
// cancelling. Each runs its own write through `DeliveryItineraryActions`, so
// the trip reloads whatever the outcome (FR-022).

/// What a prompt reports once it has closed: `error` is `null` when the server
/// accepted, otherwise the refusal the screen shows. The prompt answers `null`
/// when the user backed out.
typedef ItineraryActionResult = ({AppError? error});

/// A write's failure, as a dialog or the screen shows it: a lost connection
/// leaves the outcome unknown, so it says that rather than claiming it failed;
/// anything else is the server's refusal, localized from its code (§III).
class ItineraryRefusal extends StatelessWidget {
  const ItineraryRefusal({super.key, required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return error is NetworkError
        ? FormErrorBanner(
            key: const Key('itinerary_action_unknown'),
            headline: l10n.itineraryActionUnknown,
          )
        : ErrorBanner(key: const Key('itinerary_refusal'), error: error);
  }
}

/// A confirmation that runs [run] on confirm and closes with its outcome.
///
/// The text says what happens (FR-011, FR-012, FR-014). The dialog stays on
/// screen while the write is in flight, and closes on any outcome so the
/// screen shows the refusal where the user is looking.
class _ConfirmActionDialog extends ConsumerStatefulWidget {
  const _ConfirmActionDialog({
    required this.dialogKey,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.dismissLabel,
    required this.run,
  });

  final Key dialogKey;
  final String title;
  final List<Widget> body;
  final String confirmLabel;
  final String dismissLabel;
  final Future<AppError?> Function(DeliveryItineraryActions actions) run;

  @override
  ConsumerState<_ConfirmActionDialog> createState() =>
      _ConfirmActionDialogState();
}

class _ConfirmActionDialogState extends ConsumerState<_ConfirmActionDialog> {
  bool _busy = false;

  Future<void> _confirm() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await widget.run(
      ref.read(deliveryItineraryActionsProvider.notifier),
    );
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    return ResponsiveDialog(
      key: widget.dialogKey,
      title: widget.title,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: widget.body,
      ),
      secondaryAction: ResponsiveDialogAction(
        label: widget.dismissLabel,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('itinerary_confirm_submit'),
        label: widget.confirmLabel,
        busy: _busy,
        onPressed: _confirm,
      ),
    );
  }
}

Future<ItineraryActionResult?> _showConfirm(
  BuildContext context, {
  required Key dialogKey,
  required String title,
  required List<Widget> body,
  required String confirmLabel,
  required String dismissLabel,
  required Future<AppError?> Function(DeliveryItineraryActions actions) run,
}) => showResponsiveDialog<ItineraryActionResult>(
  context,
  builder: (context) => _ConfirmActionDialog(
    dialogKey: dialogKey,
    title: title,
    body: body,
    confirmLabel: confirmLabel,
    dismissLabel: dismissLabel,
    run: run,
  ),
);

// ---------------------------------------------------------------------------
// Cargar todo (FR-010)
// ---------------------------------------------------------------------------

/// Asks before loading everything still open on [deliveryOrderId] onto the
/// stop, after one confirmation.
Future<ItineraryActionResult?> showLoadAllDialog(
  BuildContext context, {
  required int itineraryId,
  required int stopId,
  required int deliveryOrderId,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _showConfirm(
    context,
    dialogKey: const Key('itinerary_load_all_dialog'),
    title: l10n.itineraryLoadAllTitle(deliveryOrderId),
    body: [Text(l10n.itineraryLoadAllBody)],
    confirmLabel: l10n.itineraryLoadAllConfirm,
    dismissLabel: l10n.cancelButton,
    run: (actions) => actions.commitWholeOrder(
      itineraryId,
      stopId,
      deliveryOrderId: deliveryOrderId,
    ),
  );
}

// ---------------------------------------------------------------------------
// Liberar partida / Quitar parada (FR-011)
// ---------------------------------------------------------------------------

/// Asks before releasing [line] (🗑): its loaded quantity is pending again on
/// the order.
Future<ItineraryActionResult?> showReleaseLineDialog(
  BuildContext context, {
  required int itineraryId,
  required int stopId,
  required ItineraryLine line,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _showConfirm(
    context,
    dialogKey: const Key('itinerary_release_dialog'),
    title: l10n.itineraryReleaseTitle(line.productCode),
    body: [Text(l10n.itineraryReleaseBody)],
    confirmLabel: l10n.itineraryReleaseConfirm,
    dismissLabel: l10n.cancelButton,
    run: (actions) => actions.release(itineraryId, stopId, line.id),
  );
}

/// Asks before removing [stop], naming what is released with it.
Future<ItineraryActionResult?> showRemoveStopDialog(
  BuildContext context, {
  required int itineraryId,
  required ItineraryStop stop,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _showConfirm(
    context,
    dialogKey: const Key('itinerary_remove_stop_dialog'),
    title: l10n.itineraryRemoveStopTitle(stop.sequence),
    body: [Text(l10n.itineraryRemoveStopBody)],
    confirmLabel: l10n.itineraryRemoveStopConfirm,
    dismissLabel: l10n.cancelButton,
    run: (actions) => actions.removeStop(itineraryId, stop.id),
  );
}

// ---------------------------------------------------------------------------
// Dar salida / Cancelar itinerario (FR-012, FR-014)
// ---------------------------------------------------------------------------

/// Asks before departing [trip]: its vehicle, its operator (or "Sin
/// operador"), the stop and line counts, and that the load can't change
/// afterwards (US2 scenario 1).
Future<ItineraryActionResult?> showDepartDialog(
  BuildContext context, {
  required Itinerary trip,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _showConfirm(
    context,
    dialogKey: const Key('itinerary_depart_dialog'),
    title: l10n.itineraryDepartTitle(trip.id),
    body: [
      Text(
        l10n.itineraryDepartVehicleOperator(
          trip.vehicleName ??
              (trip.vehicleId == null ? '—' : '#${trip.vehicleId}'),
          trip.operatorName ??
              (trip.vehicleOperatorId == null
                  ? l10n.itineraryNoOperator
                  : '#${trip.vehicleOperatorId}'),
        ),
        key: const Key('itinerary_depart_summary'),
      ),
      Text(
        l10n.itineraryDepartCounts(trip.stops.length, trip.loadedLineCount),
        key: const Key('itinerary_depart_counts'),
      ),
      Text(l10n.itineraryDepartWarning),
    ],
    confirmLabel: l10n.itineraryDepartConfirm,
    dismissLabel: l10n.cancelButton,
    run: (actions) => actions.depart(trip.id),
  );
}

/// Asks before cancelling [trip]: what is loaded is released and the orders
/// stay in preparation. There is no reason to give (the endpoint takes none).
Future<ItineraryActionResult?> showCancelItineraryDialog(
  BuildContext context, {
  required Itinerary trip,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _showConfirm(
    context,
    dialogKey: const Key('itinerary_cancel_dialog'),
    title: l10n.itineraryCancelTitle(trip.id),
    body: [Text(l10n.itineraryCancelBody)],
    confirmLabel: l10n.itineraryCancelConfirm,
    dismissLabel: l10n.itineraryCancelDismiss,
    run: (actions) => actions.cancel(trip.id),
  );
}

// ---------------------------------------------------------------------------
// Cantidad cargada (✎, FR-011)
// ---------------------------------------------------------------------------

/// Changes [line]'s loaded quantity. The quantity must be above 0 and at most
/// [maxQuantity] (what is pending on the order plus what is already loaded),
/// or just above 0 when [maxQuantity] is `null` because the order could not be
/// read; the server then has the last word.
Future<ItineraryActionResult?> showAdjustQuantityDialog(
  BuildContext context, {
  required int itineraryId,
  required int stopId,
  required ItineraryLine line,
  Decimal? pending,
}) => showResponsiveDialog<ItineraryActionResult>(
  context,
  builder: (context) => _AdjustQuantityDialog(
    itineraryId: itineraryId,
    stopId: stopId,
    line: line,
    pending: pending,
  ),
);

class _AdjustQuantityDialog extends ConsumerStatefulWidget {
  const _AdjustQuantityDialog({
    required this.itineraryId,
    required this.stopId,
    required this.line,
    required this.pending,
  });

  final int itineraryId;
  final int stopId;
  final ItineraryLine line;
  final Decimal? pending;

  @override
  ConsumerState<_AdjustQuantityDialog> createState() =>
      _AdjustQuantityDialogState();
}

class _AdjustQuantityDialogState extends ConsumerState<_AdjustQuantityDialog> {
  late final TextEditingController _quantity;
  bool _busy = false;

  Decimal? get _max =>
      widget.pending == null ? null : widget.pending! + widget.line.committed;

  @override
  void initState() {
    super.initState();
    _quantity = TextEditingController(
      text: ref
          .read(formattersProvider)
          .field
          .quantity(widget.line.committed.toString()),
    );
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  /// The typed quantity, or `null` when it is not a number above 0 and within
  /// the maximum.
  Decimal? get _valid {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    final value = parsed == null ? null : Decimal.tryParse(parsed);
    if (value == null || value <= Decimal.zero) return null;
    final max = _max;
    if (max != null && value > max) return null;
    return value;
  }

  Future<void> _save() async {
    final value = _valid;
    if (_busy || value == null) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await ref
        .read(deliveryItineraryActionsProvider.notifier)
        .adjust(
          widget.itineraryId,
          widget.stopId,
          widget.line.id,
          quantity: value,
        );
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final max = _max;
    final typed = _quantity.text.trim().isNotEmpty;

    return ResponsiveDialog(
      key: const Key('itinerary_adjust_dialog'),
      title: l10n.itineraryAdjustTitle(widget.line.productCode),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          TextField(
            key: const Key('itinerary_adjust_quantity'),
            controller: _quantity,
            enabled: !_busy,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.itineraryQuantityLabel,
              suffixText: widget.line.unitSymbol,
              helperText: max == null
                  ? null
                  : l10n.itineraryQuantityMaxBreakdown(
                      fmt.display.quantity(max.toString()),
                      fmt.display.quantity(widget.pending.toString()),
                      fmt.display.quantity(widget.line.committed.toString()),
                    ),
              errorText: typed && _valid == null
                  ? l10n.itineraryQuantityInvalid
                  : null,
              errorMaxLines: 3,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('itinerary_adjust_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _valid == null ? null : _save,
      ),
    );
  }
}
