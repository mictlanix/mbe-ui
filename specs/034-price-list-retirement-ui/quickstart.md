# Quickstart: validating the Price List Retirement UI

**Feature**: `034-price-list-retirement-ui` | **Date**: 2026-08-30

How to prove the feature works. *What* to build is in [plan.md](./plan.md),
[research.md](./research.md), [data-model.md](./data-model.md) and
[contracts/](./contracts/).

---

## Prerequisites

- Flutter stable; mbe-api reachable (default `http://127.0.0.1:8000`, override
  with `--dart-define=API_BASE_URL=…`), running a build that includes
  `015-price-list-retirement` (PR #186, merged). Verify with:

  ```bash
  curl -s localhost:8000/openapi.json | python3 -c \
    "import json,sys; print('/api/v1/price-lists/{price_list_id}/delete/preview' in json.load(sys.stdin)['paths'])"
  ```

  `False` means the backend predates the feature and nothing below will pass.

- **Two accounts**: one with `PRICE_LISTS` delete, one without — the
  "Delete is absent, not disabled" guarantee (FR-021) cannot be tested with one.
  Credentials live in `.env` (gitignored).

- **Four price lists**, because four of the seven dialog states are data shapes,
  not error injections:

  | List | Shape | Exercises |
  |---|---|---|
  | A | prices, no customers | priced |
  | B | prices **and** customers | assigned |
  | C | nothing at all | clean |
  | D | any list, plus a spare to move customers onto | the replacement target |

  **Every one of these is consumed by the test that deletes it.** Have a way to
  recreate them — the manual pass is not repeatable against a database it just
  retired.

- **The blocked state needs a non-price, non-customer reference** — a sales order
  on a price list is the realistic one. If the dev tenant has no such data, that
  state is covered by the widget test alone; say so in the report rather than
  claiming a live check that did not happen.

## Automated

```bash
flutter analyze
dart run build_runner build --delete-conflicting-outputs   # freezed / riverpod
flutter test                                               # unit + widget
flutter test integration_test/ -d chrome                   # live mbe-api
```

New/changed suites:

| Suite | Proves |
|---|---|
| `test/unit/features/pricing/price_list_delete_preview_test.dart` | all three fates by **whole key** (research R2), incl. an invented future key; `isBlocked`; `movedCount`/`destroyedCount`; the empty preview |
| `test/unit/features/pricing/price_list_repository_impl_test.dart` | preview mapping and order preserved; `replacement` reaching the query and being omitted when null; 409 → `ServerError(409, detail)` with the sentence intact |
| `test/unit/features/pricing/price_list_form_controller_test.dart` | `delete({replacement})` returns true/false; error and `errorDetail` retained on refusal; RBAC denial without a request |
| `test/unit/core/formatting/app_formatters_display_test.dart` | `display.count` groups per locale — `4312` → `4,312` (en) / `4.312` (es-MX) |
| `test/widget/features/pricing/price_list_delete_summary_test.dart` | three fate notes; unlabelled category humanized, never dropped; the **server's** total rendered, not a re-sum; the customers row navigates |
| `test/widget/features/pricing/price_list_delete_dialog_test.dart` | all seven states of contracts §2, and each gate in §4 independently |
| `test/widget/features/pricing/price_list_detail_screen_test.dart` | Delete opens the review dialog; absent without the privilege |
| `test/integration/price_list_retirement_flow_test.dart` | golden path: preview → replacement → acknowledge → 204 → customers moved |
| `test/unit/core/l10n_parity_test.dart` | every new key in both locales (no code change; it must simply still pass) |
| `test/unit/core/formatting_guard_test.dart` | no new `package:intl` importer — the guard must pass **without** an allowlist edit |

The last two are the ones a wrong implementation trips. If either fails, the fix
is in the feature, not in the guard.

## Manual — the happy path (US1, US2, US3)

Signed in as the delete-capable account.

1. `/price-lists` → open **A** → Edit → **Delete**.
   The dialog opens with a loading panel, then the breakdown: *Product prices*
   marked "deleted permanently", the count grouped (`4,312`, not `4312`), a
   total, and the caption "records this deletion touches".
2. The confirm button reads **Delete list and 4,312 prices** and is **disabled**.
   Tick the acknowledgment → it enables. Untick → it disables again.
3. Cancel. `/price-lists` still shows A — nothing was sent.
4. Open **B** → Delete. Now there is a *Customers* row marked "moved to the
   replacement" and a **required** replacement picker. The confirm button stays
   disabled with the acknowledgment ticked but no replacement chosen.
5. Open the picker and search. **B itself is not offered.** Choose **D**.
   The helper line becomes "All 12 customers move to D."
6. Confirm. Progress shows; Cancel is inert. On success: back on `/price-lists`,
   B is gone, and a snackbar reads "Price list deleted. 12 customers moved to D."
7. `/customers?priceList=<D>` → the 12 customers are there.
8. Open **C** → Delete. A plain confirmation: "No prices and no customers depend
   on this list." No breakdown, no picker, **no acknowledgment**, and the button
   reads just "Delete list".

## Manual — the customers link (FR-006)

9. Open **B** (recreated) → Delete → click the customers row's link.
   The dialog closes and `/customers?priceList=<B>` lists exactly those
   customers. Going back does **not** resurrect a half-filled dialog.

## Manual — refusals (US4, US5)

10. **Blocked**: open a list a sales order points at → Delete.
    The banner says the list cannot be deleted; the offending row is marked
    "blocks deletion"; there is **no** destructive button, only Close. Confirm
    from the network panel that **no `DELETE` was sent**.
11. **Degraded**: block `…/delete/preview` in devtools → Delete.
    The dialog says the dependencies could not be loaded, offers the replacement
    picker as *optional*, and still allows a confirm.
12. **Refused**: with the preview blocked, confirm on a list that does have
    customers. The server's own sentence — "Still referenced by
    customer.price_list (12) — remove those records first" — appears in the
    banner, the dialog **stays open**, any chosen replacement is **still
    selected**, and the list survives.

## Manual — RBAC and i18n

13. Sign in as the account **without** `PRICE_LISTS` delete → open any list in
    Edit. The Delete button is **absent**, not greyed out.
14. Switch the app to Spanish and repeat steps 1, 4 and 10. Every line is
    translated; no `[key]` fallback anywhere; counts group as `4.312`.
15. Set the largest text size (user settings) and reopen the dialog on **B** —
    the constitution §V check: nothing clips, and the breakdown still reads.

## What "done" looks like

Every automated suite green, steps 1–9 and 13–15 verified live, and 10–12
verified live or explicitly reported as widget-test-only where the dev tenant
could not produce the data.
