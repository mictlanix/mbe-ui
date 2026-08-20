# Quickstart: Proving the sale & delivery refinements work

**Feature**: `030-pos-sales-refinements` | **Date**: 2026-08-20

In the order that finds problems fastest. Nothing here is blocked: every
endpoint this feature touches is already live (research R9).

**Two of the three items are behaviour under the finger, not layout.** Spec
026 learned this the hard way — a stepper whose figure never moved and a UI
that froze on every tap both passed the whole suite. Debounce, focus loss and
animation timing are exactly that kind of defect, so §3 and §4 are not
optional.

---

## 1. Automated

```bash
flutter analyze
flutter test test/unit/features/sales/ test/widget/features/sales/
flutter test test/golden/                      # MUST pass with no re-baselining
flutter test                                   # full suite before pushing
```

Green means: the controller's state machine holds (bursts coalesce, bounds
clamp, Enter-only confirmation, abandonment discards), the three skins render
without overflow, the store row agrees with its own header, and both locales
are complete.

**The golden check is a real assertion here.** `test/golden/goldens/pos_sale_line_{light,dark}_{narrow,wide}.png`
must pass **unchanged** — the swap is meant to be pixel-identical on the
capture surface at the default text-size level (research R5,
[contracts/quantity-stepper.md §3](./contracts/quantity-stepper.md)). If a
golden diffs, something changed that should not have; do **not** regenerate
the baseline to make it pass.

Must stay green untouched:
`test/unit/features/sales/line_distribution_test.dart`,
`test/unit/features/sales/delivery_order_repository_impl_test.dart`,
`test/unit/core/formatting_guard_test.dart`,
`test/unit/core/l10n_parity_test.dart`.

---

## 2. Getting to the surfaces

```bash
flutter run -d chrome --dart-define-from-file=.env
```

- **Capture (Venta)**: sign in, open the POS, scan or search a product. Any
  line will do; a line whose product has a SAT unit on file shows the unit in
  the quantity label, which is the detail most at risk in the swap.
- **Delivery (Entrega)**: put at least two lines on the sale, pick the mixed
  fulfilment mode, continue to cobro, take the payment, and the step opens
  with the store row plus the add-destination action.

Widths worth switching between: **1440** (two regions, side sheet), **1024**
(tablet landscape — the capture line's single-row budget), **380** (compact
cards and bottom sheets).

---

## 3. The stepper, by hand

| # | Do this | Expect |
|---|---|---|
| 3.1 | Tap **+** on a sale line ten times as fast as you can | the figure follows every tap; the line's controls never grey out; the line's total settles once, on the tenth value |
| 3.2 | Watch the network panel during 3.1 | **one** `PUT .../lines/{id}` |
| 3.3 | Tap **+** and, before the write fires, change the same line's warehouse | both land; neither reverts the other; the quantity is not rolled back by the warehouse response |
| 3.4 | Type `25` over a quantity, click the warehouse picker | the field fades back to the original value with a brief tint; nothing is sent; the total does not move |
| 3.5 | Type `25`, press **Enter** | 25 is sent; **no** reset animation |
| 3.6 | Type `abc`, press **Enter** | nothing is sent; reset animation |
| 3.7 | With a line at 1, tap **−** | nothing happens, nothing is sent (capture floor is 1) |
| 3.8 | Type `9` without Enter, then tap **+** | the field shows `accepted + 1`, not `10` |
| 3.9 | Tap **+** and immediately press "Continuar al cobro" | the pending quantity still reaches the server; the sale confirms with the figure you stopped at |
| 3.10 | Set the app's text size to the largest level, repeat 3.1 at 1024 px | no clipping, no overflow, the band still one row |
| 3.11 | Enable the OS "reduce motion" setting, repeat 3.4 | the value snaps back with no fade; the tint still appears and clears |

Then the same control on the delivery step:

| # | Do this | Expect |
|---|---|---|
| 3.12 | Burst-tap a destination line's stepper | unchanged from today: figure follows, one write, rail and header follow |
| 3.13 | Type a quantity above what the line still owes, press Enter | nothing sent, reset animation (today it snaps back silently) |
| 3.14 | Press "assign everything pending" | the figure jumps to the ceiling **immediately**, then the rail follows |
| 3.15 | Step a line to 0 | the line is dropped from the destination, as today |

---

## 4. Editing a destination

| # | Do this | Expect |
|---|---|---|
| 4.1 | Record a destination, assign several lines to it | card shows `n líneas · m uds.` |
| 4.2 | Press the edit action in its header | the sheet opens — side sheet at 1440, bottom sheet at 380 — with the address, recipient, date and instructions already filled in, and "Guardar" as the confirm |
| 4.3 | Change the date, save | sheet closes; the card's subtitle shows the new date; **every assigned quantity is unchanged**; the rail is unchanged |
| 4.4 | Change the address to another of the customer's, save | the card's title shows the new address summary, with no visible refetch of the destination list |
| 4.5 | Open the sheet, press Cancel | nothing sent, nothing changed |
| 4.6 | Look at the store row | no edit action, no remove action |
| 4.7 | Confirm the delivery order elsewhere (or contrive a 409), then save an edit | the sheet stays open with the server's message; the card still shows its previous details |

---

## 5. The store row

| # | Do this | Expect |
|---|---|---|
| 5.1 | On a mixed sale with lines only partly assigned, expand the store row | every sale line listed, with the quantity staying at the store, zeros included |
| 5.2 | Sum the listed quantities | equals the units on the row's own header, and the store's share in the distribution rail |
| 5.3 | Assign more of one line to a delivery destination | the row's figure for that line drops by the same amount, without the row collapsing |
| 5.4 | Expand a destination card too | both stay open independently |
| 5.5 | Resume a sale that already has a recorded store-pickup destination | the row lists the same figures, drawn from the recorded destination |
| 5.6 | Assign everything to delivery destinations on a mixed sale | the row shows `0 líneas · 0 uds.` and lists every line at zero |

---

## 6. Live backend

The delivery edit is the one path worth exercising against a real server —
`PUT /api/v1/delivery-orders/{id}` has never been called by this client
before.

```bash
U=$(grep '^MBE_ADMIN_USERNAME=' .env | cut -d= -f2- | tr -d '"')
P=$(grep '^MBE_ADMIN_PASSWORD=' .env | cut -d= -f2- | tr -d '"')
flutter test test/integration/pos_counter_sale_flow_test.dart \
  --dart-define=MBE_POS_USERNAME="$U" --dart-define=MBE_POS_PASSWORD="$P" \
  --dart-define=MBE_POS_PRODUCT_PATTERN=clavo
```

`.env` defines no `MBE_POS_*` keys, so mapping the admin account across is
required; the default product pattern matches nothing sellable in the
register's warehouse, and the test **skips rather than fails** when it finds
fewer than two products — a silent skip usually means a bad pattern, not a
broken flow.

Check while you are there:

- a destination edited through the sheet keeps its lines in the server's own
  response (`GET /delivery-orders?sales_order=<id>`);
- the 409 in 4.7 is the message the sheet renders, verbatim, not a generic
  one;
- a burst on the capture stepper produces one `PUT`, not ten, in the server
  log.
