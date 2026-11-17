import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_dialogs.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Captura rápida (FR-011b, research R6): a code, a quantity and Enter,
/// product after product, keyboard or scanner only.
///
/// The code goes to the server as typed (trimmed), with no search. Enter in
/// Código moves to Cantidad; Enter in Cantidad submits. On success both
/// fields clear, focus returns to Código and a feedback line names the entry,
/// with the old quantity when it replaced one (FR-009). On a refusal the
/// values stay and the reason shows under the row.
///
/// Owns its controllers and focus nodes, so a rebuild of the detail (every
/// write puts a new count on screen) never drops keystrokes, as the POS
/// `ProductSearchField` does.
class CountQuickEntry extends ConsumerStatefulWidget {
  const CountQuickEntry({super.key, required this.count});

  /// The loaded count, to know whether an entry replaces a line.
  final InventoryCount count;

  @override
  ConsumerState<CountQuickEntry> createState() => _CountQuickEntryState();
}

class _CountQuickEntryState extends ConsumerState<CountQuickEntry> {
  final _code = TextEditingController();
  final _quantity = TextEditingController();
  final _codeFocus = FocusNode();
  final _quantityFocus = FocusNode();
  bool _busy = false;
  String? _feedback;
  AppError? _refusal;

  @override
  void dispose() {
    _code.dispose();
    _quantity.dispose();
    _codeFocus.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  bool get _quantityInvalid =>
      _quantity.text.trim().isNotEmpty &&
      parseCountedQuantity(ref, _quantity.text) == null;

  static InventoryCountLine? _lineFor(InventoryCount? count, String code) {
    final key = code.toLowerCase();
    for (final line in count?.lines ?? const <InventoryCountLine>[]) {
      if (line.productCode.toLowerCase() == key) return line;
    }
    return null;
  }

  void _toQuantity() {
    if (_code.text.trim().isEmpty) {
      _codeFocus.requestFocus();
      return;
    }
    _quantityFocus.requestFocus();
  }

  Future<void> _submit() async {
    final code = _code.text.trim();
    if (_busy) return;
    if (code.isEmpty) {
      _codeFocus.requestFocus();
      return;
    }
    final quantity = parseCountedQuantity(ref, _quantity.text);
    if (quantity == null) {
      setState(() {});
      _quantityFocus.requestFocus();
      return;
    }
    final countId = widget.count.id;
    final previous = _lineFor(widget.count, code);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(inventoryCountActionsProvider.notifier)
        .setLines(countId, [
          CountLineInput.byCode(code: code, quantity: quantity),
        ]);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = countLineRefusal(error);
        _feedback = null;
      });
      _quantityFocus.requestFocus();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.read(formattersProvider);
    final written = _lineFor(
      ref.read(inventoryCountDetailControllerProvider(countId)).value,
      code,
    );
    final shownCode = written?.productCode ?? code;
    final name = written?.productName ?? previous?.productName ?? '';
    final newQty = fmt.display.quantity(quantity.toString());
    _code.clear();
    _quantity.clear();
    setState(() {
      _busy = false;
      _feedback = previous == null
          ? l10n.inventoryCountQuickEntryFeedback(shownCode, name, newQty)
          : l10n.inventoryCountQuickEntryFeedbackReplaced(
              shownCode,
              name,
              fmt.display.quantity(previous.quantity.toString()),
              newQty,
            );
    });
    _codeFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final compact = LayoutBreakpoints.isCompact(context);
    final feedback = _feedback;
    final refusal = _refusal;

    final title = Text(
      l10n.inventoryCountQuickEntryTitle,
      style: Theme.of(context).textTheme.titleSmall,
    );
    final codeField = TextField(
      key: const Key('count_quick_entry_code'),
      controller: _code,
      focusNode: _codeFocus,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: l10n.inventoryCountQuickEntryCode),
      // Focus moves only where this row says, never to the next control.
      onEditingComplete: () {},
      onSubmitted: (_) => _toQuantity(),
    );
    final quantityField = TextField(
      key: const Key('count_quick_entry_quantity'),
      controller: _quantity,
      focusNode: _quantityFocus,
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l10n.inventoryCountQuickEntryQuantity,
        errorText: _quantityInvalid ? l10n.inventoryCountQuantityInvalid : null,
      ),
      onChanged: (_) => setState(() {}),
      onEditingComplete: () {},
      onSubmitted: (_) => _submit(),
    );
    final button = FilledButton.tonal(
      key: const Key('count_quick_entry_submit'),
      onPressed: _busy ? null : _submit,
      child: Text(l10n.inventoryCountQuickEntrySubmit),
    );

    return Column(
      key: const Key('count_quick_entry'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.xs,
      children: [
        if (compact) ...[
          title,
          codeField,
          quantityField,
          Align(alignment: AlignmentDirectional.centerEnd, child: button),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.fieldGapHorizontal,
            children: [
              Padding(
                padding: EdgeInsets.only(top: spacing.md),
                child: title,
              ),
              Expanded(flex: 2, child: codeField),
              Expanded(child: quantityField),
              Padding(
                padding: EdgeInsets.only(top: spacing.xs),
                child: button,
              ),
            ],
          ),
        if (feedback != null)
          Text(feedback, key: const Key('count_quick_entry_feedback')),
        if (refusal != null)
          ErrorBanner(
            key: const Key('count_quick_entry_refusal'),
            error: refusal,
          ),
      ],
    );
  }
}
