# Quickstart: Proving the write gating and the field discard work

**Feature**: `031-pos-write-gating` | **Date**: 2026-08-23

In the order that finds problems fastest. Nothing here is blocked — no endpoint
changes, no codegen, no upstream dependency.

**This feature is almost entirely timing.** A gate that opens one microtask
early, a hold that is never released, a dialog that never appears because the
press discarded the text first — none of those show up in a screenshot, and all
three pass a careless suite. §1 and §3 are where this feature is actually
verified; §4 is where the bug that started it gets reproduced.

---

## 1. Automated

```bash
flutter analyze
dart run build_runner build --delete-conflicting-outputs   # the guard's .g.dart
flutter test test/unit/core/critical_action_guard_test.dart
flutter test test/unit/features/sales/ test/widget/features/sales/ test/widget/core/
flutter test test/golden/                    # MUST pass with no re-baselining
flutter test                                 # full suite before pushing
```

Green means: the counter counts (concurrently, and back to zero on failure),
holds are released even from a disposed controller, the three gates open and
close with the figures, the confirm-or-discard rule behaves identically after
being extracted, and the dialog's three answers each do their own thing.

**The golden check is a real assertion here.**
`test/golden/goldens/pos_sale_line_{light,dark}_{narrow,wide}.png` and
`pos_sale_totals_bar_*` must pass **unchanged** — extracting the confirm-or-discard
core is meant to be pixel-neutral
([contracts/confirmable-field.md §4](./contracts/confirmable-field.md)). If a
golden diffs, something moved that should not have; do **not** regenerate the
baseline to make it pass.

Must stay green untouched: `test/unit/features/sales/quantity_stepper_controller_test.dart`,
`test/widget/features/sales/quantity_stepper_widget_test.dart`,
`test/widget/features/sales/sale_line_symmetry_test.dart`,
`test/widget/features/sales/payment_step_gate_test.dart`,
`test/unit/core/formatting_guard_test.dart`,
`test/unit/core/l10n_parity_test.dart`.

One test is *expected* to change: `test/unit/features/sales/pos_step_controller_test.dart`
loses its two `writeInFlight` assertions (FR-010, research R9). That is the only
sanctioned edit to an existing assertion.

---

## 2. Getting to the surfaces

```bash
flutter run -d chrome --dart-define-from-file=.env
```

- **Venta**: sign in, open the POS, scan or search a product. Two lines make
  the concurrency cases reachable.
- **Cobro**: continue to payment; apply a partial payment to see the balance
  move under an outstanding write.
- **Entrega**: put two lines on the sale, choose mixed fulfilment, take the
  payment, and the delivery step opens with the store row and the
  add-destination action.

Widths worth switching between: **1440** (two panes), **1024** (the capture
line's single-row budget), **380** (compact cards). Also worth one pass at the
largest text-size level — §V requires the capture band be verified there, and
the dialog is new text.

**Throttle the network** (Chrome DevTools → Network → Slow 3G) before doing any
of §3 or §4. On a fast local API every write settles inside a frame and every
gate looks like it works.

---

## 3. The gates (US1, US4)

1. **The reported bug.** Change a line's discount % and immediately go for
   "Continuar al cobro". It must be visibly unavailable, then available — and
   the total on screen when it becomes available must be the discounted one.
   This is issue #164; it reproduces on the current build in three or four
   tries with the network throttled.
2. **The window.** Tap + once and press continue within the same half second.
   The sale must not advance on the pre-tap total. The button stays busy for
   the rest of the ~400 ms window plus the round trip — that wait is the
   clarified decision, not a stall (research R13).
3. **A refusal.** Force one (edit a line on a sale someone else closed, or stop
   the API mid-edit). The refusal shows, and continue becomes available again.
   A gate that stays shut here is the worst outcome this feature can produce.
4. **Concurrency.** With two lines, edit both in quick succession. Continue must
   stay unavailable until *both* settle.
5. **Nothing else freezes.** During an outstanding write: step another line's
   quantity, open the warehouse picker, scan another product. All must respond
   (FR-009 — this is the freeze spec 030 removed, and it must not come back).
6. **Cobro.** Apply a payment and press the continue FAB while it is in flight;
   then reverse a payment and try again. Unavailable both times, available with
   the balance the server confirmed.
7. **Entrega.** Step a destination's quantity and press finish inside the
   window; then create, edit and remove a destination and try during each.

---

## 4. The discount field and the question (US2, US3)

1. Type `15` over a line's discount and click the warehouse picker. The field
   returns to the line's own discount with a brief fade and a colour pulse, and
   the total does not move. Watch it once at full speed — if you have to be told
   it happened, SC-007 is not met.
2. Type `15` and press Enter. It commits, the total moves, and **no**
   acknowledgement plays.
3. Type `abc` and press Enter. Nothing is sent; the field resets with the
   acknowledgement.
4. Type `15` and press "Continuar al cobro" **without** pressing Enter. The
   question appears. Exercise all three answers, in three separate attempts:
   - **keep** → the discount is applied, then the step advances;
   - **discard** → the field resets visibly, then the step advances;
   - **keep editing** → nothing happens, and `15` is still in the field.
5. Repeat 4 with two lines carrying unconfirmed discounts: **one** dialog, and
   the answer applies to both.
6. Confirm every edit properly and press continue. No dialog — a cashier who
   does the right thing must never meet it.
7. Turn on reduce-motion (macOS: Accessibility → Display → Reduce motion) and
   repeat 1. The value must still visibly change and the tint still show.

---

## 5. Live backend

Every write this feature instruments already exists, so the live pass is about
timing rather than about a new endpoint. Run the POS live tests **serially**
(`-j 1`) — they commit real documents against the register.

```bash
U=$(grep '^MBE_ADMIN_USERNAME=' .env | cut -d= -f2- | tr -d '"')
P=$(grep '^MBE_ADMIN_PASSWORD=' .env | cut -d= -f2- | tr -d '"')
flutter test -j 1 test/integration/pos_counter_sale_flow_test.dart \
  test/integration/pos_delivery_split_flow_test.dart \
  --dart-define=MBE_POS_USERNAME="$U" --dart-define=MBE_POS_PASSWORD="$P" \
  --dart-define=MBE_POS_PRODUCT_PATTERN=clavo
```

`.env` defines no `MBE_POS_*` keys, so mapping the admin account across is
required; the default product pattern matches nothing sellable in the
register's warehouse, and these tests **skip rather than fail** when they find
too few products — a silent skip usually means a bad pattern, not a broken
flow.

Check while you are there:

- a full sale from scan to finish, network throttled, with a discount edited
  immediately before each step transition: every transition lands on figures
  the server confirmed — the whole feature in one run;
- a burst on the capture stepper still produces one `PUT`, not ten, in the
  server log (spec 030's guarantee, which the new hold must not disturb);
- no request appears that did not appear before this feature (FR-012 — the
  guard adds bookkeeping, not traffic).

---

## 6. What "done" looks like

- Issue #164 no longer reproduces on any of the three steps.
- No sequence of refusals leaves a step's action unavailable (SC-003) — the
  failure mode worth being paranoid about.
- The goldens pass unchanged.
- `PosStepController` no longer carries `writeInFlight`.
- `critical_action_guard_test.dart` drives the mechanism with an operation that
  has no sale in it (SC-010).
