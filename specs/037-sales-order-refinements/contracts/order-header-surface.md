# Contract: Order Header Surface

**Feature**: 037-sales-order-refinements | Covers FR-001 – FR-005, FR-011 – FR-019, US1/US3/US4

Amends spec 032's `OrderHeaderPanel` contract (FR-002, FR-003, FR-004) and spec 023's
`contracts/capture-surface.md` §1 for the customer bar's terms control. Everything those specs said
that is not contradicted below still holds — in particular spec 032's disclosure behaviour, its
live-write rule, and its edit gating.

## C1 — Screen order

```
  [ error banner, if any ]
  [ CustomerBar        ]   ← identity first
  [ OrderHeaderPanel   ]   ← order metadata second
  [ product search / choose-a-customer hint ]
  [ lines … ]
```

The panel moves below the bar at **every** breakpoint (FR-011). Both keep the horizontal inset the
screen already supplies; neither gains a margin of its own.

## C2 — The header row

One row, in this order: **reference, status, date, due date, promise date, salesperson**, with the
disclosure control on the trailing edge. Balance is gone (FR-001); payment terms is gone (FR-003).

This merges what spec 032 kept as two bands — a read-only fact strip and a row of always-visible
fields — into one (FR-016b). It is only possible because FR-016's conversion removes the outlined
boxes that made the second band look like a form; the settled mock is the record of that decision.

Captions and values follow C5's single rule each. Spec 032's uppercase fact-strip captions and its
`timestamp` role on the order date are both superseded (FR-016d): monospace survives on the order
reference alone.

The screen's only balance is now the customer bar's — the customer's live outstanding balance, not
the order's stored one (FR-002). Spec 029's US4 scenario 3 ("the outstanding balance stays visible
without leaving the screen") is satisfied by that one.

## C3 — Collapsed state

The panel collapsed is exactly C2's row: no second band, nothing beneath it until the disclosure
opens.

## C4 — Disclosed group

Seven fields, in exactly this order (FR-012):

1. Priority
2. Currency
3. Exchange rate
4. Tax ID *(the recipient field — the label already reads this way)*
5. Delivery details *(the ship-to field — likewise)*
6. Contact
7. Comment — last, full width (FR-013)

Same seven fields as before, reordered. Nothing added, nothing removed.

The six non-comment fields sit on **one line at the large tier** (FR-016c) — roughly 187px per
column inside the grid's 1200px cap, which clears the longest value ("MXN — Peso Mexicano").
Narrower tiers keep the counts the grid already derives (2 at medium/expanded, 1 at compact), so
the six become three rows of two, then six rows of one.

`ResponsiveFormGrid.columnsForWidth` caps at three columns, and raising `maxColumns` alone cannot
exceed it (`columns = min(tierColumns, maxColumns)`). Six therefore needs a new **opt-in** input on
the shared grid — a large-tier column count this panel supplies and every other caller omits. A
caller that omits it MUST get exactly today's behaviour; this is the one change in this feature
that touches a component every form renders through, so it is additive by construction.

## C5 — Field presentation

Every control in the panel adopts the shared `CompactField` shape — a caption above the control,
optional supporting text beneath — **except the comment field**, which stays a `ConfirmableTextField`
because it is genuinely typed into and holds its own full-width row (FR-016, FR-016a).

This is not optional for the read-only values and picker launchers. A `ResponsiveFormGrid` run is as
tall as its tallest child, so one surviving outlined box pins its row and the panel gets no shorter
(research R5). Converting selections alone would satisfy the letter of the ask and deliver none of
its point.

**One caption rule, one value rule** (FR-016d). Every caption in the header stack — customer bar
and panel alike — is the same size, weight, colour and casing, and so is every value. No field
carries its own type treatment. The only value variations are data-type distinctions the app
already makes: monospace for the order reference, tabular figures for money.

**Editability is carried by a trailing affordance** (FR-016e), since a converted field has no box:
a downward arrow on a dropdown, a right chevron on a picker. The two date fields carry neither —
their formatted date-time fills the column at the compact tier and the affordance truncates it.

Rules the shape must obey:

- caption through `typeRoles.metricLabel`; no raw `labelSmall`, which bypasses the token system;
- **no fixed width** — fill the cell, `isExpanded: true` on dropdowns (research R7);
- padding and spacing from `core/design/spacing.dart` tokens only, never bare literals
  (constitution §VI);
- vertical padding symmetric; caption and control share a baseline relationship that holds at every
  text-size level (constitution §VI);
- height driven by content, so large text grows the row rather than clipping it (research R8).

`ResponsiveFormGrid` itself is unchanged and still the layout — constitution §VI requires the shared
grid for multi-field forms; this contract changes what sits in the cells, not the grid.

## C6 — Unchanged behaviour

Explicitly preserved from spec 032, and each is a regression risk worth asserting:

- edit gating per field: `canEdit` for all but priority, `canEditPriority` for priority (FR-017);
- every field writes through on change, with no Save step (FR-017);
- the disclosure opens closed on arrival, per visit, and changes visibility only;
- header-write errors render inside the card, outside the disclosed group, so a refusal from a field
  the user has since collapsed is still visible;
- no field or fact is dropped beyond balance and payment terms (FR-014).

## C7 — The customer bar's terms control

- Caption reads **"Payment terms" / "Forma de pago"** (FR-004), on both surfaces, using the existing
  `salesOrderPaymentTermsLabel` key relocated from the header panel. `posCustomerCreditLabel`
  retires.
- The credit-limit figure and the "no credit line" hint stay as supporting text (FR-005).
- The control keeps its key `pos_payment_terms_dropdown`, its enablement rule, and its width
  behaviour at compact widths — the caption is wider than "Crédito" was, and the bar's `Wrap` has
  overflowed at 390 px before (research R7).

## Verification

| Assertion | Where |
|---|---|
| No balance inside `OrderHeaderPanel`, either disclosure state | scoped by `find.descendant(of: find.byType(OrderHeaderPanel), …)` |
| No payment-terms field inside `OrderHeaderPanel` | same scoping — the string now legitimately appears in the customer bar, so an unscoped finder proves nothing |
| Customer bar renders the terms caption | scoped to `CustomerBar` |
| Disclosed fields appear in C4's order | by position, not merely presence |
| `CustomerBar` precedes `OrderHeaderPanel` | by vertical position on screen |
| Due date, promise date and salesperson sit on the header row, not a second band | same row as reference/status/date, collapsed |
| Six disclosed fields on one line at the large tier | one distinct vertical position for the six, comment strictly below |
| A caller that omits the new grid input gets today's column count | asserted against `ResponsiveFormGrid` directly, not through this panel |
| Panel is materially shorter than before | measured height against the real app theme, never a bare `MaterialApp` (research R4) |
| Symmetric padding and baselines | measured insets, per constitution §VI |
| No overflow at four text-size levels × compact and expanded | extends `sales_orders_compact_test.dart` |
