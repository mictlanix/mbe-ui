## Tokens only — no components

This is a **tokens-only** design system: the source app (mbe-ui, spec 022) is
Flutter/Dart, so there is nothing React to bundle. `window.MbeUiTokens` is
empty. Build your own components; style them with these CSS custom
properties so the result matches the brand's actual Flutter app.

## Setup

Link `styles.css` once — no provider, no JS runtime:

```html
<link rel="stylesheet" href="styles.css">
```

Dark mode: set `data-mbe-theme="dark"` on `<html>` (or any ancestor) to force
it; omit the attribute to follow `prefers-color-scheme` automatically.

## The idiom: `var(--mbe-*)`, never a literal

Every value below is a custom property — always reference it with `var()`,
never copy the literal hex/px, so a future token change still reaches your
build. Families and real examples:

| Family | Examples |
|---|---|
| `--mbe-color-*` | `--mbe-color-primary`, `--mbe-color-on-surface`, `--mbe-color-surface-container-low`, `--mbe-color-brand-ink` (safe text color for brand hues — never use `--mbe-color-primary` itself as text) |
| `--mbe-elevation-*` | `--mbe-elevation-raised` (cards), `--mbe-elevation-floating` + `--mbe-elevation-floating-shadow` (menus/FABs) |
| `--mbe-radius-*` | `--mbe-radius-lg` (16px, cards/panels), `--mbe-radius-sm` (chips), `--mbe-radius-full` (pill buttons) |
| `--mbe-spacing-*` | fixed scale, e.g. `--mbe-spacing-md` (16px) |
| `--mbe-layout-*` | responsive layout metrics, e.g. `--mbe-layout-card-padding`, `--mbe-layout-screen-margin` — already breakpointed at 600/840/1200px, matching this brand's own tablet/desktop tiers |
| `--mbe-type-<slot>-{family,weight,size,tracking,leading}` | 21 semantic slots, e.g. `--mbe-type-card-title-family`, `--mbe-type-page-heading-size` — each slot is a full bundle of 5 properties |
| `--mbe-density-*` | `--mbe-density-min-target-size`, `--mbe-density-icon-button-size` — auto-switch under `@media (pointer: coarse)`, i.e. touch vs. mouse, not viewport width |

## Where the truth lives

`styles.css` is the single entry (`@import`s `fonts/fonts.css` then
`_ds_bundle.css`). All 177 custom properties are declared in
`_ds_bundle.css` — read it directly if a name here isn't enough context.

## Build snippet — a card, using the actual token vocabulary

```css
.card {
  background: var(--mbe-elevation-raised);
  border-radius: var(--mbe-radius-lg);
  padding: var(--mbe-layout-card-padding);
}
.card-title {
  font-family: var(--mbe-type-card-title-family);
  font-weight: var(--mbe-type-card-title-weight);
  font-size: var(--mbe-type-card-title-size);
  letter-spacing: var(--mbe-type-card-title-tracking);
  line-height: var(--mbe-type-card-title-leading);
  color: var(--mbe-color-on-surface);
}
```

Fonts: `Archivo` (headings/labels) and `RobotoMono` (record IDs/timestamps
only — never for ordinary product codes) ship in `fonts/`. Body text uses
`--mbe-font-body` which names `'Roboto'` but ships no file — the source app
never bundles it either, relying on the OS default — so body text falls
back to the system sans-serif stack unless you supply Roboto yourself.
