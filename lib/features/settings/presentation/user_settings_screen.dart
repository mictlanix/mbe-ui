import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The signed-in user's display-preferences screen (spec 027 US3,
/// FR-016–FR-024): appearance, text size, language. Reachable from the user
/// menu beside "Change password" (`user_menu_button.dart`). No RBAC gate —
/// display preferences are personal, available to every signed-in user
/// (constitution §V) — and every control applies immediately, with no
/// separate Save step (FR-020), which is why this screen's `AppBar.actions`
/// is empty and there is no `RecordFormActions` action area: there is
/// nothing to save.
class UserSettingsScreen extends ConsumerWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final preferences = ref.watch(userDisplayPreferencesControllerProvider);
    final controller = ref.read(userDisplayPreferencesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveFormGrid(
          children: [
            FormGridChild(
              _AppearanceSection(
                value: preferences.themeMode,
                onChanged: controller.setThemeMode,
              ),
              span: FormGridSpan.full,
            ),
            FormGridChild(
              _TextSizeSection(
                value: preferences.textSizeLevel,
                onChanged: controller.setTextSizeLevel,
              ),
              span: FormGridSpan.full,
            ),
            FormGridChild(
              _LanguageSection(
                value: preferences.localeOverride,
                onChanged: controller.setLocaleOverride,
              ),
              span: FormGridSpan.full,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  const _SettingsSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsSectionLabel(l10n.settingsAppearanceLabel),
        SegmentedButton<ThemeMode>(
          key: const Key('settings_appearance_selector'),
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(l10n.settingsAppearanceLight),
              icon: const Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(l10n.settingsAppearanceDark),
              icon: const Icon(Icons.dark_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.settingsAppearanceSystem),
              icon: const Icon(Icons.brightness_auto_outlined),
            ),
          ],
          selected: {value},
          onSelectionChanged: (selected) => onChanged(selected.first),
        ),
      ],
    );
  }
}

class _TextSizeSection extends StatelessWidget {
  const _TextSizeSection({required this.value, required this.onChanged});

  final TextSizeLevel value;
  final ValueChanged<TextSizeLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String label(TextSizeLevel level) => switch (level) {
      TextSizeLevel.small => l10n.settingsTextSizeSmall,
      TextSizeLevel.normal => l10n.settingsTextSizeNormal,
      TextSizeLevel.large => l10n.settingsTextSizeLarge,
      TextSizeLevel.extraLarge => l10n.settingsTextSizeExtraLarge,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsSectionLabel(l10n.settingsTextSizeLabel),
        SegmentedButton<TextSizeLevel>(
          key: const Key('settings_text_size_selector'),
          segments: [
            for (final level in TextSizeLevel.values)
              ButtonSegment(value: level, label: Text(label(level))),
          ],
          selected: {value},
          onSelectionChanged: (selected) => onChanged(selected.first),
        ),
      ],
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection({required this.value, required this.onChanged});

  /// `null` means "follow system" (no personal override — spec 027 FR-018).
  final Locale? value;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsSectionLabel(l10n.settingsLanguageLabel),
        SegmentedButton<Locale?>(
          key: const Key('settings_language_selector'),
          segments: [
            ButtonSegment(
              value: const Locale('es'),
              label: Text(l10n.settingsLanguageSpanish),
            ),
            ButtonSegment(
              value: const Locale('en'),
              label: Text(l10n.settingsLanguageEnglish),
            ),
            ButtonSegment(value: null, label: Text(l10n.settingsLanguageSystem)),
          ],
          selected: {value},
          onSelectionChanged: (selected) => onChanged(selected.first),
        ),
      ],
    );
  }
}
