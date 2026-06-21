import 'package:flutter/material.dart';

/// The fixed Create/View/Edit/Delete action vocabulary every catalog MUST
/// use, with exactly one icon and one position per action (constitution
/// §VI; FR-003 through FR-005; contracts/catalog-action-icons.md).
enum CatalogAction {
  /// Toolbar-only — never a row action.
  create(Icons.add),

  /// First of the row's trailing actions. Opens the same form as [edit],
  /// rendered read-only (FR-006).
  view(Icons.visibility_outlined),

  /// Second of the row's trailing actions.
  edit(Icons.edit_outlined),

  /// Third (last) of the row's trailing actions.
  delete(Icons.delete_outline);

  const CatalogAction(this.icon);

  final IconData icon;
}

/// Builds a catalog row's trailing actions in the fixed `[view, edit,
/// delete]` order (FR-004), omitting any action whose callback is `null`
/// rather than rendering it disabled (FR-012) — callers decide whether to
/// pass a callback based on `AccessControlService.can(...)` and whether
/// the target supports the action. Tooltips are caller-supplied
/// (`AppLocalizations.viewActionTooltip` etc.) so this shared widget has
/// no localization dependency of its own.
List<Widget> buildCatalogRowActions({
  required String viewTooltip,
  required String editTooltip,
  required String deleteTooltip,
  VoidCallback? onView,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return [
    if (onView != null)
      IconButton(
        icon: Icon(CatalogAction.view.icon),
        tooltip: viewTooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onView,
      ),
    if (onEdit != null)
      IconButton(
        icon: Icon(CatalogAction.edit.icon),
        tooltip: editTooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onEdit,
      ),
    if (onDelete != null)
      IconButton(
        icon: Icon(CatalogAction.delete.icon),
        tooltip: deleteTooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onDelete,
      ),
  ];
}
