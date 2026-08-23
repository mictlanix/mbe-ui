# Implementation Plan: POS Sale & Delivery Refinements

**Branch**: `030-pos-sales-refinements` | **Date**: 2026-08-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/030-pos-sales-refinements/spec.md`

## Summary

Three small, unrelated gaps in the point-of-sale flow, all of them UI-side:

1. **One quantity control instead of two.** The debounced stepper spec 026
   built inside `destination_card.dart` becomes a shared widget plus a
   controller ([contracts/quantity-stepper.md](./contracts/quantity-stepper.md)),
   used by the wide sale-line row, the compact sale-line card and the
   destination card. The capture surface gains the debounce, the live controls
   and the pending-value display it never had; the delivery surface keeps
   exactly what it has today.
2. **Typed values confirm on Enter, and visibly reset otherwise.** The
   controller owns that rule; the widget owns the 250 ms fade-and-tint that
   makes a discard impossible to miss.
3. **The delivery step's two missing mock affordances** — an edit action on
   each destination card, and an expandable store row
   ([contracts/delivery-surface.md](./contracts/delivery-surface.md)).

No backend change, no codegen, no new dependency. `PUT /delivery-orders/{id}`
is already implemented in mbe-api *and* already exposed by this client's
repository (`updateHeader`) — this feature is its first caller (research R9).

Five findings shape the work, three of them against the intuitive reading:

- **The shared control cannot go in `core/widgets/` for free** (research R1).
  It needs `features/sales/domain/money.dart`'s exact decimal arithmetic, so
  it lives in `features/sales/presentation/widgets/` and the §VI
  "shared widgets in core" rule is answered in Complexity Tracking rather
  than ignored.
- **A widget alone cannot own the behaviour** (research R2). Two existing
  affordances — the delivery card's assign-all and the capture line's
  adjust-to-available — set a quantity from outside the stepper and must stay
  instant, so the value/debounce state lives in a small `ChangeNotifier` the
  host owns.
- **The capture line must come out pixel-identical** (research R5). Its
  control band is load-bearing (one height, one baseline, the SAT unit in the
  quantity label) and four goldens pin it. The shared widget therefore takes
  an `InputDecoration`, exactly as the mixin's existing pickers do, and the
  delivery pill remains the no-decoration default. **A golden diff is a bug,
  not a re-baseline.**
- **Removing `_busy` from the quantity path opens a real race** (research R6).
  `PosSaleController.updateLine` replaces the *whole sale*, so two overlapping
  line writes let the later response revert the earlier change. `_busy` was
  accidentally preventing that; FR-006 now requires an explicit per-line write
  queue.
- **The design system has no motion scale** (research R4). FR-016's "durations
  from the design system" is satisfiable only by inventing one for two
  durations; the plan instead names them once in the shared file and records
  the partial satisfaction.

Net: 2 new files, 8 edited, 2 `.arb` files, 1 new unit test, 1 new widget
test, 6 existing tests extended, 0 goldens re-baselined.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.44.2 (stable, this toolchain)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `freezed`,
`decimal` (already, via `features/sales/domain/money.dart`),
`flutter_localizations`/`intl`, the generated `mbe_api_client`. **No new
dependency.**

**Storage**: N/A — online-only, every read and write goes to mbe-api
(constitution §VII)

**Testing**: `flutter_test` (unit + widget + golden), `integration_test`
against a live mbe-api

**Target Platform**: Web (Chrome) primary, macOS/desktop; compact tier at
< 600 px

**Project Type**: Single Flutter application, feature-first layering

**Performance Goals**: a burst of ten stepper taps issues **one** write
(SC-001); the displayed figure never lags a tap by more than a frame; the
reset animation runs at 60 fps on the POS's own hardware; no request is
issued by any of the three changes that was not issued before, except the one
`PUT` an explicit edit performs.

**Constraints**: the capture line's single-row budget
(`saleLineSingleRowMinWidth = 950`, quantity column 132 px) is unchanged and
must still hold at 1024 px and at the largest text-size level; the delivery
destination card header must fit three trailing controls at 380 px; no mbe-api
change is in scope; `PUT /delivery-orders/{id}` accepts only draft orders and
treats `null` as "unchanged", at both ends of the wire.

**Scale/Scope**: 2 surfaces, 5 widgets, 1 new shared control. Typical sale:
1–20 lines; typical delivery: 1–3 destinations. One controller instance per
line per surface — a 20-line sale on the capture step holds 20, each a
`ChangeNotifier` with one timer.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1. Both passes
below.*

| Principle | Assessment |
|---|---|
| **I. Feature-First Layered Architecture** | PASS. Everything new is `presentation/` inside `features/sales/`. No entity, repository or data-layer change. The new shared widget sits in the module's existing `presentation/widgets/` alongside `customer_address_picker.dart` and `denomination_count_table.dart`; nothing in `core/` gains a dependency on a feature (research R1). |
| **II. Riverpod for State & DI** | PASS, with reasoning. No new provider: `QuantityStepperController` is per-widget input state in the same category as the `TextEditingController` it replaces — created, owned and disposed by one `State`, with no consumer outside the widget that renders it. §II's local-UI-state rule addresses state that outlives or is shared beyond one widget (spec 018's plan made the same call for card expansion, and spec 026's card expansion is plain `State` today). Every server interaction still goes through the existing `@riverpod` controllers; `DeliveryController` gains one method, no new provider. Recorded in Complexity Tracking for visibility. |
| **III. Contract-Driven API Integration** | PASS. No codegen, no new DTO, no hand-written model, no mbe-api edit. The one new write reuses `DeliveryOrderRepository.updateHeader` and the generated `DeliveryOrderUpdate` unchanged. mbe-api's own behaviour was read from source rather than assumed (research R9), including the 409-on-non-draft guard the UI must render. |
| **IV. Deny-by-Default RBAC** | PASS. The edit action reaches `PUT /delivery-orders/{id}`, guarded server-side by `delivery_orders:update` — **the same privilege** the card's existing assign/adjust/drop calls already require, so it exposes no capability the surface lacked. The delivery step gates no action client-side today; gating only the new one would be inconsistent, and gating all of them is a separate concern this feature does not open. The POS route itself remains RBAC-gated. |
| **V. Material 3, White-Labeled** | PASS. Every colour comes from `colorScheme`, every radius from `theme.shapes`, every gap from `theme.spacing`; no hex reaches Dart. The stepper's displayed value goes through `formattersProvider.field.quantity`, keeping `formatting_guard_test.dart` green. Two new strings, both `.arb` files, `es-MX` first; existing `editActionTooltip`/`saveButton` reused rather than duplicated. Verified at the largest text-size level on the capture band (§V's explicit POS requirement) — the one **partial**: durations, see Complexity Tracking. |
| **VI. Desktop/Web-First, Compact-Ready** | PASS, with two recorded divergences — see below. |
| **VII. Online-Only** | PASS. No caching beyond a provider's ordinary lifetime, no offline storage, no client-side documents. The controller's pending value is in-memory input state for at most 400 ms, flushed rather than persisted on teardown. |

### §VI in detail

| Rule | How this feature satisfies it |
|---|---|
| Breakpoints centralized in `core/` | Uses `LayoutBreakpoints` (`large` for the sheet presentation, `isCompact` for the tier choice). No new constant. |
| Shared widgets in `core/widgets/` | **Divergence** — the stepper is module-local. Complexity Tracking row 1. |
| Symmetric vertical padding; shared baseline in a control band; spacing from tokens | The capture band is unchanged by construction (research R5) and `sale_line_symmetry_test.dart` continues to assert it. The pill keeps its own symmetric padding. |
| One fixed Edit icon, never module-invented | The destination card's edit action uses `CatalogAction.edit.icon` and `editActionTooltip` from `core/widgets/catalog_action_icons.dart`. |
| At most two row icons | **Divergence** — the destination card header carries edit + remove + chevron. Complexity Tracking row 2. |
| Row click opens read-only; Create is toolbar-only; Delete lives on the detail screen | Not applicable: the delivery step is not a catalog list and has no detail route. The card's tap target is its own expansion, which is what the mock draws; the add action stays the step's own button. |
| No horizontal scroll; ellipsize with a fallback; never truncate critical info | The card header already ellipsizes address and subtitle at one line; the new store-row body ellipsizes product names and never truncates a quantity. |
| Mandatory pagination / filtering | Not applicable — neither surface is a list screen; every collection here is one sale's own lines and destinations. |
| `AppBar.actions` empty; `RecordFormActions` for detail screens | Untouched; this feature adds no app-bar action and no record form. |

### Post-Phase-1 re-evaluation

Re-checked after the two contracts and the data model. No new violation. Three
decisions taken during Phase 1 are worth restating because they are the ones a
reviewer should push on:

- The commit contract is `Future<bool>`, not a thrown error, so each host keeps
  its own refusal presentation (research R3). This is a deliberate refusal to
  unify two behaviours that legitimately differ.
- The store row's header counts change from "one source or the other" to their
  sum (data-model §3). It is a behaviour change on exactly one configuration —
  a resumed mixed sale with both a recorded counter destination and an
  unassigned remainder — where today's header under-reports what stays at the
  store. Called out rather than slipped in.
- The reset animation plays on a *server refusal* as well as on abandonment,
  which the spec's edge cases require but its FR-013 lists only for FR-011/012.
  The contract states it explicitly so the tests cover it.

## Project Structure

### Documentation (this feature)

```text
specs/030-pos-sales-refinements/
├── plan.md                       # This file
├── spec.md
├── research.md                   # Phase 0 — R1…R12
├── data-model.md                 # Phase 1 — controller state, the write, the derived figure
├── quickstart.md                 # Phase 1 — how to prove it, by hand and by suite
├── contracts/
│   ├── quantity-stepper.md       # Phase 1 — API, skins, behaviour table, animation
│   └── delivery-surface.md       # Phase 1 — card header, edit sheet, store row, l10n
├── checklists/
│   └── requirements.md
└── tasks.md                      # Phase 2 — created by /speckit-tasks, not here
```

### Source code

```text
lib/
├── features/sales/presentation/
│   ├── widgets/
│   │   └── quantity_stepper.dart              # +  controller + view (US1, US2)
│   ├── capture/
│   │   ├── sale_line_editing.dart             # M  quantity leaves _busy; per-line write queue
│   │   ├── sale_line_row.dart                 # M  _quantityStepper → shared widget (field skin, dense)
│   │   └── sale_line_card.dart                # M  quantity row → shared widget (field skin)
│   └── delivery/
│       ├── destination_card.dart              # M  stepper → shared widget; + edit action
│       ├── destination_line_row.dart          # +  the read-only line row, shared with the store row
│       ├── destination_counter_row.dart       # M  expandable; derived store share (US4)
│       ├── destination_editor.dart            # M  optional `destination` ⇒ edit mode (US3)
│       ├── delivery_controller.dart           # M  + updateDestination
│       └── delivery_step.dart                 # M  one sheet opener for add+edit; onEdit wiring
└── l10n/
    ├── app_es.arb                             # M  posEditDestinationSheetTitle, posCounterPickupLinesTitle
    └── app_en.arb                             # M  same pair
```

```text
test/
├── unit/features/sales/
│   └── quantity_stepper_controller_test.dart  # +  state machine: debounce, bounds, precedence
├── widget/features/sales/
│   ├── destination_counter_row_test.dart      # +  expansion, both sources, header/body agreement
│   ├── destination_card_test.dart             # M  edit action presence, order, disabled while closing
│   ├── destination_editor_error_test.dart     # M  edit mode: prefill, save label, refusal
│   ├── destination_assignment_test.dart       # M  same keys, same behaviour through the new widget
│   ├── delivery_step_layout_test.dart         # M  sheet presentation for edit at both tiers
│   ├── sale_line_row_test.dart                # M  reset animation + no overflow at 1024 px
│   └── pos_compact_delivery_test.dart         # M  three trailing controls at 380 px
└── golden/
    └── pos_capture_golden_test.dart           # unchanged — MUST pass with no re-baselining
```

**Structure Decision**: the existing feature-first layout is unchanged. The
only structural choice is where the shared control lives —
`features/sales/presentation/widgets/`, for the reasons in research R1 and
Complexity Tracking row 1.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| §VI: a shared "form-field wrapper" lives in `features/sales/presentation/widgets/`, not `core/widgets/` | The control does exact decimal-string arithmetic, whose one correct implementation (`money.dart`) is a sales-domain file imported by 17 others; both consumers are the sales module | Putting it in `core/widgets/` makes `core` import `features/sales/domain` (a layering debt for no gain today), or requires promoting money.dart's generic half into `core/` — a cross-cutting refactor outside this feature's scope. The rule's purpose (one implementation, not four) is fully served; promotion is a two-line move when a second module needs it |
| §VI: the destination card header carries three trailing controls (edit, remove, chevron), not the two-icon maximum | The mock draws exactly this set, and the remove action already shipped in spec 026; adding Edit is what brings the count to three | An overflow menu for two actions on a card the cashier works at speed costs a tap on the most common correction and hides the destructive action behind the safe one. The two-icon rule is written for catalog list rows with a detail screen behind them; this card has no detail route, no row-click affordance, and its "row click" is its own expansion |
| §II: per-line value/debounce state in a plain `ChangeNotifier` rather than a Riverpod `Notifier`/`StateProvider` | It is per-widget input state with a `Timer` and a disposal contract — the same category as the `TextEditingController` it replaces, and it must be created and torn down with the widget that renders it, one per line | A provider family keyed by line id would put a 400 ms transient in global state, need explicit invalidation on every line removal, and make the widget untestable without a container. §II's target is state shared beyond one widget (spec 018 made the same call for expansion state) |
| §V / spec FR-016: the animation's **durations** are named constants in the shared file, not design tokens | `lib/core/design/` (spec 022) defines spacing, shape, elevation, density and type roles — and no motion scale; the app's existing animations carry literal durations at their call sites | Adding a `Motion` extension for two durations would leave every existing literal inconsistent with the new token and puts a product-wide design-system change inside a three-item UI feature. Colours **do** come from the theme; a motion scale is worth a spec of its own, and this feature's two constants are its first candidate call sites |
