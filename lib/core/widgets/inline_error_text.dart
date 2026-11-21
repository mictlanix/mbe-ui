import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';

/// An error message shown inline in a screen or dialog: a leading error icon
/// plus the text in the theme's `error` color (spec 077 FR-016). The icon and
/// the words carry the meaning, so it never relies on red alone — the Casa
/// Maestra brand is red too.
///
/// For a message that needs a close button or a banner surface use
/// `ErrorBanner`; form-field errors keep Flutter's own `errorText`.
class InlineErrorText extends StatelessWidget {
  const InlineErrorText(this.text, {super.key, this.style});

  final String text;

  /// Overrides the default `fieldLabel` text role (e.g. a larger size). The
  /// color is always the theme's `error`.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    final base = style ?? theme.typeRoles.fieldLabel;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.error_outline, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text, style: base.copyWith(color: color)),
        ),
      ],
    );
  }
}
