import 'package:mbe_api_client/mbe_api_client.dart' as api;

/// The kind of address an [Address] represents (spec 014 FR-033), confirmed
/// against the mbe-api source: `class AddressType(IntEnum): OTHER = 0, HOME
/// = 1, WORK = 2, BUSINESS = 3, FISCAL = 4`.
///
/// Hand-written because openapi-generator renders the wire enum as opaque
/// `number0`-`number4` constants; [fromApi]/[toApi] are the only places
/// that name them, so the rest of the app reads in domain terms. Shape
/// mirrors [FacilityType] in `lib/core/domain/facility_type.dart`.
enum AddressType {
  other(0),
  home(1),
  work(2),
  business(3),
  fiscal(4);

  const AddressType(this.value);

  /// The integer mbe-api serializes this type as.
  final int value;

  /// Looks up the [AddressType] whose [value] matches mbe-api's `type`
  /// integer. Returns `null` for an unrecognized code — callers MUST fall
  /// back gracefully rather than crash, same posture as [FacilityType.fromValue].
  static AddressType? fromValue(int value) {
    for (final type in AddressType.values) {
      if (type.value == value) return type;
    }
    return null;
  }

  /// Maps the generated wire enum onto its domain counterpart. Unknown
  /// values degrade to [AddressType.other] so a future server-side value
  /// renders as an ordinary record instead of crashing the picker.
  static AddressType fromApi(api.AddressType type) => switch (type) {
    api.AddressType.number1 => AddressType.home,
    api.AddressType.number2 => AddressType.work,
    api.AddressType.number3 => AddressType.business,
    api.AddressType.number4 => AddressType.fiscal,
    _ => AddressType.other,
  };

  /// The generated wire enum for this type, for request bodies.
  api.AddressType toApi() => switch (this) {
    AddressType.other => api.AddressType.number0,
    AddressType.home => api.AddressType.number1,
    AddressType.work => api.AddressType.number2,
    AddressType.business => api.AddressType.number3,
    AddressType.fiscal => api.AddressType.number4,
  };
}
