import 'package:flutter/material.dart';

/// The fixed action vocabulary every catalog MUST use, with one fixed icon
/// per action (constitution §VI, v1.7.0).
enum CatalogAction {
  /// Toolbar-only — never a row action.
  create(Icons.add),

  /// The row's primary action. Clicking anywhere else on the row opens the
  /// same form read-only (constitution §VI).
  edit(Icons.edit_outlined);

  const CatalogAction(this.icon);

  final IconData icon;
}

/// A single additional row-level action beyond Edit, passed to
/// [buildCatalogRowActions]. The icon/tooltip/callback are all
/// caller-supplied so this shared widget stays free of feature-specific
/// icons and localization.
class CatalogRowAction {
  const CatalogRowAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Key? key;
}

/// Builds a catalog row's trailing actions (constitution §VI, v1.7.0): Edit
/// first, omitted when [onEdit] is `null` rather than rendered disabled, so
/// callers decide visibility based on `AccessControlService.can(...)`.
///
/// [extraActions] adds row-level actions beyond Edit:
/// - Zero or one extra action renders as its own direct icon.
/// - Two or more collapse behind a single overflow ("kebab") menu icon
///   instead of stacking more row icons — a row MUST show at most two icons
///   total. [moreActionsTooltip] is required in that case.
///
/// Tooltips are caller-supplied (e.g. `AppLocalizations.editActionTooltip`)
/// so this shared widget has no localization dependency of its own.
List<Widget> buildCatalogRowActions({
  required String editTooltip,
  VoidCallback? onEdit,
  List<CatalogRowAction> extraActions = const [],
  String? moreActionsTooltip,
}) {
  assert(
    extraActions.length <= 1 || moreActionsTooltip != null,
    'moreActionsTooltip is required once extraActions has more than one '
    'entry (constitution §VI, v1.7.0 — collapse into an overflow menu)',
  );

  return [
    if (onEdit != null)
      IconButton(
        icon: Icon(CatalogAction.edit.icon),
        tooltip: editTooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onEdit,
      ),
    if (extraActions.length == 1)
      IconButton(
        key: extraActions.single.key,
        icon: Icon(extraActions.single.icon),
        tooltip: extraActions.single.tooltip,
        visualDensity: VisualDensity.compact,
        onPressed: extraActions.single.onPressed,
      ),
    if (extraActions.length > 1)
      PopupMenuButton<VoidCallback>(
        icon: const Icon(Icons.more_vert),
        tooltip: moreActionsTooltip,
        onSelected: (onPressed) => onPressed(),
        itemBuilder: (context) => [
          for (final action in extraActions)
            PopupMenuItem<VoidCallback>(
              key: action.key,
              value: action.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(action.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(action.tooltip),
                ],
              ),
            ),
        ],
      ),
  ];
}
