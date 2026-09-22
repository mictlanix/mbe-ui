# Wireframes: Sales Quotes — Cotizaciones

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-09-21 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive — every
dimension, colour and spacing resolves through the design tokens, per constitution §V.

> ⚠ **Drawn out of order.** This feature is already planned and tasked; these wireframes
> were produced after the fact as a review aid. The Open Questions below are therefore
> checks against `plan.md`/`tasks.md`, not inputs to them.

## Surface enumerated

| Screen | Route | States drawn |
|---|---|---|
| Quotes list | `/quotes` | populated, empty, loading, error, compact |
| Quote | `/quotes/new`, `/quotes/:id` | new, inline-customer, draft, draft-no-lines, confirmed, confirmed+expired, cancelled, refusal, legacy-generic-customer, compact |

---

## Screen: Quotes list (`/quotes`)

### State: populated

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ Cotizaciones                                                                     │
├──────────────────────────────────────────────────────────────────────────────────┤
│ [ Buscar folio o cliente……… ] [Estado ▾] [Cliente ▾]      [+ Nueva cotización]   │
├──────────┬────────────┬────────────┬──────────┬──────────────────┬───────────────┤
│ Folio    │ Fecha      │ Cliente    │ Vence    │ Estado           │         Total │
├──────────┼────────────┼────────────┼──────────┼──────────────────┼───────────────┤
│ COT-0412 │ 2026-09-20 │ Aceros MX  │ 2026-10- │ (Confirmada)     │     $12,480.00│
│ COT-0411 │ 2026-09-19 │ Juan Pérez │ 2026-09- │ (Confirmada)(Ven…│      $3,200.00│
│ COT-0410 │ 2026-09-19 │ Ferre Sur  │ 2026-10- │ (Borrador)       │        $980.00│
│ COT-0409 │ 2026-09-18 │ Aceros MX  │ 2026-09- │ (Cancelada)      │      $7,150.00│
├──────────┴────────────┴────────────┴──────────┴──────────────────┴───────────────┤
│                                          ‹ 1 2 3 ›   25 por página ▾   61 result.│
└──────────────────────────────────────────────────────────────────────────────────┘
```

- **Filter row** — `CatalogFilterBar` wrapping `CatalogSearchBar` (one box, FR-036: the
  server routes a numeric term to the reference and a non-numeric one to the customer
  name), a status facet, and a customer facet (`CatalogEntityPicker`). The new-quote
  action sits in the bar's `actions:` list, as `sales_orders_list_screen.dart:153` places
  its own.
- **Table** — `DataTableView<SalesQuote>`, six columns mirroring the orders list's budget
  (that list runs reference / date / customer / status / total / balance).
- **Estado column** — `StatusChip` for the status, plus a **second** chip for expiry.
  FR-024/FR-037 require expired to read distinctly from status, and a confirmed quote can
  be expired at the same time, so the two cannot share one chip. See Open Question 4.
- **Pagination** — `CatalogPagination` (FR-038).
- Rows are not scoped to the signed-in user (FR-034), and are most-recent-first (US3 §1).

### State: empty / loading / error

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ [ Buscar folio o cliente……… ] [Estado ▾] [Cliente ▾]      [+ Nueva cotización]   │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│                          Sin cotizaciones que mostrar                            │
│                       (+ Nueva cotización)                                       │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘

 loading →  filter row stays, table area becomes the shared skeleton/spinner
 error   →  filter row stays, ErrorBanner above the table area, retry offered
```

- All three from `ListStateViews`; the filter row never disappears, so a filter that
  matched nothing can be widened without a reload.
- `ErrorBanner` for the error state.

### Compact tier

```
┌────────────────────────────────┐
│ Cotizaciones            [ + ]  │
│ [ Buscar…………………… ]  [Filtros]  │
├────────────────────────────────┤
│ COT-0412        $12,480.00     │
│ Aceros MX                      │
│ 2026-09-20  (Confirmada)       │
├────────────────────────────────┤
│ COT-0411         $3,200.00     │
│ Juan Pérez                     │
│ 2026-09-19  (Confirmada)(Venc) │
└────────────────────────────────┘
```

- Facets collapse into `CatalogFilterSheet` behind one **Filtros** button; the new-quote
  action collapses to an icon (`CatalogActionIcons`).
- The table becomes stacked rows. **Dropped: the Vence column** — expiry survives only as
  the expired chip, because the date itself is not actionable on a phone and the folio,
  customer, total and status are what identify a row. See Open Question 9.

---

## Screen: Quote (`/quotes/new`, `/quotes/:id`)

One screen, one step (FR-005, and the 2026-09-20 amendment). It is the shared capture
surface — `CaptureStep` — hosted a third time, alongside the register and the back-office
order workspace (FR-012).

### State: new — customer band searching, capture withheld

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ ‹ Nueva cotización                                                               │
├──────────────────────────────────────────────────────────────────────────────────┤
│ CLIENTE                                                                          │
│ [ Buscar cliente por nombre o código……………………………… ]        [+ Nuevo cliente]      │
│   Aceros del Norte SA          ACE-001                                           │
│   Aceros MX                    ACE-014                                           │
│   Agroinsumos Bajío            AGR-003                                           │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│            Elija un cliente para comenzar la cotización                          │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

- `CustomerBar` with `startInSearchMode: true` (FR-005). The parameter already exists on
  `CaptureStep`.
- **"Público en General" never appears in these results** (FR-007, US1 §2) — the existing
  `excludeGenericCustomer` flag.
- Product search, line list and totals bar are **absent, not disabled** — capture is
  withheld until a customer exists.
- **Nothing has been written to the server at this point** (FR-006). The draft is created
  on customer selection (FR-009), not on screen open.

### State: inline customer creation

```
┌──────────────────────────────────────────────────────────┬───────────────────────┐
│ CLIENTE                                                  │ Nuevo cliente      [×]│
│ [ Buscar cliente………………………………………… ]     [+ Nuevo cliente] │                       │
│                                                          │ Nombre    [……………]     │
│                                                          │ RFC       [……………]     │
│            Elija un cliente para comenzar                │ Correo    [……………]     │
│                                                          │ Teléfono  [……………]     │
│                                                          │ …                     │
│                                                          │                       │
│                                                          │   [Cancelar] [Guardar]│
└──────────────────────────────────────────────────────────┴───────────────────────┘
```

- `AppSideSheet` (or `RecordSheet`) over the quote screen — the user never leaves it
  (FR-010, SC-002).
- On save: customer created → draft quote opened carrying it → capture becomes available,
  all without a navigation (US4 §1).
- On cancel: no customer, no quote, screen unchanged (FR-011, US4 §2).
- On server refusal: `ErrorBanner` inside the sheet, typed values kept, no quote opened
  (US4 §3).

### State: draft with lines — the main working state

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ ‹ COT-BORRADOR-0007                                            (Borrador)        │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Aceros MX  ACE-014                       Crédito 30 días            [Cambiar]    │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Vence 2026-10-20   Moneda MXN            Comentario …………………………      [ ⌄ ]        │
├──────────────────────────────────────────────────────────────────────────────────┤
│ [ Buscar producto por código o nombre……………………………………… ]         [Búsqueda avanz.] │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Producto                        │ Cantidad │  Precio │ Desc. │  IVA │     Importe│
│ TUB-034 Tubo galv. 2" x 6m      │ [  12 pz]│  480.00 │[ 0 %] │[16 %]│    5,760.00│
│ SOL-112 Soldadura 6013 1/8      │ [   4 kg]│  212.00 │[ 5 %] │[16 %]│      805.60│
│ [+]                                                                              │
├──────────────────────────────────────────────────────────────────────────────────┤
│  Subtotal 6,565.60   IVA 1,050.50                      Total  $7,616.10          │
│  [Cancelar cotización] [Duplicar]                        [ Confirmar cotización ]│
└──────────────────────────────────────────────────────────────────────────────────┘
```

- **Header strip** — `CustomerBar` (attached state) plus a disclosed group for expiry,
  currency and comment (FR-020), through `CaptureStep`'s existing `headerExtra` slot. The
  progressive-disclosure pattern is `OrderHeaderPanel`'s, from spec 032. See Open
  Question 3.
- **Product search** — `ProductSearchField`, unchanged from the other two hosts (FR-013).
- **Lines** — `SaleLineRow`. **No warehouse column** (FR-014) and **no stock or shortfall
  warning** (FR-015). `sale_line_layout.dart` budgets warehouse at 168px floor / 240px
  comfortable; removing it returns that width to the row. See Open Question 5.
- **Totals** — `SaleTotalsBar`, values as the server reports them, never recomputed
  locally (FR-017).
- **Forward action confirms** rather than advancing (FR-018) — `CaptureStep`'s
  `onContinue` with a `continueLabel` of "Confirmar cotización".
- **No fulfilment selector** (FR-016) — `showFulfillmentSelector: false`.
- Confirm is unavailable while a write is outstanding or an edit unconfirmed (FR-019).
- Reference reads as provisional, not a folio (FR-022, US1 §8).

### State: draft with no lines

```
│ [ Buscar producto………………………………………………………………………………………………………… ]                    │
├──────────────────────────────────────────────────────────────────────────────────┤
│                        Agregue productos a la cotización                         │
├──────────────────────────────────────────────────────────────────────────────────┤
│  Subtotal 0.00   IVA 0.00                              Total      $0.00          │
│  [Cancelar cotización] [Duplicar]                        [ Confirmar cotización ]│
│                                                             ^ unavailable        │
```

- A legitimate persisted state: a customer was chosen and nothing added (Edge Cases).
- Confirm is present but unavailable (FR-018, US1 §7). Cancel remains available (FR-032).

### State: confirmed (read-only)

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ ‹ COT-0412                                                     (Confirmada)      │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Aceros MX  ACE-014                       Crédito 30 días                         │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Vence 2026-10-20   Moneda MXN            Comentario …………………………      [ ⌄ ]        │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Producto                        │ Cantidad │  Precio │ Desc. │  IVA │     Importe│
│ TUB-034 Tubo galv. 2" x 6m      │    12 pz │  480.00 │   0 % │ 16 % │    5,760.00│
│ SOL-112 Soldadura 6013 1/8      │     4 kg │  212.00 │   5 % │ 16 % │      805.60│
├──────────────────────────────────────────────────────────────────────────────────┤
│  Subtotal 6,565.60   IVA 1,050.50                      Total  $7,616.10          │
│  [Cancelar cotización] [Duplicar]                             [ Convertir a pedido ]│
└──────────────────────────────────────────────────────────────────────────────────┘
```

- Folio replaces the provisional reference; the whole document is read-only (FR-021,
  FR-023). Product search and the `[+]` row are **gone**, not disabled. Line fields lose
  their input affordance.
- **Convert** replaces Confirm as the forward action (FR-025). It is **absent** for a user
  without order-create permission (FR-004, US2 §7) — hidden, not disabled, per the house
  pattern.
- Convert is not one-time; converting twice raises a second independent order (FR-031,
  US2 §8), so nothing here presents it as spent.

### State: confirmed **and** expired

```
│ ‹ COT-0411                                        (Confirmada) (Vencida)         │
…
│  [Cancelar cotización] [Duplicar]                                                │
│                                          ^ Convert withdrawn — expired (FR-025)  │
```

- Two chips, not one (FR-024). Convert is gone because FR-025 offers it only for a
  **confirmed, unexpired** quote; Duplicate is the sanctioned way forward (FR-029, US5 §2).
- A quote can cross into this state while open on screen (Edge Cases) — expiry is the due
  date passing, not an action.

### State: cancelled

```
│ ‹ COT-0409                                                     (Cancelada)       │
…
│                                                              [Duplicar]          │
```

- No editing, no confirm, no convert (FR-032) — the forward action is withdrawn entirely
  via `SaleTotalsBar`'s existing `showAction: false`. Cancel is not offered again (US3 §8).
- Duplicate survives — FR-033 allows **any** quote to be duplicated.

### State: conversion refused

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ ⚠  <reason, in the user's language>                        [Duplicar]   [×]      │
├──────────────────────────────────────────────────────────────────────────────────┤
│  …quote below, unchanged…                                                        │
```

Four distinct refusals, each actionable (FR-028, SC-004):

| Cause | Message conveys | Recovery offered |
|---|---|---|
| Quote is a draft | must be confirmed first | — (Confirm is on screen) |
| Quote is cancelled | a cancelled quote cannot convert | — |
| Quote is expired | **names expiry** (FR-029) | **Duplicar** |
| User has no point of sale | says so plainly, not a generic failure (FR-030) | — |

- `ErrorBanner` above the document; the quote itself is left unchanged (FR-028).
- The same banner carries the stale-screen refusals from Edge Cases (editing a confirmed
  or cancelled quote), after which the screen is re-read from the server.

### State: legacy quote on the generic customer

```
│ Público en General                       Contado                                 │
│                                          ^ no [Cambiar] — read-only              │
```

- Created before this screen existed, or by another client (Edge Cases). It must read and
  cancel without crashing, even though this screen would never produce one. The customer
  band shows it but offers no way to keep it.

### Compact tier

```
┌────────────────────────────────┐
│ ‹ COT-BORRADOR-0007    (Borr.) │
├────────────────────────────────┤
│ Aceros MX            [Cambiar] │
│ Crédito 30 días                │
│ Vence 2026-10-20        [ ⌄ ]  │
├────────────────────────────────┤
│ [ Buscar producto…………………… ]    │
├────────────────────────────────┤
│ TUB-034 Tubo galv. 2" x 6m     │
│ 12 pz × 480.00                 │
│ Desc 0%  IVA 16%      5,760.00 │
├────────────────────────────────┤
│ SOL-112 Soldadura 6013 1/8     │
│ 4 kg × 212.00                  │
│ Desc 5%  IVA 16%        805.60 │
├────────────────────────────────┤
│ Total            $7,616.10     │
│ [ Confirmar cotización ]       │
│ [ ⋯ ]                          │
└────────────────────────────────┘
```

- Lines switch from `SaleLineRow` to `SaleLineCard`, which `sale_line_layout.dart` already
  substitutes below its width threshold — and the card has no warehouse control to
  suppress, so FR-014 costs nothing here.
- Header fields stack; the disclosure group carries currency and comment.
- **Secondary actions collapse into an overflow** — Cancel and Duplicate do not fit
  alongside the forward action at this width. See Open Question 2.

---

## Open Questions

1. **Where does the quote screen's app bar come from, and does it carry the folio?**
   Spec 032 found that dropping identity out of the header was a regression, and added
   Reference and Status to the fact strip for exactly that reason. The spec here says a
   quote must show a provisional reference (FR-022) and a folio once confirmed (FR-021)
   but never says where. *Wireframe assumed: app bar carries reference/folio, with the
   status chip beside it.*

2. **Three secondary actions, one slot.** Confirm/Convert take the forward action
   (FR-018, FR-025), but Cancel (FR-032), Duplicate (FR-033) and — on a refusal — a
   recovery Duplicate (FR-029) all need somewhere to live. `SaleTotalsBar` gained exactly
   **one** `secondaryAction` slot in spec 032. Options: widen it to a list; put Cancel and
   Duplicate in an app-bar overflow; a bespoke action row (violates §V). *Wireframe
   assumed: two inline secondary actions in the totals bar at regular width, overflow at
   compact — which the current single-slot signature does not support.*

3. **Is `OrderHeaderPanel` reusable for a quote, or does a quote need its own?** FR-020
   requires customer, terms, expiry, currency and comment, with a progressive disclosure
   exactly like spec 032's. But the order panel is built around order fields (promise
   date, priority, exchange rate). *Wireframe assumed: a quote-specific panel in
   `headerExtra`, mirroring the pattern rather than reusing the widget.*

4. **Two chips, or one composite marker?** FR-024/FR-037 require expired to read
   distinctly from status, and confirmed-and-expired is a real combination. *Wireframe
   assumed: two adjacent `StatusChip`s.* The alternative — one chip whose label composes
   both — is fewer pixels but loses the "distinctly" the requirement asks for.

5. **Where does the freed warehouse width go?** `sale_line_layout.dart` budgets warehouse
   at 168px floor / 240px comfortable. Removing it (FR-014) frees that width, and the
   layout interpolates between two fixed column sets, so this is a real decision rather
   than a reflow. *Wireframe assumed: the product name column absorbs it.* The alternative
   is a narrower row, which changes where the `SaleLineCard` substitution threshold should
   sit.

6. **Which header fields does the server actually accept on a draft?** FR-020 says the
   quote must "allow editing those the server accepts" — which defers the question rather
   than answering it. Expiry date in particular is the one a salesperson would most want
   to change. *Wireframe assumed: expiry, currency and comment are editable while draft;
   payment terms follow the customer and are not.*

7. **Does the empty list offer the new-quote action?** FR-038 and the list requirements
   are silent on empty. *Wireframe assumed: yes, and the filter row stays put so a
   filter that matched nothing can be widened without a reload.*

8. **Is the customer facet a picker or a free-text match?** FR-036 requires filtering by
   customer *and* searching by customer name — two overlapping affordances.
   *Wireframe assumed: a `CatalogEntityPicker` facet for exact customer, and the search
   box for name substrings, per the server's numeric/non-numeric routing.*

9. **Which list column does the compact tier drop?** Six columns (folio, fecha, cliente,
   vence, estado, total) plus an expiry chip do not fit a phone. *Wireframe assumed:
   Vence is dropped and expiry survives only as the chip.*

10. **Does a converted quote show that it was converted?** FR-026 records the origin on
    the *order*, and FR-031 says conversion is not one-time — but nothing says whether the
    quote displays its resulting order(s). *Wireframe assumed: it does not.* Worth
    confirming, since a salesperson converting twice by accident is the obvious failure
    mode of FR-031.
