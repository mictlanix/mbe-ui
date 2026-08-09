# design-sync notes — mbe-ui-tokens

## What this is

A **hand-authored tokens-only** sync, not a real npm package converted by
the usual pipeline. The source app (`mbe-ui`) is Flutter/Dart — there is no
`package.json`, no `dist/`, no React components. `.design-sync/config.json`
points `pkg`/`--entry` at a synthetic scratch package (`dist/index.js`
exports nothing) purely so `package-build.mjs` would take its documented
`[ZERO_MATCH] … treating as tokens-only DS` branch and emit a correctly-
shaped bundle/anchor from a hand-written `styles.css`, instead of the
values being reverse-engineered by hand into the upload format.

The scratch package itself is NOT committed (it lived under this session's
`/private/tmp` scratchpad and vanished when the session ended). The
`styles.css` fed to the converter was authored by hand from:

- `lib/core/branding/{xbe_palette,brand_ink}.dart` (colors)
- `lib/core/design/{spacing,shapes,elevations,density,type_roles}.dart` (spacing/shape/elevation/density/type)
- Flutter SDK's own `Typography.material2021` `englishLike2021` table (font sizes/line-heights/tracking — the app itself never restates these, so this file doesn't invent them either)

## Re-sync risks — what can silently go stale

- **No automated diffing.** Because there's no real package to rebuild from,
  a future Dart-side token change (edit `spacing.dart`, add a color role,
  etc.) will NOT be caught by re-running anything here. Whoever re-syncs
  must manually re-diff the CSS against current Dart source, or re-run the
  probe test used to extract ColorScheme/Elevation hex values (see below)
  before trusting the numbers.
- **Two values are explicitly unconfirmed**, carried over honestly from the
  Dart source's own doc comments — do not "fix" them without checking with
  the brand owner first:
  - `--mbe-color-surface-container-low` (light) is interpolated
    (`xbe_palette.dart`'s own comment: no approved value exists).
  - Archivo tracking corrections for display*/headlineLarge at w700 were
    never measured against brand mockups — this file uses M3's own
    (unmodified) tracking, same as the app does today.
- **Body text (`--mbe-font-body: 'Roboto'`) ships no font file.** The app
  itself never bundles Roboto either (relies on the OS default), so this
  is consistent, but a design agent's output will render body text in
  whatever sans-serif the browser substitutes, not real Roboto.
- **To regenerate the type-scale numbers from scratch**: `ThemeData(...).textTheme`
  read directly in a bare `flutter test` returns null-valued fields in
  this SDK snapshot (an environment quirk, not an app bug) — do NOT trust
  a live probe for font-size/line-height/tracking; read them from the
  Flutter SDK's `packages/flutter/lib/src/material/typography.dart`
  `englishLike2021` table instead, exactly as this sync did. Colors and
  elevation surface tones DID resolve correctly from a live probe test
  (`AppTheme.of(BrandConfig(...))`) — that path is fine to reuse.
