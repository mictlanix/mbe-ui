# Delivery order approval ("Aprobación de entregas")

## Summary

When the server requires approval, confirming a delivery order leaves it in Pendiente de aprobación, and until now nothing in the new app could move it on. This PR adds the supervisor's approval queue and the two decisions.

- **Queue** in the Logística nav group, right after Órdenes de entrega. It lists the orders waiting for approval at the user's facility (the server scopes it), with folio, customer, type, scheduled date, ship-to, sales orders and priority. There's no filter row, because the server takes only paging for this list.
- **Approve** from a row's ✓ icon. A delivery moves to En preparación, a pickup to Aprobada. The confirmation names where the order goes next, and the message after it names the status the server returned.
- **Reject** from a row's ✕ icon, with a required reason (up to 500 characters). The order goes back to Borrador, and spec 061's detail screen already shows the reason and the history line.
- **Detail screen:** tapping a row opens the spec 061 order screen, which now offers Rechazar and Aprobar on a pending order too.

Spec: `specs/062-delivery-order-approval/` (spec, wireframes, plan, research R1–R12, contracts C1–C9, tasks).

## Roadmap

Closes mictlanix/mbe-roadmap#39

## Open question before go-live

Approval is a server-wide setting, `DELIVERY_ORDER_APPROVAL_REQUIRED`, which defaults to `false`. With it off, confirm skips approval and this queue is always empty. That is correct, but it looks like a dead screen. **Does production turn it on?** That decision is outside this PR.

## Rights

| Right | What it gives |
|---|---|
| Delivery Order Approval (94) read | The nav entry and the queue |
| Delivery Order Approval (94) update | ✓ and ✕ on rows; Rechazar and Aprobar on the detail screen |
| Delivery Orders (71) read | A row tap opens the order. Without it, rows aren't tappable and the approver decides from the row (Clarification Q1). |

This amends spec 061 SC-006 and FR-011 for these two actions: an approver without Delivery Orders update sees Rechazar and Aprobar on the detail screen. Spec 061's own actions still need that right.

## Also in this PR

- **Detail screen gating.** `_actionButtons` now checks rights per button instead of returning nothing without Delivery Orders update. Every existing rights combination renders exactly as before, and spec 061's action-matrix test passes unchanged.
- **Every delivery-order write refreshes the queue.** `DeliveryOrderActions` invalidates the approval queue too, so cancelling a pending order in Órdenes de entrega takes it out of the queue.
- **One error code localized:** `delivery_order.not_pending_approval`. `code-scope.tsv` is updated, and the `IN` count pinned in `catalog_coverage_test` goes from 109 to 110.

## Tests

- `flutter analyze`: no issues.
- `flutter test`: 4,596 passed, 76 skipped, 7 failed. All 7 also fail on main without this change (six `core_widgets_golden_test` goldens and the `pos_screens_screenshot_test` sales list). They are platform-rendering tests, tracked with the goldens in #209.
- New unit and widget tests cover:
  - the repository's three methods;
  - queue paging and the step back when an action empties the last page;
  - write invalidation, including the queue for every existing action;
  - both dialogs (busy, refusal kept in the dialog, unknown result after a lost connection, 500-character cap);
  - the queue screen (rights, no facility, empty, 403, `#id` name fallback, row tap with and without Delivery Orders read);
  - an approval rights matrix on the detail screen (every status × 71 update × 94 update);
  - the nav entry and the route gate.
- Live (`integration_test/delivery_order_approval_quickstart_test.dart`, macOS, local mbe-api):
  - read-only: 2 of 2 passed (nav entry, queue matches the API);
  - with `MBE_WRITE=true` and `DELIVERY_ORDER_APPROVAL_REQUIRED=true`: 6 of 6 passed. Two confirmed drafts landed in Pendiente de aprobación. The delivery was approved from its row (En preparación). The pickup was rejected from its row with a reason (Borrador, reason stored and in the history), then re-confirmed (the reason cleared), opened by a row tap and approved on its detail screen (Aprobada).

  The write run left delivery order 30242 (En preparación), pickup order 30243 (Aprobada) and sales 344217 and 344218 on the local tenant. An earlier run with approval still off left orders 30240 and 30241 and sales 344215 and 344216. A step that can't run because approval is off reports SKIP, never PASS.

## Manual checks (quickstart.md)

**Not run yet**; tracked in #244:

- Step 8: a stale action from a second window. The widget tests cover the refusal.
- Step 9: a user with approval read only, and one without Delivery Orders read. Widget tests cover both.
- Step 11: the compact tier and the largest text size.
- SC-001 (review and approve one order in under 30 seconds) and SC-002 (clear 20 without leaving the screen).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
