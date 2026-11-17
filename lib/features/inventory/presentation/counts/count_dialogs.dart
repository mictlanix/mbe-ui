import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The prompts the count detail screen opens (spec 070 ui-contract
// "Dialogs", wireframes "Dialogs"). The line prompts run their own write
// through `InventoryCountActions`, which puts the returned count on screen.

/// A counted quantity: 0 or more, with up to 4 decimals (FR-008). `null`
/// when [text] is not one.
Decimal? parseCountedQuantity(WidgetRef ref, String text) {
  final parsed = ref.read(formattersProvider).field.parseQuantity(text);
  if (parsed == null) return null;
  final value = Decimal.parse(parsed);
  return value < Decimal.zero || value.scale > 4 ? null : value;
}

/// The refusal to show for a one-line write: a `batch_invalid` batch of one
/// names its single bad entry in a part, and that part's message is the
/// useful one, not the batch headline (FR-016). Any other refusal is shown
/// as it came.
AppError countLineRefusal(AppError error) {
  final problem = error.problem;
  if (problem?.code != api.ErrorCode.inventoryCountPeriodBatchInvalid ||
      problem!.parts.length != 1) {
    return error;
  }
  final part = problem.parts.single;
  if (part.code == null) return error;
  return AppError.validation(
    const [],
    null,
    ApiProblem(codeName: part.codeName, code: part.code, params: part.params),
  );
}

/// A line's product for a sentence: its name, else its code, else its id.
String _productLabel(InventoryCountLine line) => line.productName.isNotEmpty
    ? line.productName
    : line.productCode.isNotEmpty
    ? line.productCode
    : '#${line.productId}';

/// The refusal inside a dialog, localized from its code (§III).
class _Refusal extends StatelessWidget {
  const _Refusal({required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) => ErrorBanner(
    key: const Key('inventory_count_dialog_refusal'),
    error: error,
  );
}

// ---------------------------------------------------------------------------
// Cantidad contada
// ---------------------------------------------------------------------------

/// Changes [line]'s counted quantity on draft [countId]. `true` once saved.
/// The client checks only that the quantity is 0 or more with up to 4
/// decimals; every refusal shows inline and keeps the dialog open.
Future<bool> showCountLineQuantityDialog(
  BuildContext context, {
  required int countId,
  required InventoryCountLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) => _LineQuantityDialog(countId: countId, line: line),
    ) ??
    false;

class _LineQuantityDialog extends ConsumerStatefulWidget {
  const _LineQuantityDialog({required this.countId, required this.line});

  final int countId;
  final InventoryCountLine line;

  @override
  ConsumerState<_LineQuantityDialog> createState() =>
      _LineQuantityDialogState();
}

class _LineQuantityDialogState extends ConsumerState<_LineQuantityDialog> {
  late final String _initial = ref
      .read(formattersProvider)
      .field
      .quantity(widget.line.quantity.toString());
  late final _quantity = TextEditingController(text: _initial);
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Decimal? get _value => parseCountedQuantity(ref, _quantity.text);

  bool get _canSave =>
      !_busy && _value != null && _value != widget.line.quantity;

  Future<void> _save() async {
    final value = _value;
    if (!_canSave || value == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(inventoryCountActionsProvider.notifier)
        .updateLine(widget.countId, widget.line.id, quantity: value);
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

    return ResponsiveDialog(
      key: const Key('inventory_count_line_quantity_dialog'),
      title: l10n.inventoryCountDialogQuantityTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _quantity.text != _initial,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text('${line.productCode} ${line.productName}'.trim()),
          TextField(
            key: const Key('inventory_count_line_quantity_field'),
            controller: _quantity,
            enabled: !_busy,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.inventoryCountFieldCounted,
              errorText: _value != null
                  ? null
                  : l10n.inventoryCountQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          if (_refusal != null) _Refusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_count_line_quantity_submit'),
        label: l10n.inventoryCountDialogSave,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quitar partida
// ---------------------------------------------------------------------------

/// Asks before removing [line] from draft [countId], then removes it.
/// `true` once removed; a refusal shows inline and keeps the dialog open.
Future<bool> showRemoveCountLineDialog(
  BuildContext context, {
  required int countId,
  required InventoryCountLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) => _RemoveLineDialog(countId: countId, line: line),
    ) ??
    false;

class _RemoveLineDialog extends ConsumerStatefulWidget {
  const _RemoveLineDialog({required this.countId, required this.line});

  final int countId;
  final InventoryCountLine line;

  @override
  ConsumerState<_RemoveLineDialog> createState() => _RemoveLineDialogState();
}

class _RemoveLineDialogState extends ConsumerState<_RemoveLineDialog> {
  bool _busy = false;
  AppError? _refusal;

  Future<void> _remove() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(inventoryCountActionsProvider.notifier)
        .removeLine(widget.countId, widget.line.id);
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

    return ResponsiveDialog(
      key: const Key('inventory_count_line_remove_dialog'),
      title: l10n.inventoryCountDialogRemoveTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.inventoryCountDialogRemoveBody(_productLabel(widget.line))),
          if (_refusal != null) _Refusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_count_line_remove_submit'),
        label: l10n.inventoryCountRemoveAction,
        busy: _busy,
        onPressed: _remove,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirmar conteo
// ---------------------------------------------------------------------------

/// The confirm prompt (FR-012): says the stock of [warehouse] is set to the
/// counted quantities and that a confirmed count can't be cancelled, and
/// offers "count uncounted as 0", off by default.
///
/// Answers the checkbox's value on accept, `null` when the user backed out.
/// The caller runs the confirm. It never says how many products would be
/// zeroed: a draft is blind (SC-003).
Future<bool?> showConfirmCountDialog(
  BuildContext context, {
  required String warehouse,
}) => showResponsiveDialog<bool>(
  context,
  builder: (context) => _ConfirmDialog(warehouse: warehouse),
);

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({required this.warehouse});

  final String warehouse;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  bool _includeUncounted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ResponsiveDialog(
      key: const Key('inventory_count_confirm_dialog'),
      title: l10n.inventoryCountDialogConfirmTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.inventoryCountConfirmBody(widget.warehouse),
            key: const Key('inventory_count_confirm_body'),
          ),
          CheckboxListTile(
            key: const Key('inventory_count_confirm_include_uncounted'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _includeUncounted,
            title: Text(l10n.inventoryCountConfirmIncludeUncounted),
            onChanged: (value) =>
                setState(() => _includeUncounted = value ?? false),
          ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.inventoryCountDialogBack,
        onPressed: () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_count_confirm_submit'),
        label: l10n.inventoryCountActionConfirm,
        onPressed: () => Navigator.of(context).pop(_includeUncounted),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cancelar borrador
// ---------------------------------------------------------------------------

/// The cancel prompt (FR-014): says draft [countId] is cancelled with no
/// stock changed. `true` on accept, `false` when the user backed out; the
/// caller runs the cancel. There is no variant for a completed count,
/// because one can't be cancelled.
Future<bool> showCancelCountDialog(
  BuildContext context, {
  required int countId,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) => _CancelDialog(countId: countId),
    ) ??
    false;

class _CancelDialog extends StatelessWidget {
  const _CancelDialog({required this.countId});

  final int countId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialog(
      key: const Key('inventory_count_cancel_dialog'),
      title: l10n.inventoryCountDialogCancelTitle,
      body: Text(
        l10n.inventoryCountCancelBody('$countId'),
        key: const Key('inventory_count_cancel_body'),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.inventoryCountDialogBack,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_count_cancel_submit'),
        label: l10n.inventoryCountDialogCancelDraft,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
