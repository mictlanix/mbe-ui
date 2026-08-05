import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/denominations.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// The closing count's denomination rows (contracts/cash-session-screens.md
/// §2) — one per [kMxnDenominations] entry, descending, each a quantity
/// field with its extended amount. No `TextInputFormatter` — there are zero
/// uses of one anywhere in this codebase; quantity validation happens in
/// [CloseSessionFormController], matching the repo-wide convention of
/// validating in the controller rather than constraining input as it's
/// typed.
class DenominationCountTable extends StatelessWidget {
  const DenominationCountTable({
    super.key,
    required this.quantities,
    required this.onQuantityChanged,
    this.enabled = true,
    this.locale,
  });

  /// Current quantity per denomination string; a missing key reads as 0.
  final Map<String, int> quantities;
  final void Function(String denomination, int quantity) onQuantityChanged;
  final bool enabled;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    final locale = this.locale ?? Localizations.localeOf(context).toString();

    return Column(
      children: [
        for (final denomination in kMxnDenominations)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(MoneyFormatters.currency(denomination, locale: locale)),
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
                    MoneyFormatters.currency(
                      extendedAmount(denomination, quantities[denomination] ?? 0),
                      locale: locale,
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
