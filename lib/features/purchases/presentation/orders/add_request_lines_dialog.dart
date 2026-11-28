import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Agregar partidas de una solicitud" (spec 080 FR-017, FR-018, research
/// R9): pick an approved request, anyone's, and add its pending lines to
/// draft [orderId]. On success the dialog closes and a SnackBar says how many
/// lines were added and, when some were already on another order, how many
/// were left out. Every refusal (`purchase_order.nothing_to_add`,
/// `purchase_order.request_not_approved`, ...) shows inline, localized from
/// its code, and keeps the dialog open.
///
/// Reachable only with PurchasesOrders (20) update and PurchaseRequest (86)
/// read; the detail screen gates its button.
Future<void> showAddRequestLinesDialog(
  BuildContext context, {
  required int orderId,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final result = await showResponsiveDialog<PurchaseOrderLinesAdded>(
    context,
    builder: (_) => _AddRequestLinesDialog(orderId: orderId),
  );
  if (result == null) return;
  final added = l10n.purchaseOrderAddRequestSnack(result.added);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        result.skipped > 0
            ? '$added${l10n.purchaseOrderLeftOutSnack(result.skipped)}'
            : added,
      ),
    ),
  );
}

class _AddRequestLinesDialog extends ConsumerStatefulWidget {
  const _AddRequestLinesDialog({required this.orderId});

  final int orderId;

  @override
  ConsumerState<_AddRequestLinesDialog> createState() =>
      _AddRequestLinesDialogState();
}

class _AddRequestLinesDialogState
    extends ConsumerState<_AddRequestLinesDialog> {
  PurchaseRequestSummary? _request;

  /// Each offered request's "{serial} · {facility} · {warehouse}", built when
  /// the options load: folios repeat across facilities, so the option names
  /// both (079 Open Question 10).
  final Map<int, String> _labels = {};
  bool _busy = false;
  AppError? _refusal;

  /// The names come from the cached per-id lookups; one that can't be read
  /// shows as `#id`.
  Future<String> _label(PurchaseRequestSummary r) async {
    final l10n = AppLocalizations.of(context)!;
    final facilityId = r.facilityId;
    final facility = facilityId == null
        ? null
        : await _name(facilityDisplayNameProvider(facilityId), facilityId);
    final warehouse = await _name(
      warehouseDisplayNameProvider(r.warehouseId),
      r.warehouseId,
    );
    return l10n.purchaseOrderRequestOption(
      '${r.serial ?? '#${r.id}'}',
      facility ?? emptyValuePlaceholder,
      warehouse,
    );
  }

  Future<String> _name(FutureProvider<String?> provider, int id) async {
    try {
      final String? name = await ref.read(provider.future);
      return name ?? '#$id';
    } catch (_) {
      return '#$id';
    }
  }

  Future<Iterable<PurchaseRequestSummary>> _options(String search) async {
    final page = await ref
        .read(purchaseRequestRepositoryProvider)
        .list(
          status: PurchaseRequestStatus.approved,
          all: true,
          serial: int.tryParse(search.trim()),
          skip: 0,
          limit: 10,
        );
    for (final r in page.items) {
      _labels[r.id] = await _label(r);
    }
    return page.items;
  }

  String _display(PurchaseRequestSummary r) =>
      _labels[r.id] ?? '${r.serial ?? '#${r.id}'}';

  Future<void> _add() async {
    final request = _request;
    if (_busy || request == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final result = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .addRequestLines(widget.orderId, requestId: request.id);
    if (!mounted) return;
    final error = result.error;
    if (error == null) {
      navigator.pop(result);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final request = _request;

    return ResponsiveDialog(
      key: const Key('add_request_lines_dialog'),
      title: l10n.purchaseOrderAddRequestTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _request != null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<PurchaseRequestSummary>(
            key: const Key('add_request_lines_request'),
            label: l10n.purchaseOrderFieldRequest,
            enabled: !_busy,
            autofocus: request == null,
            displayStringForOption: _display,
            optionsBuilder: _options,
            onSelected: (r) => setState(() {
              _request = r;
              _refusal = null;
            }),
            // Remounts on a pick, so the chosen request stays in the field.
            initialDisplayText: request == null ? null : _display(request),
          ),
          Text(
            l10n.purchaseOrderFieldRequestHelper,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('add_request_lines_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_request_lines_submit'),
        label: l10n.purchaseOrderAddAction,
        busy: _busy,
        onPressed: request == null ? null : _add,
      ),
    );
  }
}
