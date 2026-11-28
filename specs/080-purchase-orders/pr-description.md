## Summary

Purchasing can now turn approved purchase requests into purchase orders, confirm them into warehouse receipts, and print and email them to suppliers. Spec: `specs/080-purchase-orders/`.

Two screens join the **Compras** group, after Aprobación de solicitudes.

- **Por comprar: order the pending lines (P1).**
  - It lists the marked lines of approved requests that aren't on an order yet, grouped by supplier and destination facility. Each group shows its line count and estimated total at cost, and expands to show its lines.
  - The buyer selects a group and presses "Crear orden" in the toolbar, which creates a draft priced from the cost list and opens it.
  - Lines whose product has no supplier form "Sin proveedor" groups, which can't be selected and are added to an order by hand.
  - The facility filter is in the drawer. The groups are paged in the app until the server pages them (mbe-api#354).
- **Write and confirm an order (P1).**
  - "Nueva orden" takes a supplier, an optional delivery date (not in the past, clearable) and notes.
  - On a draft, the buyer adds purchasable products or every pending line of one approved request. Lines from a request show its folio.
  - "Confirmar" always asks first, naming the warehouses that will get receipts and any line priced at 0. It then creates one draft receipt per destination warehouse, and the order lists them with a link to each.
  - A line priced at 0 shows a Spanish warning band, which never blocks.
- **Find and follow (P2).**
  - The order list shows the user's own orders without cancelled ones by default.
  - The drawer holds the scope (Mis órdenes or Todas), state, supplier, creator and date range; the order number has its own search box.
  - A confirmed order shows Recibido and Pendiente per line; a non-stockable line shows "—".
  - The request detail (079) and the receipt detail (067) now link their order number to the order, for users who can read orders.
- **Print and email (P2).**
  - A confirmed order prints its server-rendered PDF through the shared preview.
  - "Enviar por correo" suggests the supplier's contact addresses, takes 1–10 addresses and an optional message, and shows Spanish messages when mail is refused or not configured.
- **Correct or cancel a draft (P3).**
  - "Editar encabezado" changes the supplier, date and notes; clearing the date or notes clears them on the server.
  - Line ✎ changes warehouse, quantity, price and IVA (0 %, 8 %, 16 %, or the line's own rate). An untouched price is never resent rounded.
  - 🗑 removes a line.
  - "Cancelar orden" cancels a draft, keeping its lines as history and putting its request lines back in Por comprar.

**Gates mirror the server (PurchasesOrders, 20).**
- read: see the list, Por comprar and orders, and print;
- create: start an order, by hand or from a group;
- update: edit, add lines, confirm and email;
- delete: cancel.

Pickers also need read on their own catalog, adding a request's lines needs read on purchase requests (86), and opening a receipt needs read on receipts (15). Orders aren't limited by facility. Anything a user can't use is absent, not disabled. The two exceptions depend on the order's state, not the user's rights: "Confirmar" is disabled on a draft with no lines, and "Crear orden" is disabled until a group is selected.

There's no purchase-order approval: the legacy one was off from March 2025 and isn't built (mbe-api 05 §4).

**Where this changes existing code.**
- **Navigation and router:** two destinations in the `purchases` group (branches 40 and 41), a top-level detail route and two route gates.
- **Printing:** a new `DocumentKind.purchaseOrder`, gated on read on 20, and its arm in the document source.
- **Error messages:** the 9 `purchase_order.*` codes get messages in both languages. Spec 058's `code-scope.tsv` marks them `IN`, and the coverage test's count goes from 225 to 234.
- **Request and receipt details:** their plain-text order number becomes `PurchaseOrderLink`.
- **Wire setters:** `wire_value_setters.dart` gains setters for the order's quantity, price and tax-rate types.
- **Reused across features, recorded in `plan.md` Complexity Tracking:**
  - inventory's name cells, status chip and warehouse options;
  - the quote email helpers from `sales`.

**Known limits.**
- **Reopening a confirmed order shows no receipts.** The server returns them only in the confirm response, and receipts can't be filtered by order. Received and pending quantities still show per line. Filed as mbe-api#355.
- **No supplier-mismatch warning, and left-out lines are reported by count only.** The server's warnings and skip reasons are uncoded English. Filed as mbe-api#353.
- **Por comprar has no search or supplier filter.** Filed as mbe-api#354.
- **Unit prices display at the currency's precision.** They are edited and stored at full precision.
- **Draft quotation not built.** The legacy `Purchases.Export` (sending a draft to a supplier as a quotation) needs a server document: mbe-api#356, with the UI follow-up in mbe-ui#310.

The other 16 legacy actions are covered or deliberately dropped: see `specs/080-purchase-orders/legacy-actions.md`.

## Roadmap

Closes mictlanix/mbe-roadmap#71

Follow-up for manual checks: mbe-ui#311.

Upstream, not blocking: mbe-api#353 (coded warnings and skip reasons), mbe-api#354 (Por comprar filters and paging), mbe-api#355 (receipts with state on every order response), mbe-api#356 (draft quotation document). Follow-up: mbe-ui#310.

## Test plan

- [x] `flutter analyze`: no issues.
- [x] `flutter test` (whole suite, no `.env` defines): 7505 passed, 86 skipped, 8 failed. All 8 also fail on `main`:
  - 6 goldens in `test/golden/`: the known environment pixel diffs (mbe-ui#209);
  - `test/screenshots/pos_screens_screenshot_test.dart`: the same 3.03% diff on the POS sales list;
  - `test/integration/auth_flow_test.dart` scenario 2: needs a live server.

  I checked the last two on a clean `main` worktree. This branch changes no shared widget, design token or theme file, and adds l10n keys without changing existing ones.
- [x] `dart format` on the 75 changed or new Dart files: no changes. Nothing under `lib/generated/` changed.
- [x] New tests:
  - unit: price-0 function, repository, filters, list, detail and Por comprar controllers, selection, actions, availability, request-folio lookup, email controller;
  - widget: list, Por comprar, detail in each state, every dialog, the band, the receipts section, the order link, largest text;
  - new cases in the router, navigation, documents and error-catalog tests, and in the request-detail and receipt-detail tests.
- [x] Live repository test `test/integration/purchase_orders_live_test.dart` against dev, with `MBE_WRITE=true`: 22 of 22 steps passed. What it found:
  - **Wire values:** quantity, price and tax rate round-trip exactly ("1.2345", "10.1234567", "0").
  - **Dates:** an estimated date reads back as the same calendar day.
  - **Clearing:** clearing the notes and the date works (the date through a raw PUT, because the generated client drops nulls).
  - **Confirm:** it makes one receipt per warehouse and none for a service line.
  - **Reload after confirm:** the receipts list comes back empty. The test asserts that, so it fails on purpose when mbe-api#355 ships.
  - **Mail:** not configured on dev, so the test confirms the `email.not_configured` path without sending anything.
- [x] Device walkthrough `integration_test/purchase_orders_quickstart_test.dart` on macOS against dev: quickstart steps 1–12 and 14 pass, including the no-access check and the concurrent-confirm reload.
- [x] Largest text level, at 1280 px and at 360 px: the list, Por comprar, a draft and a confirmed order show no overflow. The test caught the request folio, the Por comprar group header, the creator row and the receipts rows overflowing; they now wrap or shorten.
- [x] A high-effort code review of the branch found 10 issues, all fixed in `b4f1dec0`:
  - stale request screens, Por comprar and receipts list after writes;
  - a date-picker assertion on far-future dates;
  - an options load continuing after its dialog closed;
  - compact-width overflows;
  - a cached failed folio lookup;
  - a lingering refusal banner;
  - the notes limit counting untrimmed text, also fixed in the 079 request dialogs;
  - an unused method.

**Still manual** (tracked in mbe-ui#311):
- the timed checks SC-001 (Por comprar group to a confirmed order in under 1 minute) and SC-002 (a 5-line order written, confirmed, printed and emailed in under 4 minutes);
- an email actually arriving with the PDF, which needs mail configured;
- quickstart step 13 with a read-only account on 20, since no seeded account has it;
- the largest text level on a real device.

Results are in `specs/080-purchase-orders/quickstart-results.md`.

Dev leftovers from the live and device runs are tagged "QA080". Confirmed orders 11074, 11079, 11080, 11083, 11084, 11087 and 11088 can't be cancelled, and approved requests 2315, 2318, 2320 and 2322 stay approved because their lines are on those orders.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
