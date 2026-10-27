# Research: Payments List and Search

**Spec**: [spec.md](./spec.md) | **Date**: 2026-10-27

All server facts below were read from mbe-api `main` at 6ee7d97 (2026-10-27). UI facts come from this repository at `efde149`.

## R1 — Data access: extend `CustomerPaymentRepository`, no regeneration

**Decision**: Add four methods to the existing `CustomerPaymentRepository` (`lib/features/sales/domain/repositories/customer_payment_repository.dart`) and its impl. Each one wraps a generated operation that already exists:

| New method | Generated operation | Gate (server) |
|---|---|---|
| `list({customer, cashSession, facility, dateFrom, dateTo, method, verified, skip, limit})` | `listCustomerPaymentsApiV1CustomerPaymentsGet` | CustomerPayments (8) read |
| `searchAcrossFacilities({customer, reference, dateFrom, dateTo, skip, limit})` | `searchPaymentsAcrossFacilitiesApiV1CustomerPaymentsSearchGet` | PaymentsEditor (100) read |
| `get({customerPaymentId})` | `getCustomerPaymentApiV1CustomerPaymentsCustomerPaymentIdGet` | CustomerPayments (8) read |
| `listApplications({customerPaymentId})` | `listPaymentApplicationsApiV1CustomerPaymentsCustomerPaymentIdApplicationsGet` | CustomerPayments (8) read |

**Rationale**: The repository already owns this API client (create, apply and reverse), so adding a second repository for the same resource would split it for no reason.

- The generated client already has all four operations and both models (`CustomerPaymentResponse`, `ApplicationResponse`). No codegen is needed until mbe-api#270 ships (R2).
- Date edges go through the same `wireDate` / `wireDateEnd` handling as the sales-orders repository (spec 043), so a range is inclusive in wall-clock time.

**Alternatives rejected**:
- **A new `PaymentQueryRepository`:** it would duplicate the client and error mapping.
- **Reusing `SalePayment`:** that entity models an *order application seen from the order* (`OrderApplicationResponse`), not a payment. Stretching it to cover both would blur two meanings.

## R2 — Customer names: per-id display-name provider, until mbe-api#270

**Decision**: Add `customerDisplayNameProvider`, a `FutureProvider.family<String?, int>` in `customer_repository_impl.dart`, mirroring `employeeDisplayNameProvider` and its siblings. It calls `CustomerRepository.get` and returns `null` on any error. The customer cell watches it per row.

**Rationale**:
- A Riverpod family dedupes by id, so a page of 50 rows from one customer makes one request. That satisfies the "Many rows for the same customer" edge case without hand-written batching.
- Every other id-to-name lookup in the app already works this way.

**When #270 ships**: regenerate the client, add `customerDisplayName` to the `CustomerPayment` entity, and have the cell prefer it, falling back to the provider only when it is null (FR-018). This is a follow-up task, deliberately not part of this delivery's tasks, because the field does not exist yet and cannot be referenced.

**Alternatives rejected**:
- **Batch lookup:** mbe-api has no customers-by-ids endpoint.
- **Listing customers and filtering:** this can't be bounded.

## R3 — The other names: verifier, applier, payment option, facility

**Decision**:

| Name | Source |
|---|---|
| Verifier and applier (employee ids) | `employeeDisplayNameProvider` |
| Facility (cross-facility mode, detail) | `facilityDisplayNameProvider` |
| Payment option (`payment_charge`) | New `paymentMethodOptionNameProvider` family in `payment_method_option_repository_impl.dart`, same pattern |

Every one of these falls back to the raw number when it resolves to `null` (Edge Cases: removed payment option, unknown verifier or applier).

**Rationale**: these are the existing patterns. The only new piece is the payment-option name family.

## R4 — Facility scoping and the unchecked detail endpoint

**Findings**:
1. `GET /customer-payments` honours any `facility` from any reader. This is the same gap as the sales-orders one in project memory.
2. `GET /customer-payments/{id}` and `/{id}/applications` do **not** check facility at all. Any CustomerPayments reader can fetch any payment by id.

**Decision**:
- **List:** the facility-scoped mode always sends the user's own facility (`userFacilityIdProvider`) explicitly and offers no facility facet (FR-009).
- **Detail guard (client-side):** after loading a payment, if `payment.facility != userFacilityId` and the user can't read PaymentsEditor (100), the screen shows the **not-found** state and does not load the applications. This is what makes SC-004 ("including direct links") hold in the UI.
- **Server gap:** this guard is the only protection, the same as for sales orders. Filing an mbe-api issue for a facility check on `GET /customer-payments/{id}` is recommended but not done: it is an outward-facing action left to the user.

**Alternatives rejected**: showing a "forbidden" state instead of not-found would confirm that the id exists in another facility.

## R5 — Two modes in one route, kept in the URL

**Decision**:
- **Route:** one shell route, `/sales/payments`.
- **Mode:** a `scope` facet, absent for this facility and `all` for every facility.
- **Reference search:** `ListQuery.search` carries the reference text. It is read only when `scope=all`.
- **Facets:** `customer`, `date-from` / `date-to` (`yyyy-MM-dd`, as in sales orders), `method`, `verified` (`true` / `false`; absent means any) and `cash-session`.
- **Mode switch:** switching mode navigates to a fresh `ListQuery` that keeps only `customer`, `date-from` and `date-to`. The method, verified and cash-session facets are dropped going to `all`, and the search is dropped going back (FR-012).
- **Bypassing the switch:** if `scope=all` reaches a user without PaymentsEditor read (a hand-typed URL), the filter parses it as the facility mode. It is never honoured.

**Rationale**:
- Wireframe Open Questions 1 and 2 assumed this. Back from a payment returns to the same mode, page and filters.
- It uses the existing `ListQuery` and `CatalogFilterBar` slots: the mode segmented button goes in `actions:`, and `CatalogSearchBar` goes in `search:` in `all` mode only.

**Alternatives rejected**:
- **Two routes:** two nav entries for one concept.
- **Scope as a drawer facet:** it changes which facets exist (FR-012).

## R6 — No default date range

**Decision**: when no date facet is set, the list shows every payment, newest first. Unlike Pedidos, there is no default "this month" range.

**Rationale**: Story 1, scenario 8 says clearing the filters returns "the unfiltered facility list". The server's newest-first order already puts recent payments on page 1, so a default range would add a filter the user didn't choose.

## R7 — Cash-session picker (FR-006a)

**Facts**:
- `GET /cash-sessions` accepts `facility` but has **no search parameter**. `GET /cash-sessions/{id}` exists.
- Both are gated by POS (44) read, not CustomerPayments.
- `CashSessionRepository.list` doesn't expose `facility` today.

**Decision**:
- Add an optional `facilityId` to `CashSessionRepository.list` and its impl. The generated operation already accepts it.
- The picker is a `CatalogEntityPicker<CashSession>`, and `optionsBuilder` behaves as follows:
  - **Text is all digits:** `get(cashSessionId)`. Show the session only if its facility is the user's. On a 404 or a mismatch, show no options.
  - **Otherwise:** `list(facilityId: userFacility, limit: 20)`, newest first (server default `-id`), so an empty query shows the latest sessions.
- Label: `#<id> · <cashierName> · <fmt.display.date(start)>`.
- The facet is **hidden** for users without POS read. The server would refuse their lookups anyway, and deny-by-default (§IV) hides rather than disables.
- The facet's selected label resolves through a new `cashSessionLabelProvider(id)` family, so a reloaded URL shows the label rather than a bare number.

**Facility check (verified)**: a `cash_session` row has no facility column. The response embeds `cash_drawer: CashDrawerSummary`, which carries `facility: int`. The server's own facility filter goes through the drawer (`cash_session_service.py:527`). So the UI `CashSession` entity gains `cashDrawerFacilityId`, mapped from that summary, and the digit lookup compares it with the user's facility.

## R8 — Order links by origin (FR-015)

**Facts**:
- An application carries only the `sales_order` id. Origin (`SaleOrigin`) is on the order (spec 041).
- `/sales/orders/:id` doesn't redirect POS sales. It shows a text-only foreign-order notice.

**Decision**:
- Add `orderLinkTargetProvider(saleId)`, a family that calls `SalesOrderRepository.getById` and resolves the target with `isForeignOrder(sale, settings)`, which already handles the null-origin heuristic:
  - **Foreign:** `/sales/pos/:id`, if the user can read POS (44).
  - **Back-office:** `/sales/orders/:id`, if the user can read SalesOrders (7).
  - Otherwise, plain text.
- If the user can't read SalesOrders, the order can't be fetched (the server requires it), so the cell is plain text. This also covers fetch errors.
- The cost is one request per distinct application order. A payment has few applications, and the family dedupes.

**Alternatives rejected**:
- **Always link to `/sales/orders/:id`:** a POS sale would land on a dead-end notice.
- **Asking mbe-api to add origin to `ApplicationResponse`:** a reasonable later improvement, not needed now.

## R9 — Amounts in a payment's own currency (FR-016)

**Facts**: `fmt.display.currency(String)` formats with the single configured symbol. The currency labels (`_currencyLabel`) are private copies in two header panels.

**Decision**: render amounts as `fmt.display.currency(amount)` followed by the currency code, through one new helper `currencyCodeLabel(Currency)` in `lib/core/domain/currency.dart`. It returns MXN, USD or EUR.
- On the list, the code appears on every Importe cell (the wireframe's second line).
- On the detail, it appears once, in the header.

The two private copies are **not** refactored onto the helper. That's outside this feature, and it's mentioned in the PR rather than changed (surgical-change rule).

**Rationale**: no formatter change in `core/formatting`, which would affect every screen.

## R10 — Labels: methods, types, verified

**Decision**:
- **Methods:** the existing `paymentMethodLabel(l10n, code)` (`lib/core/domain/payment_method.dart`). The private `_methodCodeFromApi` in `sale_payment.dart` is promoted to a top-level `paymentMethodCodeFromApi` beside it, so both entities share it.
- **Payment types:** new `enum PaymentType` (na, immediate, creditPayment, paymentInAdvance, creditNote, expense) in `lib/features/sales/domain/payment_type.dart`. `paymentTypeLabel(l10n, type)` maps to the clarified labels: N/A · Contado · Pago de crédito · Pago anticipado · Nota de crédito · Gasto.
- **Verified:** a `StatusChip<bool>` built in the feature, with its colour mapping kept in the caller's file (status_chip.dart convention). Labels: "Verificado" and "Sin verificar".
- **Reversed applications:** a `StatusChip` labelled "Revertida".

## R11 — The verified filter control

**Decision**: three `ChoiceChip`s (Todos · Verificados · Sin verificar), the same shape as the cash-sessions status facet. This is the tri-state pattern that the memory note and FR-007 ask for.

**Alternatives rejected**: the products screen's `_TriStateFilterChip`, a single chip that cycles. It hides the "unverified" state behind a second tap, and the three-chip form is the one drawn and clarified.

## R12 — Navigation and routing

**Decision**:
- Add a new shell branch at `/sales/payments` and append `NavBranch.salesPayments` after `salesQuotes`. Branches are never renumbered.
- In `nav_destinations.dart`, the nav entry goes **right after cash-sessions**, with `gate: PrivilegeGate(SystemObject.customerPayments, AccessRight.read)`.
- Add a top-level detail route `/sales/payments/:paymentId`.
- Add `_routeGate`: the `/sales/payments` prefix maps to `customerPayments` read.

**Rationale**: this matches how cash sessions and orders are wired (list in a shell branch, detail top-level), and wireframe Open Question 8 assumed it.

## R13 — Testing

**Decision**:
- **Unit:**
  - the repository impl (mocked API): query mapping, `verified` tri-state and date edges
  - `PaymentsFilter.fromQuery`: mode gating, facet clearing, and `scope=all` ignored without PaymentsEditor
  - the list controller: the facility is always the user's
  - the detail guard
  - `orderLinkTargetProvider`
  - payment-type labels
- **Widget:**
  - the list screen in both modes
  - the drawer facets per mode
  - empty, error and loading states
  - the customer-name placeholder and fallback
  - the detail screen: header totals, reversed rows muted and excluded from Aplicado, links shown or hidden per rights, not-found for a foreign facility
  - the cash-session picker (digits → get, text → list)
- **Live:** `test/integration/payments_list_live_test.dart` discovers its fixtures at runtime, following the project memory pattern. It finds a payment through `list`, re-reads it through `get` and `listApplications`, and checks that `unapplied == amount − Σ non-cancelled applications` when they share a currency (SC-003). It uses the `MBE_POS_*` credentials and is skipped when they're absent.
