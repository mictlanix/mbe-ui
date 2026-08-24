# Contract: The shared quantity stepper

**Feature**: 030-pos-sales-refinements | Satisfies FR-001…FR-016

One file, `lib/features/sales/presentation/widgets/quantity_stepper.dart`,
holding a controller and a view (research R1, R2). Three hosts, one behaviour.

---

## 1. Public API

```dart
/// Owns the value, the debounce and the reset signal. One per line.
class QuantityStepperController extends ChangeNotifier {
  QuantityStepperController({
    required String value,          // the server's value ("accepted")
    required Future<bool> Function(String value) onCommit,
    String min = '0',
    String? max,
    String stepBy = '1',
  });

  String get displayed;            // typed ?? pending ?? accepted
  String get accepted;
  bool get canDecrement;           // displayed − stepBy >= min
  bool get canIncrement;           // max == null || displayed + stepBy <= max
  int get resetTick;               // bumped on every discard

  void sync({required String value, String? min, String? max});
  void step(int delta);            // +1 / −1, clamped
  void edit(String text);          // keystroke; records `typed`
  void submit(String text);        // Enter; confirms or discards
  void abandon();                  // focus lost with unconfirmed text
  void set(String value);          // host-driven confirm (claim-all, adjust-to-available)
  Future<void> flush();            // fire a pending commit now (tests, teardown)
}

/// The chrome, the focus wiring and the reset animation.
class QuantityStepper extends ConsumerStatefulWidget {
  const QuantityStepper({
    super.key,
    required this.controller,
    this.enabled = true,
    this.fieldKey,                 // goes on the TextField itself
    this.decoration,               // null → pill skin; non-null → field skin
    this.textStyle,
    this.dense = false,            // 32px shrink-wrapped buttons (wide sale row)
    this.decrementTooltip,
    this.incrementTooltip,
  });
}
```

**`onCommit` returns `false`, never throws** (research R3). The host performs
the write, surfaces its own refusal, and reports acceptance. A thrown error
inside `onCommit` is a host bug; the controller treats an errored future as
`false`.

**`fieldKey` is load-bearing**: `test/widget/features/sales/destination_assignment_test.dart`
finds `Key('destination_quantity_<saleLineId>')` as a `TextField` and reads
`controller!.text`. The key MUST land on the `TextField`, and the widget MUST
keep a real `TextEditingController` behind it.

---

## 2. Behaviour table

| Input | Sends | Field shows | Animation |
|---|---|---|---|
| Tap + / − | after ~400 ms, once for the burst | new value immediately | none |
| Type, press Enter, in range | after ~400 ms | typed value | none |
| Type, press Enter, out of range or unparseable | nothing | accepted value | **reset** |
| Type, focus lost | nothing | accepted value | **reset** |
| Type, then tap + / − | after ~400 ms | accepted ± step (**not** typed ± step) | none |
| Type, then teardown | nothing | — | — |
| Commit refused by host | — | accepted value | **reset** |
| Server value changes with a commit pending | nothing new | pending value (unchanged) | none |
| Server value changes with unconfirmed text | nothing | new server value | **reset** |
| Pending commit + teardown | the pending value | — | — |

Bounds are enforced twice: the −/+ actions are **disabled** at a bound
(FR-008), and `submit`/`set` clamp-or-refuse as above. The control is never
disabled by an in-flight write (FR-004); `enabled` reflects only whether the
host's surface is editable at all.

**Debounce window**: one named constant in this file
(`kQuantityCommitDebounce = Duration(milliseconds: 400)`), the delivery step's
existing window (spec 026), referenced by tests rather than re-typed.

---

## 3. Skins

| Host | `decoration` | `dense` | Result |
|---|---|---|---|
| `DestinationCard` | `null` | `false` | 44 px pill: `surfaceContainerHighest` fill, `outlineVariant` border, `shapes.xlRadius`, 56 px field, compact `IconButton`s — pixel-identical to today |
| `SaleLineRow` (single/two row) | the band's `_fieldDecoration(label)` | `true` | plain field with its floating `Cant. (Pza)` label, 32 px shrink-wrapped buttons, inside the host's `_band(...)` — pixel-identical to today |
| `SaleLineCard` (compact) | `InputDecoration(labelText:, suffixText: unit)` | `false` | full-width row with default `IconButton`s — pixel-identical to today |

**Pixel-identical is a requirement, not an aspiration**: the four capture
goldens (`test/golden/goldens/pos_sale_line_{light,dark}_{narrow,wide}.png`)
MUST pass unchanged at the default text-size level (research R5). The pill's
own appearance is likewise unchanged, so `delivery_step_layout_test.dart` and
the compact delivery test keep their current expectations.

---

## 4. The reset animation

| Aspect | Specification |
|---|---|
| Trigger | `resetTick` changes |
| Duration | `kQuantityResetAnimation = Duration(milliseconds: 250)` |
| Value | field faded out and back in through the animation, text swapped at the midpoint (research R4) |
| Colour | control background tweened resting → `colorScheme.errorContainer` → resting; the value's text colour follows with `onErrorContainer` at the peak |
| Resting colour | pill skin: `surfaceContainerHighest`. Field skin: transparent — the tint is painted by the widget's own rounded wrapper, so both skins pulse the same way |
| Reduced motion | `MediaQuery.disableAnimationsOf(context)` → value swaps instantly; the tint is applied and cleared on the same 250 ms schedule (FR-016) |
| Never plays | on an accepted commit, on a normal server-value update, on first build (FR-014) |
| Semantics | the restored value is announced via the field's own value change; no separate live region — the reset is a correction, not an alert |

---

## 5. Host wiring

### `SaleLineEditing` (both capture tiers)

- Owns one `QuantityStepperController`, created in `initState`, `sync`ed from
  `line.quantity` in `didUpdateWidget` (alongside the existing `syncFields`).
- `onCommit` → `_serialized(() => posSaleController.updateLine(quantity: v))`,
  returning `false` on `AppError`. **Does not set `_busy`** (FR-004).
- `_busy` keeps gating the discount field, the tax picker and the warehouse
  picker exactly as today.
- All line writes — quantity, discount, tax, warehouse — pass through one
  per-line `Future` chain so two never overlap (FR-006, research R6).
- `step(int)` and the raw `quantityField` controller leave the mixin; the
  shortfall action's `update(quantity: availableQuantity)` becomes
  `quantityStepper.set(availableQuantity)`.
- Removed with them: nothing else. The price field, the pickers, the rejection
  re-keying (`_rejections`) and the shortfall computation are untouched.

### `DestinationCard`

- Replaces `_quantityControllers`, `_pending`, `_debounce`, `_inFlight` and
  `_request`/`_send`'s display bookkeeping with one controller per sale line,
  created lazily in the same `Map`-keyed way, disposed with the card.
- Keeps: `_lineErrors` (per-line server message), `_ceilingFor` (fed to the
  controller as `max` on every build), and the assign/adjust/drop dispatch —
  which moves into `onCommit`, where it still chooses `onAssign` for a line
  this destination does not carry, `onAdjust` for one it does, and `onDrop`
  at zero.
- `destination_claim_all_<saleLineId>` → `controller.set(_ceilingFor(line))`.
- The dispose-time flush that spec 026 documented is now the controller's
  (research R8); the card's own `dispose` no longer needs it.

---

## 6. Test contract

| Level | Must cover |
|---|---|
| Unit (`test/unit/features/sales/quantity_stepper_controller_test.dart`) | burst coalescing (FR-003), bound clamping both ends (FR-007/008), Enter-only confirmation (FR-010), abandonment discard (FR-011), out-of-range discard (FR-012), step-from-accepted-not-typed (FR-015), `sync` precedence table (research R7), no overlapping commits (FR-006), flush on dispose (FR-005) |
| Widget | reset animation plays on abandonment and not on acceptance (FR-013/014); reduced-motion path; both skins render at compact and expanded tiers; `Key('destination_quantity_*')` still resolves to a `TextField` |
| Golden | the four `pos_sale_line_*` files pass **unchanged** |
| Guard | `formatting_guard_test.dart` stays green — the displayed value goes through `formattersProvider.field.quantity` |
