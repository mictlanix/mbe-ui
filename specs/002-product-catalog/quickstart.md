# Quickstart: Validating Product Catalog (Products CRUD)

End-to-end validation steps for the acceptance scenarios in
[spec.md](./spec.md). Run against a real mbe-api instance — this feature has
no mocked/offline mode (constitution §VII).

## Prerequisites

1. **mbe-api running locally**, per its `README.md`:
   ```bash
   cd ../mbe-api
   uv run uvicorn app.main:app --reload
   ```
   Confirms `products` paths at `http://127.0.0.1:8000/openapi.json`
   (contracts/mbe-api-products.md).
2. **A signed-in mbe-ui session** (this feature builds on
   specs/001-user-authentication) for three account profiles:
   - An account with `SystemObject.products` Create/Update/Delete (full
     CRUD) — e.g. an administrator, or a non-admin with that privilege row.
   - An account with `SystemObject.products` Read only — to validate
     FR-013.
   - An account with no `SystemObject.products` privilege row at all — to
     validate FR-012/SC-004 (deny-by-default).
3. **At least one existing product** in mbe-api's database with a known
   `code` and `name`, to validate search (User Story 1) without depending
   on create working first.

## Setup (mbe-ui)

```bash
flutter pub get

# Re-confirm the OpenAPI client is current against the running mbe-api
# (research.md §3):
./tool/generate_api_client.sh http://127.0.0.1:8000/openapi.json

dart run build_runner build --delete-conflicting-outputs
```

## Run

```bash
flutter run -d chrome      # or -d macos / -d windows / -d linux
```

## Validation scenarios

### Story 1 — Browse and find products (P1)

1. **Exact code search** (Acceptance Scenario 1, SC-001): sign in with any
   `products` Read account, go to `/products`, type the known product's
   exact code. Expect: that product appears within ~10s of typing.
2. **Partial name/brand/model search** (Acceptance Scenario 2): type a
   partial name. Expect: all matching products appear.
3. **Active-only filter** (Acceptance Scenario 3, FR-002): deactivate a
   product first (Story 4), then apply the "active only" filter. Expect: it
   disappears from the filtered list.
4. **Deny-by-default** (Acceptance Scenario 4, FR-012, SC-004): sign in with
   the no-privilege account, attempt to navigate to `/products`. Expect:
   access denied / redirected, no product data shown.

### Story 2 — Create a new product (P1)

1. **Valid create** (Acceptance Scenario 1, SC-002): sign in with the full-
   CRUD account, open the create form, submit a unique `code`, a `name` ≥4
   chars, and a `unitOfMeasurement`. Expect: product appears in `/products`
   as active within seconds.
2. **Duplicate code** (Acceptance Scenario 2, FR-004): submit a `code` that
   already exists (try both an active and a previously-deactivated
   product's code). Expect: rejected with a clear message, no new row
   created.
3. **Invalid name/required field** (Acceptance Scenario 3, FR-006, SC-003):
   submit a 3-character name. Expect: blocked client-side before any
   network call, field highlighted.
4. **Invalid barcode** (Acceptance Scenario 4, FR-007): enter a 10-digit
   barcode. Expect: rejected; then clear the field entirely and resubmit.
   Expect: accepted (empty is valid).
5. **No create privilege** (Acceptance Scenario 5, FR-012): sign in with the
   Read-only account. Expect: no "create product" action visible anywhere
   in the UI.

### Story 3 — Edit an existing product (P2)

1. **Valid edit** (Acceptance Scenario 1): open an existing product with the
   full-CRUD account, change its `name` and `price`-related field
   (`taxRate` or a `ProductPrice` row if exposed read-only — price *list*
   values themselves are read-only per data-model.md), save. Expect: change
   reflected in both detail and list views immediately.
2. **Duplicate code on edit** (Acceptance Scenario 2, FR-004): change the
   `code` to another existing product's code. Expect: rejected with a clear
   message.
3. **Read-only view** (Acceptance Scenario 3, FR-013): open the same product
   with the Read-only account. Expect: all fields visible, none editable,
   no Save action.

### Story 4 — Deactivate a product (P2)

1. **Deactivate** (Acceptance Scenario 1, FR-010, FR-011, SC-005): with the
   full-CRUD account, deactivate a product. Expect: it disappears from the
   default (active-only) `/products` list on the next refresh and is not
   selectable in any "add to order" picker elsewhere (if such a picker
   exists yet in another feature — otherwise this part is N/A until that
   feature exists).
2. **Include-disabled filter** (Acceptance Scenario 2): with the
   "include disabled" filter on, search for the same product. Expect: it
   still appears, visibly marked inactive.
3. **Historical integrity** (Acceptance Scenario 3): if any historical
   record referencing this product exists from another feature, confirm its
   display is unaffected (N/A until a consuming feature exists — otherwise
   confirm the product detail screen itself still renders correctly for a
   deactivated product).
4. **No delete privilege** (Acceptance Scenario 4, FR-012): sign in with the
   Read-only account, open a product. Expect: no Deactivate action visible.

## Out of scope reminders (do not test as failures)

- Photo upload, SAT product-key picker, default-supplier picker, price-list
  *value* editing, label assignment editing, and the merge-duplicates
  feature are explicitly out of scope (spec.md Assumptions) — absence of UI
  for these is expected, not a bug.
