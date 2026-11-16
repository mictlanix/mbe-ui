import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';

/// The names behind a receipt's ids, shared by the list and the detail
/// screen (spec 067 FR-004). Each resolves through the app's cached per-id
/// display-name provider and falls back to `#id` when the name can't be read
/// (a missing catalog right, a deleted record or a failed request). While
/// loading it shows `…`.
///
/// One line, ellipsized, with the full text in a tooltip (constitution §VI).
class _ResolvedName extends ConsumerWidget {
  const _ResolvedName({required this.provider, required this.id});

  final FutureProvider<String?> provider;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref
        .watch(provider)
        .when(
          data: (name) => name ?? '#$id',
          loading: () => '…',
          error: (_, _) => '#$id',
        );
    return Tooltip(
      message: text,
      child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}

/// A warehouse's name (Warehouses read).
class ReceiptWarehouseName extends StatelessWidget {
  const ReceiptWarehouseName({super.key, required this.warehouseId});

  final int warehouseId;

  @override
  Widget build(BuildContext context) => _ResolvedName(
    provider: warehouseDisplayNameProvider(warehouseId),
    id: warehouseId,
  );
}

/// A facility's name (Facilities read).
class ReceiptFacilityName extends StatelessWidget {
  const ReceiptFacilityName({super.key, required this.facilityId});

  final int facilityId;

  @override
  Widget build(BuildContext context) => _ResolvedName(
    provider: facilityDisplayNameProvider(facilityId),
    id: facilityId,
  );
}

/// An employee's name: a receipt's `creator` and `updater` are employee ids.
class ReceiptEmployeeName extends StatelessWidget {
  const ReceiptEmployeeName({super.key, required this.employeeId});

  final int employeeId;

  @override
  Widget build(BuildContext context) => _ResolvedName(
    provider: employeeDisplayNameProvider(employeeId),
    id: employeeId,
  );
}
