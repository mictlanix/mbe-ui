import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/address_inline_create.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Picks one of the customer's own addresses, or creates one inline and links
/// it to them (FR-031, FR-056). Returns the chosen address id, or `null` if
/// the cashier backed out.
///
/// Reads `Customer.addresses` (embedded since mbe-api#132) — there is no
/// global address search fallback any more (research §9, resolved).
Future<int?> showCustomerAddressPicker(
  BuildContext context, {
  required int customerId,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _CustomerAddressPicker(customerId: customerId),
  );
}

class _CustomerAddressPicker extends ConsumerStatefulWidget {
  const _CustomerAddressPicker({required this.customerId});

  final int customerId;

  @override
  ConsumerState<_CustomerAddressPicker> createState() =>
      _CustomerAddressPickerState();
}

class _CustomerAddressPickerState extends ConsumerState<_CustomerAddressPicker> {
  bool _linking = false;

  /// Creates an address and links it to the customer, then returns it. The
  /// link is a replace-all update carrying the existing ids plus the new one
  /// — omitting any would unlink them.
  Future<void> _createAndLink(List<AddressListItem> existing) async {
    final created = await showAddressInlineCreateDialog(context);
    if (created == null || !mounted) return;

    setState(() => _linking = true);
    try {
      await ref
          .read(customerRepositoryProvider)
          .update(
            customerId: widget.customerId,
            addresses: [...existing.map((a) => a.addressId), created.addressId],
          );
      ref.invalidate(saleCustomerControllerProvider(widget.customerId));
      if (mounted) Navigator.of(context).pop(created.addressId);
    } on Object {
      // The address itself was created; only the link failed. Leaving the
      // dialog open lets the cashier retry without re-entering it, and the
      // orphaned address is harmless.
      if (mounted) setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customer = ref.watch(saleCustomerControllerProvider(widget.customerId));

    return AlertDialog(
      title: Text(l10n.posDeliveryAddressTitle),
      content: SizedBox(
        width: 480,
        child: customer.when(
          data: (value) => value.addresses.isEmpty
              ? Text(l10n.posNoAddressesOnFile)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final address in value.addresses)
                      ListTile(
                        key: Key('address_option_${address.addressId}'),
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(address.label),
                        onTap: _linking
                            ? null
                            : () => Navigator.of(context).pop(address.addressId),
                      ),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text(l10n.posNoAddressesOnFile),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _linking ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          key: const Key('address_create_button'),
          onPressed: _linking
              ? null
              : () => _createAndLink(customer.valueOrNull?.addresses ?? const []),
          child: _linking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.posNewAddressAction),
        ),
      ],
    );
  }
}
