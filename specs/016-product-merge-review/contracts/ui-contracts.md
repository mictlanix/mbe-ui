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

Renders once the comparison provider resolves (`AsyncData`). Two-column value layout (kept / deleted) with a persistent header row labeling each column — never a per-row label that could scroll out of view (research.md §5). One row per field: internal id, code, SKU, model, brand, unit of measure, tax rate, status (FR-005, data-model.md). A row whose kept/deleted values differ is visually flagged (`Key('merge_diff_row')` on flagged rows, for widget-test targeting), e.g. a badge or background tint distinct from the kept/deleted panel colors (so "this field differs" is never confused with "which side is kept").

- `AsyncLoading` → the table area shows a loading indicator (`Key('merge_comparison_loading')`).
- `AsyncError` → the shared `ErrorBanner` renders in the table's place (reusing spec 008's existing error-banner pattern); the acknowledgment checkbox and merge button remain disabled (FR-011 extended to this fetch).

## 4. Acknowledgment (`Key('merge_acknowledge_checkbox')`)

A `CheckboxListTile`-style control below the panels/table, visible whenever `state.reviewReady` is true. Label text names the specific product currently in the `duplicate` role, e.g. `l10n.mergeAcknowledgeLabel(state.duplicate!.name)` ("Entiendo que **{name}** se eliminará" / "I understand **{name}** will be deleted"). `onChanged` calls `controller.acknowledgeToggled()`. Its checked state is `state.acknowledged` — since `acknowledged` resets on swap/selection change (data-model.md), this control visibly unchecks itself if the operator swaps after having checked it, making the reset impossible to miss.

## 5. Merge submit button — updated gating

`Key('merge_submit_button')` (spec 008, unchanged key): `onPressed` is `null` unless `state.canSubmit`, which now additionally requires `state.acknowledged` (data-model.md) on top of spec 008's existing `bothSelected && !isSameProduct && !submission.isLoading`.

## 6. Confirmation dialog — extended content

`_confirmMerge` (spec 008, unchanged trigger/flow: opened on submit-button tap, `Key('merge_confirm_cancel_button')`/`Key('merge_confirm_button')` unchanged) has its message extended to restate **both** products by name and code (FR-009), not just by name as in spec 008:

- content: `l10n.mergeConfirmMessage(keptName, keptCode, deletedName, deletedCode)` (arb key signature extended with two new placeholders).
- When a related-record total is available (not in this pass — research.md §4), it would be appended to this same message; omitted entirely for now, consistent with FR-006's fallback.

## 7. Compact-width layout

Below the compact breakpoint, panels stack vertically (kept above deleted, matching the reference design's compact mock) and the comparison table's two value columns remain side by side within the narrower width (wrapping/truncating long values with a tooltip/expand fallback per constitution §VI, rather than introducing horizontal scroll).
