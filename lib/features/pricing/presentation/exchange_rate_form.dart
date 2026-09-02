import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rate_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single exchange rate (spec 035 US5 —
/// converted from the pushed `/exchange-rates/new` /
/// `/exchange-rates/:exchangeRateId` routes to the shared record panel,
/// `showRecordSheet`). [exchangeRateId] is `null` in create mode. See
/// `label_form.dart` for the base pattern (spec 035 T029).
class ExchangeRateForm extends ConsumerStatefulWidget {
  const ExchangeRateForm({
    super.key,
    this.exchangeRateId,
    this.forceReadOnly = false,
  });

  final int? exchangeRateId;
  final bool forceReadOnly;

  @override
  ConsumerState<ExchangeRateForm> createState() => ExchangeRateFormPanelState();
}

/// Public so a caller can address it via
/// `GlobalKey<ExchangeRateFormPanelState>` and query [isDirty] from
/// `showRecordSheet`'s `isDirty` callback.
class ExchangeRateFormPanelState extends ConsumerState<ExchangeRateForm> {
  bool get _isEdit => widget.exchangeRateId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [ExchangeRateFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028).
  ExchangeRateFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(exchangeRateFormControllerProvider.notifier)
            .loadForEdit(widget.exchangeRateId!);
        if (mounted) {
          setState(
            () => _snapshot = ref.read(exchangeRateFormControllerProvider),
          );
        }
      });
    } else {
      _snapshot = ref.read(exchangeRateFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(exchangeRateFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(exchangeRateFormControllerProvider);
    final controller = ref.read(exchangeRateFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final fmt = ref.watch(formattersProvider);
    final canCreate = access.can(
      SystemObject.exchangeRates,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.exchangeRates,
      AccessRight.update,
    );
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;

    if (formState.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (formState.saved || formState.deleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final fieldsEnabled = !formState.submitting && !readOnly;
    final canSave = !readOnly && (_isEdit ? canUpdate : canCreate);
    final canDelete =
        _isEdit &&
        !readOnly &&
        access.can(SystemObject.exchangeRates, AccessRight.delete);

    final mode = !_isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);

    return ResponsiveFormGrid(
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
              // fmt.display.date renders '—' for a null date
              // (spec 028 FR-008), replacing this field's own empty
              // string rendering.
              child: Text(fmt.display.date(formState.date)),
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: controller.rateChanged,
          ),
        ),
        FormGridChild(
          DropdownButtonFormField<Currency>(
            key: const Key('exchange_rate_base_field'),
            initialValue: formState.base,
            isExpanded: true,
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
            isExpanded: true,
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
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
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
