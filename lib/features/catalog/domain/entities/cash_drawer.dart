import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';

part 'cash_drawer.freezed.dart';

/// A cash-handling station belonging to exactly one facility — full detail
/// entity for the CashDrawers catalog's list and detail screens
/// (data-model.md "CashDrawer"), mapped from `CashDrawerResponse`.
/// Structurally identical to [Warehouse] (research.md §3).
@freezed
class CashDrawer with _$CashDrawer {
  const factory CashDrawer({
    required int cashDrawerId,
    required int facilityId,
    required String facilityName,
    required String code,
    required String name,
    String? comment,
    required EntityStatus status,
  }) = _CashDrawer;

  factory CashDrawer.fromResponse(CashDrawerResponse r) => CashDrawer(
    cashDrawerId: r.cashDrawerId,
    facilityId: r.facility.facilityId,
    facilityName: r.facility.name,
    code: r.code,
    name: r.name,
    comment: r.comment,
    status: EntityStatus.fromApi(r.status),
  );
}

/// [facilityName] arrives empty only for a dangling/misconfigured reference
/// — the generated `CashDrawerResponse.facility` is always expanded and
/// non-null, so this is a defensive fallback rather than a case the API can
/// actually return today (FR-018). Kept as an extension, not baked into
/// [CashDrawer.fromResponse], so the domain entity stays free of `BuildContext`/l10n
/// — the caller supplies the localized fallback label.
extension CashDrawerFacilityDisplay on CashDrawer {
  String facilityDisplayName(String unknownFacilityLabel) =>
      facilityName.isNotEmpty ? facilityName : unknownFacilityLabel;
}
