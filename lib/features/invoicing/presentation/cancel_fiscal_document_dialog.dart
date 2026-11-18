import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/sat_cancellation_reason.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_candidate_picker.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Asks SAT, through the PAC, to cancel issued [document] (spec 072 C21): a
/// SAT reason, and for reason 01 the stamped document that replaces it. The
/// dialog's own text is the confirmation, so there is no second prompt.
///
/// `substitution_invalid`, `substitution_required` and
/// `unknown_cancellation_reason` stay inline so the choice can be fixed; any
/// other refusal (live receipts, a PAC rejection or timeout, ...) closes the
/// dialog and is answered to the caller, which shows it above its action
/// area. `null` when the user backed out.
Future<FiscalDocumentActionResult?> showCancelFiscalDocumentDialog(
  BuildContext context, {
  required FiscalDocument document,
}) => showResponsiveDialog<FiscalDocumentActionResult>(
  context,
  builder: (_) => _CancelFiscalDocumentDialog(document: document),
);

const _inlineCodes = {
  api.ErrorCode.fiscalDocumentPeriodSubstitutionInvalid,
  api.ErrorCode.fiscalDocumentPeriodSubstitutionRequired,
  api.ErrorCode.fiscalDocumentPeriodUnknownCancellationReason,
};

String _reasonLabel(AppLocalizations l10n, SatCancellationReason reason) =>
    '${reason.code} ${switch (reason) {
      SatCancellationReason.withRelation => l10n.fiscalDocumentCancelReason01,
      SatCancellationReason.withoutRelation => l10n.fiscalDocumentCancelReason02,
      SatCancellationReason.notCarriedOut => l10n.fiscalDocumentCancelReason03,
      SatCancellationReason.globalInvoiceNominative => l10n.fiscalDocumentCancelReason04,
    }}';

class _CancelFiscalDocumentDialog extends ConsumerStatefulWidget {
  const _CancelFiscalDocumentDialog({required this.document});

  final FiscalDocument document;

  @override
  ConsumerState<_CancelFiscalDocumentDialog> createState() =>
      _CancelFiscalDocumentDialogState();
}

class _CancelFiscalDocumentDialogState
    extends ConsumerState<_CancelFiscalDocumentDialog> {
  SatCancellationReason? _reason;
  FiscalDocumentSummary? _substitute;
  bool _busy = false;
  AppError? _refusal;

  FiscalDocument get _doc => widget.document;

  /// A reason is picked and, for 01, so is the replacement.
  bool get _valid =>
      _reason != null && (!_reason!.needsSubstitute || _substitute != null);

  void _pickReason(SatCancellationReason? reason) => setState(() {
    _reason = reason;
    _refusal = null;
    if (reason == null || !reason.needsSubstitute) _substitute = null;
  });

  void _pickSubstitute(FiscalDocumentSummary document) {
    // Only a stamped document can replace another, and its UUID is what goes
    // to SAT.
    if (document.stampUuid == null) return;
    setState(() {
      _substitute = document;
      _refusal = null;
    });
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (_busy || !_valid || reason == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .cancel(_doc.id, reason, substitution: _substitute?.stampUuid);
    if (!mounted) return;
    if (error != null && _inlineCodes.contains(error.problem?.code)) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final reason = _reason;
    final substitute = _substitute;

    return ResponsiveDialog(
      key: const Key('cancel_cfdi_dialog'),
      title: l10n.fiscalDocumentCancelTitle(
        _doc.summary.folioLabel ?? '#${_doc.id}',
      ),
      dismissible: !_busy,
      maxWidth: 720,
      hasUnsavedChanges: () => _reason != null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.fiscalDocumentCancelReasonLabel,
            style: theme.textTheme.labelLarge,
          ),
          RadioGroup<SatCancellationReason?>(
            groupValue: _reason,
            onChanged: _busy ? (_) {} : _pickReason,
            child: Column(
              children: [
                for (final r in SatCancellationReason.values)
                  RadioListTile<SatCancellationReason?>(
                    key: Key('cancel_cfdi_reason_${r.code}'),
                    value: r,
                    title: Text(_reasonLabel(l10n, r)),
                    enabled: !_busy,
                  ),
              ],
            ),
          ),
          if (reason != null && reason.needsSubstitute)
            Column(
              key: const Key('cancel_cfdi_substitute'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing.fieldGapVertical,
              children: [
                Text(
                  l10n.fiscalDocumentCancelSubstituteLabel,
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  l10n.fiscalDocumentCancelSubstituteHint,
                  style: theme.textTheme.bodySmall,
                ),
                if (substitute != null)
                  Row(
                    key: const Key('cancel_cfdi_substitute_selected'),
                    spacing: spacing.sm,
                    children: [
                      Expanded(
                        child: Text(
                          '${substitute.folioLabel ?? '#${substitute.id}'}'
                          ' · ${substitute.stampUuid}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        key: const Key('cancel_cfdi_substitute_change'),
                        onPressed: _busy
                            ? null
                            : () => setState(() => _substitute = null),
                        child: Text(l10n.fiscalDocumentCancelSubstituteChange),
                      ),
                    ],
                  )
                else
                  // The list API cannot filter by recipient, so the search
                  // starts as the recipient's RFC and the picker keeps only
                  // that recipient's issued documents (research R7).
                  FiscalDocumentCandidatePicker(
                    keyPrefix: 'cancel_cfdi_candidate',
                    issuerRfc: _doc.summary.issuerRfc,
                    status: FiscalDocumentStatus.issued,
                    excludeId: _doc.id,
                    initialSearch: _doc.summary.recipientRfc ?? '',
                    recipientRfc: _doc.summary.recipientRfc,
                    emptyMessage: l10n.fiscalDocumentCancelNoCandidates,
                    enabled: !_busy,
                    onPicked: _pickSubstitute,
                  ),
              ],
            ),
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
          Text(l10n.fiscalDocumentCancelNote, style: theme.textTheme.bodySmall),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('cancel_cfdi_back'),
        label: l10n.fiscalDocumentCancelBack,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('cancel_cfdi_submit'),
        label: l10n.fiscalDocumentCancelSubmit,
        busy: _busy,
        onPressed: _valid ? _submit : null,
      ),
    );
  }
}
