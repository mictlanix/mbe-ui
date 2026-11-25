import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_pickers.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Editar encabezado" (spec 075 FR-006): date, vehicle, operator and comment
/// of an Abierto trip. The dispatch warehouse isn't editable after creation:
/// the server's update has no such field, so it isn't offered.
///
/// Confirm is enabled only when something changed. Answers the write's outcome
/// like the other prompts, or `null` when the user backed out.
Future<ItineraryActionResult?> showItineraryHeaderDialog(
  BuildContext context, {
  required Itinerary trip,
}) => showResponsiveDialog<ItineraryActionResult>(
  context,
  builder: (context) => _HeaderDialog(trip: trip),
);

class _HeaderDialog extends ConsumerStatefulWidget {
  const _HeaderDialog({required this.trip});

  final Itinerary trip;

  @override
  ConsumerState<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends ConsumerState<_HeaderDialog> {
  late final TextEditingController _comment;
  late DateTime _date;
  int? _vehicleId;
  int? _operatorId;
  bool _busy = false;
  AppError? _refusal;

  Itinerary get _trip => widget.trip;

  @override
  void initState() {
    super.initState();
    _comment = TextEditingController(text: _trip.comment ?? '');
    _date = _trip.date;
    _vehicleId = _trip.vehicleId;
    _operatorId = _trip.vehicleOperatorId;
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _vehicleChanged => _vehicleId != _trip.vehicleId;

  bool get _changed =>
      _vehicleChanged ||
      _operatorId != _trip.vehicleOperatorId ||
      _date != _trip.date ||
      _comment.text.trim() != (_trip.comment ?? '');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  /// Another Abierto trip that already holds [vehicleId], if any.
  ///
  /// The server checks one open trip per vehicle on create and on update
  /// (`vehicle.open_itinerary_exists`, mbe-api#345); this asks the list first
  /// so the warning comes before the save (research R16). A failed check
  /// doesn't block the save.
  Future<int?> _holderOf(int vehicleId) async {
    try {
      final page = await ref
          .read(deliveryItineraryRepositoryProvider)
          .list(
            status: ItineraryStatus.open,
            vehicleId: vehicleId,
            skip: 0,
            limit: 2,
          );
      return page.items
          .where((trip) => trip.id != _trip.id)
          .map((trip) => trip.id)
          .firstOrNull;
    } on AppError {
      return null;
    }
  }

  Future<void> _save() async {
    if (_busy || !_changed) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    if (_vehicleChanged && _vehicleId != null) {
      final holder = await _holderOf(_vehicleId!);
      if (!mounted) return;
      if (holder != null) {
        // The creation refusal's own code and params, so one localized
        // message serves both paths.
        setState(() {
          _busy = false;
          _refusal = AppError.server(
            statusCode: 409,
            problem: ApiProblem(
              codeName: 'vehicle.open_itinerary_exists',
              code: api.ErrorCode.vehiclePeriodOpenItineraryExists,
              params: {'vehicle_id': _vehicleId, 'itinerary_id': holder},
            ),
          );
        });
        return;
      }
    }
    final comment = _comment.text.trim();
    final error = await ref
        .read(deliveryItineraryActionsProvider.notifier)
        .updateHeader(
          _trip.id,
          date: _date == _trip.date ? null : _date,
          vehicleId: _vehicleChanged ? _vehicleId : null,
          operatorId: _operatorId == _trip.vehicleOperatorId
              ? null
              : _operatorId,
          comment: comment == (_trip.comment ?? '') ? null : comment,
        );
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    bool canRead(SystemObject object) => access.can(object, AccessRight.read);

    return ResponsiveDialog(
      key: const Key('itinerary_header_dialog'),
      title: l10n.itineraryHeaderTitle(_trip.id),
      dismissible: !_busy,
      hasUnsavedChanges: () => _changed,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          InkWell(
            key: const Key('itinerary_header_date'),
            onTap: _busy ? null : _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.itineraryFieldDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(fmt.display.date(_date)),
            ),
          ),
          if (canRead(SystemObject.vehicle))
            ItineraryVehiclePicker(
              key: const Key('itinerary_header_vehicle'),
              label: l10n.itineraryFieldVehicle,
              initialDisplayText: _trip.vehicleName,
              onSelected: (v) => setState(() {
                _vehicleId = v.vehicleId;
                _refusal = null;
              }),
            ),
          if (canRead(SystemObject.vehicleOperators))
            ItineraryOperatorPicker(
              key: const Key('itinerary_header_operator'),
              label: l10n.itineraryFieldOperator,
              initialDisplayText: _trip.operatorName,
              onSelected: (o) =>
                  setState(() => _operatorId = o.vehicleOperatorId),
            ),
          TextField(
            key: const Key('itinerary_header_comment'),
            controller: _comment,
            enabled: !_busy,
            decoration: InputDecoration(labelText: l10n.itineraryFieldComment),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null) ItineraryRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('itinerary_header_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _changed ? _save : null,
      ),
    );
  }
}
