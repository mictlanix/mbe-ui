import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/outstanding_order.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_editor_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// What is wrong with the amount typed into the apply dialog (spec 059 FR-007).
enum ApplyAmountIssue {
  /// Not a number, not above zero, or with more than two decimals.
  invalid,

  /// Above [applyCeiling].
  tooHigh,
}

/// The most that can be applied to an order: the smaller of the order's
/// [balance] and what the payment has [unapplied] (FR-007). Both are the
/// server's figures; this only picks one.
String applyCeiling(String balance, String unapplied) =>
    compareAmounts(balance, unapplied) <= 0 ? balance : unapplied;

/// Whether [text] is an amount that may be applied given the [ceiling], or
/// what is wrong with it. Exact decimal comparison, never `double`.
ApplyAmountIssue? applyAmountIssue(String text, String ceiling) {
  final amount = tryParseAmount(text);
  if (amount == null || compareAmounts(amount, '0') <= 0) {
    return ApplyAmountIssue.invalid;
  }
  final decimals = amount.contains('.') ? amount.split('.').last.length : 0;
  if (decimals > 2) return ApplyAmountIssue.invalid;
  if (compareAmounts(amount, ceiling) > 0) return ApplyAmountIssue.tooHigh;
  return null;
}

/// Applies [payment]'s unapplied money to one of its customer's outstanding
/// orders (spec 059 C5, US1). Closes itself when the application went through.
Future<void> showApplyPaymentDialog(
  BuildContext context,
  CustomerPayment payment,
) => showDialog<void>(
  context: context,
  builder: (context) => _ApplyPaymentDialog(payment: payment),
);

class _ApplyPaymentDialog extends ConsumerStatefulWidget {
  const _ApplyPaymentDialog({required this.payment});

  final CustomerPayment payment;

  @override
  ConsumerState<_ApplyPaymentDialog> createState() =>
      _ApplyPaymentDialogState();
}

class _ApplyPaymentDialogState extends ConsumerState<_ApplyPaymentDialog> {
  final _search = TextEditingController();
  final _amount = TextEditingController();
  Timer? _debounce;
  int _request = 0;

  List<OutstandingOrder>? _orders;
  AppError? _loadError;
  OutstandingOrder? _selected;
  bool _busy = false;
  AppError? _refusal;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _amount.dispose();
    super.dispose();
  }

  /// The payment as the server holds it now: after a refusal the editor has
  /// reloaded it, and the ceiling must follow, not the snapshot the dialog
  /// opened with.
  CustomerPayment get _current =>
      ref.read(paymentDetailProvider(widget.payment.customerPaymentId)).value ??
      widget.payment;

  Future<void> _load() async {
    final request = ++_request;
    setState(() => _loadError = null);
    try {
      // simplified: the first 50 matches only. A customer with more
      // outstanding orders narrows the list by searching; add paging when a
      // customer really has that many.
      final page = await ref
          .read(customerPaymentRepositoryProvider)
          .listOutstandingOrders(
            customerId: widget.payment.customerId,
            search: _search.text,
            limit: 50,
          );
      if (!mounted || request != _request) return;
      // simplified: the server has no currency filter, so a page can come back
      // thin when the customer's orders are mostly in another currency; ask
      // mbe-api for a filter if that happens.
      final orders = page.items
          .where((order) => order.currency == widget.payment.currency)
          .toList();
      setState(() {
        _orders = orders;
        if (_selected != null && !orders.any((o) => o.id == _selected!.id)) {
          _selected = null;
          _amount.clear();
        }
      });
    } on AppError catch (e) {
      if (!mounted || request != _request) return;
      setState(() => _loadError = e);
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(ref.read(inputDebounceProvider), _load);
  }

  void _select(OutstandingOrder order) {
    setState(() {
      _selected = order;
      _amount.text = applyCeiling(order.balance, _current.unapplied);
    });
  }

  String? _ceiling() {
    final order = _selected;
    return order == null
        ? null
        : applyCeiling(order.balance, _current.unapplied);
  }

  ApplyAmountIssue? get _issue {
    final ceiling = _ceiling();
    return ceiling == null ? null : applyAmountIssue(_amount.text, ceiling);
  }

  bool get _canConfirm =>
      _selected != null && !_busy && _amount.text.isNotEmpty && _issue == null;

  Future<void> _confirm() async {
    final order = _selected;
    if (!_canConfirm || order == null) return;
    final amount = tryParseAmount(_amount.text)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final done = AppLocalizations.of(context)!.paymentApplyDone('${order.id}');
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(paymentEditorProvider.notifier)
        .apply(
          paymentId: widget.payment.customerPaymentId,
          saleId: order.id,
          amount: amount,
        );
    if (!mounted) return;
    if (error == null) {
      messenger.showSnackBar(SnackBar(content: Text(done)));
      navigator.pop();
      return;
    }
    // The refusal means the list or the payment was out of date: show why,
    // clear the choice, and read the orders again (FR-009).
    setState(() {
      _busy = false;
      _refusal = error;
      _selected = null;
      _amount.clear();
    });
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    // Watched so the header and the ceiling follow the editor's reload.
    final payment =
        ref
            .watch(paymentDetailProvider(widget.payment.customerPaymentId))
            .value ??
        widget.payment;
    final currencyLabel = currencyCodeLabel(payment.currency);
    final ceiling = _ceiling();
    final issue = _issue;

    return ResponsiveDialog(
      key: const Key('apply_payment_dialog'),
      title: l10n.paymentApplyTitle('${payment.customerPaymentId}'),
      maxWidth: 640,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            '${l10n.paymentApplyUnapplied(fmt.display.currency(payment.unapplied))} $currencyLabel',
            key: const Key('apply_payment_unapplied'),
            style: theme.textTheme.titleMedium,
          ),
          TextField(
            key: const Key('apply_payment_search'),
            controller: _search,
            enabled: !_busy,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.paymentApplySearchHint,
            ),
            onChanged: _searchChanged,
            onSubmitted: (_) {
              _debounce?.cancel();
              unawaited(_load());
            },
          ),
          _OrderList(
            orders: _orders,
            loadError: _loadError,
            selectedId: _selected?.id,
            searching: _search.text.trim().isNotEmpty,
            currencyLabel: currencyLabel,
            onSelect: _busy ? null : _select,
            onRetry: _load,
          ),
          TextField(
            key: const Key('apply_payment_amount'),
            controller: _amount,
            enabled: _selected != null && !_busy,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.paymentApplyAmountLabel,
              prefixText: '$currencyLabel  ',
              helperText: ceiling == null
                  ? null
                  : l10n.paymentApplyAmountMax(fmt.display.currency(ceiling)),
              errorText: switch (issue) {
                null => null,
                ApplyAmountIssue.invalid => l10n.paymentApplyAmountInvalid,
                ApplyAmountIssue.tooHigh => l10n.paymentApplyAmountTooHigh(
                  fmt.display.currency(ceiling!),
                ),
              },
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null) ErrorBanner(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('apply_payment_confirm'),
        label: l10n.paymentApplyConfirm,
        busy: _busy,
        onPressed: _canConfirm ? _confirm : null,
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  const _OrderList({
    required this.orders,
    required this.loadError,
    required this.selectedId,
    required this.searching,
    required this.currencyLabel,
    required this.onSelect,
    required this.onRetry,
  });

  final List<OutstandingOrder>? orders;
  final AppError? loadError;
  final int? selectedId;
  final bool searching;
  final String currencyLabel;
  final void Function(OutstandingOrder order)? onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fmt = ref.watch(formattersProvider);
    final orders = this.orders;

    if (loadError != null) {
      return ListFailedView(
        error: loadError!,
        retryLabel: l10n.retryButton,
        onRetry: onRetry,
      );
    }
    if (orders == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (orders.isEmpty) {
      return KeyedSubtree(
        key: const Key('apply_payment_empty'),
        child: ListEmptyView(
          message: searching
              ? l10n.paymentApplyNoMatches
              : l10n.paymentApplyEmpty(currencyLabel),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final order in orders)
            ListTile(
              key: Key('apply_payment_order_${order.id}'),
              selected: order.id == selectedId,
              enabled: onSelect != null,
              leading: Icon(
                order.id == selectedId
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(
                [
                  '#${order.id}',
                  if (order.serial != null)
                    '${l10n.paymentApplyColumnFolio} ${order.serial}',
                ].join(' · '),
              ),
              subtitle: Text(fmt.display.date(order.date)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${l10n.paymentApplyColumnBalance} ${fmt.display.currency(order.balance)}',
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    '${l10n.paymentApplyColumnTotal} ${fmt.display.currency(order.total)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              onTap: onSelect == null ? null : () => onSelect!(order),
            ),
        ],
      ),
    );
  }
}
