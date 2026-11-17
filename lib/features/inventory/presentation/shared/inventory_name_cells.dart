import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';

/// The names behind a receipt's ids, shared by the list and the detail
/// screen (spec 067 FR-004). A list row passes the server's joined [name]
/// (mbe-api#327–#330), shown as is. Without one, the name resolves through
/// the app's cached per-id display-name provider and falls back to `#id` when
/// it can't be read (a missing catalog right, a deleted record or a failed
/// request). While loading it shows `…`.
///
/// One line, ellipsized, with the full text in a tooltip (constitution §VI).
class _ResolvedName extends ConsumerWidget {
  const _ResolvedName({required this.provider, required this.id, this.name});

  final FutureProvider<String?> provider;
  final int id;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = name;
    final text = server != null && server.isNotEmpty
        ? server
        : ref
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
class InventoryWarehouseName extends StatelessWidget {
  const InventoryWarehouseName({
    super.key,
    required this.warehouseId,
    this.name,
  });

  final int warehouseId;

  /// The server's joined name, when the row carries one.
  final String? name;

  @override
  Widget build(BuildContext context) => _ResolvedName(
    provider: warehouseDisplayNameProvider(warehouseId),
    id: warehouseId,
    name: name,
  );
}

/// A facility's name (Facilities read).
class InventoryFacilityName extends StatelessWidget {
  const InventoryFacilityName({super.key, required this.facilityId, this.name});

  final int facilityId;

  /// The server's joined name, when the row carries one.
  final String? name;

  @override
  Widget build(BuildContext context) => _ResolvedName(
    provider: facilityDisplayNameProvider(facilityId),
    id: facilityId,
    name: name,
  );
}

/// An employee's name: a receipt's `creator` and `updater` are employee ids.
class InventoryEmployeeName extends StatelessWidget {
  const InventoryEmployeeName({super.key, required this.employeeId, this.name});

  final int employeeId;

  /// The server's joined name, when the row carries one.
  final String? name;

  @override
  Widget build(BuildContext context) => _ResolvedName(
    provider: employeeDisplayNameProvider(employeeId),
    id: employeeId,
    name: name,
  );
}
