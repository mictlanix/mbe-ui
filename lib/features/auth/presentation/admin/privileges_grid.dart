import 'package:flutter/material.dart';

import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Renders a full-width DataTable with one row per [SystemObject] and four
/// C/R/U/D checkbox columns. Read-only when [onChanged] is null.
class PrivilegesGrid extends StatelessWidget {
  const PrivilegesGrid({
    super.key,
    required this.privileges,
    this.onChanged,
  });

  final List<Privilege> privileges;

  /// Called when a checkbox is toggled. Receives the [SystemObject] and the
  /// new `rawValue` bitmask (`0`–`15`). Null = read-only.
  final void Function(SystemObject obj, int rawValue)? onChanged;

  @override
  Widget build(BuildContext context) {
    final byObject = {for (final p in privileges) p.systemObject: p};
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columns: [
              DataColumn(label: Text(l10n.privilegesModuleColumn)),
              DataColumn(
                label: Tooltip(
                  message: l10n.privilegesCreateTooltip,
                  child: Text(l10n.privilegesCreateColumn),
                ),
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.privilegesReadTooltip,
                  child: Text(l10n.privilegesReadColumn),
                ),
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.privilegesUpdateTooltip,
                  child: Text(l10n.privilegesUpdateColumn),
                ),
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.privilegesDeleteTooltip,
                  child: Text(l10n.privilegesDeleteColumn),
                ),
              ),
            ],
            rows: [
              for (final obj in SystemObject.values)
                _buildRow(obj, byObject[obj]),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(SystemObject obj, Privilege? privilege) {
    final raw = privilege?.rawValue ?? 0;

    return DataRow(
      cells: [
        DataCell(Text(obj.name)),
        for (final right in [
          AccessRight.create,
          AccessRight.read,
          AccessRight.update,
          AccessRight.delete,
        ])
          DataCell(
            Checkbox(
              key: Key('privilege_${obj.name}_${right.name}'),
              value: raw & right.value != 0,
              onChanged: onChanged == null
                  ? null
                  : (checked) {
                      final newRaw =
                          checked! ? raw | right.value : raw & ~right.value;
                      onChanged!(obj, newRaw & 0xF);
                    },
            ),
          ),
      ],
    );
  }
}
