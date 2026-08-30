# Contract: the price list delete review dialog

The UI contract for `PriceListDeleteDialog` and `PriceListDeleteSummary` —
structure, keys, gates and strings. Layout follows
`artifacts/price_list_delete/` (Main / Blocked / Simple artboards); as
constitution §V requires, the artboards' pixel values and palette are a
*presentation*, and everything resolves through `Theme.of(context)`, the spec 022
spacing tokens and the type roles.

---

## 1. Entry point

`PriceListDetailScreen` keeps `RecordFormActions` and passes:

```dart
RecordFormActions(
  mode: …, deleteLabel: l10n.deletePriceListButton,
  deleteKey: const Key('delete_price_list_button'),
  onDelete: canDelete ? () => _reviewAndDelete(context) : null,
  deleteConfirmation: null,   // the review dialog replaces the AlertDialog
)
```

`deleteConfirmation: null` makes `RecordFormActions` invoke `onDelete` directly
— an already-documented branch of the shared widget, so no edit to
`core/widgets/record_form_actions.dart` (research R7).

`onDelete` stays `null` without `can(priceLists, delete)`, so the button is
**absent**, never disabled (constitution §IV, FR-021). Unchanged from today.

### 1.1 The screen's half of the flow

```dart
final outcome = await showPriceListDeleteDialog(context, priceList: …);
if (outcome == null || !context.mounted) return;
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
  outcome.replacementName == null
    ? l10n.priceListDeletedMessage
    : l10n.priceListDeletedWithMoveMessage(outcome.movedCount, fmt.display.count(outcome.movedCount), outcome.replacementName!),
)));
context.pop();
```

Snackbar **before** pop: `ScaffoldMessenger` sits above the popped route, the
same ordering `merge_products_screen.dart` already relies on. The old
`formState.deleted` post-frame pop is gone (research R9) — with a dialog on the
stack it would have popped the dialog instead of the screen.

---

## 2. Dialog structure

`AlertDialog`, ~560 logical px wide, sections in order:

| # | Section | Rendered when |
|---|---|---|
| 1 | Title — "Delete price list?" | always |
| 2 | Lead line — name + `#id`, "will be permanently deleted. This cannot be undone." | not blocked |
| 3 | Refusal banner (`ErrorBanner`) | a submission was refused |
| 4 | Blocked banner | `preview.isBlocked` |
| 5 | Degraded note | preview errored |
| 6 | `PriceListDeleteSummary` / skeleton / clean note | see §3 |
| 7 | Replacement picker | `movedCount > 0` **and not blocked** (required), or preview errored (optional) |
| 8 | Acknowledgment checkbox | preview resolved non-empty and not blocked, or preview errored |
| 9 | Actions — Cancel/Close, then the destructive button | always |

The lead line is suppressed in the blocked state: the blocked banner already
says the list is not going anywhere, and "will be permanently deleted" directly
above it contradicts it.

### 2.1 Widget keys

| Key | On |
|---|---|
| `price_list_delete_dialog` | the dialog root |
| `price_list_delete_summary` | the breakdown panel |
| `price_list_delete_row_<category>` | one breakdown row, e.g. `…_row_customer.price_list` |
| `price_list_delete_total` | the total figure |
| `price_list_delete_customers_link` | the customers row's navigation affordance |
| `price_list_delete_replacement` | the replacement picker |
| `price_list_delete_acknowledge` | the acknowledgment checkbox |
| `price_list_delete_confirm` | the destructive button |
| `price_list_delete_blocked_banner` | the blocked banner |
| `price_list_delete_preview_failed_note` | the degraded note |
| `price_list_delete_clean_note` | the "nothing depends on this" note |

---

## 3. `PriceListDeleteSummary`

Same visual shape as `MergeRelatedRecordsSummary` — bordered, clipped
`Container` with a `surfaceContainerHighest` header, one row per category, a
top-bordered total footer — built independently (research R5).

Per row: label, a parenthesized fate note, and the count right-aligned.

| Fate | Note string | Colour |
|---|---|---|
| `destroyed` | `priceListDeleteFateDestroyed` | `colorScheme.error` |
| `moved` | `priceListDeleteFateMoved` | `colorScheme.onSurfaceVariant` |
| `blocking` | `priceListDeleteFateBlocking` | `colorScheme.error` |

**Labels** resolve from `category.table`: `product_price` and `customer` get
translated strings; anything else is humanized (`sales_order` → "Sales order")
by a private copy of the merge widget's helper (research R6). A category is
**never** dropped — omitting one would understate the blast radius (FR-005).

**Caption** below the panel: "Records this deletion touches — not all of them are
deleted." (FR-004).

**Counts and total** go through `fmt.display.count(...)` (research R3), with
`FontFeature.tabularFigures()` so a column of counts aligns.

**The customers row** additionally renders `price_list_delete_customers_link`,
navigating to `/customers?priceList=<id>` (FR-006). It opens a different route
while a modal is up, so it pops the dialog first — the deletion is abandoned, not
backgrounded, and the operator returns to a clean state.

---

## 4. Gates

The destructive button is enabled iff **all** hold:

1. the preview is not loading;
2. `!preview.isBlocked` (in the blocked state the button is not rendered at all);
3. `acknowledged`, when an acknowledgment is shown;
4. `replacement != null`, when the picker is shown as required;
5. no submission is in flight.

While submitting, the button shows a progress indicator and **both** it and
Cancel are disabled (FR-016) — the dialog is `barrierDismissible: false` and its
`PopScope` blocks back/escape for the same reason.

### 4.1 The replacement picker

`CatalogEntityPicker<PriceList>` over `PriceListRepository.list(search:)`, the
same construction the customers filter uses. Its options exclude the list being
deleted (FR-010) by filtering the result client-side on `priceListId`.

The picker is **not rendered at all in the blocked state**, even when customers
are assigned: a blocked list offers only Close (FR-018), so a replacement it can
never use would be an input with no outcome. data-model.md §4.1's `blocked` row
is authoritative wherever this reads ambiguously.

Helper text, in priority order:

| Condition | Text |
|---|---|
| chosen, `movedCount > 0` | "All {n} customers move to {name}." |
| chosen, preview errored | "Used only if customers turn out to be assigned." |
| not chosen, required | "Required — every customer on this list moves here." |
| not chosen, optional | "Optional — used only if customers turn out to be assigned." |

---

## 5. Strings

New keys, both `.arb` files, `es-MX` authored first (constitution §V;
`test/unit/core/l10n_parity_test.dart` enforces parity).

| Key | English |
|---|---|
| `priceListDeleteLead` | "{name} {id} will be permanently deleted. This cannot be undone." |
| `priceListDeleteRelatedTitle` | Records attached to this price list |
| `priceListDeleteTotalLabel` | Total |
| `priceListDeleteTotalCaption` | Records this deletion touches — not all of them are deleted. |
| `priceListDeleteFateDestroyed` | deleted permanently |
| `priceListDeleteFateMoved` | moved to the replacement |
| `priceListDeleteFateBlocking` | blocks deletion — clear these first |
| `priceListDeleteCategoryProductPrice` | Product prices |
| `priceListDeleteCategoryCustomer` | Customers |
| `priceListDeleteViewCustomers` | View customers |
| `priceListDeleteCleanNote` | No prices and no customers depend on this list. |
| `priceListDeleteBlockedBanner` | This list is still in use by records the deletion cannot touch. Clear them first, then delete the list. |
| `priceListDeletePreviewFailedNote` | Could not load what depends on this list. You can still delete it — if customers are assigned, the deletion will be refused. |
| `priceListDeleteReplacementLabel` | Replacement price list |
| `priceListDeleteReplacementLabelOptional` | Replacement price list (optional) |
| `priceListDeleteReplacementRequiredHelper` | Required — every customer on this list moves here. |
| `priceListDeleteReplacementOptionalHelper` | Optional — used only if customers turn out to be assigned. |
| `priceListDeleteReplacementChosenHelper` | ICU plural — "All {formatted} customers move to {name}." |
| `priceListDeleteAcknowledge` | I understand this cannot be undone and that this list's prices are deleted with it. |
| `priceListDeleteConfirm` | Delete list |
| `priceListDeleteConfirmPrices` | ICU plural — "Delete list and {formatted} prices" |
| `priceListDeleteConfirmCustomers` | ICU plural — "Delete list and move {formatted} customers" |
| `priceListDeletedMessage` | Price list deleted. |
| `priceListDeletedWithMoveMessage` | ICU plural — "Price list deleted. {formatted} customers moved to {name}." |

### 5.1 Plural + formatting gotcha

An ICU `plural` interpolating its own selector prints the raw integer —
`{count, plural, other{{count} prices}}` renders `4312`, ungrouped, defeating
research R3. Every plural key here therefore takes **two** placeholders: `count`
(`int`, selects the branch) and `formatted` (`String`, already through
`display.count`, and the only one interpolated into the text).

```json
"priceListDeleteConfirmPrices": "{count, plural, =1{Delete list and 1 price} other{Delete list and {formatted} prices}}",
"@priceListDeleteConfirmPrices": {
  "placeholders": { "count": {"type": "int"}, "formatted": {"type": "String"} }
}
```

### 5.2 Reused and retired

**Reused**: `deletePriceListConfirmTitle` ("Delete price list?" / "¿Eliminar
lista de precios?") is already exactly the artboards' title. The dialog keeps it
rather than adding a synonym.

**Retired**: `deletePriceListConfirmMessage` — the old one-line body, replaced by
`priceListDeleteLead`, which adds the `#id` the artboards show. Removed from both
`.arb` files.

`priceListDeleteFailedError` and `priceListDeletePermissionDeniedError` **stay**:
they are the generic lines `ErrorBanner` pairs with the server's detail.
