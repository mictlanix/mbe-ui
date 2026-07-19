import 'package:flutter/material.dart';

import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A multi-select label picker rendered as [FilterChip] widgets in a [Wrap]
/// (data-model.md "LabelMultiPicker"). When [enabled] is false the chips are
/// non-interactive (read-only display for users without edit privilege).
/// Renders nothing when [labels] is empty.
///
/// [labelCounts] (spec 009 contracts/ui-contracts.md) optionally narrows
/// which chips are selectable and shows each one's matching-product count:
/// a chip is interactive only if it is already selected (so it can always be
/// deselected) or its id is a key in [labelCounts], and its text becomes
/// "Name (count)" whenever a count is known for it. `null` means availability
/// is unknown (loading/error/not applicable) and every chip stays interactive
/// with no count shown — callers that omit it (e.g. the product form) keep
/// today's all-enabled, count-less behavior; the products-list filter drawer
/// passes the current facet lookup result.
class LabelMultiPicker extends StatelessWidget {
  const LabelMultiPicker({
    super.key,
    required this.labels,
    required this.selectedIds,
    required this.onChanged,
    this.enabled = true,
    this.labelCounts,
  });

  final List<LabelItem> labels;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;
  final bool enabled;
  final Map<int, int>? labelCounts;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: labels.map((label) {
        final selected = selectedIds.contains(label.labelId);
        final count = labelCounts?[label.labelId];
        final available = labelCounts == null || count != null;
        final interactive = enabled && (selected || available);
        final chip = FilterChip(
          label: Text(
            count == null ? label.name : l10n.labelWithCount(label.name, count),
          ),
          selected: selected,
          onSelected: interactive
              ? (_) {
                  final updated = List<int>.from(selectedIds);
                  if (selected) {
                    updated.remove(label.labelId);
                  } else {
                    updated.add(label.labelId);
                  }
                  onChanged(updated);
                }
              : null,
        );
        if (interactive || selected) return chip;
        return Tooltip(message: l10n.labelUnavailableTooltip, child: chip);
      }).toList(),
    );
  }
}
