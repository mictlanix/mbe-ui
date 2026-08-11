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
| ≥ 970 px | single row | `saleLineLayoutFor` |
| 600–970 px | two rows | `saleLineLayoutFor` |
| < 600 px | `SaleLineCard`, unchanged | the caller, as today |

### 4.2 The single row

```
[40 img] Product name, up to     [warehouse ▾ 168] [− Cant. (Pza) +] [precio 88] [desc 80] [imp 80]  [total 100] [🗑]
         two lines               132
         CODE (secondary)
```

Band height `saleLineRowHeight` = 56 (the mock's own row height); every
editable control in it is `saleLineFieldHeight` = 48 tall and shares one
vertical centre (FR-038a).

| Column | Width | Content |
|---|---|---|
| Thumbnail | 40 | `ProductPhoto(photoUrl: null, size: 40)` — reserved slot, placeholder until mbe-api exposes `photo` (research R11); lives inside the product column |
| Product | flex, min 226 | name in the body role over **two reserved lines**, ellipsized; code beneath in the smaller secondary role — **not** `'code — name'` in one string. Both lines are reserved whether the name needs them or not, so rows do not jump height (FR-040) |
| Warehouse | 168 | existing `warehousePicker()`, with the availability figure kept visible |
| Quantity | 132 | −/field/+ stepper, labelled `posLineQuantityWithUnitLabel` (`Cant. (Pza)`) when the product has a unit, `posLineQuantityLabel` (`Cant.`) when it does not |
| Price | 88 | editable — see 4.2a |
| Discount | 80 | editable, percent |
| Tax | 80 | editable, percent |
| Total | 100 | right-aligned in `typeRoles.money`, never truncated |
| Delete | unconstrained | existing icon, Material's own default sizing |

Gaps are `spacing.xs` (8), 6 of them (no gap before the trailing delete icon).
**These are budgets, not measurements** — the FR-037a widget test pumps a real
line at a 1024-px surface and asserts no overflow. It caught exactly this: the
quantity column's first budget (104 px, two `IconButton`s explicitly constrained
to 28 px each plus a 36-px field) overflowed by 12 px in practice — `IconButton`'s
own sizing did not shrink as far as the `constraints`/`padding` overrides implied
— and was widened, rather than fighting the framework further.

The columns above are the mock's own grid (`minmax(300px,1fr) 176px 128px 96px
100px 88px 84px 124px 44px`), trimmed to fit 1024 px. What paid for widening
them is the **unit's own column**, folded into the quantity field's label: a
unit is one short symbol, and a column of its own had already cost 56 px after
growing 36 → 56 to stop `Cubeta` wrapping and taking the whole row taller. The
compact tier reached the same conclusion independently — `SaleLineCard` carries
the unit as the quantity field's `suffixText`.

### 4.2a Price stays editable

The mock renders `Precio` as plain read-only text while `Desc.` and `IVA` carry
field chrome. The API disagrees, and the API wins: `SalesOrderLineCreate` and
`SalesOrderLineUpdate` both accept `price` (`Decimal | None, ge=0`), and
mbe-api validates a supplied price against the product's profit-margin band
(`price_validation_in_range_required`) rather than ignoring it — a deliberate,
guarded override, not an accident. Spec 020 FR-023 and this spec's FR-023 both
make it editable, so the mock's read-only price is read as presentation, on the
same footing as its dark palette.

### 4.3 The two-row fallback

Row 1: thumbnail, product, warehouse, total, delete.
Row 2: quantity stepper (unit in its label, as above), price, discount, tax.
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
