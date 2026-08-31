import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form.dart'
    show localizeCustomerFieldError, localizeCustomerFormError;
import 'package:mbe_ui/features/catalog/presentation/customer_form_controller.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Creates a customer without leaving the sale (FR-013), returning the new
/// customer's id — or `null` if the cashier backed out.
///
/// A dialog on anything but a phone, a full-screen route below the compact
/// breakpoint: a nine-field form does not fit in a phone-width dialog, and the
/// point of the whole thing is that the sale underneath is never discarded.
///
/// Reuses the Customers catalog's `CustomerFormController` rather than
/// restating its validation and permission checks. That controller is shared,
/// so it is cleared here — whatever the Customers screen last left it holding
/// is not this cashier's new customer.
Future<int?> showCustomerInlineCreate(BuildContext context, WidgetRef ref) {
  ref.invalidate(customerFormControllerProvider);
  if (LayoutBreakpoints.isCompact(context)) {
    return Navigator.of(context).push<int>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _CustomerInlineCreateScreen(),
      ),
    );
  }
  return showDialog<int>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: const _CustomerInlineCreateScreen(),
      ),
    ),
  );
}

class _CustomerInlineCreateScreen extends StatelessWidget {
  const _CustomerInlineCreateScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newCustomerTitle),
        leading: IconButton(
          key: const Key('pos_new_customer_close'),
          icon: const Icon(Icons.close),
          tooltip: l10n.cancelButton,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _CustomerInlineCreateForm(),
      ),
    );
  }
}

/// Every field FR-013 asks for, tax registration included since mbe-api#150
/// exposed the customer/taxpayer-recipient link.
class _CustomerInlineCreateForm extends ConsumerStatefulWidget {
  const _CustomerInlineCreateForm();

  @override
  ConsumerState<_CustomerInlineCreateForm> createState() =>
      _CustomerInlineCreateFormState();
}

class _CustomerInlineCreateFormState
    extends ConsumerState<_CustomerInlineCreateForm> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final form = ref.watch(customerFormControllerProvider);
    final controller = ref.read(customerFormControllerProvider.notifier);
    final priceListRepo = ref.read(priceListRepositoryProvider);
    final taxpayerRepo = ref.read(taxpayerRecipientRepositoryProvider);
    final enabled = !form.submitting;

    ref.listen(customerFormControllerProvider, (previous, next) {
      final created = next.customerId;
      if (next.saved && created != null) Navigator.of(context).pop(created);
    });

    return ResponsiveFormGrid(
      maxColumns: 2,
      children: [
        if (form.error != null)
          FormGridChild(
            span: FormGridSpan.full,
            ErrorBanner(
              error: AppError.validation([
                FieldError(
                  loc: const [],
                  msg: localizeCustomerFormError(l10n, form.error!),
                  type: 'error',
                ),
                if (form.errorDetail != null)
                  FieldError(
                    loc: const [],
                    msg: form.errorDetail!,
                    type: 'error',
                  ),
              ]),
            ),
          ),
        FormGridChild(
          TextFormField(
            key: const Key('pos_new_customer_code'),
            decoration: InputDecoration(
              labelText: l10n.codeLabel,
              errorText: localizeCustomerFieldError(
                l10n,
                form.fieldErrors['code'],
              ),
            ),
            enabled: enabled,
            onChanged: controller.codeChanged,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('pos_new_customer_name'),
            decoration: InputDecoration(
              labelText: l10n.nameLabel,
              errorText: localizeCustomerFieldError(
                l10n,
                form.fieldErrors['name'],
              ),
            ),
            enabled: enabled,
            onChanged: controller.nameChanged,
          ),
        ),
        FormGridChild(
          CatalogEntityPicker<PriceList>(
            key: const Key('pos_new_customer_price_list'),
            label: l10n.priceListFieldLabel,
            displayStringForOption: (p) => p.name,
            optionsBuilder: (query) async {
              final result = await priceListRepo.list(
                search: query.isEmpty ? null : query,
              );
              return result.items;
            },
            onSelected: (p) =>
                controller.priceListSelected(p.priceListId, p.name),
            initialDisplayText: form.priceListDisplayText,
            errorText: localizeCustomerFieldError(
              l10n,
              form.fieldErrors['priceList'],
            ),
            enabled: enabled,
          ),
        ),
        FormGridChild(
          CatalogEntityPicker<TaxpayerRecipientListItem>(
            key: const Key('pos_new_customer_taxpayer'),
            label: l10n.taxpayerRecipientFieldLabel,
            displayStringForOption: (t) =>
                '${t.taxpayerRecipientId} — ${t.name}',
            optionsBuilder: (query) async {
              final result = await taxpayerRepo.list(
                search: query.isEmpty ? null : query,
              );
              return result.items;
            },
            onSelected: (t) => controller.taxpayerSelected(
              t.taxpayerRecipientId,
              t.name,
            ),
            initialDisplayText: form.taxpayerDisplayText,
            enabled: enabled,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('pos_new_customer_zone'),
            decoration: InputDecoration(labelText: l10n.zoneLabel),
            enabled: enabled,
            onChanged: controller.zoneChanged,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('pos_new_customer_credit_limit'),
            decoration: InputDecoration(
              labelText: l10n.creditLimitLabel,
              errorText: localizeCustomerFieldError(
                l10n,
                form.fieldErrors['creditLimit'] ??
                    form.fieldErrors['credit_limit'],
              ),
            ),
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: controller.creditLimitChanged,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('pos_new_customer_credit_days'),
            decoration: InputDecoration(
              labelText: l10n.creditDaysLabel,
              errorText: localizeCustomerFieldError(
                l10n,
                form.fieldErrors['creditDays'] ??
                    form.fieldErrors['credit_days'],
              ),
            ),
            enabled: enabled,
            keyboardType: TextInputType.number,
            onChanged: controller.creditDaysChanged,
          ),
        ),
        FormGridChild(
          span: FormGridSpan.full,
          SwitchListTile(
            key: const Key('pos_new_customer_shipping'),
            title: Text(l10n.shippingLabel),
            value: form.shipping,
            onChanged: enabled ? controller.shippingChanged : null,
          ),
        ),
        FormGridChild(
          span: FormGridSpan.full,
          SwitchListTile(
            key: const Key('pos_new_customer_shipping_document'),
            title: Text(l10n.shippingRequiredDocumentLabel),
            value: form.shippingRequiredDocument,
            onChanged: enabled
                ? controller.shippingRequiredDocumentChanged
                : null,
          ),
        ),
        FormGridChild(
          span: FormGridSpan.full,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed: enabled ? () => Navigator.of(context).pop() : null,
                child: Text(l10n.cancelButton),
              ),
              FilledButton(
                key: const Key('pos_new_customer_save'),
                onPressed: enabled ? controller.submitCreate : null,
                child: Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
