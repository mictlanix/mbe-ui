import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';

/// The read-only names behind a delivery order's ids, shared by the list and
/// the detail screen (spec 061 research R4, FR-025).
///
/// Each resolves through the app's cached per-id providers and falls back to
/// `#id` when the name can't be read: a missing catalog right, a deleted
/// record or a failed request. While loading it shows `…`.
///
/// Every name is one line, ellipsized, with the full text in a tooltip
/// (constitution §VI); pass `truncate: false` where the full text fits, such
/// as the detail screen's band.
class _NameText extends StatelessWidget {
  const _NameText(this.text, {required this.truncate});

  final String text;
  final bool truncate;

  @override
  Widget build(BuildContext context) {
    if (!truncate) return Text(text);
    return Tooltip(
      message: text,
      child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}

String _resolved(AsyncValue<String?> value, int id) => value.when(
  data: (name) => name ?? '#$id',
  loading: () => '…',
  error: (_, _) => '#$id',
);

/// The customer's name (Customers read).
class DeliveryOrderCustomerName extends ConsumerWidget {
  const DeliveryOrderCustomerName({
    super.key,
    required this.customerId,
    this.truncate = true,
  });

  final int customerId;
  final bool truncate;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _NameText(
    _resolved(ref.watch(customerDisplayNameProvider(customerId)), customerId),
    truncate: truncate,
  );
}

/// The facility's name (Facilities read).
class DeliveryOrderFacilityName extends ConsumerWidget {
  const DeliveryOrderFacilityName({
    super.key,
    required this.facilityId,
    this.truncate = true,
  });

  final int facilityId;
  final bool truncate;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _NameText(
    _resolved(ref.watch(facilityDisplayNameProvider(facilityId)), facilityId),
    truncate: truncate,
  );
}

/// An employee's name (Employees read, or a related right the server's
/// lookup accepts). Used by the history and the proof sections.
class DeliveryOrderEmployeeName extends ConsumerWidget {
  const DeliveryOrderEmployeeName({
    super.key,
    required this.employeeId,
    this.truncate = true,
  });

  final int employeeId;
  final bool truncate;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _NameText(
    _resolved(ref.watch(employeeDisplayNameProvider(employeeId)), employeeId),
    truncate: truncate,
  );
}

/// A line's dispatch warehouse, from the order facility's warehouses
/// (Warehouses read), as `_WarehouseCell` in `refund_detail_screen.dart`.
class DeliveryOrderWarehouseName extends ConsumerWidget {
  const DeliveryOrderWarehouseName({
    super.key,
    required this.facilityId,
    required this.warehouseId,
  });

  final int facilityId;
  final int warehouseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouses = ref.watch(
      facilityWarehousesControllerProvider(facilityId),
    );
    final name = warehouses.when(
      data: (list) =>
          list.where((w) => w.warehouseId == warehouseId).firstOrNull?.name ??
          '#$warehouseId',
      loading: () => '…',
      error: (_, _) => '#$warehouseId',
    );
    return _NameText(name, truncate: true);
  }
}

/// Where the order goes. A pickup's ship-to is a facility address the
/// customer's list doesn't hold, so it shows the facility's name instead
/// (research R4). A delivery's comes from the customer's embedded addresses
/// (Customers read).
class DeliveryOrderShipTo extends ConsumerWidget {
  const DeliveryOrderShipTo({
    super.key,
    required this.type,
    required this.customerId,
    required this.facilityId,
    required this.shipToId,
    this.truncate = true,
  });

  final FulfillmentType type;
  final int customerId;
  final int facilityId;
  final int? shipToId;
  final bool truncate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (type == FulfillmentType.counterPickup) {
      return DeliveryOrderFacilityName(
        facilityId: facilityId,
        truncate: truncate,
      );
    }
    final id = shipToId;
    if (id == null) {
      return _NameText(emptyValuePlaceholder, truncate: truncate);
    }
    return _NameText(
      _fromCustomer(
        ref.watch(saleCustomerControllerProvider(customerId)),
        id,
        (customer) => customer.addresses
            .where((a) => a.addressId == id)
            .firstOrNull
            ?.label,
      ),
      truncate: truncate,
    );
  }
}

/// The order's contact, from the customer's embedded contacts (Customers
/// read): the name, then a phone when there is one.
class DeliveryOrderContact extends ConsumerWidget {
  const DeliveryOrderContact({
    super.key,
    required this.customerId,
    required this.contactId,
    this.truncate = true,
  });

  final int customerId;
  final int? contactId;
  final bool truncate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = contactId;
    if (id == null) {
      return _NameText(emptyValuePlaceholder, truncate: truncate);
    }
    return _NameText(
      _fromCustomer(ref.watch(saleCustomerControllerProvider(customerId)), id, (
        customer,
      ) {
        final contact = customer.contacts
            .where((c) => c.contactId == id)
            .firstOrNull;
        if (contact == null) return null;
        final phone = contact.phone ?? contact.mobile;
        return phone == null || phone.isEmpty
            ? contact.name
            : '${contact.name} · $phone';
      }),
      truncate: truncate,
    );
  }
}

String _fromCustomer(
  AsyncValue<Customer> customer,
  int id,
  String? Function(Customer customer) pick,
) => customer.when(
  data: (value) => pick(value) ?? '#$id',
  loading: () => '…',
  error: (_, _) => '#$id',
);
