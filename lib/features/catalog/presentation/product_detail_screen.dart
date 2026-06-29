import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (formState.error != null) ...[
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
              const SizedBox(height: 16),
            ],
            Center(
              child: Column(
                children: [
                  if (formState.pendingPhotoBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        formState.pendingPhotoBytes!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    ProductPhoto(
                      photoUrl:
                          formState.photoMarkedForRemoval ? null : formState.photo,
                      size: 96,
                    ),
                  if (canEditPhoto && !hasPhoto) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      key: const Key('upload_photo_button'),
                      onPressed: formState.submitting
                          ? null
                          : () => _pickPhoto(controller),
                      icon: const Icon(Icons.upload),
                      label: Text(l10n.uploadPhotoButton),
                    ),
                  ],
                  if (canEditPhoto && hasPhoto) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          key: const Key('replace_photo_button'),
                          onPressed: formState.submitting
                              ? null
                              : () => _pickPhoto(controller),
                          icon: const Icon(Icons.upload),
                          label: Text(l10n.replacePhotoButton),
                        ),
                        TextButton.icon(
                          key: const Key('remove_photo_button'),
                          onPressed: formState.submitting
                              ? null
                              : controller.photoRemoveRequested,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.removePhotoButton),
                        ),
                      ],
                    ),
                  ],
                  if (_localizeFieldError(l10n, formState.fieldErrors['photo'])
                      case final photoError?) ...[
                    const SizedBox(height: 4),
                    Text(
                      photoError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('unit_of_measurement_field'),
              initialValue: formState.unitOfMeasurement,
              decoration: InputDecoration(
                labelText: l10n.unitOfMeasurementLabel,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['unitOfMeasurement'],
                ),
              ),
              enabled: fieldsEnabled,
              onChanged: controller.unitOfMeasurementChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('brand_field'),
              initialValue: formState.brand,
              decoration: InputDecoration(labelText: l10n.brandLabel),
              enabled: fieldsEnabled,
              onChanged: controller.brandChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('model_field'),
              initialValue: formState.model,
              decoration: InputDecoration(labelText: l10n.modelLabel),
              enabled: fieldsEnabled,
              onChanged: controller.modelChanged,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('location_field'),
              initialValue: formState.location,
              decoration: InputDecoration(labelText: l10n.locationLabel),
              enabled: fieldsEnabled,
              onChanged: controller.locationChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('tax_rate_field'),
              initialValue: formState.taxRate,
              decoration: InputDecoration(labelText: l10n.taxRateLabel),
              enabled: fieldsEnabled,
              onChanged: controller.taxRateChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('comment_field'),
              initialValue: formState.comment,
              decoration: InputDecoration(labelText: l10n.commentLabel),
              enabled: fieldsEnabled,
              onChanged: controller.commentChanged,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              key: const Key('stockable_switch'),
              title: Text(l10n.stockableLabel),
              value: formState.stockable,
              onChanged: fieldsEnabled ? controller.stockableChanged : null,
            ),
            SwitchListTile(
              key: const Key('perishable_switch'),
              title: Text(l10n.perishableLabel),
              value: formState.perishable,
              onChanged: fieldsEnabled ? controller.perishableChanged : null,
            ),
            SwitchListTile(
              key: const Key('seriable_switch'),
              title: Text(l10n.seriableLabel),
              value: formState.seriable,
              onChanged: fieldsEnabled ? controller.seriableChanged : null,
            ),
            SwitchListTile(
              key: const Key('purchasable_switch'),
              title: Text(l10n.purchasableLabel),
              value: formState.purchasable,
              onChanged: fieldsEnabled ? controller.purchasableChanged : null,
            ),
            SwitchListTile(
              key: const Key('salable_switch'),
              title: Text(l10n.salableLabel),
              value: formState.salable,
              onChanged: fieldsEnabled ? controller.salableChanged : null,
            ),
            SwitchListTile(
              key: const Key('invoiceable_switch'),
              title: Text(l10n.invoiceableLabel),
              value: formState.invoiceable,
              onChanged: fieldsEnabled ? controller.invoiceableChanged : null,
            ),
            const SizedBox(height: 24),
            if (canSave)
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
