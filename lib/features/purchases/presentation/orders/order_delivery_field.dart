import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The "Entrega" field of Nueva orden and Editar encabezado (spec 080
/// FR-010, FR-011, research R7): tapping it opens a date picker that starts
/// at today, since the estimated receipt can't be in the past; once there is
/// a date, a ✕ clears it.
class OrderDeliveryField extends ConsumerWidget {
  const OrderDeliveryField({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.clearKey,
  });

  final DateTime? value;
  final bool enabled;
  final ValueChanged<DateTime?> onChanged;

  /// The ✕'s key.
  final Key clearKey;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = value;
    final fiveYears = DateTime(today.year + 5, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      // A date already in the past starts the picker at today instead.
      initialDate: current == null || current.isBefore(today) ? today : current,
      firstDate: today,
      // A date further out than five years stays pickable.
      lastDate: current != null && current.isAfter(fiveYears)
          ? current
          : fiveYears,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.purchaseOrderFieldDelivery,
          enabled: enabled,
          suffixIcon: value == null
              ? const Icon(Icons.calendar_today_outlined)
              : IconButton(
                  key: clearKey,
                  icon: const Icon(Icons.close),
                  tooltip: l10n.purchaseOrderClearDelivery,
                  onPressed: enabled ? () => onChanged(null) : null,
                ),
        ),
        child: Text(fmt.display.date(value)),
      ),
    );
  }
}
