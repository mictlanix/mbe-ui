import 'package:flutter/material.dart';

import 'package:mbe_ui/l10n/app_localizations.dart';

/// Asks for the reference a method such as a card or transfer requires, right
/// before its payment is applied (spec 047 contracts C6). Resolves to the
/// trimmed reference when confirmed, or `null` when cancelled — a cancel
/// applies nothing.
Future<String?> showPaymentReferenceDialog(BuildContext context) =>
    showDialog<String>(
      context: context,
      builder: (_) => const _PaymentReferenceDialog(),
    );

class _PaymentReferenceDialog extends StatefulWidget {
  const _PaymentReferenceDialog();

  @override
  State<_PaymentReferenceDialog> createState() => _PaymentReferenceDialogState();
}

class _PaymentReferenceDialogState extends State<_PaymentReferenceDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final reference = _controller.text.trim();
    if (reference.isEmpty) return;
    Navigator.of(context).pop(reference);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      key: const Key('payment_reference_dialog'),
      title: Text(l10n.posPaymentReferenceTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: TextField(
          key: const Key('payment_reference_input'),
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.posPaymentReferenceLabel),
          onSubmitted: (_) => _confirm(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => FilledButton(
            key: const Key('payment_reference_confirm'),
            onPressed: _controller.text.trim().isEmpty ? null : _confirm,
            child: Text(l10n.posPaymentReferenceConfirm),
          ),
        ),
      ],
    );
  }
}
