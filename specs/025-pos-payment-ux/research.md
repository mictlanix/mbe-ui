# Phase 0 — Research: POS Payment Step Look & Feel

Every decision below is anchored in code that already exists in this repository,
in the recorded findings of specs 020/022/023, or in the constitution. Numbers
that decide a layout are arithmetic on real token values, shown so the next
reader can check them rather than trust them.

---

## R1 — The rail's threshold is 1200 px, and the arithmetic says why

**Decision.** The two-pane shape turns on at `LayoutBreakpoints.large`
(1200 px) — `MediaQuery.sizeOf(context).width >= LayoutBreakpoints.large`.
Below it, and down to the phone breakpoint, the step is one column with a
pinned footer. Below 600 px (`LayoutBreakpoints.isCompact`) it is the same
column, scrolling as one list.

**Rationale.** Work the widths with the real tokens. The rail carries a money
summary whose widest row is a label plus a currency figure; 360 px is what the
mock spends (400 px including its own padding) and what `NumberPad.maxPadWidth`
already establishes as "a comfortable fixed column" in this product. At the
Large tier `screenMargin` is 24 and `paneGutter` is 24, so:

| Window | Rail | Gutter | Margins | Capture pane |
|---|---|---|---|---|
| 1920 | 360 | 24 | 48 | 1488 |
| 1440 | 360 | 24 | 48 | 1008 |
| 1200 | 360 | 24 | 48 | 768 |
| 1024 | 360 | 24 | 48 | 592 |

At 1024 the capture pane is 592 px — a two-column method grid of 284 px cells
with a 360 px keypad below it, which fits, but leaves the tablet-landscape user
a rail they did not ask for at the cost of the entry surface. At 1200 the pane
is 768 px, which is where the method tiles stop being cramped (two 376 px
columns). 1200 is also already a named tier in this product, so the rule needs
no new constant.

**Alternatives rejected.** (a) 840 px (`isExpanded`, what `CaptureStep` uses for
its customer/mode row) — the capture pane would be 408 px, narrower than the
keypad plus a tile column, and the rail would win space from the surface the
cashier is actually typing into. (b) A percentage split — the rail's content is
fixed-width by nature (a label and a figure); giving it a share of a 1920-px
window would stretch a summary across 500 px of nothing.

**Note.** The number is an assumption in the spec, not a requirement. FR-003 and
FR-004 say *that* the shape changes with width, not where.

## R2 — The methods/keypad split inside the capture pane is the pane's own decision

**Decision.** Inside the capture pane, a `LayoutBuilder` puts the method grid
and the keypad side by side when the pane is at least **900 px** wide, and
stacks the keypad beneath the grid otherwise.

**Rationale.** Side by side needs two tile columns at a legible width
(2 × 260 = 520), a `paneGutter` (24) and the keypad at its cap
(`NumberPad.maxPadWidth` = 360): 904 px. Rounding to 900 gives the 1440-px
window its mock-faithful side-by-side arrangement (pane 1008) and gives the
1200-px window the stacked one (pane 768) — the same widths R1's table
produced, now read from the pane rather than the window.

**Why a `LayoutBuilder` and not another `MediaQuery` tier.** The pane's width is
not the window's: the workspace has no rail, but the step has one, and the
capture pane is what is left after it. Deciding from the window would be right
only at the exact widths where the rail happens to be 360 px.

## R3 — `NumberPad` is not touched

**Decision.** No change to `lib/core/widgets/number_pad.dart`. It keeps
`childAspectRatio: 1.8`, `maxPadWidth = 360`, its `shrinkWrap` grid and its
`OutlinedButton` keys. The new layout places it; it does not restyle it.

**Rationale.** FR-011 asks that the pad keep its key proportions and width cap.
Those are exactly the properties the widget already encodes, and its own
docstring records why: a `GridView.count` handed a wide pane derived ~550×300 px
keys and pushed the submit button below the fold, mis-entering amounts on a real
register. The cheapest way to honour a requirement that says "do not regress
this" is to not edit the file. It also keeps the four existing golden images
(`number_pad_{light,dark}_{narrow,wide}.png`) valid, so this feature adds zero
golden churn.

**Consequence for the mock.** The mock's keypad is a `grid-auto-rows:1fr` block
that fills its pane's height; the pad here will not fill a tall pane, and will
sit at the top of the space it is given. That is the deliberate divergence the
user asked for.

**Alternatives rejected.** Restyling the keys to the mock's filled tonal squares
— it buys a small visual gain, invalidates four goldens, and touches a shared
core widget used by nothing else today but designed to be shared. Out of
proportion to the ask.

## R4 — The amount display is still a `TextField`, dressed as the mock's figure

**Decision.** `PaymentAmountField` keeps a real `TextField` (key
`payment_amount_field`, `TextInputType.numberWithOptions(decimal: true)`) and
changes only its presentation: an uppercase section label above it,
`textAlign: TextAlign.end`, the currency as `prefixText`, `filled: true`, and a
text style of

```dart
typeRoles.heroHeading.copyWith(
  fontFamily: TypeRoles.monoFamily,
  fontFeatures: const [FontFeature.tabularFigures()],
)
```

**Rationale.** `heroHeading` resolves to `displaySmall` at expanded/large and
`headlineMedium` on a phone, so the figure is the largest thing in the pane at
every tier without a literal font size — the mock's 52 px/34 px pair expressed
as a role. Mono plus tabular figures is how every other money figure in this
product is drawn (`TypeRoles.money`, `recordId`), and it is what stops the digits
from shifting sideways as they are keyed. Keeping a real field is what FR-009
and FR-012 require: the keypad edits the same `TextEditingController` a physical
keyboard does, which is `NumberPad`'s whole contract.

**Alternatives rejected.** A read-only `Text` fed by the draft with the keypad as
the only input — it breaks keyboard entry, breaks `enterText` in the existing
widget tests, and drops the caret the mock itself draws.

## R5 — The draft has to survive the reflow, and today it would not

**Finding.** `_PaymentAmountFieldState` creates its `TextEditingController` in
`initState` and never seeds it from `PaymentDraft.amount`. The draft itself lives
in Riverpod and survives anything; the controller does not. Today that is
invisible because the widget is never rebuilt with a different ancestor chain.
The moment the step switches between the one-column and two-pane shapes, the
field is remounted, and the cashier would watch a keyed amount vanish from a
screen whose provider still holds it — and whose apply button would still be
enabled.

**Decision.** Seed the controller in `initState` from the current draft:

```dart
_controller = TextEditingController(text: ref.read(paymentControllerProvider).amount);
```

The existing post-frame "clear when the draft was reset" listener stays as it is.

**Verification.** A widget test that resizes the surface across 1200 px with an
amount, a method and a reference in the draft, asserting all three survive
(spec edge case "a window resized across the two-pane threshold mid-tender").

## R6 — Method tiles: `Wrap` with a computed column count, not a `GridView`

**Decision.** `PaymentMethodGrid` renders a `LayoutBuilder` + `Wrap`, sizing each
tile with an explicit `SizedBox(width: …)` computed as
`(available - gutter × (columns - 1)) / columns`, with `columns` = 2 when the
available width admits two tiles of at least 260 px and 1 otherwise. Tile height
comes from its content, not from an aspect ratio.

**Rationale.** This is the same trap R3 exists to avoid: `GridView.count` derives
cell height from cell width, so a pane that grows sideways grows the tiles
vertically. A tile is a fixed-height object (icon, name, secondary line); `Wrap`
lets it be exactly as tall as its text needs, wraps to one column when the pane
is narrow, and never scales with the pane. `SaleLineRow` already establishes
"measure the budget, choose the arrangement" as this feature area's idiom.

**Tile construction.** `Material` + `InkWell` inside a `Container` with
`shapes.md` radius: a 1 px `outlineVariant` border unselected; a 2 px `primary`
border, `elevations.engaged.surfaceColor` fill and a trailing
`Icons.check_circle` when selected. Wrapped in `Semantics(button: true,
selected: …)` so a screen reader announces the state the border carries
(FR-014, FR-017); `InkWell` gives it keyboard focus and activation for free.

**Alternatives rejected.** (a) `ChoiceChip` with an avatar — a chip cannot carry
a two-line body without becoming a mis-shapen pill. (b) `Card` + `ListTile` —
`ListTile`'s fixed leading/title/subtitle geometry is close, but its minimum
height and horizontal padding make a 2-column grid of them noticeably taller
than the mock's 64 px tile, and its selected state is a fill, not a border.

## R7 — Method icons need a mapping, and it belongs beside the label mapping

**Decision.** Add `IconData paymentMethodIcon(int code)` to
`lib/core/domain/payment_method.dart`, next to the existing
`paymentMethodLabel(l10n, code)`, switching on `PaymentMethod.fromCode` with the
same "unknown code falls back" posture (`Icons.payments_outlined`).

Mapping, from the mock's own choices where it makes one:

| Method | Icon |
|---|---|
| `cash` | `payments_outlined` |
| `check` | `receipt_long_outlined` |
| `eft` | `account_balance_outlined` |
| `creditCard` | `credit_score_outlined` |
| `debitCard` | `credit_card_outlined` |
| `electronicPurse`, `electronicMoney` | `account_balance_wallet_outlined` |
| `foodVouchers` | `restaurant_outlined` |
| `giving` | `swap_horiz` |
| `advancePayments` | `schedule_outlined` |
| everything else, and unknown codes | `payments_outlined` |

**Rationale.** The label mapping already lives there and its docstring records
that it was promoted precisely to stop a third copy being written. An icon
mapping is the same fact about the same enum. Outlined variants throughout,
matching the icon set the POS workspace already uses (`Icons.payments_outlined`
is the Cobro step's own indicator icon).

## R8 — The rail is a `Column`, and only its list scrolls

**Decision.** The rail is `Column[ header, Expanded(ListView of payments),
summary + action ]`, so the header and the summary stay put while the payments
list scrolls on its own (FR-006). The capture pane does not scroll at the widths
the two-pane shape is used at; it is a `Column` sized to fit, with the apply
action at its foot.

**Rationale.** This is the shape `CaptureStep` already uses (fixed header, one
`Expanded` scrolling region, pinned footer band) and the shape the mock draws.
The applied-payments list is the only region whose length is unbounded.

**The summary block's surface.** `elevations.raised.surfaceColor` with a top
hairline of `colorScheme.outlineVariant` — literally what `SaleTotalsBar` does,
because it is the same object in the same role: a statement about the list above
it, on its own plane. Reusing the treatment is what makes the two steps look
like one product.

## R9 — Where each figure comes from (no new derivation)

| Figure | Source | Notes |
|---|---|---|
| Total | `sale.total` | unchanged |
| Paid | `subtractAmounts(sale.total, sale.balance)` | exactly today's expression in `payment_step.dart` |
| Remaining | `sale.balance` | unchanged |
| Change | `PaymentController.changeFor(sale.balance)` | reads `state.amount`, so the widget must `watch` the provider, not `read` it |

**Consequence.** The summary widget is a `ConsumerWidget` that watches
`paymentControllerProvider` so the change row tracks the amount as it is keyed —
which is already how the current step gets its live change line. Nothing is
recomputed, and no rounding is done in the presentation layer (spec 020
research §1: figures come from the sale, never from arithmetic here).

## R10 — Copy: four new keys, one reworded value, one orphan removed

**New keys** (both locales, FR-029):

| Key | es-MX | en |
|---|---|---|
| `posPaymentChangeLabel` | Cambio | Change |
| `posPaymentGateHint` | Se habilita cuando el saldo queda en cero | Opens once the balance is settled |
| `posPaymentMethodRequiresReference` | Requiere referencia | Requires a reference |
| `posPaymentMethodNoReference` | Sin referencia | No reference needed |
| `posPaymentMethodSectionLabel` | Método de pago | Payment method |

**Reworded.** `posPaymentBalance` becomes "Restante" / "Remaining" — the mock's
own word for the same figure, and the one that reads correctly beside "Pagado".
The key is unchanged, so both existing tests that assert on it keep passing.

**Removed.** `posPaymentChange` ("Cambio: {amount}") becomes unused once the
change is a labelled row rather than an interpolated sentence — an orphan this
feature creates, so this feature removes it (CLAUDE.md §3).

**Reused unchanged.** `posAmountLabel`, `posQuickAmountRemaining`,
`posQuickAmountHalf`, `posPaymentReferenceLabel`, `posPaymentTotal`,
`posPaymentPaid`, `posApplyPayment`, `posContinue`, `posAppliedPaymentsTitle`,
`posNoAppliedPayments`, `posPaymentReferenceValue`,
`posPaymentPendingValidation`, `posPaymentCancelled`, `posReverseAction`.

## R11 — What the existing tests demand, and what has to change in them

**`payment_step_gate_test.dart`** reads `payment_close_button` as a
`FilledButton` and `payment_submit_button` as a `FilledButton`, taps
`payment_method_1`, and types into `payment_amount_field`. All four keys
survive. The close button today is a `FilledButton.tonal` — which *is* a
`FilledButton` — so as long as the rail's action stays in that family the
`tester.widget<FilledButton>` cast holds. **This constrains the implementation**:
the exit action must remain a `FilledButton`/`FilledButton.tonal`, not become a
`FloatingActionButton.extended` like the capture step's.

**`pos_compact_layout_test.dart`** drags inside `find.byType(ListView)` until
`payment_close_button` is visible. In the new compact shape that button is in a
pinned footer and is visible without dragging; `dragUntilVisible` returns
immediately when the finder already resolves, so the test still passes — but it
would no longer be testing what it claims. It gets rewritten to assert the
footer is reachable *without* scrolling, plus the existing no-horizontal-scroll
assertion, which is the actual FR-004 guarantee.

**`number_pad_test.dart`** and the four number-pad goldens are untouched (R3).

## R12 — Disabled and read-only parity: consult nothing new

**Finding.** `PaymentStep` today gates its controls on `draft.submitting` alone —
never on `sale.isEditable`. That is deliberate: a *completed* sale with an
outstanding balance is exactly the sale a cashier opens this step to pay
(`pos-screen.md` §5: "Selected sale is completed, balance > 0 → opens Cobro,
lines read-only, balance shown"). Making the tiles or the keypad honour
`isEditable` would break paying a confirmed sale.

**Decision.** The new widgets take the same `enabled: !draft.submitting` flag
the current ones take, and nothing else. FR-030 is satisfied by carrying the
flag through, not by adding a condition.

## R13 — File layout: one composer, three presentational widgets

**Decision.**

| File | Role |
|---|---|
| `payment/payment_step.dart` | the composer: reads the sale and the draft, chooses one column or two panes, hosts the error banner |
| `payment/payment_capture_pane.dart` *(new)* | amount + quick amounts + method grid + reference + apply, with the ≥900 px in-pane split |
| `payment/payment_summary_panel.dart` *(new)* | total / paid / remaining / change, the exit action and the gate hint — used at the rail's foot and as the compact footer band, one widget in both shapes |
| `payment/applied_payments_panel.dart` | restyled to the mock's cards; keeps its reversal dialog and its keys verbatim |
| `payment/payment_amount_field.dart` | restyled per R4, seeded per R5 |
| `payment/payment_method_grid.dart` | tiles per R6 |

**Rationale.** The summary being *one* widget used in both shapes is what keeps
FR-021 and FR-004 from drifting apart — there is no second copy to forget. The
split mirrors `capture/`, where `capture_step.dart` composes and each band is its
own file.

**No controller changes.** `PaymentController`, `orderPaymentsController`,
`facilityPaymentOptionsController` and every repository are untouched (FR-001,
SC-009).

## R14 — No new goldens

**Decision.** This feature adds no golden images. Its guarantees are structural
(what is on screen, what scrolls, what is pinned, what keeps its aspect ratio)
and are asserted with widget tests and size assertions, which is how spec 023
verified the same class of change.

**Rationale.** Goldens on a data-driven, provider-fed step lock in fixture text
as much as layout, and the pad — the one piece whose pixel geometry is the
requirement — already has its four.
