# Contract: Merge Products Review Step UI

Extends spec 008's `MergeProductsScreen` (`lib/features/catalog/presentation/merge_products_screen.dart`, route `/products/merge`, unchanged gating). No new route.

## 1. Review step visibility

Rendered inline on the same screen, below the two existing pickers, when `state.reviewReady` is true (data-model.md). While `false` (a selection missing, or both selections equal), the existing spec 008 validation message (`Key('merge_validation_message')`) continues to show in its place — this feature does not change that behavior.

## 2. `MergeReviewPanel` pair (new widget, `widgets/merge_review_panel.dart`)

Two panels, laid out side by side above the compact-width breakpoint and stacked below it (constitution §VI, research.md §5):

- **Kept panel** (`Key('merge_kept_panel')`): label `l10n.mergeKeptLabel` ("Se conserva" / "Kept") rendered as visible text (not color-only, FR-002) plus a distinct container color/border; shows photo, `productId`, `name`, `code`/`sku`/`model`, status badge, unit-of-measure badge, tax-rate badge — sourced from the comparison provider's kept `Product` (data-model.md).
- **Deleted panel** (`Key('merge_deleted_panel')`): label `l10n.mergeDeletedLabel` ("Se elimina" / "Deleted"), distinct container color/border from the kept panel; same fields, `name` rendered with a strikethrough text decoration (FR-002).
- **Swap control** (`Key('merge_swap_button')`, e.g. an icon button with tooltip `l10n.mergeSwapTooltip`): calls `controller.swap()`. Both panels and the diff table re-render immediately from the (now-exchanged) `canonical`/`duplicate` ids; the comparison provider re-fetches only if the underlying ids weren't already both cached (they typically are, since both were just fetched for the pre-swap render).

## 3. `MergeComparisonTable` (new widget, `widgets/merge_comparison_table.dart`)

Renders once the comparison provider resolves (`AsyncData`). Two-column value layout (kept / deleted) with a persistent header row labeling each column — never a per-row label that could scroll out of view (research.md §5). One row per field: internal id, code, SKU, model, brand, unit of measure, tax rate, status (FR-005, data-model.md). A row whose kept/deleted values differ is visually flagged with both a badge and a background tint distinct from the kept/deleted panel colors (so "this field differs" is never confused with "which side is kept").

**Test targeting**: each row carries a per-field key `Key('merge_row_<fieldLabel>')` — Flutter requires sibling keys to be unique, so a single shared `merge_diff_row` key across flagged rows is not usable. Flagged rows are identified instead by their `Key('merge_diff_badge')` marker, which repeats across rows but never among siblings; widget tests count badges to assert how many and which fields differ.

- `AsyncLoading` → the table area shows a loading indicator (`Key('merge_comparison_loading')`).
- `AsyncError` → the shared `ErrorBanner` renders in the table's place (reusing spec 008's existing error-banner pattern); the acknowledgment checkbox and merge button remain disabled (FR-011 extended to this fetch).

## 3b. `MergeRelatedRecordsSummary` (new widget, `widgets/merge_related_records_summary.dart`)

Renders the blast-radius summary (FR-006 / Story 5) from the merge-preview provider, independently of the comparison provider's state.

- Header framed around the product marked for deletion, e.g. `l10n.mergeRelatedRecordsTitle` — **not** a blanket "will be reassigned" heading, since one category is destroyed rather than moved (research.md §4).
- One row per `MergePreviewCategory` (`Key('merge_related_category_row')`): resolved label on the left, count on the right, in the server's order (largest first).
  - Known category keys resolve to localized labels; unrecognized keys fall back to a humanized rendering of the raw key (data-model.md). A category is never dropped.
  - A category with `isDestroyed == true` (price-list rows) is visually and textually marked as destroyed rather than moved — e.g. a short qualifier via `l10n.mergeRelatedDestroyedNote` — so the operator is not told their price rows survive.
- Footer row showing `preview.total` (`Key('merge_related_total')`), displayed as returned by the server.
- `AsyncLoading` → a compact loading placeholder (`Key('merge_related_loading')`) in the section's place.
- `AsyncError` → the section is **omitted entirely** (no banner, no zero-filled rows): it is informational context, and a failure here must not distract from or block the destructive decision (Story 5 #4). The merge button's enablement is unaffected.

## 4. Acknowledgment (`Key('merge_acknowledge_checkbox')`)

A `CheckboxListTile`-style control below the panels/table, visible whenever `state.reviewReady` is true. Label text names the specific product currently in the `duplicate` role, e.g. `l10n.mergeAcknowledgeLabel(state.duplicate!.name)` ("Entiendo que **{name}** se eliminará" / "I understand **{name}** will be deleted"). `onChanged` calls `controller.acknowledgeToggled()`. Its checked state is `state.acknowledged` — since `acknowledged` resets on swap/selection change (data-model.md), this control visibly unchecks itself if the operator swaps after having checked it, making the reset impossible to miss.

## 5. Merge submit button — updated gating

`Key('merge_submit_button')` (spec 008, unchanged key): `onPressed` is `null` unless `state.canSubmit`, which now additionally requires `state.acknowledged` (data-model.md) on top of spec 008's existing `bothSelected && !isSameProduct && !submission.isLoading`.

## 6. Confirmation dialog — extended content

`_confirmMerge` (spec 008, unchanged trigger/flow: opened on submit-button tap, `Key('merge_confirm_cancel_button')`/`Key('merge_confirm_button')` unchanged) has its message extended to restate **both** products by name and code (FR-009), not just by name as in spec 008:

- content: `l10n.mergeConfirmMessage(keptName, keptCode, deletedName, deletedCode)` (arb key signature extended with two new placeholders).
- When the merge preview has resolved, the total is appended via a separate localized line (`l10n.mergeConfirmTotalLine(total)`) rather than being folded into the main message — so a pending or failed preview simply omits that line instead of forcing a placeholder into the sentence (FR-009's "when available").

## 7. Picker suggestion subtitle — amends spec 008

`specs/008-merge-products/contracts/ui-contracts.md` §2 specifies the suggestion subtitle as "code, model, and SKU joined with ` · `, omitting any blank part". That format is **superseded here**: each value is now prefixed with its localized field name (`Code: 292699 · Model: 292699 · SKU: 292699`), matching the review panels (§2).

Rationale: this catalog routinely carries the same string in all three fields, so the unlabelled form (`292699 · 292699 · 292699`) cannot tell the operator which identifier they matched on — the identification failure the review step downstream exists to catch. Blank-part omission is unchanged. Spec 008's FR-003 ("display the product's photo thumbnail together with identifying text (name, code, model, SKU)") is still satisfied; only the rendering changed.

## 8. Compact-width layout

Below the compact breakpoint, panels stack vertically (kept above deleted, matching the reference design's compact mock) and the comparison table's two value columns remain side by side within the narrower width (wrapping/truncating long values with a tooltip/expand fallback per constitution §VI, rather than introducing horizontal scroll).
