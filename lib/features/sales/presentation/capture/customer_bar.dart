import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Customer identity and payment terms (FR-011, FR-012, FR-016). Preselected
/// with the walk-in customer the sale already opened with; the cashier may
/// search a different one or toggle immediate/credit terms, both wired
/// straight to `PosSaleController.updateHeader`. FR-015's re-pricing needs no
/// special handling here: the response already carries every line re-priced,
/// and the controller's normal wholesale replace picks it up.
///
/// Shows name and price list. `CustomerResponse` carries no outstanding-
/// balance field (verified against the generated DTO) — FR-011's "outstanding
/// balance" is not rendered here for lack of a backing field, a documented
/// gap rather than a fabricated figure.
class CustomerBar extends ConsumerStatefulWidget {
  const CustomerBar({super.key, required this.sale, this.enabled = true});

  final Sale sale;
  final bool enabled;

  @override
  ConsumerState<CustomerBar> createState() => _CustomerBarState();
}

class _CustomerBarState extends ConsumerState<CustomerBar> {
  AppError? _error;
  bool _busy = false;

  Future<void> _updateHeader({int? customer, PaymentTerms? paymentTerms}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(posSaleControllerProvider.notifier)
          .updateHeader(customer: customer, paymentTerms: paymentTerms);
    } on AppError catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sale = widget.sale;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              ErrorBanner(error: _error!, onDismiss: () => setState(() => _error = null)),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: CatalogEntityPicker<CustomerListItem>(
                    label: l10n.posCustomerLabel,
                    initialDisplayText: sale.customerName,
                    enabled: widget.enabled && !_busy,
                    displayStringForOption: (c) => '${c.code} — ${c.name}',
                    optionsBuilder: (query) async {
                      final result = await ref
                          .read(customerRepositoryProvider)
                          .list(search: query, limit: 10);
                      return result.items;
                    },
                    onSelected: (c) => _updateHeader(customer: c.customerId),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<PaymentTerms>(
                  segments: [
                    ButtonSegment(value: PaymentTerms.immediate, label: Text(l10n.posPaymentTermsImmediate)),
                    ButtonSegment(value: PaymentTerms.netD, label: Text(l10n.posPaymentTermsCredit)),
                  ],
                  selected: {sale.paymentTerms},
                  onSelectionChanged: (widget.enabled && !_busy)
                      ? (selection) => _updateHeader(paymentTerms: selection.first)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
