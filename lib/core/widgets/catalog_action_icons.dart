import 'package:flutter/material.dart';

/// The fixed action vocabulary every catalog MUST use, with exactly one
/// icon and one position per action (constitution §VI, v1.5.0).
enum CatalogAction {
  /// Toolbar-only — never a row action.
  create(Icons.add),

  /// The row's sole trailing action. Clicking anywhere else on the row
  /// opens the same form read-only (constitution §VI).
  edit(Icons.edit_outlined);

  const CatalogAction(this.icon);

  final IconData icon;
}

/// Builds a catalog row's trailing actions — just Edit (constitution §VI,
/// v1.5.0) — omitting it when [onEdit] is `null` rather than rendering it
/// disabled, so callers decide visibility based on
/// `AccessControlService.can(...)`. The tooltip is caller-supplied
/// (`AppLocalizations.editActionTooltip`) so this shared widget has no
/// localization dependency of its own.
List<Widget> buildCatalogRowActions({
  required String editTooltip,
  VoidCallback? onEdit,
}) {
  return [
    if (onEdit != null)
      IconButton(
        icon: Icon(CatalogAction.edit.icon),
        tooltip: editTooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onEdit,
      ),
  ];
}
