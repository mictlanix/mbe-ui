import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';

/// The commission labels, by name, in a dropdown: the "Etiqueta" control of
/// the assign dialogs and of the product labels filter. [value] `null` shows
/// [label] as the empty state; [onChanged] gets the chosen label's id (and
/// `null` when [allowClear] is on and the empty entry is chosen).
class CommissionLabelDropdown extends ConsumerWidget {
  const CommissionLabelDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.allowClear = false,
  });

  final String label;
  final int? value;
  final ValueChanged<int?>? onChanged;
  final bool enabled;

  /// Adds an empty entry that answers `null`, for a filter.
  final bool allowClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = [...?ref.watch(commissionLabelsProvider).value]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return DropdownButtonFormField<int>(
      // The value is only known to the dropdown after the labels arrive.
      key: ValueKey((value, labels.length)),
      initialValue: labels.any((l) => l.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        if (allowClear)
          const DropdownMenuItem<int>(value: null, child: Text('')),
        for (final l in labels)
          DropdownMenuItem(
            value: l.id,
            child: Text(l.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
