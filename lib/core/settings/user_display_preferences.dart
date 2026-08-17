import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/text_scale.dart';

/// The signed-in user's personal, device-local display choices (spec 027
/// FR-016–FR-024) — appearance, text size, language. Deliberately **not**
/// named `UserSettings`: that type already exists
/// (`core/access/user_settings.dart`) for the server-side cash
/// drawer/point-of-sale assignment, an operational concern that follows the
/// user across devices. This one is display taste that does not
/// (constitution §V) — persisted via `shared_preferences`
/// (`UserDisplayPreferencesController`), never synced through mbe-api.
@immutable
class UserDisplayPreferences {
  const UserDisplayPreferences({
    this.themeMode = ThemeMode.system,
    this.textSizeLevel = TextSizeLevel.normal,
    this.localeOverride,
  });

  final ThemeMode themeMode;
  final TextSizeLevel textSizeLevel;

  /// `null` means "no personal choice" — the deployment's default locale
  /// (`AppSettings.defaultLocale`) applies (spec 027 FR-018).
  final Locale? localeOverride;

  UserDisplayPreferences copyWith({
    ThemeMode? themeMode,
    TextSizeLevel? textSizeLevel,
    Locale? Function()? localeOverride,
  }) {
    return UserDisplayPreferences(
      themeMode: themeMode ?? this.themeMode,
      textSizeLevel: textSizeLevel ?? this.textSizeLevel,
      localeOverride: localeOverride != null ? localeOverride() : this.localeOverride,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserDisplayPreferences &&
      other.themeMode == themeMode &&
      other.textSizeLevel == textSizeLevel &&
      other.localeOverride == localeOverride;

  @override
  int get hashCode => Object.hash(themeMode, textSizeLevel, localeOverride);
}
