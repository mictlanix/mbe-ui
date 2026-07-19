/// Gender codes mirroring mbe-api/legacy `GenderEnum`
/// (`mbe/docs/constants.md` §GenderEnum). Hand-written — mbe-api exposes
/// `Employee.gender` as a bare `int` with no published enum schema to
/// generate from (spec 012 research.md §6). Shape mirrors
/// `lib/core/domain/currency.dart` / `lib/core/access/system_object.dart`.
enum Gender {
  female(0),
  male(1);

  const Gender(this.value);

  final int value;

  /// Looks up the [Gender] whose [value] matches mbe-api's `gender` integer.
  /// Returns `null` for an unrecognized code — callers MUST fall back
  /// gracefully rather than crash, same posture as [Currency.fromValue].
  static Gender? fromValue(int value) {
    for (final gender in Gender.values) {
      if (gender.value == value) return gender;
    }
    return null;
  }
}
