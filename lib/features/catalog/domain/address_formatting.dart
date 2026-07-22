import 'package:mbe_api_client/mbe_api_client.dart';

/// Renders an [AddressResponse] as one readable line (FR-035): street +
/// exterior/interior number, neighborhood, city/state — falling back
/// gracefully when optional parts are absent. Shared by [Facility] (the
/// facility form's read display) and `AddressListItem` (the address picker's
/// suggestion rows), so both surfaces describe an address identically.
String formatAddress(AddressResponse a) {
  final numberPart = a.interiorNumber == null || a.interiorNumber!.isEmpty
      ? a.exteriorNumber
      : '${a.exteriorNumber} Int. ${a.interiorNumber}';
  final cityPart = a.city == null || a.city!.isEmpty ? a.state : a.city!;
  return '${a.street} $numberPart, ${a.neighborhood}, $cityPart';
}
