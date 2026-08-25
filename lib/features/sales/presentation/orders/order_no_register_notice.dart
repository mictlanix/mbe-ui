import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The FR-014 blocked state: a user with no point of sale configured can
/// still list, search and read every order — only creating a new one is
/// impossible, because `POST /sales-orders` needs a register and mbe-api
/// takes it from the caller's own configuration
/// (contracts/mbe-api-sales-orders.md §2). This widget replaces the "New
/// order" toolbar action in that case, naming the missing setting and who
/// can supply it — told **before** the salesperson starts typing an order,
/// never as a 422 afterwards.
///
/// Renders nothing when a register *is* configured, so a caller can place
/// this unconditionally where the create action would go.
class OrderNoRegisterNotice extends ConsumerWidget {
  const OrderNoRegisterNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointSale = ref.watch(registerPointSaleProvider);
    if (pointSale != null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: l10n.salesOrderNoRegisterMessage,
      child: Chip(
        key: const Key('sales_order_no_register_notice'),
        avatar: const Icon(Icons.info_outline, size: 18),
        label: Text(l10n.salesOrderNoRegisterTitle),
      ),
    );
  }
}
