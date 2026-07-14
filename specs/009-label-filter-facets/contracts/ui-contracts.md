# Contract: UI — `LabelMultiPicker` availability/count extension & drawer wiring

## `LabelMultiPicker` (core/widgets/label_multi_picker.dart) — extended

Add an optional availability + count map. Backward-compatible: omitting it preserves today's all-enabled, count-less behavior (used by the product form / detail).

```dart
const LabelMultiPicker({
  super.key,
  required this.labels,
  required this.selectedIds,
  required this.onChanged,
  this.enabled = true,       // existing: read-only mode for whole picker
  this.labelCounts,          // NEW: Map<int, int>? — labelId -> matching-product count;
                              // null => availability/counts unknown => all enabled, no count shown
});

final Map<int, int>? labelCounts;
```

**Per-chip enabled logic** (replaces the current `enabled ? ... : null`):

| Condition | Chip state |
|-----------|-----------|
| `enabled == false` (whole-picker read-only) | all chips non-interactive (unchanged) |
| `labelCounts == null` (loading/error/omitted) | all chips interactive — **fail open** (FR-010) |
| `selectedIds.contains(id)` | interactive (deselectable), regardless of availability (FR-006) |
| `labelCounts!.containsKey(id)` | interactive (selecting narrows to non-empty, FR-005) |
| otherwise | **disabled/greyed**, `onSelected: null` (FR-004) |

So: `chipInteractive = enabled && (labelCounts == null || selectedIds.contains(id) || labelCounts!.containsKey(id))`.

**Chip text**: `labelCounts?[label.labelId]` — when non-null, the chip renders the localized `labelWithCount` template (`"{name} ({count})"`, `app_es.arb`/`app_en.arb`); when null (unknown, or the label has no count — i.e. it's disabled), the chip renders the plain label name. Counts are shown for both available and already-selected labels (a selected label's count reflects the current narrowed result size), never for disabled ones.

**Visual**: disabled chips use `FilterChip`'s native disabled styling (Material 3, §V). Optional `Tooltip` on disabled chips using a localized "no matching products" key (research §7) — no hardcoded strings.

**Widget test keys**: keep `Key('products_filter_label')` on the picker; individual chips are identifiable via a prefix-matching finder on their label text, since the trailing `" (count)"` is conditional.

## `_ProductFiltersPanel` (products_list_screen.dart) — wiring

- Watch the availability/count provider: `final labelCounts = ref.watch(productLabelFacetsProvider).valueOrNull;`
- Pass it into the existing `LabelMultiPicker`:

```dart
LabelMultiPicker(
  key: const Key('products_filter_label'),
  labels: allLabels,
  selectedIds: filter.labels,
  labelCounts: labelCounts,   // null while loading/errored => all enabled, no count shown
  onChanged: filterController.labelsChanged,
);
```

- No change to the label section's visibility rule (`if (allLabels.isNotEmpty)`), the "Clear all" wiring (`filterController.reset`), the active-filter badge, or the responsive sheet chrome.

## Behavioral contract (maps to spec)

1. **FR-003 / FR-004** — on any filter change while the drawer is open, `productLabelFacetsProvider` refetches; chips not in the returned map (and not selected) become disabled and show no count.
2. **FR-005** — because the facet query includes selected labels under AND, every returned (enabled) label has ≥1 co-occurring product; selecting it cannot empty the list. Its chip shows that exact count.
3. **FR-006** — selected chips are always interactive (deselectable), even when nothing further narrows; they still show a count when the map has one for them.
4. **FR-007 / US3** — deselecting changes the filter → refetch → previously-disabled co-occurring labels re-enable, with fresh counts.
5. **FR-008** — "Clear all" (`reset`) clears labels; provider refetches for the now label-less filter → all labels present in the (search/attribute-)filtered catalog re-enable with their counts.
6. **FR-010** — provider loading/error → `valueOrNull == null` → all chips enabled, no counts shown; the list query is independent and still applies filters.

## Testing

- `LabelMultiPicker` widget test: given `labelCounts`, assert selected + available chips interactive with `"Name (count)"` text and others disabled with plain `"Name"` text; given `labelCounts == null`, assert all interactive with no count shown; assert a selected-but-unavailable chip stays interactive.
- `_ProductFiltersPanel` widget test with `productLabelFacetsProvider` overridden: loading/error → all enabled, no counts; data set → correct chips disabled and correct counts rendered on enabled/selected chips; toggling a filter triggers a re-read.
