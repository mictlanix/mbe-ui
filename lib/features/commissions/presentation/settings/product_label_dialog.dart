import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/info_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/product_labels_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_label_dropdown.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Etiqueta de comisión": gives a product a label (spec 078 FR-016). With
/// [existing] the product is fixed and the label changes, and "Quitar
/// etiqueta" removes it; without it any product can be picked, since the list
/// only holds labelled ones. Assigning is a PUT (Update, the caller's gate);
/// removing is a DELETE and needs Delete.
Future<void> showCommissionProductLabelDialog(
  BuildContext context, {
  CommissionProductLabel? existing,
}) => showResponsiveDialog<void>(
  context,
  builder: (_) => _ProductLabelDialog(existing: existing),
);

class _ProductLabelDialog extends ConsumerStatefulWidget {
  const _ProductLabelDialog({this.existing});

  final CommissionProductLabel? existing;

  @override
  ConsumerState<_ProductLabelDialog> createState() =>
      _ProductLabelDialogState();
}

class _ProductLabelDialogState extends ConsumerState<_ProductLabelDialog> {
  ProductListItem? _product;
  int? _labelId;
  bool _busy = false;
  AppError? _refusal;

  @override
  void initState() {
    super.initState();
    _labelId = widget.existing?.labelId;
  }

  int? get _productId => widget.existing?.productId ?? _product?.productId;

  bool get _complete => _productId != null && _labelId != null;

  Future<void> _run(Future<AppError?> Function() write) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await write();
    if (!mounted) return;
    if (error == null) {
      navigator.pop();
    } else {
      setState(() {
        _busy = false;
        _refusal = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final existing = widget.existing;
    // Commissions (112) Delete: "Quitar etiqueta" is a DELETE.
    final canRemove =
        existing != null &&
        ref
            .watch(accessControlProvider)
            .can(SystemObject.commissionsBySalesPerson, AccessRight.delete);
    final controller = ref.read(productLabelsControllerProvider.notifier);

    return ResponsiveDialog(
      key: const Key('commission_product_label_dialog'),
      title: l10n.commissionProductLabelTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (_refusal != null) ErrorBanner(error: _refusal!),
          CatalogEntityPicker<ProductListItem>(
            key: const Key('commission_product_label_product'),
            label: l10n.commissionProductLabelProduct,
            enabled: existing == null && !_busy,
            displayStringForOption: (p) => p.name,
            initialDisplayText: existing == null
                ? _product?.name
                : '${existing.productCode} · ${existing.productName}',
            optionsBuilder: (query) async {
              final trimmed = query.trim();
              if (trimmed.isEmpty) return const [];
              final result = await ref
                  .read(productRepositoryProvider)
                  .list(
                    search: trimmed,
                    status: EntityStatus.active,
                    limit: 10,
                  );
              return result.items;
            },
            onSelected: (p) => setState(() {
              _product = p;
              _refusal = null;
            }),
            optionImageUrl: (p) => p.photo,
            optionSubtitle: (p) => p.code,
          ),
          CommissionLabelDropdown(
            key: const Key('commission_product_label_label'),
            label: l10n.commissionProductLabelLabel,
            value: _labelId,
            enabled: !_busy,
            onChanged: (id) => setState(() {
              _labelId = id;
              _refusal = null;
            }),
          ),
          InfoBanner(
            key: const Key('commission_product_label_note'),
            message: l10n.commissionSettingsNote,
          ),
          if (canRemove)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('commission_product_label_remove'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: _busy
                    ? null
                    : () => _run(() => controller.remove(existing.productId)),
                child: Text(l10n.commissionRemoveLabelAction),
              ),
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('commission_product_label_cancel'),
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('commission_product_label_submit'),
        label: l10n.commissionProductLabelAssign,
        busy: _busy,
        onPressed: _complete
            ? () => _run(() => controller.set(_productId!, _labelId!))
            : null,
      ),
    );
  }
}
