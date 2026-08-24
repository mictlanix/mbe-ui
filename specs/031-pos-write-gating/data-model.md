# Data Model: POS Write Gating & Field Discard

**Feature**: `031-pos-write-gating` | **Date**: 2026-08-23

No persisted data, no entity, no DTO, no schema. Everything below is
in-memory UI state (constitution §VII); it is listed because its transitions
are what the tests assert.

---

## 1. Pending writes (per scope)

| Field | Type | Meaning |
|---|---|---|
| `count` | `int` (≥ 0) | changes begun in this scope and not yet settled |

Scope is an opaque `String`. The point of sale uses one: `posWritesScope`.

**Two ways a change enters the count**

| Mode | Enters when | Leaves when |
|---|---|---|
| tracked future | a controller method is invoked | that method's future completes — success **or** failure — and **after** its new state is published (research R6) |
| hold | a value is confirmed locally but not yet sent (a coalescing window opens) | the value is sent and settles, or is superseded, or is discarded |

**Invariants**

- `count == 0` ⟺ every figure on screen is a figure the server confirmed.
- `count` never goes negative: releasing an already-released hold is a no-op.
- No `count > 0` outlives the sale it belongs to: `startNew()`/`load()` reset
  the scope, and a reset that drops a non-zero count asserts in debug.

**State transitions**

```text
idle (0) ──begin/track──▶ outstanding (n>0) ──last settles──▶ idle (0)
                │                    ▲
                └──another write─────┘   (n increments; the gate stays closed)
```

---

## 2. Unconfirmed edit entry (per field, per scope)

| Field | Type | Meaning |
|---|---|---|
| `id` | `Object` | the field's identity — stable for its lifetime, unique in the scope |
| `text` | `String` | what the cashier typed and has not confirmed |
| `confirm` | `Future<bool> Function()` | commit it exactly as Enter would (FR-026) |
| `discard` | `void Function()` | discard it exactly as a focus loss would (FR-027) |

An entry exists **only** while its field holds unconfirmed text. It is added on
the first unconfirmed keystroke, replaced (same `id`) on each subsequent one,
and removed on confirmation, on discard, and on dispose.

**Invariant**: an entry never outlives its field. A removed sale line, a
changed step and a torn-down surface all leave the registry empty of it, so the
step action can never be asked to keep a value whose field is gone.

---

## 3. Confirmable field value

The three values a field distinguishes, and which one it shows:

| Value | Meaning | Shown when |
|---|---|---|
| `accepted` | the last value known to be on the server | nothing newer exists |
| `pending` | confirmed locally, not yet acknowledged by the server | present (steppers only — a typed field has no pending state of its own) |
| `typed` | keystrokes not yet confirmed | present — it wins over both |

`displayed = typed ?? pending ?? accepted`

**Transitions**

```text
                    ┌──── edit ────┐
                    ▼              │
accepted ──────▶ typed ──submit(valid)──▶ pending ──write ok──▶ accepted
   ▲               │  │                      │
   │               │  └─submit(invalid)──┐   └──refused──┐
   │        abandon│                     │              │
   └───────────────┴─────────────────────┴──────────────┘
                        resetTick++  (the acknowledgement plays)
```

`resetTick` is a monotonic counter, not a flag: the widget animates when it
changes, and its value carries no meaning beyond "different from last time".
Every arrow that lands back on `accepted` from `typed` bumps it — abandonment
(FR-014), an unparseable entry (FR-016), a server refusal (FR-017), and an
external change that invalidates typed text (FR-018).

---

## 4. Unconfirmed-changes answer

| Value | Effect |
|---|---|
| `keep` | every registered entry's `confirm()` runs; the step action proceeds only if all succeed |
| `discard` | every entry's `discard()` runs (each plays its acknowledgement); the step action proceeds |
| `keepEditing` | nothing runs; the step action does not proceed; typed text stays |

An unanswerable dismissal (Esc, a barrier tap we did not anticipate) maps to
`keepEditing` — the answer that changes nothing (research R11).

---

## 5. Step gate conditions

The gate each step's primary action evaluates. Only the last column is new.

| Step | Action | Existing conditions | New condition |
|---|---|---|---|
| Venta | continue to Cobro | sale editable, ≥ 1 line, not already confirming | pending writes == 0 |
| Cobro | continue to Entrega / finish | balance settled or credit terms, not already submitting | pending writes == 0 |
| Entrega | finish | distribution complete, not already closing | pending writes == 0 |

The unconfirmed-edits registry is **not** part of the gate: unconfirmed text
never disables an action (FR-005). It is read when the action fires, and only
then (FR-024).
