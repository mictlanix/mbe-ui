import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/below_minimum.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/request_minimum_band.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The prompts the request detail screen opens (spec 079 research R11,
// wireframes "Dialogs"). Each runs its own write through
// `PurchaseRequestActions`, which puts the returned request on screen. A
// refusal shows inside the dialog, localized from its code (§III), and keeps
// it open.

/// The refusal inside a dialog.
class _Refusal extends StatelessWidget {
  const _Refusal({required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) => ErrorBanner(
    key: const Key('purchase_request_dialog_refusal'),
    error: error,
  );
}

/// The busy flag, the refusal and the write every prompt here shares.
mixin _PromptState<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool busy = false;
  AppError? refusal;

  /// The refusal says the request changed meanwhile: the dialog then offers
  /// only "Cerrar".
  bool get stale {
    final error = refusal;
    return error != null && isStaleRefusal(error);
  }

  /// Runs [write]; pops `true` on success, else shows its refusal.
  Future<void> run(
    Future<AppError?> Function(PurchaseRequestActions actions) write,
  ) async {
    if (busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      busy = true;
      refusal = null;
    });
    final error = await write(
      ref.read(purchaseRequestActionsProvider.notifier),
    );
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      busy = false;
      refusal = error;
    });
  }
}

// ---------------------------------------------------------------------------
// Quitar partida
// ---------------------------------------------------------------------------

/// Asks before removing [line] from draft [requestId], then removes it.
/// `true` once removed.
Future<bool> showRemoveRequestLineDialog(
  BuildContext context, {
  required int requestId,
  required PurchaseRequestLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _RemoveLineDialog(requestId: requestId, line: line),
    ) ??
    false;

class _RemoveLineDialog extends ConsumerStatefulWidget {
  const _RemoveLineDialog({required this.requestId, required this.line});

  final int requestId;
  final PurchaseRequestLine line;

  @override
  ConsumerState<_RemoveLineDialog> createState() => _RemoveLineDialogState();
}

class _RemoveLineDialogState extends ConsumerState<_RemoveLineDialog>
    with _PromptState {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final line = widget.line;
    final code = line.productCode.isEmpty
        ? '#${line.productId}'
        : line.productCode;

    return ResponsiveDialog(
      key: const Key('purchase_request_line_remove_dialog'),
      title: l10n.purchaseRequestRemoveTitle,
      dismissible: !busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.purchaseRequestRemoveBody(code)),
          if (refusal != null) _Refusal(error: refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.purchaseRequestBack,
        onPressed: busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('purchase_request_line_remove_submit'),
        label: l10n.purchaseRequestRemoveAction,
        busy: busy,
        onPressed: () => run((a) => a.removeLine(widget.requestId, line.id)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Enviar solicitud
// ---------------------------------------------------------------------------

/// Explains what submitting [request] does, lists its lines below the
/// purchase minimum (never blocking, FR-013), then submits it. A request
/// without a folio gets one; a rejected draft keeps its own (US4). `true`
/// once submitted; a refusal (such as `purchase_request.no_lines`) shows
/// inside the dialog.
Future<bool> showSubmitRequestDialog(
  BuildContext context,
  PurchaseRequest request,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _SubmitDialog(request: request),
    ) ??
    false;

class _SubmitDialog extends ConsumerStatefulWidget {
  const _SubmitDialog({required this.request});

  final PurchaseRequest request;

  @override
  ConsumerState<_SubmitDialog> createState() => _SubmitDialogState();
}

class _SubmitDialogState extends ConsumerState<_SubmitDialog>
    with _PromptState {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final request = widget.request;
    final serial = request.serial;
    final below = belowMinimum(request.lines);

    return ResponsiveDialog(
      key: const Key('purchase_request_submit_dialog'),
      title: l10n.purchaseRequestSubmitTitle,
      dismissible: !busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            serial == null
                ? l10n.purchaseRequestSubmitFirstBody
                : l10n.purchaseRequestSubmitResubmitBody('$serial'),
            key: const Key('purchase_request_submit_body'),
          ),
          if (below.isNotEmpty)
            Column(
              key: const Key('purchase_request_submit_below_minimum'),
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xs,
              children: [
                Text(l10n.purchaseRequestSubmitBelowMinimum),
                for (final entry in below)
                  Text(belowMinimumText(l10n, fmt, entry)),
              ],
            ),
          if (refusal != null) _Refusal(error: refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.purchaseRequestBack,
        onPressed: busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('purchase_request_submit_submit'),
        label: l10n.purchaseRequestSubmit,
        busy: busy,
        onPressed: () => run((a) => a.submit(request.id)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aprobar / Rechazar (US2)
// ---------------------------------------------------------------------------

/// The request a decision prompt names. Both a queue row and the detail
/// carry these parts.
typedef RequestDecisionTarget = ({
  int id,
  int? serial,
  int? facilityId,
  int warehouseId,
  int lineCount,
});

/// The folio a prompt names: the serial, or "Borrador #{id}".
String _folio(AppLocalizations l10n, RequestDecisionTarget target) =>
    target.serial == null
    ? l10n.purchaseRequestDraftFolio('${target.id}')
    : '${target.serial}';

/// The primary and secondary buttons of a decision prompt: [label] runs
/// [onPressed]; after a stale refusal only "Cerrar" is left (research R13).
({ResponsiveDialogAction primary, ResponsiveDialogAction? secondary})
_decisionActions<T extends ConsumerStatefulWidget>(
  _PromptState<T> state, {
  required Key key,
  required String label,
  required VoidCallback? onPressed,
}) {
  final l10n = AppLocalizations.of(state.context)!;
  final navigator = Navigator.of(state.context);
  if (state.stale) {
    return (
      primary: ResponsiveDialogAction(
        key: const Key('purchase_request_dialog_close'),
        label: l10n.purchaseRequestResultClose,
        onPressed: () => navigator.pop(false),
      ),
      secondary: null,
    );
  }
  return (
    primary: ResponsiveDialogAction(
      key: key,
      label: label,
      busy: state.busy,
      onPressed: onPressed,
    ),
    secondary: ResponsiveDialogAction(
      label: l10n.purchaseRequestBack,
      onPressed: state.busy ? null : () => navigator.pop(false),
    ),
  );
}

/// "¿Aprobar solicitud {folio}?" with its facility, warehouse and line count,
/// then approves it (FR-021). `true` once approved; a refusal shows inside
/// the dialog.
Future<bool> showApproveRequestDialog(
  BuildContext context,
  RequestDecisionTarget target,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _ApproveDialog(target: target),
    ) ??
    false;

class _ApproveDialog extends ConsumerStatefulWidget {
  const _ApproveDialog({required this.target});

  final RequestDecisionTarget target;

  @override
  ConsumerState<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends ConsumerState<_ApproveDialog>
    with _PromptState {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final target = widget.target;
    final facilityId = target.facilityId;
    final facility = facilityId == null
        ? emptyValuePlaceholder
        : ref.watch(facilityDisplayNameProvider(facilityId)).value ??
              '#$facilityId';
    final warehouse =
        ref.watch(warehouseDisplayNameProvider(target.warehouseId)).value ??
        '#${target.warehouseId}';
    final actions = _decisionActions(
      this,
      key: const Key('purchase_request_approve_submit'),
      label: l10n.purchaseRequestApproveAction,
      onPressed: () => run((a) => a.approve(target.id)),
    );

    return ResponsiveDialog(
      key: const Key('purchase_request_approve_dialog'),
      title: l10n.purchaseRequestApproveTitle(_folio(l10n, target)),
      dismissible: !busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.purchaseRequestApproveSummary(
              facility,
              warehouse,
              fmt.display.count(target.lineCount),
            ),
            key: const Key('purchase_request_approve_summary'),
          ),
          if (refusal != null) _Refusal(error: refusal!),
        ],
      ),
      secondaryAction: actions.secondary,
      primaryAction: actions.primary,
    );
  }
}

/// "Rechazar solicitud {folio}": a required reason (trimmed, up to 500
/// characters) and the note that the request returns to draft keeping its
/// folio (FR-022, research R11). It doesn't promise the requester sees the
/// reason (mbe-api#352). `true` once rejected.
Future<bool> showRejectRequestDialog(
  BuildContext context,
  RequestDecisionTarget target,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _RejectDialog(target: target),
    ) ??
    false;

const _reasonMaxLength = 500;

class _RejectDialog extends ConsumerStatefulWidget {
  const _RejectDialog({required this.target});

  final RequestDecisionTarget target;

  @override
  ConsumerState<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends ConsumerState<_RejectDialog>
    with _PromptState {
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    // "Rechazar" follows the reason as it is typed.
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final target = widget.target;
    final reason = _reason.text.trim();
    final actions = _decisionActions(
      this,
      key: const Key('purchase_request_reject_submit'),
      label: l10n.purchaseRequestRejectAction,
      onPressed: reason.isEmpty
          ? null
          : () => run((a) => a.reject(target.id, reason: reason)),
    );

    return ResponsiveDialog(
      key: const Key('purchase_request_reject_dialog'),
      title: l10n.purchaseRequestRejectTitle(_folio(l10n, target)),
      dismissible: !busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          TextField(
            key: const Key('purchase_request_reject_reason'),
            controller: _reason,
            enabled: !busy && !stale,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            maxLength: _reasonMaxLength,
            decoration: InputDecoration(
              labelText: l10n.purchaseRequestFieldReason,
            ),
          ),
          Text(l10n.purchaseRequestRejectNote),
          if (refusal != null) _Refusal(error: refusal!),
        ],
      ),
      secondaryAction: actions.secondary,
      primaryAction: actions.primary,
    );
  }
}

// ---------------------------------------------------------------------------
// Cancelar solicitud (US6)
// ---------------------------------------------------------------------------

/// "Cancelar el borrador" for a draft, otherwise "Cancelar la solicitud
/// {folio}: queda cancelada y ya no se podrá usar", then cancels it (FR-018).
/// `true` once cancelled; a refusal (such as
/// `purchase_request.lines_on_live_order`) shows inside the dialog.
Future<bool> showCancelRequestDialog(
  BuildContext context,
  PurchaseRequest request,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _CancelDialog(request: request),
    ) ??
    false;

class _CancelDialog extends ConsumerStatefulWidget {
  const _CancelDialog({required this.request});

  final PurchaseRequest request;

  @override
  ConsumerState<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends ConsumerState<_CancelDialog>
    with _PromptState {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final request = widget.request;
    final serial = request.serial;
    final actions = _decisionActions(
      this,
      key: const Key('purchase_request_cancel_submit'),
      label: l10n.purchaseRequestCancelAction,
      onPressed: () => run((a) => a.cancel(request.id)),
    );

    return ResponsiveDialog(
      key: const Key('purchase_request_cancel_dialog'),
      title: l10n.purchaseRequestCancelTitle,
      dismissible: !busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            request.status == PurchaseRequestStatus.draft
                ? l10n.purchaseRequestCancelDraftBody
                : l10n.purchaseRequestCancelBody(
                    serial == null
                        ? l10n.purchaseRequestDraftFolio('${request.id}')
                        : '$serial',
                  ),
            key: const Key('purchase_request_cancel_body'),
          ),
          if (refusal != null) _Refusal(error: refusal!),
        ],
      ),
      secondaryAction: actions.secondary,
      primaryAction: actions.primary,
    );
  }
}
