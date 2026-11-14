import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_address_picker.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_contact_picker.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Edits a draft's header (spec 061 C10, FR-012, research R7): scheduled date
/// and time, priority, ship-to, contact and comment. `true` once saved.
///
/// Only changed fields are sent. None can be cleared, because the server
/// ignores an empty value (spec Edge Cases "Fields that can't be cleared"),
/// so no field offers to. A pickup keeps its store's address: its ship-to is
/// shown read-only. A refusal shows inline and keeps the dialog open.
Future<bool> showDeliveryOrderHeaderDialog(
  BuildContext context,
  DeliveryOrder order,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) => _HeaderDialog(order: order),
    ) ??
    false;

class _HeaderDialog extends ConsumerStatefulWidget {
  const _HeaderDialog({required this.order});

  final DeliveryOrder order;

  @override
  ConsumerState<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends ConsumerState<_HeaderDialog> {
  late DateTime? _date = widget.order.date;
  late int? _shipTo = widget.order.shipToId;
  late int? _contact = widget.order.contactId;
  late final _priority = TextEditingController(
    text: '${widget.order.priority}',
  );
  late final _comment = TextEditingController(text: widget.order.comment ?? '');
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _priority.dispose();
    _comment.dispose();
    super.dispose();
  }

  DeliveryOrder get _order => widget.order;

  /// The typed priority, or `null` when it isn't a whole number ≥ 0.
  int? get _priorityValue {
    final value = int.tryParse(_priority.text.trim());
    return value == null || value < 0 ? null : value;
  }

  // Each answers the value to send, or null when the field is unchanged.
  DateTime? get _dateChange => _date == _order.date ? null : _date;
  int? get _priorityChange {
    final value = _priorityValue;
    return value == _order.priority ? null : value;
  }

  int? get _shipToChange =>
      _order.isPickup || _shipTo == _order.shipToId ? null : _shipTo;
  int? get _contactChange => _contact == _order.contactId ? null : _contact;
  String? get _commentChange {
    final text = _comment.text.trim();
    // An empty comment would be ignored by the server, so it isn't a change.
    return text.isEmpty || text == (_order.comment ?? '') ? null : text;
  }

  bool get _canSave =>
      !_busy &&
      _priorityValue != null &&
      (_dateChange != null ||
          _priorityChange != null ||
          _shipToChange != null ||
          _contactChange != null ||
          _commentChange != null);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _date ?? today;
    final day = await showDatePicker(
      context: context,
      initialDate: current,
      // A draft may carry a date already past; the picker must still open on
      // it. The server checks the notice on confirm.
      firstDate: current.isBefore(today) ? current : today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted) return;
    // Backing out of the time keeps the time the order had.
    final picked = time ?? TimeOfDay.fromDateTime(current);
    setState(
      () => _date = DateTime(
        day.year,
        day.month,
        day.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  Future<void> _pickShipTo() async {
    final id = await showCustomerAddressPicker(
      context,
      customerId: _order.customerId,
    );
    if (id != null && mounted) setState(() => _shipTo = id);
  }

  Future<void> _pickContact() async {
    final id = await showCustomerContactPicker(
      context,
      customerId: _order.customerId,
    );
    if (id != null && mounted) setState(() => _contact = id);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(deliveryOrderActionsProvider.notifier)
        .updateHeader(
          _order.id,
          date: _dateChange,
          priority: _priorityChange,
          shipTo: _shipToChange,
          contact: _contactChange,
          comment: _commentChange,
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
    final order = _order;

    Widget picker({
      required Key key,
      required IconData icon,
      required VoidCallback onPressed,
      required Widget label,
    }) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: OutlinedButton.icon(
        key: key,
        onPressed: _busy ? null : onPressed,
        icon: Icon(icon),
        label: label,
      ),
    );

    return ResponsiveDialog(
      key: const Key('delivery_order_header_dialog'),
      title: l10n.deliveryOrderHeaderTitle,
      maxWidth: 640,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          ResponsiveFormGrid(
            maxColumns: 2,
            spacing: spacing.fieldGapHorizontal,
            children: [
              FormGridChild(
                CompactField(
                  label: l10n.deliveryOrderHeaderScheduledLabel,
                  child: picker(
                    key: const Key('delivery_order_header_date'),
                    icon: Icons.event_outlined,
                    onPressed: _pickDate,
                    label: Text(fmt.display.dateTime(_date)),
                  ),
                ),
              ),
              FormGridChild(
                TextField(
                  key: const Key('delivery_order_header_priority'),
                  controller: _priority,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.deliveryOrderHeaderPriorityLabel,
                    errorText: _priorityValue == null
                        ? l10n.deliveryOrderHeaderPriorityInvalid
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              FormGridChild(
                CompactField(
                  label: l10n.deliveryOrderHeaderDestinationLabel,
                  child: order.isPickup
                      ? Text(
                          l10n.deliveryOrderHeaderPickupDestination(
                            ref
                                    .watch(
                                      facilityDisplayNameProvider(
                                        order.facilityId,
                                      ),
                                    )
                                    .value ??
                                '#${order.facilityId}',
                          ),
                          key: const Key('delivery_order_header_ship_to_store'),
                        )
                      : picker(
                          key: const Key('delivery_order_header_ship_to'),
                          icon: Icons.location_on_outlined,
                          onPressed: _pickShipTo,
                          label: DeliveryOrderShipTo(
                            type: order.type,
                            customerId: order.customerId,
                            facilityId: order.facilityId,
                            shipToId: _shipTo,
                          ),
                        ),
                ),
                span: FormGridSpan.full,
              ),
              FormGridChild(
                CompactField(
                  label: l10n.deliveryOrderHeaderContactLabel,
                  child: picker(
                    key: const Key('delivery_order_header_contact'),
                    icon: Icons.person_outline,
                    onPressed: _pickContact,
                    label: DeliveryOrderContact(
                      customerId: order.customerId,
                      contactId: _contact,
                    ),
                  ),
                ),
                span: FormGridSpan.full,
              ),
              FormGridChild(
                TextField(
                  key: const Key('delivery_order_header_comment'),
                  controller: _comment,
                  enabled: !_busy,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.deliveryOrderHeaderCommentLabel,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                span: FormGridSpan.full,
              ),
            ],
          ),
          if (_refusal != null) DeliveryOrderRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('delivery_order_header_save'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
