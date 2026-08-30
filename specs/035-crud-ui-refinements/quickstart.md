# Quickstart: validating CRUD UI Refinements

**Feature**: 035-crud-ui-refinements

How to prove this feature works. Automated checks first; the visual and navigational changes need
a real run, because a golden that was regenerated to match a bug still passes.

---

## Prerequisites

- A live mbe-api reachable with the credentials in `.env` (see `test/integration/TEST_ACCOUNTS.md`).
- At least one catalog seeded with **both** active and inactive records — otherwise the default
  filter is indistinguishable from no filter. Customers or vehicles are good candidates.
- A facility with a warehouse, a point of sale and a cash drawer, for the facility-card checks.

---

## Automated

```bash
flutter analyze
flutter test
```

Both must be clean (SC-009).

```bash
flutter test test/golden
```

**Expect failures on the first run.** The card outline, the clipped corners and the filter-bar
inset all change rendered output, so `core_widgets_golden_test.dart` and any list-screen golden
will diverge. Regenerate only after confirming each diff visually shows the intended change:

```bash
flutter test test/golden --update-goldens
```

Review the regenerated images before committing. A golden accepted without looking at it is how a
styling bug becomes the reference.

---

## Manual — run the app

```bash
flutter run -d macos     # or: -d chrome
```

### Default Active filter (US1)

1. Open **Customers** with no query string. Only active customers listed; the total reflects only
   active ones.
2. Open the filter panel — **Active** is the selected chip, not "All".
3. The filters button indicates a filter is applied.
4. Choose **All** — inactive and archived appear, and the address gains `status=all`.
5. Page forward, then reload the browser. Still "All", still on that page.
6. Paste a `?status=inactive` link into a fresh tab — inactive only, default not reapplied.
7. Repeat 1–3 for the other nine: users, user profiles, employees, facilities, vehicles, vehicle
   operators, products, payment method options, pricing grid.
8. Open **POS sales**, **Sales orders** and **Cash sessions**. Their filtering must be **exactly as
   before** — every state shown, no default applied (FR-007). This is a regression check, not a
   feature check.

### Search always refreshes (US2)

1. On any list, search a term that returns rows.
2. In a second window (or via the API directly), rename one of those records.
3. Back in the app, press the search button **without touching the term**. The new name appears.
4. Go to page 2, apply a status filter, then press search unchanged — still page 2, filter intact.
5. Type into the field without submitting. Watch the network panel: no request.
6. Change the term and submit. Exactly one request.

### List surface (US3)

1. On any list, confirm the search box's left edge and the filter button's right edge line up with
   the table's left and right edges. Check at a narrow window and a maximised one — the inset
   changes tier, the alignment must not.
2. All four table corners rounded; the header band does not square off the top two.
3. A hairline outline bounds the table, visible in **both** light and dark themes.
4. Filter to a term matching nothing — the outline and corners still frame the empty table.
5. Check an unpaginated table (the pricing grid) looks identical to a paginated one.

### Facility cards (US4)

1. Open **Facilities**. Each facility card and each warehouse / point-of-sale / cash-drawer row
   carries the same outline as the tables.
2. Hover a card and a child row — the hover state is still clearly distinguishable.

### Records in a panel (US5)

For each of the 14 entities — price lists, suppliers, labels, employees, customers, taxpayer
recipients, expenses, vehicles, vehicle operators, warehouses, points of sale, cash drawers,
exchange rates, payment method options:

1. Scroll to page 2 of the list and apply a filter. Click a row.
2. The record opens in a panel **over the list**; the list is still behind it, still on page 2.
3. The form is read-only. On a maximised window it renders in **two columns**, not one.
4. Press **Edit** — same form, now editable. As a user without update rights, no Edit control.
5. Change a field, then click outside the panel. You are warned before losing the edit.
6. Save. Panel closes, the row shows the new value, still page 2, filter intact.
7. Open it again, press **Delete**, confirm. Panel closes, row gone, page and filter intact.
8. Press **New**, fill it, save. Panel closes, list updated.
9. Warehouses / points of sale / cash drawers: open from the **facility card** — the panel opens
   without leaving the Facilities screen.
10. Customers: inside the panel, add an address and a contact inline. Both work and return you to
    the customer form.

### Removed routes

1. Navigate directly to `/labels/1` and to `/labels/new`. Both land on the labels list, not an
   error page.
2. Confirm `/products/1`, `/facilities/1` and `/taxpayer-issuers/1` still open their full screens
   (FR-036) — this feature must not have touched them.

---

## Definition of done

- `flutter analyze` and `flutter test` clean.
- Goldens regenerated deliberately, each diff reviewed.
- Every manual section above passes.
- `.specify/memory/constitution.md` is at 1.13.0 with §VI re-expressed in terms of a record's
  surface (FR-037).
