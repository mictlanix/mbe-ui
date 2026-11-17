import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_actions.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Agregar desde pedido" (spec 069 FR-012, research R8): pick a completed
/// sales order and add its stockable products to draft [transferId]; the
/// products already on the transfer are left as they are. Answers how many
/// lines were added (0 when they were all there already) for the caller's
/// snackbar, or `null` when the user backed out.
///
/// The search lists completed orders of any customer and facility.
/// `sales_order.not_confirmed` and `resource.not_found` stay inline and keep
/// the dialog open. The detail screen gates the button on InventoryTransfers
/// (17) update and SalesOrders (7) read.
Future<int?> showAddFromSalesOrderDialog(
  BuildContext context, {
  required int transferId,
}) => showResponsiveDialog<int>(
  context,
  builder: (_) => _AddFromSalesOrderDialog(transferId: transferId),
);

class _AddFromSalesOrderDialog extends ConsumerStatefulWidget {
  const _AddFromSalesOrderDialog({required this.transferId});

  final int transferId;

  @override
  ConsumerState<_AddFromSalesOrderDialog> createState() =>
      _AddFromSalesOrderDialogState();
}

class _AddFromSalesOrderDialogState
    extends ConsumerState<_AddFromSalesOrderDialog> {
  OpenSale? _order;
  bool _busy = false;
  AppError? _refusal;

  String _label(OpenSale order) {
    final fmt = ref.read(formattersProvider);
    return AppLocalizations.of(context)!.inventoryTransferFromOrderOption(
      '${order.serial ?? '#${order.id}'}',
      posSaleCustomerLabel(order),
      fmt.display.date(order.date),
    );
  }

  Future<List<OpenSale>> _search(String search) async {
    final text = search.trim();
    final page = await ref
        .read(salesOrderRepositoryProvider)
        .listOrders(
          status: SaleStatus.completed,
          search: text.isEmpty ? null : text,
          limit: 10,
        );
    return page.items;
  }

  Future<void> _add() async {
    final order = _order;
    if (_busy || order == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final (error, added) = await ref
        .read(inventoryTransferActionsProvider.notifier)
        .addSalesOrderItems(widget.transferId, salesOrderId: order.id);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(added);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ResponsiveDialog(
      key: const Key('inventory_transfer_from_order_dialog'),
      title: l10n.inventoryTransferFromOrderTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _order != null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<OpenSale>(
            key: const Key('inventory_transfer_from_order_picker'),
            label: l10n.inventoryTransferFromOrderField,
            enabled: !_busy,
            autofocus: true,
            displayStringForOption: _label,
            optionsBuilder: _search,
            onSelected: (order) => setState(() {
              _order = order;
              _refusal = null;
            }),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('inventory_transfer_from_order_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_transfer_from_order_submit'),
        label: l10n.inventoryTransferFromOrderSubmit,
        busy: _busy,
        onPressed: _order == null || _busy ? null : _add,
      ),
    );
  }
}
