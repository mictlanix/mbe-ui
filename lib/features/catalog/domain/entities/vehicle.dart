import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'vehicle.freezed.dart';

/// A fleet vehicle — full detail entity for the Vehicles catalog
/// (data-model.md §2), mapped from `VehicleResponse`. No external picker
/// consumer, so this single entity covers both list and detail rendering
/// (research.md §3).
@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required int vehicleId,
    required String licensePlate,
    required String name,
    required String nickname,
    required int tonsCapacity,
    required bool active,
  }) = _Vehicle;

  factory Vehicle.fromResponse(VehicleResponse response) {
    return Vehicle(
      vehicleId: response.vehicleId,
      licensePlate: response.licensePlate,
      name: response.name,
      nickname: response.nickname,
      tonsCapacity: response.tonsCapacity,
      active: response.active,
    );
  }
}
