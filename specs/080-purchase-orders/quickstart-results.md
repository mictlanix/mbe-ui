# Quickstart results: Purchase Orders (080)

Run on 2026-11-28 against the dev tenant (`https://test.api.mbe.mictlanix.com`) as the administrator (`MBE_POS_*`; W1 = warehouse 12 ZUMPANGO 1 (Materiales), facility 51 CASA MAESTRA ZUMPANGO), task T038.

## How it was verified

- **Device test**: `integration_test/purchase_orders_quickstart_test.dart` (T037) on macOS, run with `caffeinate -dims flutter test integration_test/purchase_orders_quickstart_test.dart -d macos --dart-define-from-file=.env.settings --dart-define-from-file=.env`. The third run passed all 18 checks (`02:58 +1: All tests passed!`).
- **Live repository test**: `test/integration/purchase_orders_live_test.dart` (T036) with `MBE_WRITE=true`, 22/22 passed.
- **Widget tests**: `test/widget/features/purchases/` (the rights matrix, the order link, and the largest-text test `purchase_orders_large_text_test.dart`).

Fixtures the device test found at run time: product P = `30733` (#902, supplier 86 DEACERO, S.A. DE C.V.), the costless product Z = `ALAMREC` (#9035, same supplier, cost 0; found by pricing candidates on a scratch draft), the service product `RVC` (#5652, not stockable), and W2 = warehouse 6 CONCRETO 3 (Agregados), facility 6.

## Results

| Step | What | Verified by | Result | Deviations / notes |
|---|---|---|---|---|
| 1 | Navigation: Compras holds Solicitudes de compra, Aprobación de solicitudes, Por comprar and Órdenes de compra, in that order; `qanoaccess` sees neither new entry, and `/purchases/orders`, `/purchases/orders/{id}` and `/purchases/to-purchase` redirect home | Device (1, 1b) | Pass | none |
| 2 | Por comprar: a request with two marked lines (P, Z). The group shows its line count and estimate, Z shows "sin costo", a "Sin proveedor" group has no radio and can't be selected, paging ("1–20 de N grupos", page 2), and the Sucursal filter in the drawer shows only facility 51's groups (badge 1) | Device (2) | Pass | dev has 165 groups, so paging was exercised for real. The supplier 86 / facility 51 group also holds 8 legacy pending lines, which go into step 3's draft and come back on the cancel in step 11. |
| 3 | Crear orden is disabled until a group is selected. It creates the draft with the group's lines: P at its cost, Z at 0 with the price-0 band. On Back the group is gone (the summary counts one group fewer) | Device (3) | Pass | **Timed SC-001 (under 1 minute): manual.** |
| 4 | Nueva orden with a supplier, a date (the picker's first date is today) and notes | Device (4); live test | Pass | "Past dates are not selectable" is checked as the picker's `firstDate` = today, not by tapping a past day. |
| 5 | Change the date; clear the notes and the date; on reopen both show "—" and the API holds null | Device (5); live test (R7 raw PUT) | Pass | none |
| 6 | Add P × 2: it lands in W1 at its cost and the product's tax rate. Edit it to W2, 1.2345, 10.1234567, IVA 0 (read back exact). The dialog refuses 0 and 1.23456. Delete the line | Device (6); live test (wire strings) | Pass | none |
| 7 | Adding the request already ordered in step 3 shows `nothing_to_add` (Spanish, inline). Another approved request's line is added with "Sol. {folio}" and the SnackBar "Se agregó 1 partida." | Device (7) | Pass | The server answered `purchase_order.nothing_to_add` rather than a partial add with a "ya estaba" SnackBar; both are accepted. |
| 8 | Confirm the hand order (W1 request line, W2 line at price 0, one service line). The prompt names both warehouses and the price-0 line. After: Confirmada, Entradas lists 2 receipts (one per warehouse, none for the service line) and "Abrir" opens the receipt. On reload the Entradas section is gone (mbe-api#355). Recibido 0 / Pendiente = ordered; the service line shows "—" | Device (8); live test | Pass | none |
| 9 | Confirm the W1 receipt; reopen the order: that line shows Recibido = ordered, Pendiente 0. The receipt's "Orden de compra" links back to the order (FR-030), and so does the request detail's order column | Device (9) | Pass | The receipt is confirmed through the repository (spec 067's screen is not under test here); the order, receipt and request screens are checked in the UI. |
| 10 | Imprimir shows the PDF in the preview, titled "Orden de compra {id}". Enviar por correo suggests the supplier's contacts (none preselected). Two typed addresses (`qa080a@` / `qa080b@example.com`) and a message are added. Send shows "El correo no está configurado en el servidor." in the dialog. A draft offers neither Imprimir nor email | Device (10); live test (PDF bytes, 503) | Pass (mail off) | **Manual: the mail actually arriving with the PDF.** Mail is not configured on dev (`email.not_configured`), so no success SnackBar or delivery could be seen. **Timed SC-002 (5-line order written, confirmed, printed and emailed in under 4 minutes): manual.** |
| 11 | Cancel the Por comprar draft: Cancelada, lines kept, no actions, and its lines are back in Por comprar (API and screen). A confirmed order offers no Cancelar orden | Device (11); live test (`already_cancelled`, `confirmed_cannot_cancel`) | Pass | none |
| 12 | List: the default page is the admin's orders without cancelled (badge empty). Mostrar → Todas (badge 1), Estado = Cancelada, Proveedor (badge 2), a date range, and an order-number search each match the API page | Device (12a–12f) | Pass | The date range is set through the URL (`from`/`to`), not through the range picker chip; the filter, badge and rows are checked. |
| 13 | Rights: a user with read on 20 only can open the list and detail and gets only Imprimir. Without read on 20, the request and receipt details show the order number as plain text | Widget tests (`purchase_order_detail_screen_test.dart` "with read only on 20 there is Imprimir, not the email", "without update on 20 there are no actions"; `purchase_order_link_test.dart` "without read on 20 it is plain text") | Pass (widget) | **Manual on dev:** no seeded account holds read on 20. `qareadonly` has only products and users read (per `tool/seed_test_accounts.py`), and its rights were not changed. Needs a temporary grant of 20 read (plus 86/15 read for the link half) on a test account. |
| 14 | Concurrency: the draft is open in the app and confirmed by another session (the API); editing the header here shows "Este documento está completado o cancelado y ya no se puede editar." and the screen reloads as Confirmada | Device (14) | Pass | The "other session" is the same administrator through the API, not a second app window. |
| 15 | Largest text: the list, Por comprar and the detail stay readable | Widget test `purchase_orders_large_text_test.dart` (T035) | Pass (widget) | **Manual on a real device**, like 079. |

## Device-test runs

- Run 1: 15 of 18 passed. Steps 2 and 3 failed because Por comprar's pagination footer is the last child of a lazy `ListView`, so it isn't built until scrolled to. Step 10 failed because, on the device, a second `enterText` into the email field reached no field after "Agregar" had taken focus. Both were test-harness problems, fixed in the test: it now scrolls the list to the footer, and taps the field before typing. A widget test confirmed the app adds two typed addresses. **No app bug was found; `lib/` was not changed.**
- Run 2: 17 of 18 passed (step 10 again; the diagnostics showed the field stayed empty after typing).
- Run 3: 18 of 18 passed.

## Records left on dev

Every record carries a `QA080 …` tag. Confirmed orders and confirmed receipts can't be cancelled; everything else was cancelled.

| Run | Confirmed orders (kept) | Confirmed receipt (kept, +1 kg of P in W1) | Cancelled | Request left approved |
|---|---|---|---|---|
| probe (fixture search, by hand) | none | none | order 11076 | none |
| 1 | 11079 (hand), 11080 (step 14) | 32070 | orders 11077, 11078; receipts 32069, 32071; request 2317 | 2318 |
| 2 | 11083, 11084 | 32073 | orders 11081, 11082; receipts 32072, 32074; request 2319 | 2320 |
| 3 | 11087, 11088 | 32076 | orders 11085, 11086; receipts 32075, 32077; request 2321 | 2322 |

The requests left approved (2318, 2320, 2322) refuse cancel with `purchase_request.lines_on_live_order` because their line is on a confirmed order. That is expected.

## Manual checks still open

1. Step 3, SC-001: from Por comprar group to confirmed order in under 1 minute (timed).
2. Step 10: with mail configured, the email to the supplier's contact plus a second address arrives with the PDF, and the success SnackBar shows.
3. Step 10, SC-002: a 5-line order written, confirmed, printed and emailed in under 4 minutes (timed).
4. Step 13: on dev, with a user holding read on 20 only (none is seeded), the list and detail open with only Imprimir. Without 20 read, the request and receipt details show the order number as plain text.
5. Step 15: the largest text level on a real device.
