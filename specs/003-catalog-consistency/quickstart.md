# Quickstart: Validating Catalog Screen Consistency

End-to-end validation steps for the acceptance scenarios in
[spec.md](./spec.md). Run against a real mbe-api instance — no mocked/
offline mode (constitution §VII).

## Prerequisites

1. **mbe-api running locally**:
   ```bash
   cd ../mbe-api
   uv run uvicorn app.main:app --reload
   ```
2. **A signed-in mbe-ui session** for two account profiles:
   - An administrator (full Create/View/Edit/Delete on both Users and
     Products).
   - A non-admin account with only `SystemObject.users`/
     `SystemObject.products` Read (no Update/Delete privilege row) — to
     confirm Edit/Delete are omitted while View remains (FR-012).
3. **At least 25 existing users and 25 existing products** in mbe-api's
   database (more than one page at the fixed page size of 20) so
   pagination (FR-002, User Story 1) is exercisable without depending on
   create working first.

## Setup (mbe-ui)

```bash
flutter pub get   # picks up the new data_table_2 dependency
dart run build_runner build --delete-conflicting-outputs
```

## Run

```bash
flutter run -d chrome   # or any Expanded-tier target
```

## Validation steps

1. **Users search + pagination (User Story 1)**
   - Open `/users`. Confirm a bounded first page (≤20 rows) renders with
     page-navigation controls.
   - Type a partial username into the search box; confirm the list does
     **not** change yet. Press Enter (or click the search icon button);
     confirm only matching users are now shown.
   - Navigate to page 2; confirm different users are shown and the page
     control reflects the new page.
   - Clear the search; confirm the full paginated list returns.

2. **Consistent row actions (User Story 2)**
   - As the administrator, open `/users` and `/products` in turn. Confirm
     each row's trailing columns show the same View/Edit/Delete icons in
     the same left-to-right order (contracts/catalog-action-icons.md), and
     the toolbar's Create icon matches between both screens.
   - Sign in as the Read-only account. Reopen both catalogs; confirm Edit
     and Delete icons are absent from every row (not present-but-disabled)
     while View remains and the toolbar's Create icon is also absent.
   - Click View on any row; confirm it opens the same form Edit would,
     but with all fields disabled/read-only.

3. **Frozen identity column (User Story 3)**
   - On `/products`, resize the window narrow enough (or zoom in) to force
     horizontal scrolling. Scroll right; confirm the product code column
     stays pinned at the left edge.
   - Repeat on `/users`, confirming the username column stays pinned.

4. **Single-row filters at Expanded width (User Story 4)**
   - With the window at desktop width (≥ `LayoutBreakpoints.expanded`,
     840px), confirm `/products`' search box and facet filter chips sit on
     one row.
   - Resize the window narrower than 840px; confirm the filter controls
     are still all reachable (wrapping to additional rows is acceptable
     below this width).

## Expected outcome

All four user stories' acceptance scenarios in spec.md pass; in
particular, no network request fires from the search box until Enter or
the search button is used (inspect the browser/devtools network panel
while typing to confirm zero requests per keystroke).
