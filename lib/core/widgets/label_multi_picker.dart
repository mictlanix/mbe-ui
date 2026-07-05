import 'package:flutter/material.dart';

import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';

/// A multi-select label picker rendered as [FilterChip] widgets in a [Wrap]
/// (data-model.md "LabelMultiPicker"). When [enabled] is false the chips are
/// non-interactive (read-only display for users without edit privilege).
/// Renders nothing when [labels] is empty.
class LabelMultiPicker extends StatelessWidget {
  const LabelMultiPicker({
    super.key,
    required this.labels,
    required this.selectedIds,
    required this.onChanged,
    this.enabled = true,
  });

  final List<LabelItem> labels;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: labels.map((label) {
        final selected = selectedIds.contains(label.labelId);
        return FilterChip(
          label: Text(label.name),
          selected: selected,
          onSelected: enabled
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
      }).toList(),
    );
  }
}
