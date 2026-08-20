import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/denominations.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// The closing count's denomination rows (contracts/cash-session-screens.md
/// §2) — one per [kMxnDenominations] entry, descending, each a quantity
/// field with its extended amount. No `TextInputFormatter` — there are zero
/// uses of one anywhere in this codebase; quantity validation happens in
/// [CloseSessionFormController], matching the repo-wide convention of
/// validating in the controller rather than constraining input as it's
/// typed.
class DenominationCountTable extends ConsumerWidget {
  const DenominationCountTable({
    super.key,
    required this.quantities,
    required this.onQuantityChanged,
    this.enabled = true,
  });

  /// Current quantity per denomination string; a missing key reads as 0.
  final Map<String, int> quantities;
  final void Function(String denomination, int quantity) onQuantityChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(formattersProvider);

    return Column(
      children: [
        for (final denomination in kMxnDenominations)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(fmt.display.currency(denomination)),
                ),
                Expanded(
                  child: TextFormField(
                    key: Key('cash_session_denomination_field_$denomination'),
                    initialValue: '${quantities[denomination] ?? 0}',
                    decoration: const InputDecoration(isDense: true),
                    keyboardType: TextInputType.number,
                    enabled: enabled,
                    onChanged: (value) => onQuantityChanged(
                      denomination,
                      int.tryParse(value) ?? 0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    fmt.display.currency(
                      extendedAmount(denomination, quantities[denomination] ?? 0),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
