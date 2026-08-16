# Implementation Plan: Point of Sale — Delivery Step Look & Feel

**Branch**: `026-pos-delivery-ux` | **Date**: 2026-08-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/026-pos-delivery-ux/spec.md`

---

## Summary

Spec 023 reshaped the capture step and spec 025 the payment step; both deferred
this one. This feature is the last of the three, and unlike the other two it is
not purely visual: the mock assigns quantities *inside* a destination's card,
which the shipped screen cannot do at all.

The approach, in one paragraph: at 1200 px and wider the step becomes two
regions — the destinations on the left (a counter row for mixed sales, one
collapsible card per address, a dashed add action) and a fixed 360-px rail on
the right holding the per-line distribution, the assigned-units total, the gate
line and "Finalizar venta". Below that it is the same content as one column with
the total and the finish action pinned as a footer band, the shape
`SaleTotalsBar` already gives the capture step. Each card carries a positional
badge (`D1`, `D2`) that keys its chips in the rail, and expands to show the
sale's lines with what this destination takes of each. Creating a destination
moves into a side sheet that asks only where, who, when and any instructions.

**Nothing is blocked any more.** The design needed two things mbe-api did not
have; both were filed rather than patched from here, and both landed on
2026-08-15 with the client regenerated — [#163](https://github.com/mictlanix/mbe-api/issues/163)
adds a line to a destination that already exists, and
[#165](https://github.com/mictlanix/mbe-api/issues/165) lets an explicit
`lines: []` create one that carries nothing ([research R2](./research.md)). The
phases below are ordered by dependency alone.

Four findings are worth reading before implementing. The 1200-px threshold and
the 360-px rail are arithmetic on the real spacing tokens
([R1](./research.md)). The stepper must dispatch between three endpoints on
local state — a duplicate `POST` is a 409, not a fold, and neither `POST` nor
`PUT` accepts zero ([R13](./research.md)). The header-only create must send an
explicit `lines: []`, because an omitted `lines` claims the entire sale — the
one mistake in this feature that produces a wrong sale rather than an error
([R14](./research.md)). And the stepper's behaviour already exists in this
codebase: `SaleLineEditing` is the same per-edit-round-trip, revert-on-refusal
shape, with two deliberate differences ([R6](./research.md)).

## Technical Context

**Language/Version**: Dart 3.10.3+ / Flutter stable

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `decimal`,
`intl`, `flutter_localizations`. No new package.

**Storage**: none — online-only (constitution §VII). This feature persists
nothing and caches nothing.

**Testing**: `flutter_test` + `mocktail`; the existing
`test/widget/features/sales/pos_test_harness.dart`

**Target Platform**: Flutter web/desktop first (expanded/large tiers), with the
tablet and phone tiers explicitly in scope (FR-005, SC-007)

**Project Type**: single Flutter application (feature-first layers)

**Performance Goals**: no request beyond create, list, per-line
add/update/remove and cancel; no refetch of the destination list after an
assignment (SC-010)

**Constraints**: no literal colour/spacing/size values (FR-039, SC-008); every
surviving widget-test key preserved (FR-042); the distribution arithmetic, the
completion gate and the counter sweep untouched (FR-001)

**External dependencies**: both **landed 2026-08-15, client regenerated** —
[mbe-api#163](https://github.com/mictlanix/mbe-api/issues/163) (`POST
/api/v1/delivery-orders/{id}/lines`) and
[mbe-api#165](https://github.com/mictlanix/mbe-api/issues/165) (an explicit
`lines: []` on create). Neither blocks any phase.

**Scale/Scope**: one step of one screen — five presentation files, two of them
new, one controller extended, nine localization keys

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | Note |
|---|---|---|
| I. Feature-first layered architecture | **Pass** | Everything lands in `features/sales/presentation/delivery/`. No entity moves; nothing new is shared, so nothing belongs in the shared kernel |
| II. Riverpod for state and DI | **Pass** | No new provider. `DeliveryController` gains three methods over repository methods that already exist; `state` stays `AsyncValue<List<Destination>>` ([data-model §3](./data-model.md)) |
| III. Contract-driven API integration | **Pass** | No hand-written DTO. The two gaps this design needed were **filed against mbe-api (#163, #165), not patched from here**, per §III; both shipped and phases F–G consume the regenerated client |
| IV. Deny-by-default RBAC | **Pass** | No new action to gate. The POS route gate and the step's existing gating are untouched |
| V. Material 3, white-labeled | **Pass** | Material 3 throughout (`Card`, `InkWell`, `IconButton`, `TextField`, `FilledButton`, modal sheets). All colour and type from the theme and the spec 022 tokens; all nine new labels shipped in `es-MX` and `en` (FR-040) |
| VI. Desktop/web-first, compact-ready | **Pass** | Breakpoints from `core/layout/breakpoints.dart`. The list/table, row-action, form-grid and `AppBar.actions` rules do not apply — the POS workspace is not a catalog list or a record form, as specs 023 and 025 established for the same reason. §VI's truncation rule **does** apply and is honoured: addresses and product names ellipsize, counts and quantities never do ([contract §4.1](./contracts/delivery-surface.md)) |
| VII. Online-only | **Pass** | Nothing cached, nothing stored; every assignment is a round trip |

**Re-check after Phase 1 design**: unchanged — no gate moved. The design added
three controller methods and one widget, all inside the feature's own
presentation layer. No Complexity Tracking entry is required.

## Project Structure

### Documentation (this feature)

```text
specs/026-pos-delivery-ux/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — R1…R13
├── data-model.md        # Phase 1 output — read-only inventory + 3 new methods
├── quickstart.md        # Phase 1 output — how to prove it works
├── contracts/
│   └── delivery-surface.md  # Phase 1 output — the UI contract
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── design/                          # spacing / shapes / type roles     [read]
│   ├── layout/breakpoints.dart          # LayoutBreakpoints.large           [read]
│   └── widgets/catalog_filter_sheet.dart # side-sheet mechanics precedent   [read]
├── features/sales/
│   ├── domain/entities/
│   │   ├── line_distribution.dart       # UNTOUCHED (research R9)
│   │   └── destination.dart             # UNTOUCHED
│   ├── domain/repositories/
│   │   └── delivery_order_repository.dart # + addLine                        [edit, F]
│   ├── data/
│   │   └── delivery_order_repository_impl.dart # + addLine                   [edit, F]
│   └── presentation/
│       ├── delivery/
│       │   ├── delivery_step.dart       # composer: one column or two regions [rewrite]
│       │   ├── destination_card.dart    # tile → collapsible card + lines     [rewrite]
│       │   ├── destination_counter_row.dart # the mixed-sale counter row      [new]
│       │   ├── line_distribution_panel.dart # table → rail + foot             [rewrite]
│       │   ├── destination_editor.dart  # inline form → header-only sheet     [rewrite, G]
│       │   └── delivery_controller.dart # +assignLine/adjustLine/dropLine     [edit, F]
│       └── capture/
│           ├── sale_totals_bar.dart     # footer-band treatment               [read]
│           └── sale_line_editing.dart   # the stepper pattern (research R6)   [read]
└── l10n/
    ├── app_es.arb                       # +8 keys, 1 removed                  [edit]
    └── app_en.arb                       # same                                [edit]

test/
├── unit/features/sales/
│   ├── line_distribution_test.dart      # UNTOUCHED — must stay green         [read]
│   └── delivery_order_repository_impl_test.dart # UNTOUCHED                   [read]
└── widget/features/sales/
    ├── delivery_step_layout_test.dart   # two shapes, reflow, overflow        [new]
    ├── destination_card_test.dart       # header, expansion, independence     [new]
    ├── line_distribution_rail_test.dart # chips, badges, total, gate line     [new]
    ├── destination_assignment_test.dart # stepper, clamp, drop, refusal       [new, F]
    ├── pos_compact_delivery_test.dart   # quantity assertions move to card    [edit]
    └── destination_editor_error_test.dart # pump changes; keys preserved      [edit, G]
```

**Structure Decision**: the existing feature-first layout, unchanged. The one
structural choice is that the counter row becomes its own widget rather than a
mode of `DestinationCard` — it has no expansion, no badge and no remove action,
so sharing the card would mean three conditionals in a header that already
carries six elements ([contract §3](./contracts/delivery-surface.md)).

## Implementation phases

Ordered so each phase leaves the tree green. Nothing waits on mbe-api.

### The visual restyle

**Phase A — the copy.** Add the nine keys of [research R11](./research.md) to
both `.arb` files; run `flutter gen-l10n`. `posDestinationQuantitiesTitle`'s
removal waits for F, when its last caller goes.

**Phase B — the leaf widgets.** In any order, each independently testable:
`DestinationCounterRow` ([contract §3](./contracts/delivery-surface.md));
`DestinationCard`'s header and expansion, with its body listing every sale line
([§4.1, §4.2](./contracts/delivery-surface.md)). Keys preserved verbatim. The
rows are read-only until phase F gives them steppers.

**Phase C — the rail.** Rewrite `LineDistributionPanel` as header, chip rows and
pinned foot ([§5](./contracts/delivery-surface.md)), taking the badge map as a
parameter.

**Phase D — the composer.** Rewrite `delivery_step.dart` as the two-shape host,
building the badge map once and passing it to both regions
([§1, §2](./contracts/delivery-surface.md)).

**Phase E — the tests.** The three new widget tests, the compact-test edit, and
a full `flutter analyze && flutter test`. Then walk
[quickstart §3](./quickstart.md)'s width table against a live register; the 1200
and 1199 rows are the two research says are most likely to be wrong.

**Phase F — the controller and the stepper.** Add `addLine` to
`DeliveryOrderRepository` and its impl, over the regenerated
`addDeliveryOrderLineApiV1DeliveryOrdersDeliveryOrderIdLinesPost`; add
`assignLine` / `adjustLine` / `dropLine` to `DeliveryController`
([data-model §3](./data-model.md)); build the stepper pill, its clamp and its
three-way dispatch ([§4.3, §4.4](./contracts/delivery-surface.md),
[R6](./research.md), [R7](./research.md), [R13](./research.md)); then
`destination_assignment_test.dart` and [quickstart §4.3](./quickstart.md)
against a real register — including the network-panel check that a clamped
over-claim sends nothing.

### The header-only sheet

**Phase G — the sheet.** Rewrite `destination_editor.dart` as the header-only
sheet ([§6](./contracts/delivery-surface.md)); drop `addDestination`'s
`quantities` parameter and have it pass `lines: const []`
([R14](./research.md)); disable the add action when nothing is left unassigned
(FR-016); remove `posDestinationQuantitiesTitle`; update
`destination_editor_error_test.dart`'s pump; walk
[quickstart §4.4](./quickstart.md), including the network-panel check that the
create body carries `"lines": []`.

## Risks

| Risk | Mitigation |
|---|---|
| The card header wraps at exactly 1200 px | [R1](./research.md)'s arithmetic, plus the 1200/1199 rows of the width table and an overflow assertion in `delivery_step_layout_test.dart` |
| The stepper posts a line the destination already carries | `add_line` refuses a duplicate with 409 rather than folding; the dispatch reads `Destination.lines` first ([R13](./research.md)) |
| Someone reaches for a placeholder line or a local-only card to unblock the sheet | FR-003 forbids both by name; [R3](./research.md) records why the deferred-creation variant was rejected on its merits, not just by rule |
| Badges and rail chips disagree after a removal | One badge map, built once in the step and passed to both regions ([R8](./research.md)) |
| The clamp and the server disagree, so SC-006 fails in practice | The ceiling formula is the same expression `update_line` validates ([R7](./research.md)) |
| A refused assignment leaves the refused figure on screen | The `syncFields()` shape from `SaleLineEditing`, with a dedicated test ([R6](./research.md)) |
| The sheet is torn down by the shell's nested Navigator | `useRootNavigator: true`, the reason `showCatalogFilterSheet` already documents ([R10](./research.md)) |
| Literal values creep in while chasing the mock's look | SC-008 is a diff-level check; the contract names a token for every element |
| The create sends an omitted `lines` instead of `[]`, silently claiming the whole sale | The repository already distinguishes null from empty, and the generated serializer emits `[]` for a non-null empty list; the quickstart checks the wire body directly ([R14](./research.md)) |
| The add action offers itself on a fully-assigned sale and 409s | FR-016 disables it on exactly the condition that opens the finish gate ([R14](./research.md)) |

## Complexity Tracking

> No constitution violations. Table intentionally empty.
