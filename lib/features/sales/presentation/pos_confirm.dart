import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';

/// Confirms [sale] exactly once, immediately before the first action that
/// actually needs `completed` status — never merely by reaching a later step
/// (spec 036 FR-008; for the back-office order, spec 039 A2/FR-032: the first
/// destination create is what commits it, since the server refuses to record
/// a delivery against an order that is not yet completed). A no-op once the
/// sale is no longer `draft`, which is what makes this safe to call from
/// every trigger point without each one separately tracking whether
/// confirmation already succeeded.
///
/// Confirms through [saleEditorProvider] rather than the register's own
/// controller, so this commits whichever document the calling host is
/// editing — the cashier's sale by default, the back-office order when a
/// nested `ProviderScope` overrides the seam (contracts/shared-step-seam.md
/// §4). On failure, reports it through [saleConfirmFailureProvider], which
/// each host answers with its own "record the error, return to the step that
/// can act on it" behaviour, then rethrows so the caller (a payment
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
    await read(saleEditorProvider).confirm();
  } on AppError catch (e) {
    read(saleConfirmFailureProvider)(e);
    rethrow;
  }
}
