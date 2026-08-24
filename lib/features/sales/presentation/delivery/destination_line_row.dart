import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';

/// One sale line, read-only: its name and the quantity a destination holds
/// of it. The shape `DestinationCard`'s non-interactive rows and
/// `DestinationCounterRow`'s expanded body both draw (spec 030 research
/// R11) — lifted here so it exists once rather than twice.
class DestinationLineRow extends StatelessWidget {
  const DestinationLineRow({
    super.key,
    required this.productName,
    required this.quantity,
    required this.fmt,
  });

  final String productName;

  /// A wire-format decimal string, formatted here through [fmt] — the one
  /// formatting surface (constitution §V).
  final String quantity;

  final AppFormatters fmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              productName,
              style: theme.typeRoles.tableCell,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(fmt.field.quantity(quantity), style: theme.typeRoles.recordId),
        ],
      ),
    );
  }
}
