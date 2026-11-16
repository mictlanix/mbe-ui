import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design_theme_extensions.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/form_error_banner.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/features/catalog/presentation/fiscal_document_kind_label.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_batch_dialog_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the dialog of one series (spec 065): adds a series when [existing]
/// is `null`; otherwise shows it read-only, or editable when [startInEdit].
/// A read-only series offers an Editar toggle that switches in place, when
/// the user may update and the issuer screen is editable ([parentReadOnly]
/// false). Saving or deleting closes the dialog after refreshing the
/// issuer's series list itself.
///
/// The dialog is the record's own surface (constitution §VI): Eliminar lives
/// in its body, behind a confirmation, and only for an unused series the
/// user may delete.
Future<void> showTaxpayerBatchDialog(
  BuildContext context, {
  required String rfc,
  TaxpayerBatch? existing,
  bool startInEdit = false,
  required bool parentReadOnly,
}) {
  final mode = existing == null
      ? RecordFormMode.create
      : (startInEdit ? RecordFormMode.edit : RecordFormMode.view);
  return showDialog<void>(
    context: context,
    builder: (_) => _TaxpayerBatchDialog(
      rfc: rfc,
      existing: existing,
      startMode: mode,
      parentReadOnly: parentReadOnly,
    ),
  );
}

class _TaxpayerBatchDialog extends ConsumerWidget {
  const _TaxpayerBatchDialog({
    required this.rfc,
    required this.existing,
    required this.startMode,
    required this.parentReadOnly,
  });

  final String rfc;
  final TaxpayerBatch? existing;
  final RecordFormMode startMode;
  final bool parentReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = taxpayerBatchDialogControllerProvider(
      rfc,
      existing,
      startMode,
    );
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final access = ref.watch(accessControlProvider);
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final current = existing;

    if (state.done || state.issuerGone) {
      final router = GoRouter.maybeOf(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        // The issuer is gone: back to the issuer list (research R8).
        if (state.issuerGone) router?.go('/taxpayer-issuers');
      });
    }

    final viewOnly = state.mode == RecordFormMode.view;
    final canEdit =
        !parentReadOnly &&
        access.can(SystemObject.taxpayers, AccessRight.update);
    final canDelete =
        state.mode == RecordFormMode.edit &&
        current != null &&
        !state.locked &&
        access.can(SystemObject.taxpayers, AccessRight.delete);

    final title = switch (state.mode) {
      RecordFormMode.create => l10n.taxpayerBatchDialogCreateTitle,
      RecordFormMode.view => l10n.taxpayerBatchDialogViewTitle,
      RecordFormMode.edit => l10n.taxpayerBatchDialogEditTitle,
    };

    final ResponsiveDialogAction primary;
    ResponsiveDialogAction? secondary;
    if (viewOnly) {
      // A reader (or a View render of the issuer) only closes; an updater
      // switches to the editable form in place (constitution §VI).
      if (canEdit) {
        primary = ResponsiveDialogAction(
          key: const Key('taxpayer_batch_edit_button'),
          label: l10n.editButton,
          onPressed: controller.switchToEdit,
        );
        secondary = ResponsiveDialogAction(
          key: const Key('taxpayer_batch_close_button'),
          label: l10n.taxpayerBatchCloseButton,
          onPressed: () => Navigator.of(context).pop(),
        );
      } else {
        primary = ResponsiveDialogAction(
          key: const Key('taxpayer_batch_close_button'),
          label: l10n.taxpayerBatchCloseButton,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
    } else {
      primary = ResponsiveDialogAction(
        key: const Key('taxpayer_batch_save_button'),
        label: l10n.saveButton,
        busy: state.submitting,
        onPressed: state.submitting ? null : controller.submit,
      );
      secondary = ResponsiveDialogAction(
        key: const Key('taxpayer_batch_cancel_button'),
        label: l10n.cancelButton,
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return ResponsiveDialog(
      title: title,
      dismissible: !state.submitting,
      primaryAction: primary,
      secondaryAction: secondary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Outside the grid: inserting a child there would shift the
          // fields' positions and drop what the user entered.
          if (state.error != null) ...[
            FormErrorBanner(
              key: const Key('taxpayer_batch_error_banner'),
              headline: _errorHeadline(l10n, state.error!),
              cause: state.errorCause,
            ),
            SizedBox(height: spacing.md),
          ],
          if (state.locked) ...[
            _LockNote(l10n.taxpayerBatchInUseNote),
            SizedBox(height: spacing.md),
          ],
          _BatchFields(
            state: state,
            controller: controller,
            viewOnly: viewOnly,
          ),
          SizedBox(height: spacing.md),
          const Divider(),
          SizedBox(height: spacing.sm),
          _AccountsGroup(
            state: state,
            controller: controller,
            viewOnly: viewOnly,
          ),
          if (canDelete) ...[
            SizedBox(height: spacing.lg),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton(
                key: const Key('taxpayer_batch_delete_button'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                onPressed: state.submitting
                    ? null
                    : () async {
                        final kind = current.kind;
                        final confirmed = await showRecordDeleteConfirmation(
                          context,
                          RecordDeleteConfirmation(
                            title: l10n.taxpayerBatchDeleteTitle,
                            message: l10n.taxpayerBatchDeleteMessage(
                              current.series,
                              kind == null
                                  ? l10n.fiscalDocumentKindUnknown(
                                      current.typeCode,
                                    )
                                  : fiscalDocumentKindLabel(l10n, kind),
                            ),
                            confirmLabel: l10n.deleteButton,
                            cancelLabel: l10n.cancelButton,
                            confirmKey: const Key(
                              'confirm_delete_taxpayer_batch_button',
                            ),
                          ),
                        );
                        if (confirmed == true) controller.delete();
                      },
                child: Text(l10n.deleteButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _errorHeadline(AppLocalizations l10n, String code) => switch (code) {
  TaxpayerBatchDialogErrorCode.deleteFailed => l10n.taxpayerBatchDeleteFailed,
  _ => l10n.taxpayerBatchSaveFailed,
};

/// The note that says why series and type can't change.
class _LockNote extends StatelessWidget {
  const _LockNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      key: const Key('taxpayer_batch_in_use_note'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: theme.spacing.xs),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// The text a field shows for a refusal: the form's own rule on its first
/// save attempt, else what the server refused.
String? _fieldError(
  AppLocalizations l10n,
  TaxpayerBatchDialogState state,
  String field,
) {
  if (state.submitted) {
    final code = state.clientErrors[field];
    if (code != null) return _clientMessage(l10n, field, code);
  }
  final server = state.serverErrors[field];
  if (server == null) return null;
  if (server == taxpayerBatchDuplicateSeries) {
    return l10n.apiErrorResourceAlreadyExists(
      resourceGender('taxpayer_batch', l10n),
      resourceNoun('taxpayer_batch', l10n),
    );
  }
  return localizeValidationType(server, l10n) ?? server;
}

String _clientMessage(AppLocalizations l10n, String field, String code) =>
    switch ((field, code)) {
      ('batch', TaxpayerBatchFieldError.tooLong) =>
        l10n.taxpayerBatchSeriesTooLongError,
      ('batch', _) => l10n.taxpayerBatchSeriesRequiredError,
      ('type', _) => l10n.taxpayerBatchTypeRequiredError,
      ('name', TaxpayerBatchFieldError.tooLong) =>
        l10n.taxpayerBatchTemplateNameTooLongError,
      ('name', _) => l10n.taxpayerBatchTemplateNameRequiredError,
      _ => l10n.taxpayerBatchHeightInvalidError,
    };

class _BatchFields extends StatelessWidget {
  const _BatchFields({
    required this.state,
    required this.controller,
    required this.viewOnly,
  });

  final TaxpayerBatchDialogState state;
  final TaxpayerBatchDialogController controller;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final enabled = !state.submitting;
    // Series and type are greyed while locked, and the keyed subtree
    // rebuilds them when the lock resets them to the stored values.
    final identityEnabled = enabled && !state.locked;

    return ResponsiveFormGrid(
      maxColumns: 2,
      spacing: spacing.md,
      children: [
        FormGridChild(
          KeyedSubtree(
            key: ValueKey('series-${state.locked}'),
            child: TextFormField(
              key: const Key('taxpayer_batch_series_field'),
              initialValue: state.series,
              enabled: identityEnabled,
              readOnly: viewOnly,
              decoration: InputDecoration(
                labelText: l10n.taxpayerBatchSeriesLabel,
                errorText: _fieldError(l10n, state, 'batch'),
              ),
              onChanged: controller.seriesChanged,
            ),
          ),
        ),
        FormGridChild(
          KeyedSubtree(
            key: ValueKey('type-${state.locked}'),
            child: DropdownButtonFormField<FiscalDocumentKind>(
              key: const Key('taxpayer_batch_type_field'),
              isExpanded: true,
              initialValue: state.kind,
              decoration: InputDecoration(
                labelText: l10n.taxpayerBatchTypeLabel,
                errorText: _fieldError(l10n, state, 'type'),
              ),
              items: [
                for (final kind in FiscalDocumentKind.values)
                  DropdownMenuItem(
                    value: kind,
                    child: Text(fiscalDocumentKindLabel(l10n, kind)),
                  ),
              ],
              onChanged: identityEnabled && !viewOnly
                  ? controller.kindChanged
                  : null,
            ),
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('taxpayer_batch_template_name_field'),
            initialValue: state.templateName,
            enabled: enabled,
            readOnly: viewOnly,
            decoration: InputDecoration(
              labelText: l10n.taxpayerBatchTemplateNameLabel,
              errorText: _fieldError(l10n, state, 'name'),
            ),
            onChanged: controller.templateNameChanged,
          ),
          span: FormGridSpan.full,
        ),
        FormGridChild(
          TextFormField(
            key: const Key('taxpayer_batch_logo_field'),
            initialValue: state.logo,
            enabled: enabled,
            readOnly: viewOnly,
            decoration: InputDecoration(
              labelText: l10n.taxpayerBatchLogoLabel,
              errorText: _fieldError(l10n, state, 'logo'),
            ),
            onChanged: controller.logoChanged,
          ),
          span: FormGridSpan.full,
        ),
        FormGridChild(
          TextFormField(
            key: const Key('taxpayer_batch_header_height_field'),
            initialValue: state.headerHeight,
            enabled: enabled,
            readOnly: viewOnly,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.taxpayerBatchHeaderHeightLabel,
              errorText: _fieldError(l10n, state, 'header_height'),
            ),
            onChanged: controller.headerHeightChanged,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('taxpayer_batch_footer_height_field'),
            initialValue: state.footerHeight,
            enabled: enabled,
            readOnly: viewOnly,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.taxpayerBatchFooterHeightLabel,
              errorText: _fieldError(l10n, state, 'footer_height'),
            ),
            onChanged: controller.footerHeightChanged,
          ),
        ),
      ],
    );
  }
}

/// The "Cuentas bancarias" group: a one-line list when read-only, an editor
/// of ordered rows otherwise (FR-007).
class _AccountsGroup extends StatelessWidget {
  const _AccountsGroup({
    required this.state,
    required this.controller,
    required this.viewOnly,
  });

  final TaxpayerBatchDialogState state;
  final TaxpayerBatchDialogController controller;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final enabled = !state.submitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.taxpayerBatchAccountsTitle,
          style: theme.textTheme.titleSmall,
        ),
        SizedBox(height: spacing.xs),
        if (viewOnly)
          ..._summaries(context, l10n, theme)
        else
          ..._editor(l10n, enabled),
      ],
    );
  }

  /// The read-only list: one line per filled account, or a note when none.
  List<Widget> _summaries(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final filled = [
      for (final (i, a) in state.accounts.indexed)
        if (!a.isBlank) (i, a),
    ];
    if (filled.isEmpty) {
      return [
        Text(
          l10n.taxpayerBatchNoAccounts,
          key: const Key('taxpayer_batch_no_accounts'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ];
    }
    return [
      for (final (i, a) in filled)
        Padding(
          padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
          child: Text(
            _accountSummary(l10n, a),
            key: Key('taxpayer_batch_account_summary_$i'),
          ),
        ),
    ];
  }

  /// The editor: the ordered rows and the button that adds one.
  List<Widget> _editor(AppLocalizations l10n, bool enabled) {
    return [
      for (final (i, a) in state.accounts.indexed)
        _AccountRow(
          key: ValueKey('taxpayer_batch_account_row_${state.accountIds[i]}'),
          index: i,
          account: a,
          isFirst: i == 0,
          isLast: i == state.accounts.length - 1,
          enabled: enabled,
          controller: controller,
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: const Key('add_taxpayer_batch_account_button'),
          icon: Icon(CatalogAction.create.icon),
          label: Text(l10n.taxpayerBatchAddAccount),
          onPressed: enabled ? controller.accountAdded : null,
        ),
      ),
    ];
  }
}

/// One account on a single line: the filled fields, joined.
String _accountSummary(AppLocalizations l10n, TaxpayerBatchAccount a) {
  final parts = [
    if (a.bank.trim().isNotEmpty) a.bank.trim(),
    if (a.account.trim().isNotEmpty) a.account.trim(),
    if (a.clabe.trim().isNotEmpty)
      '${l10n.taxpayerBatchAccountClabe} ${a.clabe.trim()}',
    if (a.currency.trim().isNotEmpty) a.currency.trim(),
  ];
  return parts.join(' · ');
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    super.key,
    required this.index,
    required this.account,
    required this.isFirst,
    required this.isLast,
    required this.enabled,
    required this.controller,
  });

  final int index;
  final TaxpayerBatchAccount account;
  final bool isFirst;
  final bool isLast;
  final bool enabled;
  final TaxpayerBatchDialogController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    Widget field(
      String name,
      String label,
      String value,
      TaxpayerBatchAccount Function(String) update,
    ) => TextFormField(
      key: Key('taxpayer_batch_account_${name}_$index'),
      initialValue: value,
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
      onChanged: (text) => controller.accountChanged(index, update(text)),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveFormGrid(
            maxColumns: 2,
            spacing: spacing.sm,
            children: [
              FormGridChild(
                field(
                  'bank',
                  l10n.taxpayerBatchAccountBank,
                  account.bank,
                  (t) => account.copyWith(bank: t),
                ),
              ),
              FormGridChild(
                field(
                  'number',
                  l10n.taxpayerBatchAccountNumber,
                  account.account,
                  (t) => account.copyWith(account: t),
                ),
              ),
              FormGridChild(
                field(
                  'clabe',
                  l10n.taxpayerBatchAccountClabe,
                  account.clabe,
                  (t) => account.copyWith(clabe: t),
                ),
              ),
              FormGridChild(
                field(
                  'currency',
                  l10n.taxpayerBatchAccountCurrency,
                  account.currency,
                  (t) => account.copyWith(currency: t),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isFirst)
                IconButton(
                  key: Key('move_account_up_$index'),
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: l10n.taxpayerBatchMoveAccountUp,
                  visualDensity: VisualDensity.compact,
                  onPressed: enabled
                      ? () => controller.accountMoved(index, -1)
                      : null,
                ),
              if (!isLast)
                IconButton(
                  key: Key('move_account_down_$index'),
                  icon: const Icon(Icons.arrow_downward),
                  tooltip: l10n.taxpayerBatchMoveAccountDown,
                  visualDensity: VisualDensity.compact,
                  onPressed: enabled
                      ? () => controller.accountMoved(index, 1)
                      : null,
                ),
              IconButton(
                key: Key('remove_account_$index'),
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.taxpayerBatchRemoveAccount,
                visualDensity: VisualDensity.compact,
                onPressed: enabled
                    ? () => controller.accountRemoved(index)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
