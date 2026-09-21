# Phase 1 Data Model: Fix List Origin Filtering and Cash Session List Refresh

**Feature**: `041-fix-list-origin-refresh` | **Date**: 2026-09-20

> **Amended 2026-09-20.** The origin facet and column were removed after
> review (see spec.md § Amendments, contracts/origin-filter.md §0). Two
> things below no longer describe the built code:
> - **§2 `OpenSale.origin` was reverted** — with no column to render, nothing
>   read it, so the field and its mapping were removed again. `OpenSale` is
>   exactly as it was before this feature.
> - **§3's two filter fields were reverted** — `PosSalesFilter.hideBackOffice`
>   and `SalesOrdersFilter.hidePointOfSale` do not exist; neither filter
>   class changed at all, and no URL facet was added.
>
> **§4 stands, with one change**: `listSales` takes `SaleOrigin? origin`
> (inclusive) rather than `excludeOrigin`; `listOrders` takes
> `SaleOrigin? excludeOrigin` as described. Both are passed unconditionally
> by their controllers rather than from filter state. §1, §5 and §6 are
> unaffected.

This feature introduces **no new entity**. It adds one field to an existing
entity, one facet to two existing filter values, and one parameter to two
existing repository methods. Everything else listed here is unchanged and
recorded only to pin what must *not* drift.

---

## 1. `SaleOrigin` — unchanged, and load-bearing

`lib/features/sales/domain/entities/sale_origin.dart:15-38`

```dart
enum SaleOrigin { pointOfSale, backOffice }
```

| Domain value | Wire (`api.OrderOrigin`) | Meaning |
|---|---|---|
| `SaleOrigin.pointOfSale` | `number0` → `0` | Raised at a register |
| `SaleOrigin.backOffice` | `number1` → `1` | Raised in the back office |
| `null` | absent / unknown | **Never recorded.** Not a synonym for either member. |

Converters already exist and are reused as-is: `SaleOrigin.fromApi(api.OrderOrigin?)`
(inbound, returning `null` for an absent value) and `toApi()` (outbound).

**Invariant this feature must preserve**: `null` is a distinct third state, and
no code added here may collapse it into a member or hide it from a list
(FR-005). The enum deliberately has no `unrecorded` member; absence is modelled
by nullability.

---

## 2. `OpenSale` — gains `origin`

`lib/features/sales/domain/entities/open_sale.dart:11-49`

The row entity both lists render. Currently:

```dart
@freezed
class OpenSale with _$OpenSale {
  const factory OpenSale({
    required int id,
    int? serial,
    String? customerName,
    String? customerDisplayName,
    required String total,
    required String balance,
    required SaleStatus status,
    required DateTime date,
  }) = _OpenSale;

  factory OpenSale.fromResponse(api.SalesOrderSummary r) => OpenSale(/* … */);
}
```

**Change**: add one optional field and one mapping line.

| Field | Type | Source | Notes |
|---|---|---|---|
| `origin` | `SaleOrigin?` | `SaleOrigin.fromApi(r.origin)` | Nullable; absent on pre-#209 orders |

The wire field is confirmed present on the list projection —
`api.SalesOrderSummary.origin` is `OrderOrigin?`
(`lib/generated/openapi/lib/src/model/sales_order_summary.dart:72-73`), and its
deserializer skips a null value, leaving `r.origin == null`. **No codegen
against mbe-api is required**; only `freezed` regeneration for `OpenSale`.

**Compatibility**: the field is optional, so every existing `OpenSale(...)`
construction site (fixtures included) stays valid without edit.

**Not changed**: `Sale.origin` (`sale.dart:36-42,77`) already exists and is
untouched. `OpenSalePage` (`sales_order_repository.dart:187-191`) is unchanged.

---

## 3. Filter values — each gains one facet field

Both are `freezed` classes used directly as the Riverpod family key, so any
added field participates in equality and therefore in cache identity.

### `PosSalesFilter` — `pos_sales_list_controller.dart:26-64`

| Field | Type | Default | Status |
|---|---|---|---|
| `from`, `to` | `DateTime` | today | unchanged |
| `status` | `SaleStatus?` | `null` | unchanged |
| `search` | `String` | `''` | unchanged |
| `pageIndex` | `int` | `0` | unchanged |
| **`hideBackOffice`** | **`bool`** | **`false`** | **new** |

### `SalesOrdersFilter` — `orders/sales_orders_list_controller.dart:34-75`

| Field | Type | Default | Status |
|---|---|---|---|
| `from`, `to` | `DateTime` | current month | unchanged |
| `status` | `SaleStatus?` | `null` | unchanged |
| `salesperson`, `facility` | `int?` | `null` | unchanged (admin-only) |
| `search` | `String` | `''` | unchanged |
| `pageIndex` | `int` | `0` | unchanged |
| **`hidePointOfSale`** | **`bool`** | **`false`** | **new** |

**Why a non-nullable `bool` rather than a `SaleOrigin?`**: per screen only one
exclusion is meaningful (research R3), so the *screen-level* state is genuinely
binary and the `false` default reproduces today's behaviour exactly (FR-012).
The mapping from that boolean to the domain value happens at the controller
boundary, where the screen's identity is known:

- POS list: `hideBackOffice ? SaleOrigin.backOffice : null`
- Pedidos list: `hidePointOfSale ? SaleOrigin.pointOfSale : null`

**Derived members** (in the existing `…FilterBadge` extensions) must account for
the new field: `activeFilterCount` (+1 when set) and `hasActiveFilters`. See
contracts/origin-filter.md for the full four-point registration checklist.

---

## 4. Repository contract — one new parameter, two methods

`lib/features/sales/domain/repositories/sales_order_repository.dart`
(declarations at :151-159 and :174-184) and its impl
(`lib/features/sales/data/sales_order_repository_impl.dart:273-334`).

Both `listSales(...)` and `listOrders(...)` gain:

```dart
SaleOrigin? excludeOrigin,
```

…forwarded to the already-generated parameter as
`excludeOrigin: excludeOrigin?.toApi()`. A `null` value omits the query
parameter entirely (the generated method only emits it `if (x != null)`), so the
default call is byte-identical to today's.

This matches existing house style: `open({..., SaleOrigin? origin})`
(`sales_order_repository.dart:40`) already takes a domain `SaleOrigin` and
converts at the boundary. The third sibling `listOpen(...)` (:133-139) is **not**
changed — it backs the register's resume flow, not a user-facing list.

**Layering**: the domain signature speaks `SaleOrigin`, never `api.OrderOrigin`;
the generated enum stays behind the `data` layer (constitution I and III).

---

## 5. Cash session entities — unchanged

No data change is required for fix 3. Recorded for completeness:

- `CashSessionFilter` (`cash_sessions_list_controller.dart:19-39`) —
  `{cashDrawerId, cashierId, status, pageIndex}`, unchanged. The fix must keep
  each family instance's own filter intact (FR-011), which bare-family
  invalidation does by construction: each instance re-runs `build(filter)` with
  the argument it already had.
- `CashSession`, `CurrentSession`, `CashSessionStatus` — unchanged.

The change is behavioural, not structural: two controllers each gain one
`ref.invalidate(...)` call. See contracts/list-refresh.md.

---

## 6. State transitions

Nothing in this feature introduces a state machine. The one transition worth
naming is the cash session lifecycle that fix 3 must make visible, because *when*
the list re-reads is the whole requirement:

```text
  none ──open()──▶ open ──close()──▶ closed
         │                    │
         └── invalidate ──────┴── invalidate
             currentSessionControllerProvider   (existing, kept)
             cashSessionsListControllerProvider (new, this feature)
```

A cancelled form never reaches `submit()`, so neither invalidation fires — which
is FR-010, satisfied by construction rather than by a guard.
