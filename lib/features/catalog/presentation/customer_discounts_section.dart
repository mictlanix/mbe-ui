import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design_theme_extensions.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discount_dialog.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discounts_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A customer's Discounts section (spec 052 FR-001, FR-002, FR-007) — a
/// divider-delimited **child collection** rendered inside the customer
/// detail, loaded through its own endpoint rather than the customer's. Rows
/// are listed in the server's order (by product code).
///
/// In create mode ([customerId] `null`) the customer has no id to load
/// discounts for, so the section shows a note instead and never touches the
/// provider.
class CustomerDiscountsSection extends ConsumerWidget {
  const CustomerDiscountsSection({
    super.key,
    required this.customerId,
    required this.readOnly,
  });

  final int? customerId;

  /// The parent customer screen's own read-only flag — passed straight
  /// through so this section's mutation controls follow the same visibility
  /// rule as every other one on that screen.
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = customerId;
    final access = ref.watch(accessControlProvider);
    // Adding needs Update on customers, and Read on products to search them
    // (FR-012). The button also waits for the list: until it has loaded the
    // products that already carry a discount are unknown, and the picker
    // must leave them out (FR-005) — hidden, not disabled (§IV).
    final loaded = id == null
        ? null
        : ref
              .watch(customerDiscountsControllerProvider(id))
              .whenOrNull(data: (discounts) => discounts);
    // Changing or removing a discount needs only Update on customers: the
    // product is fixed, so nothing is searched.
    final canEdit =
        !readOnly && access.can(SystemObject.customers, AccessRight.update);
    final canAdd =
        canEdit &&
        loaded != null &&
        access.can(SystemObject.products, AccessRight.read);

    // Same header as the linked-record sections above it: the title (with
    // a count once there is something to count) and a "New" text button.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                loaded == null || loaded.isEmpty
                    ? l10n.customerDiscountsSection
                    : '${l10n.customerDiscountsSection} (${loaded.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (id != null && canAdd)
              TextButton.icon(
                key: const Key('add_customer_discount_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.linkedRecordNewAction),
                onPressed: () => showCustomerDiscountDialog(
                  context,
                  customerId: id,
                  takenProductIds: {for (final d in loaded) d.productId},
                ),
              ),
          ],
        ),
        if (id == null)
          _MutedNote(
            l10n.customerDiscountsAfterSaveNote,
            key: const Key('customer_discounts_after_save_note'),
          )
        else
          _DiscountsList(customerId: id, canEdit: canEdit),
      ],
    );
  }
}

/// Rows per page. Like the user's permissions grid, the table sits inside
/// the page's own scroll, so it grows with its rows up to one page and then
/// pages instead of scrolling inside the page.
const _pageSize = 10;

class _DiscountsList extends ConsumerStatefulWidget {
  const _DiscountsList({required this.customerId, required this.canEdit});

  final int customerId;
  final bool canEdit;

  @override
  ConsumerState<_DiscountsList> createState() => _DiscountsListState();
}

class _DiscountsListState extends ConsumerState<_DiscountsList> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final customerId = widget.customerId;
    final canEdit = widget.canEdit;
    final discountsAsync = ref.watch(
      customerDiscountsControllerProvider(customerId),
    );
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);

    return discountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ListFailedView(
        error: toAppError(e),
        retryLabel: l10n.retryButton,
        onRetry: () =>
            ref.invalidate(customerDiscountsControllerProvider(customerId)),
      ),
      data: (discounts) {
        if (discounts.isEmpty) return _MutedNote(l10n.customerDiscountsEmpty);
        // A removal can empty the last page: fall back to the new last one.
        final lastPage = (discounts.length - 1) ~/ _pageSize;
        final pageIndex = _pageIndex > lastPage ? lastPage : _pageIndex;
        final page = discounts
            .skip(pageIndex * _pageSize)
            .take(_pageSize)
            .toList();
        return Padding(
          padding: EdgeInsets.only(top: Theme.of(context).spacing.xs),
          child: DataTableView<CustomerDiscount>(
            key: const Key('customer_discounts_table'),
            columns: [
              // Dropped on the compact tier, where three columns do not
              // fit: the code moves into the product cell instead.
              if (!compact)
                DataTableColumn.text(
                  label: l10n.customerDiscountColumnCode,
                  text: (d) => d.productCode,
                  size: ColumnSize.S,
                ),
              DataTableColumn.text(
                label: l10n.customerDiscountColumnProduct,
                text: (d) => compact
                    ? '${d.productCode} · ${d.productName}'
                    : d.productName,
                size: ColumnSize.L,
              ),
              DataTableColumn.text(
                label: l10n.customerDiscountColumnDiscount,
                text: (d) => fmt.display.percent(d.discount),
                size: ColumnSize.S,
                numeric: true,
              ),
            ],
            rows: page,
            pagination: CatalogPage<CustomerDiscount>(
              items: page,
              total: discounts.length,
              pageIndex: pageIndex,
              pageSize: _pageSize,
            ),
            onPageChanged: (index) => setState(() => _pageIndex = index),
            // Edit only: removing a discount lives in its dialog, behind a
            // confirmation (§VI, FR-009).
            rowActionsBuilder: canEdit
                ? (context, d) => buildCatalogRowActions(
                    editTooltip: l10n.editActionTooltip,
                    editKey: Key(
                      'edit_customer_discount_${d.customerDiscountId}',
                    ),
                    onEdit: () => showCustomerDiscountDialog(
                      context,
                      customerId: customerId,
                      takenProductIds: {for (final x in discounts) x.productId},
                      existing: d,
                    ),
                  )
                : null,
            shrinkWrap: true,
            margin: EdgeInsets.zero,
          ),
        );
      },
    );
  }
}

/// The empty-state line the linked-record sections use: small, muted, with
/// a little air above and below.
class _MutedNote extends StatelessWidget {
  const _MutedNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
