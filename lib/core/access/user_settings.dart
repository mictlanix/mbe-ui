import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'user_settings.freezed.dart';

/// Read-only display of a user's default store/POS/cash-drawer references
/// (data-model.md "UserSettings"). Maps `UserSettingsResponse` /
/// `UserSettingsUpdate`; the referenced IDs are opaque to this feature.
@freezed
class UserSettings with _$UserSettings {
  const UserSettings._();

  const factory UserSettings({
    int? storeId,
    int? pointSaleId,
    int? cashDrawerId,
  }) = _UserSettings;

  factory UserSettings.fromResponse(UserSettingsResponse response) {
    return UserSettings(
      storeId: response.storeId,
      pointSaleId: response.pointSaleId,
      cashDrawerId: response.cashDrawerId,
    );
  }

  UserSettingsUpdate toUpdate() {
    return UserSettingsUpdate((b) => b
      ..storeId = storeId
      ..pointSaleId = pointSaleId
      ..cashDrawerId = cashDrawerId);
  }
}
