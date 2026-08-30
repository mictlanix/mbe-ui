# Phase 0 Research: Price List Retirement UI

Twelve findings. Five change what gets built (R1, R3, R5, R6, R9); the rest fix
details that would otherwise be discovered mid-implementation.

---

## R1. The API and the generated client are both already in place — nothing upstream is missing

**Decision**: Build against the client as generated today. No mbe-api issue, no
`openapi-generator` run, no hand-written DTO.

**Rationale**: mbe-api's `015-price-list-retirement` merged as PR #186, and the
checked-in client already carries both halves:

| Need | Generated symbol |
|---|---|
| The report | `PriceListsApi.previewPriceListDeleteApiV1PriceListsPriceListIdDeletePreviewGet({required int priceListId})` → `Response<PriceListDeletePreviewResponse>` |
| Deletion with a replacement | `PriceListsApi.deletePriceListApiV1PriceListsPriceListIdDelete({required int priceListId, int? replacement})` → `Response<void>` |
| The payload | `PriceListDeletePreviewResponse { BuiltList<PriceListDeletePreviewItem> items; int total }`, `PriceListDeletePreviewItem { String category; int count }` |

Verified by reading `lib/generated/openapi/lib/src/api/price_lists_api.dart` and
the two model files: `replacement` is emitted into `_queryParameters` only when
non-null, which is exactly the contract's "omit it and today's behaviour is
preserved".

**Alternatives considered**: regenerating the client defensively — rejected, it
would produce no diff and risks unrelated churn in a 200-file generated tree.

---

## R2. `product_price.list` and `customer.price_list` are matched as whole keys, not by table prefix

**Decision**: Map a category to its fate by exact `category` string:
`'product_price.list'` → destroyed, `'customer.price_list'` → moved, everything
else → blocking.

**Rationale**: The contract defines `category` as `table.column` and names
exactly two keys. `product_price` has other columns and `customer` certainly
does; a second foreign key from either table to `price_list` would arrive as a
*different* column and, per the contract, must block. Prefix-matching the table
would silently classify such a relation as "deleted with the list" — the exact
failure mode FR-011 upstream exists to prevent, inverted.

This is a deliberate divergence from `MergePreviewCategory.isDestroyed`, which
uses `key.startsWith('product_price.')`. That is defensible there (merge deletes
*all* of a product's prices, whichever column points at it); it is not
defensible here.

**Alternatives considered**: matching on `table` for symmetry with merge —
rejected for the reason above. Treating an unknown key as non-blocking —
rejected outright: the whole point of deriving blockers from mapped metadata
upstream is that an unfamiliar relation fails loudly.

---

## R3. There is no count formatter on the formatting surface, and the guard forbids adding one locally

**Decision**: Add `DisplayFormatters.count(int)` to
`lib/core/formatting/app_formatters.dart`, backed by
`NumberFormat.decimalPattern(locale)`. Use it for every count and the total.

**Rationale**: The spec requires locale-grouped counts (`4,312`), and the
artboards render them that way. `AppFormatters` today exposes `currency`,
`percent`, `date`, `dateTime`, `quantity` and the `field.*` group — nothing for
a plain integer, and `display.quantity` takes a `String` and renders through
`Decimal.toString()`, which applies **no grouping** at all. Meanwhile
`test/unit/core/formatting_guard_test.dart` fails the suite on any
`import 'package:intl/...'` under `lib/` outside a short allowlist, so a widget
cannot reach `NumberFormat` itself.

So there are exactly two legal options: render `'$count'` unformatted, or extend
the surface. Constitution §V puts quantities on the surface by name, and the
surface file is itself allowlisted, so extending it is the compliant path and a
genuinely small one (one method, one unit test).

**Knock-on, deliberately not taken**: `MergeRelatedRecordsSummary` renders
`'${category.count}'` raw and would read better through the same method. That is
a pre-existing inconsistency in a shipped destructive flow, outside this
feature's diff, and is left alone (see R5).

**Alternatives considered**: unformatted counts — rejected, the artboards and the
spec's edge case both call for grouping, and `43127` vs `4312` is exactly the
misread this dialog cannot afford. Adding the allowlist entry for the pricing
widget instead — rejected, that is what the guard exists to prevent.

---

## R4. The preview is a provider; its failure is a state, not an error screen

**Decision**: `@riverpod Future<PriceListDeletePreview> priceListDeletePreview(ref, {required int priceListId})`,
auto-disposing, read once when the dialog opens. The dialog renders its three
`AsyncValue` cases as three dialog states — loading, resolved, and the FR-020
degraded state — never as a full-screen error.

**Rationale**: Directly mirrors `mergePreview` in
`merge_products_comparison_provider.dart`, whose doc comment already states the
policy this feature needs: informational counts whose failure must leave the
surrounding flow usable. The one difference is that merge has a *second*
provider (`mergeComparison`) whose failure blocks; here there is no such
companion, so the single provider carries the whole read.

**Alternatives considered**: fetching in the controller and holding the result in
form state — rejected, it puts a request lifecycle into a form controller that
has none today and loses `AsyncValue`'s three-case rendering for free.

---

## R5. The breakdown panel is built new, and the merge one is not touched

**Decision**: New `PriceListDeleteSummary` under
`lib/features/pricing/presentation/widgets/`. `MergeRelatedRecordsSummary` is
left exactly as it is.

**Rationale**: This was settled with the requester before the spec was written,
and the code supports it. The two panels look alike, but this one has a third
fate (blocking) that merge has no concept of, a row that navigates, and a
different caption. Generalizing would mean parameterizing fate, note colour,
row-tap behaviour and caption — at which point the shared widget is a
configuration object with two callers, and the refactor lands in a shipped
irreversible flow for no new capability.

mbe-api reached the same conclusion independently about the DTO: the generated
`PriceListDeletePreviewItem` doc comment says it is "structurally identical to
`ProductMergePreviewItem`, and deliberately not shared with it… Worth unifying
when a third caller appears." Same trigger, recorded on both sides.

**Alternatives considered**: lifting the merge widget to `core/widgets/` —
rejected as above; noted as the right move if a third such panel ever appears.

---

## R6. `humanizeCategoryKey` is duplicated rather than moved

**Decision**: Re-declare the five-line humanizer privately in the pricing widget.
Do not move the existing one out of
`features/catalog/presentation/widgets/merge_related_records_summary.dart`.

**Rationale**: The pricing feature importing a symbol from the catalog feature's
`presentation/` layer is cross-feature presentation coupling that constitution §I
does not sanction; moving it to `core/` would edit the merge widget's imports,
which R5 just decided not to touch. Five lines of pure string manipulation, with
its own test on each side, is the cheaper of the two. Recorded here so it is a
decision rather than an oversight, with the same "third caller unifies all three"
trigger as R5.

**Alternatives considered**: `core/text/humanize.dart` — the right home
eventually, but it makes this feature's diff reach into merge for a helper merge
already has.

---

## R7. The screen keeps `RecordFormActions`; only the confirmation changes

**Decision**: `PriceListDetailScreen` keeps `RecordFormActions` and passes
`deleteConfirmation: null`, routing `onDelete` to
`showPriceListDeleteDialog(context, …)`. No change to
`core/widgets/record_form_actions.dart`.

**Rationale**: `RecordFormActions._confirmAndDelete` already calls `onDelete`
directly when `deleteConfirmation` is null — a documented, unused-until-now
branch ("not used by any screen today, but not disallowed"). So the richer
dialog needs no new parameter, no builder callback, and no edit to a component
shared by all 18 record screens. Constitution §VI's requirement that Delete be
rendered by that one shared component in that one fixed order still holds; only
what the button opens changes.

**Alternatives considered**: a `confirmationBuilder` parameter on
`RecordFormActions` — rejected, it adds an extension point for one caller and
touches every screen's shared widget to do it.

---

## R8. The delete entry point stays on the edit screen

**Decision**: No row action on `price_lists_list_screen.dart`. No file in that
screen is touched.

**Rationale**: Settled with the requester, and independently required by
constitution §VI: "Delete/soft-delete MUST be surfaced on the record's own
detail screen… MUST NOT place it back on the list row", with per-row Delete
icons "banned outright". So the alternative was not merely undesirable, it was
non-compliant.

---

## R9. `delete()` returns an outcome instead of setting a `deleted` flag

**Decision**: Change `PriceListFormController.delete()` to
`Future<bool> delete({int? replacement})` and remove the `deleted` field from
`PriceListFormState`. The screen awaits the dialog, then shows the snackbar and
pops.

**Rationale**: This is the one non-obvious trap in the feature. Today the screen
does:

```dart
if (formState.saved || formState.deleted) {
  WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) context.pop(); });
}
```

With the review dialog open, `deleted: true` rebuilds the screen and the
post-frame `context.pop()` pops **the topmost route — the dialog** — leaving the
operator on a price list that no longer exists. Keeping the flag and trying to
sequence around it means racing a post-frame callback against a dialog
dismissal.

Returning a result inverts the control flow so there is no race: the dialog pops
itself with its outcome, the screen resumes after `await`, shows the snackbar
(`ScaffoldMessenger` is above the popped route, the same ordering
`merge_products_screen.dart` relies on), and pops itself. `deleted` is read
nowhere else, so removing it is orphan cleanup from this change rather than an
unrelated refactor.

**Alternatives considered**: keeping `deleted` and having the dialog pop first,
then letting the flag fire — rejected, correctness would depend on frame
ordering between two independent mechanisms. Popping the screen from inside the
dialog — rejected, a dialog that navigates its opener is the harder thing to
test and reason about.

---

## R10. A 409 arrives as `ServerError(statusCode: 409)` with the server's sentence intact

**Decision**: Render a refusal with `ErrorBanner`, which already prints a
localized generic line plus `AppError.serverMessage`.

**Rationale**: `mapDioException` has no 409 case, so a conflict falls to
`default:` → `AppError.server(statusCode: 409, message: _detailFrom(data))`, and
`_detailFrom` extracts FastAPI's `{"detail": "..."}` string. The server's
sentence — *"Still referenced by customer.price_list (12) — remove those records
first"* — therefore survives to `serverMessage` unchanged, which is precisely
what FR-019 wants shown. `ErrorBanner` renders exactly that pair.

Untranslatable server text next to a localized line is the app's established
compromise for server-authored detail; nothing new is introduced here.

**Alternatives considered**: adding a `ConflictError` variant to `AppError` —
rejected, a shared error hierarchy change for one dialog, when the existing
mapping already delivers everything needed.

---

## R11. The blocked state is computed from the preview, and never submits

**Decision**: `PriceListDeletePreview.isBlocked` ⇔ any category whose fate is
`blocking`. When true the dialog shows the blocked banner, marks the offending
rows, and offers only Close.

**Rationale**: The client can determine this before submitting, because the
report enumerates every relation and the contract fixes what each of the two
known keys does. Submitting anyway to collect a 409 the app already predicted is
a self-inflicted failure (spec Story 4).

The 409 path stays fully implemented regardless — it is the race where something
starts referencing the list between the report and the deletion, and it is also
the only protection when the report never loaded (R4's degraded state).

---

## R12. Testing follows the merge feature's four-layer split

**Decision**:

| Layer | File | Covers |
|---|---|---|
| unit | `test/unit/features/pricing/price_list_delete_preview_test.dart` | fate mapping (R2), `isBlocked`, `priceCount`/`customerCount`, empty preview |
| unit | `test/unit/features/pricing/price_list_repository_impl_test.dart` (extend) | preview mapping, `replacement` reaching the query, 409 → `ServerError` with detail |
| unit | `test/unit/features/pricing/price_list_form_controller_test.dart` (extend) | `delete({replacement})` returns true/false, error retained, RBAC denial |
| unit | `test/unit/core/formatting/app_formatters_display_test.dart` (extend) | `display.count` grouping per locale (R3) |
| widget | `test/widget/features/pricing/price_list_delete_summary_test.dart` | three fates, unlabelled fallback, server total not re-summed, customers row navigates |
| widget | `test/widget/features/pricing/price_list_delete_dialog_test.dart` | all seven states and every gate |
| widget | `test/widget/features/pricing/price_list_detail_screen_test.dart` (extend) | Delete opens the review dialog, still absent without the privilege |
| integration | `test/integration/price_list_retirement_flow_test.dart` | the golden path end to end |

**Rationale**: Mirrors `016-product-merge-review`'s own split
(`merge_preview_test`, `merge_related_records_summary_test`,
`merge_products_screen_test`, `product_merge_flow_test`), which is the closest
precedent and the one a reviewer will compare against. The seven dialog states
are enumerable and each has one visible consequence, so they are a widget-test
table rather than seven hand-written cases.

**Note on the existing screen test**: `price_list_detail_screen_test.dart` has a
case asserting the old flow ("a user with delete privilege sees the Delete
button, and confirming …" driving `confirm_delete_price_list_button`). That key
disappears with the old dialog; the case is rewritten, not deleted — the
privilege assertions in it are still the ones FR-021 needs.
