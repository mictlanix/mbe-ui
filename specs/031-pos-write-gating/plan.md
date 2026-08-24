# Implementation Plan: POS Write Gating & Field Discard

**Branch**: `031-pos-write-gating` | **Date**: 2026-08-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/031-pos-write-gating/spec.md`

## Summary

Two halves of one rule: the register must never show a figure the server does
not hold, and must never let the cashier act on one.

1. **One outstanding-writes guard, in core.** A new
   `lib/core/async/critical_action_guard.dart` holds two scope-keyed Riverpod
   providers — a count of changes begun and not yet settled, and a registry of
   fields holding unconfirmed text
   ([contracts/critical-action-guard.md](./contracts/critical-action-guard.md)).
   Every mutating method on `PosSaleController`, `DeliveryController` and
   `PaymentController` registers in it; all three steps' primary actions gate
   on it ([contracts/pos-step-gates.md](./contracts/pos-step-gates.md)). The
   dead `PosStepController.writeInFlight` is removed rather than wired
   (research R9).
2. **The confirm-or-discard rule, extracted and applied.** Spec 030's rule and
   its 250 ms cross-fade-and-tint move into
   `core/widgets/confirmable_text_field.dart`; the quantity stepper keeps its
   bounds, its debounce and its decimal arithmetic on top of it, and the sale
   line's discount field adopts the base directly with no subclass at all
   ([contracts/confirmable-field.md](./contracts/confirmable-field.md)).
3. **The step-boundary question.** Pressing a step's action with unconfirmed
   text asks — keep, discard, or keep editing — instead of silently throwing
   the typing away (spec clarification, 2026-08-23).

No mbe-api change, no codegen, no new dependency, no new endpoint.

Five findings shape the work, and three of them cut against the obvious
reading:

- **A counter is not enough.** FR-004's coalescing window has no future to
  wrap, so the guard needs holds as well as future-tracking (research R2), and
  the release has to survive the holder's disposal because spec 030's stepper
  deliberately fires its last write from `dispose`.
- **The press does not destroy what it should ask about.** Measured, not
  assumed: a Material button takes no focus on tap, so the step action's
  handler still sees the unconfirmed text (research R4). Three defensive
  designs sketched before that probe were all unnecessary.
- **Release after publish, not before.** Decrementing the count before the new
  state is published leaves a one-microtask window with a pressable button and
  stale figures — the original bug in miniature (research R6).
- **The fields have to volunteer.** "Keep" must commit through the field's own
  path, so the step action needs a handle on the field, not just knowledge
  that one is dirty (research R5).
- **Half of spec 030's §VI divergence dissolves.** The confirm-or-discard core
  handles opaque strings and needs no `money.dart`, so it belongs in
  `core/widgets/` after all; only the stepper's arithmetic stays in the feature
  (research R7).

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.44.2 (stable, this toolchain)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator` (one new
generated family provider file), `decimal` via
`features/sales/domain/money.dart` (unchanged), `flutter_localizations`/`intl`,
the generated `mbe_api_client` (untouched). **No new dependency.**

**Storage**: N/A — online-only; the guard's state is in-memory UI state that
is never persisted (constitution §VII)

**Testing**: `flutter_test` (unit + widget + golden), `integration_test`
against a live mbe-api

**Target Platform**: Web (Chrome) primary, macOS/desktop; compact tier below
600 px

**Project Type**: Single Flutter application, feature-first layering

**Performance Goals**: the gate costs one rebuild of one action widget per
write start and stop; the action becomes pressable in the **same frame** the
totals update (SC-002, research R6); no request is issued that was not issued
before — the guard adds bookkeeping, not traffic.

**Constraints**: `pos_sale_line_*` and `pos_sale_totals_bar_*` goldens must
pass **unchanged** (research R8); the capture band's fixed height, column
budget and baseline (`sale_line_layout.dart`, spec 023) are untouched; the
~400 ms coalescing window is not shortened (clarification), so a
tap-then-continue waits the window plus the round trip with the action visibly
busy; a leaked hold would disable a step action permanently, which FR-006
forbids — hence the paired-release and scope-reset rules in research R2.

**Scale/Scope**: 1 new core mechanism (2 providers), 1 core widget +
controller extracted, 3 controllers instrumented (11 methods), 3 step actions
gated, 1 new dialog, 1 dead field removed. Typical sale: 1–20 lines, so up to
20 field controllers live at once on the capture step, each registering at
most one hold.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1. Both passes
below.*

| Principle | Assessment |
|---|---|
| **I. Feature-First Layered Architecture** | PASS. The new mechanism is generic UI plumbing in `core/`, depending on nothing in `features/` — the dependency runs the correct way (features → core). Everything else is `presentation/` inside `features/sales/`. No entity, repository, domain or data-layer change anywhere. |
| **II. Riverpod for State Management & DI** | PASS. The guard is exactly what §II's "local UI state … MUST use plain `Notifier`" prescribes: two `@Riverpod(keepAlive: true)` family notifiers, no hand-rolled singleton, overridable in tests. The extracted `ConfirmableFieldController` stays a plain `ChangeNotifier` for the reason spec 030 recorded — per-widget input state with a disposal contract, in the same category as the `TextEditingController` it wraps. `keepAlive` is justified in research R1, not idiomatic drift. |
| **III. Contract-Driven API Integration** | PASS. No codegen, no DTO, no new or changed endpoint, no mbe-api edit. Every write this feature instruments already exists and keeps its exact signature, return value and error surface (FR-012). |
| **IV. Deny-by-Default RBAC** | PASS. Nothing new is reachable. The feature only ever makes an existing action *less* available; no privilege is checked differently and no action appears that the surface did not already offer. |
| **V. Material 3, White-Labeled Design System** | PASS. The dialog is `AlertDialog` with `colorScheme` colours and `theme.spacing` gaps; the tint keeps `colorScheme.errorContainer`; no hex reaches Dart. Five new strings in both `.arb` files, `es-MX` authored first (`l10n_parity_test.dart` enforces the pair). Every displayed value still goes through `formattersProvider` — the discount field's parse continues to use `field.parseRate`, keeping `formatting_guard_test.dart` green. Verified at the largest text-size level on the capture band, §V's explicit POS requirement. |
| **VI. Desktop/Web-First, Compact-Ready Layout** | PASS, and it *reduces* an inherited divergence — see below. |
| **VII. Online-Only, Server-Rendered Documents** | PASS. No storage, no cache, no offline anything. The guard's count and registry live for the length of a keystroke-to-response and are never written down. |

### §VI in detail

| Rule | How this feature satisfies it |
|---|---|
| Shared widgets in `core/widgets/` | **Satisfied, newly.** `ConfirmableTextField` + its controller land in `core/widgets/`, which is where spec 030 wanted the whole stepper and could not put it. The stepper's decimal bounds/debounce stay module-local because they need `features/sales/domain/money.dart`; that half of spec 030's Complexity Tracking row survives, narrowed (research R7). |
| Breakpoints centralized in `core/` | Unchanged — no new breakpoint, no new tier logic. |
| Symmetric vertical padding, shared baseline in a control band, spacing from tokens | The capture band is untouched by construction: the discount field keeps its `_fieldDecoration`, its width and its style, and gains only a layout-neutral wrapper. `sale_line_symmetry_test.dart` and the goldens are the proof (research R8). |
| One fixed Edit icon; at most two row icons; row click opens read-only; toolbar-only Create; detail-screen Delete | Not applicable — no list row, no catalog screen, no record form is touched. |
| Mandatory pagination and filtering | Not applicable — nothing here is a list screen. |
| `AppBar.actions` empty; `RecordFormActions` for detail screens | Untouched; this feature adds no app-bar action. |
| No horizontal scroll; ellipsize with a fallback | Unchanged; no new text column. The dialog's body wraps rather than scrolls at every supported width. |

### Post-Phase-1 re-evaluation

Re-checked against the three contracts and the data model. No new violation,
and one divergence retired rather than added. Four decisions taken during
Phase 1 are the ones a reviewer should attack:

- **The registry holds callbacks in a provider** (research R5,
  [contracts/critical-action-guard.md §4](./contracts/critical-action-guard.md)).
  Unusual, deliberate, and bounded: entries are removed on dispose, nothing is
  serialized, and the alternative (walking the widget tree for dirty fields)
  cannot commit through a controller it cannot reach.
- **`startNew()`/`load()` reset the scope's count**, with a debug assertion
  when the count was non-zero. This is a safety net around a class of bug —
  a leaked hold — that would otherwise strand a cashier with a dead button.
  It could mask a leak in release; the assertion is what keeps it from masking
  one in a test.
- **The guard is one file with two providers**, not two mechanisms. They are
  answers to the same question a critical action asks — "is anything
  outstanding, and is anything unconfirmed?" — and splitting them would put
  the two halves of one gate in two places.
- **`_confirming`, `_closing` and `draft.submitting` all stay.** They are
  per-press re-entrancy guards and the source of each action's busy visual;
  the counter is about *other* writes. FR-010 bans a second mechanism for the
  same question, not a different one (research R10, R12).

## Project Structure

### Documentation (this feature)

```text
specs/031-pos-write-gating/
├── plan.md                          # This file
├── research.md                      # Phase 0 — R1…R13
├── data-model.md                    # Phase 1 — the guard's state, the field's states
├── quickstart.md                    # Phase 1 — how to prove it works
├── contracts/
│   ├── critical-action-guard.md     # the core mechanism, and how to adopt it
│   ├── confirmable-field.md         # confirm-or-discard: states, animation, hosts
│   └── pos-step-gates.md            # the three gates + the unconfirmed-changes question
├── checklists/
│   └── requirements.md              # spec quality checklist (specify step)
└── tasks.md                         # Phase 2 — /speckit-tasks, not created here
```

### Source code

```text
lib/
├── core/
│   ├── async/
│   │   ├── critical_action_guard.dart          # NEW — pendingWrites + unconfirmedEdits
│   │   └── critical_action_guard.g.dart        # NEW — generated
│   └── widgets/
│       └── confirmable_text_field.dart         # NEW — controller + field + reset animation
└── features/sales/presentation/
    ├── pos_write_scope.dart                    # NEW — the POS's scope constant
    ├── pos_sale_controller.dart                # 5 methods register; startNew/load reset
    ├── pos_step_controller.dart                # writeInFlight removed (FR-010)
    ├── capture/
    │   ├── capture_step.dart                   # gate + the unconfirmed-changes question
    │   ├── sale_line_editing.dart              # discount adopts ConfirmableFieldController
    │   ├── sale_line_row.dart                  # discount cell renders ConfirmableTextField
    │   └── sale_line_card.dart                 # same, compact tier
    ├── delivery/
    │   ├── delivery_controller.dart            # 6 methods register
    │   └── delivery_step.dart                  # gate + the question
    ├── payment/
    │   ├── payment_controller.dart             # submit + reverse register
    │   ├── payment_summary_panel.dart          # gate + the question
    │   └── ...
    └── widgets/
        ├── quantity_stepper.dart               # now extends the core base; holds a guard hold
        └── unconfirmed_changes_dialog.dart     # NEW — keep / discard / keep editing

test/
├── unit/
│   ├── core/critical_action_guard_test.dart            # NEW — counting, holds, leaks, non-sales scope
│   └── features/sales/
│       ├── quantity_stepper_controller_test.dart       # must stay green
│       └── pos_step_controller_test.dart               # writeInFlight assertions removed
├── widget/
│   ├── core/confirmable_text_field_test.dart           # NEW — confirm, discard, animation, reduced motion
│   └── features/sales/
│       ├── pos_write_gating_test.dart                  # NEW — the three gates
│       ├── unconfirmed_changes_test.dart               # NEW — the question + R4's premise
│       ├── sale_line_discount_test.dart                # NEW — the discount field's rule
│       └── (sale_line_row, sale_totals_bar, payment_step_gate, destination_* — must stay green)
└── golden/pos_capture_golden_test.dart                 # must pass unchanged
```

**Structure Decision**: the existing feature-first layout, with one new core
directory (`lib/core/async/`) for the guard. It goes in core rather than in
`features/sales/` by the spec's own clarification (FR-011) and by §II/§VI; the
POS's scope constant stays in the feature so core never learns what a sale is.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| The quantity stepper's controller stays in `features/sales/presentation/widgets/` rather than `core/widgets/` (§VI, inherited from spec 030) | Its bounds and stepping are exact-decimal arithmetic from `features/sales/domain/money.dart`; moving it would drag a feature's domain into core | Moving `money.dart` to core is a larger, unrelated refactor with its own blast radius (spec 030 research R1). This feature *narrows* the divergence: the confirm-or-discard core it used to justify now lives in core |
| `@Riverpod(keepAlive: true)` on both guard providers, where most controllers in this codebase are autoDisposed | An autoDisposed family entry is recreated at zero once its last listener leaves; a write begun against one instance could end against another, which is a silent wrong answer in a gate | Watching the provider from a long-lived widget to hold it alive works by accident and breaks the moment the widget tree changes. Precedent exists (`user_display_preferences_controller.dart`, the auth notifier) |
| The unconfirmed-edits registry stores callbacks in provider state | "Keep" must commit through the field's own path (FR-026), which needs a handle on the field, not a dirty flag | A boolean-per-field registry cannot commit; walking the widget tree for dirty fields cannot either, and is brittle besides (research R5) |
| A debug-only assertion plus a scope reset on `startNew()`/`load()` | A leaked hold disables a step action for the rest of the session, which FR-006 forbids outright | No net at all means a single missed release becomes an unusable register; a release-mode-only reset would hide the leak from the tests that should catch it |
