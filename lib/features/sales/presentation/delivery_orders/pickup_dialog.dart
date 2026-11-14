import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_dialogs.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A chosen photo: its bytes and the file's name.
typedef PickedPhoto = ({Uint8List bytes, String name});

/// The platform file picker, restricted to the formats the server accepts
/// (spec 051's path, research R6). `null` when the user chose nothing.
Future<PickedPhoto?> _pickPhoto() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['jpg', 'jpeg', 'png'],
    withData: true,
  );
  final file = result?.files.singleOrNull;
  final bytes = file?.bytes;
  if (file == null || bytes == null) return null;
  return (bytes: bytes, name: file.name);
}

/// "Entregar al cliente" for pickup [order] in Lista para recoger (spec 061
/// C9, FR-021): the receiver's name, the identification they showed (free
/// text) and a photo, all required. `true` once the server accepted.
///
/// Every refusal (`delivery_order.proof_incomplete`, `image.too_large`,
/// `image.unsupported_format` and the rest) shows inside the dialog, which
/// stays open with the fields and the chosen photo kept. The photo's size and
/// format are the server's to check.
///
/// [pickPhoto] replaces the platform picker in tests.
Future<bool> showPickupDialog(
  BuildContext context,
  DeliveryOrder order, {
  @visibleForTesting Future<PickedPhoto?> Function()? pickPhoto,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) =>
          _PickupDialog(order: order, pickPhoto: pickPhoto ?? _pickPhoto),
    ) ??
    false;

class _PickupDialog extends ConsumerStatefulWidget {
  const _PickupDialog({required this.order, required this.pickPhoto});

  final DeliveryOrder order;
  final Future<PickedPhoto?> Function() pickPhoto;

  @override
  ConsumerState<_PickupDialog> createState() => _PickupDialogState();
}

class _PickupDialogState extends ConsumerState<_PickupDialog> {
  final _name = TextEditingController();
  final _idShown = TextEditingController();
  PickedPhoto? _photo;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _name.dispose();
    _idShown.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_busy &&
      _name.text.trim().isNotEmpty &&
      _idShown.text.trim().isNotEmpty &&
      _photo != null;

  Future<void> _choose() async {
    final photo = await widget.pickPhoto();
    if (!mounted || photo == null) return;
    setState(() => _photo = photo);
  }

  Future<void> _submit() async {
    final photo = _photo;
    if (!_canSubmit || photo == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(deliveryOrderActionsProvider.notifier)
        .confirmPickup(
          widget.order.id,
          receiverName: _name.text.trim(),
          receiverIdShown: _idShown.text.trim(),
          bytes: photo.bytes,
          filename: photo.name,
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
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final order = widget.order;
    final photo = _photo;

    return ResponsiveDialog(
      key: const Key('delivery_order_pickup_dialog'),
      title: l10n.deliveryOrderPickupTitle(
        order.serial == null ? l10n.deliveryOrderDraftFolio : '${order.serial}',
      ),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          TextField(
            key: const Key('delivery_order_pickup_name'),
            controller: _name,
            enabled: !_busy,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.deliveryOrderPickupNameLabel,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            key: const Key('delivery_order_pickup_id'),
            controller: _idShown,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.deliveryOrderPickupIdLabel,
            ),
            onChanged: (_) => setState(() {}),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.xs,
            children: [
              Text(
                l10n.deliveryOrderPickupPhotoLabel,
                style: theme.textTheme.labelLarge,
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: spacing.sm,
                runSpacing: spacing.xs,
                children: [
                  OutlinedButton.icon(
                    key: const Key('delivery_order_pickup_choose_file'),
                    onPressed: _busy ? null : _choose,
                    icon: const Icon(Icons.attach_file),
                    label: Text(l10n.deliveryOrderPickupChooseFile),
                  ),
                  if (photo != null) ...[
                    Text(
                      photo.name,
                      key: const Key('delivery_order_pickup_file_name'),
                    ),
                    IconButton(
                      key: const Key('delivery_order_pickup_clear_file'),
                      tooltip: l10n.deliveryOrderPickupClearFile,
                      onPressed: _busy
                          ? null
                          : () => setState(() => _photo = null),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (_refusal != null) DeliveryOrderRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.deliveryOrderBackButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('delivery_order_pickup_submit'),
        label: l10n.deliveryOrderPickupSubmit,
        busy: _busy,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }
}
