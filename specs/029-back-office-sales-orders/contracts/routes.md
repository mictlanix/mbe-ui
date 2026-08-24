# Contract: Routes & Navigation

**Feature**: `029-back-office-sales-orders`

## 1. Navigation

One new destination, in the **Sales** group of `kNavigationTree`
(`lib/core/navigation/nav_destinations.dart`), placed **before** Point of Sale —
back-office order capture is the more general entry point, and the group already
reads Pricing → Cash Sessions → POS.

| Property | Value |
|---|---|
| `id` | `sales-orders` |
| `label` | `l10n.salesOrdersMenuTitle` ("Pedidos" / "Sales Orders") |
| `icon` / `selectedIcon` | `Icons.receipt_long_outlined` / `Icons.receipt_long` |
| `route` | `/sales/orders` |
| `branchIndex` | `NavBranch.salesOrders` |
| `gate` | `PrivilegeGate(SystemObject.salesOrders, AccessRight.read)` |

`NavBranch.salesOrders = 20`, **appended** after `userProfiles = 19`. Never
renumber: display order comes from position in `kNavigationTree`, not from the
index (the file says so already, twice).

**Invariant with no compile-time enforcement**: `NavBranch.salesOrders` must equal
this branch's positional index among the router's `StatefulShellBranch` list. The
new branch is appended last in `app_router.dart` for exactly that reason.

## 2. Routes

| Path | Where | Builder | Notes |
|---|---|---|---|
| `/sales/orders` | `StatefulShellBranch` (appended last) | `SalesOrdersListScreen(query: ListQuery.fromUri(state.uri))` | inside the shell, with the rail |
| `/sales/orders/new` | top level | `OrderScreen(orderId: null)` | full-screen, no rail |
| `/sales/orders/:orderId` | top level | `OrderScreen(orderId: int.parse(...))` | full-screen, no rail |

This mirrors spec 023's split exactly: the list lives in the shell branch, the
record screen at top level so it renders full-width. A non-numeric `:orderId`
must not throw — parse defensively and render the not-found treatment.

## 3. Guard

Added to `_gateFor` in `app_router.dart`:

```dart
if (location.startsWith('/sales/orders')) {
  return PrivilegeGate(SystemObject.salesOrders, AccessRight.read);
}
```

**Deliberately `salesOrders(7)`, not `pos(44)`** (FR-002): a back-office
salesperson with no register privilege must get in, and a cashier without
sales-order rights must not. This differs from the neighbouring `/sales/pos` and
`/sales/cash-sessions` guards, which use `pos` — that is pre-existing and not
touched here.

`startsWith('/sales/orders')` covers all three routes and collides with neither
`/sales/pos` nor `/sales/cash-sessions`. It must be added as its own clause; do
**not** widen an existing one.

## 4. Addressable state

`/sales/orders` decodes `ListQuery` from the URI. Facet keys:

| Key | Values | Who |
|---|---|---|
| `date-from`, `date-to` | `yyyy-MM-dd` | everyone |
| `status` | `draft` \| `completed` \| `paid` \| `cancelled` | everyone |
| `salesperson` | employee id | **administrators only** |
| `facility` | facility id | **administrators only** |
| `search`, `page` | reserved `ListQuery` keys | everyone |

A non-administrator's `salesperson`/`facility` values are dropped at decode time
(`SalesOrdersFilter.fromQuery`), not merely hidden in the drawer. The default
month encodes to **no** `date-from`/`date-to` at all, so an unfiltered first page
is a bare `/sales/orders`.

## 5. In-screen action gates

| Action | Gate | Presentation |
|---|---|---|
| New order | `can(salesOrders, create)` **and** a configured point of sale | hidden without the privilege; present-but-blocked with an explanation when only the register is missing (FR-014) |
| Edit (row) | `can(salesOrders, update)` **and** the row is a draft | hidden otherwise |
| Add / edit / remove line, confirm | `can(salesOrders, update)` **and** `sale.isEditable` | hidden otherwise |
| Header field edit (promise date, currency, salesperson, contact, ship-to, fiscal recipient, comment) | `can(salesOrders, update)` **and** `sale.isEditable` | the field renders as its read-only face otherwise — a header field always *shows*, so this one degrades rather than disappearing; it is never a disabled control |
| Cancel | `can(salesOrders, update)` **and** `sale.isEditable` | on the order screen only, never on a row; requires a confirmation dialog |
| Change priority | `can(salesOrders, update)` | the one control that survives `!isEditable` |
| Salesperson / facility facets | `access.isAdministrator` | absent otherwise |

Hidden, never disabled — constitution §IV.
