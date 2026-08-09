# Quickstart: Validating Design System Tokens

**Feature**: 022-design-system-tokens

Runnable scenarios proving the feature works. Each maps to user stories and success
criteria in [spec.md](./spec.md). Token values live in [data-model.md](./data-model.md);
the API is in [contracts/design-tokens.md](./contracts/design-tokens.md).

## Prerequisites

```bash
cd /Users/augusto/development/repos/mictlanix/mbe-ui
flutter --version          # expect 3.44.2 — goldens are version-sensitive (research R4)
flutter pub get
```

> **Known pre-existing failure, unrelated to this feature.** ~126 tests currently fail to
> compile because of stale `built_value` output in `lib/generated/openapi/`. Verified
> identical on a clean checkout. Regenerate before trusting a full-suite run:
> ```bash
> cd lib/generated/openapi && dart run build_runner build --delete-conflicting-outputs
> ```
> Until then, scope runs to the directories below rather than reading a whole-suite total.

---

## Scenario 1 — Brand text and surfaces (US1, FR-001/002, SC-003)

Proves text uses the brand's ink rather than the framework's, and that the light raised
surface resolves from an approved value.

```bash
flutter test test/widget/app/app_theme_test.dart
```

**Expected**: every text role's color equals the active scheme's `onSurface`
(`#1C1A16` light, `#EFE9DF` dark) — **not** `#1D1B20` / `#E6E0E9`; `surfaceContainerLow`
is a pinned value in both brightnesses; every text role clears 4.5:1 against its surface.

Visual confirmation:

```bash
flutter run -d macos    # toggle Light/Dark in app settings
```

Body text reads warm off-white on dark and near-black on light; cards sit on the warm
raised tone in both.

---

## Scenario 2 — Token vocabulary (US2, FR-004…FR-011, SC-005/SC-008)

```bash
flutter test test/unit/core/design/
```

**Expected**:
- Every spacing step is a positive multiple of 4; radii are ordered ascending.
- Every tier-dependent metric returns a value for all four tiers — no `null`, no gap
  (`SC-005`).
- Constructing tokens under two different `BrandConfig`s returns **identical** values
  (`SC-008`) — the structural proof that product tokens are not brandable.
- A bare `ThemeData` with no extensions returns the const defaults instead of throwing
  (`FR-024`).

---

## Scenario 3 — Golden safety net (US3, FR-020/021/023, SC-006)

Generate once, then verify. **Must pass before any sub-theme work lands** (`FR-021`).

```bash
flutter test test/golden --update-goldens     # first time only
flutter test test/golden                      # verification
```

**Expected**: every shared control in `lib/core/widgets/` has 4 goldens (light/dark ×
narrow/wide). A control with no golden **fails** the run rather than passing silently
(`FR-023`).

**Font check — do this before trusting any golden.** Open one generated PNG and confirm
headings render as Archivo glyphs, not placeholder boxes. Boxes mean the `FontLoader`
setup in the harness did not run, and the whole suite is verifying nothing (research R4).

Prove the net actually catches change:

```bash
# temporarily alter a shared control's padding, then:
flutter test test/golden     # expect failure naming the control and the combination
```

---

## Scenario 4 — Components consistent everywhere (US4, FR-015…FR-018, SC-007/SC-009/SC-010)

```bash
flutter test test/widget/core/widgets/
flutter test test/golden
```

**Expected**: the same control renders identically across feature areas; one status
indicator implementation remains, not two (`SC-010`).

Manual check — the same status indicator in three places:

```bash
flutter run -d macos
# 1. Catalog → Products → a row's status
# 2. Facilities → a facility → child rows
# 3. Sales → Cash Sessions → session status
```

All three identical in shape, label treatment and density.

`SC-009` — change `CardThemeData.shape` in `lib/app/theme/` alone, rerun the goldens, and
confirm every card-bearing screen reports a diff with **zero screen files edited**.

---

## Scenario 5 — Type by role, and zero hardcoded style (US5, FR-019/FR-028, SC-001/SC-002)

```bash
# zero hardcoded typefaces or sizes outside the token definitions
grep -rn "fontFamily:\s*'" lib --include='*.dart' \
  | grep -v "^lib/generated/" | grep -v "^lib/core/design/"
grep -rn "fontSize:" lib --include='*.dart' \
  | grep -v "^lib/generated/" | grep -v "^lib/core/design/"
```

**Expected**: no output from either (`SC-001`).

```bash
# zero hardcoded colors outside the token definitions (SC-002)
grep -rn "Color(0x" lib --include='*.dart' \
  | grep -v "^lib/generated/" | grep -v "^lib/core/branding/"
grep -rn "Colors\." lib --include='*.dart' \
  | grep -v "^lib/generated/" | grep -v "^lib/core/branding/"
```

**Expected**: no output from the `Color(0x` grep. The `Colors\.` grep returns only the
documented legitimate exceptions — `Colors.transparent` as an absent-color sentinel,
`Colors.black54` matching Flutter's own barrier default, and `ColorFilter.mode(Colors.white,
…)` for asset tinting (see the original theme audit for the exact site list). Any other
result is a new hardcode and a defect (`SC-002`).

**Expected for `FR-028`**: record identifiers and timestamps render monospaced; an ordinary
product code or SKU in a table cell renders in the standard body face. Confirm on
Catalog → Products, where the SKU column stays body text.

---

## Scenario 6 — Form-factor readiness (US6, FR-012/013/014, SC-005)

```bash
flutter test test/widget/core/design/tier_resolution_test.dart
```

**Expected**: pumping at 480 / 720 / 1024 / 1440 logical px resolves `compact` / `medium` /
`expanded` / `large`, and the metrics match [data-model.md](./data-model.md).

Manual, between tablet and desktop widths (`FR-013`):

```bash
flutter run -d macos    # drag the window across 840 px
```

Screen margin, card padding and section gaps step to their documented values at the
boundary. Nothing else jumps.

Compact values resolve even though compact **layouts** are not built (`FR-014`, `FR-025`).

---

## Scenario 7 — White-label isolation and the contrast gate (FR-003/027, SC-004/SC-011)

Isolation:

```bash
flutter test test/widget/app/app_theme_test.dart
```

**Expected**: an overridden-seed config yields zero XBE-traceable values — including
`goldInk` via `BrandInk` — and identical product tokens (`SC-004`, `SC-008`).

The deployment gate — **both commands must receive identical defines** (research R6):

```bash
SEED=1B5E20
flutter test test/contract/brand_contrast_test.dart --dart-define=BRAND_SEED_COLOR=$SEED
flutter build web --dart-define=BRAND_SEED_COLOR=$SEED
```

**Expected**: the test passes and the build proceeds, for essentially any seed you try —
verified directly: `flutter test test/contract/brand_contrast_test.dart
--dart-define=BRAND_SEED_COLOR=F5E642` (a pale yellow) **passes**. `ColorScheme.fromSeed`'s
`primary` clears ~6.1:1+ against its own `surface` across every seed and
`DynamicSchemeVariant` tried (8 saturated hues, 6 near-neutral/extreme colors) — M3's tonal
system appears to structurally prevent this specific failure by construction, so a real
`--dart-define` value that fails could not be found. `brand_contrast_test.dart`'s own
"gate catches a real failure" group proves the **assertion logic** still catches a bad
color when one exists, via a synthetic pair, rather than relying on an unfindable real one
(`SC-011`).

---

## Full check

```bash
flutter analyze lib test
flutter test test/unit test/widget test/golden
```

**Expected**: analyzer clean; all three suites green. Compare against the pre-existing
baseline noted at the top — do not read a raw total as a regression signal until the
generated client is regenerated.

## Success criteria coverage

| Scenario | Covers |
|---|---|
| 1 | SC-003 |
| 2 | SC-005, SC-008 |
| 3 | SC-006 |
| 4 | SC-007, SC-009, SC-010 |
| 5 | SC-001, SC-002 |
| 6 | SC-005 |
| 7 | SC-004, SC-011 |
