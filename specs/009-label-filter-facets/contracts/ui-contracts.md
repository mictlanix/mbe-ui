# Contract: UI — `LabelMultiPicker` availability extension & drawer wiring

## `LabelMultiPicker` (core/widgets/label_multi_picker.dart) — extended

Add an optional availability set. Backward-compatible: omitting it preserves today's all-enabled behavior (used by the product form / detail).

```dart
const LabelMultiPicker({
  super.key,
  required this.labels,
  required this.selectedIds,
  required this.onChanged,
  this.enabled = true,       // existing: read-only mode for whole picker
  this.availableIds,         // NEW: Set<int>? — null => availability unknown => all enabled
});

final Set<int>? availableIds;
```

**Per-chip enabled logic** (replaces the current `enabled ? ... : null`):

| Condition | Chip state |
|-----------|-----------|
| `enabled == false` (whole-picker read-only) | all chips non-interactive (unchanged) |
| `availableIds == null` (loading/error/omitted) | all chips interactive — **fail open** (FR-010) |
| `selectedIds.contains(id)` | interactive (deselectable), regardless of availability (FR-006) |
| `availableIds!.contains(id)` | interactive (selecting narrows to non-empty, FR-005) |
| otherwise | **disabled/greyed**, `onSelected: null` (FR-004) |

So: `chipInteractive = enabled && (availableIds == null || selectedIds.contains(id) || availableIds!.contains(id))`.

**Visual**: disabled chips use `FilterChip`'s native disabled styling (Material 3, §V). Optional `Tooltip` on disabled chips using a localized "no matching products" key (research §7) — no hardcoded strings.

**Widget test keys**: keep `Key('products_filter_label')` on the picker; individual chips remain identifiable by label text for tests asserting enabled vs. disabled.

## `_ProductFiltersPanel` (products_list_screen.dart) — wiring

- Watch the availability provider: `final availableIds = ref.watch(productLabelFacetsProvider).valueOrNull;`
- Pass it into the existing `LabelMultiPicker`:

```dart
LabelMultiPicker(
  key: const Key('products_filter_label'),
  labels: allLabels,
  selectedIds: filter.labels,
  availableIds: availableIds,   // null while loading/errored => all enabled
  onChanged: filterController.labelsChanged,
);
```

- No change to the label section's visibility rule (`if (allLabels.isNotEmpty)`), the "Clear all" wiring (`filterController.reset`), the active-filter badge, or the responsive sheet chrome.

## Behavioral contract (maps to spec)

1. **FR-003 / FR-004** — on any filter change while the drawer is open, `productLabelFacetsProvider` refetches; chips not in the returned set (and not selected) become disabled.
2. **FR-005** — because the facet query includes selected labels under AND, every returned (enabled) label has ≥1 co-occurring product; selecting it cannot empty the list.
3. **FR-006** — selected chips are always interactive (deselectable), even when nothing further narrows.
4. **FR-007 / US3** — deselecting changes the filter → refetch → previously-disabled co-occurring labels re-enable.
5. **FR-008** — "Clear all" (`reset`) clears labels; provider refetches for the now label-less filter → all labels present in the (search/attribute-)filtered catalog re-enable.
6. **FR-010** — provider loading/error → `valueOrNull == null` → all chips enabled; the list query is independent and still applies filters.

## Testing

- `LabelMultiPicker` widget test: given `availableIds`, assert selected + available chips interactive and others disabled; given `availableIds == null`, assert all interactive; assert a selected-but-unavailable chip stays interactive.
- `_ProductFiltersPanel` widget test with `productLabelFacetsProvider` overridden: loading/error → all enabled; data set → correct chips disabled; toggling a filter triggers a re-read.
