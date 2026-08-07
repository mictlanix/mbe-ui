import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/presentation/contact_inline_create.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Picks one of the customer's own contacts, or creates one inline and links
/// it to them (FR-031). Returns the chosen contact id, or `null` if the
/// cashier backed out.
///
/// A destination's contact is a real `Contact` id (research §10, resolved) —
/// it is never written into the delivery comment as free text.
Future<int?> showCustomerContactPicker(
  BuildContext context, {
  required int customerId,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _CustomerContactPicker(customerId: customerId),
  );
}

class _CustomerContactPicker extends ConsumerStatefulWidget {
  const _CustomerContactPicker({required this.customerId});

  final int customerId;

  @override
  ConsumerState<_CustomerContactPicker> createState() =>
      _CustomerContactPickerState();
}

class _CustomerContactPickerState extends ConsumerState<_CustomerContactPicker> {
  bool _linking = false;

  Future<void> _createAndLink(List<Contact> existing) async {
    final created = await showContactInlineCreateDialog(context);
    if (created == null || !mounted) return;

    setState(() => _linking = true);
    try {
      await ref
          .read(customerRepositoryProvider)
          .update(
            customerId: widget.customerId,
            // Replace-all: every existing id has to be resent or it unlinks.
            contacts: [...existing.map((c) => c.contactId), created.contactId],
          );
      ref.invalidate(saleCustomerControllerProvider(widget.customerId));
      if (mounted) Navigator.of(context).pop(created.contactId);
    } on Object {
      if (mounted) setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customer = ref.watch(saleCustomerControllerProvider(widget.customerId));

    return AlertDialog(
      title: Text(l10n.posDeliveryContactTitle),
      content: SizedBox(
        width: 480,
        child: customer.when(
          data: (value) => value.contacts.isEmpty
              ? Text(l10n.posNoContactsOnFile)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final contact in value.contacts)
                      ListTile(
                        key: Key('contact_option_${contact.contactId}'),
                        leading: const Icon(Icons.person_outline),
                        title: Text(contact.name),
                        subtitle: contact.preferredPhone == null
                            ? null
                            : Text(contact.preferredPhone!),
                        onTap: _linking
                            ? null
                            : () => Navigator.of(context).pop(contact.contactId),
                      ),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text(l10n.posNoContactsOnFile),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _linking ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          key: const Key('contact_create_button'),
          onPressed: _linking
              ? null
              : () => _createAndLink(customer.valueOrNull?.contacts ?? const []),
          child: _linking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.posNewContactAction),
        ),
      ],
    );
  }
}
