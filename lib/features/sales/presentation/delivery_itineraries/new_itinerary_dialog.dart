import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_pickers.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Nuevo itinerario" (spec 075 FR-005, research R15): a short dialog with the
/// date (today), the vehicle, the operator, the optional dispatch warehouse and
/// a comment. Everything is optional: an empty trip is allowed, and the
/// vehicle and operator can be set until departure.
///
/// A refusal such as `vehicle.open_itinerary_exists` shows inline and keeps the
/// dialog open, naming the trip that holds the vehicle (US1 scenario 4).
/// Answers the new trip's id, or `null` when the user backed out.
Future<int?> showNewItineraryDialog(BuildContext context) =>
    showResponsiveDialog<int>(
      context,
      builder: (context) => const _NewItineraryDialog(),
    );

class _NewItineraryDialog extends ConsumerStatefulWidget {
  const _NewItineraryDialog();

  @override
  ConsumerState<_NewItineraryDialog> createState() =>
      _NewItineraryDialogState();
}

class _NewItineraryDialogState extends ConsumerState<_NewItineraryDialog> {
  final _comment = TextEditingController();
  DateTime _date = DateTime.now();
  int? _vehicleId;
  int? _operatorId;
  int? _warehouseId;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _create() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final comment = _comment.text.trim();
    final result = await ref
        .read(deliveryItineraryActionsProvider.notifier)
        .create(
          date: _date,
          vehicleId: _vehicleId,
          operatorId: _operatorId,
          warehouseId: _warehouseId,
          comment: comment.isEmpty ? null : comment,
        );
    if (!mounted) return;
    if (result.id != null) {
      navigator.pop(result.id);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = result.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    bool canRead(SystemObject object) => access.can(object, AccessRight.read);

    return ResponsiveDialog(
      key: const Key('new_itinerary_dialog'),
      title: l10n.itineraryNewTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          InkWell(
            key: const Key('new_itinerary_date'),
            onTap: _busy ? null : _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.itineraryFieldDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(fmt.display.date(_date)),
            ),
          ),
          // A picker the user can't read is left out (§IV).
          if (canRead(SystemObject.vehicle))
            ItineraryVehiclePicker(
              key: const Key('new_itinerary_vehicle'),
              label: l10n.itineraryFieldVehicle,
              onSelected: (v) => _vehicleId = v.vehicleId,
            ),
          if (canRead(SystemObject.vehicleOperators))
            ItineraryOperatorPicker(
              key: const Key('new_itinerary_operator'),
              label: l10n.itineraryFieldOperator,
              onSelected: (o) => _operatorId = o.vehicleOperatorId,
            ),
          if (canRead(SystemObject.warehouses))
            ItineraryWarehousePicker(
              key: const Key('new_itinerary_warehouse'),
              label: l10n.itineraryFieldWarehouse,
              onSelected: (w) => _warehouseId = w.warehouseId,
            ),
          Text(
            l10n.itineraryWarehouseHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextField(
            key: const Key('new_itinerary_comment'),
            controller: _comment,
            enabled: !_busy,
            decoration: InputDecoration(labelText: l10n.itineraryFieldComment),
          ),
          if (_refusal != null) ItineraryRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('new_itinerary_submit'),
        label: l10n.itineraryCreateButton,
        busy: _busy,
        onPressed: _create,
      ),
    );
  }
}
