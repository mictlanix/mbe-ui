# Contract: Brand definition and build selection

## Selecting a brand

| `BRAND_ID` value | Brand used | Legacy `BRAND_*` flags |
| --- | --- | --- |
| absent or empty | `xbe` | Honored exactly as before (spec 019) |
| `mbe` or `xbe` | `xbe` | Honored |
| `xbe.cm` | Casa Maestra | Ignored |
| anything else | `xbe`, with a debug-only log line | Honored |

- Startup never fails on this value (FR-003).
- `BRAND_ID` is listed in `.env.template` with an empty default.
- Release builds get the value from `tool/release.sh`, never from a deployment `.env` (contracts/release-brand.md).

## What a brand may set (FR-005)

A brand may set its color roles, typography (families and per-style metrics) and logo assets, plus its display name and login-pane style. Nothing else is a brand field.

## Casa Maestra (`xbe.cm`)

- **Seed**: `#00325F`, with `fidelity` as the dynamic-scheme variant.
- **`ColorScheme` overrides**, light and dark, values exactly as in spec.md › Verbatim Constraints:
  - `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`
  - `error`, `onError`, `errorContainer`, `onErrorContainer`
  - `surface`, `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`
  - `onSurface`, `onSurfaceVariant`, `outline`, `outlineVariant`, `scrim`
- **`SemanticColors`**:
  - The accent, success and warning families use the spec's values.
  - `onSuccess` and `onWarning` are `#FFFFFF` in light. In dark they are `#00210D` and `#2A1700`.
- **`brand-navy` and `brand-red`** are constants on the definition, used only by the logo-related login pane. Neither is a theme role.
- **Typography**:
  - Display, headline and title styles use `Bitter`. Body and label styles use `BrandRoboto`.
  - Metrics come from the spec's type table.
  - Mono stays `RobotoMono`.
- **Assets**, under `assets/brand/xbe.cm/` with `2.0x/` and `3.0x/` variants:
  - `casa-maestra-logo.png` is the lockup.
  - `casa-maestra-logo-reversed.png` is the reversed lockup.
  - `casa-maestra-mark.png` is the mark.
- **Login pane**: follows the theme. It shows the lockup in light and the reversed lockup in dark, with one accent bar.

## XBE (`xbe`, the default)

- Seed, pins, Archivo weights and assets are moved, not changed, from `XbePalette`, `AppTheme` and `BrandConfig`. `AppTheme.of(defaultBrand)` MUST produce a `ThemeData` whose `colorScheme` and `textTheme` equal today's. This is the existing `app_theme_test.dart`, which keeps passing unchanged.
- **`SemanticColors`**:
  - The accent family comes from the scheme's `tertiary`, `onTertiary`, `tertiaryContainer` and `onTertiaryContainer`.
  - Success and warning use the Casa Maestra values.
- **Login pane**: today's always-dark `XbePalette` pane with red, orange and gold bars.

## Contrast gate (FR-020)

`test/contract/brand_contrast_test.dart` runs for every registered brand and both brightnesses. It checks:

- 4.5:1 for each `on*` / background pair, including the 12 semantic roles, and for `onSurface` and `onSurfaceVariant` on every `surface*` role.
- 3:1 for `outline` on `surface`.

A new brand that fails cannot merge.
