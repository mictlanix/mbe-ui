import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart'
    hide EntityStatus, PaymentMethod;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';

part 'payment_method_option.freezed.dart';

/// A configurable payment tender available at a facility (and optionally a
/// specific warehouse) — full detail entity for the Payment Method Options
/// catalog's list and detail screens (data-model.md §1), mapped from
/// `PaymentMethodOptionResponse`.
@freezed
class PaymentMethodOption with _$PaymentMethodOption {
  const factory PaymentMethodOption({
    required int paymentMethodOptionId,
    required int facilityId,
    required String facilityName,
    int? warehouseId,
    String? warehouseName,
    required String name,
    required int numberOfPayments,
    required bool displayOnTicket,
    required int paymentMethod,
    String? commission,
    required EntityStatus status,
    // Computed server-side from the SAT payment-method code, not stored —
    // never drifts from mbe-api's own catalog (020-point-of-sale research
    // §6). Card/transfer/cheque/electronic-purse/electronic-money/food
    // vouchers/debit/service-card require one; cash and in-kind settlements
    // do not; an unrecognized code defaults to `false` so an unclassified
    // method never blocks a cashier from taking money.
    @Default(false) bool requiresReference,
  }) = _PaymentMethodOption;

  factory PaymentMethodOption.fromResponse(PaymentMethodOptionResponse r) =>
      PaymentMethodOption(
        paymentMethodOptionId: r.paymentMethodOptionId,
        facilityId: r.facility.facilityId,
        facilityName: r.facility.name,
        warehouseId: r.warehouse?.warehouseId,
        warehouseName: r.warehouse?.name,
        name: r.name,
        numberOfPayments: r.numberOfPayments,
        displayOnTicket: r.displayOnTicket,
        paymentMethod: r.paymentMethod,
        commission: r.commission,
        status: EntityStatus.fromApi(r.status),
        requiresReference: r.requiresReference,
      );
}

/// [facilityName]/[warehouseName] arrive empty only for a dangling/
/// misconfigured reference — both are always expanded on the generated
/// response when present, so this is a defensive fallback (FR-004), mirroring
/// [WarehouseFacilityDisplay]/[PointSaleFkDisplay]. [paymentMethodLabel] falls
/// back to the raw code for an unmapped value (research §5).
extension PaymentMethodOptionDisplay on PaymentMethodOption {
  String facilityDisplayName(String unknownFacilityLabel) =>
      facilityName.isNotEmpty ? facilityName : unknownFacilityLabel;

  String? warehouseDisplayName(String unknownWarehouseLabel) {
    if (warehouseId == null) return null;
    final name = warehouseName;
    return (name == null || name.isEmpty) ? unknownWarehouseLabel : name;
  }

  PaymentMethod? get paymentMethodValue =>
      PaymentMethod.fromCode(paymentMethod);
}
