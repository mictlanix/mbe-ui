import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_controller.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_address_picker.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_contact_picker.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Composes a destination's header only (FR-027, contract §6): where it
/// goes, who receives it, when, and any instructions. No quantity — every
/// line is assigned afterwards, inside the resulting card's own stepper
/// (`DestinationCard`, US2).
///
/// The address and contact are real linked records, picked from the
/// customer's own or created inline — never free text. A refused submit keeps
/// the editor open with the server's own message and leaves every
/// already-created destination untouched (FR-037).
class DestinationEditor extends ConsumerStatefulWidget {
  const DestinationEditor({super.key, required this.sale, required this.onDone});

  final Sale sale;

  /// Invoked once the destination is saved, or Cancel is pressed — the
  /// caller (the sheet opener, `delivery_step.dart`) decides what that means
  /// for its own presentation (closing the sheet).
  final VoidCallback onDone;

  @override
  ConsumerState<DestinationEditor> createState() => _DestinationEditorState();
}

class _DestinationEditorState extends ConsumerState<DestinationEditor> {
  int? _shipTo;
  String? _addressLabel;
  int? _contact;
  String? _contactLabel;
  DateTime? _date;
  final _comment = TextEditingController();

  AppError? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    final id = await showCustomerAddressPicker(
      context,
      customerId: widget.sale.customer,
    );
    if (id == null || !mounted) return;
    final customer = ref.read(saleCustomerControllerProvider(widget.sale.customer)).valueOrNull;
    setState(() {
      _shipTo = id;
      _addressLabel = customer
          ?.addresses
          .where((a) => a.addressId == id)
          .firstOrNull
          ?.label;
    });
  }

  Future<void> _pickContact() async {
    final id = await showCustomerContactPicker(
      context,
      customerId: widget.sale.customer,
    );
    if (id == null || !mounted) return;
    final customer = ref.read(saleCustomerControllerProvider(widget.sale.customer)).valueOrNull;
    setState(() {
      _contact = id;
      _contactLabel = customer
          ?.contacts
          .where((c) => c.contactId == id)
          .firstOrNull
          ?.name;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(deliveryControllerProvider(widget.sale).notifier)
          .addDestination(
            shipTo: _shipTo!,
            contact: _contact,
            date: _date,
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          );
      if (mounted) widget.onDone();
    } on AppError catch (e) {
      // Stays open with the reason; nothing already created is affected.
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSubmit = !_submitting && _shipTo != null;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);

    return Padding(
      key: const Key('destination_editor'),
      padding: EdgeInsets.all(spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            ErrorBanner(
              key: const Key('destination_editor_error'),
              error: _error!,
              onDismiss: () => setState(() => _error = null),
            ),
            SizedBox(height: spacing.xs),
          ],
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              OutlinedButton.icon(
                key: const Key('destination_address_button'),
                onPressed: _submitting ? null : _pickAddress,
                icon: const Icon(Icons.location_on_outlined),
                label: Text(_addressLabel ?? l10n.posDeliveryAddressTitle),
              ),
              OutlinedButton.icon(
                key: const Key('destination_contact_button'),
                onPressed: _submitting ? null : _pickContact,
                icon: const Icon(Icons.person_outline),
                label: Text(_contactLabel ?? l10n.posDeliveryContactTitle),
              ),
              OutlinedButton.icon(
                key: const Key('destination_date_button'),
                onPressed: _submitting ? null : _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _date == null
                      ? l10n.posDeliveryDateLabel
                      : fmt.display.date(_date),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          TextField(
            key: const Key('destination_comment_field'),
            controller: _comment,
            enabled: !_submitting,
            decoration: InputDecoration(labelText: l10n.posDeliveryInstructions),
          ),
          SizedBox(height: spacing.md),
          // A `Wrap`, because "Cancelar" beside "Agregar destino" does not
          // fit a phone-width sheet (US5, SC-007) — there the second button
          // drops to its own line rather than being pushed off the edge.
          Wrap(
            alignment: WrapAlignment.end,
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              TextButton(
                onPressed: _submitting ? null : widget.onDone,
                child: Text(l10n.cancelButton),
              ),
              FilledButton(
                key: const Key('destination_save_button'),
                onPressed: canSubmit ? _submit : null,
                child: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.posAddDestination),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
