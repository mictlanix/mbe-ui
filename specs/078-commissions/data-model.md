# Data Model: Commissions

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

Domain entities live in `lib/features/commissions/domain/entities/` and are freezed. They are
mapped from the generated DTOs in `data/` (§III). Money, rates and quantities stay
`Decimal`, parsed from the server's strings, and only `formattersProvider` turns them into text.

## Periods

### `CommissionPeriodStatus` (enum)

| Value | Wire | es | Chip tone |
|---|---|---|---|
| `open` | `open` | Abierto | neutral |
| `closed` | `closed` | Cerrado | info |
| `paid` | `paid` | Pagado | success |

An unknown wire value maps to `open` and is logged. A period the server does not know about is not final.

### `CommissionMonth` (value)

`year: int`, `month: int` (1–12). Has `previous` and `next`, and compares chronologically.
`isAfterCurrent(now)` is computed in the business time zone (the app's existing "now",
not device UTC).

### `CommissionPeriodSummary`, from `CommissionPeriodSummary` DTO (`GET /periods`)

| Field | Type | Notes |
|---|---|---|
| `month` | `CommissionMonth` | |
| `status` | `CommissionPeriodStatus` | |
| `total` | `Decimal` | 0 for a reopened month |
| `closedAt`, `paidAt`, `reopenedAt` | `DateTime?` | |
| `closedBy`, `paidBy`, `reopenedBy` | `int?` | **employee** ids (research R2) |

### `CommissionPeriod`, from `CommissionPeriodDetail` (`GET /periods/{y}/{m}?salesperson=`)

| Field | Type | Notes |
|---|---|---|
| `month`, `status`, audit fields | as above | |
| `isFinal` | `bool` | the server's `final` |
| `totals` | `List<CommissionTotal>` | per (agent, label) |
| `lines` | `List<CommissionLine>` | for the requested agent, or all |
| `agentId` | `int?` | the filter the period was read with |

Derived on the entity, so the screen never adds money:
- `grandTotal`: the sum of `totals.commission`;
- `lineCount`: the sum of `totals.lines`;
- `totalsByAgent`: (agent, lines, commission), folded from `totals`;
- `totalsByLabel(agentId)`: one agent's rows.

All are sums of the server's rounded values. SC-002 holds because the server's totals are
the sum of its rounded lines.

### `CommissionTotal`

`agentId: int`, `labelId: int?` (null = "Sin etiqueta"), `labelName: String?`, `lines: int`, `commission: Decimal`.

### `CommissionLine`

| Field | Type | Shown in |
|---|---|---|
| `movement` | `CommissionMovement { sale, refund }` | table (icon + "Devolución"), panel |
| `scheme` | `CommissionScheme` | panel |
| `salesOrderId`, `salesOrderDetailId`, `customerRefundDetailId?` | `int` | table (order), panel |
| `orderDate`, `paidDate` | `DateTime` | panel / table |
| `customerId`, `customerName` | | table |
| `productId`, `productName` | | table |
| `labelId?`, `labelName?` | | table ("Sin etiqueta" + Asignar when the month is open) |
| `labelRate`, `participationRate`, `rate` | `Decimal` | panel / panel / table |
| `agentId`, `orderSalespersonId`, `customerSalespersonId` | `int` | panel |
| `participationId`, `participationName` | | table |
| `price`, `quantity`, `total` | `Decimal` | panel / panel / table (amount) |
| `fullCommission` | `Decimal` | panel |
| `share` | `Decimal?` | panel, scheme-2 sales only |
| `commission` | `Decimal` | table |

Identity for list keys: (`movement`, `salesOrderDetailId`, `customerRefundDetailId`, `agentId`, `participationId`).

### Action availability (computed in the month controller, from the period and the months list)

| Action | Offered when (UI guidance; the server decides, FR-011) | Right |
|---|---|---|
| Cerrar mes | `status == open` **and** the month has ended **and** (no month is closed or paid, **or** the previous month is closed or paid) **and** no later month is closed or paid | Update |
| Reabrir | `status == closed` **and** no later month is closed or paid | Update |
| Marcar pagado | `status == closed` | Update |
| Asignar etiqueta (line) | `status == open` and the line has no label | Update |

The blocked-close reason, shown in place of the button (FR-007):

| Reason | Text key |
|---|---|
| Not ended | `commissionCloseBlockedNotEnded` |
| Previous month open | `commissionCloseBlockedPrevious(month)` |
| A later month is closed | `commissionCloseBlockedLater` |

"Closed or paid" both count as closed for the chain (spec 025 FR-010a). The months list
supplies the "latest closed" and "previous" facts. The month screen reads it alongside the
detail.

## Settings

| Entity | Fields | From | Notes |
|---|---|---|---|
| `CommissionLabel` | `id`, `name`, `rate: Decimal` (fraction), `comment?` | `/labels` | rate 0–1 |
| `CommissionParticipation` | `id`, `name` | `/participations` | |
| `CommissionAgent` | `employeeId`, `name`, `scheme: CommissionScheme` | `/agents` | `CommissionScheme { fullyPaid = 1, partialPayments = 2 }` |
| `CommissionAgentRate` | `id`, `agentId`, `labelId`, `participationId`, `share: Decimal` | `/agent-rates` | unique per (agent, label, participation) |
| `CommissionProductLabel` | `productId`, `productCode`, `productName`, `labelId` | `/product-labels` | paged: `CommissionProductLabelPage { items, total }` |

### `AgentRateGrid` (presentation model, built from the four lists above)

Rows are labels, sorted by name. Columns are participation types, sorted by id, so CLIENTE VITALICIO,
CANALIZACIÓN, ATENCIÓN EN CAMPO come in that order. Each cell is `AgentRateCell { labelId,
participationId, rateId?, share? }`, and an empty cell has both null. A cell's write follows
research R11's create/update/delete table.

### Validation (client side, before sending)

| Field | Rule | Message key |
|---|---|---|
| Label name, participation name | not blank, trimmed | `commissionNameRequired` |
| Label rate, agent share | `PercentInput`: number, 0–100, ≤ 4 decimals | `percentInvalid`, `percentOutOfRange`, `percentTooPrecise` |
| Agent | employee chosen, not already an agent (picker excludes current agents) | — |
| Product label | product and label chosen | — |
