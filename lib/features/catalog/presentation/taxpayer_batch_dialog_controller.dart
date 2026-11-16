import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_batches_controller.dart';

part 'taxpayer_batch_dialog_controller.freezed.dart';
part 'taxpayer_batch_dialog_controller.g.dart';

/// The longest series the API accepts, after trimming.
const taxpayerBatchSeriesMaxLength = 10;

/// The longest template name the API accepts, after trimming.
const taxpayerBatchTemplateNameMaxLength = 50;

/// The rule a field breaks, from the form's own validation (data-model.md).
abstract final class TaxpayerBatchFieldError {
  static const required = 'required';
  static const tooLong = 'tooLong';
  static const invalid = 'invalid';
}

/// What failed, as the code the dialog turns into a banner headline.
abstract final class TaxpayerBatchDialogErrorCode {
  static const saveFailed = 'saveFailed';
  static const deleteFailed = 'deleteFailed';
}

/// The value stored under a field for a server refusal that has no
/// validation type of its own: the series already exists for the issuer.
const taxpayerBatchDuplicateSeries = 'duplicate';

/// A height field's value: a whole number ≥ 0, or `null`.
int? parseTaxpayerBatchHeight(String text) {
  final value = int.tryParse(text.trim());
  return value == null || value < 0 ? null : value;
}

@freezed
abstract class TaxpayerBatchDialogState with _$TaxpayerBatchDialogState {
  const TaxpayerBatchDialogState._();

  const factory TaxpayerBatchDialogState({
    /// `create` for a new series; `view` or `edit` for an existing one. The
    /// Editar toggle moves `view` to `edit` in place.
    required RecordFormMode mode,
    @Default('') String series,
    FiscalDocumentKind? kind,
    @Default('') String templateName,
    @Default('') String logo,
    @Default('0') String headerHeight,
    @Default('15') String footerHeight,
    @Default(<TaxpayerBatchAccount>[]) List<TaxpayerBatchAccount> accounts,

    /// A stable id per account row, parallel to [accounts], so a row's text
    /// fields keep their state when rows are removed or moved.
    @Default(<int>[]) List<int> accountIds,
    @Default(0) int nextAccountId,

    /// Series and kind can't change: the series is in use. Starts as the
    /// series' own flag and is set by the server's in-use refusal when
    /// another user used the series after the list loaded (research R6).
    @Default(false) bool locked,

    /// `true` after the first save attempt, so a blank new dialog doesn't
    /// open already showing errors.
    @Default(false) bool submitted,
    @Default(false) bool submitting,
    @Default(false) bool done,

    /// The issuer no longer exists (research R8): the dialog closes and the
    /// screen goes back to the issuer list.
    @Default(false) bool issuerGone,

    /// A [TaxpayerBatchDialogErrorCode] for the banner headline.
    String? error,

    /// The server's refusal, kept as the error itself, never its text, so the
    /// message is built when shown and follows the language (§III).
    AppError? errorCause,

    /// Server refusals by field key: a validation type or message, or
    /// [taxpayerBatchDuplicateSeries].
    @Default(<String, String>{}) Map<String, String> serverErrors,
  }) = _TaxpayerBatchDialogState;

  /// The rules the form's own fields break, by field key (`batch`, `type`,
  /// `name`, `header_height`, `footer_height`).
  Map<String, String> get clientErrors {
    final errors = <String, String>{};
    final trimmedSeries = series.trim();
    if (!locked) {
      if (trimmedSeries.isEmpty) {
        errors['batch'] = TaxpayerBatchFieldError.required;
      } else if (trimmedSeries.length > taxpayerBatchSeriesMaxLength) {
        errors['batch'] = TaxpayerBatchFieldError.tooLong;
      }
    }
    if (kind == null) errors['type'] = TaxpayerBatchFieldError.required;
    final name = templateName.trim();
    if (name.isEmpty) {
      errors['name'] = TaxpayerBatchFieldError.required;
    } else if (name.length > taxpayerBatchTemplateNameMaxLength) {
      errors['name'] = TaxpayerBatchFieldError.tooLong;
    }
    if (parseTaxpayerBatchHeight(headerHeight) == null) {
      errors['header_height'] = TaxpayerBatchFieldError.invalid;
    }
    if (parseTaxpayerBatchHeight(footerHeight) == null) {
      errors['footer_height'] = TaxpayerBatchFieldError.invalid;
    }
    return errors;
  }
}

/// The add, view, edit and delete dialog of one series (spec 065). A family
/// keyed by the issuer's RFC, the series (`null` to add) and the mode it
/// opens in. Saving or deleting refreshes the issuer's series list itself.
@riverpod
class TaxpayerBatchDialogController extends _$TaxpayerBatchDialogController {
  @override
  TaxpayerBatchDialogState build(
    String rfc,
    TaxpayerBatch? existing,
    RecordFormMode startMode,
  ) {
    final batch = existing;
    if (batch == null) {
      return const TaxpayerBatchDialogState(mode: RecordFormMode.create);
    }
    final accounts = batch.template.accounts;
    return TaxpayerBatchDialogState(
      mode: startMode,
      series: batch.series,
      kind: batch.kind,
      templateName: batch.template.name,
      logo: batch.template.logo ?? '',
      headerHeight: '${batch.template.headerHeight}',
      footerHeight: '${batch.template.footerHeight}',
      accounts: accounts,
      accountIds: [for (var i = 0; i < accounts.length; i++) i],
      nextAccountId: accounts.length,
      locked: batch.inUse,
    );
  }

  /// Moves a read-only view to the editable form, in place.
  void switchToEdit() {
    if (state.mode == RecordFormMode.view) {
      state = state.copyWith(mode: RecordFormMode.edit);
    }
  }

  void seriesChanged(String value) =>
      state = _edited(state.copyWith(series: value), 'batch');

  void kindChanged(FiscalDocumentKind? value) =>
      state = _edited(state.copyWith(kind: value), 'type');

  void templateNameChanged(String value) =>
      state = _edited(state.copyWith(templateName: value), 'name');

  void logoChanged(String value) =>
      state = _edited(state.copyWith(logo: value), 'logo');

  void headerHeightChanged(String value) =>
      state = _edited(state.copyWith(headerHeight: value), 'header_height');

  void footerHeightChanged(String value) =>
      state = _edited(state.copyWith(footerHeight: value), 'footer_height');

  void accountAdded() {
    state = _edited(
      state.copyWith(
        accounts: [...state.accounts, const TaxpayerBatchAccount()],
        accountIds: [...state.accountIds, state.nextAccountId],
        nextAccountId: state.nextAccountId + 1,
      ),
    );
  }

  void accountRemoved(int index) {
    if (index < 0 || index >= state.accounts.length) return;
    state = _edited(
      state.copyWith(
        accounts: [...state.accounts]..removeAt(index),
        accountIds: [...state.accountIds]..removeAt(index),
      ),
    );
  }

  /// Moves the account at [index] one place up ([delta] -1) or down (+1).
  /// Does nothing at either end.
  void accountMoved(int index, int delta) {
    final target = index + delta;
    if (index < 0 ||
        index >= state.accounts.length ||
        target < 0 ||
        target >= state.accounts.length) {
      return;
    }
    final accounts = [...state.accounts];
    final ids = [...state.accountIds];
    accounts.insert(target, accounts.removeAt(index));
    ids.insert(target, ids.removeAt(index));
    state = _edited(state.copyWith(accounts: accounts, accountIds: ids));
  }

  void accountChanged(int index, TaxpayerBatchAccount account) {
    if (index < 0 || index >= state.accounts.length) return;
    state = _edited(
      state.copyWith(accounts: [...state.accounts]..[index] = account),
    );
  }

  Future<void> submit() async {
    if (state.mode == RecordFormMode.view || state.submitting) return;
    state = state.copyWith(submitted: true);
    if (state.clientErrors.isNotEmpty) return;
    final current = existing;
    final draft = _draft(current);
    state = _clearErrors(state).copyWith(submitting: true);
    final repository = ref.read(taxpayerBatchRepositoryProvider);
    try {
      if (current == null) {
        await repository.create(rfc, draft);
      } else {
        await repository.update(rfc, current.taxpayerBatchId, draft);
      }
      ref.invalidate(taxpayerBatchesControllerProvider(rfc));
      state = state.copyWith(submitting: false, done: true);
    } on AppError catch (e) {
      _fail(e, TaxpayerBatchDialogErrorCode.saveFailed);
    }
  }

  Future<void> delete() async {
    final current = existing;
    if (current == null || state.submitting) return;
    state = _clearErrors(state).copyWith(submitting: true);
    try {
      await ref
          .read(taxpayerBatchRepositoryProvider)
          .delete(rfc, current.taxpayerBatchId);
      ref.invalidate(taxpayerBatchesControllerProvider(rfc));
      state = state.copyWith(submitting: false, done: true);
    } on AppError catch (e) {
      _fail(e, TaxpayerBatchDialogErrorCode.deleteFailed);
    }
  }

  /// What is sent: a locked series sends its own series and kind back
  /// unchanged; blank accounts are dropped and the rest trimmed.
  TaxpayerBatchDraft _draft(TaxpayerBatch? current) {
    final locked = state.locked && current != null;
    return TaxpayerBatchDraft(
      series: locked ? current.series : state.series.trim(),
      kind: state.kind!,
      template: TaxpayerBatchTemplate(
        name: state.templateName.trim(),
        logo: state.logo.trim().isEmpty ? null : state.logo.trim(),
        headerHeight: parseTaxpayerBatchHeight(state.headerHeight)!,
        footerHeight: parseTaxpayerBatchHeight(state.footerHeight)!,
        accounts: [
          for (final a in state.accounts)
            if (!a.isBlank)
              TaxpayerBatchAccount(
                bank: a.bank.trim(),
                account: a.account.trim(),
                clabe: a.clabe.trim(),
                currency: a.currency.trim(),
              ),
        ],
      ),
    );
  }

  /// A change to [field] drops that field's server refusal and the banner,
  /// which no longer describe what is on screen.
  TaxpayerBatchDialogState _edited(
    TaxpayerBatchDialogState next, [
    String? field,
  ]) {
    final errors = {...next.serverErrors};
    if (field != null) errors.remove(field);
    return next.copyWith(error: null, errorCause: null, serverErrors: errors);
  }

  TaxpayerBatchDialogState _clearErrors(TaxpayerBatchDialogState s) =>
      s.copyWith(error: null, errorCause: null, serverErrors: const {});

  /// Turns a refusal into state. Recognised by the error's `code`, never by
  /// the server's prose (§III). The user's input is always kept.
  void _fail(AppError e, String headline) {
    final problem = e.problem;
    final code = problem?.code;
    final resource = problem?.stringParam('resource');

    if (code == api.ErrorCode.taxpayerBatchPeriodInUse) {
      // Another user used the series after the list loaded: lock series and
      // kind (reset to what is stored) and keep the template edits so they
      // can still be saved (research R6).
      final current = existing;
      ref.invalidate(taxpayerBatchesControllerProvider(rfc));
      state = state.copyWith(
        submitting: false,
        locked: true,
        series: current?.series ?? state.series,
        kind: current?.kind ?? state.kind,
        error: headline,
        errorCause: e,
        serverErrors: const {},
      );
      return;
    }
    if (code == api.ErrorCode.resourcePeriodAlreadyExists &&
        resource == 'taxpayer_batch') {
      state = state.copyWith(
        submitting: false,
        error: headline,
        errorCause: e,
        serverErrors: const {'batch': taxpayerBatchDuplicateSeries},
      );
      return;
    }
    if (code == api.ErrorCode.resourcePeriodNotFound &&
        resource == 'taxpayer_issuer') {
      state = state.copyWith(submitting: false, issuerGone: true);
      return;
    }
    if (e is NotFoundError) {
      // The series was removed by someone else: show what is there now.
      ref.invalidate(taxpayerBatchesControllerProvider(rfc));
      state = state.copyWith(submitting: false, error: headline, errorCause: e);
      return;
    }
    if (e is ValidationError && e.errors.isNotEmpty) {
      final errors = <String, String>{};
      for (final fieldError in e.errors) {
        final field = fieldError.loc.isEmpty ? null : fieldError.loc.last;
        if (field != null) errors[field] = serverFieldValue(fieldError);
      }
      state = state.copyWith(
        submitting: false,
        error: headline,
        errorCause: e,
        serverErrors: errors,
      );
      return;
    }
    state = state.copyWith(submitting: false, error: headline, errorCause: e);
  }
}
