## Summary

Four follow-ups to Pagos (spec 054), now that mbe-api has shipped what they waited for. Spec: `specs/055-payments-followups/`.

- **Payment ticket (#227).** "Ver ticket" on the payment view, and a receipt icon on list rows in both scopes, for credit payments and advances only. It opens the shared document preview (spec 044), where the user prints or downloads. Every other type is absent rather than disabled, because the server answers 409 for them. Gated by Customer Payments read. Adds `DocumentKind.customerPaymentTicket` (`GET /customer-payments/{id}/ticket`).
- **Customer names and search (#223).** Payments carry the server's `customer_display_name`, so a page shows every name on first render with no per-customer request. The old lookup stays only as the fallback for a missing name. The facility scope gets a customer-name search box (`?search=`); the all-facilities scope keeps its reference search, and each box's hint says which it is. Switching scope clears the text.
- **Facility checks (#224).** The client guards stay as defence in depth. If the server refuses the list (403), it now shows "No tienes permiso para ver estos pagos." with no retry, instead of the generic error. The detail already mapped the server's 404 to "El pago N no existe.", and a test now pins that it has no retry.
- **Walkthrough coverage (#225).** `tool/seed_payment_fixtures.py` creates, idempotently, a credit payment applied to a completed back-office order on the dev tenant. The walkthrough now picks dates through the picker dialog, fails instead of skipping when the back-office data is missing, opens the ticket from the view and the row, searches by customer name, and checks as QA054 that the server refuses another facility's payment, applications, ticket (404) and list (403).

**Table layout, every list.** The shared `DataTableView` now uses 24 px between columns (was data_table_2's default 56) and sizes the row-icon column to the most icons a shown row has (was a fixed 150 px). On Pagos this keeps dates and amounts on one line at desktop width. In the payments list the Verified column is now an icon (a verified badge, or a grey circle) with the label as tooltip; the chip's text was being clipped. The payment view keeps its chip.

Also: the API client is regenerated against mbe-api `b5fb935` (PRs #273, #274, #275). Only the customer-payments API, its response model and the generated README changed; no unrelated endpoints came along.

## Roadmap

No roadmap plan issue: these are follow-ups to spec 054 (mictlanix/mbe-roadmap#25, already closed).

Closes #223
Closes #224
Closes #225
Closes #227

Related: mictlanix/mbe-api#276. The server's "Sin aplicar" doesn't subtract change handed back, while the ticket's balance does (for example payment 300789: ticket 0, `unapplied` 70). Pagos shows the server's figure as it comes until that's settled.

## Test plan

- [x] `flutter analyze`: no issues.
- [x] `flutter test`: 3742 passed. 7 failed, all goldens and screenshots (`test/golden/core_widgets_golden_test.dart`, one in `test/screenshots/pos_screens_screenshot_test.dart`); the same 7 fail on unmodified `main`, so they predate this branch (CI-only goldens, mbe-ui#209).
- [x] `python3 tool/seed_payment_fixtures.py`, run twice on the dev tenant: the first run seeded payment 300834 on back-office order 344062; the second wrote nothing.
- [x] Walkthrough `integration_test/payments_quickstart_test.dart` on macOS against the dev tenant: 22 of 22 steps PASS, none skipped, including a real-font check that dates and amounts stay on one line at 1680 px.
- [ ] Manual check at Expanded and phone widths (T039), timing SC-001 (ticket in three actions or fewer) and SC-004 (customer search in under 15 s).
- [ ] Physical thermal printer and phone browsers: tracked in #185.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
