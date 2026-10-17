# UI Contracts: POS Sales Fixes

**Feature**: 047-pos-sales-fixes | **Date**: 2026-10-17

These contracts list the widget keys, routes and function signatures that tests rely on. All new strings are added to both `app_es.arb` and `app_en.arb` (FR-021).

## C1 — Session gate on the POS sales list

- `_NewSaleAction`:
  - **Disabled** when `state == none`. The existing tooltip and the `posSalesNewSaleBlockedNoSession` key are kept.
  - **Enabled** when the state is `open` or `stale`.
- On tap, the session is re-read (`ref.refresh(currentSessionControllerProvider.future)`):
  - `open` → `context.push('/sales/pos/new')` (as today).
  - `stale` → `context.go('/sales/cash-sessions/<cashSessionId>')`, plus a snackbar with the new key `posSessionExpiredRedirect` ("Tu sesión de caja está vencida. Ciérrala para continuar vendiendo.").
  - `none` → snackbar `posSalesNewSaleBlockedNoSession`; no navigation.

## C2 — Session gate in the workspace

- `/sales/pos/new` under `stale` → `GoRouter.replace` (or `go`) to `/sales/cash-sessions/<id>`, with the same snackbar. No sale is created.
- `/sales/pos/:saleId` under `stale` or `none` → the sale renders. In the payment step:
  - the method grid is disabled;
  - `pos_session_blocked_banner` shows the new `posSessionExpiredPaymentsBlocked` text (stale) or `posGateNoSessionBody` (none);
  - an action button `pos_session_blocked_action` goes to the close screen (stale) or to `/sales/cash-sessions` (none).
- The existing `_StaleSessionBanner` (non-blocking) is replaced by this behavior.

## C3 — `CurrentListQueryBuilder` URI resolution

```dart
/// The URI of the top-most route, including routes that were pushed.
Uri currentRouteUri(GoRouter router);
```

`CurrentListQueryBuilder` uses this function in place of `routerDelegate.currentConfiguration.uri`. Its behavior is unchanged for routes reached with `go` (the 14 shell list screens).

## C4 — Stock gate on the capture step

```dart
StockGate evaluateStock(Sale sale, Map<int, ProductStock> cache);
Future<void> ensureStockFor(Sale sale); // on ProductStockCache notifier
```

- `SaleTotalsBar.onContinue` is `null` while `gate.blocks`.
- `capture_continue_blocked_reason` text shows the new `posCaptureShortLines(count)` ("{count} partidas sin existencia suficiente").
- A line in `shortLineIds` keeps its existing short indicator. A line in `unknownLineIds` shows the existing "unknown" stock flag.

## C5 — Warehouse field and pop-up

```dart
Future<int?> showWarehousePicker(
  BuildContext context, {
  required List<Warehouse> warehouses,
  required int? selected,
  required ProductStock? stock,
  required Decimal quantity,
});
```

- The field has the key `sale_line_warehouse_<lineId>`. It is an `InputDecorator`-styled tap target showing the name and the stock flag. It does nothing when the line is not editable.
- The dialog has the key `warehouse_picker_dialog`. Its rows have the key `warehouse_option_<id>`, and the selected row shows `Icons.check`.
- Returns the picked id, or `null` on cancel. The caller ignores `null`, and ignores a result equal to the current warehouse.

## C6 — Payment capture pane

- **Removed**: `payment_submit_button` and `payment_reference_field`.
- **Method tiles**: `payment_option_<id>` and `payment_method_<code>` keep their keys. `onTap` → `PaymentController.tender(sale, option)`. Tiles are disabled while `submitting`, or while the session is invalid.
- **Reference dialog**: key `payment_reference_dialog`, field `payment_reference_input`, confirm button `payment_reference_confirm`.
- **New errors**:
  - `posPaymentAmountRequired`
  - `posPaymentOverpayNonCash` ("Solo el efectivo puede exceder el saldo")
- **Amount field**: pre-filled with the balance (C7 below).

## C7 — Change card

- Key `payment_change_card`. Rendered when `draft.lastChange != null`.
- Shows the `posPaymentChangeDue` label ("Cambio a entregar") and the amount from `formattersProvider` in a display style.
- A dismiss button with the key `payment_change_dismiss` clears it.
- The existing summary "Cambio" row is kept as the live preview.

## C8 — No API contract changes

- No endpoint, schema or codegen changes.
- An optional mbe-api follow-up is proposed: a batch `products` parameter on `product-lookup` (research R4).
