import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'user_settings.freezed.dart';

/// Read-only display of a user's default facility/POS/cash-drawer references
/// (data-model.md "UserSettings"). Maps `UserSettingsResponse` /
/// `UserSettingsUpdate`. The `*Name`/`*Code` fields are resolved
/// server-side (mbe-api#79) and are display-only; `toUpdate()` sends only
/// the ids back, since names are derived, not stored, by the client.
@freezed
class UserSettings with _$UserSettings {
  const UserSettings._();

  const factory UserSettings({
    int? facilityId,
    String? facilityCode,
    String? facilityName,
    int? pointSaleId,
    String? pointSaleCode,
    String? pointSaleName,
    int? cashDrawerId,
    String? cashDrawerCode,
    String? cashDrawerName,
  }) = _UserSettings;

  factory UserSettings.fromResponse(UserSettingsResponse response) {
    return UserSettings(
      facilityId: response.facilityId,
      facilityCode: response.facilityCode,
      facilityName: response.facilityName,
      pointSaleId: response.pointSaleId,
      pointSaleCode: response.pointSaleCode,
      pointSaleName: response.pointSaleName,
      cashDrawerId: response.cashDrawerId,
      cashDrawerCode: response.cashDrawerCode,
      cashDrawerName: response.cashDrawerName,
    );
  }

  UserSettingsUpdate toUpdate() {
    return UserSettingsUpdate(
      (b) => b
        ..facilityId = facilityId
        ..pointSaleId = pointSaleId
        ..cashDrawerId = cashDrawerId,
    );
  }
}
