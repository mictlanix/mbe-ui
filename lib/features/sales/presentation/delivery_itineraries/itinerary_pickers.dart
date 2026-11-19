import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';

// The three catalog pickers the itinerary dialogs and the list's drawer share
// (spec 075 ui-contract). Each lists active records only and needs read on its
// catalog, which the caller checks (§IV): a picker the user can't read is left
// out, not disabled.

/// How a vehicle reads: `{nickname} · {licensePlate}`, as the printed
/// itinerary and the server's `vehicle_name` show it.
String vehicleOptionLabel(Vehicle v) => '${v.nickname} · ${v.licensePlate}';

class ItineraryVehiclePicker extends ConsumerWidget {
  const ItineraryVehiclePicker({
    super.key,
    required this.label,
    required this.onSelected,
    this.initialDisplayText,
    this.bare = false,
  });

  final String label;
  final ValueChanged<Vehicle> onSelected;
  final String? initialDisplayText;
  final bool bare;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      CatalogEntityPicker<Vehicle>(
        label: label,
        bare: bare,
        displayStringForOption: vehicleOptionLabel,
        optionsBuilder: (search) async {
          final result = await ref
              .read(vehicleRepositoryProvider)
              .list(
                search: search.isEmpty ? null : search,
                status: EntityStatus.active,
                limit: 10,
              );
          return result.items;
        },
        onSelected: onSelected,
        initialDisplayText: initialDisplayText,
      );
}

class ItineraryOperatorPicker extends ConsumerWidget {
  const ItineraryOperatorPicker({
    super.key,
    required this.label,
    required this.onSelected,
    this.initialDisplayText,
    this.bare = false,
  });

  final String label;
  final ValueChanged<VehicleOperator> onSelected;
  final String? initialDisplayText;
  final bool bare;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      CatalogEntityPicker<VehicleOperator>(
        label: label,
        bare: bare,
        displayStringForOption: (o) => o.driverName,
        optionsBuilder: (search) async {
          final result = await ref
              .read(vehicleOperatorRepositoryProvider)
              .list(
                search: search.isEmpty ? null : search,
                status: EntityStatus.active,
                limit: 10,
              );
          return result.items;
        },
        onSelected: onSelected,
        initialDisplayText: initialDisplayText,
      );
}

class ItineraryWarehousePicker extends ConsumerWidget {
  const ItineraryWarehousePicker({
    super.key,
    required this.label,
    required this.onSelected,
    this.initialDisplayText,
    this.bare = false,
  });

  final String label;
  final ValueChanged<Warehouse> onSelected;
  final String? initialDisplayText;
  final bool bare;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      CatalogEntityPicker<Warehouse>(
        label: label,
        bare: bare,
        displayStringForOption: (w) => w.name,
        optionsBuilder: (search) async {
          final result = await ref
              .read(warehouseRepositoryProvider)
              .list(
                search: search.isEmpty ? null : search,
                status: EntityStatus.active,
                limit: 10,
              );
          return result.items;
        },
        onSelected: onSelected,
        initialDisplayText: initialDisplayText,
      );
}
