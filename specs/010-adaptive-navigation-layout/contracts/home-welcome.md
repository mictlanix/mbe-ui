# Contract: HomeWelcome — `features/home/presentation/home_welcome.dart`

The Home destination body: a branded welcome that never renders blank (FR-015–FR-017).

## Signature

```dart
class HomeWelcome extends ConsumerWidget {
  const HomeWelcome({super.key});
}
```

## Behavior

- Reads `brandConfigProvider`.
- If `brand.hasWelcomeAsset`: renders the configured `welcomeAsset` (image) plus the brand `displayName` / welcome message (FR-015). If that image fails to load, `Image.errorBuilder` falls back to the placeholder (edge case: broken brand asset).
- If not: renders the bundled default placeholder `assets/branding/default_welcome.png` and a generic localized welcome message (FR-016). Key `Key('home_welcome_default')`.
- Content is centered and constrained (e.g. `maxWidth`, `BoxFit.contain`) so it scales without overflow/clipping on any tier (FR US3 scenario 3).
- Contains **no** navigation list — navigation lives in the shell; Change Password lives in the user menu (FR-017).

## Acceptance (widget test `home_welcome_test.dart`)

1. With `brandConfigProvider` overridden to a config with a welcome asset, the branded image + display name render.
2. With the default config (no asset), the default placeholder (`home_welcome_default`) and generic welcome message render.
3. The widget renders no `ListTile` navigation entries (regression guard for the old Home nav list).
4. Renders without overflow at widths 400 and 1400 (pump at both sizes).
