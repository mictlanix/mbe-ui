/// Bitmask flags mirroring mbe-api/legacy `AccessRight` (DESIGN.md §3.7).
///
/// Values combine with bitwise OR; `Privilege.rawValue` (`0`-`15`) is the sum
/// of the granted flags, e.g. `create.value | read.value == 3`.
enum AccessRight {
  none(0),
  create(1),
  read(2),
  update(4),
  delete(8);

  const AccessRight(this.value);

  final int value;
}
