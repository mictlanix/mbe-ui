import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Nueva factura" (spec 066 C6): pick a customer, then one of its RFCs, and
/// start an invoice draft. Answers the new document's id, or `null` when the
/// user backed out. Every refusal (`issuer_has_no_series`,
/// `recipient_not_linked`, `user.no_facility`) stays inline.
Future<int?> showNewInvoiceDialog(BuildContext context) => showDialog<int>(
  context: context,
  builder: (_) => const _NewInvoiceDialog(),
);

class _NewInvoiceDialog extends ConsumerStatefulWidget {
  const _NewInvoiceDialog();

  @override
  ConsumerState<_NewInvoiceDialog> createState() => _NewInvoiceDialogState();
}

class _NewInvoiceDialogState extends ConsumerState<_NewInvoiceDialog> {
  int? _customerId;
  Future<Customer>? _customer;
  String? _rfc;
  bool _busy = false;
  AppError? _refusal;

  void _pick(CustomerListItem item) {
    setState(() {
      _customerId = item.customerId;
      _rfc = null;
      _refusal = null;
      _customer = ref
          .read(customerRepositoryProvider)
          .get(customerId: item.customerId);
    });
  }

  Future<void> _create() async {
    final customerId = _customerId;
    final rfc = _rfc;
    if (_busy || customerId == null || rfc == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final result = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .create(NewInvoice(customerId: customerId, recipientRfc: rfc));
    if (!mounted) return;
    final error = result.error;
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop(result.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ResponsiveDialog(
      key: const Key('new_invoice_dialog'),
      title: l10n.fiscalDocumentNewTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<CustomerListItem>(
            key: const Key('new_invoice_customer'),
            label: l10n.fiscalDocumentNewCustomer,
            enabled: !_busy,
            displayStringForOption: (c) => '${c.code} — ${c.name}',
            optionsBuilder: (search) async {
              final result = await ref
                  .read(customerRepositoryProvider)
                  .list(search: search.isEmpty ? null : search, limit: 10);
              return result.items;
            },
            onSelected: _pick,
          ),
          if (_customer != null)
            FutureBuilder<Customer>(
              key: ValueKey(_customerId),
              future: _customer,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return FiscalDocumentRefusal(
                    error: toAppError(snapshot.error!),
                  );
                }
                final customer = snapshot.data;
                if (customer == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final taxpayers = customer.taxpayers;
                if (taxpayers.isEmpty) {
                  return Text(
                    l10n.fiscalDocumentNewNoTaxpayers,
                    key: const Key('new_invoice_no_taxpayers'),
                  );
                }
                // One RFC needs no choice.
                final selected =
                    _rfc ??
                    (taxpayers.length == 1
                        ? taxpayers.single.taxpayerRecipientId
                        : null);
                if (selected != _rfc) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _rfc = selected);
                  });
                }
                return DropdownButtonFormField<String>(
                  key: const Key('new_invoice_recipient'),
                  initialValue: selected,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.fiscalDocumentNewRecipient,
                  ),
                  items: [
                    for (final t in taxpayers)
                      DropdownMenuItem(
                        value: t.taxpayerRecipientId,
                        child: Text(
                          '${t.taxpayerRecipientId} · ${t.name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _busy ? null : (v) => setState(() => _rfc = v),
                );
              },
            ),
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('new_invoice_submit'),
        label: l10n.fiscalDocumentNewCreate,
        busy: _busy,
        onPressed: _rfc == null ? null : _create,
      ),
    );
  }
}
