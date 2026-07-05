import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/label_multi_picker.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/product_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single product (FR-003..FR-009,
/// FR-013, FR-014, FR-015). [productId] is `null` in create mode.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({
    super.key,
    this.productId,
    this.forceReadOnly = false,
  });

  final int? productId;

  /// Forces read-only rendering regardless of update permission — set when
  /// navigated to via the View row action rather than Edit (FR-006,
  /// research.md §5), read from the `?view=true` query parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      // Load after the first frame so the provider is already mounted.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(productFormControllerProvider.notifier)
            .loadForEdit(widget.productId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormControllerProvider);
    final controller = ref.read(productFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.products, AccessRight.create);
    final l10n = AppLocalizations.of(context)!;
    final allLabels = ref.watch(allLabelsProvider).valueOrNull ?? <LabelItem>[];
    final satRepo = ref.read(satCatalogRepositoryProvider);
    final supplierRepo = ref.read(supplierRepositoryProvider);

    if (formState.loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? l10n.editProductTitle : l10n.newProductTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (formState.saved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    }

    final canUpdate = access.can(SystemObject.products, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final fieldsEnabled = !formState.submitting && !readOnly;
    final canSave = !widget.forceReadOnly && (_isEdit ? canUpdate : canCreate);
    final canDeactivate =
        !widget.forceReadOnly &&
        _isEdit &&
        !formState.deactivated &&
        access.can(SystemObject.products, AccessRight.delete);
    final canEditPhoto = canSave;
    final hasPhoto =
        formState.pendingPhotoBytes != null ||
        (formState.photo != null && !formState.photoMarkedForRemoval);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editProductTitle : l10n.newProductTitle),
        actions: [
          if (canDeactivate)
            IconButton(
              key: const Key('deactivate_product_button'),
              icon: const Icon(Icons.block),
              tooltip: l10n.deactivateProductTooltip,
              onPressed: formState.submitting
                  ? null
                  : () =>
                        _confirmDeactivate(context, controller, formState.code),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveFormGrid(
          // Two columns is the widest this form uses — the text fields read
          // best paired rather than in three narrow columns (US2, FR-009).
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
                    // The server's own message (e.g. "Product not found")
                    // can't be localized client-side, so it's shown as
                    // supplementary detail under the localized heading above.
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
              span: FormGridSpan.full,
              _PhotoSection(
                formState: formState,
                controller: controller,
                canEditPhoto: canEditPhoto,
                hasPhoto: hasPhoto,
                photoError: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['photo'],
                ),
                onPick: () => _pickPhoto(controller),
                uploadLabel: l10n.uploadPhotoButton,
                replaceLabel: l10n.replacePhotoButton,
                removeLabel: l10n.removePhotoButton,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('code_field'),
                initialValue: formState.code,
                decoration: InputDecoration(
                  labelText: l10n.codeLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['code'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.codeChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('name_field'),
                initialValue: formState.name,
                decoration: InputDecoration(
                  labelText: l10n.nameLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['name'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.nameChanged,
              ),
            ),
            FormGridChild(
              CatalogEntityPicker<SatCatalogItem>(
                key: const Key('unit_of_measurement_field'),
                label: l10n.unitOfMeasurementLabel,
                displayStringForOption: (item) => item.description != null
                    ? '${item.code} — ${item.description}'
                    : item.code,
                optionsBuilder: (query) async {
                  final result = await satRepo.listUnitsOfMeasurement(
                    search: query.isEmpty ? null : query,
                  );
                  return result.items;
                },
                onSelected: controller.unitSelected,
                initialDisplayText:
                    formState.unitOfMeasurementDisplayText.isNotEmpty
                    ? formState.unitOfMeasurementDisplayText
                    : formState.unitOfMeasurementCode,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['unitOfMeasurementCode'],
                ),
                enabled: fieldsEnabled,
              ),
            ),
            FormGridChild(
              CatalogEntityPicker<SupplierListItem>(
                key: const Key('supplier_field'),
                label: l10n.supplierLabel,
                displayStringForOption: (item) => '${item.code} — ${item.name}',
                optionsBuilder: (query) async {
                  final result = await supplierRepo.list(
                    search: query.isEmpty ? null : query,
                  );
                  return result.items;
                },
                onSelected: controller.supplierSelected,
                initialDisplayText: formState.supplierName ?? '',
                enabled: fieldsEnabled,
              ),
            ),
            if (fieldsEnabled || formState.satKeyCode != null)
              FormGridChild(
                CatalogEntityPicker<SatCatalogItem>(
                  key: const Key('sat_key_field'),
                  label: l10n.satKeyLabel,
                  displayStringForOption: (item) => item.description != null
                      ? '${item.code} — ${item.description}'
                      : item.code,
                  optionsBuilder: (query) async {
                    final result = await satRepo.listProductServices(
                      search: query.isEmpty ? null : query,
                    );
                    return result.items;
                  },
                  onSelected: controller.satKeySelected,
                  initialDisplayText: formState.satKeyDisplayText ?? '',
                  enabled: fieldsEnabled,
                ),
              ),
            FormGridChild(
              TextFormField(
                key: const Key('brand_field'),
                initialValue: formState.brand,
                decoration: InputDecoration(labelText: l10n.brandLabel),
                enabled: fieldsEnabled,
                onChanged: controller.brandChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('model_field'),
                initialValue: formState.model,
                decoration: InputDecoration(labelText: l10n.modelLabel),
                enabled: fieldsEnabled,
                onChanged: controller.modelChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('bar_code_field'),
                initialValue: formState.barCode,
                decoration: InputDecoration(
                  labelText: l10n.barCodeLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['barCode'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.barCodeChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('location_field'),
                initialValue: formState.location,
                decoration: InputDecoration(labelText: l10n.locationLabel),
                enabled: fieldsEnabled,
                onChanged: controller.locationChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('tax_rate_field'),
                initialValue: formState.taxRate,
                decoration: InputDecoration(labelText: l10n.taxRateLabel),
                enabled: fieldsEnabled,
                onChanged: controller.taxRateChanged,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              TextFormField(
                key: const Key('comment_field'),
                initialValue: formState.comment,
                decoration: InputDecoration(labelText: l10n.commentLabel),
                enabled: fieldsEnabled,
                onChanged: controller.commentChanged,
                maxLines: 3,
              ),
            ),
            const FormGridChild(
              span: FormGridSpan.full,
              Divider(key: Key('attributes_divider_top')),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              _SwitchesPricesBand(
                switches: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      key: const Key('stockable_switch'),
                      title: Text(l10n.stockableLabel),
                      value: formState.stockable,
                      onChanged: fieldsEnabled
                          ? controller.stockableChanged
                          : null,
                    ),
                    SwitchListTile(
                      key: const Key('perishable_switch'),
                      title: Text(l10n.perishableLabel),
                      value: formState.perishable,
                      onChanged: fieldsEnabled
                          ? controller.perishableChanged
                          : null,
                    ),
                    SwitchListTile(
                      key: const Key('seriable_switch'),
                      title: Text(l10n.seriableLabel),
                      value: formState.seriable,
                      onChanged: fieldsEnabled
                          ? controller.seriableChanged
                          : null,
                    ),
                    SwitchListTile(
                      key: const Key('purchasable_switch'),
                      title: Text(l10n.purchasableLabel),
                      value: formState.purchasable,
                      onChanged: fieldsEnabled
                          ? controller.purchasableChanged
                          : null,
                    ),
                    SwitchListTile(
                      key: const Key('salable_switch'),
                      title: Text(l10n.salableLabel),
                      value: formState.salable,
                      onChanged: fieldsEnabled
                          ? controller.salableChanged
                          : null,
                    ),
                    SwitchListTile(
                      key: const Key('invoiceable_switch'),
                      title: Text(l10n.invoiceableLabel),
                      value: formState.invoiceable,
                      onChanged: fieldsEnabled
                          ? controller.invoiceableChanged
                          : null,
                    ),
                  ],
                ),
                prices: (_isEdit && formState.prices.isNotEmpty)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.pricesSubpanelTitle,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ...formState.prices.map(
                            (price) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                price.priceListName.trim().isEmpty
                                    ? l10n.unknownPriceList
                                    : price.priceListName,
                              ),
                              trailing: Text(price.price),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const FormGridChild(
              span: FormGridSpan.full,
              Divider(key: Key('attributes_divider_bottom')),
            ),
            if (allLabels.isNotEmpty)
              FormGridChild(
                span: FormGridSpan.full,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.labelsLabel,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    LabelMultiPicker(
                      key: const Key('label_multi_picker'),
                      labels: allLabels,
                      selectedIds: formState.labelIds,
                      onChanged: (newIds) {
                        final current = formState.labelIds;
                        final toggled = newIds.length > current.length
                            ? newIds.firstWhere((id) => !current.contains(id))
                            : current.firstWhere((id) => !newIds.contains(id));
                        controller.labelToggled(toggled);
                      },
                      enabled: fieldsEnabled,
                    ),
                  ],
                ),
              ),
            if (canSave)
              FormGridChild(
                span: FormGridSpan.full,
                FilledButton(
                  key: const Key('save_button'),
                  onPressed: formState.submitting
                      ? null
                      : (_isEdit
                            ? controller.submitUpdate
                            : controller.submitCreate),
                  child: formState.submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Opens the native file picker restricted to JPEG/PNG and stages the
  /// result via [ProductFormController.photoPicked] (FR-003, FR-004).
  /// Client-side type/size validation happens in the controller, not here.
  Future<void> _pickPhoto(ProductFormController controller) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    controller.photoPicked(bytes, file.name);
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    ProductFormController controller,
    String code,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deactivateProductConfirmTitle),
        content: Text(l10n.deactivateProductConfirmMessage(code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_deactivate_button'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deactivateButton),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.deactivate();
  }
}

/// Lays the boolean attribute [switches] and the (optional) [prices] section
/// into a two-column band on non-compact viewports — switches on the left,
/// prices on the right — reclaiming the horizontal space each switch row
/// otherwise wastes (FR-017). On compact widths they stack vertically, and
/// when there is no price list the switches occupy the full width.
class _SwitchesPricesBand extends StatelessWidget {
  const _SwitchesPricesBand({required this.switches, this.prices});

  final Widget switches;
  final Widget? prices;

  @override
  Widget build(BuildContext context) {
    if (prices == null) return switches;

    if (LayoutBreakpoints.isCompact(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [switches, const SizedBox(height: 24), prices!],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: switches),
        const SizedBox(width: 32),
        Expanded(child: prices!),
      ],
    );
  }
}

/// The product photo thumbnail plus its edit affordances (upload / replace /
/// remove) and any photo field error. Rendered as a full-width row in the
/// responsive form grid (FR-012).
class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.formState,
    required this.controller,
    required this.canEditPhoto,
    required this.hasPhoto,
    required this.photoError,
    required this.onPick,
    required this.uploadLabel,
    required this.replaceLabel,
    required this.removeLabel,
  });

  final ProductFormState formState;
  final ProductFormController controller;
  final bool canEditPhoto;
  final bool hasPhoto;
  final String? photoError;
  final VoidCallback onPick;
  final String uploadLabel;
  final String replaceLabel;
  final String removeLabel;

  Widget _thumbnail() {
    if (formState.pendingPhotoBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          formState.pendingPhotoBytes!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      );
    }
    return ProductPhoto(
      photoUrl: formState.photoMarkedForRemoval ? null : formState.photo,
      size: 96,
    );
  }

  /// The upload / replace+remove controls, or `null` for read-only users.
  /// [horizontal] left-aligns them (beside the thumbnail); otherwise they
  /// center (stacked below the thumbnail on compact).
  Widget? _actions({required bool horizontal}) {
    if (!canEditPhoto) return null;
    final children = hasPhoto
        ? [
            TextButton.icon(
              key: const Key('replace_photo_button'),
              onPressed: formState.submitting ? null : onPick,
              icon: const Icon(Icons.upload),
              label: Text(replaceLabel),
            ),
            TextButton.icon(
              key: const Key('remove_photo_button'),
              onPressed: formState.submitting
                  ? null
                  : controller.photoRemoveRequested,
              icon: const Icon(Icons.delete_outline),
              label: Text(removeLabel),
            ),
          ]
        : [
            TextButton.icon(
              key: const Key('upload_photo_button'),
              onPressed: formState.submitting ? null : onPick,
              icon: const Icon(Icons.upload),
              label: Text(uploadLabel),
            ),
          ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: horizontal
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    // On compact widths, stack the actions below the thumbnail to avoid a
    // horizontal overflow; otherwise place them beside it, reclaiming the row
    // (FR-012, spec.md Edge Cases).
    final compact = LayoutBreakpoints.isCompact(context);
    final actions = _actions(horizontal: !compact);
    final thumbnail = _thumbnail();

    final Widget media;
    if (actions == null) {
      media = thumbnail;
    } else if (compact) {
      media = Column(
        mainAxisSize: MainAxisSize.min,
        children: [thumbnail, const SizedBox(height: 8), actions],
      );
    } else {
      media = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [thumbnail, const SizedBox(width: 16), actions],
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          media,
          if (photoError case final error?) ...[
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

/// Localizes a [ProductFormErrorCode] for [ProductFormState.error].
/// Falls back to the raw value for codes this UI doesn't recognize (e.g.
/// a server-provided message that isn't one of our codes).
String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case ProductFormErrorCode.loadFailed:
      return l10n.productLoadFailedError;
    case ProductFormErrorCode.createFailed:
      return l10n.productCreateFailedError;
    case ProductFormErrorCode.updateFailed:
      return l10n.productUpdateFailedError;
    case ProductFormErrorCode.deactivateFailed:
      return l10n.productDeactivateFailedError;
    case ProductFormErrorCode.createPermissionDenied:
      return l10n.productCreatePermissionDeniedError;
    case ProductFormErrorCode.updatePermissionDenied:
      return l10n.productUpdatePermissionDeniedError;
    case ProductFormErrorCode.deactivatePermissionDenied:
      return l10n.productDeactivatePermissionDeniedError;
    case ProductFormErrorCode.photoUploadFailed:
      return l10n.productPhotoUploadFailedError;
    default:
      return code;
  }
}

/// Localizes a [ProductFormState.fieldErrors] entry. Server-provided
/// messages (e.g. a duplicate-code rejection) aren't one of
/// [ProductFormErrorCode]'s values, so they pass through unchanged.
String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case ProductFormErrorCode.codeRequired:
      return l10n.productCodeRequiredError;
    case ProductFormErrorCode.codeWhitespace:
      return l10n.productCodeWhitespaceError;
    case ProductFormErrorCode.codeTooLong:
      return l10n.productCodeTooLongError;
    case ProductFormErrorCode.nameLength:
      return l10n.productNameLengthError;
    case ProductFormErrorCode.unitRequired:
      return l10n.productUnitRequiredError;
    case ProductFormErrorCode.barCodeInvalid:
      return l10n.productBarCodeInvalidError;
    case ProductFormErrorCode.photoInvalidType:
      return l10n.productPhotoInvalidTypeError;
    case ProductFormErrorCode.photoTooLarge:
      return l10n.productPhotoTooLargeError;
    default:
      return code;
  }
}
