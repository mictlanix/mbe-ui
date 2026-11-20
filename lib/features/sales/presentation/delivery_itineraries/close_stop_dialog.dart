import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/signature_pad.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';
import 'package:mbe_ui/core/widgets/inline_error_text.dart';

/// A chosen proof image: its bytes and the file's name.
typedef PickedProof = ({Uint8List bytes, String name});

/// The most the server takes for a proof image (`image.too_large`). Checked
/// here too, before the upload, so the user isn't sent a whole round trip to
/// be told (spec 075 research R8).
const _maxProofBytes = 2 * 1024 * 1024;

const _proofExtensions = ['jpg', 'jpeg', 'png'];

/// The platform file picker, restricted to the formats the server accepts, as
/// the pickup dialog does (spec 051's path). `null` when nothing was chosen.
Future<PickedProof?> _pickProof() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: _proofExtensions,
    withData: true,
  );
  final file = result?.files.singleOrNull;
  final bytes = file?.bytes;
  if (file == null || bytes == null) return null;
  return (bytes: bytes, name: file.name);
}

/// "Cerrar parada" (spec 075 FR-015 to FR-018, research R8): the one form that
/// records a stop from the returned paperwork. Who received it, what each
/// line delivered (with a reason for any shortfall), and one proof: an image
/// from a file, or a signature drawn on screen.
///
/// "Cerrar parada" stays disabled until FR-016 holds, and a list under the
/// form names what's missing. A server refusal (`stop_already_resolved`,
/// `stop_shortfall_needs_reason`, `image.too_large`, ...) shows inside the
/// dialog, which stays open with everything the user typed. Answers the
/// outcome, or `null` when the user backed out.
///
/// [pickImage] replaces the platform picker in tests.
Future<ItineraryActionResult?> showCloseStopDialog(
  BuildContext context, {
  required Itinerary trip,
  required ItineraryStop stop,
  @visibleForTesting Future<PickedProof?> Function()? pickImage,
}) => showResponsiveDialog<ItineraryActionResult>(
  context,
  builder: (context) => _CloseStopDialog(
    trip: trip,
    stop: stop,
    pickImage: pickImage ?? _pickProof,
  ),
);

enum _Proof { image, signature }

class _CloseStopDialog extends ConsumerStatefulWidget {
  const _CloseStopDialog({
    required this.trip,
    required this.stop,
    required this.pickImage,
  });

  final Itinerary trip;
  final ItineraryStop stop;
  final Future<PickedProof?> Function() pickImage;

  @override
  ConsumerState<_CloseStopDialog> createState() => _CloseStopDialogState();
}

class _CloseStopDialogState extends ConsumerState<_CloseStopDialog> {
  final _name = TextEditingController();
  final _idShown = TextEditingController();
  final _signature = SignatureController();
  final _delivered = <int, TextEditingController>{};
  final _reasons = <int, ShortfallReason?>{};

  _Proof _proof = _Proof.image;
  PickedProof? _image;

  /// The inline text for an image that was refused before sending.
  String? _imageProblem;
  bool _busy = false;
  AppError? _refusal;

  ItineraryStop get _stop => widget.stop;

  @override
  void initState() {
    super.initState();
    final fmt = ref.read(formattersProvider);
    // Everything delivered is the common case, so it's where each row starts.
    for (final line in _stop.lines) {
      _delivered[line.id] = TextEditingController(
        text: fmt.field.quantity(line.sent.toString()),
      );
    }
    _signature.addListener(_rebuild);
  }

  @override
  void dispose() {
    _name.dispose();
    _idShown.dispose();
    _signature
      ..removeListener(_rebuild)
      ..dispose();
    for (final c in _delivered.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  /// What the line's field says, when it is a number between 0 and what was
  /// sent; `null` otherwise.
  Decimal? _deliveredOf(ItineraryLine line) {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_delivered[line.id]!.text);
    final value = parsed == null ? null : Decimal.tryParse(parsed);
    if (value == null || value < Decimal.zero || value > line.sent) {
      return null;
    }
    return value;
  }

  bool _isShort(ItineraryLine line) {
    final value = _deliveredOf(line);
    return value != null && value < line.sent;
  }

  void _setAll({required bool everything}) {
    final fmt = ref.read(formattersProvider);
    setState(() {
      for (final line in _stop.lines) {
        _delivered[line.id]!.text = everything
            ? fmt.field.quantity(line.sent.toString())
            : '0';
      }
    });
  }

  Future<void> _chooseImage() async {
    final picked = await widget.pickImage();
    if (!mounted || picked == null) return;
    final extension = picked.name.split('.').last.toLowerCase();
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (!_proofExtensions.contains(extension)) {
        _image = null;
        _imageProblem = l10n.itineraryCloseImageFormat;
      } else if (picked.bytes.length > _maxProofBytes) {
        _image = null;
        _imageProblem = l10n.itineraryCloseImageTooLarge;
      } else {
        _image = picked;
        _imageProblem = null;
      }
    });
  }

  bool get _hasProof => switch (_proof) {
    _Proof.image => _image != null,
    _Proof.signature => !_signature.isEmpty,
  };

  /// What stands between the user and "Cerrar parada" (FR-016), in words.
  List<String> _missing(AppLocalizations l10n) => [
    if (_name.text.trim().isEmpty) l10n.itineraryCloseMissingReceiver,
    if (_idShown.text.trim().isEmpty) l10n.itineraryCloseMissingId,
    for (final line in _stop.lines)
      if (_isShort(line) && _reasons[line.id] == null)
        l10n.itineraryCloseMissingReason(line.productCode),
    if (!_hasProof) l10n.itineraryCloseMissingProof,
  ];

  bool get _linesValid => _stop.lines.every((l) => _deliveredOf(l) != null);

  bool _canClose(AppLocalizations l10n) =>
      !_busy && _linesValid && _missing(l10n).isEmpty;

  Future<void> _close() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_canClose(l10n)) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final ProofImage proof;
    if (_proof == _Proof.signature) {
      proof = ProofImage(
        bytes: await _signature.toPng(),
        filename: 'firma.png',
      );
    } else {
      proof = ProofImage(bytes: _image!.bytes, filename: _image!.name);
    }
    if (!mounted) return;
    final error = await ref
        .read(deliveryItineraryActionsProvider.notifier)
        .closeStop(
          widget.trip.id,
          _stop.id,
          StopClosure(
            receiverName: _name.text.trim(),
            receiverIdShown: _idShown.text.trim(),
            lines: [
              for (final line in _stop.lines)
                StopClosureLine(
                  lineId: line.id,
                  delivered: _deliveredOf(line)!,
                  reason: _isShort(line) ? _reasons[line.id] : null,
                ),
            ],
            proof: proof,
          ),
        );
    if (!mounted) return;
    if (error == null) {
      navigator.pop((error: null));
      return;
    }
    // Kept open with everything the user typed, so the fix is one edit away.
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  Widget _lineRow(
    BuildContext context,
    ItineraryLine line, {
    required bool compact,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final typed = _delivered[line.id]!.text.trim().isNotEmpty;
    final unit = line.unitSymbol == null ? '' : ' ${line.unitSymbol}';

    final product = Text('${line.productCode}  ${line.productName}');
    final sent = Text(
      l10n.itineraryCloseSentLabel(
        '${fmt.display.quantity(line.sent.toString())}$unit',
      ),
    );
    final field = SizedBox(
      width: 120,
      child: TextField(
        key: Key('itinerary_close_delivered_${line.id}'),
        controller: _delivered[line.id],
        enabled: !_busy,
        textAlign: TextAlign.end,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          isDense: true,
          labelText: l10n.itineraryCloseDeliveredField,
          errorText: typed && _deliveredOf(line) == null
              ? l10n.itineraryQuantityInvalid
              : null,
          errorMaxLines: 3,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
    final reason = _isShort(line)
        ? SizedBox(
            width: 200,
            child: DropdownButtonFormField<ShortfallReason>(
              key: Key('itinerary_close_reason_${line.id}'),
              initialValue: _reasons[line.id],
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                labelText: l10n.itineraryCloseReasonField,
              ),
              items: [
                for (final r in ShortfallReason.values)
                  DropdownMenuItem(
                    value: r,
                    child: Text(shortfallReasonLabel(l10n, r)),
                  ),
              ],
              onChanged: _busy
                  ? null
                  : (r) => setState(() => _reasons[line.id] = r),
            ),
          )
        : null;

    if (compact) {
      // Each line is two rows: what it is and was sent, then the inputs.
      return Column(
        key: Key('itinerary_close_line_${line.id}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xs,
        children: [
          product,
          sent,
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [field, ?reason],
          ),
        ],
      );
    }
    return Row(
      key: Key('itinerary_close_line_${line.id}'),
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: spacing.md,
      children: [
        Expanded(child: product),
        sent,
        field,
        // The reason column keeps its width, so rows don't jump.
        SizedBox(width: 200, child: reason),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final compact = LayoutBreakpoints.isCompact(context);
    final missing = _missing(l10n);
    final title = l10n.itineraryCloseTitle(_stop.sequence);
    final orderId = _stop.deliveryOrderId;

    return ResponsiveDialog(
      key: const Key('itinerary_close_dialog'),
      title: orderId != null && _stop.customerName != null
          ? l10n.itineraryCloseSubtitle(title, '$orderId', _stop.customerName!)
          : title,
      dismissible: !_busy,
      maxWidth: 860,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.itineraryCloseReceiverSection,
            style: theme.textTheme.titleSmall,
          ),
          Wrap(
            spacing: spacing.md,
            runSpacing: spacing.sm,
            children: [
              SizedBox(
                width: compact ? double.infinity : 320,
                child: TextField(
                  key: const Key('itinerary_close_name'),
                  controller: _name,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: l10n.itineraryCloseReceiverName,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                width: compact ? double.infinity : 320,
                child: TextField(
                  key: const Key('itinerary_close_id'),
                  controller: _idShown,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: l10n.itineraryCloseReceiverId,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const Divider(),
          // The section's title, and its two shortcuts: beside it on a wide
          // screen, under it on a compact one, where they would overflow.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.md,
            runSpacing: spacing.sm,
            children: [
              Text(
                l10n.itineraryCloseLinesSection,
                style: theme.textTheme.titleSmall,
              ),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  OutlinedButton(
                    key: const Key('itinerary_close_all'),
                    onPressed: _busy ? null : () => _setAll(everything: true),
                    child: Text(l10n.itineraryCloseAllDelivered),
                  ),
                  OutlinedButton(
                    key: const Key('itinerary_close_none'),
                    onPressed: _busy ? null : () => _setAll(everything: false),
                    child: Text(l10n.itineraryCloseNothingDelivered),
                  ),
                ],
              ),
            ],
          ),
          for (final line in _stop.lines)
            _lineRow(context, line, compact: compact),
          const Divider(),
          Text(
            l10n.itineraryCloseProofSection,
            style: theme.textTheme.titleSmall,
          ),
          SegmentedButton<_Proof>(
            key: const Key('itinerary_close_proof_kind'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _Proof.image,
                label: Text(l10n.itineraryCloseProofImage),
              ),
              ButtonSegment(
                value: _Proof.signature,
                label: Text(l10n.itineraryCloseProofSignature),
              ),
            ],
            selected: {_proof},
            // Switching keeps each side's input; only the selected one is sent.
            onSelectionChanged: _busy
                ? null
                : (s) => setState(() => _proof = s.single),
          ),
          if (_proof == _Proof.image)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: spacing.sm,
              runSpacing: spacing.xs,
              children: [
                OutlinedButton.icon(
                  key: const Key('itinerary_close_choose_image'),
                  onPressed: _busy ? null : _chooseImage,
                  icon: const Icon(Icons.attach_file),
                  label: Text(l10n.itineraryCloseChooseImage),
                ),
                if (_image != null) ...[
                  Text(
                    _image!.name,
                    key: const Key('itinerary_close_image_name'),
                  ),
                  IconButton(
                    key: const Key('itinerary_close_remove_image'),
                    tooltip: l10n.itineraryCloseRemoveImage,
                    onPressed: _busy
                        ? null
                        : () => setState(() => _image = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
                if (_imageProblem != null)
                  InlineErrorText(
                    _imageProblem!,
                    key: const Key('itinerary_close_image_problem'),
                  ),
              ],
            )
          else
            SignaturePad(controller: _signature),
          if (missing.isNotEmpty)
            Text(
              '${l10n.itineraryCloseMissingTitle} ${missing.join(', ')}.',
              key: const Key('itinerary_close_missing'),
              style: theme.textTheme.bodySmall,
            ),
          if (_refusal != null) ItineraryRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('itinerary_close_submit'),
        label: l10n.itineraryCloseConfirm,
        busy: _busy,
        onPressed: _canClose(l10n) ? _close : null,
      ),
    );
  }
}
