import 'package:mbe_api_client/mbe_api_client.dart' as api;

/// The kind of operating site a [Facility] is — the merged successor of the
/// legacy Store and Production Site concepts (spec 014 Clarifications,
/// confirmed against the mbe-api source: `class FacilityType(IntEnum): STORE
/// = 0, PRODUCTION_SITE = 1`, mictlanix/mbe-api#92).
///
/// Hand-written because openapi-generator renders the wire enum as opaque
/// `number0`/`number1` constants; [fromApi]/[toApi] are the only places that
/// name them, so the rest of the app reads in domain terms. Shape mirrors
/// [EntityStatus] in `lib/core/domain/entity_status.dart` (FR-026).
enum FacilityType {
  store(0),
  productionSite(1);

  const FacilityType(this.value);

  /// The integer mbe-api serializes this type as.
  final int value;

  /// Looks up the [FacilityType] whose [value] matches mbe-api's `type`
  /// integer. Returns `null` for an unrecognized code — callers MUST fall
  /// back gracefully rather than crash, same posture as [EntityStatus.fromValue].
  static FacilityType? fromValue(int value) {
    for (final type in FacilityType.values) {
      if (type.value == value) return type;
    }
    return null;
  }

  /// Maps the generated wire enum onto its domain counterpart. Unknown
  /// values degrade to [FacilityType.store] so a future server-side value
  /// renders as an ordinary record instead of crashing the list.
  static FacilityType fromApi(api.FacilityType type) {
    if (type == api.FacilityType.number1) return FacilityType.productionSite;
    return FacilityType.store;
  }

  /// The generated wire enum for this type, for request bodies.
  api.FacilityType toApi() => switch (this) {
    FacilityType.store => api.FacilityType.number0,
    FacilityType.productionSite => api.FacilityType.number1,
  };
}
