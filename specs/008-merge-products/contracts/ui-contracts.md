# Contract: Merge Products UI

## 1. `CatalogEntityPicker<T>` extension (shared widget)

`lib/core/widgets/catalog_entity_picker.dart`. Add **optional, backward-compatible**
parameters so a picker can render richer option rows (photo + subtitle). Existing
callers (supplier, SAT catalog) pass none and keep today's text-only behavior.

```dart
const CatalogEntityPicker({
  // …existing params…
  this.optionImageUrl,   // String? Function(T)?  — leading thumbnail URL (nullable per item)
  this.optionSubtitle,   // String? Function(T)?  — secondary line under displayStringForOption
});
```

Behavior:

- When `optionImageUrl` or `optionSubtitle` is non-null, the picker supplies a
  custom `Autocomplete.optionsViewBuilder` rendering each option as a Material
  `ListTile`: `leading` = a small `ProductPhoto`/thumbnail from `optionImageUrl(option)`
  (with the same placeholder behavior as elsewhere when the URL is null),
  `title` = `displayStringForOption(option)`, `subtitle` = `optionSubtitle(option)`.
- When both are null, behavior is unchanged (default text options).
- The debounce (300 ms), `enabled`/read-only rendering, min-length gating, and
  `onSelected`/clear semantics are unchanged.

## 2. `MergeProductsScreen`

`lib/features/catalog/presentation/merge_products_screen.dart`. Route
`/products/merge`. Watches `mergeProductsControllerProvider`.

Layout (Material 3, width-constrained/centered per constitution §VI — no
edge-to-edge single fields):

- **App bar**: title = `l10n.mergeProductsTitle` ("Fusión de Productos" / "Merge Products").
- **"Product" picker** (`Key('merge_canonical_field')`): `CatalogEntityPicker<ProductListItem>`
  - `label` = `l10n.mergeProductLabel` ("Producto" / "Product")
  - `optionsBuilder(query)` → if `query.trim().length < 3` return `const []`; else
    `(await productRepository.list(search: query.trim(), deactivated: null, limit: 15)).items`
  - `displayStringForOption` = product name
  - `optionImageUrl` = `(p) => p.photo`; `optionSubtitle` = code/model (e.g. `"${p.code} · ${p.model ?? ''}"`)
  - `onSelected` = `controller.canonicalSelected`
- **"Duplicate" picker** (`Key('merge_duplicate_field')`): same config; `label` =
  `l10n.duplicatedLabel` ("Duplicado" / "Duplicate"); `onSelected` = `controller.duplicateSelected`.
- **Inline validation** (`Key('merge_validation_message')`): shows
  `state.validationMessage` when present (both-required / self-merge).
- **Error banner** (`Key('merge_error_banner')`): shared `error_banner` shown when
  `state.submission` is `AsyncError`, using the mapped `AppError` message.
- **Back affordance** (`Key('merge_back_button')`): returns to `/products` without merging (FR-013).
- **Merge action** (`Key('merge_submit_button')`): label `l10n.mergeButton`
  ("Fusionar" / "Merge"); `onPressed` is `null` (disabled) unless `state.canSubmit`;
  shows a progress indicator while `state.submission.isLoading` (FR-009).

Interactions:

1. **Merge tap** → if `!canSubmit`, do nothing (button already disabled) — the
   validation message communicates why. If `canSubmit`, open the confirm dialog.
2. **Confirm dialog** (inline `showDialog<bool>` + `AlertDialog`, mirroring the
   product-delete dialog):
   - title `l10n.mergeConfirmTitle`; content `l10n.mergeConfirmMessage(canonicalName, duplicateName)`
     clearly stating the duplicate will be **permanently and irreversibly deleted** (FR-007).
   - Cancel (`Key('merge_confirm_cancel_button')`) → returns `false`, no-op, selections intact (FR US3 #4).
   - Confirm (`Key('merge_confirm_button')`, error-styled) → returns `true`.
3. On confirm `true` → `controller.submit()`.
4. **Success** (`submission` → `AsyncData`) → show success SnackBar
   (`l10n.mergeSuccess`) and navigate back to `/products` (FR-010). The screen
   listens for the success edge (e.g. `ref.listen`) to fire navigation once.
5. **Failure** (`submission` → `AsyncError`) → error banner shows the message;
   `canonical` and `duplicate` remain populated (FR-011); the user may retry or adjust.

## 3. Products-list entry point

`lib/features/catalog/presentation/products_list_screen.dart`. Add a Merge
entry point to the app-bar `actions` (an `IconButton`, e.g. `Icons.merge`, or an
overflow item), `Key('merge_products_button')`, tooltip `l10n.mergeProductsTooltip`,
shown **only** when `access.can(SystemObject.productsMerge, AccessRight.create)`
(FR-012), navigating to `context.push('/products/merge')`. Placed alongside the
existing create action, following the same `if (canX) IconButton(...)` pattern.
