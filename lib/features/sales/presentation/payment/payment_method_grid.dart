import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/presentation/payment/facility_payment_options_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Method selection, built from the facility's own configured
/// `PaymentMethodOption`s — each tile reads `requiresReference` directly off
/// the option, since mbe-api computes it from the SAT code (research.md §6,
/// resolved). There is no client-side reference table.
///
/// A facility with no options configured falls back to the shared
/// [PaymentMethod] enum's common tenders, so a cashier is never stuck unable
/// to take money because a catalog is empty; those fall-back tiles carry no
/// `paymentCharge` and never require a reference, which is the safe default
/// (`PaymentMethodOption.requiresReference`'s own documented posture).
class PaymentMethodGrid extends ConsumerWidget {
  const PaymentMethodGrid({
    super.key,
    required this.facilityId,
    this.enabled = true,
  });

  final int facilityId;
  final bool enabled;

  static const _fallbackMethods = [
    PaymentMethod.cash,
    PaymentMethod.creditCard,
    PaymentMethod.debitCard,
    PaymentMethod.eft,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final options = ref.watch(facilityPaymentOptionsControllerProvider(facilityId));
    final draft = ref.watch(paymentControllerProvider);
    final notifier = ref.read(paymentControllerProvider.notifier);

    return options.when(
      data: (list) {
        if (list.isEmpty) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final method in _fallbackMethods)
                ChoiceChip(
                  key: Key('payment_method_${method.code}'),
                  label: Text(paymentMethodLabel(l10n, method.code)),
                  selected: draft.methodCode == method.code &&
                      draft.paymentCharge == null,
                  onSelected: enabled
                      ? (_) => notifier.selectMethod(methodCode: method.code)
                      : null,
                ),
            ],
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in list)
              ChoiceChip(
                key: Key('payment_option_${option.paymentMethodOptionId}'),
                label: Text(option.name),
                selected: draft.paymentCharge == option.paymentMethodOptionId,
                onSelected: enabled
                    ? (_) => notifier.selectMethod(
                        methodCode: option.paymentMethod,
                        paymentCharge: option.paymentMethodOptionId,
                        requiresReference: option.requiresReference,
                      )
                    : null,
              ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
