# Contract: the capture surface (Venta step)

Refines `specs/020-point-of-sale/contracts/pos-screen.md` §3's Venta step. The
visual reference is `artifacts/point_of_sale/POS_Adaptativo.dc.html` frame `2a`
(expanded) and the first frame of `2e` (compact); its palette is a presentation,
not a requirement — every colour, inset, radius and size resolves through
`Theme.of(context)` and the spec 022 tokens.

Composition, top to bottom, at ≥ 600 px:

```
[ CustomerBar ..................... | FulfillmentModeSelector ]   ← one row
[ ProductSearchField ......................................... ]
[ SaleLineRow × n  (Expanded — absorbs all remaining height) .. ]
[ SaleTotalsBar + primary action ............................. ]   ← one band
```

Below 600 px the order is unchanged but everything scrolls as one `ListView`,
with the footer pinned (spec 020 FR-053, unchanged).

---

## 1. `CustomerBar` — two faces, one card

### 1.1 The `facts` face (default)

```
[icon] Cliente              │ Crédito ▾      Lista        Saldo    │ [Buscar] [Nuevo]
       PÚBLICO EN GENERAL   │ Contado        Mostrador    $0.00    │
```

| Element | Content | Notes |
|---|---|---|
| Customer name | `customerRecord.name ?? sale.customerName ?? placeholder` | Fixes the blank field: the picker used to seed from `sale.customerName`, which is null for the walk-in customer while the facts row knew the name (research R8) |
| Payment terms | `DropdownButtonFormField<PaymentTerms>`, key `pos_payment_terms_dropdown` | Replaces the `SegmentedButton`; occupies the slot the credit figure had, with the credit line as its supporting text (§1.3) |
| Price list | `customer.priceList.name` | unchanged |
| Balance | `customerOutstandingBalanceProvider` | unchanged, still independently loading/failing |
| Buscar | `OutlinedButton.icon`, key `pos_customer_search_button` | → `searching` face |
| Nuevo | existing `IconButton`, key `pos_create_customer_button` | unchanged; hidden without `customers` create |

The whole facts group keeps key `pos_customer_facts`.

### 1.2 The `searching` face

Entered by Buscar, left by the picker's cancel affordance or Escape.

- `CatalogEntityPicker<CustomerListItem>` (key `pos_customer_picker`), autofocused,
  seeded with the resolved display name.
- Transition: `AnimatedSwitcher` (fade) wrapping an `AnimatedSize`, both with the
  theme's motion duration — stock Material 3, no package.
- Progress: the picker's own in-flight indicator while candidates load; the band
  disables and shows a spinner while `updateHeader` runs (today's `_busy` flag).
- On success the band returns to `facts` showing the new customer, with every line
  re-priced exactly as the server returned it (spec 020 FR-015 — nothing new).
- On dismissal the band returns to `facts` and **nothing about the sale changes**.

### 1.3 Payment terms rules

| Condition | Dropdown |
|---|---|
| Value | always `sale.paymentTerms` |
| `Crédito` (`PaymentTerms.netD`) | selectable only when `!isZeroAmount(customer.creditLimit)` |
| No credit line | `Crédito` disabled, `posCustomerNoCreditHint` as helper text |
| Sale not editable | whole control disabled |
| On change | `updateHeader(paymentTerms: …)` — the existing call |

**The screen never writes `paymentTerms` anywhere else.** Whatever mbe-api sets
when a customer is attached is what the control displays (FR-030). This makes the
question of whether the backend auto-switches terms irrelevant to the UI.

### 1.4 Insets

`Card` keeps `spacing.cardPadding` internally. The step does **not** wrap it in a
second `EdgeInsets.all(12)` — that doubling is the odd narrowing visible in the
screenshot. Horizontal insets for the whole step come from `spacing.screenMargin`,
applied once, at the step root.

## 2. `FulfillmentModeSelector` — beside, not below

| Width | Placement |
|---|---|
| ≥ `LayoutBreakpoints.expanded` (840) | same `Row` as `CustomerBar`, `flex: none`, right of it |
| < 840 | below `CustomerBar`, full width (today's placement) |

Behaviour is untouched: the delivery-permission refusal (`pos_delivery_refusal`),
the mandatory delivery-address pick, and the `shipTo` write all stay exactly as
spec 020 built them. Only the placement changes, and the refusal/error strips
render under the pair rather than under the selector alone so the row does not
jump height when one appears.

## 3. `ProductSearchField` — options while typing, scanner intact

| Path | Trigger | Behaviour |
|---|---|---|
| Type | `onChanged`, 300 ms debounce | look up; **offer** results; never auto-add |
| Scan / Enter | `onSubmitted` | cancel any pending debounce, look up immediately; **a single exact match is added directly**, the field clears and keeps focus |
| Stale result | a lookup whose request number is not the latest | dropped |
| Escape | with results showing | dismiss the list, keep the typed text |
| Empty result | search settled with nothing | `posProductSearchNoResults` |

Rule 1's "never auto-add" is the crux: today's single-match auto-add is what makes
scanning work, and moving it to the typing path would silently add a line
mid-word. Rule 3 is new — searching only on submit, the shipped field could not
have the race.

`productLookupControllerProvider` is reused as-is: an autodispose family keyed by
`(pattern, warehouse)`, which its own docstring describes as "each keystroke's
request is its own short-lived provider". Debounce interval matches
`CatalogEntityPicker`'s 300 ms so the two pickers feel the same.

## 4. `SaleLineRow` — one row, with a budget

### 4.1 Layout selection

Driven by `LayoutBuilder` on the row's **own available width**, never
`MediaQuery` (the row must answer for its container, not the window):

| Available width | Layout | Chosen by |
|---|---|---|
| ≥ 950 px | single row | `saleLineLayoutFor` |
| 600–950 px | two rows | `saleLineLayoutFor` |
| < 600 px | `SaleLineCard`, unchanged | the caller, as today |

### 4.2 The single row

```
[36 img] Product name           [warehouse ▾ 140] [− 128 +] unit [price 84] [desc 68] [iva 68]  [total 96] [🗑]
         CODE (secondary)        stock badge
```

| Column | Width | Content |
|---|---|---|
| Thumbnail | 36 | `ProductPhoto(photoUrl: null, size: 36)` — reserved slot, placeholder until mbe-api exposes `photo` (research R11) |
| Product | flex, min 200 | name in the body role; code beneath in the smaller secondary role — **not** `'code — name'` in one string |
| Warehouse | 140 | existing `warehousePicker()`, with the availability figure kept visible |
| Quantity | 128 | −/field/+ stepper, with its own `posLineQuantityLabel` — widened from an initially tighter 104 during implementation (see below) |
| Unit | 36 | `line.unit`, omitted (not placeholdered) when the product has none |
| Price | 84 | editable |
| Discount | 68 | editable, percent |
| Tax | 68 | editable, percent |
| Total | 96 | right-aligned, never truncated |
| Delete | unconstrained | existing icon, Material's own default sizing |

Gaps are `spacing.xs` (8), 7 of them (no gap before the trailing delete icon).
**These are budgets, not measurements** — the FR-037a widget test pumps a real
line at a 1024-px surface and asserts no overflow. It caught exactly this: the
quantity column's first budget (104 px, two `IconButton`s explicitly constrained
to 28 px each plus a 36-px field) overflowed by 12 px in practice — `IconButton`'s
own sizing did not shrink as far as the `constraints`/`padding` overrides implied
— and was widened to 128 px, matching the mock's own original column width,
rather than fighting the framework further.

### 4.3 The two-row fallback

Row 1: thumbnail, product, warehouse, total, delete.
Row 2: quantity stepper, unit, price, discount, tax.
Nothing is dropped and nothing is read-only that was editable.

### 4.4 Unchanged behaviour

Everything comes from the `SaleLineEditing` mixin as it does today: per-field
server round trips, refusal-restores-fields, the stepper's floor at > 0, and the
non-blocking shortfall strip with its "adjust to available" action, which renders
under the row in both layouts. Row key becomes `sale_line_row_<id>` to match the
card's existing convention.

## 5. `SaleTotalsBar` — the footer band

```
ARTÍCULOS        SUBTOTAL      DESCUENTOS     IVA                    TOTAL MXN
9 líneas · 409 u $25,609.00    −$369.00       $4,038.40           $29,278.40  [Continuar al cobro →]
```

| Element | Type role | Notes |
|---|---|---|
| Group labels | the smallest label role, letter-spaced, uppercase | Artículos, Subtotal, Descuentos, IVA |
| Group figures | body role | discounts group omitted entirely when zero (today's behaviour) |
| Total label + figure | label role + the largest display/headline role available in the token scale, right-aligned, with the currency stated | the visually dominant element |
| Primary action | `FilledButton`, key `pos_continue_to_payment` | **moves into this band**; disabled when `lineCount == 0`, mid-confirm, or the sale is not editable; full-width on compact |

Every figure still comes from `Sale` as returned — the discount is
`(subtotal + tax) − total` through `addAmounts`/`subtractAmounts`, unchanged
(FR-047). Band key `pos_totals_footer`. No literal font size or colour: the
mock's 32 px total maps to the nearest token type role, not to `fontSize: 32`.

## 6. Accessibility

- Touch targets at compact stay ≥ the density token's minimum; the tightened
  desktop column widths apply to the expanded/large tiers only, where a pointer
  is the input.
- Every new control is keyboard reachable: Buscar, the terms dropdown, and the
  product candidate list are all focusable and operable without a pointer, and
  Escape dismisses both overlays.
- Contrast comes from the theme; nothing introduces a colour of its own.
