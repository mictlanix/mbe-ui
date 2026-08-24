import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_address_picker.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_contact_picker.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/pos_sale_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The order screen's own header fields (spec 029 FR-016, FR-017,
/// contracts/sales-orders-screen.md §2.2) — everything the point-of-sale
/// capture step does not already show via `CustomerBar`. Laid out in a
/// [ResponsiveFormGrid], two columns wide on anything but the compact tier,
/// matching legacy "Pedidos"' own left/right split.
///
/// Every editable field writes through a single [updateHeader] call the
/// instant it changes — there is no batching Save button here, the same
/// "live surface" rule the register's own header controls follow.
///
/// [canEdit] is `can(salesOrders, update) && sale.isEditable` — every field
/// but priority is absent that control's editable face without it
/// (constitution §IV, FR-003; contracts/routes.md §5's "Header field edit"
/// row). [canEditPriority] is `can(salesOrders, update)` alone: priority is
/// the one field that survives completion (FR-027).
class OrderHeaderPanel extends ConsumerStatefulWidget {
  const OrderHeaderPanel({
    super.key,
    required this.sale,
    required this.canEdit,
    required this.canEditPriority,
    required this.onStale,
  });

  final Sale sale;
  final bool canEdit;
  final bool canEditPriority;

  /// US2 scenario 5: called when a header edit is refused because the
  /// order is no longer a draft — re-reads the order's real state so this
  /// panel stops offering edits the server will keep refusing.
  final VoidCallback onStale;

  @override
  ConsumerState<OrderHeaderPanel> createState() => _OrderHeaderPanelState();
}

class _OrderHeaderPanelState extends ConsumerState<OrderHeaderPanel> {
  AppError? _error;

  late final _commentController = ConfirmableFieldController(
    value: widget.sale.comment ?? '',
    parse: (text) => text,
    commit: _commitComment,
    unconfirmedEdits: ref.read(unconfirmedEditsProvider(salesOrderWritesScope).notifier),
  );

  @override
  void didUpdateWidget(OrderHeaderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sale.comment != widget.sale.comment) {
      _commentController.sync(value: widget.sale.comment ?? '');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<bool> _commitComment(String value) async {
    try {
      await ref
          .read(saleEditorProvider)
          .updateHeader(comment: value.isEmpty ? null : value);
      return true;
    } on Object {
      widget.onStale();
      return false;
    }
  }

  Future<void> _update({
    DateTime? promiseDate,
    Currency? currency,
    Priority? priority,
    int? salesperson,
    int? contact,
    int? shipTo,
    String? recipient,
  }) async {
    setState(() => _error = null);
    try {
      await ref
          .read(saleEditorProvider)
          .updateHeader(
            promiseDate: promiseDate,
            currency: currency,
            priority: priority,
            salesperson: salesperson,
            contact: contact,
            shipTo: shipTo,
            recipient: recipient,
          );
    } on AppError catch (e) {
      if (mounted) setState(() => _error = e);
      widget.onStale();
    }
  }

  Future<void> _pickPromiseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.sale.promiseDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) await _update(promiseDate: picked);
  }

  Future<void> _pickContact() async {
    final id = await showCustomerContactPicker(
      context,
      customerId: widget.sale.customer,
    );
    if (id != null && mounted) await _update(contact: id);
  }

  Future<void> _pickShipTo() async {
    final id = await showCustomerAddressPicker(
      context,
      customerId: widget.sale.customer,
    );
    if (id != null && mounted) await _update(shipTo: id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final sale = widget.sale;
    final canEdit = widget.canEdit;
    final customer = ref
        .watch(saleCustomerControllerProvider(sale.customer))
        .valueOrNull;
    final contactLabel = customer?.contacts
        .where((c) => c.contactId == sale.contact)
        .firstOrNull
        ?.name;
    final shipToLabel = customer?.addresses
        .where((a) => a.addressId == sale.shipTo)
        .firstOrNull
        ?.label;

    return ResponsiveFormGrid(
      children: [
        FormGridChild(_readOnly(l10n.salesOrderReferenceLabel, '${sale.serial ?? sale.id}')),
        FormGridChild(_readOnly(l10n.salesOrderStatusLabel, posSaleStatusLabel(l10n, sale.status))),
        FormGridChild(_readOnly(l10n.salesOrderDateLabel, fmt.display.dateTime(sale.date))),
        FormGridChild(_readOnly(l10n.salesOrderDueDateLabel, fmt.display.dateTime(sale.dueDate))),
        FormGridChild(
          _readOnly(l10n.salesOrderExchangeRateLabel, sale.exchangeRate),
        ),
        FormGridChild(
          _readOnly(
            l10n.salesOrderPaymentTermsLabel,
            sale.paymentTerms == PaymentTerms.netD
                ? l10n.posPaymentTermsCredit
                : l10n.posPaymentTermsImmediate,
          ),
        ),
        // US4 scenario 3: outstanding balance visible without leaving the
        // screen — paid state itself already reads off the Status field
        // above (a paid order's own `SaleStatus.paid`).
        FormGridChild(
          _readOnly(l10n.salesOrdersColumnBalance, fmt.display.currency(sale.balance)),
        ),
        FormGridChild(
          InkWell(
            onTap: canEdit ? _pickPromiseDate : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.salesOrderPromiseDateLabel,
                enabled: canEdit,
              ),
              child: Text(fmt.display.dateTime(sale.promiseDate)),
            ),
          ),
        ),
        FormGridChild(
          DropdownButtonFormField<Currency>(
            key: const Key('sales_order_currency_field'),
            initialValue: sale.currency,
            // The Spanish label "MXN — Peso Mexicano" is wider than a
            // three-column grid cell at common desktop widths (~1400px);
            // without this the row overflows instead of ellipsizing.
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.salesOrderCurrencyLabel),
            items: [
              for (final currency in Currency.values)
                DropdownMenuItem(value: currency, child: Text(_currencyLabel(l10n, currency))),
            ],
            onChanged: !canEdit
                ? null
                : (currency) {
                    if (currency != null) _update(currency: currency);
                  },
          ),
        ),
        FormGridChild(
          DropdownButtonFormField<Priority>(
            key: const Key('sales_order_priority_field'),
            initialValue: sale.priority,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.salesOrderPriorityLabel),
            items: [
              for (final priority in Priority.values)
                DropdownMenuItem(value: priority, child: Text(_priorityLabel(l10n, priority))),
            ],
            onChanged: !widget.canEditPriority
                ? null
                : (priority) {
                    if (priority != null) _update(priority: priority);
                  },
          ),
        ),
        FormGridChild(
          CatalogEntityPicker<EmployeeListItem>(
            key: const Key('sales_order_salesperson_field'),
            label: l10n.salesOrderSalespersonLabel,
            displayStringForOption: (e) => e.fullName,
            optionsBuilder: (query) async {
              final result = await ref
                  .read(employeeRepositoryProvider)
                  .list(search: query.isEmpty ? null : query, salesPerson: true);
              return result.items;
            },
            onSelected: (e) => _update(salesperson: e.employeeId),
            enabled: canEdit,
          ),
        ),
        FormGridChild(
          _PickerField(
            label: l10n.salesOrderContactLabel,
            value: contactLabel,
            enabled: canEdit,
            onTap: _pickContact,
          ),
        ),
        FormGridChild(
          _PickerField(
            label: l10n.salesOrderShipToLabel,
            value: shipToLabel,
            enabled: canEdit,
            onTap: _pickShipTo,
          ),
        ),
        FormGridChild(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatalogEntityPicker<TaxpayerRecipientListItem>(
                key: const Key('sales_order_recipient_field'),
                label: l10n.salesOrderRecipientLabel,
                displayStringForOption: (r) => r.taxpayerRecipientId,
                optionsBuilder: (query) async {
                  final result = await ref
                      .read(taxpayerRecipientRepositoryProvider)
                      .list(search: query.isEmpty ? null : query);
                  return result.items;
                },
                onSelected: (r) => _update(recipient: r.taxpayerRecipientId),
                initialDisplayText: sale.recipient,
                enabled: canEdit,
              ),
              if (sale.recipientName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    sale.recipientName!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        FormGridChild(
          ConfirmableTextField(
            controller: _commentController,
            enabled: canEdit,
            fieldKey: const Key('sales_order_comment_field'),
            decoration: InputDecoration(labelText: l10n.salesOrderCommentLabel),
          ),
          span: FormGridSpan.full,
        ),
        if (_error != null)
          FormGridChild(
            ErrorBanner(
              error: _error!,
              onDismiss: () => setState(() => _error = null),
            ),
            span: FormGridSpan.full,
          ),
      ],
    );
  }

  Widget _readOnly(String label, String value) =>
      InputDecorator(decoration: InputDecoration(labelText: label), child: Text(value));
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String? value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, enabled: enabled),
        child: Text(value ?? ''),
      ),
    );
  }
}

String _currencyLabel(AppLocalizations l10n, Currency currency) => switch (currency) {
  Currency.mxn => l10n.currencyMxnLabel,
  Currency.usd => l10n.currencyUsdLabel,
  Currency.eur => l10n.currencyEurLabel,
};

String _priorityLabel(AppLocalizations l10n, Priority priority) => switch (priority) {
  Priority.low => l10n.salesOrderPriorityLow,
  Priority.normal => l10n.salesOrderPriorityNormal,
  Priority.high => l10n.salesOrderPriorityHigh,
  Priority.critical => l10n.salesOrderPriorityCritical,
};

