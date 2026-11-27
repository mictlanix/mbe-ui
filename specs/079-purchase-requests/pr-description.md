## Summary

Stores can now ask for goods with a purchase request, and supervisors approve or reject them. Spec: `specs/079-purchase-requests/`.

The back office gets a new **Compras** group, between Inventario and Finanzas, with two screens.

- **Solicitudes de compra: create and submit (P1).** "Nueva solicitud" starts a draft on the user's point-of-sale warehouse, with optional notes. The user adds purchasable products; the server fills each line's name, quantity and destination. Each line's name, quantity and destination can be edited. A quantity below the product's minimum order quantity shows a Spanish warning band, which never blocks. "Enviar" gives the request its facility's next folio and makes it read-only.
- **Aprobación de solicitudes: approve and reject (P1).** The queue lists the submitted requests of every facility, oldest first, and can be filtered by facility. The supervisor:
  - approves a request with ✓ on its row or from the request's detail;
  - rejects it from the detail with a reason. It goes back to draft and keeps its folio;
  - selects several on the page and approves them together. A result dialog names any that were refused and why.
- **Find and follow (P2).** The list shows the user's own requests without cancelled ones by default. The filter drawer holds the scope (Mis solicitudes or Todas), state, facility, warehouse, requester and date range, and the folio has its own search box. An approved request shows who approved it and when. A line already on a purchase order shows that order's number and state.
- **Correct and resubmit (P2).** A rejected request is a draft with its folio. Its requester edits it ("Editar encabezado" keeps a numbered request's warehouse within its facility) and submits it again under the same folio.
- **Mark lines (P3).** On a submitted or approved request, purchasing unmarks or re-marks lines for purchase with the "Comprar" checkbox.
- **Cancel (P3).** A draft, submitted or approved request can be cancelled, unless a line is on a live purchase order.

**Gates mirror the server.**
- **Requests (PurchaseRequest, 86):** read to see them, create to start one, update to edit and submit, delete to cancel.
- **Approval (PurchaseRequestApproval, 96):** read for the queue, update to approve and reject.
- **Marking lines:** update on PurchasesOrders (20).
- **Approvers without read on 86:** opening a request needs read on 86, so an approver without it can see the queue and approve requests there, but can't open or reject one (spec clarification 1).
- **Other facilities:** a non-administrator doesn't see edit, line, submit or cancel actions on another facility's request.

Anything a user can't use is absent, not disabled. The one exception is "Aprobar seleccionadas", which is disabled while nothing is selected.

**Where this changes existing code.**
- **Navigation and router:** a new `purchases` group, branches 38 and 39, a top-level detail route, and two route gates.
- **Error messages:** 11 codes get messages in both languages: the 10 `purchase_request.*` codes and `product.not_purchasable`. Spec 058's `code-scope.tsv` marks them `IN`, and the coverage test's count goes from 214 to 225.
- **Shared code reused, not changed:**
  - inventory's name cells and warehouse options (`inventory/presentation/shared/`);
  - the sales payments filter's date helpers, which invoicing already reuses.
  - This is recorded in `plan.md`, Complexity Tracking.
- **`DataTableView` is unchanged.** The queue's checkboxes are a column the screen builds through the existing `DataTableColumn.header`. Unlike advanced search's checkbox, they are live controls, because a row tap opens the request; a test checks that tapping one doesn't navigate.

**Known limits.**
- **The rejection reason isn't shown.** The server writes it only to its incidence log, which the client can't read, so a rejected request is back in draft with no explanation. Filed as mbe-api#352.
- **The order number on a line is plain text.** It becomes a link when the purchase-orders screen ships (mbe-roadmap#71).
- **Names come from per-id lookups,** because the list rows carry ids only. Without read on employees, the requester shows as "#id".

## Roadmap

Closes mictlanix/mbe-roadmap#69

Upstream: mbe-api#352 (latest rejection reason on the request), not blocking.

## Test plan

- [x] `flutter analyze`: no issues.
- [x] `flutter test` (whole suite, no `.env` defines): 7123 passed, 85 skipped, 8 failed. All 8 failures are goldens in `test/golden/` (core widgets and the Casa Maestra header), the known environment pixel diffs that also fail on `main` (mbe-ui#209). This branch changes no shared widget, design token or theme file, and adds l10n keys without changing existing ones.
- [x] `dart format` on the 51 changed or new Dart files: no changes. Nothing under `lib/generated/` changed.
- [x] New tests:
  - unit: below-minimum, repository, filter, list, detail and queue controllers, actions, availability, selection;
  - widget: list, detail, queue, every dialog, the band, the status chip, largest text;
  - new cases in the router, navigation and error-catalog tests.
- [x] Live repository test `test/integration/purchase_requests_live_test.dart` against dev, with `MBE_WRITE=true`: 32 steps, none failed. Every error code and its params matched `contracts/error-messages.md`. What it found:
  - **Clearing the notes** with `""` works.
  - **Quantities** go out as strings and come back with 2 decimals.
  - **The default scope** shows only the user's own non-cancelled requests; `status=cancelled` shows their cancelled ones.
- [x] Device walkthrough `integration_test/purchase_requests_quickstart_test.dart` on macOS against dev: quickstart steps 1–11 pass, including the no-access check (no Compras group, both routes redirect home).
- [x] Largest text level: the list, a submitted request with every action, a draft and the queue show no overflow.
- [ ] Not verified live:
  - **Below the minimum:** no purchasable product on dev has a minimum order quantity above 1, so the warning band and the "quantity = minimum" default are covered only by unit and widget tests. Setting a minimum on one dev product would let the live tests cover them.
  - **Another facility's request (quickstart step 12):** needs a seeded non-administrator with rights on 86; none exists.
  - **Approvers without read on 86 (step 13):** not checked live. Both 12 and 13 are covered by the availability and queue widget tests.
- [ ] Manual: the timed checks for SC-001 (10 products in 3 minutes) and SC-002 (20 requests in 1 minute), and the screens on a real device at the largest text size.
- Dev tenant: the live and device runs left requests #2294–#2314, all cancelled. The device run's notes start with "QA079 ".

🤖 Generated with [Claude Code](https://claude.com/claude-code)
