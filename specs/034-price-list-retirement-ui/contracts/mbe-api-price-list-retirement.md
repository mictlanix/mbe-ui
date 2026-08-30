# Contract: what mbe-ui consumes from price list retirement

Consumption side of mbe-api's
`specs/015-price-list-retirement/contracts/price-list-retirement.md` (issue #181,
PR #186). That document is authoritative; this one records only what mbe-ui
relies on, and what it must not.

Both endpoints are already in the checked-in generated client — no codegen run
is part of this feature (research R1).

---

## 1. `GET /api/v1/price-lists/{price_list_id}/delete/preview`

**Generated**: `PriceListsApi.previewPriceListDeleteApiV1PriceListsPriceListIdDeletePreviewGet({required int priceListId})`
→ `Response<PriceListDeletePreviewResponse>`

```json
{
  "items": [
    { "category": "product_price.list", "count": 4312 },
    { "category": "customer.price_list", "count": 12 }
  ],
  "total": 4324
}
```

**Mapped to** `PriceListDeletePreview` (data-model §1.1).

**Relied on**:

- `items` arrives **largest count first**. mbe-ui renders that order and never re-sorts.
- `total` is the server's sum. Rendered as-is; mbe-ui never re-sums `items`.
- `category` is a stable `table.column` string, the same label the `409` uses.
- An empty `items` with `total: 0` means nothing references the list.

**Not relied on**:

- The *set* of categories. Two are known; anything else is a blocker by
  construction (research R2), so a third category appearing needs no mbe-ui
  release.
- Any ordering guarantee beyond largest-first — in particular, that
  `product_price.list` precedes `customer.price_list`. Rows are looked up by key.
- Any customer or product identity. The report carries counts only; there is no
  endpoint enumerating the affected customers, which is why FR-006 links to the
  existing filtered customers list instead of listing them.

**Failure**: any non-200 is the FR-020 degraded state. mbe-ui does not
distinguish a 404 from a network failure here — either way the report is
unavailable and the deletion may still be attempted.

---

## 2. `DELETE /api/v1/price-lists/{price_list_id}[?replacement={id}]`

**Generated**: `PriceListsApi.deletePriceListApiV1PriceListsPriceListIdDelete({required int priceListId, int? replacement})`
→ `Response<void>`, 204 on success.

**Relied on**:

- `replacement` is a **query** parameter, omitted entirely when null. The
  generated method already builds it that way, so omitting it preserves exactly
  today's behaviour for a list with no customers.
- 204 guarantees the list is gone, its prices are gone, every customer that was
  on it is on `replacement`, and nothing still references it.
- Every refusal is all-or-nothing. mbe-ui therefore does **no** compensating
  action after a failure — it re-renders the dialog and lets the operator retry.

**Refusals and how each surfaces** (research R10; `mapDioException` is unchanged
by this feature):

| Status | Server `detail` | `AppError` | Dialog |
|---|---|---|---|
| 400 | "Cannot replace a price list with itself" | `ServerError(400, detail)` | Refusal banner. Prevented upstream by FR-010's picker exclusion, still handled. |
| 404 | "Price list not found" / "Replacement price list not found" | `NotFoundError(detail)` | Refusal banner. |
| 409 | "Still referenced by customer.price_list (12) — remove those records first" | `ServerError(409, detail)` | Refusal banner with the sentence intact. |

`ErrorBanner` renders a localized generic line plus `AppError.serverMessage`, so
the server's own sentence reaches the operator untranslated — the app's
established treatment for server-authored detail.

**The 409 is not dead code.** The blocked state (FR-018) prevents the *predicted*
409, but two paths still reach a real one: a relation created between the report
and the submission, and a submission made when the report never loaded.

---

## 3. Category fates

The one piece of contract knowledge mbe-ui encodes:

| `category` | Fate | Retirement does |
|---|---|---|
| `product_price.list` | `destroyed` | Deletes the rows |
| `customer.price_list` | `moved` | Reassigns to `replacement`, or refuses |
| *anything else* | `blocking` | Refuses |

Matched on the **whole key**, not the table prefix (research R2). The mapping
lives in one place, `PriceListDeleteCategory.fate`, and is unit-tested against
all three arms including an invented future key.

---

## 4. What this feature does not ask mbe-api for

Recorded so the absence is a decision, not an oversight — and so a future spec
can pick any of them up:

- **Enumerating the affected customers.** Would let the dialog name them instead
  of linking out. Not filed: the link satisfies FR-006, and the count is what the
  decision actually turns on.
- **A dry-run delete.** Would let the client confirm a replacement is valid
  before submitting. Not filed: the picker's own search already guarantees the id
  exists, and the 400/404 paths are handled.
- **Undo / soft-delete / an audit of prior assignments.** Not offered upstream by
  design ("There is no un-retire"), and this feature does not ask for it.
