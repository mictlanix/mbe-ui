import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest note a request takes.
const _commentMaxLength = 500;

/// "Editar encabezado" (spec 079 US4, FR-007, FR-008, research R6 and R8):
/// change draft [request]'s warehouse or notes. `true` once saved; every
/// refusal (such as `purchase_request.facility_locked`) stays inline and keeps
/// the dialog open.
///
/// Only the changed fields are sent; clearing the notes is sent as
/// `clearComment` (research R8). The detail screen gates the button on
/// PurchaseRequest (86) update, Warehouses (4) read, a draft and an own
/// facility.
Future<bool> showRequestHeaderDialog(
  BuildContext context,
  PurchaseRequest request,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _HeaderDialog(request: request),
    ) ??
    false;

class _HeaderDialog extends ConsumerStatefulWidget {
  const _HeaderDialog({required this.request});

  final PurchaseRequest request;

  @override
  ConsumerState<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends ConsumerState<_HeaderDialog> {
  late final String _initialComment = widget.request.comment ?? '';
  late final _comment = TextEditingController(text: _initialComment);

  /// The warehouse the user picked; `null` keeps the request's.
  Warehouse? _picked;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// The new warehouse, when it differs from the request's.
  int? get _warehouseChange {
    final picked = _picked?.warehouseId;
    return picked == null || picked == widget.request.warehouseId
        ? null
        : picked;
  }

  bool get _commentChanged => _comment.text.trim() != _initialComment.trim();

  bool _hasUnsavedChanges() => _warehouseChange != null || _commentChanged;

  bool get _canSave =>
      !_busy &&
      _hasUnsavedChanges() &&
      _comment.text.trim().length <= _commentMaxLength;

  Future<void> _save() async {
    if (!_canSave) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final comment = _comment.text.trim();
    final error = await ref
        .read(purchaseRequestActionsProvider.notifier)
        .updateHeader(
          widget.request.id,
          warehouseId: _warehouseChange,
          comment: _commentChanged && comment.isNotEmpty ? comment : null,
          clearComment: _commentChanged && comment.isEmpty,
        );
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
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
    final commentLength = _comment.text.trim().length;
    final commentTooLong = commentLength > _commentMaxLength;
    final spacing = Theme.of(context).spacing;
    final request = widget.request;
    final facilityId = request.facilityId;
    // A request with a folio keeps its facility (FR-008): say so under the
    // picker rather than let the server refuse it.
    final facilityName = request.serial == null || facilityId == null
        ? null
        : ref.watch(facilityDisplayNameProvider(facilityId)).value ??
              '#$facilityId';

    return ResponsiveDialog(
      key: const Key('purchase_request_header_dialog'),
      title: l10n.purchaseRequestEditHeaderTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          _WarehousePicker(
            request: request,
            picked: _picked,
            enabled: !_busy,
            onSelected: (w) => setState(() {
              _picked = w;
              _refusal = null;
            }),
          ),
          if (facilityName != null)
            Text(
              l10n.purchaseRequestWarehouseFacilityHelper(facilityName),
              key: const Key('purchase_request_header_facility_helper'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          TextField(
            key: const Key('purchase_request_header_comment'),
            controller: _comment,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            // Over-long text stays visible with the counter in error, rather
            // than being cut silently, and "Guardar" stays disabled. The
            // counter counts the trimmed text, which is what is sent.
            decoration: InputDecoration(
              labelText: l10n.purchaseRequestFieldComment,
              counterText: '$commentLength/$_commentMaxLength',
              errorText: commentTooLong ? '' : null,
              counterStyle: commentTooLong
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('purchase_request_header_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('purchase_request_header_submit'),
        label: l10n.purchaseRequestSaveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}

/// The warehouse picker over the user's own-facility warehouses (an
/// administrator's: every one), starting on the request's.
class _WarehousePicker extends ConsumerWidget {
  const _WarehousePicker({
    required this.request,
    required this.picked,
    required this.enabled,
    required this.onSelected,
  });

  final PurchaseRequest request;
  final Warehouse? picked;
  final bool enabled;
  final ValueChanged<Warehouse> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scope = ref.watch(inventoryWarehouseScopeProvider);
    final current =
        ref.watch(warehouseDisplayNameProvider(request.warehouseId)).value ??
        '#${request.warehouseId}';
    return CatalogEntityPicker<Warehouse>(
      key: const Key('purchase_request_header_warehouse'),
      label: l10n.purchaseRequestFieldWarehouse,
      enabled: enabled,
      displayStringForOption: (w) => w.name,
      optionSubtitle: (w) => w.facilityName,
      optionsBuilder: (search) => inventoryWarehouseOptions(
        ref.read(warehouseRepositoryProvider),
        scope,
        search,
      ),
      onSelected: onSelected,
      // The pick, once there is one: the current name may resolve after it
      // and must not replace it.
      initialDisplayText: picked?.name ?? current,
    );
  }
}
