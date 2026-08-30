# Implementation Plan: Price List Retirement UI

**Branch**: `034-price-list-retirement-ui` | **Date**: 2026-08-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/034-price-list-retirement-ui/spec.md`

## Summary

Replace the one-line delete confirmation on the price list edit screen with a
review dialog: what the deletion destroys, what it moves, where the customers go,
an explicit acknowledgment, and a refusal shown *before* submitting when the list
cannot be retired at all. Design base is `artifacts/price_list_delete/`; the
capability comes from mbe-api's `015-price-list-retirement` (PR #186).

Twelve findings shape the work ([research.md](./research.md)); five of them change
what gets built:

1. **Nothing upstream is missing** (R1). The API merged and the checked-in
   generated client already carries both the preview call and `replacement` on
   delete. No mbe-api issue, no codegen run, no hand-written DTO — unusually for
   a feature this size, the whole diff is mbe-ui presentation and domain.

2. **The category→fate mapping must match whole keys, not table prefixes** (R2).
   `product_price.list` and `customer.price_list` are the two known relations;
   *everything else blocks*. Copying `MergePreviewCategory.isDestroyed`'s
   `startsWith('product_price.')` would classify a future `product_price.<other>`
   as "deleted with the list" — inverting the upstream guarantee that an
   unfamiliar relation fails loudly.

3. **The formatting surface has no count formatter, and the guard forbids a local
   one** (R3). `display.quantity` applies no grouping and
   `test/unit/core/formatting_guard_test.dart` bans `package:intl` outside its
   allowlist, so `4,312` is reachable only by adding `DisplayFormatters.count(int)`
   to `lib/core/formatting/app_formatters.dart`. One method — the single file
   this feature touches outside `features/pricing/`.

4. **`delete()` must return an outcome, not set a `deleted` flag** (R9). This is
   the feature's one real trap: today the screen pops on `formState.deleted` in a
   post-frame callback, which with a dialog on the stack pops **the dialog**, not
   the screen. The dialog returns its result instead; `deleted` is removed.

5. **`RecordFormActions` needs no change** (R7). Its `deleteConfirmation: null`
   branch already calls `onDelete` directly — a documented, until-now-unused path
   — so the richer dialog costs nothing in the component shared by 18 screens.

Net: two domain entities, two repository methods (one new, one gaining an
optional parameter), one provider, one dialog, one summary widget, one formatter
method, ~24 l10n keys in two files, one retired key, and eight test files.

## Technical Context

**Language/Version**: Dart 3.x / Flutter (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `freezed`,
`go_router`, `dio` via the generated `mbe_api_client`, `flutter_localizations`/
`intl`. **No new dependency, no codegen run** (R1).

**Storage**: N/A — online-only (§VII). Dialog state lives for the dialog.

**Testing**: `flutter_test` (unit + widget), `integration_test` against a live
mbe-api

**Target Platform**: Web (Chrome) primary, macOS/desktop; compact tier < 600 px

**Project Type**: Single Flutter application, feature-first layering

**Performance Goals**: one request when the dialog opens (the preview), one on
confirm (the delete). The replacement picker adds one debounced search per query,
as every `CatalogEntityPicker` does.

**Constraints**: the deletion is irreversible with no undo upstream; counts reach
five figures and must group (R3); the preview and the delete can disagree, so the
409 path stays implemented even though the blocked state predicts it (R11); no
mbe-api edit may be made from this repo (§III).

**Scale/Scope**: 1 new dialog, 1 new widget, 1 new provider, 2 new entities, 1
repository method added + 1 signature widened, 1 formatter method, 2 `.arb`
files, 8 test files.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design. Both
passes reach the same verdict: **PASS, no violations, Complexity Tracking
empty**.*

| Principle | Assessment |
|---|---|
| **I. Feature-First Layered Architecture** | PASS. Everything lands in `lib/features/pricing/`: entities in `domain/entities/`, the call declared in `domain/repositories/` and implemented in `data/`, dialog and widget in `presentation/`. `presentation` imports `domain` only. The single file outside the feature is `core/formatting/app_formatters.dart` (R3) — the shared surface §V mandates, not a feature file. The merge widget's humanizer is duplicated rather than imported precisely to avoid a `pricing/presentation → catalog/presentation` edge (R6). |
| **II. Riverpod for State & DI** | PASS. The preview is a `@riverpod` auto-disposing family whose `AsyncValue` renders three of the seven dialog states (R4). The acknowledgment and the chosen replacement stay in the dialog's own `State` — per-widget input state with the dialog's lifetime, which §II names as local UI state. The repository is reached through `priceListRepositoryProvider`, so every test overrides it with a mock. |
| **III. Contract-Driven API Integration** | PASS. No hand-written DTO: the generated `PriceListDeletePreviewResponse` maps to a `freezed` entity in `domain/` before reaching `presentation`. No codegen run is needed (R1) and none is faked. No mbe-api source is touched from this repo, and no upstream change is required, so there is nothing to file. Errors flow through the existing `mapDioException`/`AppError`/`ErrorBanner` path (R10) — no new error type. No multipart is involved. |
| **IV. Deny-by-Default RBAC** | PASS. Delete stays gated on `can(priceLists, delete)` and stays **absent** rather than disabled without it (FR-021); the controller re-checks before submitting, as it does today. This feature changes what the action opens, never who sees it. |
| **V. Material 3, White-Labeled** | PASS. `AlertDialog`, `CheckboxListTile`, `CatalogEntityPicker`, `ErrorBanner` — all Material 3, no Cupertino branch. Colour and typography from `Theme.of(context)`, spacing from the spec 022 tokens; the artboards' hex values and pixel offsets are treated as presentation, not requirement. Counts go through the formatting surface, extended by exactly one method rather than bypassed (R3). Every new string in both `.arb` files with `es-MX` authored first, enforced by `l10n_parity_test`. |
| **VI. Desktop/Web-First, Compact-Ready** | PASS, and this feature is *more* compliant than what it replaces. §VI requires Delete on the record's own detail screen and bans a per-row Delete icon — which is exactly the decision recorded in R8, so "no list-screen row action" is not merely a scope choice. `RecordFormActions` keeps rendering Delete in its fixed order (R7). No data table is added; the breakdown is a bordered panel, not a `DataTableView`, so the pagination and truncation rules do not engage. Counts are critical info and are never ellipsized. |
| **VII. Online-Only, Server-Rendered Documents** | PASS. Auto-disposing provider, no cache, no offline path. No document rendering. |

**Quality-gates clause** (§ Development Workflow): mbe-api *has* changed endpoints
relevant to this feature, so the clause applies — its three obligations are
(a) re-run codegen: already done upstream, verified rather than assumed (R1);
(b) update the domain-entity mapping: `PriceListDeletePreview`, data-model §1;
(c) update the `SystemObject` table if RBAC-relevant: it is not — `PRICE_LISTS`
already carries `delete`, and no new object or right appears.

## Project Structure

### Documentation (this feature)

```text
specs/034-price-list-retirement-ui/
├── plan.md              # This file
├── research.md          # Phase 0 output — R1…R12
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── mbe-api-price-list-retirement.md
│   └── price-list-delete-dialog.md
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks output — not created here
```

### Source Code (repository root)

```text
lib/
├── core/formatting/
│   └── app_formatters.dart                         # + DisplayFormatters.count(int)  (R3)
├── features/pricing/
│   ├── domain/
│   │   ├── entities/
│   │   │   └── price_list_delete_preview.dart      # NEW — preview, category, fate
│   │   └── repositories/
│   │       └── price_list_repository.dart          # + deletePreview; delete gains replacement
│   ├── data/
│   │   └── price_list_repository_impl.dart         # both, via the generated client
│   └── presentation/
│       ├── price_list_delete_preview_provider.dart # NEW — @riverpod family  (R4)
│       ├── price_list_delete_dialog.dart           # NEW — the review dialog
│       ├── widgets/
│       │   └── price_list_delete_summary.dart      # NEW — breakdown panel   (R5, R6)
│       ├── price_list_detail_screen.dart           # opens the dialog; owns snackbar + pop (R9)
│       └── price_list_form_controller.dart         # delete → Future<bool>; `deleted` removed (R9)
└── l10n/
    ├── app_es.arb                                  # new keys first; 1 key retired
    └── app_en.arb

test/
├── unit/
│   ├── core/formatting/app_formatters_display_test.dart   # + count grouping
│   └── features/pricing/
│       ├── price_list_delete_preview_test.dart            # NEW — fate mapping (R2)
│       ├── price_list_repository_impl_test.dart           # + preview, replacement, 409
│       └── price_list_form_controller_test.dart           # + delete outcome
├── widget/features/pricing/
│   ├── price_list_delete_summary_test.dart                # NEW
│   ├── price_list_delete_dialog_test.dart                 # NEW — seven states
│   └── price_list_detail_screen_test.dart                 # old confirm case rewritten
└── integration/
    └── price_list_retirement_flow_test.dart               # NEW — golden path
```

**Structure Decision**: feature-first, as every other module. Two files that
might have been shared are deliberately not: the breakdown panel is built beside
merge's rather than lifted out of it (R5), and its humanizer is duplicated rather
than moved (R6) — both recorded with the same trigger, that a *third* caller is
what should unify all three.

**Explicitly untouched**: `lib/features/pricing/presentation/price_lists_list_screen.dart`
(R8), `lib/core/widgets/record_form_actions.dart` (R7),
`lib/features/catalog/presentation/widgets/merge_related_records_summary.dart`
(R5) — including its raw `'${category.count}'`, a pre-existing inconsistency this
feature notes and leaves alone.

## Delivery Order

Four slices in dependency order; each is independently testable, and nothing is
blocked on anything outside this repo.

| Slice | Stories | Contents |
|---|---|---|
| **A. Data path** | — | `PriceListDeletePreview` + fate mapping, both repository methods, the provider, `display.count`. Fully unit-testable with no UI. The fate mapping (R2) is the piece worth writing first and getting exactly right. |
| **B. The review** | US1 | `PriceListDeleteSummary`, the dialog in its loading / clean / priced states, the acknowledgment, the counted button label, `delete()`'s new signature and the screen's snackbar-then-pop (R9). Ships a complete improvement for lists with no customers. |
| **C. The replacement** | US2, US3 | The picker with self-exclusion, the required-gate, the "N customers move to X" line, the customers-row link, the `replacement` query parameter reaching the wire. Completes the golden path. |
| **D. Refusals** | US4, US5 | The blocked state computed from the preview, the degraded no-preview state with an optional picker, and the 409 banner that preserves the chosen replacement. |

B depends on A; C and D each depend on B and are independent of each other.

## Complexity Tracking

No constitutional violations. The two decisions that *look* like duplication —
building a second breakdown panel (R5) and a second humanizer (R6) — are
deliberate and recorded there with their alternatives; neither contradicts a
MUST, and both name the condition (a third caller) under which they should be
unified.
