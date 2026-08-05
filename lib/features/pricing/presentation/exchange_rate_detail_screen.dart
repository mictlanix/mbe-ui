import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rate_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single exchange rate (FR-016,
/// FR-017). [exchangeRateId] is `null` in create mode.
class ExchangeRateDetailScreen extends ConsumerStatefulWidget {
  const ExchangeRateDetailScreen({
    super.key,
    this.exchangeRateId,
    this.forceReadOnly = false,
  });

  final int? exchangeRateId;
  final bool forceReadOnly;

  @override
  ConsumerState<ExchangeRateDetailScreen> createState() =>
      _ExchangeRateDetailScreenState();
}

class _ExchangeRateDetailScreenState
    extends ConsumerState<ExchangeRateDetailScreen> {
  bool get _isEdit => widget.exchangeRateId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(exchangeRateFormControllerProvider.notifier)
            .loadForEdit(widget.exchangeRateId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(exchangeRateFormControllerProvider);
    final controller = ref.read(exchangeRateFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.exchangeRates,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.exchangeRates,
      AccessRight.update,
    );
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;

    final title = readOnly
        ? l10n.viewExchangeRateTitle
        : (_isEdit ? l10n.editExchangeRateTitle : l10n.newExchangeRateTitle);

    if (formState.loading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (formState.saved || formState.deleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    }

    final fieldsEnabled = !formState.submitting && !readOnly;
    final canSave = !widget.forceReadOnly && (_isEdit ? canUpdate : canCreate);
    final canDelete =
        _isEdit &&
        !readOnly &&
        access.can(SystemObject.exchangeRates, AccessRight.delete);

    final mode = !_isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveFormGrid(
          maxColumns: 2,
          children: [
            if (formState.error != null)
              FormGridChild(
                span: FormGridSpan.full,
                ErrorBanner(
                  error: AppError.validation([
                    FieldError(
                      loc: const [],
                      msg: _localizeFormError(l10n, formState.error!),
                      type: 'error',
                    ),
                    if (formState.errorDetail != null)
                      FieldError(
                        loc: const [],
                        msg: formState.errorDetail!,
                        type: 'error',
                      ),
                  ]),
                ),
              ),
            FormGridChild(
              InkWell(
                key: const Key('exchange_rate_date_field'),
                onTap: !fieldsEnabled
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: formState.date ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) controller.dateChanged(picked);
                      },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.exchangeRateDateLabel,
                    errorText: _localizeFieldError(
                      l10n,
                      formState.fieldErrors['date'],
                    ),
                  ),
                  child: Text(
                    formState.date != null
                        ? MoneyFormatters.date(formState.date!)
                        : '',
                  ),
                ),
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('exchange_rate_rate_field'),
                initialValue: formState.rate,
                decoration: InputDecoration(
                  labelText: l10n.exchangeRateRateLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['rate'],
                  ),
                ),
                enabled: fieldsEnabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.rateChanged,
              ),
            ),
            FormGridChild(
              DropdownButtonFormField<Currency>(
                key: const Key('exchange_rate_base_field'),
                initialValue: formState.base,
                decoration: InputDecoration(
                  labelText: l10n.exchangeRateBaseCurrencyLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['base'],
                  ),
                ),
                items: [
                  for (final currency in Currency.values)
                    DropdownMenuItem(
                      value: currency,
                      child: Text(_currencyLabel(l10n, currency)),
                    ),
                ],
                onChanged: !fieldsEnabled
                    ? null
                    : (currency) {
                        if (currency != null) controller.baseChanged(currency);
                      },
              ),
            ),
            FormGridChild(
              DropdownButtonFormField<Currency>(
                key: const Key('exchange_rate_target_field'),
                initialValue: formState.target,
                decoration: InputDecoration(
                  labelText: l10n.exchangeRateTargetCurrencyLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['target'],
                  ),
                ),
                items: [
                  for (final currency in Currency.values)
                    DropdownMenuItem(
                      value: currency,
                      child: Text(_currencyLabel(l10n, currency)),
                    ),
                ],
                onChanged: !fieldsEnabled
                    ? null
                    : (currency) {
                        if (currency != null) {
                          controller.targetChanged(currency);
                        }
                      },
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              RecordFormActions(
                mode: mode,
                saveLabel: l10n.saveButton,
                editLabel: l10n.editRecordTooltip,
                deleteLabel: l10n.deleteExchangeRateButton,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_exchange_rate_button'),
                saveKey: const Key('save_button'),
                deleteKey: const Key('delete_exchange_rate_button'),
                onEdit: (canUpdate && widget.exchangeRateId != null)
                    ? () => context.replace(
                        '/exchange-rates/${widget.exchangeRateId}',
                      )
                    : null,
                onSave: canSave
                    ? (_isEdit
                          ? controller.submitUpdate
                          : controller.submitCreate)
                    : null,
                onDelete: canDelete ? controller.delete : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deleteExchangeRateConfirmTitle,
                  message: l10n.deleteExchangeRateConfirmMessage,
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_exchange_rate_button'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _currencyLabel(AppLocalizations l10n, Currency currency) =>
    switch (currency) {
      Currency.mxn => l10n.currencyMxnLabel,
      Currency.usd => l10n.currencyUsdLabel,
      Currency.eur => l10n.currencyEurLabel,
    };

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case ExchangeRateFormErrorCode.loadFailed:
      return l10n.exchangeRateLoadFailedError;
    case ExchangeRateFormErrorCode.createFailed:
      return l10n.exchangeRateCreateFailedError;
    case ExchangeRateFormErrorCode.updateFailed:
      return l10n.exchangeRateUpdateFailedError;
    case ExchangeRateFormErrorCode.deleteFailed:
      return l10n.exchangeRateDeleteFailedError;
    case ExchangeRateFormErrorCode.createPermissionDenied:
      return l10n.exchangeRateCreatePermissionDeniedError;
    case ExchangeRateFormErrorCode.updatePermissionDenied:
      return l10n.exchangeRateUpdatePermissionDeniedError;
    case ExchangeRateFormErrorCode.deletePermissionDenied:
      return l10n.exchangeRateDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case ExchangeRateFormErrorCode.dateRequired:
      return l10n.exchangeRateDateRequiredError;
    case ExchangeRateFormErrorCode.rateInvalid:
      return l10n.exchangeRateRateInvalidError;
    case ExchangeRateFormErrorCode.currencyRequired:
      return l10n.exchangeRateCurrencyRequiredError;
    default:
      return code;
  }
}
