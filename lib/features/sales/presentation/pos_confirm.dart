import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';

/// spec 036 FR-008/research R1: surfaces a `confirm()` failure that happens
/// away from the Venta step (payment, delivery, or leaving Cobro on credit
/// terms) so [CaptureStep] can render it through its own existing banner
/// once the step machine has returned there. POS-only — the back-office
/// order screen still confirms from its own screen directly and renders its
/// own banner locally, unaffected by this.
final confirmErrorProvider = StateProvider<AppError?>((ref) => null);

/// Confirms [sale] exactly once, immediately before the first POS action
/// that actually needs `completed` status — never merely by reaching Cobro
/// or Entrega (spec 036 FR-008). A no-op once the sale is no longer `draft`,
/// which is what makes this safe to call from every trigger point without
/// each one separately tracking whether confirmation already succeeded.
///
/// On failure, records the error on [confirmErrorProvider] and jumps the
/// step machine back to Venta, then rethrows so the caller (a payment
/// submission or a delivery-destination create) aborts its own action rather
/// than proceeding as if the sale were confirmed.
///
/// Takes a bare `read` function rather than a `Ref`/`WidgetRef` — the three
/// callers span both a notifier's own `Ref` (`payment_controller.dart`,
/// `delivery_controller.dart`) and a widget's `WidgetRef`
/// (`payment_summary_panel.dart`), which share an identical `read<T>`
/// signature but no common supertype to accept instead.
Future<void> confirmBeforePayableAction(
  T Function<T>(ProviderListenable<T> provider) read,
  Sale sale,
) async {
  if (sale.status != SaleStatus.draft) return;
  try {
    await read(posSaleControllerProvider.notifier).confirm();
  } on AppError catch (e) {
    read(confirmErrorProvider.notifier).state = e;
    read(posStepControllerProvider.notifier).jumpTo(PosStep.venta);
    rethrow;
  }
}
