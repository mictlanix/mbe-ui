# Contract: The three POS step gates & the unconfirmed-changes question

**Feature**: `031-pos-write-gating` | Satisfies FR-003, FR-007 … FR-010,
FR-024 … FR-031

Where the guard meets the register: which writes register, which actions gate,
what the cashier sees, and what happens when they press continue with something
still typed.

---

## 1. Writes that register (FR-003)

All through `track` ([critical-action-guard.md §2](./critical-action-guard.md)),
at the controller method, releasing **after** the new state is published.

| Controller | Methods |
|---|---|
| `PosSaleController` | `updateHeader`, `addLine`, `updateLine`, `removeLine`, `confirm` |
| `DeliveryController` | `addDestination`, `updateDestination`, `removeDestination`, `assignLine`, `adjustLine`, `dropLine`, `sweepRemainderToCounter` |
| `PaymentController` | `submit`, `reverse` |

Deliberately **not** registered: `load`, `refresh`, `ensureOpen`, the product
lookup, the warehouse list, the stock cache — reads, or an open that moves no
figure (research R3). `PosSaleController.startNew()` and `.load()` additionally
`reset()` the scope.

**Plus one hold**: `QuantityStepperController` holds the guard from the moment a
value is confirmed locally until it settles — covering the ~400 ms coalescing
window that no future spans (FR-004, research R2). The release is attached to
the write's future so the `dispose`-time flush releases too.

---

## 2. The three gates (FR-007, FR-008)

| Step | Action | Widget | Existing conditions | Busy visual |
|---|---|---|---|---|
| Venta | continue to Cobro | `SaleTotalsBar.onContinue` ← `capture_step.dart` | `sale.isEditable`, `lineCount > 0`, `!_confirming` | the bar's existing `confirming` spinner |
| Cobro | continue / finish | the summary panel's FAB ← `payment_summary_panel.dart` | `canLeavePayment(balance, isCreditTerms)` | the FAB's existing disabled treatment, plus `draft.submitting` |
| Entrega | finish | `LineDistributionFoot.onClose` ← `delivery_step.dart` | `complete`, `!_closing` | the foot's existing `closing` state |

Each gains `pendingWrites == 0`, ANDed with the above. Nothing else on any of
the three surfaces changes availability (FR-009): lines stay editable, the
quantity stepper stays live through its own writes, products can still be
scanned, and a destination can still be assigned while another write is in
flight.

The busy visual is **reused, not invented** (FR-008): each of the three
surfaces already has one for its own submission, and the requirement is that
the cashier sees "working", not that a new indicator appears.

`_confirming`, `_closing` and `draft.submitting` all stay. They guard one press
against itself; the counter answers a different question (research R12), so
FR-010's "no two competing mechanisms" is not in play — what FR-010 removes is
`PosStepController.writeInFlight`, along with its `copyWith` parameter,
`setWriteInFlight`, and the two assertions in `pos_step_controller_test.dart`
that are its only readers.

---

## 3. The unconfirmed-changes question (FR-024 … FR-031)

Every one of the three actions runs through the same flow:

```text
press
 ├─ pendingWrites > 0 ──▶ unreachable: the action is disabled (FR-007)
 ├─ registry empty ─────▶ proceed exactly as today (FR-029)
 └─ registry non-empty ─▶ ask once (FR-030)
       ├─ keep ─────────▶ confirm() every entry ─┬─ all succeed ─▶ proceed
       │                                         └─ any refused ─▶ stay; fields restored; refusal surfaced (FR-026)
       ├─ discard ──────▶ discard() every entry (each plays its acknowledgement) ─▶ proceed (FR-027)
       └─ keep editing ─▶ stay; typed text intact (FR-028)
```

**The premise this rests on is measured, not assumed**: tapping a Material
button does not move focus, so the field's typed text is still unconfirmed when
the handler runs (research R4). A widget test asserts it inside the callback so
a future Flutter upgrade cannot quietly break the feature — if it ever did, the
discard would simply have happened first and the question would not appear,
which is the pre-feature behaviour rather than a defect.

**The dialog** (`widgets/unconfirmed_changes_dialog.dart`): `AlertDialog`,
`barrierDismissible: false`, three actions in Material order — keep editing
(dismissive), discard, keep (the primary). A `null` result maps to **keep
editing**: the answer that changes nothing, so no dismissal can silently save
or silently lose a value (research R11).

Five new l10n keys, `es-MX` authored first with `en` alongside:
title, body, and the three action labels. `l10n_parity_test.dart` enforces the
pair.

While the kept values are being written, the action shows the same busy visual
as any other outstanding write — because it *is* one: `confirm()` goes through
the field's own commit path, which registers in the guard (FR-026).

---

## 4. Tests this contract owes

| Behaviour | Assertion |
|---|---|
| Venta gate | edit a line's discount; continue disabled while the write is outstanding; enabled again when the totals update |
| Venta gate, refusal | the write is refused → continue is available again (no lockout, SC-003) |
| Venta gate, concurrency | two lines edited → still disabled after the first settles, enabled after the second |
| Coalescing window | tap + then press continue immediately → the sale does not advance on the pre-tap total |
| Cobro gate | a payment being applied → the FAB is unavailable; a reversal in flight → likewise |
| Entrega gate | an assignment outstanding → finish unavailable; a destination create/edit/remove → likewise |
| Nothing else disabled | during an outstanding write, the stepper, the pickers and the search box all still respond (SC-005) |
| Same-frame release | the frame the totals update is the frame the action becomes pressable (SC-002) |
| Question — keep | typed discount + continue + keep → one write with the typed value, then the step advances |
| Question — keep refused | same, refused → the step does not advance, the field restores, the refusal shows |
| Question — discard | typed discount + continue + discard → no write, acknowledgement plays, step advances |
| Question — keep editing | typed discount + continue + keep editing → no write, no advance, text still there |
| Question — never spurious | a sale with every edit confirmed → continue advances with no dialog (SC-013) |
| Question — asked once | two lines with unconfirmed discounts → one dialog, answer applies to both (FR-030) |
| Focus premise | inside the action's callback, the field still reports unconfirmed text (research R4) |
| `writeInFlight` gone | `PosStepState` no longer exposes it; the step machine's other behaviour is unchanged |
