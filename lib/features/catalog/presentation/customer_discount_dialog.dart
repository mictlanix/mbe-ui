import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design_theme_extensions.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discount_dialog_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// How many product suggestions the picker asks for.
const _suggestionLimit = 20;

/// Opens the discount dialog (spec 052 FR-004, FR-008): add when [existing] is
/// `null`, edit otherwise — the product is shown but can't change, and Remove
/// lives here (FR-009). [takenProductIds] are the products this customer already has a
/// discount on, which the add picker leaves out (FR-005). Saving closes the
/// dialog after refreshing the customer's discounts list itself.
Future<void> showCustomerDiscountDialog(
  BuildContext context, {
  required int customerId,
  required Set<int> takenProductIds,
  CustomerDiscount? existing,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _CustomerDiscountDialog(
      customerId: customerId,
      takenProductIds: takenProductIds,
      existing: existing,
    ),
  );
}

class _CustomerDiscountDialog extends ConsumerWidget {
  const _CustomerDiscountDialog({
    required this.customerId,
    required this.takenProductIds,
    required this.existing,
  });

  final int customerId;
  final Set<int> takenProductIds;
  final CustomerDiscount? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = customerDiscountDialogControllerProvider(
      customerId,
      existing,
    );
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final productRepository = ref.read(productRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final current = existing;

    if (state.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
    }

    final fieldsEnabled = !state.submitting;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                current == null
                    ? l10n.newCustomerDiscountDialogTitle
                    : l10n.editCustomerDiscountDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: spacing.md),
              // Outside the grid: inserting a child there would shift the
              // fields' positions and drop what the user entered.
              if (state.error != null) ...[
                ErrorBanner(
                  error: AppError.server(
                    message: _errorMessage(l10n, state.error!, state),
                  ),
                ),
                SizedBox(height: spacing.md),
              ],
              ResponsiveFormGrid(
                maxColumns: 1,
                spacing: spacing.md,
                children: [
                  FormGridChild(switch ((current, state.product)) {
                    // The product is fixed once the discount exists. Its
                    // summary carries no photo, so the placeholder shows.
                    (final current?, _) => _SelectedProduct(
                      label: l10n.customerDiscountProductLabel,
                      name: current.productName,
                      code: current.productCode,
                    ),
                    // Picked: shown like a search row, with a way back.
                    (null, final product?) => _SelectedProduct(
                      label: l10n.customerDiscountProductLabel,
                      name: product.name,
                      code: product.code,
                      photoUrl: product.photo,
                      onClear: fieldsEnabled ? controller.productCleared : null,
                      clearTooltip: l10n.customerDiscountChangeProductTooltip,
                    ),
                    (null, null) => CatalogEntityPicker<ProductListItem>(
                      key: const Key('customer_discount_product_field'),
                      label: l10n.customerDiscountProductLabel,
                      enabled: fieldsEnabled,
                      displayStringForOption: (item) => item.name,
                      optionsBuilder: (query) =>
                          _search(productRepository, query, takenProductIds),
                      onSelected: controller.productSelected,
                      optionImageUrl: (item) => item.photo,
                      optionSubtitle: (item) => item.code,
                    ),
                  }),
                  FormGridChild(
                    TextFormField(
                      key: const Key('customer_discount_percent_field'),
                      initialValue: state.percent,
                      enabled: fieldsEnabled,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.customerDiscountPercentLabel,
                        suffixText: '%',
                        errorText:
                            _percentError(l10n, state.percentError) ??
                            state.fieldErrors['discount'],
                      ),
                      onChanged: controller.percentChanged,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),
              Row(
                children: [
                  // Destructive action furthest from the primary one.
                  if (current != null)
                    OutlinedButton(
                      key: const Key('customer_discount_delete_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onPressed: fieldsEnabled
                          ? () async {
                              final confirmed =
                                  await showRecordDeleteConfirmation(
                                    context,
                                    RecordDeleteConfirmation(
                                      title: l10n
                                          .deleteCustomerDiscountConfirmTitle,
                                      message: l10n
                                          .deleteCustomerDiscountConfirmMessage(
                                            current.productCode,
                                            current.productName,
                                          ),
                                      confirmLabel:
                                          l10n.deleteCustomerDiscountButton,
                                      cancelLabel: l10n.cancelButton,
                                      confirmKey: const Key(
                                        'confirm_delete_customer_discount_button',
                                      ),
                                    ),
                                  );
                              if (confirmed == true) controller.delete();
                            }
                          : null,
                      child: Text(l10n.deleteCustomerDiscountButton),
                    ),
                  const Spacer(),
                  TextButton(
                    key: const Key('customer_discount_cancel_button'),
                    onPressed: fieldsEnabled
                        ? () => Navigator.of(context).pop()
                        : null,
                    child: Text(l10n.cancelButton),
                  ),
                  SizedBox(width: spacing.xs),
                  FilledButton(
                    key: const Key('customer_discount_save_button'),
                    onPressed: controller.canSubmit ? controller.submit : null,
                    child: state.submitting
                        ? SizedBox(
                            width: spacing.md,
                            height: spacing.md,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(l10n.saveButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The chosen product, laid out like a row of the picker's suggestions:
/// photo, name, and the code beneath it. [onClear] (add mode only) drops it
/// so another can be searched.
class _SelectedProduct extends StatelessWidget {
  const _SelectedProduct({
    required this.label,
    required this.name,
    required this.code,
    this.photoUrl,
    this.onClear,
    this.clearTooltip,
  });

  final String label;
  final String name;
  final String code;
  final String? photoUrl;
  final VoidCallback? onClear;
  final String? clearTooltip;

  @override
  Widget build(BuildContext context) {
    final clear = onClear;
    return InputDecorator(
      key: const Key('customer_discount_selected_product'),
      decoration: InputDecoration(labelText: label),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: ProductPhoto(photoUrl: photoUrl, size: 40),
        title: Text(name),
        subtitle: Text(code),
        trailing: clear == null
            ? null
            : IconButton(
                key: const Key('customer_discount_clear_product'),
                icon: const Icon(Icons.close),
                tooltip: clearTooltip,
                onPressed: clear,
              ),
      ),
    );
  }
}

/// Active products matching [query], minus the ones that already carry a
/// discount for this customer (FR-005).
Future<List<ProductListItem>> _search(
  ProductRepository repository,
  String query,
  Set<int> takenProductIds,
) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return const [];
  final result = await repository.list(
    search: trimmed,
    status: EntityStatus.active,
    limit: _suggestionLimit,
  );
  return result.items
      .where((item) => !takenProductIds.contains(item.productId))
      .toList();
}

String? _percentError(AppLocalizations l10n, String? code) => switch (code) {
  CustomerDiscountPercentError.required =>
    l10n.customerDiscountPercentRequiredError,
  CustomerDiscountPercentError.invalid =>
    l10n.customerDiscountPercentInvalidError,
  CustomerDiscountPercentError.outOfRange =>
    l10n.customerDiscountPercentOutOfRangeError,
  CustomerDiscountPercentError.tooPrecise =>
    l10n.customerDiscountPercentTooPreciseError,
  _ => null,
};

String _errorMessage(
  AppLocalizations l10n,
  String code,
  CustomerDiscountDialogState state,
) => switch (code) {
  CustomerDiscountDialogErrorCode.duplicateProduct =>
    l10n.customerDiscountDuplicateError,
  CustomerDiscountDialogErrorCode.productMissing =>
    l10n.customerDiscountProductMissingError,
  CustomerDiscountDialogErrorCode.discountMissing =>
    l10n.customerDiscountMissingError,
  CustomerDiscountDialogErrorCode.deleteFailed =>
    state.errorDetail ?? l10n.customerDiscountDeleteFailedError,
  _ => state.errorDetail ?? l10n.customerDiscountSaveFailedError,
};
