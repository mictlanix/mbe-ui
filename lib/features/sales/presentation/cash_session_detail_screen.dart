import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/presentation/cash_session_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/close_session_form_controller.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/cash_session_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/denomination_count_table.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The session summary + count/close screen (contracts/cash-session-screens.md
/// §2). No `forceReadOnly` param, unlike every other detail route — a
/// session has no editable form, so there is no read-only/edit distinction
/// to toggle.
class CashSessionDetailScreen extends ConsumerWidget {
  const CashSessionDetailScreen({super.key, required this.cashSessionId});

  final int cashSessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessionAsync = ref.watch(
      cashSessionDetailControllerProvider(cashSessionId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cashSessionViewTitle)),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorBanner(error: toAppError(error)),
        ),
        data: (session) => _DetailBody(session: session),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.session});

  final CashSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final status = cashSessionStatusOf(session, today: DateTime.now());
    final access = ref.watch(accessControlProvider);
    final canClose = access.can(SystemObject.cashSessionClose, AccessRight.update);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Uniform 24px gap, present only when the conditional block below
        // actually renders something (spec 028 US2 collection-if case).
        spacing: 24,
        children: [
          ResponsiveFormGrid(
            maxColumns: 2,
            children: [
              FormGridChild(
                span: FormGridSpan.full,
                CashSessionStatusChip(status: status),
              ),
              FormGridChild(
                _LabeledText(l10n.cashSessionDrawerFieldLabel, session.cashDrawerName),
              ),
              FormGridChild(
                _LabeledText(l10n.cashSessionCashierFieldLabel, session.cashierName),
              ),
              FormGridChild(
                _LabeledText(
                  l10n.cashSessionStartFieldLabel,
                  fmt.display.dateTime(session.start),
                ),
              ),
              if (session.end != null)
                FormGridChild(
                  _LabeledText(
                    l10n.cashSessionEndFieldLabel,
                    fmt.display.dateTime(session.end),
                  ),
                ),
              if (session.cashSupervisorName != null)
                FormGridChild(
                  _LabeledText(
                    l10n.cashSessionClosedByFieldLabel,
                    session.cashSupervisorName!,
                  ),
                ),
              FormGridChild(
                _LabeledText(
                  l10n.cashSessionOpeningAmountFieldLabel,
                  fmt.display.currency(session.openingAmount),
                ),
              ),
              FormGridChild(
                span: FormGridSpan.full,
                _PaymentsByMethodSection(session: session),
              ),
            ],
          ),
          if (status != CashSessionStatus.closed)
            if (canClose)
              _CloseSection(session: session)
            else
              Text(
                l10n.cashSessionSupervisorRequiredMessage,
                key: const Key('cash_session_supervisor_required_message'),
              ),
        ],
      ),
    );
  }
}

class _LabeledText extends StatelessWidget {
  const _LabeledText(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value),
      ],
    );
  }
}

class _PaymentsByMethodSection extends ConsumerWidget {
  const _PaymentsByMethodSection({required this.session});

  final CashSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cashSessionPaymentsByMethodLabel, style: Theme.of(context).textTheme.titleSmall),
        for (final total in session.paymentsByMethod)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: Text(paymentMethodLabel(l10n, total.method))),
                Text(fmt.display.currency(total.total)),
              ],
            ),
          ),
      ],
    );
  }
}

class _CloseSection extends ConsumerWidget {
  const _CloseSection({required this.session});

  final CashSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final formState = ref.watch(closeSessionFormControllerProvider);
    final controller = ref.read(closeSessionFormControllerProvider.notifier);

    // Seeded from inside this build(), which is what watches the provider —
    // seeding from a StatefulWidget's initState risks the seed landing on a
    // transient, zero-listener autoDispose instance that gets disposed
    // before this widget ever mounts (research.md §19). Guarded by
    // `cashSessionId == null` so it never re-fires once loaded.
    if (formState.cashSessionId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadSession(session));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (formState.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ErrorBanner(
              error: AppError.validation([
                FieldError(
                  loc: const [],
                  msg: _localizeCloseFormError(l10n, formState.error!),
                  type: 'error',
                ),
                if (formState.errorDetail != null)
                  FieldError(loc: const [], msg: formState.errorDetail!, type: 'error'),
              ]),
            ),
          ),
        DenominationCountTable(
          quantities: formState.quantities,
          onQuantityChanged: controller.quantityChanged,
          enabled: !formState.submitting,
        ),
        const SizedBox(height: 16),
        _TotalsRow(
          label: l10n.cashSessionCountedTotalLabel,
          value: fmt.display.currency(formState.countedTotal),
        ),
        _TotalsRow(
          label: l10n.cashSessionExpectedCashLabel,
          value: fmt.display.currency(formState.expectedCash),
        ),
        _TotalsRow(
          label: l10n.cashSessionDifferenceLabel,
          value: _differenceDisplay(l10n, formState.difference, fmt),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.cashSessionAdvisoryNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('cash_session_close_button'),
          onPressed: formState.submitting
              ? null
              : () => _handleClose(context, ref, l10n, fmt),
          child: Text(l10n.cashSessionCloseButtonLabel),
        ),
      ],
    );
  }

  Future<void> _handleClose(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AppFormatters fmt,
  ) async {
    final controller = ref.read(closeSessionFormControllerProvider.notifier);
    final quantities = ref.read(closeSessionFormControllerProvider).quantities;
    final allZero = quantities.values.every((q) => q == 0);

    if (allZero) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.cashSessionEmptyCountConfirmTitle),
          content: Text(l10n.cashSessionEmptyCountConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              key: const Key('cash_session_confirm_empty_count_button'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.cashSessionConfirmEmptyCountButton),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await controller.submit();
    if (!context.mounted) return;

    final state = ref.read(closeSessionFormControllerProvider);
    if (!state.closed) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cashSessionCloseSuccessTitle),
        content: Text(
          l10n.cashSessionCloseSuccessMessage(
            fmt.display.currency(state.countedTotal),
            fmt.display.currency(state.expectedCash),
            fmt.display.currency(state.difference),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.okButton),
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

String _localizeCloseFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case CloseSessionFormErrorCode.quantityInvalid:
      return l10n.cashSessionQuantityInvalidError;
    case CloseSessionFormErrorCode.alreadyClosed:
      return l10n.cashSessionAlreadyClosedError;
    case CloseSessionFormErrorCode.sessionNotFound:
      return l10n.cashSessionSessionNotFoundError;
    case CloseSessionFormErrorCode.closePermissionDenied:
      return l10n.cashSessionClosePermissionDeniedError;
    case CloseSessionFormErrorCode.closeFailed:
      return l10n.cashSessionCloseFailedError;
    default:
      return code;
  }
}

String _differenceDisplay(AppLocalizations l10n, String difference, AppFormatters fmt) {
  final amount = num.tryParse(difference) ?? 0;
  final formatted = fmt.display.currency(difference);
  if (amount > 0) return '$formatted (${l10n.cashSessionDifferenceOver})';
  if (amount < 0) return '$formatted (${l10n.cashSessionDifferenceShort})';
  return '$formatted (${l10n.cashSessionDifferenceZero})';
}
