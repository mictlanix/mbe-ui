import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/customer_bar.dart';
import 'package:mbe_ui/features/sales/presentation/capture/default_warehouse_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_header_panel.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';
import 'package:mbe_ui/features/sales/presentation/unconfirmed_edits_resolver.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// `/sales/orders/new` and `/sales/orders/:orderId` — the back-office order
/// screen (spec 029, contracts/sales-orders-screen.md §2). Reuses the
/// point-of-sale capture surface (`CustomerBar`, `ProductSearchField`, the
/// line rows/cards, `SaleTotalsBar` — FR-029) through a nested
/// [ProviderScope] that overrides **both** [saleEditorProvider] (with
/// [orderEditorControllerProvider]) and [saleWritesScopeProvider] (with
/// [salesOrderWritesScope]) — omitting the second would silently couple this
/// screen's write gate to the register's (FR-038).
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key, this.orderId});

  /// `null` for a brand-new order — nothing is written until the first
  /// action needs one (FR-015, SC-005).
  final int? orderId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        saleEditorProvider.overrideWith(
          (ref) => ref.watch(orderEditorControllerProvider(orderId).notifier),
        ),
        saleWritesScopeProvider.overrideWithValue(salesOrderWritesScope),
      ],
      child: _OrderScreenBody(orderId: orderId),
    );
  }
}

class _OrderScreenBody extends ConsumerStatefulWidget {
  const _OrderScreenBody({required this.orderId});

  final int? orderId;

  @override
  ConsumerState<_OrderScreenBody> createState() => _OrderScreenBodyState();
}

class _OrderScreenBodyState extends ConsumerState<_OrderScreenBody> {
  AppError? _confirmError;
  bool _confirming = false;
  bool _cancelling = false;

  Future<void> _addLine(ProductLookupResult result, int? defaultWarehouse) async {
    ref.read(productStockCacheProvider.notifier).update(
      (cache) => {...cache, result.product: result.stock},
    );
    ref.read(productTaxRateCacheProvider.notifier).update(
      (cache) => {...cache, result.product: result.taxRate},
    );
    await ref
        .read(saleEditorProvider)
        .addLine(
          product: result.product,
          quantity: _initialQuantity(result),
          warehouse: defaultWarehouse,
        );
    // Once the first action opened the order, the address reflects its real
    // id rather than staying on `/new` (mirroring the register's own
    // `/sales/pos/new` → `/sales/pos/<id>` rewrite, spec 023 research R1).
    final opened = ref.read(orderEditorControllerProvider(widget.orderId)).valueOrNull;
    if (widget.orderId == null && opened != null && mounted) {
      context.go('/sales/orders/${opened.id}');
    }
  }

  String _initialQuantity(ProductLookupResult result) =>
      result.minOrderQty > 0 ? '${result.minOrderQty}' : '1';

  Future<void> _confirm() async {
    setState(() {
      _confirming = true;
      _confirmError = null;
    });
    try {
      await ref.read(saleEditorProvider).confirm();
    } on AppError catch (e) {
      setState(() => _confirmError = e);
      // US2 scenario 5: the refusal may mean the order changed underneath
      // (already confirmed/cancelled elsewhere) — re-read its real state.
      await ref
          .read(orderEditorControllerProvider(widget.orderId).notifier)
          .refresh();
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  /// The confirm gate (FR-035, FR-036): additional to `lineCount > 0`, no
  /// write may be outstanding — including a stepped quantity still inside
  /// its coalescing window — and any unconfirmed typed text is resolved
  /// (keep / discard / keep editing) before confirming, never after.
  Future<void> _onConfirmPressed() async {
    final proceed = await resolveUnconfirmedEdits(
      context,
      ref,
      salesOrderWritesScope,
    );
    if (proceed && mounted) await _confirm();
  }

  Future<void> _cancel(int orderId) async {
    setState(() => _cancelling = true);
    try {
      await ref.read(orderEditorControllerProvider(widget.orderId).notifier).cancel();
    } on AppError catch (e) {
      if (mounted) setState(() => _confirmError = e);
      await ref
          .read(orderEditorControllerProvider(widget.orderId).notifier)
          .refresh();
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _confirmCancel(AppLocalizations l10n, int orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.salesOrderCancelDialogTitle),
        content: Text(l10n.salesOrderCancelDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.salesOrderCancelDialogKeepEditing),
          ),
          FilledButton(
            key: const Key('sales_order_cancel_confirm_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.salesOrderCancelDialogConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _cancel(orderId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderAsync = ref.watch(orderEditorControllerProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.salesOrdersScreenTitle)),
      body: orderAsync.when(
        data: (sale) => _body(context, l10n, sale),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorBanner(
              error: toAppError(error),
              onDismiss: () => ref.invalidate(
                orderEditorControllerProvider(widget.orderId),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// spec 036 FR-001/FR-003: no product line may be added, and confirming is
  /// blocked, until a specific (non-generic) customer is attached — true for
  /// a brand-new order and for one still sitting on the generic default.
  bool _needsCustomer(Sale? sale) =>
      sale == null ||
      ref.read(appSettingsProvider).isGenericCustomer(sale.customer);

  Widget _body(BuildContext context, AppLocalizations l10n, Sale? sale) {
    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(SystemObject.salesOrders, AccessRight.update);
    final editable = sale?.isEditable ?? true;
    final canEditFields = canUpdate && editable;
    final needsCustomer = _needsCustomer(sale);
    final compact = LayoutBreakpoints.isCompact(context);
    final spacing = Theme.of(context).spacing;
    final pointSale = sale?.pointSale ?? ref.watch(registerPointSaleProvider);
    final defaultWarehouse = pointSale == null
        ? const AsyncValue<int>.loading()
        : ref.watch(defaultWarehouseControllerProvider(pointSale));
    // FR-035: additional to lineCount > 0 — a write still outstanding must
    // not let the user confirm on figures the order does not yet hold.
    final writesPending =
        ref.watch(pendingWritesProvider(salesOrderWritesScope)) > 0;
    final horizontalInset = EdgeInsets.symmetric(horizontal: spacing.screenMargin);

    final header = <Widget>[
      if (_confirmError != null)
        Padding(
          padding: horizontalInset.add(EdgeInsets.only(top: spacing.xs)),
          child: ErrorBanner(
            error: _confirmError!,
            onDismiss: () => setState(() => _confirmError = null),
          ),
        ),
      if (sale != null)
        Padding(
          padding: horizontalInset.add(EdgeInsets.only(top: spacing.xs)),
          child: OrderHeaderPanel(
            sale: sale,
            canEdit: canEditFields,
            canEditPriority: canUpdate,
            // US2 scenario 5: a refusal because the order is no longer a
            // draft (confirmed or cancelled from elsewhere) re-reads the
            // real state rather than leaving stale controls on screen.
            onStale: () => ref
                .read(orderEditorControllerProvider(widget.orderId).notifier)
                .refresh(),
          ),
        ),
      Padding(
        padding: horizontalInset.add(EdgeInsets.only(top: spacing.sm)),
        child: CustomerBar(
          sale: sale,
          enabled: canEditFields,
          excludeGenericCustomer: true,
        ),
      ),
      // spec 036 FR-001/FR-003: no product line until a specific customer is
      // attached — the field is absent, not merely disabled, matching this
      // screen's existing "not applicable yet" convention (`showAction`
      // above).
      if (needsCustomer)
        Padding(
          padding: horizontalInset.add(EdgeInsets.symmetric(vertical: spacing.sm)),
          child: Text(
            l10n.salesOrderChooseCustomerFirst,
            key: const Key('sales_order_choose_customer_hint'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )
      else
        Padding(
          key: const Key('sales_order_product_search_field'),
          padding: horizontalInset.add(EdgeInsets.symmetric(vertical: spacing.sm)),
          child: ProductSearchField(
            enabled: canEditFields,
            warehouse: defaultWarehouse.value,
            onProductSelected: (result) => _addLine(result, defaultWarehouse.value),
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact)
          Expanded(
            child: ListView(
              children: [
                ...header,
                if (sale == null || sale.lines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(l10n.salesOrderNoLinesYet)),
                  )
                else
                  ..._lines(sale, canEditFields, compact: true, inset: horizontalInset),
              ],
            ),
          )
        else ...[
          ...header,
          Expanded(
            child: sale == null || sale.lines.isEmpty
                ? Center(child: Text(l10n.salesOrderNoLinesYet))
                : ListView(
                    padding: horizontalInset,
                    children: _lines(sale, canEditFields, compact: false),
                  ),
          ),
        ],
        SaleTotalsBar(
          sale: sale,
          compact: compact,
          confirming: _confirming,
          actionLabel: l10n.salesOrderConfirmAction,
          actionKey: const Key('sales_order_confirm_button'),
          // FR-027: absent, not merely disabled, once the order can no
          // longer be confirmed at all.
          showAction: editable,
          onContinue:
              (canUpdate &&
                  editable &&
                  !needsCustomer &&
                  (sale?.lineCount ?? 0) > 0 &&
                  !_confirming &&
                  !writesPending)
              ? _onConfirmPressed
              : null,
          // Spec 032 FR-013/FR-014: cancel rides in the totals bar beside
          // confirm rather than in a band of its own beneath it. Absent —
          // never disabled — without update rights or on an order that is no
          // longer editable (FR-016, 029 FR-026).
          secondaryAction: sale != null && canUpdate && editable
              ? _cancelAction(l10n, sale.id)
              : null,
        ),
      ],
    );
  }

  /// The destructive twin of the primary action: low emphasis, error role,
  /// same confirmation dialog and same widget key as the band it replaces
  /// (FR-015, FR-017, FR-018).
  Widget _cancelAction(AppLocalizations l10n, int orderId) => TextButton(
    key: const Key('sales_order_cancel_button'),
    style: TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.error,
    ),
    onPressed: _cancelling ? null : () => _confirmCancel(l10n, orderId),
    child: _cancelling
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(l10n.salesOrderCancelAction),
  );

  List<Widget> _lines(
    Sale sale,
    bool enabled, {
    required bool compact,
    EdgeInsets inset = EdgeInsets.zero,
  }) => [
    for (final line in sale.lines)
      if (compact)
        Padding(
          padding: inset,
          child: SaleLineCard(
            key: ValueKey(line.id),
            line: line,
            facilityId: sale.facility,
            enabled: enabled,
            showComment: true,
          ),
        )
      else
        SaleLineRow(
          key: ValueKey(line.id),
          line: line,
          facilityId: sale.facility,
          enabled: enabled,
          showComment: true,
        ),
  ];
}
