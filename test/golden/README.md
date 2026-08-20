# Golden tests

Spec 022's safety net (`FR-020`/`021`/`023`, User Story 3) — captures the
current appearance of every shared widget in `lib/core/widgets/` before
Phase 5's component sub-theme rollout, so that rollout's blast radius is
visible instead of invisible.

## Generating version

Baselines in `goldens/` were generated on **Flutter 3.44.2** (stable). Golden
comparisons are sensitive to the host OS, GPU, and font-rendering stack, not
just the Flutter version — treat a diff on a different machine/CI image as
inconclusive until reproduced on the generating configuration. This repo
designates **CI** as the source of truth for goldens; a local
`--update-goldens` run is advisory, not authoritative, until it lands there.
CI is `.github/workflows/test.yml` (added spec 028 T047 — no workflow existed
before that, so this line was aspirational until then), pinned to the same
Flutter 3.44.2 the baselines above were generated on.

## Workflow

```bash
# First run, or after an intentional appearance change:
flutter test test/golden --update-goldens

# Verification (what CI runs):
flutter test test/golden
```

**Font check — do this before trusting any golden.** Open one generated PNG
and confirm headings render as actual Archivo glyphs, not placeholder boxes.
Boxes mean `loadGoldenFonts()` (in `golden_harness.dart`) didn't run before
the pump, and the whole suite is verifying nothing (research R4).

## Coverage scope

`core_widgets_golden_test.dart` covers every **renderable widget** in
`lib/core/widgets/` at the time of writing, minus three deliberate
exclusions:

| File | Why excluded |
|---|---|
| `money_formatters.dart` | Static formatting utility — no `Widget` class. |
| `catalog_action_icons.dart` | `CatalogRowAction`/`CatalogAction` are plain data classes consumed by the shared row-actions component, not `Widget`s themselves. |
| `catalog_pagination.dart` | `CatalogPage<T>` is a plain data class; the pagination UI itself lives inside `data_table_view.dart`, which **is** covered. |
| `app_shell.dart` | `AppShell` requires a live `StatefulNavigationShell` from `go_router`, which cannot be meaningfully constructed in isolation. Its own visual surface (an `AppBar`/`Scaffold`/drawer composition) delegates entirely to `AppNavigation`, `BrandNavHeader`, and `UserMenuButton` — all three of which **are** covered individually, so a Phase 5 sub-theme change (`AppBarTheme`, `NavigationRailThemeData`, etc.) is still caught. |

Verified by mechanical `grep`, not memory — see the file-scan test in
`core_widgets_golden_test.dart`, which fails if a future widget file is added
to `lib/core/widgets/` without being wired into this suite (closing the gap a
purely-enumerated widget list would leave for `FR-023`'s "report, don't
silently accept" requirement).

**One class per file, not every class.** Three files define more than one
public widget (`entity_status_controls.dart`: 3, `list_state_views.dart`: 4,
`brand_logo.dart`: 2, `catalog_entity_picker.dart`: 2). Each golden covers the
file's primary/most representative class rather than every nested one — a
deliberate scope call to keep this net buildable in one pass rather than
gold-plated. The uncovered siblings share the same theming call sites as
their covered counterpart, so Phase 5's sub-theme changes are still caught;
they just aren't individually snapshotted.

## Matrix

Each covered widget gets 4 goldens: light/dark × narrow (400dp, inside the
compact tier) / wide (1024dp, inside the expanded tier) — matching
`SC-006`'s literal "light/dark × narrow/wide" requirement. This is
deliberately **not** all four `LayoutTier`s; spec.md's own User Story 3 scope
is two widths, not four (`FR-012`'s "every tier has a value" claim is a
different requirement, verified separately in `test/widget/core/design/`).
