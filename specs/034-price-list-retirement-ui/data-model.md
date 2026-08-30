# Phase 1 Data Model: Price List Retirement UI

Two new domain types, two repository signatures, one provider, one state change
on an existing controller. No persisted state — the whole model lives for the
lifetime of one dialog (constitution §VII).

---

## 1. Domain entities

### 1.1 `PriceListDeletePreview`

`lib/features/pricing/domain/entities/price_list_delete_preview.dart` — `freezed`,
mapped from the generated `PriceListDeletePreviewResponse` (constitution §III:
generated DTOs never reach `presentation`).

| Field | Type | Notes |
|---|---|---|
| `categories` | `List<PriceListDeleteCategory>` | In the server's order — largest count first. Never re-sorted client-side. |
| `total` | `int` | The server's own total, displayed as-is and never re-summed (FR-002). |

Derived:

| Getter | Returns | Definition |
|---|---|---|
| `isEmpty` | `bool` | `categories.isEmpty` — the "nothing depends on this list" case (FR-008). |
| `isBlocked` | `bool` | Any category with `fate == blocking` (FR-018, R11). |
| `movedCount` | `int` | Count of the `customer.price_list` category, `0` when absent. Drives "requires a replacement" (FR-009) and the "N customers move to X" line (FR-011). |
| `destroyedCount` | `int` | Count of the `product_price.list` category, `0` when absent. Drives the confirm button's label (FR-015). |

`movedCount`/`destroyedCount` are counts, not booleans, because both the gating
decision and the copy need the number, and deriving one from the other twice is
how the two drift apart.

### 1.2 `PriceListDeleteCategory`

| Field | Type | Notes |
|---|---|---|
| `key` | `String` | The raw `table.column` identifier, verbatim (`product_price.list`, `customer.price_list`, `sales_order.price_list`, …). Kept unparsed so an unknown relation survives to the UI (FR-005). |
| `count` | `int` | Rows of that relation pointing at this list. |

Derived:

| Getter | Returns | Definition |
|---|---|---|
| `fate` | `PriceListDeleteFate` | **Exact** key match (R2): `product_price.list` → `destroyed`, `customer.price_list` → `moved`, anything else → `blocking`. |
| `table` | `String` | `key.split('.').first` — the basis for label lookup and the humanized fallback. |

### 1.3 `PriceListDeleteFate`

A plain `enum` with three values. Each maps to exactly one visible treatment in
the summary panel (FR-003):

| Value | Panel note | Colour role | Meaning |
|---|---|---|---|
| `destroyed` | "deleted permanently" | `colorScheme.error` | Deleted with the list. |
| `moved` | "moved to the replacement" | `colorScheme.onSurfaceVariant` | Reassigned to the replacement. |
| `blocking` | "blocks deletion — clear these first" | `colorScheme.error` | Prevents the deletion entirely. |

**Open-set by construction**: `blocking` is the default arm, so a relation added
to mbe-api's data model after this ships lands there with no mbe-ui change
(SC-006). There is no `unknown` value — an unrecognized relation is not a
classification gap, it is a blocker, and the enum says so.

---

## 2. Repository surface

`lib/features/pricing/domain/repositories/price_list_repository.dart`

```dart
/// `GET /api/v1/price-lists/{price_list_id}/delete/preview`. Read-only.
/// Throws `NotFoundError` on 404.
Future<PriceListDeletePreview> deletePreview({required int priceListId});

/// `DELETE /api/v1/price-lists/{price_list_id}[?replacement={id}]`.
/// `replacement` is omitted from the request when null.
Future<void> delete({required int priceListId, int? replacement});
```

`delete` gains one optional named parameter; every existing call site keeps
compiling. Implementation in `data/price_list_repository_impl.dart` forwards to
the generated methods named in research R1 and maps `DioException` through the
existing `_toAppError`.

**Error surface** (unchanged mechanism, R10):

| HTTP | `AppError` | Reaches the dialog as |
|---|---|---|
| 400 (`replacement == price_list_id`) | `ServerError(400, detail)` | Refusal banner. Unreachable in practice — the picker excludes the list (FR-010) — but not assumed away. |
| 404 (list or replacement gone) | `NotFoundError(detail)` | Refusal banner. |
| 409 (still referenced) | `ServerError(409, detail)` | Refusal banner, server sentence intact. |

---

## 3. Providers

`lib/features/pricing/presentation/price_list_delete_preview_provider.dart`

```dart
@riverpod
Future<PriceListDeletePreview> priceListDeletePreview(
  PriceListDeletePreviewRef ref, { required int priceListId },
);
```

Auto-disposing and keyed by id, so the report is fetched when the dialog opens
and released when it closes. Its `AsyncValue` maps one-to-one onto three of the
dialog's states (§4).

No provider is added for the replacement picker: `CatalogEntityPicker` calls
`PriceListRepository.list(search:)` directly, as the customers filter already
does.

---

## 4. Dialog state

`PriceListDeleteDialog` is a `ConsumerStatefulWidget`. Its own `State` holds two
fields; everything else is derived from the preview `AsyncValue` and the form
controller.

| Field | Type | Reset when |
|---|---|---|
| `acknowledged` | `bool` (initially `false`) | Never within one dialog — the dialog is the scope. |
| `replacement` | `PriceList?` | Never — deliberately **survives a refusal** (FR-019), so a retry does not re-type it. |

Held in widget `State` rather than a provider because both are per-widget input
state with the dialog's own lifetime, which constitution §II names as local UI
state.

### 4.1 The seven states

Every state is a function of `(preview AsyncValue, isBlocked, isEmpty, submitting, lastError)` — there is no state enum to keep in sync with reality.

| State | Condition | Panel | Replacement | Ack | Primary action |
|---|---|---|---|---|---|
| **loading** | preview loading | skeleton | hidden | hidden | disabled |
| **clean** | resolved, `isEmpty` | "nothing depends on this list" note | hidden | hidden | enabled |
| **priced** | resolved, `movedCount == 0`, not blocked | breakdown | hidden | required | enabled once acked |
| **assigned** | resolved, `movedCount > 0`, not blocked | breakdown | **required** | required | enabled once acked + picked |
| **blocked** | resolved, `isBlocked` | breakdown, blocking rows marked | hidden | hidden | **absent**; Close only |
| **previewFailed** | preview errored | degraded note | **optional** | required | enabled once acked |
| **refused** | `lastError != null` | whatever the underlying state shows | preserved | preserved | enabled (retry) |

`refused` is an overlay on the state beneath it, not a seventh mutually-exclusive
mode — the banner is added, nothing else is taken away.

### 4.2 Confirm button label (FR-015)

| Condition | Label |
|---|---|
| `destroyedCount > 0` | "Delete list and {n} prices" |
| `destroyedCount == 0 && movedCount > 0` | "Delete list and move {n} customers" |
| otherwise (clean, blocked, previewFailed) | "Delete list" |

Counts pass through `display.count` (R3); both plural forms come from ICU
`plural` in the `.arb` files.

### 4.3 Return value

The dialog pops `PriceListDeleteOutcome?`:

```dart
({ int movedCount, String? replacementName })  // deleted
null                                            // cancelled or closed
```

The screen uses it to compose the snackbar (FR-017) and decide whether to pop.
This is the mechanism research R9 chose over a `deleted` state flag.

---

## 5. Change to `PriceListFormController`

`lib/features/pricing/presentation/price_list_form_controller.dart`

| Before | After |
|---|---|
| `Future<void> delete()` | `Future<bool> delete({int? replacement})` |
| `PriceListFormState.deleted` (`bool`) | **removed** |

`delete` keeps its RBAC pre-check, its `submitting` toggling, its
`error`/`errorDetail` reporting and its `ref.invalidate(priceListsListControllerProvider)`.
It returns `true` only on a 204. `deleted` is read by nothing else once the
screen stops watching it (R9), so its removal is cleanup from this change rather
than an unrelated edit.

---

## 6. Formatting surface addition

`lib/core/formatting/app_formatters.dart` — one method on `DisplayFormatters`:

```dart
/// A whole-number count with locale grouping, e.g. 4312 → "4,312" (en) /
/// "4.312" (es-MX). Not [quantity]: that takes a decimal string and drops
/// trailing zeros without grouping.
String count(int value);
```

Non-nullable `int`, so no `emptyValuePlaceholder` case — a count is always
present or its row is not rendered. Justification and the alternatives are in
research R3.
