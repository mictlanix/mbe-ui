import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';

/// An info-toned notice: a message beside an info icon on the secondary
/// container color. For errors use `ErrorBanner`.
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final color = theme.colorScheme.onSecondaryContainer;
    return Material(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(message, style: TextStyle(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
