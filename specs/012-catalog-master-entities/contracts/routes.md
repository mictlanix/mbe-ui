# Contract: Routes, Navigation & RBAC Gating

**Feature**: `012-catalog-master-entities` | **Date**: 2026-07-19

Mirrors the specs/011-product-pricing router/nav wiring exactly. **The branch
order in `app_router.dart` MUST match the `NavBranch` index order in
`nav_destinations.dart`** (invariant documented at `nav_destinations.dart:10-11`).

## 1. Shell branches (in `app_router.dart`)

Five new `StatefulShellBranch`es are appended to the existing indexed-stack
shell. Current branches are home(0), users(1), products(2), priceLists(3),
pricing(4), exchangeRates(5). **Branch index is positional** —
`StatefulShellRoute.indexedStack`'s `branches:` is a literal ordered list, so a
branch's index is simply its position in that list at the moment it's added,
not an arbitrary label. The order below is therefore fixed to **tasks.md's
build order** (Suppliers→Labels→Employees→Customers→TaxpayerRecipients, per
the spec's story priorities), so each story can add its branch at the next
available position without reshuffling earlier ones (corrected 2026-07-19,
`/speckit-analyze` finding I1 — the original table used a different,
unrelated order that didn't match the build sequence):

| New branch index | Route | List screen | Story |
|---|---|---|---|
| 6 | `/suppliers` | `SuppliersListScreen` | US1 |
| 7 | `/labels` | `LabelsListScreen` | US2 |
| 8 | `/employees` | `EmployeesListScreen` | US3 |
| 9 | `/customers` | `CustomersListScreen` | US4 |
| 10 | `/taxpayer-recipients` | `TaxpayerRecipientsListScreen` | US5 |

> This order MUST be replicated identically in `NavBranch` and
> `kNavigationTree` (`nav_destinations.dart:10-11`'s invariant), and each
> story's router-wiring task MUST append its branch at the position shown
> here, in build order — not skip ahead to a "reserved" future index.

## 2. Top-level detail/form sub-routes (siblings, full-screen, no rail)

Four entities use server-assigned `int` ids (standard `/new` + `/:id` shape):

```
/customers/new                         → CustomerDetailScreen()
/customers/:customerId                 → CustomerDetailScreen(customerId, forceReadOnly=?view=true)
/employees/new                         → EmployeeDetailScreen()
/employees/:employeeId                 → EmployeeDetailScreen(employeeId, forceReadOnly=?view=true)
/suppliers/new                         → SupplierDetailScreen()
/suppliers/:supplierId                 → SupplierDetailScreen(supplierId, forceReadOnly=?view=true)
/labels/new                            → LabelDetailScreen()
/labels/:labelId                       → LabelDetailScreen(labelId, forceReadOnly=?view=true)
```

TaxpayerRecipient uses a **String** path key (client-supplied PK, research.md §9),
so `:taxpayerRecipientId` is passed through as a String (no `int.parse`):

```
/taxpayer-recipients/new               → TaxpayerRecipientDetailScreen()
/taxpayer-recipients/:taxpayerRecipientId
                                       → TaxpayerRecipientDetailScreen(
                                           taxpayerRecipientId: state.pathParameters[...],  // String
                                           forceReadOnly: ?view=true)
```

`int` id routes parse with `int.parse(state.pathParameters['…']!)`, exactly as
products/price-lists do.

## 3. `_routeGate` entries (deny-by-default, `AccessRight.read`)

Add to `_routeGate` in `app_router.dart`, each gating on the entity's read
privilege (the screen then hides create/update/delete controls per the form
controllers):

```dart
if (location.startsWith('/customers'))  return (customers, read);
if (location.startsWith('/employees'))  return (employees, read);
if (location.startsWith('/suppliers'))  return (suppliers, read);
if (location.startsWith('/labels'))     return (labels, read);
if (location.startsWith('/taxpayer-recipients')) return (taxpayerRecipients, read);
```

All five follow the standard convention (gate on `read`; no `/merge`-style
create-gated exception). Order them among the existing `startsWith` checks so no
prefix shadows another — none of these five prefixes collide with existing
routes.

## 4. Navigation (`nav_destinations.dart`)

Add five `NavDestination`s to the existing `catalogs` `NavGroup` (alongside
users/products/price-lists/exchange-rates), each `gate`d on read:

| id | label key | route | branchIndex | icon (outlined/filled) |
|---|---|---|---|---|
| suppliers | `suppliersMenuTitle` | `/suppliers` | `NavBranch.suppliers` (6) | `local_shipping_outlined` / `local_shipping` |
| labels | `labelsMenuTitle` | `/labels` | `NavBranch.labels` (7) | `label_outline` / `label` |
| employees | `employeesMenuTitle` | `/employees` | `NavBranch.employees` (8) | `badge_outlined` / `badge` |
| customers | `customersMenuTitle` | `/customers` | `NavBranch.customers` (9) | `people_alt_outlined` / `people_alt` |
| taxpayer-recipients | `taxpayerRecipientsMenuTitle` | `/taxpayer-recipients` | `NavBranch.taxpayerRecipients` (10) | `receipt_long_outlined` / `receipt_long` |

Add matching `NavBranch` constants (6–10) and top-level label tear-offs
(`_suppliersLabel`, etc.), keeping `kNavigationTree` `const`. The existing
`navDestinationsProvider` filter hides any destination the user cannot read and
drops an empty group — no change needed there.

> **Icon choice caveat**: `label_outline`/`label` are already used by the
> exchange-rates? No — exchange-rates uses `currency_exchange`. Verify no icon
> collides confusingly within the catalogs group at implementation; the table
> above is the intended set. `users` uses `people_outline`/`people`, so
> Customers uses `people_alt_*` to stay distinct.

## 5. Detail-screen AppBar (constitution v1.8.0)

Every detail screen's `AppBar.actions` carries **only** the read-only→edit
toggle `IconButton`, shown when `readOnly && canUpdate && id != null` (exactly
as `product_detail_screen.dart` / `price_list_detail_screen.dart`). Save is a
body `FilledButton`; Delete is a body error-styled `FilledButton` with a
confirm dialog. **No** other AppBar icon actions — this feature's spec prompted
that amendment, so it must be the reference implementation of it.

## 6. Row actions (constitution §VI)

Every list row uses `buildCatalogRowActions(editTooltip, onEdit: canUpdate ? … :
null)` — a single Edit icon, hidden without update privilege. Whole-row
`onRowTap` → `context.push('/entity/:id?view=true')` (read-only view). Create is
a toolbar `FilledButton.icon` in `CatalogFilterBar.actions`, shown only with
create privilege. No per-row View or Delete icon. None of these five needs a
second row action (no cross-feature shortcut like products→pricing), so each row
shows exactly one icon.
