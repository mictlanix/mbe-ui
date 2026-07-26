# Contract: list loading / empty / filtered-empty / error views

**Feature**: `017-ui-consistency-filters` | Satisfies FR-027 – FR-032
**Prerequisite**: localizing `ErrorBanner` (research §6)

Replaces the ad-hoc rendering currently repeated in all 18 list screens:

```dart
loading: () => const Center(child: CircularProgressIndicator()),
error: (e, _) => Center(child: Text(l10n.<entity>LoadError(e))),   // raw exception in a string
data: (page) => page.items.isEmpty
    ? Center(child: Text(l10n.no<Entity>Found))                    // no empty/filtered distinction
    : DataTableView<…>(…),
```

## 0. Prerequisite: `ErrorBanner` must be localized first

`ErrorBanner` — the widget constitution §III designates as *the* shared error
surface — hard-codes all five of its messages in English
(`lib/core/widgets/error_banner.dart:60-75`), taking a `BuildContext` it never uses.
Pointing 18 more screens at it would multiply an existing §V violation across the
app, so this is a **blocking prerequisite**, not a follow-up:

| Variant | New key |
|---|---|
| `ValidationError` (no field errors) | `errorValidationGeneric` |
| `AuthError` | `errorAuthGeneric` |
| `NotFoundError` | `errorNotFoundGeneric` |
| `ServerError` | `errorServerGeneric` |
| `NetworkError` | `errorNetworkGeneric` |

Field-level `ValidationError` messages keep coming from the server unchanged. The
fix also repairs the record screens that already use `ErrorBanner`.

## 1. The four states

Selected from the `AsyncValue` plus the screen's `ListQuery` — no new state is
introduced, because `query.isFiltered` already distinguishes the two empty cases
(FR-028).

| State | Condition | Content | Recovery |
|---|---|---|---|
| `loading` | `isLoading` and no previous data | centered progress indicator | — |
| `empty` | items empty **and** `!query.isFiltered` | icon + "no records yet" message | **Create the first record** — rendered only with the create privilege (FR-029) |
| `filteredEmpty` | items empty **and** `query.isFiltered` | icon + "nothing matched your filters" | **Clear filters** → `context.go(barePath)` (FR-030) |
| `failed` | `hasError` | `ErrorBanner` with the mapped `AppError` | **Retry** → re-fetch the same query unchanged (FR-032) |

Each state must be visually distinguishable from the other three (SC-007) — the two
empty states differ in icon, message, and offered action, not wording alone.

## 2. Error typing

`failed` renders the `AppError` through `ErrorBanner`; the raw error object is
**never** interpolated into a string (FR-031). Repositories already map
`DioException` → `AppError` via `_toAppError`, so `AsyncValue.error` carries the
right type today; anything else degrades to `ServerError` rather than being shown
raw.

The per-entity `l10n.<entity>LoadError(e)` keys become unused. Leave them in place
rather than deleting 18 keys from both locales in the same change — removal is
mechanical cleanup, better done once the conversion is complete and nothing
references them.

## 3. Interface

```dart
CatalogListStateView({
  required AsyncValue<CatalogPage<T>> state,
  required bool isFiltered,
  required Widget Function(CatalogPage<T>) onData,
  required String emptyMessage,
  required String filteredEmptyMessage,
  String? createLabel,          // null ⇒ no create affordance (no privilege)
  VoidCallback? onCreate,
  required String clearFiltersLabel,
  required VoidCallback onClearFilters,
  required String retryLabel,
  required VoidCallback onRetry,
})
```

Entity-specific strings are caller-supplied, per the `catalog_action_icons`
convention; only genuinely generic strings (`retry`, `clear filters`, the
filtered-empty title) become new shared keys. A null `onCreate` means the affordance
is absent, not disabled — same posture as `RecordFormActions`.

## 4. Also applies to

`pricing_screen.dart` renders the same four states ad hoc
(`pricing_screen.dart:99-105`, including a `pricingLoadError(state.error!)`
interpolation) and adopts the shared views even though it is not a paginated catalog
list. Its "select a product first" prompt is a fifth, screen-specific state that
stays local.

**Out of scope**: that screen's table empty-space and footer layout issues, which
remain deferred.

## 5. Test obligations

- Each of the four states renders its own treatment, and the four are mutually
  distinguishable.
- `empty` vs `filteredEmpty` is chosen by `isFiltered`, not by item count alone.
- The create affordance is absent without the create privilege.
- Clear-filters navigates to the bare list path.
- Retry re-fetches with search, facets, and page unchanged.
- **No list screen renders a raw exception**: assert that no rendered `Text` contains
  the mapped error's `toString()`.
- `ErrorBanner` renders localized text in both `en` and `es`.
