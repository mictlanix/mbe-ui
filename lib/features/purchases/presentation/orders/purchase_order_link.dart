import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_screen.dart';

/// A purchase order's number where another screen mentions it (spec 080
/// research R16, FR-030): a compact link that opens the order for a user with
/// PurchasesOrders (SystemObject 20) read, plain text for anyone else.
class PurchaseOrderLink extends ConsumerWidget {
  const PurchaseOrderLink({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canOpen = ref
        .watch(accessControlProvider)
        .can(SystemObject.purchasesOrders, AccessRight.read);
    if (!canOpen) return RecordIdText('$orderId');
    return TextButton(
      key: Key('purchase_order_link_$orderId'),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: AlignmentDirectional.centerStart,
      ),
      onPressed: () => context.push('$purchaseOrdersPath/$orderId'),
      // Inherits the button's link color; only the font becomes mono.
      child: RecordIdText.inherit('$orderId'),
    );
  }
}
