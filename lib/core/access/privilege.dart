import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'access_right.dart';
import 'system_object.dart';

part 'privilege.freezed.dart';

/// A single user's CRUD bitmask for one [SystemObject] (data-model.md
/// "Privilege"). Maps `PrivilegeResponse` / `PrivilegeUpdate`.
@freezed
class Privilege with _$Privilege {
  const Privilege._();

  @Assert('rawValue >= 0 && rawValue <= 15', 'rawValue must be in 0..15')
  const factory Privilege({
    required SystemObject systemObject,
    required int rawValue,
  }) = _Privilege;

  /// Returns `null` if `response.systemObject` does not map to a known
  /// [SystemObject] (e.g. a legacy disabled code) — callers should drop such
  /// entries, which is safe under deny-by-default RBAC.
  static Privilege? fromResponse(PrivilegeResponse response) {
    final object = SystemObject.fromValue(response.systemObject);
    if (object == null) return null;
    return Privilege(systemObject: object, rawValue: response.privileges);
  }

  bool get allowCreate => has(AccessRight.create);

  bool get allowRead => has(AccessRight.read);

  bool get allowUpdate => has(AccessRight.update);

  bool get allowDelete => has(AccessRight.delete);

  bool has(AccessRight right) => rawValue & right.value != 0;

  PrivilegeUpdate toUpdate() {
    return PrivilegeUpdate(
      (b) => b
        ..systemObject = systemObject.value
        ..privileges = rawValue,
    );
  }
}
