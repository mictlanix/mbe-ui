# Contract: Confirmable text field (`lib/core/widgets/confirmable_text_field.dart`)

**Feature**: `031-pos-write-gating` | Satisfies FR-013 … FR-021, FR-031

Spec 030's rule — typed text is confirmed by Enter and by nothing else, and
text abandoned without confirmation is discarded visibly — extracted from the
quantity stepper so the discount field can have it without a second copy
(FR-020). The extraction must be invisible: the quantity stepper's pixels and
behaviour are unchanged (research R7, R8).

---

## 1. `ConfirmableFieldController extends ChangeNotifier`

Owns the three values in [data-model.md §3](../data-model.md) and the rule that
decides between them.

```dart
ConfirmableFieldController({
  required String value,                         // the accepted value
  required String? Function(String) parse,       // null ⇒ not a valid value
  required Future<bool> Function(String) commit, // false ⇒ refused (never throws)
});

String get displayed;            // typed ?? pending ?? accepted
String get accepted;
bool   get hasUnconfirmedText;
int    get resetTick;            // bumped on every discard

void edit(String text);          // a keystroke — sends nothing
void submit(String text);        // Enter — parse, then commit, or discard+reset
void abandon();                  // focus lost / torn down — discard+reset if dirty
void sync({required String value});  // the server's own value pushed in
```

**Rules**

1. `edit` never writes (FR-013). Only `submit` — or a subclass's own confirmed
   path — reaches `commit`.
2. `submit` with text `parse` rejects: nothing is sent, the typed text is
   dropped, `resetTick` bumps (FR-016).
3. `abandon` on a dirty field: dropped, `resetTick` bumps (FR-014). A no-op
   when nothing was typed — pressing Enter and then clicking away must not
   animate anything (edge case: "Enter pressed twice").
4. `commit` returning `false` restores the accepted value and bumps
   `resetTick` (FR-017). `commit` reports refusal; it never throws — the host
   converts its own errors, keeping each surface's refusal presentation its own
   (spec 030 research R3, preserved).
5. `sync` while dirty: if the incoming value differs from the accepted one, the
   typed text loses and `resetTick` bumps (FR-018). If it is the same value, the
   typed text stays — a no-op refresh must not wipe an edit in progress.
6. The controller registers itself in the unconfirmed-edits registry while
   dirty and removes itself on confirm, on discard and on `dispose`
   ([critical-action-guard.md §4](./critical-action-guard.md)).

---

## 2. `ConfirmableTextField`

The field plus the acknowledgement, lifted verbatim from
`_QuantityStepperState._animatedField`:

- a 250 ms (`kFieldResetAnimation`) cross-fade — the old text out, the restored
  text in — with the swap landing while the text is invisible, so the value
  never appears to jump;
- a colour pulse of the same wrapper (`colorScheme.errorContainer`) peaking and
  settling with it;
- both driven by one `peak` value, keyed off `resetTick`;
- reduced motion (`MediaQuery.disableAnimations`): the value swaps immediately
  and the tint is held for the same duration, so the acknowledgement is still
  perceptible without a transition (FR-015's reduced-motion case).

**Layout neutrality is a requirement, not a hope** (FR-021). The wrapper is a
`DecoratedBox` + `Opacity`: transparent and fully opaque at rest, adding no
insets. The host supplies the `InputDecoration`, the `TextStyle` and the
keyboard type, so a field adopting this keeps its exact appearance.

`onSubmitted` → `controller.submit`, `onChanged` → `controller.edit`, and a
`FocusNode` listener → `controller.abandon` on focus loss. That last wiring is
the only place FR-031's "leaving a field discards silently" is implemented.

---

## 3. The two hosts

| Host | How |
|---|---|
| `QuantityStepperController` (`features/sales/presentation/widgets/quantity_stepper.dart`) | **extends** the base, adding bounds (`min`/`max`/`stepBy`), `step`, `set`, the 400 ms debounce, and its `money.dart` arithmetic. `QuantityStepper` composes `ConfirmableTextField` between its −/+ buttons, in both skins, with the same decorations and `dense` behaviour it has today. It additionally takes a guard **hold** while a value is pending (FR-004). |
| The sale line's discount field (`features/sales/presentation/capture/sale_line_editing.dart`) | uses the base **directly** — no subclass — with `parse: formatters.field.parseRate` and `commit:` the existing `updateLine(discountRate:)` path. Rendered by `ConfirmableTextField` in `sale_line_row.dart`'s control band and in `sale_line_card.dart`'s stacked layout. |

The discount keeps everything else about its current behaviour: no stepper, no
debounce, Enter-only commit, and the line's other controls still go inert for
the duration of its write (FR-019, via the mixin's existing `_busy`).

---

## 4. What must not change

- `pos_sale_line_{light,dark}_{narrow,wide}.png` and `pos_sale_totals_bar_*`
  pass **unchanged**. A diff is a bug in the extraction, not a new baseline
  (research R8).
- `quantity_stepper_controller_test.dart` and `quantity_stepper_widget_test.dart`
  pass unchanged: every spec 030 behaviour — burst coalescing, bounds,
  Enter-only confirmation, abandonment, the dispose flush, the reset animation —
  is the same behaviour after the split.
- `sale_line_symmetry_test.dart` and `sale_line_row_test.dart` pass unchanged:
  the band's height, baseline and column widths are untouched.
- `formatting_guard_test.dart` stays green: the field's text still comes from
  `formattersProvider`, never from `toStringAsFixed`.

---

## 5. Tests this contract owes

| Behaviour | Assertion |
|---|---|
| Enter confirms | typed + Enter → one commit with the parsed value; no reset |
| focus loss discards | typed + focus away → no commit, field shows accepted, `resetTick` bumped |
| unparseable | typed garbage + Enter → no commit, reset plays |
| refusal | `commit` → `false` → field restored, reset plays |
| external change | `sync` with a different value while dirty → typed text loses |
| no-op sync | `sync` with the same value while dirty → typed text survives |
| double Enter | Enter, then Enter again on the same value → one commit, no reset |
| reduced motion | `disableAnimations: true` → value swaps at once, tint still shown |
| registry | dirty ⇒ one entry; confirmed/discarded/disposed ⇒ none |
| layout | the wrapper adds no insets: field size identical with and without it |
