import 'package:flutter/material.dart';

import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Renders a full-height grid with one row per [SystemObject] and four
/// C/R/U/D checkbox columns (constitution §VI — shared widget). Read-only
/// when [onChanged] is null.
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

    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(),
          1: FixedColumnWidth(48),
          2: FixedColumnWidth(48),
          3: FixedColumnWidth(48),
          4: FixedColumnWidth(48),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            children: [
              _HeaderCell(l10n.privilegesModuleColumn),
              _HeaderCell(l10n.privilegesCreateColumn),
              _HeaderCell(l10n.privilegesReadColumn),
              _HeaderCell(l10n.privilegesUpdateColumn),
              _HeaderCell(l10n.privilegesDeleteColumn),
            ],
          ),
          for (final obj in SystemObject.values)
            _buildRow(context, obj, byObject[obj]),
        ],
      ),
    );
  }

  TableRow _buildRow(
      BuildContext context, SystemObject obj, Privilege? privilege) {
    final raw = privilege?.rawValue ?? 0;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(obj.name),
        ),
        for (final right in [
          AccessRight.create,
          AccessRight.read,
          AccessRight.update,
          AccessRight.delete,
        ])
          _CheckCell(
            key: Key('privilege_${obj.name}_${right.name}'),
            value: raw & right.value != 0,
            onChanged: onChanged == null
                ? null
                : (checked) {
                    final newRaw = checked!
                        ? raw | right.value
                        : raw & ~right.value;
                    onChanged!(obj, newRaw & 0xF);
                  },
          ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Text(label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _CheckCell extends StatelessWidget {
  const _CheckCell({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(value: value, onChanged: onChanged);
  }
}
