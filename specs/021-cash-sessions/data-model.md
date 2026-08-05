# Phase 1 Data Model: Cash Session Open, Close and Count

**Feature**: `021-cash-sessions` | **Date**: 2026-08-04 | **Research**: [research.md](./research.md)

All entities are hand-written `freezed` classes with a `fromResponse` factory, per the
convention in `lib/features/catalog/domain/entities/cash_drawer.dart`: `@freezed class X
with _$X`, one `const factory`, `part 'x.freezed.dart'` only (no `.g.dart`), foreign keys
flattened, derived/display logic in an `extension`, never in the freezed body.

Monetary values are `String` on every entity — the repo-wide convention. Arithmetic
happens only in `money.dart` (§7).

---

## 1. `CashSession` — `lib/features/sales/domain/entities/cash_session.dart`

A cashier's shift on one cash drawer. Used for both list rows and detail; the backend
returns the same shape from all three read operations, so there is no separate
`CashSessionListItem`.

| Field | Type | Null | Source | Notes |
|---|---|---|---|---|
| `cashSessionId` | `int` | no | `cash_session_id` | |
| `cashDrawerId` | `int` | no | `cash_drawer` | Bare FK — no name from the API (§5) |
| `cashierId` | `int` | no | `cashier` | Bare FK — employee id |
| `start` | `DateTime` | no | `start` | Shift open time |
| `end` | `DateTime?` | **yes** | `end` | `null` ⇒ still open. The status discriminator |
| `cashSupervisorId` | `int?` | **yes** | `cash_supervisor` | Whoever closed it; `null` while open |
| `openingAmount` | `String` | no | `opening_amount` | Decimal-as-string |
| `paymentsByMethod` | `List<PaymentMethodTotal>` | no | `payments_by_method` | Defaults to `const []` — the wire field is nullable |

**Deliberately absent**: any `status` field. The API returns none (only
`GET /current` reports a state, and only for the caller). Status is derived — §3.

**Deliberately absent**: the closing denomination breakdown. No read operation returns it
(spec FR-033, D-004). Nothing on this entity should suggest it exists.

### Validation rules

None on read. This entity is never constructed from user input — opening and closing are
modelled as separate request shapes (§5, §6), not as a mutable session.

### Extension — `CashSessionDisplay`

```
String cashDrawerDisplayName(String? resolvedName)   // falls back to '#$cashDrawerId'
String cashierDisplayName(String? resolvedName)      // falls back to '#$cashierId'
```

Follows `CashDrawerFacilityDisplay`'s posture: the caller passes the resolved name (or
`null`), and the extension supplies the fallback. Keeps `BuildContext` and l10n out of the
domain layer.

---

## 2. `PaymentMethodTotal` — same file

One payment method's total for a session.

| Field | Type | Null | Source |
|---|---|---|---|
| `method` | `int` | no | `method` |
| `total` | `String` | no | `total` |

`method` stays a raw `int`, not a `PaymentMethod` enum, because `PaymentMethod.fromCode`
returns `null` for unrecognized codes and the documented posture is to render the raw code
rather than crash. Mapping to the enum happens at the display edge.

**Net of refunds.** A cash refund paid out of the drawer lands as a *negative* customer
payment against the session, so a method's `total` can be lower than the gross received
and can in principle be negative. Nothing may describe this as "cash received".

---

## 3. `CashSessionStatus` — `lib/features/sales/domain/cash_session_status.dart`

```
enum CashSessionStatus { open, stale, closed }

CashSessionStatus cashSessionStatusOf(CashSession session, {required DateTime today})
```

Pure function, in the domain layer so it is unit-testable without a widget. Replicates
mbe-api's `session_state` exactly:

| Condition | Result |
|---|---|
| `end != null` | `closed` |
| `end == null` && `start` date `< today` date | `stale` |
| `end == null` otherwise | `open` |

`today` is injected rather than read from `DateTime.now()` inside the function, so the
midnight-boundary case (spec Edge Cases) is testable.

**Not to be confused with** `SessionState` (§4), which is the caller-scoped three-way
answer from `GET /current`. The two agree for a single session but answer different
questions: `CashSessionStatus` describes *a* session, `SessionState` describes *this
user's* situation.

### State transitions

```
     (open)                    (close)
 ∅ ─────────▶ open ──────────────────────────▶ closed   [terminal]
                │
                └─ becomes `stale` at midnight (derived, never written)
```

`stale` is not a fourth state — it is `open` with an older start date. There is no
transition *into* `stale` and none out of it except `close`. `closed` is terminal: the API
exposes no update, delete, or reopen (FR-032).

---

## 4. `CurrentSession` — `lib/features/sales/domain/entities/current_session.dart`

The signed-in user's shift situation, from `GET /cash-sessions/current`.

| Field | Type | Null | Source |
|---|---|---|---|
| `state` | `SessionState` | no | `state` |
| `session` | `CashSession?` | **yes** | `session` |

```
enum SessionState { none, open, stale }
```

Mapped from the generated `SessionState` enum class (`none` / `open` / `stale`). Note the
wire enum has **no `closed` member** — a closed session is simply not the caller's current
one.

### Invariant the UI must not assume away

`state == none` ⟺ `session == null`. For `open` and `stale`, `session` is present. But
`GET /current` returns only the **most recent** open session when a cashier has several
(legacy data has cashiers with three and four). So `CurrentSession` is not a complete
picture of the user's open sessions, which is exactly why FR-004 requires the shift panel
to say that others may exist, and why the history list is the only path to them (FR-034).

---

## 5. Opening a session — request shape

Not an entity. The repository method takes the two fields directly:

```
Future<CashSession> open({int? cashDrawerId, required String openingAmount})
```

| Field | Wire | Required | Constraint |
|---|---|---|---|
| `cashDrawerId` | `cash_drawer` | no | Omitted ⇒ server falls back to the user's assigned drawer |
| `openingAmount` | `opening_amount` | no (defaults `0`) | `>= 0`; validated client-side before submit (FR-008) |

`openingAmount` is a `String`, matching the entity convention, and is written through the
generated `OpeningAmount` wrapper. **That wrapper is an `AnyOf<String, num>`, not a
scalar** — it must be built as `AnyOf2<String, num>(values: {0: value})` with the `String`
arm at key `0`. Reversing the type parameters throws a type mismatch at runtime; the
existing `_setCommission` / `_setHighProfitMargin` shims in
`payment_method_option_repository_impl.dart:162` and `price_list_repository_impl.dart:171`
carry that warning explicitly. One `_setOpeningAmount(OpeningAmountBuilder, String)` shim
is needed here.

### Failure outcomes and their client meaning

| Status | Backend detail | Client handling |
|---|---|---|
| 409 | `That cash drawer already has an open session` | Drawer-busy. Remedy: pick another drawer |
| 409 | `You already have an open session; close it before opening another` | Cashier-busy. Remedy: navigate to that session and close it |
| 422 | `No cash drawer is configured for your user; set one or supply it explicitly` | Predicted client-side (FR-007) and normally never reached |
| 404 | `Cash drawer not found` | Drawer vanished between picker load and submit |

The two 409s are **not** distinguished by their detail text. Per research §4, the client
re-reads `GET /current`: a session now present means cashier-busy, absent means
drawer-busy. The detail string is still shown as the banner's secondary line.

---

## 6. Closing a session — request shape

```
Future<CashSession> close({required int cashSessionId, required List<DenominationCount> counts})
```

### `DenominationCount` — `lib/features/sales/domain/entities/denomination_count.dart`

| Field | Type | Wire | Constraint |
|---|---|---|---|
| `denomination` | `String` | `denomination` | `> 0`; always a value from the ladder (§8) |
| `quantity` | `int` | `quantity` | `>= 0`, whole number (FR-022) |

Same `AnyOf<String, num>` wrapper problem as `openingAmount` — the generated
`Denomination` type needs its own `String`-arm-at-key-`0` shim.

**Only rows with `quantity > 0` are submitted** (FR-020). The server would accept zero
rows, and would accept an entirely empty list, but the client requires either a non-empty
count or an explicit "counted and empty" confirmation (FR-021).

**Write-only.** Once submitted, no operation returns these rows. The counted total and
difference are computed client-side and shown in the close confirmation because that is
the only moment they can be seen (FR-023).

### Failure outcomes

| Status | Backend detail | Client handling |
|---|---|---|
| 409 | `Session is already closed` | Report plainly, refresh session state, keep the entered counts (FR-024) |
| 404 | `Cash session not found` | Session vanished |
| 403 | `Insufficient privileges` | Should be unreachable — the action is hidden without 111 (FR-025) |

---

## 7. `money.dart` — `lib/features/sales/domain/money.dart`

Not an entity; the arithmetic boundary. Wraps `package:decimal`. Values are `String` on
the way in and out; `Decimal` never escapes this file.

```
Decimal parseAmount(String value)            // exact; throws on malformed input
String formatAmount(Decimal value)           // canonical string form
Decimal countedTotal(List<DenominationCount> counts)
Decimal expectedCash({required String openingAmount, required List<PaymentMethodTotal> payments})
Decimal difference({required Decimal counted, required Decimal expected})
```

`expectedCash` sums `openingAmount` plus only those `paymentsByMethod` entries whose
`method == PaymentMethod.cash.code` (1). Every other method is excluded — a card payment
never entered the drawer. Because the per-method total is net of cash refunds, the result
is the cash the drawer *should* hold from payments, not the cash it received.

**Known incompleteness, by design**: expense vouchers, cash-on-delivery movements and any
other drawer outflow are not in `payments_by_method` and cannot be obtained. This is why
FR-018 requires the figure be labelled advisory. `money.dart` must not pretend otherwise —
its doc comment states the omission.

The unit test asserts the exactness property directly: a full ladder count summed as
`Decimal` equals the expected total to the cent, where the same sum in `double` does not.

---

## 8. `denominations.dart` — `lib/features/sales/domain/denominations.dart`

```
const List<String> kMxnDenominations = [
  '1000', '500', '200', '100', '50', '20', '10', '5', '2', '1', '0.50',
];
```

Eleven distinct values, descending. Declared as strings so they round-trip through
`money.dart` without a `double` ever appearing. Client-owned because mbe-api has no
denomination catalog, constant, or config of any kind (research §8). MXN only.

The 20-peso value appears once, though it circulates as both a note and a coin, because
`cash_count.type` cannot represent the distinction and two rows of the same value would
only confuse the count.

---

## 9. `CashSessionFilter` — `lib/features/sales/presentation/cash_sessions_list_controller.dart`

The freezed family key for the history list, built from the URL. Value equality is what
makes the Riverpod family work, so it must be `freezed`, not a plain class.

| Field | Type | Default | URL source |
|---|---|---|---|
| `cashDrawerId` | `int?` | `null` | facet `cash-drawer` |
| `pageIndex` | `int` | `0` | `?page=` (1-based in URL, 0-based here) |

```
factory CashSessionFilter.fromQuery(ListQuery query)
extension CashSessionFilterBadge → activeFilterCount, hasActiveFilters
```

**No `search` field.** Every other catalog filter carries one; this endpoint has none and a
session has no free-text field to match (research §12, spec D-003). Adding a dead `search`
field would imply a capability that does not exist.

---

## 10. `CashSessionListResult` — in the repository interface file

```
class CashSessionListResult {
  const CashSessionListResult({required this.items, required this.total});
  final List<CashSession> items;
  final int total;
}
```

Plain class with a `const` constructor, declared in
`domain/repositories/cash_session_repository.dart` — matching `CashDrawerListResult`
exactly. The presentation layer converts it to the shared `CatalogPage<CashSession>`; the
repository never returns `CatalogPage`.

---

## 11. Form state

Two separate freezed states, because opening and closing are different tasks with
different privileges and different failure modes. Both follow
`cash_drawer_form_controller.dart`: synchronous `Notifier` (not `AsyncNotifier`), error
codes as `static const String` on an `abstract final class`, `saved` boolean for success,
field setters that clear errors, and an RBAC re-check at submit time.

### `OpenSessionFormState`

| Field | Type | Default | Purpose |
|---|---|---|---|
| `cashDrawerId` | `int?` | `null` | Seeded from `userSettings.cashDrawerId` |
| `cashDrawerDisplayText` | `String` | `''` | Seeded from `userSettings.cashDrawerName` — no request needed |
| `openingAmount` | `String` | `'0'` | |
| `submitting` | `bool` | `false` | |
| `saved` | `bool` | `false` | Screen watches this and refreshes the shift panel |
| `error` | `String?` | `null` | An `OpenSessionErrorCode` |
| `errorDetail` | `String?` | `null` | Raw server detail, banner's second line |
| `fieldErrors` | `Map<String, String>` | `{}` | Keyed by `loc.last` from a 422 |

Error codes: `drawerRequired`, `amountNegative`, `amountInvalid`, `drawerBusy`,
`cashierBusy`, `noDrawerConfigured`, `drawerNotFound`, `openFailed`,
`openPermissionDenied`.

### `CloseSessionFormState`

| Field | Type | Default | Purpose |
|---|---|---|---|
| `cashSessionId` | `int?` | `null` | |
| `quantities` | `Map<String, int>` | `{}` | Keyed by denomination string; absent ⇒ 0 |
| `countedTotal` | `String` | `'0'` | Recomputed on every quantity change |
| `expectedCash` | `String` | `'0'` | From the loaded session |
| `difference` | `String` | `'0'` | `counted - expected`; sign carries over/short |
| `submitting` | `bool` | `false` | |
| `closed` | `bool` | `false` | |
| `error` / `errorDetail` / `fieldErrors` | as above | | |

Error codes: `quantityInvalid`, `alreadyClosed`, `sessionNotFound`, `closeFailed`,
`closePermissionDenied`.

`countedTotal`, `expectedCash` and `difference` are stored as recomputed strings rather
than derived at render time so that FR-017's "updates immediately" is a property of the
state, and a widget test can assert the three figures after a single quantity change
without reaching into formatting.

**Not persisted.** A close form abandoned mid-count is lost (spec A-009). Nothing caches
it, per constitution §VII.

---

## 12. Relationships

```
CashSession ──1:1──▶ CashDrawer        (cashDrawerId; name resolved via a cached map)
CashSession ──1:1──▶ Employee          (cashierId; name resolved per distinct id)
CashSession ──0:1──▶ Employee          (cashSupervisorId; detail screen only)
CashSession ──1:N──▶ PaymentMethodTotal (embedded, aggregate — not individual payments)
CashSession ──1:N──▶ DenominationCount  (write-only; never read back)

CurrentSession ──0:1──▶ CashSession    (the caller's most recent open one)
```

Neither `CashDrawer` nor `Employee` is redefined here — both already exist in
`lib/features/catalog/domain/entities/`. Constitution §I sanctions a sales feature
importing `features/catalog/domain`, since `catalog` is the shared master-data module.

`paymentsByMethod` is an **aggregate**, not a list of payments. Drilling into the
individual payments of a session would need `GET /customer-payments?cash_session=`, which
this feature does not use.
