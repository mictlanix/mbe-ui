# Implementation Plan: Merge Products — Explicit Kept/Deleted Review

**Branch**: `016-product-merge-review` | **Date**: 2026-07-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/016-product-merge-review/spec.md`

## Summary

Insert an explicit review step into the existing Merge Products screen (`specs/008-merge-products`), between the two search-as-you-type pickers and the existing destructive confirmation dialog. Once both "Product" (canonical) and "Duplicate" selections are valid and distinct, the screen renders a side-by-side comparison built from each product's **full** record (not the thin picker-suggestion projection): a green "kept" panel and a red "deleted" panel (photo, name — deleted one struck through — code/SKU/model, status, unit of measure, tax rate), a swap control, and a field-by-field diff table with mismatched rows flagged. A destructive action can only be enabled after an acknowledgment checkbox naming the specific product to be deleted is checked; the existing confirmation dialog is extended to restate both products by name and code. The "records that will be reassigned" count summary (Story 5/FR-006) ships in its graceful-degradation form only — omitted entirely — because mbe-api has no endpoint to compute it yet; that gap is filed as [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111) and tracked as an external dependency (constitution §III), not worked around in this feature.

Technical approach: everything lands inside the existing `features/catalog` presentation layer already built for spec 008. `MergeProductsState` gains an `acknowledged` flag (reset whenever the selections or their roles change) and a `swap()` operation implemented by exchanging `canonical`/`duplicate` (no new "role" concept needed — the existing fields already mean "kept" and "deleted"). A new `FutureProvider.family` fetches the full `Product` for both selected ids via the already-existing `ProductRepository.get(productId:)` (no OpenAPI regeneration required — constitution §III). The review UI is new, feature-local presentation code (a review panel + diff table), not promoted to `core/widgets/` since nothing else in the app needs a two-column kept/deleted product diff.

## Technical Context

**Language/Version**: Dart 3 / Flutter (stable channel)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state/DI), `go_router` (routing, unchanged — no new route), `dio` + generated `mbe_api_client` (OpenAPI dio client), `freezed` (immutable entities/state), `intl` + `flutter_localizations` (es-MX default / en), Material 3. No new pub dependencies.

**Storage**: N/A — online-only (constitution §VII); no local persistence.

**Testing**: `flutter_test` widget tests for the new review panel (kept/deleted labeling, diff-row flagging, swap, acknowledgment gating, confirmation restatement, graceful omission of the related-records summary) and updated tests for `MergeProductsScreen`/`MergeProductsController`/`MergeProductsState`; unit tests for the new comparison-fetch provider and any new `ProductRepository` usage, with the API client mocked.

**Target Platform**: Web + desktop (Expanded tier first per constitution §VI), compact-ready — both breakpoints are in scope per spec FR-012.

**Project Type**: Single Flutter application, feature-first layered (`lib/features/*`, shared `lib/core/*`).

**Performance Goals**: 60 fps interaction; the two full-product fetches for the review step run in parallel (`Future.wait`-style) so opening the review step does not feel like two sequential round-trips.

**Constraints**: Material 3 only (§V); deny-by-default RBAC unchanged from spec 008 (§IV — this feature adds no new gate, it sits behind the existing one); generated DTOs only, no hand-written schemas (§III); no hardcoded strings (§V); kept/deleted attribution must not rely on color alone (spec FR-002, accessibility); no edge-to-edge single fields on wide displays (§VI).

**Scale/Scope**: 1 new review panel + diff table (feature-local presentation code, not a new screen/route) + 1 new comparison-fetch provider + `MergeProductsState`/`MergeProductsController` extensions + `.arb` keys. 14 functional requirements, 5 user stories (4 fully in scope; the 5th ships in its degraded/omitted form pending an external dependency).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Feature-First Layered Architecture | ✅ Pass | The new comparison fetch is exposed through the existing `domain` `ProductRepository.get()` (no new interface method needed); the review panel/diff table are new `presentation`-layer widgets alongside `MergeProductsScreen`. Presentation still depends only on domain. |
| II. Riverpod state/DI | ✅ Pass | The full-product comparison fetch is a `@riverpod` `FutureProvider`-style function provider keyed by `(canonicalId, duplicateId)`, reusing `productRepositoryProvider`. `MergeProductsState`/`MergeProductsController` are extended, not replaced — still a plain `Notifier` holding local UI state. |
| III. Contract-Driven API | ✅ Pass | The richer comparison uses the already-generated `getProductApiV1ProductsProductIdGet` (via existing `ProductRepository.get`) — no regeneration needed. The related-record-counts summary (FR-006) has **no** backend support today; per §III this is filed as an mbe-api issue ([mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111)) and recorded as an external dependency below, rather than hand-patched or faked client-side. The feature ships now with that summary section omitted (spec Story 5 #2), and is wired in once the endpoint exists and the client is regenerated. |
| IV. Deny-by-Default RBAC | ✅ Pass | No new route or entry point; the review step lives inside the already-gated `/products/merge` screen (`can(SystemObject.productsMerge, AccessRight.create)`, spec 008). Nothing here loosens or duplicates that gate. |
| V. Material 3, White-Labeled, i18n | ✅ Pass | Kept/deleted panels use `colorScheme` tokens (e.g. `tertiaryContainer`/`errorContainer`-family roles) plus explicit text labels — never color alone (FR-002). All new copy (panel labels, diff-table headers, acknowledgment text, confirmation restatement) added to `app_es.arb` (default) + `app_en.arb`; no hardcoded strings. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ Pass | Not a list/table screen in the row-action sense, so those specific clauses don't apply; the review step is new content within the existing form, laid out with `ResponsiveFormGrid`/similar so panels sit side by side on wide displays and stack on compact width (spec FR-012 / Story 2 #4), avoiding single-field edge-to-edge stretch. |
| VII. Online-Only | ✅ Pass | The comparison fetch goes straight to mbe-api; no caching/offline. |

**Gate result**: PASS — no violations. The one open item (related-record counts, FR-006) is an explicitly-scoped external dependency with a documented fallback (omit), not a constitution deviation — recorded in Complexity Tracking below per the amendment precedent set by spec 008's SKU dependency.

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
│       │   └── repositories/product_repository.dart   # unchanged — reuses existing get()
│       └── presentation/
│           ├── merge_products_screen.dart              # + renders the review step when a comparison is ready
│           ├── merge_products_controller.dart          # + swap(), acknowledgeToggled()
│           ├── merge_products_state.dart                # + acknowledged flag, reset rules
│           ├── merge_products_comparison_provider.dart  # NEW — fetches both full Products in parallel
│           └── widgets/
│               ├── merge_review_panel.dart              # NEW — kept/deleted panel pair + swap control
│               └── merge_comparison_table.dart          # NEW — field-by-field diff table
└── l10n/{app_es.arb, app_en.arb}           # new keys: panel labels, diff-table headers, acknowledgment text, confirmation restatement

test/                                       # widget/unit for the above
```

**Structure Decision**: Single Flutter project, feature-first layered per constitution §I — no new module, no new route. All additions are new files inside the existing `features/catalog/presentation/` directory (plus one new provider file), following spec 008's precedent of keeping merge-specific UI local rather than promoting it to `core/widgets/`.

## Complexity Tracking

*No constitution violations.* One tracked external dependency, mirroring spec 008's resolved SKU-in-suggestion precedent:

| Item | Why deferred | Tracking |
|------|--------------|----------|
| Related-record counts (FR-006, Story 5) | No mbe-api endpoint reports, for a given product, how many records reference it across the categories a merge would remap (sales/purchase lines, inventory movement lines, lot/serial tracking, price lists, labels). Per constitution §III, mbe-ui does not patch mbe-api directly; this must ship upstream first. | Filed as [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111). This feature ships with the summary section omitted (spec Story 5 #2's graceful-degradation path is the *only* behavior implemented for FR-006 in this pass); wiring in real counts is a follow-up once the endpoint ships and the client is regenerated. |

## Phase 0 — Research

See [research.md](./research.md). Key decisions: fetch full `Product` records for both ids via the existing `ProductRepository.get()` rather than reusing picker suggestion data; implement "swap" by exchanging the `canonical`/`duplicate` fields directly rather than introducing a separate role concept; reset `acknowledged` on any change to either selection (including swap) so an acknowledgment can never apply to a since-changed product; ship FR-006/Story 5 in its degraded (omitted) form pending [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111).

## Phase 1 — Design & Contracts

- [data-model.md](./data-model.md) — `MergeProductsState` extensions (`acknowledged`, updated `canSubmit`), the comparison view model built from two full `Product` records, and the diff-row computation rule.
- [contracts/product-repository.md](./contracts/product-repository.md) — how the review step reuses `ProductRepository.get()`; no new repository method.
- [contracts/ui-contracts.md](./contracts/ui-contracts.md) — review panel, diff table, swap control, acknowledgment gate, and the extended confirmation dialog.
- [quickstart.md](./quickstart.md) — manual validation walkthrough per user story.
- Agent context (`CLAUDE.md`) updated to point at this plan.
