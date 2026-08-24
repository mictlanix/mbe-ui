import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';

part 'sale_editor.g.dart';

/// The seam that lets a second screen reuse the point-of-sale capture
/// widgets without sharing the register's sale (spec 029 FR-029, FR-030;
/// research §R1). `CustomerBar`, `ProductLookupController` and
/// `SaleLineEditing` — the three shared files — read this instead of
/// `PosSaleController` directly, so a caller can override [saleEditorProvider]
/// with a different notifier and those widgets follow without knowing it.
///
/// The method set is the union both [PosSaleController] and the back-office
/// order controller implement — every mutation `SalesOrderRepository`
/// exposes except the ones that are impossible to be a "first action"
/// ([updateLine], [removeLine], [confirm] already assert an open sale) and
/// the ones each controller keeps for itself ([PosSaleController.startNew],
/// the order controller's own `load`/family key) because no shared widget
/// calls them.
abstract interface class SaleEditor {
  Future<Sale> ensureOpen();

  Future<void> updateHeader({
    int? customer,
    PaymentTerms? paymentTerms,
    Currency? currency,
    int? shipTo,
    int? contact,
    String? customerName,
    FulfillmentMode? fulfillmentIntent,
    DateTime? promiseDate,
    int? salesperson,
    Priority? priority,
    String? comment,
    String? recipient,
  });

  Future<void> addLine({
    required int product,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  });

  Future<void> updateLine({
    required int lineId,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  });

  Future<void> removeLine(int lineId);

  Future<void> confirm();
}

/// The sale a shared capture widget edits. Defaults to the register's own
/// controller, so point-of-sale behaviour is unchanged unless a caller
/// overrides this provider — which the back-office order screen does, inside
/// its own nested `ProviderScope` (contracts/sales-orders-screen.md §2.1).
@riverpod
SaleEditor saleEditor(Ref ref) => ref.watch(posSaleControllerProvider.notifier);

/// The [pendingWritesProvider]/[unconfirmedEditsProvider] scope a shared
/// capture widget registers its writes and unconfirmed edits against.
/// Defaults to [posWritesScope]; the back-office order screen overrides this
/// **alongside** [saleEditorProvider] so its own confirm gate is never held
/// open — or shut — by the register's edits, and vice versa (FR-038).
/// Omitting this override while overriding only [saleEditorProvider] would
/// silently couple the two screens' write gates — the mistake this provider
/// exists to make impossible to forget.
@riverpod
String saleWritesScope(Ref ref) => posWritesScope;
