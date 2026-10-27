# Research: Payments Follow-ups

Phase 0 for [plan.md](./plan.md). The spec had no open clarifications. Each item below records a design decision and the code it rests on.

## R1. Regenerating the API client

**Decision**: Regenerate with `tool/generate_api_client.sh` against mbe-api `main` at `b5fb935` or later. That version includes PRs #273, #274 and #275. Then rebuild the generated package on its own:

```
(cd lib/generated/openapi && dart pub get && dart run build_runner build --delete-conflicting-outputs)
```

**Rationale**:
- The committed client (2026-10-27 03:10) has none of the three changes:
  - `CustomerPaymentResponse` has no `customer_display_name`.
  - `listCustomerPaymentsApiV1CustomerPaymentsGet` (`customer_payments_api.dart:348`) has no `search` parameter.
  - There is no ticket operation.
- The sibling checkout `../mbe-api` has all three (`app/schemas/customer_payment.py:27,101`, `app/api/v1/endpoints/customer_payments.py:59,198-202`).
- The script fetches `http://127.0.0.1:8000/openapi.json` by default, or takes a file path.

**Expected names**:
- `CustomerPaymentResponse.customerDisplayName` (`String?`).
- A `search` named parameter on `listCustomerPaymentsApiV1CustomerPaymentsGet`.
- `printCustomerPaymentTicketApiV1CustomerPaymentsCustomerPaymentIdTicketGet(customerPaymentId:)`, returning `Future<Response<Uint8List>>`.

**Traps**:
- Run the rebuild inside the generated package, not the root build_runner, because the script leaves stale `serializers.g.dart` and orphan `*.g.dart` files (memory: no-repo-wide-format).
- Format only the changed files.
- Review the generated diff. If unrelated endpoints changed since the last regeneration (mbe-api specs 029–032 merged in between), they come along, and that is expected. Nothing in `lib/` should break because of them, and `flutter analyze` must be clean.

**Alternatives considered**: Hand-patching the generated model. Rejected, because the constitution (§III) requires the generated client.

## R2. Customer name: projected first, provider as fallback

**Decision**:
- `CustomerPayment` gains `String? customerName`, mapped from `customerDisplayName`.
- `PaymentCustomerName` takes the payment's projected name. When it's non-null, the widget shows it and never watches `customerDisplayNameProvider`. When it's null, it keeps today's behavior: watch the provider, show "…" while loading, and fall back to `#id`.

**Rationale**:
- The server fills the name on every response, list and single (PR #274). It's `null` only when the customer row is missing.
- Not watching the provider at all when a name is present is what removes the per-customer requests (SC-003).
- The fallback stays for the null case and for any older server.

**Alternatives considered**: Dropping the provider entirely. Rejected, because FR-008 keeps the fallback, and a deleted customer would then show only a number with no attempt to look it up.

## R3. Customer-name search in the facility scope

**Decision**:
- `PaymentsFilter` gains `String? customerSearch`, read from `ListQuery.search` in the facility scope only. `reference` keeps reading it in the all-facilities scope.
- The repository's `list()` gains `String? search`, passed to the generated `search` parameter.
- The screen shows `CatalogSearchBar` in both scopes, with a scope-specific hint: `paymentsSearchCustomerHint` or the existing `paymentsSearchReferenceHint`.

**Rationale**:
- The search text is already in the URL as `ListQuery.search`, so FR-013 needs no new facet.
- `paymentsQueryForScope` already rebuilds the query from scratch, keeping only scope, customer and dates. It therefore already clears `search` on a mode switch (FR-012). A unit test pins that.
- One field per scope, rather than one shared `search` field, keeps each controller branch reading only what its endpoint supports, the same shape as the facility-only facets.
- `isNarrowed` must count `customerSearch`, so a search with no results shows the filtered-empty view (Story 2, scenario 5).
- `activeFilterCount` does not count it: the search box is visible, so it isn't a drawer facet (same rule as `reference`).

**Alternatives considered**:
- A single shared `searchText` field. Rejected, because the meaning would change silently between scopes.
- Putting customer-name search in the drawer. Rejected: §VI makes free-text search the search box.

## R4. Ticket as a new `DocumentKind`

**Decision**:
- Add `DocumentKind.customerPaymentTicket`.
  - Gate: `SystemObject.customerPayments` (8), read.
  - Fallback filename: `pago-%08d.pdf`.
- Add a case for it in `DocumentSourceImpl.fetch`, calling the generated ticket operation.
- Add its method name to `generated_client_bytes_test.dart`.
- Add a ref builder `paymentTicketRef(l10n, payment)`, titled with a new `documentPaymentTicketTitle(id)` key.
- Call sites use `canOpenDocument(access, DocumentKind.customerPaymentTicket)` and `documentActionsProvider.preview(context, ref)`.

**Rationale**:
- Spec 044 built a single document pipeline. Every PDF goes through `DocumentSource.fetch(DocumentRef)`, and every preview through `DocumentActions.preview`, which already:
  - dedupes double-opens (edge case "twice quickly");
  - checks the `%PDF-` magic bytes;
  - takes the filename from `Content-Disposition`;
  - shows server errors (404, 409, 5xx) through `ErrorBanner`, with retry (FR-006).
- Adding a kind is the precedent's extension point. Nothing new is built.
- The gate is the same right Pagos already requires, so FR-005 holds by construction.

**Alternatives considered**: A `printTicket` method on `CustomerPaymentRepository`. Rejected, because it would bypass the shared pipeline and duplicate its byte, filename and error handling.

## R5. Which payments show the action

**Decision**:
- Add a getter `bool get hasTicket` on `PaymentType`, true for `creditPayment` and `paymentInAdvance` only.
- Both call sites check `payment.type.hasTicket && canOpenDocument(...)`.

**Rationale**:
- The server answers 409 for every other type (PR #275).
- `PaymentType` is an exhaustive enum. An unknown wire value already throws at mapping (spec 054 R10), so an "unknown type" can never reach the screen, and the edge case is covered by construction.

## R6. Where the action sits

**Decision**:

| Where | Control | Key |
|---|---|---|
| **List row** | One `CatalogRowAction` via `buildCatalogRowActions` with `onEdit: null`, icon `Icons.receipt_long_outlined`, tooltip `paymentViewTicketTooltip`. | `payment_view_ticket_<id>` |
| **Payment view** | `OutlinedButton.icon` labelled "Ver ticket", placed in the body's action area and aligned to the end, like "Ver corte" (`cash_session_detail_screen.dart:129-148`). | `payment_view_ticket_button` |

The row tap still opens the payment view.

**Rationale**:
- §VI allows at most one direct action besides Edit, built with the shared row-actions helper. Payment rows have no Edit, because they are read-only, so the ticket is the row's only icon.
- §VI forbids app-bar actions on detail screens. "Ver corte" is the in-repo precedent.
- `pos_sales_list_screen.dart:283-310` is the row precedent, including the receipt icon.

**Alternatives considered**: A `FilledButton.tonalIcon`, as on the POS sale detail view. Rejected in favor of `OutlinedButton.icon`, matching the closer precedent: a read-only record screen in the same section (the cash-session detail).

## R7. A refused list

**Decision**:
- The payments list screen checks its page state before `CatalogListStateView`.
- When the error is `ServerError(statusCode: 403)`, it renders a local `_ListForbidden` view: an `ErrorBanner` with `paymentsListForbidden` ("No tienes permiso para ver estos pagos."), and no retry.
- Every other error still goes through `ListFailedView` with retry.

**Rationale**:
- `AppError` has no forbidden variant. A 403 arrives as `ServerError(statusCode: 403)`, and `ListFailedView` always shows Retry.
- `pos_sale_detail_view.dart:259-270` (`_isForbidden`) is the in-repo precedent for treating a 403 as "not allowed", not as a failure.
- Doing it in the screen keeps `core/widgets/` unchanged.

**Alternatives considered**: Teaching `ListFailedView` to hide retry on a 403. That would be a core-widget behavior change for every list, which is out of this spec's scope. If it's wanted, it should be a separate change.

**Detail screen**: no change. mbe-api returns 404 (not 403) for another facility's payment and its applications (PR #273), and `PaymentDetailScreen` already maps `NotFoundError` to `_NotFound` with no retry. The existing client guard in `paymentDetailProvider` stays (FR-014), so for a non-editor the server path isn't even reached. This is covered by a test, not new code.

## R8. Seeding the back-office application

**Decision**: Add `tool/seed_payment_fixtures.py`, a stdlib-only script modeled on `tool/seed_test_accounts.py`. It reads the same `.env` and logs in as `MBE_ADMIN_*`, then:

1. Looks for an existing application to a back-office order: `GET /sales-orders?origin=1&status=completed&facility=<admin facility>`, then that order's payments. If one exists, it prints it and exits. This makes the script idempotent.
2. Otherwise it picks the first completed back-office order with a balance greater than 0. It creates a `CREDIT_PAYMENT` customer payment for that order's customer, for the order's balance or 1.00, whichever is smaller, with reference `QA055-SEED`. Then it applies the payment to the order with `POST /customer-payments/{id}/applications`.
3. It prints the payment id and the order id.

**Rationale**:
- The app can't apply a payment to a back-office order yet (roadmap#26), so the data has to come from the API.
- A separate script keeps `seed_test_accounts.py` doing only accounts. Both are rerun after a database reset (TEST_ACCOUNTS.md gets a line).
- A credit payment also serves FR-021: the walkthrough needs a credit payment or advance for the ticket step, and dev-tenant counter payments are mostly `IMMEDIATE`.

**Alternatives considered**: Creating the data inside the integration test. Rejected, because the walkthrough's posture (spec 054 R13) is runtime discovery against existing data with no writes, and FR-018 asks for a rerunnable setup step.

## R9. Walkthrough changes

**Decision**: These changes go in `integration_test/payments_quickstart_test.dart`.

| Step | Change |
|---|---|
| **2b** | Drive the picker. Tap `date_range_filter_chip`, then in `DateRangePickerDialog` tap the two days and the Save label from `MaterialLocalizations`, then assert the URL facets and the narrowed rows. Clear through the chip's delete, which is "Cualquier fecha". The widget test `payments_filters_test.dart:118-140` already has the finder sequence. |
| **5b** | A missing back-office application becomes a `fail` with the reason "run tool/seed_payment_fixtures.py", no longer a `softFinding` (FR-019). |
| **New 12** | The ticket. Open a credit payment or advance (the seeded one, or any one discovered), tap `payment_view_ticket_button`, and wait for the preview dialog to render a page. Close the dialog. Open an `IMMEDIATE` payment and assert there is no ticket button. Repeat from a list row via `payment_view_ticket_<id>`. The print dialog itself isn't driven, because it's a native OS dialog. |
| **New 13** | Customer-name search. Type part of a discovered customer's name and assert that every row's customer contains it, ignoring case. |
| **9 (extended)** | As QA054, through the authenticated Dio: `GET /customer-payments/{other}` and `/{other}/applications` must be 404, `/{other}/ticket` must be 404, and `GET /customer-payments?facility=<other>` must be 403 (FR-017). The UI assertion "El pago N no existe." stays. |

**Rationale**: Each step maps to a spec FR and an issue checkbox. The skip-to-fail change is what makes SC-006 ("none skipped") checkable.
