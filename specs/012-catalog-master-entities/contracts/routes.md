# Contract: Routes, Navigation & RBAC Gating

**Feature**: `012-catalog-master-entities` | **Date**: 2026-07-19

Mirrors the specs/011-product-pricing router/nav wiring exactly. **The branch
order in `app_router.dart` MUST match the `NavBranch` index order in
`nav_destinations.dart`** (invariant documented at `nav_destinations.dart:10-11`).

## 1. Shell branches (in `app_router.dart`)

Five new `StatefulShellBranch`es are appended to the existing indexed-stack
shell. Current branches are home(0), users(1), products(2), priceLists(3),
pricing(4), exchangeRates(5). The new branches continue the sequence:

| New branch index | Route | List screen |
|---|---|---|
| 6 | `/customers` | `CustomersListScreen` |
| 7 | `/employees` | `EmployeesListScreen` |
| 8 | `/suppliers` | `SuppliersListScreen` |
| 9 | `/labels` | `LabelsListScreen` |
| 10 | `/taxpayer-recipients` | `TaxpayerRecipientsListScreen` |

> Order within the group is a presentation choice; whatever order is chosen here
> MUST be replicated identically in `NavBranch` and `kNavigationTree`. The table
> above is the canonical order for this feature.

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
| customers | `customersMenuTitle` | `/customers` | `NavBranch.customers` (6) | `people_alt_outlined` / `people_alt` |
| employees | `employeesMenuTitle` | `/employees` | `NavBranch.employees` (7) | `badge_outlined` / `badge` |
| suppliers | `suppliersMenuTitle` | `/suppliers` | `NavBranch.suppliers` (8) | `local_shipping_outlined` / `local_shipping` |
| labels | `labelsMenuTitle` | `/labels` | `NavBranch.labels` (9) | `label_outline` / `label` |
| taxpayer-recipients | `taxpayerRecipientsMenuTitle` | `/taxpayer-recipients` | `NavBranch.taxpayerRecipients` (10) | `receipt_long_outlined` / `receipt_long` |

Add matching `NavBranch` constants (6–10) and top-level label tear-offs
(`_customersLabel`, etc.), keeping `kNavigationTree` `const`. The existing
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
