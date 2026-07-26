# Implementation Plan: Merge Products — Explicit Kept/Deleted Review

**Branch**: `016-product-merge-review` | **Date**: 2026-07-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/016-product-merge-review/spec.md`

## Summary

Insert an explicit review step into the existing Merge Products screen (`specs/008-merge-products`), between the two search-as-you-type pickers and the existing destructive confirmation dialog. Once both "Product" (canonical) and "Duplicate" selections are valid and distinct, the screen renders a side-by-side comparison built from each product's **full** record (not the thin picker-suggestion projection): a green "kept" panel and a red "deleted" panel (photo, name — deleted one struck through — code/SKU/model, status, unit of measure, tax rate), a swap control, and a field-by-field diff table with mismatched rows flagged. A destructive action can only be enabled after an acknowledgment checkbox naming the specific product to be deleted is checked; the existing confirmation dialog is extended to restate both products by name and code. A blast-radius summary (Story 5/FR-006) lists every category of record attached to the doomed product with counts and a total, sourced from mbe-api's merge-preview endpoint.

Technical approach: everything lands inside the existing `features/catalog` layer already built for spec 008. `MergeProductsState` gains an `acknowledged` flag (reset whenever the selections or their roles change) and a `swap()` operation implemented by exchanging `canonical`/`duplicate` (no new "role" concept needed — the existing fields already mean "kept" and "deleted"). A new provider fetches the full `Product` for both selected ids via the already-existing `ProductRepository.get(productId:)`; a second provider fetches the merge preview via a new `ProductRepository.mergePreview()` wrapping the already-generated `previewProductMergeApiV1ProductsMergePreviewGet`. The review UI is new, feature-local presentation code (review panel + diff table + summary), not promoted to `core/widgets/` since nothing else in the app needs a two-column kept/deleted product diff.

**Dependency status (changed since first draft)**: FR-006 was originally scoped as "omit the summary, pending [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111)". That issue **shipped and is closed** (mbe-api `990fa83`), and mbe-ui's client was already regenerated against it (mbe-ui `2d9b1e5`), so Story 5 is now in scope. A companion upstream fix, [mictlanix/mbe-api#112](https://github.com/mictlanix/mbe-api/issues/112) (`caa4fcc`), made the merge move *every* reference rather than six hard-coded tables — so the preview's counts and the merge's actual effect now describe the same set. See research.md §4 for the contract and its two UI-shaping properties (raw `table.column` category keys; `product_price` counted but destroyed rather than moved).

## Technical Context

**Language/Version**: Dart 3 / Flutter (stable channel)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state/DI), `go_router` (routing, unchanged — no new route), `dio` + generated `mbe_api_client` (OpenAPI dio client), `freezed` (immutable entities/state), `intl` + `flutter_localizations` (es-MX default / en), Material 3. No new pub dependencies.

**Storage**: N/A — online-only (constitution §VII); no local persistence.

**Testing**: `flutter_test` widget tests for the new review panel (kept/deleted labeling, diff-row flagging, swap, acknowledgment gating, confirmation restatement, graceful omission of the related-records summary) and updated tests for `MergeProductsScreen`/`MergeProductsController`/`MergeProductsState`; unit tests for the new comparison-fetch provider and any new `ProductRepository` usage, with the API client mocked.

**Target Platform**: Web + desktop (Expanded tier first per constitution §VI), compact-ready — both breakpoints are in scope per spec FR-012.

**Project Type**: Single Flutter application, feature-first layered (`lib/features/*`, shared `lib/core/*`).

**Performance Goals**: 60 fps interaction; the two full-product fetches for the review step run in parallel (`Future.wait`-style) so opening the review step does not feel like two sequential round-trips.

**Constraints**: Material 3 only (§V); deny-by-default RBAC unchanged from spec 008 (§IV — this feature adds no new gate, it sits behind the existing one); generated DTOs only, no hand-written schemas (§III); no hardcoded strings (§V); kept/deleted attribution must not rely on color alone (spec FR-002, accessibility); no edge-to-edge single fields on wide displays (§VI).

**Scale/Scope**: 1 new review panel + diff table + related-records summary (feature-local presentation code, not a new screen/route) + 2 fetch providers + 1 new domain entity and repository method + `MergeProductsState`/`MergeProductsController` extensions + `.arb` keys. 14 functional requirements, 5 user stories — all in scope.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Feature-First Layered Architecture | ✅ Pass | The new comparison fetch is exposed through the existing `domain` `ProductRepository.get()` (no new interface method needed); the review panel/diff table are new `presentation`-layer widgets alongside `MergeProductsScreen`. Presentation still depends only on domain. |
| II. Riverpod state/DI | ✅ Pass | The full-product comparison fetch is a `@riverpod` `FutureProvider`-style function provider keyed by `(canonicalId, duplicateId)`, reusing `productRepositoryProvider`. `MergeProductsState`/`MergeProductsController` are extended, not replaced — still a plain `Notifier` holding local UI state. |
| III. Contract-Driven API | ✅ Pass | Both server calls use already-generated methods — `getProductApiV1ProductsProductIdGet` (via existing `ProductRepository.get`) for the comparison, and `previewProductMergeApiV1ProductsMergePreviewGet` for the blast-radius summary. **No regeneration needed**: the preview models landed in `lib/generated/openapi/` in mbe-ui `2d9b1e5`. The backend gap this feature originally had was handled the way §III requires — filed as [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111) from mbe-ui rather than patched across the repo boundary — and has since shipped upstream. Generated DTOs are mapped to domain types in `data/` before reaching `presentation`; errors go through the existing `mapDioException` → `AppError` chain. |
| IV. Deny-by-Default RBAC | ✅ Pass | No new route or entry point; the review step lives inside the already-gated `/products/merge` screen (`can(SystemObject.productsMerge, AccessRight.create)`, spec 008). Nothing here loosens or duplicates that gate. |
| V. Material 3, White-Labeled, i18n | ✅ Pass | Kept/deleted panels use `colorScheme` tokens (e.g. `tertiaryContainer`/`errorContainer`-family roles) plus explicit text labels — never color alone (FR-002). All new copy (panel labels, diff-table headers, acknowledgment text, confirmation restatement) added to `app_es.arb` (default) + `app_en.arb`; no hardcoded strings. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ Pass | Not a list/table screen in the row-action sense, so those specific clauses don't apply; the review step is new content within the existing form, laid out with `ResponsiveFormGrid`/similar so panels sit side by side on wide displays and stack on compact width (spec FR-012 / Story 2 #4), avoiding single-field edge-to-edge stretch. |
| VII. Online-Only | ✅ Pass | The comparison fetch goes straight to mbe-api; no caching/offline. |

**Gate result**: PASS — no violations, and no open external dependencies. The one item previously tracked here (related-record counts, FR-006) has shipped upstream and is now consumed through the regenerated client; see Complexity Tracking below.

## Project Structure

### Documentation (this feature)

```text
specs/016-product-merge-review/
├── plan.md              # This file
├── research.md          # Phase 0 — decisions (full-product fetch, swap semantics, ack-reset rule, related-counts dependency)
├── data-model.md         # Phase 1 — MergeProductsState extensions, comparison view model
├── quickstart.md        # Phase 1 — manual validation walkthrough per user story
├── contracts/
│   ├── product-repository.md   # Reuse of ProductRepository.get() for the comparison fetch
│   └── ui-contracts.md         # Review panel + diff table + confirmation-dialog extension behavior
├── checklists/
│   └── requirements.md  # From /speckit-specify (present)
└── tasks.md             # /speckit-tasks output — NOT created here
```

### Source Code (repository root)

```text
lib/
├── features/
│   └── catalog/
│       ├── domain/
│       ├── domain/
│       │   ├── entities/merge_preview.dart              # NEW — MergePreview + MergePreviewCategory
│       │   └── repositories/product_repository.dart     # + mergePreview(); get() reused as-is
│       ├── data/
│       │   └── product_repository_impl.dart             # + mergePreview() via generated preview method
│       └── presentation/
│           ├── merge_products_screen.dart               # + renders the review step when a comparison is ready
│           ├── merge_products_controller.dart           # + swap(), acknowledgeToggled()
│           ├── merge_products_state.dart                # + acknowledged flag, reset rules
│           ├── merge_products_comparison_provider.dart  # NEW — both full Products in parallel + merge preview
│           └── widgets/
│               ├── merge_review_panel.dart              # NEW — kept/deleted panel pair + swap control
│               ├── merge_comparison_table.dart          # NEW — field-by-field diff table
│               └── merge_related_records_summary.dart   # NEW — per-category counts + total (FR-006)
└── l10n/{app_es.arb, app_en.arb}           # new keys: panel labels, diff-table headers, acknowledgment text,
                                            #   confirmation restatement, category labels + fallback

test/                                       # widget/unit for the above
```

**Structure Decision**: Single Flutter project, feature-first layered per constitution §I — no new module, no new route. All additions are new files inside the existing `features/catalog/presentation/` directory (plus one new provider file), following spec 008's precedent of keeping merge-specific UI local rather than promoting it to `core/widgets/`.

## Complexity Tracking

*No constitution violations, no outstanding deviations.* The one external dependency this feature opened has been resolved upstream, mirroring spec 008's resolved SKU-in-suggestion precedent:

| Item | Status | Tracking |
|------|--------|----------|
| Related-record counts (FR-006, Story 5) | **Resolved.** Originally deferred — no mbe-api endpoint reported per-product reference counts, and per constitution §III mbe-ui filed an issue rather than patching the sibling repo. The endpoint has since shipped and the client was regenerated, so Story 5 moved from "omitted" into full scope. | [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111) (closed, mbe-api `990fa83`) → mbe-ui `2d9b1e5` regenerated the client. Companion fix [mictlanix/mbe-api#112](https://github.com/mictlanix/mbe-api/issues/112) (closed, `caa4fcc`) aligned the merge's actual effect with what the preview counts. |

Two contract properties (research.md §4) are carried into the requirements rather than left as implementation surprises: category keys arrive as raw `table.column` strings from a set that grows on its own (unknown keys need a fallback label — FR-006 / Story 5 #3), and `product_price` is counted by the preview but *destroyed* rather than moved by the merge (the summary must not blanket-label everything "reassigned" — FR-006 / Story 5 #2).

## Phase 0 — Research

See [research.md](./research.md). Key decisions: fetch full `Product` records for both ids via the existing `ProductRepository.get()` rather than reusing picker suggestion data; implement "swap" by exchanging the `canonical`/`duplicate` fields directly rather than introducing a separate role concept; reset `acknowledged` on any change to either selection (including swap) so an acknowledgment can never apply to a since-changed product; and consume the now-shipped merge-preview endpoint for FR-006/Story 5, mapping its raw `table.column` category keys to localized labels with a humanized fallback for unrecognized ones, while calling out that price-list rows are destroyed rather than moved.

## Phase 1 — Design & Contracts

- [data-model.md](./data-model.md) — `MergeProductsState` extensions (`acknowledged`, updated `canSubmit`), the comparison view model built from two full `Product` records, and the diff-row computation rule.
- [contracts/product-repository.md](./contracts/product-repository.md) — how the review step reuses `ProductRepository.get()`; no new repository method.
- [contracts/ui-contracts.md](./contracts/ui-contracts.md) — review panel, diff table, swap control, acknowledgment gate, and the extended confirmation dialog.
- [quickstart.md](./quickstart.md) — manual validation walkthrough per user story.
- Agent context (`CLAUDE.md`) updated to point at this plan.
