# Contract: CatalogFilterBar actions slot — `core/widgets/catalog_filter_bar.dart` (edit)

Adds a trailing action region so catalogs place Add/Merge beside the search bar instead of in the app bar (FR-018–FR-021).

## Signature (additive, backward-compatible)

```dart
class CatalogFilterBar extends StatelessWidget {
  const CatalogFilterBar({
    super.key,
    required this.search,
    this.filters = const [],
    this.actions = const [], // NEW: entity actions, rendered between search and filters
  });
}
```

## Behavior

- `actions` render **between** `search` and `filters` (Filters button) — closer to the search box, with Filters last — in both the single-row layout (≥ 840 px) and the reflowed `Wrap`/`Column` layout (< 840 px), inheriting the existing anti-overflow reflow (FR-021).
- The **Add** action is passed by callers as a **primary**-styled control (e.g. `FilledButton.icon`) — visually distinct from the outlined/icon Filters and secondary actions (FR-019). This contract does not style actions itself; it positions them.
- Empty `actions` ⇒ unchanged current rendering (existing callers/tests unaffected).

## Caller changes

- **Products list** (`products_list_screen.dart`): remove `AppBar.actions`; pass `actions: [ if (canMerge) MergeButton, if (canCreate) AddProductButton(primary) ]`. Keys preserved: `merge_products_button`, `new_product_button`.
- **Users list** (`users_list_screen.dart`): remove `AppBar.actions`; pass `actions: [ if (canCreate) AddUserButton(primary) ]`. Key preserved: `new_user_button`.
- Both screens drop their own `Scaffold`/`AppBar` (shell owns them) and return the `Column(filterBar, Expanded(table))` body.

## Acceptance (widget tests)

1. `catalog_filter_bar_test.dart`: with `actions` non-empty, the actions render between the search box and the filters at wide width and remain present (no overflow) at narrow width.
2. `products_list_screen_test.dart` (edit): `new_product_button` and `merge_products_button` are found **within the filter bar region**, not in an `AppBar`; Add uses the primary style; both hidden when the respective privilege is absent (FR-020).
3. `users_list_screen_test.dart`: `new_user_button` renders beside the search bar and is hidden without `users.create`.
