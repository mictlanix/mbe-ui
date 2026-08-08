import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/customer_inline_create.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Customer identity and payment terms (FR-011, FR-012, FR-016). Preselected
/// with the walk-in customer the sale already opened with; the cashier may
/// search a different one or toggle immediate/credit terms, both wired
/// straight to `PosSaleController.updateHeader`. FR-015's re-pricing needs no
/// special handling here: the response already carries every line re-priced,
/// and the controller's normal wholesale replace picks it up.
///
/// Shows everything FR-011 asks for: the customer's name, credit line,
/// outstanding balance and price list.
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

  /// FR-013/FR-014: create a customer without discarding the sale, then
  /// attach it. Attaching goes through the same `updateHeader` path as picking
  /// an existing customer, so the re-priced lines the server returns land the
  /// same way (FR-015) — there is nothing special about a brand-new customer.
  Future<void> _createCustomer() async {
    final created = await showCustomerInlineCreate(context, ref);
    if (created == null || !mounted) return;
    await _updateHeader(customer: created);
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
            // Phone width cannot hold the picker, the create button and a
            // three-segment terms control on one line, so the terms control
            // drops below (US5, SC-007).
            if (LayoutBreakpoints.isCompact(context)) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _picker(l10n, sale)),
                  if (_canCreateCustomers) _createButton(l10n),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: _paymentTermsControl(l10n, sale),
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _picker(l10n, sale)),
                  if (_canCreateCustomers) _createButton(l10n),
                  const SizedBox(width: 12),
                  _paymentTermsControl(l10n, sale),
                ],
              ),
            const SizedBox(height: 8),
            _CustomerFacts(customerId: sale.customer),
          ],
        ),
      ),
    );
  }

  bool get _canCreateCustomers => ref
      .watch(accessControlProvider)
      .can(SystemObject.customers, AccessRight.create);

  Widget _createButton(AppLocalizations l10n) => IconButton(
    key: const Key('pos_create_customer_button'),
    icon: const Icon(Icons.person_add_alt),
    tooltip: l10n.posCreateCustomerAction,
    onPressed: (widget.enabled && !_busy) ? _createCustomer : null,
  );

  Widget _paymentTermsControl(AppLocalizations l10n, Sale sale) =>
      SegmentedButton<PaymentTerms>(
        segments: [
          ButtonSegment(
            value: PaymentTerms.immediate,
            label: Text(l10n.posPaymentTermsImmediate),
          ),
          ButtonSegment(
            value: PaymentTerms.netD,
            label: Text(l10n.posPaymentTermsCredit),
          ),
        ],
        selected: {sale.paymentTerms},
        onSelectionChanged: (widget.enabled && !_busy)
            ? (selection) => _updateHeader(paymentTerms: selection.first)
            : null,
      );

  Widget _picker(AppLocalizations l10n, Sale sale) =>
      CatalogEntityPicker<CustomerListItem>(
        key: const Key('pos_customer_picker'),
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
      );
}

/// FR-011's standing facts about the selected customer: credit line and price
/// list, read from the full `Customer` record (the sale itself carries only
/// the id and a display name).
///
/// The **outstanding balance** comes from a second call
/// ([customerOutstandingBalanceProvider]): `CustomerResponse` carries no such
/// field, so it is summed from the customer's open orders. It renders on its
/// own once it arrives, so a slow or failing sum never holds up the rest.
class _CustomerFacts extends ConsumerWidget {
  const _CustomerFacts({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final customer = ref.watch(saleCustomerControllerProvider(customerId));
    return customer.when(
      data: (value) => Wrap(
        key: const Key('pos_customer_facts'),
        spacing: 24,
        runSpacing: 4,
        children: [
          fact(context, l10n.posCustomerNameLabel, value.name),
          fact(
            context,
            l10n.posCustomerCreditLabel,
            isZeroAmount(value.creditLimit)
                ? l10n.posCustomerNoCredit
                : MoneyFormatters.currency(value.creditLimit),
          ),
          fact(context, l10n.posCustomerPriceListLabel, value.priceList.name),
          _BalanceFact(customerId: customerId),
        ],
      ),
      loading: () => const SizedBox(height: 20),
      // A customer whose details cannot be read must not block capture — the
      // sale already knows who it is for.
      error: (error, stackTrace) => const SizedBox(height: 20),
    );
  }

  static Widget fact(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

/// FR-011's outstanding balance. Separate from [_CustomerFacts] so its own
/// loading and failure states stay local: an unavailable balance leaves a
/// blank where the figure goes rather than blanking the customer area.
class _BalanceFact extends ConsumerWidget {
  const _BalanceFact({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final balance = ref.watch(customerOutstandingBalanceProvider(customerId));
    return balance.when(
      data: (value) => _CustomerFacts.fact(
        context,
        l10n.posCustomerBalanceLabel,
        MoneyFormatters.currency(value),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
