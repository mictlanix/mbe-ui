# Quickstart — Manual Validation: Faceted Label Filtering

Validates the feature end-to-end per user story. **Prerequisite**: mbe-api#78 (`GET /api/v1/products/labels/facets`) is deployed on the target mbe-api and the mbe-ui client has been regenerated (`tool/generate_api_client.sh`).

## Setup

1. Point mbe-ui at an mbe-api that has #78 and some products with overlapping labels. Suggested fixture:
   - `P1` → labels `{Trupper, DeWalt}`
   - `P2` → labels `{Trupper}`
   - `P3` → labels `{Makita}`
2. Log in as a user with `products` **Read** privilege.
3. Open the products list and click the **Filters** (tune) button to open the drawer.

## US1 — Narrow by combining labels (P1)

1. In the drawer, select **Trupper**.
   - **Expect**: list shows `P1` and `P2` (both carry Trupper); `P3` gone.
2. Also select **DeWalt**.
   - **Expect**: list shows only `P1` (carries both). This confirms AND narrowing (already server-side).
3. Deselect **DeWalt**.
   - **Expect**: list broadens back to `P1` + `P2`.

## US2 — See which labels still narrow (P2)

1. With no filters, open the drawer.
   - **Expect**: every label that appears on any product is enabled; a label carried by no product is disabled.
2. Select **Trupper**.
   - **Expect**: **DeWalt** stays enabled (P1 has Trupper+DeWalt); **Makita** becomes **disabled/greyed** (no Trupper product has Makita). Trupper stays selected and interactive.
3. Select **DeWalt** (now only `P1`).
   - **Expect**: any label not on `P1` is disabled; `P1`'s labels remain enabled.
4. Edit the search box (e.g. type a term that excludes `P1`) and submit.
   - **Expect**: label enabled/disabled states recompute for the new result set.

## US3 — Recover & reset (P3)

1. From the narrowed state (Trupper + DeWalt), deselect **DeWalt**.
   - **Expect**: **Makita** stays disabled (still no Trupper+Makita product) but any label co-occurring with Trupper re-enables; list broadens.
2. Press **Clear all**.
   - **Expect**: all label selections clear; every label present in the (otherwise-filtered) catalog is enabled again; the active-filter badge drops accordingly.

## Fail-open (FR-010)

1. Simulate the facets endpoint failing or being slow (e.g. block the request / point at an mbe-api without #78 in a dev build).
   - **Expect**: all label chips remain **selectable** (no stuck-disabled chips); applying a label still filters the list normally. The drawer never blocks filtering on a facet failure.

## Success criteria checkpoints

- No enabled label, when selected, yields an empty list (SC-002).
- Combining N labels returns exactly the products carrying all N (SC-003).
- Chip states refresh within ~1s of a filter change (SC-004).
- Deselect / Clear all re-enable applicable labels in one interaction (SC-005).
- Facet failure degrades gracefully to all-enabled (SC-006).
