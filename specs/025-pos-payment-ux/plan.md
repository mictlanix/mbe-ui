# Implementation Plan: Point of Sale — Payment Step Look & Feel

**Branch**: `025-pos-payment-ux` | **Date**: 2026-08-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/025-pos-payment-ux/spec.md`

---

## Summary

Spec 023 reshaped the capture step against its mock and explicitly deferred this
one. This feature is that deferred half: the payment step keeps every rule it
has and changes only how it looks.

The approach, in one paragraph: at 1200 px and wider the step becomes two panes
— capture on the left (a headline amount, the quick amounts, a grid of method
tiles, the keypad, the reference, and "Aplicar pago" at its foot) and a fixed
360-px rail on the right holding the applied payments, the money summary and
"Continuar". Below that it is the same content as one column with the summary
and the exit pinned as a footer band, which is the shape `SaleTotalsBar` already
gives the capture step. The method chips become tiles carrying an icon, the
option's name and what it will ask for; the amount field keeps being a real
typable field but is drawn as the mock's large right-aligned figure; the change
stops being a line that flickers in and out under the amount and becomes a
permanent row of the summary. No controller, repository or request is touched.

Three findings from research are worth reading before implementing. The rail's
1200-px threshold and the 900-px in-pane split are arithmetic on the real
spacing tokens, not taste ([research R1, R2](./research.md)). `NumberPad` is
deliberately **not edited** — the requirement to keep its key proportions is
already what the file encodes, and leaving it alone also keeps its four goldens
valid ([R3](./research.md)). And `PaymentAmountField` has a latent bug this
feature would otherwise expose: its controller is never seeded from the draft,
so the first reflow across the threshold would blank a keyed amount the provider
still holds ([R5](./research.md)).

## Technical Context

**Language/Version**: Dart 3.10.3+ / Flutter stable

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `decimal`,
`intl`, `flutter_localizations`. No new package.

**Storage**: none — online-only (constitution §VII). This feature persists
nothing and reads nothing new.

**Testing**: `flutter_test` + `mocktail`; the existing `pos_test_harness.dart`;
the spec 022 golden harness (used by `number_pad_test.dart` only, and unchanged
here)

**Target Platform**: Flutter web/desktop first (expanded/large tiers), with the
tablet and phone tiers explicitly in scope (FR-004, SC-005)

**Project Type**: single Flutter application (feature-first layers)

**Performance Goals**: zero added requests (SC-009); no new provider watch
outside the two widgets that need the draft

**Constraints**: no literal colour/spacing/size values (FR-028, SC-006); every
existing widget-test key preserved (FR-031); `NumberPad`'s key aspect ratio and
width cap unchanged (FR-011, SC-004)

**Scale/Scope**: one step of one screen — six presentation files, two of them
new, plus one shared-kernel helper and five localization keys

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | Note |
|---|---|---|
| I. Feature-first layered architecture | **Pass** | Everything lands in `features/sales/presentation/payment/`; the one shared addition (`paymentMethodIcon`) goes to `core/domain/payment_method.dart`, beside the label mapping it mirrors — the shared-kernel rule's own prescription |
| II. Riverpod for state and DI | **Pass** | No new provider, no new state. The two new widgets are `ConsumerWidget`s watching providers that already exist |
| III. Contract-driven API integration | **Pass — trivially** | No request, no DTO, no codegen. No mbe-api change is needed, so no external dependency is filed |
| IV. Deny-by-default RBAC | **Pass** | No new action to gate. The step's existing gating (the POS route gate, the reversal action) is untouched |
| V. Material 3, white-labeled | **Pass** | Material 3 throughout (`InkWell`, `FilledButton`, `ActionChip`, `TextField`). All colour and type from the theme and the spec 022 tokens; both new labels shipped in `es-MX` and `en` |
| VI. Desktop/web-first, compact-ready | **Pass** | Breakpoints come from `core/layout/breakpoints.dart`; the pane-level split uses `LayoutBuilder`. The list/table, row-action, form-grid and `AppBar.actions` rules do not apply — the POS workspace is not a catalog list or a record form, as spec 023 established for the same reason |
| VII. Online-only | **Pass** | Nothing cached, nothing stored |

**Re-check after Phase 1 design**: unchanged — no gate moved. The design added
one pure function to the shared kernel (§I's prescribed home for a mapping over
a shared enum) and two presentation widgets. No Complexity Tracking entry is
required.

## Project Structure

### Documentation (this feature)

```text
specs/025-pos-payment-ux/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — R1…R14
├── data-model.md        # Phase 1 output — read-only inventory; no new entity
├── quickstart.md        # Phase 1 output — how to prove it works
├── contracts/
│   └── payment-surface.md   # Phase 1 output — the UI contract
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── domain/
│   │   └── payment_method.dart          # + paymentMethodIcon(code)   [edit]
│   ├── design/                          # spacing / shapes / type roles  [read]
│   ├── layout/breakpoints.dart          # LayoutBreakpoints.large        [read]
│   └── widgets/number_pad.dart          # UNTOUCHED (research R3)
├── features/sales/presentation/
│   ├── payment/
│   │   ├── payment_step.dart            # composer: one column or two panes [rewrite]
│   │   ├── payment_capture_pane.dart    # amount + chips + tiles + pad + ref [new]
│   │   ├── payment_summary_panel.dart   # figures + Continuar + hint         [new]
│   │   ├── payment_amount_field.dart    # headline figure; seed from draft   [edit]
│   │   ├── payment_method_grid.dart     # chips → tiles                      [edit]
│   │   ├── applied_payments_panel.dart  # ListTiles → cards                  [edit]
│   │   └── *_controller.dart            # UNTOUCHED
│   └── capture/sale_totals_bar.dart     # the footer-band treatment          [read]
└── l10n/
    ├── app_es.arb                       # +5 keys, 1 reworded, 1 removed     [edit]
    └── app_en.arb                       # same                               [edit]

test/
├── widget/features/sales/
│   ├── payment_step_gate_test.dart      # must stay green                    [read]
│   ├── payment_step_layout_test.dart    # shapes, reflow, overflow           [new]
│   ├── payment_summary_panel_test.dart  # figures, change, hint              [new]
│   ├── payment_method_grid_test.dart    # tiles, selection, reference        [new]
│   └── pos_compact_layout_test.dart     # phone case rewritten               [edit]
└── widget/core/widgets/number_pad_test.dart   # UNTOUCHED
```

**Structure Decision**: the existing feature-first layout, unchanged. The one
structural choice is that `PaymentSummaryPanel` is a single widget used in both
the rail and the compact footer — one implementation, so the two shapes cannot
drift ([research R13](./research.md)).

## Implementation phases

Ordered so each phase leaves the tree green.

**Phase A — the shared helper.** Add `paymentMethodIcon(int code)` to
`core/domain/payment_method.dart` with the mapping in [research R7](./research.md),
plus a unit test for the fallback on an unknown code. Nothing consumes it yet.

**Phase B — the copy.** Add the five keys to both `.arb` files, reword
`posPaymentBalance`, remove `posPaymentChange`; run `flutter gen-l10n`. The
removal will not compile until Phase D, so do B and D together or leave the
removal for D — the l10n parity test is the gate either way.

**Phase C — the leaf widgets.** In any order, each independently testable:
`PaymentMethodGrid` → tiles ([contract §4](./contracts/payment-surface.md));
`PaymentAmountField` → headline figure plus the `initState` seed
([R4](./research.md), [R5](./research.md)); `AppliedPaymentsPanel` → cards
([contract §5](./contracts/payment-surface.md)). Keys preserved verbatim in all
three.

**Phase D — the new composites.** `PaymentSummaryPanel`
([contract §6](./contracts/payment-surface.md)), then `PaymentCapturePane` with
its ≥ 900 px in-pane split ([contract §3](./contracts/payment-surface.md)).

**Phase E — the composer.** Rewrite `payment_step.dart` as the two-shape host
([contract §2](./contracts/payment-surface.md)).

**Phase F — the tests.** The three new widget tests, the phone-case rewrite in
`pos_compact_layout_test.dart`, and a full `flutter analyze && flutter test`.

**Phase G — drive it.** Walk [quickstart.md](./quickstart.md)'s width table
against a live register. The reflow row and the keypad row are the two that
research says are most likely to be wrong.

## Risks

| Risk | Mitigation |
|---|---|
| The exit action's widget type changes and `payment_step_gate_test.dart` stops compiling | The contract pins it: `FilledButton.tonal`, still a `FilledButton` ([R11](./research.md)) |
| The keypad regrows when placed in a new pane | `NumberPad` is not edited, and its existing test asserts exactly this at a desktop surface ([R3](./research.md)) |
| A keyed amount is lost on reflow | The `initState` seed, with a dedicated resize test ([R5](./research.md)) |
| Method tiles stretch vertically in a wide pane | `Wrap` with computed widths, never a `GridView` aspect ratio ([R6](./research.md)) |
| Literal values creep in while chasing the mock's look | SC-006 is a diff-level check; the contract names a token for every element |

## Complexity Tracking

> No constitution violations. Table intentionally empty.
