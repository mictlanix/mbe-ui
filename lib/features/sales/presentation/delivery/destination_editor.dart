import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/line_distribution_panel.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_address_picker.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_contact_picker.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Composes one destination before it is submitted (FR-031, FR-032): where it
/// goes, who receives it, when, and how much of each line it takes.
///
/// The address and contact are real linked records, picked from the
/// customer's own or created inline — never free text. A refused submit keeps
/// the editor open with the server's own message, naming the line and
/// shortfall it objected to, and leaves every already-created destination
/// untouched (FR-037).
class DestinationEditor extends ConsumerStatefulWidget {
  const DestinationEditor({super.key, required this.sale, required this.onDone});

  final Sale sale;
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

  /// Sale line id → the quantity this destination claims.
  final Map<int, TextEditingController> _quantities = {};

  AppError? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    for (final line in widget.sale.lines) {
      _quantities[line.id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _comment.dispose();
    for (final controller in _quantities.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<int, String> get _draft => {
    for (final entry in _quantities.entries)
      entry.key: entry.value.text.trim().isEmpty ? '0' : entry.value.text.trim(),
  };

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
            quantities: _draft,
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
    final distribution = ref
        .read(deliveryControllerProvider(widget.sale).notifier)
        .distribution(draft: _draft);
    final overClaimed = distribution.any((d) => d.isOverClaimed);
    final claimsSomething = _draft.values.any((q) => !isZeroAmount(q));
    final canSubmit =
        !_submitting && _shipTo != null && claimsSomething && !overClaimed;

    return Card(
      key: const Key('destination_editor'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              ErrorBanner(
                key: const Key('destination_editor_error'),
                error: _error!,
                onDismiss: () => setState(() => _error = null),
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                        : MoneyFormatters.date(_date!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('destination_comment_field'),
              controller: _comment,
              enabled: !_submitting,
              decoration: InputDecoration(labelText: l10n.posDeliveryInstructions),
            ),
            const SizedBox(height: 12),
            Text(l10n.posDestinationQuantitiesTitle,
                style: Theme.of(context).textTheme.titleSmall),
            for (final line in distribution)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(line.productName)),
                    Expanded(
                      child: Text(
                        l10n.posDistributionClaimable(
                          formatQuantity(line.claimable),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      child: TextField(
                        key: Key('destination_quantity_${line.saleLineId}'),
                        controller: _quantities[line.saleLineId],
                        enabled: !_submitting,
                        textAlign: TextAlign.center,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          errorText: line.isOverClaimed
                              ? l10n.posDistributionOverClaimed
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      key: Key('destination_claim_all_${line.saleLineId}'),
                      tooltip: l10n.posDistributionClaimAll,
                      onPressed: _submitting
                          ? null
                          : () => setState(() {
                              _quantities[line.saleLineId]!.text =
                                  formatQuantity(line.claimable);
                            }),
                      icon: const Icon(Icons.keyboard_double_arrow_left),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            LineDistributionPanel(distribution: distribution),
            const SizedBox(height: 12),
            // A `Wrap`, because "Cancelar" beside "Agregar destino" does not
            // fit a phone-width card (US5, SC-007) — there the second button
            // drops to its own line rather than being pushed off the edge.
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
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
      ),
    );
  }
}
