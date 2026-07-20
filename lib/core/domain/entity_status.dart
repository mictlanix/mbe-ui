import 'package:mbe_api_client/mbe_api_client.dart' as api;

/// Unified lifecycle state shared by every status-bearing entity, mirroring
/// mbe-api's `EntityStatus` IntEnum (mbe-api spec 005, fixes mbe-api#80 and
/// mbe-api#81). Replaces the old per-entity boolean flags — `disabled`
/// (User, Customer), `active` (Employee, Vehicle, VehicleOperator) and
/// `deactivated` (Product) — which each carried their own polarity.
///
/// Hand-written because openapi-generator renders the wire enum as opaque
/// `number0`/`number1`/`number2` constants; [fromApi]/[toApi] are the only
/// places that name them, so the rest of the app reads in domain terms.
/// Shape mirrors [Gender] in `lib/core/domain/gender.dart`.
enum EntityStatus {
  active(0),
  inactive(1),
  archived(2);

  const EntityStatus(this.value);

  /// The integer mbe-api serializes this state as.
  final int value;

  /// Looks up the [EntityStatus] whose [value] matches mbe-api's `status`
  /// integer. Returns `null` for an unrecognized code — callers MUST fall
  /// back gracefully rather than crash, same posture as [Gender.fromValue].
  static EntityStatus? fromValue(int value) {
    for (final status in EntityStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }

  /// Maps the generated wire enum onto its domain counterpart. Unknown
  /// values degrade to [EntityStatus.active] so a future server-side state
  /// renders as an ordinary record instead of crashing the list.
  static EntityStatus fromApi(api.EntityStatus status) {
    if (status == api.EntityStatus.number1) return EntityStatus.inactive;
    if (status == api.EntityStatus.number2) return EntityStatus.archived;
    return EntityStatus.active;
  }

  /// The generated wire enum for this state, for request bodies and the
  /// uniform `?status=` list filter.
  api.EntityStatus toApi() => switch (this) {
    EntityStatus.active => api.EntityStatus.number0,
    EntityStatus.inactive => api.EntityStatus.number1,
    EntityStatus.archived => api.EntityStatus.number2,
  };
}
