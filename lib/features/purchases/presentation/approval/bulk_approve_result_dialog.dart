import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Resultado de la aprobación" (spec 079 FR-023, research R10): how many of
/// the selected requests were approved and, for each refused one, its folio,
/// its facility (folios repeat across facilities) and the reason, localized
/// from its code (§III).
///
/// [requests] are the summaries of the page the screen held before the call,
/// by id: the queue has reloaded by now and no longer holds the approved ones.
Future<void> showBulkApproveResultDialog(
  BuildContext context, {
  required List<BulkApproveOutcome> outcomes,
  required Map<int, PurchaseRequestSummary> requests,
}) => showResponsiveDialog<void>(
  context,
  builder: (_) =>
      _BulkApproveResultDialog(outcomes: outcomes, requests: requests),
);

class _BulkApproveResultDialog extends ConsumerWidget {
  const _BulkApproveResultDialog({
    required this.outcomes,
    required this.requests,
  });

  final List<BulkApproveOutcome> outcomes;
  final Map<int, PurchaseRequestSummary> requests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final approved = outcomes.where((o) => o.approved).length;
    final refused = outcomes.where((o) => !o.approved).toList();

    String folio(int id) {
      final serial = requests[id]?.serial;
      return serial == null ? l10n.purchaseRequestDraftFolio('$id') : '$serial';
    }

    String facility(int id) {
      final facilityId = requests[id]?.facilityId;
      if (facilityId == null) return emptyValuePlaceholder;
      return ref.watch(facilityDisplayNameProvider(facilityId)).value ??
          '#$facilityId';
    }

    String reason(BulkApproveOutcome outcome) {
      final problem = outcome.problem;
      return (problem == null ? null : localizeProblem(problem, l10n, fmt)) ??
          l10n.errorValidationGeneric;
    }

    return ResponsiveDialog(
      key: const Key('purchase_request_bulk_result_dialog'),
      title: l10n.purchaseRequestBulkResultTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.purchaseRequestBulkResultSummary(
              fmt.display.count(approved),
              fmt.display.count(outcomes.length),
            ),
            key: const Key('purchase_request_bulk_result_summary'),
          ),
          if (refused.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xs,
              children: [
                Text(l10n.purchaseRequestBulkResultRefused),
                for (final outcome in refused)
                  Text(
                    l10n.purchaseRequestBulkResultRefusedItem(
                      folio(outcome.requestId),
                      facility(outcome.requestId),
                      reason(outcome),
                    ),
                    key: Key(
                      'purchase_request_bulk_result_refused_'
                      '${outcome.requestId}',
                    ),
                  ),
              ],
            ),
        ],
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('purchase_request_bulk_result_close'),
        label: l10n.purchaseRequestResultClose,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
