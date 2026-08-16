# Quickstart: Validating 027-app-user-settings

**Feature**: 027-app-user-settings | **Branch**: `027-app-user-settings`

How to prove this feature works end to end. Details of *what* each thing does
live in [contracts/](contracts/) and [data-model.md](data-model.md); this file
is the run guide.

---

## Prerequisites

- Flutter toolchain as used by the repo (`flutter --version`).
- mbe-api reachable at `API_BASE_URL` for the live scenarios (§3 onward).
  The automated suites in §1–§2 need no backend.
- A `.env` at the repo root for local work — gitignored, and already the home
  of integration-test credentials. `.env.template` documents both sections
  (test credentials and app settings); copy it and fill in only what you need.
- Deployment configuration lives in its own per-customer file, e.g.
  `deploy/casa-maestra.env`, passed the same way.

---

## 1. Static gates

```bash
flutter analyze
flutter test test/unit/core/
```

Expected: `layering_test.dart` and `l10n_parity_test.dart` pass — the new
settings screen adds strings to **both** `.arb` files.

> Formatting is **out of scope** for this feature (spec.md Clarifications), so
> there is no formatting guard and no formatter migration to validate. The
> checks for those live with the future formatting spec; its contract is
> already written in [contracts/formatting-surface.md](contracts/formatting-surface.md).

---

## 2. Nothing rendered changed

```bash
flutter test test/golden/ test/screenshots/
```

Expected: **pass with no re-baselining** — the strongest single check that
this feature is behaviour-preserving everywhere it isn't deliberately changing
a screen. Two things could break it: a formatting call touched by accident, or
a text-scaling mechanism that isn't the identity at the default level
(research R1). Investigate before running `--update-goldens`; a mass
re-baseline here would hide real regressions.

---

## 3. Deployment configuration

Configure a deployment without touching source:

```bash
cat > /tmp/alt.env <<'EOF'
DEFAULT_LOCALE=en_US
API_BASE_URL=http://192.168.1.50:8000
BRAND_DISPLAY_NAME=CASA MAESTRA
EOF

flutter run -d macos --dart-define-from-file=/tmp/alt.env
```

Expected: the interface comes up in English, against that host, under that
brand name — with no source change.

Then prove the fallbacks:

```bash
flutter run -d macos                                 # no .env at all
flutter run -d macos --dart-define=DEFAULT_LOCALE=xx_YY
flutter run -d macos --dart-define=POS_DEFAULT_CUSTOMER_ID=abc
```

Expected: all three start normally on documented defaults. A malformed value
must never prevent startup.

---

## 4. User settings

```bash
flutter run -d macos --dart-define-from-file=.env
```

1. Open the user menu → **Settings**. It sits beside Change password.
2. **Appearance** → Dark. The whole app changes immediately.
3. **Text size** → each of the four levels. Text scales app-wide.
4. **Language** → English, then Español. The interface language changes
   immediately (research R9).
5. Restart the app. All three choices are still in effect, **with no flash of
   the default theme on launch** — that flash exists today and this feature
   removes it (research R5).
6. With unsaved input in some form, change the language: the input survives.

```bash
flutter test test/widget/features/settings/
```

---

## 5. The largest text size (FR-024)

The one place this genuinely constrains the design:

```bash
flutter test test/widget/features/sales/sale_line_row_test.dart
```

Expected: passes at all four levels. At `extraLarge` on a 1024 px surface the
line is expected to **fall back to the two-row layout** — that is the
responsive design working, not a failure. What must never happen is an
overflow.

Manually, at `extraLarge`, walk the POS capture screen, the settings screen
itself, and two or three catalog lists at 1280 px: nothing clips, overflows or
hides content.

---

## 6. The two remediated screens

**POS sales list** (`/sales/pos`):

1. The filter row shows the search box, the New sale action, and **one badged
   filters button** — no inline chips.
2. Open the drawer, set a date range and a status. The list filters and the
   URL carries both facets, exactly as before.
3. The badge shows the active-filter count.
4. Clear all → returns to **today's range**, not an unbounded one.

**Cash sessions** (`/sales/cash-sessions`):

1. The route is a standard list screen — no form above the list.
2. With no open shift: the toolbar action reads as "open a shift". Activating
   it opens the sheet.
3. Open a shift → the sheet dismisses, the history list refreshes without a
   manual reload, and the toolbar action now reflects an open shift.
4. With an open shift, the sheet shows drawer, start, opening amount, payments
   by method, and the close action. With a stale one, the stale warning too,
   and the toolbar action says so.
5. As a user without the open-shift privilege: the toolbar action is
   **absent**, not disabled.
6. From the sheet, trigger the blocked-by-another-session error and follow its
   link — the sheet dismisses cleanly rather than stranding over the new route.

```bash
flutter test test/widget/features/sales/
```

---

## 7. Alignment (FR-031/032/035)

```bash
flutter test test/widget/features/sales/ -n "symmetry"
```

Expected: measured top inset equals bottom inset, and the control band's text
baseline equals the line total's, in all three sale-line layouts. Visually,
the extra space under a sale line reported in the spec is gone.

---

## Full suite

```bash
flutter analyze && flutter test
```

Everything above, plus the existing suites. No mbe-api change is required at
any point (SC-011).
