# Contract: Critical Action Guard (`lib/core/async/critical_action_guard.dart`)

**Feature**: `031-pos-write-gating` | Satisfies FR-001 … FR-012, FR-024 (the
registry half), FR-030

The generic half of this feature: a mechanism any screen can use to stop a
critical action from firing while its own asynchronous work is outstanding, or
while the user has typed something they have not confirmed. It knows nothing
about sales, and nothing in `core/` may learn.

---

## 1. Shape

```dart
const _scope = 'a caller-chosen, opaque String';

// How many changes are outstanding in this scope.
final n = ref.watch(pendingWritesProvider(_scope));            // int

// Which fields in this scope hold unconfirmed text.
final dirty = ref.watch(unconfirmedEditsProvider(_scope));     // List<UnconfirmedEdit>
```

Both are `@Riverpod(keepAlive: true)` families keyed by the scope string.
`keepAlive` is load-bearing, not idiomatic drift: an autoDisposed entry is
recreated at zero when its last listener leaves, so a write begun against one
instance could end against another and the gate would answer wrongly
(research R1).

Scope strings are declared by the adopter, not by core. The point of sale
declares exactly one, in `features/sales/presentation/pos_write_scope.dart`.

---

## 2. Registering work — two modes

```dart
// Mode A — an ordinary write with a future.
Future<T> track<T>(Future<T> Function() action);

// Mode B — work outstanding before a future exists (a coalescing window).
Object begin();
void end(Object token);
```

**Rules**

1. `track` increments before invoking `action`, and decrements in a `finally` —
   so a throw releases exactly as a success does (FR-006). It rethrows
   unchanged: registration never alters what a write does, returns, or throws
   (FR-012).
2. `end` is idempotent. A token released twice is a no-op, not a decrement —
   the count can never go negative.
3. **Release after publish.** A caller that publishes new state must publish it
   *before* releasing, in the same synchronous block. Releasing first opens a
   window in which the action is pressable and the figures are stale — the very
   defect this feature exists to remove (research R6, SC-002).
4. A hold's release must not depend on the holder being alive. A holder that
   fires its last write from `dispose` attaches the release to that future
   (`.whenComplete`), which is safe precisely because these providers outlive
   any widget.
5. Every acquisition is paired by construction — a `finally`, a
   `whenComplete`, or a `try`/`finally` in the caller. No release is written
   by hand at each exit path.

**Reset**

```dart
void reset();   // drops the count to zero
```

For the boundary where a scope's work provably ends — a new sale, a different
sale loaded. It asserts in debug when it drops a non-zero count, so a leaked
hold fails a test instead of stranding a cashier with a dead button (FR-006).
It is not an error-recovery path and must not be called to "unstick" a gate.

---

## 3. Reading the gate

```dart
final blocked = ref.watch(pendingWritesProvider(scope)) > 0;
onPressed: (myOwnConditions && !blocked) ? _run : null,
```

The gate is **additive**: it is ANDed with whatever already gated the action,
and it never becomes the reason a *different* control is disabled (FR-009).
An action that was already unavailable stays unavailable for its own reason.

---

## 4. The unconfirmed-edits registry

```dart
class UnconfirmedEdit {
  final Object id;                        // stable for the field's lifetime
  final String text;                      // what was typed, uncommitted
  final Future<bool> Function() confirm;  // exactly what Enter would do
  final void Function() discard;          // exactly what a focus loss would do
}

void put(UnconfirmedEdit edit);   // add or replace by id
void remove(Object id);           // on confirm, on discard, on dispose
```

**Rules**

1. An entry exists only while its field holds unconfirmed text.
2. An entry never outlives its field: `dispose` removes it. A step action can
   therefore never be handed a `confirm` for a field that is gone.
3. Registry membership never disables anything (FR-005). It is read when a
   critical action fires, and only then.
4. Storing callbacks in provider state is deliberate: keeping a typed value
   (FR-026) has to go through the field's own commit path, which a dirty flag
   cannot do (research R5).

---

## 5. Adopting it on another screen

The whole recipe, and the proof of FR-011:

1. Declare a scope constant next to the screen.
2. Wrap each of the screen's writes in `track`.
3. AND the screen's submit condition with `pendingWrites == 0`.
4. If the screen has fields that confirm explicitly, register them and ask the
   question before submitting.

Nothing in steps 1–4 mentions a sale. `critical_action_guard_test.dart`
exercises the mechanism against a non-sales operation for exactly this reason
(SC-010).

**What it does not replace.** The product's per-form `submitting` flags
(cash-session open/close, the inline customer form, the destination editor) keep
working untouched. They answer "is *this* form mid-submit" — a re-entrancy
guard for one press — where this answers "is anything outstanding in this
scope". Converting them is explicitly out of scope.

---

## 6. Tests this contract owes

| Behaviour | Assertion |
|---|---|
| counting | two concurrent tracked writes → count 2; first settles → 1; second → 0 |
| failure | a tracked write that throws → count returns to 0, and the error still reaches the caller |
| holds | `begin` → count 1; `end` → 0; `end` again → still 0 |
| ordering | a tracked write's new state is observable before the count reaches 0 |
| reset | `reset()` zeroes the count; a non-zero reset trips the debug assertion |
| registry | `put`/`put`(same id)/`remove` → one entry, replaced, then none |
| scope isolation | two scopes count independently |
| non-sales adoption | the whole mechanism driven by an operation with no sale in it (SC-010) |
