# Data Model: Bulk Pricing Grid

**Feature**: `033-bulk-pricing-grid` | **Date**: 2026-08-29

Client-side model only — no new wire type, no codegen ([research.md](./research.md) R11).
Existing entities are listed where the grid depends on a field of theirs.

---

## 1. Existing entities, unchanged

| Entity | Where | Used for |
|---|---|---|
| `ProductListItem` | `features/catalog/domain/entities/` | a grid row's identity: `productId`, `code`, `name`, `photo`, `status` |
| `PriceList` | `features/pricing/domain/entities/` | a column: `priceListId`, `name`; **and** `highProfitMargin`/`lowProfitMargin`, which stop being displayed but are still read when creating a price (R6 rule 2) |
| `ProductPrice` | `features/pricing/domain/entities/` | a cell's stored value: `productPriceId`, `price`; **and** `lowProfit`/`highProfit`, echoed back unchanged on update (R6 rule 1) |

**The two profit pairs stay on the entities.** FR-034 removes them from every
screen, not from the model — the write path needs them and the deprecation itself
is mbe-api#185's.

## 2. `PricingGridRow` — the unit of display

One product with its price on each shown list. The transpose of the old
`ProductPriceRow` (one list, one product), which stays for the standalone screen.

```dart
@freezed
class PricingGridRow with _$PricingGridRow {
  const factory PricingGridRow({
    required ProductListItem product,
    /// Keyed by price list id. Absent key = no price row exists for that
    /// list, which is what makes "not set" ≠ 0.00 representable (FR-005).
    required Map<int, ProductPrice> prices,
  }) = _PricingGridRow;
}
```

Built by a pure `buildPricingGridRows({products, prices})` join, mirroring the
existing `buildProductPriceRows` helper so it is unit-testable without a widget.

## 3. `PriceCellKey` — the coordinate

```dart
@freezed
class PriceCellKey with _$PriceCellKey {
  const factory PriceCellKey({
    required int productId,
    required int priceListId,
  }) = _PriceCellKey;
}
```

Freezed gives it value equality, so it is a legal `Map` key. Every per-cell map in
§4 is keyed by it.

## 4. `PricingGridState`

```dart
@freezed
class PricingGridState with _$PricingGridState {
  const factory PricingGridState({
    @Default(<PricingGridRow>[]) List<PricingGridRow> rows,
    @Default(<PriceList>[]) List<PriceList> allLists,
    CatalogPage<PricingGridRow>? page,
    @Default(false) bool loading,
    AppError? error,

    /// Cells whose write is in flight (FR-022 "saving").
    @Default(<PriceCellKey>{}) Set<PriceCellKey> inFlight,

    /// Cells the server refused, holding the text the user typed so it is
    /// never lost (FR-009). Presence here also means "show the rejected
    /// badge"; the stored price in [rows] is untouched.
    @Default(<PriceCellKey, RejectedEdit>{}) Map<PriceCellKey, RejectedEdit> rejected,

    /// Value each cell held when the current view loaded — the baseline
    /// "revert all" restores to, and what makes the changed badge and the
    /// "was X" tooltip possible (FR-024).
    @Default(<PriceCellKey, String?>{}) Map<PriceCellKey, String?> baseline,

    /// Newest last. One entry per undoable change (FR-016, FR-024).
    @Default(<PriceChange>[]) List<PriceChange> history,
  }) = _PricingGridState;
}
```

Derived, not stored: `changedCount` (cells whose current value ≠ `baseline`),
`rejectedCount` (`rejected.length`), `hasChanges` (either non-zero) — the summary
bar's three numbers (FR-023).

**Draft text is not here.** The cell being edited holds its own text in a
`ConfirmableFieldController` (R3); the controller learns of it only at commit.

## 5. `PriceChange` — one undoable unit

```dart
@freezed
class PriceChange with _$PriceChange {
  const factory PriceChange({
    /// What the change was, for the summary bar's wording.
    required PriceChangeKind kind,   // cell | fillDown | copyFromCost | adjustPercent
    /// Every cell the change touched, with the value it held before.
    required List<PriceWrite> writes,
  }) = _PriceChange;
}

@freezed
class PriceWrite with _$PriceWrite {
  const factory PriceWrite({
    required PriceCellKey cell,
    /// `null` = the cell had no price row before this change.
    required String? previous,
    required String next,
  }) = _PriceWrite;
}
```

A single-cell edit is a `PriceChange` with one `PriceWrite`; a column action is one
`PriceChange` with many — which is exactly FR-016 ("one undo, not nine"), expressed
in the type rather than in the undo code.

**Undo is a forward write.** Reversing a `PriceChange` issues writes restoring each
`previous`, and can itself fail; it is not a local rollback (spec Assumptions,
§VII).

## 6. `RejectedEdit`

```dart
@freezed
class RejectedEdit with _$RejectedEdit {
  const factory RejectedEdit({
    required String typed,     // what the user typed, shown in the cell
    required String reason,    // localized message / error code
  }) = _RejectedEdit;
}
```

## 7. `PricingGridFilter`

The provider key, built from `ListQuery` exactly as `ProductFilter` is, so the URL
stays the source of truth for narrowing (spec 017 pattern):

```dart
@freezed
class PricingGridFilter with _$PricingGridFilter {
  const factory PricingGridFilter({
    @Default('') String search,
    @Default(0) int pageIndex,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    int? supplier,
    @Default(<int>[]) List<int> labels,
    /// US2, ships with mbe-api#184 — until then always null (FR-019).
    int? missingPriceList,
  }) = _PricingGridFilter;
}
```

**Shown columns are not in this filter** and not in the URL: they change which
attributes are shown, not which records (R9). They live in a session-scoped
provider holding `Set<int>` of price list ids, seeded to every list.

## 8. State transitions of a cell

```text
        click (canUpdate)          commit, parse ok
reading ─────────────────► editing ─────────────────► inFlight
   ▲                          │                          │
   │ Escape / blur w/o change │                          │ 200
   └──────────────────────────┘                          ▼
   ▲                                                  reading (changed)
   │        parse fails, or server refuses               │
   └────────────────── rejected ◄────────────────────────┘
```

- `reading (changed)` = current value ≠ `baseline` → the "saved" badge and the
  "was X" tooltip.
- `rejected` keeps the typed text on screen and leaves `rows` untouched (FR-009);
  it clears when the same cell is next committed successfully, or on revert-all.
- No cell can be `editing` while another is — one active cell at a time (R3).
