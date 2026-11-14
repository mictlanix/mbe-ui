import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/facility_payment_options_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// What the record form can refuse (spec 059 FR-012, FR-015), each shown
/// under the field it is about.
enum RecordPaymentIssue {
  customer,
  walkIn,
  method,
  reference,
  amount,
  cashSession,
}

/// Records a credit payment or an advance from the back office (spec 059 C2,
/// US2). On success it closes and opens the new payment's own view, where it is
/// applied and its ticket printed.
Future<void> showRecordPaymentDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => const _RecordPaymentDialog(),
);

/// One thing the payment can be tendered as: a facility's payment-method
/// option, or a bare method when the facility has no options.
class _Tender {
  const _Tender({
    required this.name,
    required this.methodCode,
    this.optionId,
    this.requiresReference = false,
  });

  final String name;
  final int methodCode;
  final int? optionId;
  final bool requiresReference;

  bool get isCash => methodCode == PaymentMethod.cash.code;
}

class _RecordPaymentDialog extends ConsumerStatefulWidget {
  const _RecordPaymentDialog();

  @override
  ConsumerState<_RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<_RecordPaymentDialog> {
  // simplified: these are the bare tenders the register falls back to when a
  // facility defines no options of its own; add the rest if a facility needs
  // one here without defining an option.
  static const _fallbackMethods = [
    PaymentMethod.cash,
    PaymentMethod.creditCard,
    PaymentMethod.debitCard,
    PaymentMethod.eft,
  ];

  final _reference = TextEditingController();
  final _amount = TextEditingController();

  CustomerListItem? _customer;
  PaymentType _type = PaymentType.creditPayment;
  int? _tenderIndex;
  // simplified: the tenant's default currency isn't exposed to the client, so
  // a multi-currency deployment starts on the peso; with one currency the
  // field is left out and the server applies its own default.
  Currency _currency = Currency.mxn;

  Set<RecordPaymentIssue> _issues = const {};
  bool _busy = false;
  AppError? _refusal;
  bool _unknownResult = false;

  @override
  void dispose() {
    _reference.dispose();
    _amount.dispose();
    super.dispose();
  }

  List<_Tender> _tenders(AppLocalizations l10n) {
    final facilityId = ref.watch(userFacilityIdProvider);
    final options = facilityId == null
        ? null
        : ref.watch(facilityPaymentOptionsControllerProvider(facilityId));
    final list = options?.value;
    if (facilityId == null || (options?.hasError ?? false)) {
      return _bareTenders(l10n);
    }
    if (list == null) return const [];
    if (list.isEmpty) return _bareTenders(l10n);
    return [
      for (final option in list)
        _Tender(
          name: option.name,
          methodCode: option.paymentMethod,
          optionId: option.paymentMethodOptionId,
          requiresReference: option.requiresReference,
        ),
    ];
  }

  List<_Tender> _bareTenders(AppLocalizations l10n) => [
    for (final method in _fallbackMethods)
      _Tender(
        name: paymentMethodLabel(l10n, method.code),
        methodCode: method.code,
      ),
  ];

  /// Reads the cash session fresh: a stale or missing one, or a failed read,
  /// counts as none (FR-015), as the register's own check does.
  Future<bool> _hasOpenSession() async {
    try {
      final session = await ref.refresh(
        currentSessionControllerProvider.future,
      );
      return session.isValid;
    } on AppError {
      return false;
    }
  }

  Future<Set<RecordPaymentIssue>> _validate(_Tender? tender) async {
    final issues = <RecordPaymentIssue>{};
    final customer = _customer;
    if (customer == null) {
      issues.add(RecordPaymentIssue.customer);
    } else if (ref
        .read(appSettingsProvider)
        .isGenericCustomer(customer.customerId)) {
      issues.add(RecordPaymentIssue.walkIn);
    }
    if (tender == null) {
      issues.add(RecordPaymentIssue.method);
    } else if (tender.requiresReference && _reference.text.trim().isEmpty) {
      issues.add(RecordPaymentIssue.reference);
    }
    final amount = tryParseAmount(_amount.text);
    if (amount == null || compareAmounts(amount, '0') <= 0) {
      issues.add(RecordPaymentIssue.amount);
    }
    if (tender != null && tender.isCash && !await _hasOpenSession()) {
      issues.add(RecordPaymentIssue.cashSession);
    }
    return issues;
  }

  Future<void> _save(List<_Tender> tenders) async {
    if (_busy) return;
    final tender = _tenderIndex == null ? null : tenders[_tenderIndex!];
    setState(() {
      _busy = true;
      _refusal = null;
      _unknownResult = false;
    });
    final issues = await _validate(tender);
    if (!mounted) return;
    if (issues.isNotEmpty) {
      setState(() {
        _busy = false;
        _issues = issues;
      });
      return;
    }
    setState(() => _issues = const {});

    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    try {
      final reference = _reference.text.trim();
      final id = await ref
          .read(customerPaymentRepositoryProvider)
          .createPayment(
            customer: _customer!.customerId,
            amount: tryParseAmount(_amount.text)!,
            method: tender!.methodCode,
            currency: ref.read(multiCurrencyEnabledProvider) ? _currency : null,
            paymentCharge: tender.optionId,
            reference: reference.isEmpty ? null : reference,
            type: _type,
          );
      ref.invalidate(paymentsListControllerProvider);
      if (!mounted) return;
      navigator.pop();
      unawaited(router.push('/sales/payments/$id'));
    } on NetworkError {
      // The request may have reached the server: say so rather than offer a
      // retry that could record the payment twice (spec edge case).
      if (mounted) setState(() => _unknownResult = true);
    } on AppError catch (e) {
      if (mounted) setState(() => _refusal = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _issueText(AppLocalizations l10n, Set<RecordPaymentIssue> hit) {
    if (hit.contains(RecordPaymentIssue.walkIn)) {
      return l10n.paymentRecordErrorWalkIn;
    }
    if (hit.contains(RecordPaymentIssue.customer)) {
      return l10n.paymentRecordErrorCustomer;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final tenders = _tenders(l10n);
    final multiCurrency = ref.watch(multiCurrencyEnabledProvider);
    final index = _tenderIndex != null && _tenderIndex! < tenders.length
        ? _tenderIndex
        : null;
    final tender = index == null ? null : tenders[index];

    return ResponsiveDialog(
      key: const Key('record_payment_dialog'),
      title: l10n.paymentRecordAction,
      maxWidth: 640,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<CustomerListItem>(
            key: const Key('record_payment_customer'),
            label: l10n.paymentsColumnCustomer,
            enabled: !_busy,
            errorText: _issueText(l10n, _issues),
            displayStringForOption: (c) => '${c.code} — ${c.name}',
            optionsBuilder: (search) async {
              final result = await ref
                  .read(customerRepositoryProvider)
                  .list(search: search.isEmpty ? null : search, limit: 10);
              return result.items;
            },
            onSelected: (c) => setState(() {
              _customer = c;
              _issues = _issues.difference({
                RecordPaymentIssue.customer,
                RecordPaymentIssue.walkIn,
              });
            }),
          ),
          SegmentedButton<PaymentType>(
            key: const Key('record_payment_type'),
            segments: [
              for (final type in const [
                PaymentType.creditPayment,
                PaymentType.paymentInAdvance,
              ])
                ButtonSegment(
                  value: type,
                  label: Text(paymentTypeLabel(l10n, type)),
                ),
            ],
            selected: {_type},
            onSelectionChanged: _busy
                ? null
                : (selection) => setState(() => _type = selection.first),
          ),
          ResponsiveFormGrid(
            maxColumns: 2,
            spacing: spacing.fieldGapHorizontal,
            children: [
              FormGridChild(
                DropdownButtonFormField<int>(
                  key: const Key('record_payment_method'),
                  initialValue: index,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.paymentsColumnMethod,
                    errorText: _issues.contains(RecordPaymentIssue.method)
                        ? l10n.paymentRecordErrorMethod
                        : null,
                  ),
                  items: [
                    for (var i = 0; i < tenders.length; i++)
                      DropdownMenuItem(value: i, child: Text(tenders[i].name)),
                  ],
                  onChanged: _busy || tenders.isEmpty
                      ? null
                      : (value) => setState(() {
                          _tenderIndex = value;
                          _issues = _issues.difference({
                            RecordPaymentIssue.method,
                            RecordPaymentIssue.cashSession,
                          });
                        }),
                ),
              ),
              FormGridChild(
                TextField(
                  key: const Key('record_payment_reference'),
                  controller: _reference,
                  enabled: !_busy,
                  maxLength: 50,
                  decoration: InputDecoration(
                    labelText: (tender?.requiresReference ?? false)
                        ? '${l10n.paymentsColumnReference} *'
                        : l10n.paymentsColumnReference,
                    errorText: _issues.contains(RecordPaymentIssue.reference)
                        ? l10n.paymentRecordErrorReference
                        : null,
                  ),
                ),
              ),
              FormGridChild(
                TextField(
                  key: const Key('record_payment_amount'),
                  controller: _amount,
                  enabled: !_busy,
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.paymentsColumnAmount,
                    errorText: _issues.contains(RecordPaymentIssue.amount)
                        ? l10n.paymentRecordErrorAmount
                        : null,
                  ),
                ),
              ),
              if (multiCurrency)
                FormGridChild(
                  DropdownButtonFormField<Currency>(
                    key: const Key('record_payment_currency'),
                    initialValue: _currency,
                    decoration: InputDecoration(
                      labelText: l10n.paymentRecordCurrencyLabel,
                    ),
                    items: [
                      for (final currency in Currency.values)
                        DropdownMenuItem(
                          value: currency,
                          child: Text(currencyCodeLabel(currency)),
                        ),
                    ],
                    onChanged: _busy
                        ? null
                        : (value) => setState(() => _currency = value!),
                  ),
                ),
            ],
          ),
          if (_issues.contains(RecordPaymentIssue.cashSession))
            Column(
              key: const Key('record_payment_cash_session_error'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.paymentRecordErrorCashSession,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                TextButton(
                  key: const Key('record_payment_go_sessions'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).go('/sales/cash-sessions');
                  },
                  child: Text(l10n.paymentRecordGoToSessions),
                ),
              ],
            ),
          if (_refusal != null) ErrorBanner(error: _refusal!),
          if (_unknownResult)
            ErrorBanner(
              key: const Key('record_payment_unknown_result'),
              error: AppError.validation([
                FieldError(
                  loc: const [],
                  msg: l10n.paymentRecordUnknownResult,
                  type: 'error',
                ),
              ]),
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('record_payment_save'),
        label: _busy ? l10n.paymentRecordSaving : l10n.paymentRecordSave,
        busy: _busy,
        onPressed: () => _save(tenders),
      ),
    );
  }
}
