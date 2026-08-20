import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/customer_inline_create.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Customer identity and payment terms (FR-011, FR-012, FR-016;
/// spec 023 contracts/capture-surface.md §1). Two mutually exclusive faces,
/// animated between:
///
/// - **facts** (default): the customer's standing facts — name, payment
///   terms, price list, outstanding balance — read as information, with
///   Buscar/Nuevo actions trailing.
/// - **searching**: Buscar swaps the facts for the customer picker, in
///   place, until a customer is chosen or the search is dismissed
///   (FR-023, FR-025, FR-026).
///
/// The payment-terms segmented control from spec 020 is gone; terms are now
/// a dropdown in the credit-line slot, gated on whether the customer
/// actually has a credit line, and never written except by the cashier's
/// own choice (FR-028–FR-030). FR-015's re-pricing needs no special
/// handling here: the response already carries every line re-priced, and
/// the controller's normal wholesale replace picks it up.
class CustomerBar extends ConsumerStatefulWidget {
  const CustomerBar({super.key, required this.sale, this.enabled = true});

  /// `null` before the first action has opened a sale. The band still renders
  /// — on [posDefaultCustomerId], the walk-in customer mbe-api would raise
  /// the sale against anyway — so the capture surface opens complete instead
  /// of the band appearing from nowhere once the first scan lands (and
  /// shoving the search field and lines down as it does).
  ///
  /// Nothing here writes that fallback: both actions this band offers go
  /// through `PosSaleController.updateHeader`, which opens the sale itself
  /// (its own "editing the header is a legitimate first action"), and the
  /// sale's real `customer` takes over from that moment on.
  final Sale? sale;
  final bool enabled;

  @override
  ConsumerState<CustomerBar> createState() => _CustomerBarState();
}

enum _CustomerBandMode { facts, searching }

class _CustomerBarState extends ConsumerState<CustomerBar> {
  AppError? _error;
  bool _busy = false;
  _CustomerBandMode _mode = _CustomerBandMode.facts;

  Future<void> _updateHeader({int? customer, PaymentTerms? paymentTerms}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(posSaleControllerProvider.notifier)
          .updateHeader(customer: customer, paymentTerms: paymentTerms);
      // A customer was just attached — return to reporting facts for it
      // (FR-023). A terms-only change has no face to return from.
      if (customer != null && mounted) {
        setState(() => _mode = _CustomerBandMode.facts);
      }
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

  void _startSearch() {
    setState(() {
      _error = null;
      _mode = _CustomerBandMode.searching;
    });
  }

  /// FR-026: dismissing the picker restores facts with nothing changed.
  void _cancelSearch() => setState(() => _mode = _CustomerBandMode.facts);

  /// The customer the band reports on: the sale's own once there is one,
  /// the configured walk-in default until then.
  int get _customerId =>
      widget.sale?.customer ?? ref.read(appSettingsProvider).posDefaultCustomerId;

  /// Immediate is what mbe-api itself derives for a customer with no credit
  /// line, which the walk-in customer is — so the dropdown shows the terms
  /// the sale would actually be raised on, not a guess.
  PaymentTerms get _terms => widget.sale?.paymentTerms ?? PaymentTerms.immediate;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final enabled = widget.enabled && !_busy;

    final theme = Theme.of(context);

    return Card(
      // Material's own default `Card` margin, left in place, inset this band
      // a few pixels further than the product search field directly beneath
      // it — a misalignment visible against that field's edge. The step
      // already owns every horizontal inset here (`horizontalInset` in
      // `capture_step.dart`), so the card contributes none of its own.
      margin: EdgeInsets.zero,
      // Outlined, as the mock draws this band (`border:1px solid #26262F`
      // over a barely-lighter fill): at this size a shadow alone did not
      // read as an edge, and the band needs one to sit as a peer beside the
      // mode selector's own outline. `outlineVariant` is M3's subtle-border
      // role, and the radius stays the card theme's own `shapes.lg` so this
      // is still the same card shape every other surface uses.
      shape: RoundedRectangleBorder(
        borderRadius: theme.shapes.lgRadius,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        // Tighter than the generic `spacing.cardPadding` (24 at this tier),
        // which made a band of one-line facts as tall as a form. The mock
        // gives this band no vertical padding at all — a fixed 56 px with the
        // content centred (`padding:0 8px 0 16px`) — which is not reachable
        // here while the actions keep the 48 px height they share with the
        // mode selector beside them (FR-038a). `sm` vertical is the floor that
        // leaves those buttons breathing room; `md` horizontal is the mock's
        // own leading inset.
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              ErrorBanner(error: _error!, onDismiss: () => setState(() => _error = null)),
              SizedBox(height: spacing.xs),
            ],
            AnimatedSize(
              duration: kThemeAnimationDuration,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: kThemeAnimationDuration,
                child: _mode == _CustomerBandMode.facts
                    ? _FactsView(
                        key: const ValueKey('facts'),
                        customerId: _customerId,
                        terms: _terms,
                        enabled: enabled,
                        busy: _busy,
                        canCreate: _canCreateCustomers,
                        onSearch: _startSearch,
                        onCreate: _createCustomer,
                        onTermsChanged: (terms) => _updateHeader(paymentTerms: terms),
                      )
                    : _SearchingView(
                        key: const ValueKey('searching'),
                        enabled: enabled,
                        busy: _busy,
                        initialDisplayText: widget.sale?.customerName,
                        onSelected: (customer) =>
                            _updateHeader(customer: customer.customerId),
                        onCancel: _cancelSearch,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canCreateCustomers => ref
      .watch(accessControlProvider)
      .can(SystemObject.customers, AccessRight.create);
}

/// The default face: the customer's standing facts, read-only, with the
/// Buscar/Nuevo actions trailing (contracts/capture-surface.md §1.1).
class _FactsView extends ConsumerWidget {
  const _FactsView({
    required super.key,
    required this.customerId,
    required this.terms,
    required this.enabled,
    required this.busy,
    required this.canCreate,
    required this.onSearch,
    required this.onCreate,
    required this.onTermsChanged,
  });

  /// The sale's customer, or the walk-in default before a sale exists —
  /// resolved by [CustomerBar], so this face never asks which it is.
  final int customerId;
  final PaymentTerms terms;
  final bool enabled;
  final bool busy;
  final bool canCreate;
  final VoidCallback onSearch;
  final VoidCallback onCreate;
  final ValueChanged<PaymentTerms> onTermsChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final customerAsync = ref.watch(saleCustomerControllerProvider(customerId));
    // FR-023: the resolved customer record's name is what this shows. The
    // sale's own `customerName` is only the per-document override — null for
    // the walk-in customer even while this same record knows the name — so
    // reading it first left the band blank (mictlanix/mbe-api#172).
    final displayName = customerAsync.valueOrNull?.name ?? '—';

    // Both actions share one height, so they sit on a single baseline rather
    // than each on its own.
    //
    // That height was originally the one `SegmentedButton` could not be pushed
    // past; the mode selector is hand-rolled now and stands at 56
    // (`fulfillmentModeSelectorHeight`), so the constraint is gone. These stay
    // at Material's minimum interactive dimension because that is what the
    // mock gives them — buttons *inside* the band, smaller than the band, not
    // peers of the selector beside it.
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, kMinInteractiveDimension),
    );

    final actions = Wrap(
      spacing: 8,
      children: [
        OutlinedButton.icon(
          key: const Key('pos_customer_search_button'),
          style: buttonStyle,
          icon: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          label: Text(l10n.posCustomerSearchAction),
          onPressed: enabled ? onSearch : null,
        ),
        if (canCreate)
          // Same affordance as Buscar, deliberately: the mock draws the pair
          // as two identical outlined pills, and as a bare icon this one read
          // as a lesser control while also being the only unlabelled thing in
          // the band. The longer `posCreateCustomerAction` stays as the
          // tooltip, so the short visible label costs nothing in clarity.
          OutlinedButton.icon(
            key: const Key('pos_create_customer_button'),
            style: buttonStyle,
            icon: const Icon(Icons.person_add_alt),
            label: Text(l10n.posCustomerCreateAction),
            onPressed: enabled ? onCreate : null,
          ),
      ],
    );

    final facts = Wrap(
      spacing: 24,
      runSpacing: 4,
      children: [
        _CustomerBarFact.fact(context, l10n.posCustomerNameLabel, displayName),
        _TermsFact(
          customerId: customerId,
          terms: terms,
          enabled: enabled,
          onChanged: onTermsChanged,
        ),
        customerAsync.when(
          data: (value) => _CustomerBarFact.fact(
            context,
            l10n.posCustomerPriceListLabel,
            value.priceList.name,
          ),
          loading: () => const SizedBox(height: 20),
          error: (error, stackTrace) => const SizedBox(height: 20),
        ),
        _BalanceFact(customerId: customerId),
      ],
    );

    // Beside the facts where there is room, beneath them on a phone. Both
    // actions carry a label now, and the pair is wide enough that keeping it
    // on the facts' row at 390 px squeezed the `Expanded` below the terms
    // dropdown's own fixed width — which, being fixed, overflowed rather
    // than shrinking with it.
    return LayoutBreakpoints.isCompact(context)
        ? Column(
            key: const Key('pos_customer_facts'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              facts,
              SizedBox(height: theme.spacing.xs),
              actions,
            ],
          )
        : Row(
            // Centred so the facts and the action pills share one line
            // rather than the pills hanging from the facts' top edge — the
            // same centring the step applies between this band and the mode
            // selector, so all three read as one row of controls.
            key: const Key('pos_customer_facts'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: facts),
              SizedBox(width: theme.spacing.sm),
              actions,
            ],
          );
  }
}

/// The credit-line fact, now a payment-terms dropdown (FR-028, FR-029,
/// FR-030) rather than a plain figure: it shows the sale's *current* terms
/// and never writes them on its own, whether or not the customer has a
/// credit line — only [onChanged] does, and only when the cashier actually
/// picks a value.
class _TermsFact extends ConsumerWidget {
  const _TermsFact({
    required this.customerId,
    required this.terms,
    required this.enabled,
    required this.onChanged,
  });

  final int customerId;
  final PaymentTerms terms;
  final bool enabled;
  final ValueChanged<PaymentTerms> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final customer = ref.watch(saleCustomerControllerProvider(customerId));
    final creditLimit = customer.valueOrNull?.creditLimit;
    final hasCredit = creditLimit != null && !isZeroAmount(creditLimit);
    final fmt = ref.watch(formattersProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.posCustomerCreditLabel, style: theme.textTheme.labelSmall),
        // A fixed width, rather than left to `DropdownButton`'s own
        // widest-item measurement pass: that auto-sizing is known to
        // overflow its own render box by a sub-pixel hair at some text
        // scales (a longstanding Flutter framework quirk, not particular to
        // this text) — reproduced live by a phone-width widget test.
        // 132 px comfortably fits "Crédito"/"Contado" plus the built-in
        // dropdown arrow with room to spare.
        SizedBox(
          width: 132,
          child: DropdownButton<PaymentTerms>(
            key: const Key('pos_payment_terms_dropdown'),
            value: terms,
            isDense: true,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: theme.textTheme.bodyMedium,
            onChanged: enabled ? (terms) => terms != null ? onChanged(terms) : null : null,
            items: [
              DropdownMenuItem(
                value: PaymentTerms.immediate,
                child: Text(l10n.posPaymentTermsImmediate),
              ),
              DropdownMenuItem(
                value: PaymentTerms.netD,
                enabled: hasCredit,
                child: Text(l10n.posPaymentTermsCredit),
              ),
            ],
          ),
        ),
        // research R9: the credit-limit figure the dropdown's slot used to
        // show is not lost — it becomes supporting text beneath the
        // control, exactly like the "no credit line" hint it replaces when
        // there is nothing to show instead.
        Text(
          hasCredit ? fmt.display.currency(creditLimit) : l10n.posCustomerNoCreditHint,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}

/// The searching face: the customer picker in place of the facts, with an
/// explicit way to dismiss it without picking anything (FR-026).
class _SearchingView extends ConsumerWidget {
  const _SearchingView({
    required super.key,
    required this.enabled,
    required this.busy,
    required this.initialDisplayText,
    required this.onSelected,
    required this.onCancel,
  });

  final bool enabled;
  final bool busy;
  final String? initialDisplayText;
  final ValueChanged<CustomerListItem> onSelected;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          onCancel();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CatalogEntityPicker<CustomerListItem>(
              key: const Key('pos_customer_picker'),
              label: l10n.posCustomerLabel,
              initialDisplayText: initialDisplayText,
              enabled: enabled && !busy,
              autofocus: true,
              displayStringForOption: (c) => '${c.code} — ${c.name}',
              optionsBuilder: (query) async {
                final result = await ref
                    .read(customerRepositoryProvider)
                    .list(search: query, limit: 10);
                return result.items;
              },
              onSelected: onSelected,
            ),
          ),
          IconButton(
            key: const Key('pos_customer_search_cancel_button'),
            icon: const Icon(Icons.close),
            tooltip: l10n.posCustomerSearchCancelAction,
            onPressed: busy ? null : onCancel,
          ),
        ],
      ),
    );
  }
}

/// FR-011's standing facts about the selected customer, shared by
/// [_FactsView]'s name/price-list entries and [_BalanceFact] — the same
/// `Column(label, value)` shape spec 020 already used.
abstract final class _CustomerBarFact {
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

/// FR-011's outstanding balance. Separate from the rest of the facts so its
/// own loading and failure states stay local: an unavailable balance leaves
/// a blank where the figure goes rather than blanking the customer area.
class _BalanceFact extends ConsumerWidget {
  const _BalanceFact({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final balance = ref.watch(customerOutstandingBalanceProvider(customerId));
    final fmt = ref.watch(formattersProvider);
    return balance.when(
      data: (value) => _CustomerBarFact.fact(
        context,
        l10n.posCustomerBalanceLabel,
        fmt.display.currency(value),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
