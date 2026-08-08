import 'package:flutter/material.dart';

import 'package:mbe_ui/l10n/app_localizations.dart';

/// A 0–9 / decimal-point / backspace pad for amount entry (FR-043).
///
/// Keyboard-equivalent by construction: it edits the [controller] a caller
/// also binds to a real `TextField`, so every key here has a keyboard
/// counterpart and neither path is privileged. The pad never holds the
/// amount itself.
///
/// New in 020-point-of-sale — 021-cash-sessions' denomination-count entry is
/// a different shape (a quantity per denomination row) and built no
/// equivalent.
class NumberPad extends StatelessWidget {
  const NumberPad({super.key, required this.controller, this.enabled = true});

  final TextEditingController controller;
  final bool enabled;

  void _append(String character) {
    final text = controller.text;
    // One decimal point only — a second press is a no-op rather than
    // producing a value the server would reject.
    if (character == '.' && text.contains('.')) return;
    controller.text = text + character;
  }

  void _backspace() {
    final text = controller.text;
    if (text.isEmpty) return;
    controller.text = text.substring(0, text.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    const keys = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '.', '0'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.8,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final key in keys)
          OutlinedButton(
            key: Key('number_pad_$key'),
            onPressed: enabled ? () => _append(key) : null,
            child: Text(key),
          ),
        // The only key with no text of its own, so it carries a label for a
        // screen reader rather than announcing itself as an unnamed button.
        OutlinedButton(
          key: const Key('number_pad_backspace'),
          onPressed: enabled ? _backspace : null,
          child: Semantics(
            label: AppLocalizations.of(context)?.numberPadBackspace,
            button: true,
            child: const Icon(Icons.backspace_outlined),
          ),
        ),
      ],
    );
  }
}
