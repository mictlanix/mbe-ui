# Contract: mbe-api `/cash-sessions` as consumed by mbe-ui

**Feature**: `021-cash-sessions` | **Date**: 2026-08-04

Five operations, all present in the checked-in generated client at
`lib/generated/openapi/lib/src/api/cash_sessions_api.dart`. Verified against mbe-api source
on 2026-08-04, then **re-verified against the client regenerated 2026-08-05** after
mbe-api#141/#142 shipped mid-implementation (research.md §17) — this file reflects the
current wire shapes, not the ones planning started from.

There is no PUT, PATCH, or DELETE anywhere on this resource.

---

## 1. `GET /api/v1/cash-sessions/current`

`getCurrentSessionApiV1CashSessionsCurrentGet()` → `CurrentSessionResponse`

Privilege: `POS (44)` READ. No parameters.

```
{ "state": "none" | "open" | "stale", "session": CashSessionResponse | null }
```

**Keys off the authenticated user's employee id**, not off a drawer. When the cashier has
several open sessions — which legacy data contains — it returns the **most recent** one
(`ORDER BY start DESC LIMIT 1`) and silently hides the rest. mbe-api deliberately tolerates
the non-unique condition here rather than raising, because asserting uniqueness produced
500s on payments recorded by such cashiers.

Consumed by: the shift panel (FR-001), and the 409 disambiguation on open (FR-009).

Errors: 401, 403.

---

## 2. `GET /api/v1/cash-sessions`

`listCashSessionsApiV1CashSessionsGet({int? cashDrawer, int? cashier, int? facility,
CashSessionStatus? status, DateTime? dateFrom, DateTime? dateTo, CashSessionSort? sort = -id,
int? skip = 0, int? limit = 20})` → `ListResponseCashSessionResponse` (`{items, total}`)

Privilege: `POS (44)` READ.

mbe-api#142 (filed during planning) shipped mid-implementation and added five parameters;
this is the **current** signature, not the one-filter version planning started from
(research.md §17).

| Parameter | Type | Default | Constraint |
|---|---|---|---|
| `cashDrawer` | `int?` | none | Exact match |
| `cashier` | `int?` | none | Exact match — used by the recover-abandoned-session flow (FR-004) |
| `facility` | `int?` | none | Exact match. Not used by this feature's UI — no requirement needs it |
| `status` | `CashSessionStatus?` | none | Generated enum `open`/`stale`/`closed`, derived server-side by the identical `session_state` rule this plan's `cashSessionStatusOf` replicates for display |
| `dateFrom` / `dateTo` | `DateTime?` | none | Not exposed in the UI — no requirement asks for a date-range filter |
| `sort` | `CashSessionSort?` | `-id` | `-id` (default), `start`, or `-start`. Not exposed in the UI — the default already satisfies FR-027's "newest first" |
| `skip` | `int` | 0 | `>= 0` |
| `limit` | `int` | 20 | `>= 1`, `<= 100` |

Still **not** scoped by facility or cashier by default — every filter above is opt-in, so an
unfiltered request still returns every facility's and every cashier's sessions (spec A-007,
A-008 both still hold; only the *option* to narrow changed).

Still no free-text `search` — a session has no text field a search would match against, and
this was never requested.

Consumed by: the history list (FR-027 to FR-029, FR-034), and the FR-004 "other open
sessions" check (`cashier` + `status: open`, replacing the same-drawer heuristic research §16
describes as superseded).

Errors: 401, 403, 422 (parameter validation).

---

## 3. `POST /api/v1/cash-sessions` → **201**

`openCashSessionApiV1CashSessionsPost({required CashSessionOpen cashSessionOpen})`
→ `CashSessionResponse`

Privilege: `POS (44)` **CREATE**.

```
CashSessionOpen { cash_drawer?: int, opening_amount: Decimal = 0 }
```

Both fields optional. `cash_drawer` omitted ⇒ the server uses the caller's configured
drawer. `opening_amount` must be `>= 0`.

**Client-side wrapper hazard**: `opening_amount` generates as `OpeningAmount`, an
`AnyOf<String, num>` — not a scalar. Build it as
`AnyOf2<String, num>(values: {0: value})`, `String` arm at key `0`. The reverse order
throws at runtime; see the warnings on the existing `_setCommission` /
`_setHighProfitMargin` shims.

**Server-side side effect worth knowing**: the opening amount has no column. It is stored
as a single synthetic `cash_count` row of type `StartingCash` (`denomination = amount,
quantity = 1`), written **only when `> 0`**, and read back by summing that type. So it is a
scalar, not a breakdown, and an opening of zero writes no row at all.

| Status | Detail | Meaning |
|---|---|---|
| 409 | `That cash drawer already has an open session` | Drawer busy |
| 409 | `You already have an open session; close it before opening another` | Cashier busy |
| 422 | `No cash drawer is configured for your user; set one or supply it explicitly` | Neither body nor settings supplied a drawer |
| 404 | `Cash drawer not found` | |
| 422 | (Pydantic) | Negative `opening_amount` |

The two 409s are indistinguishable by status. mbe-ui does **not** parse their detail text —
it re-reads operation 1 and branches on whether the caller now has a session (research §4).

---

## 4. `GET /api/v1/cash-sessions/{cash_session_id}`

`getCashSessionApiV1CashSessionsCashSessionIdGet({required int cashSessionId})`
→ `CashSessionResponse`

Privilege: `POS (44)` READ.

Consumed by: the session detail screen (FR-031), and the close flow's source of the
expected-cash inputs.

Errors: 404 `Cash session not found`, 401, 403.

---

## 5. `POST /api/v1/cash-sessions/{cash_session_id}/close` → **200**

`closeCashSessionApiV1CashSessionsCashSessionIdClosePost({required int cashSessionId,
required CashSessionClose cashSessionClose})` → `CashSessionResponse`

Privilege: **`CASH_SESSION_CLOSE (111)` UPDATE** — a different system object from the
other four operations. Gating the close button on `POS` instead would show cashiers an
action that 403s (FR-035).

```
CashSessionClose { counts: [ { denomination: Decimal > 0, quantity: int >= 0 } ] }
```

`counts` defaults to `[]`, so **the server will close a session with no count at all**.
Requiring a count is a client-only rule (FR-021). Each `denomination` is an
`AnyOf<String, num>` with the same key-`0` hazard as above.

**Server-side effects**: writes one `cash_count` row per submitted entry with type
`CountedCash`; sets `end = now()`; sets `cash_supervisor` to the **caller's** employee id.

Three consequences the UI must reflect honestly:
- The closer is not verified as a second person. A cashier holding 111 who closes their own
  shift is recorded as their own supervisor (spec A-006).
- Anyone holding 111 may close **any** session, not only their own (FR-026).
- The submitted counts are **write-only**. No operation returns them, so the counted total
  and difference must be shown in the close confirmation (FR-023) and must never be
  promised afterwards (FR-033).

| Status | Detail | Meaning |
|---|---|---|
| 409 | `Session is already closed` | Double close; keep the user's counts (FR-024) |
| 404 | `Cash session not found` | |
| 422 | (Pydantic) | Malformed `counts` entry |

---

## `CashSessionResponse`

mbe-api#141 (filed during planning) shipped mid-implementation and expanded three fields
from bare ints to full objects; this is the **current** shape (research.md §17).

| Field | Type | Null |
|---|---|---|
| `cash_session_id` | `int` | no |
| `cash_drawer` | `CashDrawerSummary { cash_drawer_id, facility, code, name, comment, status }` | no |
| `cashier` | `EmployeeResponse { employee_id, first_name, last_name, … }` | no |
| `start` | `datetime` | no |
| `end` | `datetime` | **yes** |
| `cash_supervisor` | `EmployeeResponse` | **yes** |
| `opening_amount` | `Decimal` (JSON string) | no |
| `payments_by_method` | `[{ method: int, total: Decimal }]` | nullable, defaults `[]` |

**No `state` field.** Status must still be derived from `end` and `start` versus today,
wherever a session is displayed (FR-002, data-model §3) — mbe-api#142 added a `CashSessionStatus`
generated enum, but only as a *list filter input*, never echoed back on this or any other
response.

**No more bare FK integers.** `cash_drawer`, `cashier`, and `cash_supervisor` now match the
API's own dominant shape — `CashDrawerResponse.facility` was already expanded this way — so
there is no client-side name resolution anywhere in this feature. `CashSession.fromResponse`
flattens `cash_drawer.name`/`.code` and `cashier`/`cash_supervisor`'s first+last name directly
off these objects, the same pattern `CashDrawer.facilityName` already uses.

`payments_by_method` is an aggregate net of cash refunds, and excludes expense vouchers and
other drawer outflows entirely.

---

## Adjacent behavior mbe-ui relies on but does not call

- **`POST /customer-payments`** attaches the cashier's open session **when one exists**; a
  payment does not require one. Payments taken with no session are permanently
  unattributed and cannot be reconciled later (spec D-007).
- **Refunds** do require an open session server-side, and land as *negative* cash payments
  against it — which is why `payments_by_method` is net.
- **`GET /customer-payments?cash_session=`** would list a session's individual payments.
  Not used by this feature; the per-method aggregate is sufficient for FR-031.
- **`GET /cash-drawers`** is gated on `CASH_DRAWERS (10)` READ — a different object from
  `POS (44)`. A cashier may therefore be able to open a session but not list drawers, which
  drives the picker fallback in research §7.
