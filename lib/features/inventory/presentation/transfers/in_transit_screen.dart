import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/in_transit_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const inTransitPath = '/inventory/transfers/in-transit';

/// En tránsito: what is outstanding toward or from one facility (spec 069
/// US7, contracts/ui-contract.md "In-transit screen"). Gated by
/// InventoryTransfers (SystemObject 17) read.
///
/// An administrator with Facilities (29) read can switch facility; anyone
/// else sees their own, named in the title.
class InTransitScreen extends ConsumerWidget {
  const InTransitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final access = ref.watch(accessControlProvider);
    // Facilities (29) read: the picker lists facilities.
    final canPick =
        access.isAdministrator &&
        access.can(SystemObject.facilities, AccessRight.read);
    final facilityId = ref.watch(inTransitFacilityProvider);
    final facilityName = facilityId == null
        ? null
        : ref.watch(facilityDisplayNameProvider(facilityId)).value;
    final title = canPick || facilityId == null
        ? l10n.inventoryTransferInTransitTitle
        : l10n.inventoryTransferInTransitTitleFacility(
            facilityName ?? '#$facilityId',
          );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: EdgeInsets.all(spacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.fieldGapVertical,
          children: [
            if (canPick)
              Row(
                spacing: spacing.sm,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: CatalogEntityPicker<FacilityListItem>(
                        key: ValueKey('in_transit_facility_picker_$facilityId'),
                        label: l10n.inventoryTransferInTransitFacilityField,
                        displayStringForOption: (f) => f.name,
                        optionsBuilder: (search) async {
                          final result = await ref
                              .read(facilityRepositoryProvider)
                              .list(search: search.isEmpty ? null : search);
                          return result.items;
                        },
                        onSelected: (f) => ref
                            .read(inTransitFacilityProvider.notifier)
                            .select(f.facilityId),
                        initialDisplayText: facilityId == null
                            ? null
                            : (facilityName ?? '#$facilityId'),
                      ),
                    ),
                  ),
                  TextButton(
                    key: const Key('in_transit_facility_mine'),
                    onPressed: ref
                        .read(inTransitFacilityProvider.notifier)
                        .reset,
                    child: Text(l10n.inventoryTransferInTransitMyFacility),
                  ),
                ],
              ),
            Expanded(
              child: facilityId == null
                  ? _Message(
                      key: const Key('in_transit_no_facility'),
                      canPick
                          ? l10n.inventoryTransferInTransitSelectFacility
                          : l10n.inventoryDocumentNoFacility,
                    )
                  : _InTransitBody(facilityId: facilityId),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
  );
}

class _InTransitBody extends ConsumerWidget {
  const _InTransitBody({required this.facilityId});

  final int facilityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final async = ref.watch(inTransitControllerProvider(facilityId));
    final view = async.value;

    if (view == null) {
      if (async.hasError) {
        return ListFailedView(
          error: toAppError(async.error),
          retryLabel: l10n.retryButton,
          onRetry: () =>
              ref.invalidate(inTransitControllerProvider(facilityId)),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    if (view.lines.isEmpty && view.products.isEmpty) {
      return ListEmptyView(message: l10n.inventoryTransferInTransitEmpty);
    }

    DataTableColumn<T> quantity<T>(String label, Decimal Function(T) value) =>
        DataTableColumn<T>(
          label: label,
          numeric: true,
          size: ColumnSize.S,
          cellBuilder: (context, r) =>
              Text(fmt.display.quantity(value(r).toString())),
        );

    // simplified: unpaginated, the endpoint takes no paging and returns only transfers in flight; paginate client-side if a facility ever has hundreds of lines.
    return ListView(
      children: [
        Text(
          l10n.inventoryTransferInTransitByProduct,
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: spacing.sm),
        DataTableView<InTransitProductTotal>(
          key: const Key('in_transit_products_table'),
          shrinkWrap: true,
          margin: EdgeInsets.zero,
          rows: view.products,
          columns: [
            DataTableColumn(
              label: l10n.inventoryTransferLineColCode,
              size: ColumnSize.S,
              cellBuilder: (context, r) => Text(r.productCode ?? ''),
            ),
            DataTableColumn(
              label: l10n.inventoryTransferLineColProduct,
              size: ColumnSize.L,
              cellBuilder: (context, r) => Text(r.productName ?? ''),
            ),
            quantity(
              l10n.inventoryTransferLineColOutstanding,
              (InTransitProductTotal r) => r.quantity,
            ),
          ],
        ),
        SizedBox(height: spacing.sectionGap),
        Text(
          l10n.inventoryTransferInTransitByTransfer,
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: spacing.sm),
        DataTableView<InTransitLineItem>(
          key: const Key('in_transit_lines_table'),
          shrinkWrap: true,
          margin: EdgeInsets.zero,
          rows: view.lines,
          onRowTap: (r) =>
              context.push('$inventoryTransfersPath/${r.transferId}'),
          columns: [
            DataTableColumn(
              label: l10n.inventoryTransferColFolio,
              size: ColumnSize.S,
              numeric: true,
              cellBuilder: (context, r) =>
                  Text(r.serial == null ? '#${r.transferId}' : '${r.serial}'),
            ),
            DataTableColumn(
              label: l10n.inventoryTransferColSource,
              size: ColumnSize.M,
              cellBuilder: (context, r) => InventoryWarehouseName(
                warehouseId: r.warehouseId,
                name: r.warehouseName,
              ),
            ),
            DataTableColumn(
              label: l10n.inventoryTransferColDestination,
              size: ColumnSize.M,
              cellBuilder: (context, r) => InventoryWarehouseName(
                warehouseId: r.warehouseToId,
                name: r.warehouseToName,
              ),
            ),
            DataTableColumn(
              label: l10n.inventoryTransferLineColCode,
              size: ColumnSize.S,
              cellBuilder: (context, r) => Text(r.productCode ?? ''),
            ),
            DataTableColumn(
              label: l10n.inventoryTransferLineColProduct,
              size: ColumnSize.L,
              cellBuilder: (context, r) => Text(r.productName ?? ''),
            ),
            quantity(
              l10n.inventoryTransferLineColOutstanding,
              (InTransitLineItem r) => r.quantityOutstanding,
            ),
          ],
        ),
      ],
    );
  }
}
