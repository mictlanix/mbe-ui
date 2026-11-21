# Contract: Navigation sections (FR-018) and nav header (FR-012)

`kNavigationTree`, in order. Home stays first and outside the sections. Section headers keep the key `nav_group_<id>`.

| # | Section id | Label key (es / en) | Destinations, in order |
| --- | --- | --- | --- |
| 0 | — | — | `home` |
| 1 | `operation` | `navOperationGroup` (Operación / Operations) | `pos`, `sales-orders`, `sales-quotes`, `pricing`, `customers`, `cash-sessions`, `delivery-orders`, `delivery-order-approval`, `for-delivery`, `delivery-itineraries`, `vehicles`, `vehicle-operators` |
| 2 | `inventory` | `navInventoryGroup` (Inventario / Inventory), existing | `inventory-receipts`, `inventory-issues`, `inventory-transfers`, `inventory-counts`, `inventory-stock`, `inventory-kardex`, `products`, `price-lists`, `suppliers`, `labels` |
| 3 | `finance` | `navFinanceGroup` (Finanzas / Finance) | `payments`, `payment-verification`, `credit-notes`, `refunds`, `fiscal-documents`, `taxpayer-issuers`, `taxpayer-recipients`, `exchange-rates`, `payment-method-options`, `expenses` |
| 4 | `system` | `navSystemGroup` (Sistema / System) | `users`, `user-profiles`, `employees`, `facilities` |

Invariants, checked by `nav_destinations_test.dart`:

- The 37 destination ids before and after the change are the same set. Each appears exactly once.
- `NavBranch` indices and routes are unchanged.
- A section whose destinations are all hidden by rights or by multi-currency is not shown.
- These keys are removed, because nothing else uses them: `catalogsGroupTitle`, `salesGroupTitle`, `logisticsGroupTitle` and `navInvoicingGroup`. Each removal is confirmed by grep first.

## Nav header

`BrandNavHeader` shows the brand mark alone below 840px (Compact and Medium) and the mark plus `displayName` at 840px and up. This applies to every brand. The header appears in two places, and both follow the rule:

- the drawer header at Compact;
- the app-bar leading slot at Medium and up.

## App-bar rule (FR-017)

Every `AppBar` has a 3px bottom border in `SemanticColors.accent`, set through `AppBarTheme.shape`. Two more spots need their own change:

- The three screens that set their own `shape` drop it.
- The compact full-screen header in `ResponsiveDialog` draws the same border.
