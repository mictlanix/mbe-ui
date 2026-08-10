# Data Model: POS Sales List, Full-Width Workspace, Capture Polish

**Feature**: `023-pos-ux-improvements` | **Date**: 2026-08-10

This feature adds no new backend resource and no new persisted state. What
follows is the shape of the view state it introduces, the one derived predicate
it depends on, and the reused types it deliberately does **not** duplicate.

---

## §1 The list row — `OpenSale`, reused as-is

**No new entity.** `lib/features/sales/domain/entities/open_sale.dart` is already
the freezed mapping of `SalesOrderSummary`, and it carries exactly the columns
the list shows:

| Field | Type | Source | Shown as |
|---|---|---|---|
| `id` | `int` | `salesOrderId` | Reference, when no folio yet |
| `serial` | `int?` | `serial` | Folio, once assigned |
| `customerName` | `String?` | `customerName` | Customer |
| `date` | `DateTime` | `date` | Date and time |
| `status` | `SaleStatus` | `status` | Status chip |
| `total` | `String` | `total` | Total (right-aligned, never truncated) |
| `balance` | `String` | `balance` | Balance (right-aligned, never truncated) |

**Recorded naming wart.** The type is named for the selector that first needed
it, and the list also shows sales that are *not* open (finished, cancelled). A
rename to `SaleSummary` would be honest but touches 45 references across 9
hand-written files including the shipped selector and its tests — a diff with no
behavioural content. It is left as an optional follow-up, not done here.

**Page wrapper.** `OpenSalePage {items, total}` is likewise reused for the new
repository call; it is already exactly "a page of summaries plus the server's
total".

## §2 `PosSalesFilter` — the list's addressable view state

New freezed class beside its controller, modelled on `CashSessionFilter`
(spec 021) so the two list screens in this feature module read alike.

```dart
@freezed
class PosSalesFilter with _$PosSalesFilter {
  const factory PosSalesFilter({
    required DateTime from,          // inclusive, local wall-clock date
    required DateTime to,            // inclusive, local wall-clock date
    SaleStatus? status,              // null = every status
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _PosSalesFilter;

  factory PosSalesFilter.fromQuery(ListQuery query, {required DateTime today});
}
```

The register is **not** a field: it is read from `registerPointSaleProvider` by
the controller, because it is not something the cashier may vary (FR-003) and
therefore has no business being addressable.

### §2.1 URL encoding

| Facet key | Value | Absent means |
|---|---|---|
| `date-from` | `yyyy-MM-dd` | today |
| `date-to` | `yyyy-MM-dd` | today |
| `status` | `SaleStatus.name` (`draft`, `completed`, `paid`, `cancelled`) | every status |
| `search` | free text (a `ListQuery` reserved key, not a facet) | no search |
| `page` | 1-based (a `ListQuery` reserved key) | page 1 |

`fromQuery` is **total** — it never throws, matching `ListQuery`'s contract: an
unparseable date or an unknown status name degrades to its default. `today` is
injected rather than read from the clock so the decode is testable.

### §2.2 Derived

```dart
extension PosSalesFilterBadge on PosSalesFilter {
  bool get isToday;               // from == to == today — the default range
  int get activeFilterCount;      // range-not-today + status + search
  bool get hasActiveFilters;
}
```

`activeFilterCount` drives the filter-sheet badge every other list screen shows;
`isToday` distinguishes "no sales today" from "no sales matching your filters" in
the empty state (FR-010).

## §3 `saleIsWorkable` — the one derived predicate

New pure function in `lib/features/sales/domain/sale_workability.dart`, unit
tested in isolation (research R4):

```dart
/// Whether a listed sale can still be worked on, and therefore whether its
/// row offers Edit (FR-006).
///
/// [resumableIds] is the register's open-sales set for the current trading
/// day — `openSalesSelectorControllerProvider`'s own answer, which is the
/// single source of truth spec 020 FR-058 defined. It is consulted only for
/// the one case a summary cannot decide: a zero-balance paid sale, workable
/// only when it is a delivery sale with an unfinished distribution.
bool saleIsWorkable(OpenSale sale, {required Set<int> resumableIds});
```

| Status | Balance | Verdict | Decided by |
|---|---|---|---|
| `draft` | any | workable | the row |
| `completed` | non-zero | workable | the row |
| `completed` | zero | `resumableIds` | the set |
| `paid` | non-zero | workable | the row (it owes money) |
| `paid` | zero | `resumableIds` | the set |
| `cancelled` | any | not workable | the row |

Zero-balance comparison uses `isZeroAmount` from `features/sales/domain/money.dart`
— never `double` parsing, and never a string compare against `'0'` (mbe-api
returns `'0.00'`, `'0.000000'` and `'0'` in different places).

**Cost.** Zero additional requests per row. When `resumableIds` has not resolved
yet (or failed), it is treated as empty: a row is then *provisionally*
non-workable rather than offering an Edit that would land on a refusal. The
distinction is invisible for drafts and unpaid sales, which never consult it.

## §4 `PosSalesListController` — the fetch

```dart
@riverpod
class PosSalesListController extends _$PosSalesListController {
  @override
  Future<CatalogPage<OpenSale>> build(PosSalesFilter filter);
}
```

- Page size 20, via `fetchClampedPage` (`core/widgets/catalog_pagination.dart`),
  exactly as `CashSessionsListController` does — so an out-of-range `?page=`
  clamps instead of showing an empty table.
- Reads `registerPointSaleProvider`; with no register configured it yields the
  "no register" state rather than an unscoped query (FR-003, Edge Cases).
- Narrows each page to `filter.status` client-side when a status facet is set,
  because mbe-api's `status` filter is not exclusive (research R3).

### §4.1 Repository addition

```dart
/// `GET /sales-orders?point_sale&status&date_from&date_to&search&skip&limit`
Future<OpenSalePage> listSales({
  required int pointSale,
  SaleStatus? status,
  DateTime? dateFrom,
  DateTime? dateTo,
  String? search,
  int skip = 0,
  int limit = 20,
});
```

Added to `SalesOrderRepository` beside `listOpen`, which keeps its narrower
three-status contract untouched. Both share one date helper:

```dart
/// Midnight of a local date, flagged UTC — the only encoding that both
/// serializes (built_value rejects a local DateTime) and selects the intended
/// rows (mbe-api reads the value as local wall-clock and ignores the offset).
/// Extracted from open_sales_selector_controller.dart's `_startOfToday`.
DateTime wireDate(DateTime local);
```

## §5 Presentation state introduced (no persistence)

| Type | Where | Values | Purpose |
|---|---|---|---|
| `CustomerBandMode` | `capture/customer_bar.dart` | `facts`, `searching` | Which face the band shows; local `State`, reset on customer change (FR-025, FR-026) |
| `SaleLineLayout` | `capture/sale_line_layout.dart` (new) | `singleRow`, `twoRow`, `card` | Chosen by `saleLineLayoutFor(double availableWidth)` — the one place the 950 px / 600 px thresholds live (FR-037, FR-037a) |

```dart
const saleLineSingleRowMinWidth = 950.0;   // research R10's measured budget
SaleLineLayout saleLineLayoutFor(double availableWidth);
```

Both thresholds live in one file so the widget tests, the row and the card agree
by construction rather than by three copies of a magic number.

## §6 Derived display values (nothing new stored)

| Value | Derivation |
|---|---|
| Customer display name | `customerRecord.name ?? sale.customerName ?? l10n placeholder` — fixes the blank field (research R8) |
| Credit availability | `!isZeroAmount(customer.creditLimit)` — gates `PaymentTerms.netD` in the dropdown (FR-029) |
| Terms shown | `sale.paymentTerms`, always; never locally overridden (FR-030) |
| Footer figures | `sale.subtotal`, `sale.taxTotal`, `sale.total`, and discount as `(subtotal + tax) − total` via `addAmounts`/`subtractAmounts` — the existing `SaleTotalsBar` derivation, unchanged (FR-047) |
| Unit count | Sum of `Decimal.tryParse(line.quantity)` — existing derivation |
| Thumbnail | Always `null` → `ProductPhoto`'s placeholder, until mbe-api exposes `photo` (research R11) |

## §7 Localization keys added

Both `lib/l10n/app_es.arb` and `app_en.arb` (the parity test enforces it):

| Area | Keys |
|---|---|
| List screen | `posSalesSearchLabel`, `posSalesNewSaleAction`, `posSalesColumnReference`, `posSalesColumnDate`, `posSalesColumnCustomer`, `posSalesColumnStatus`, `posSalesColumnTotal`, `posSalesColumnBalance`, `posSalesEmptyToday`, `posSalesNoRegister`, `posSalesNewSaleBlockedNoSession`, `posSalesStatusFilterLabel`, `posSalesStatusFilterAll` — no `posSalesListTitle` (see above) and no `posSalesEmptyFiltered`: `CatalogListStateView`'s filtered-empty state always renders its own shared generic message (`filteredEmptyTitle`/`filteredEmptyMessage`) regardless of what `emptyMessage` is passed — every other catalog already relies on that, and a custom filtered string here would simply never render |
| Date range filter | `dateRangeFilterLabel`, `dateRangeFilterToday`, `dateRangeFilterRange`, `dateRangeFilterClear` |
| Workspace | `posWorkspaceBackTooltip`, `posSaleUnreachableTitle`, `posSaleUnreachableCancelled`, `posSaleUnreachableUnknown`, `posSaleUnreachableOtherRegister`, `posSaleBackToListAction` |
| Customer band | `posCustomerSearchAction`, `posCustomerSearchCancelAction`, `posCustomerNoCreditHint` |
| Statuses | New: `posSaleStatusDraft`, `posSaleStatusCompleted`, `posSaleStatusPaid`, `posSaleStatusCancelled`. The existing `posOpenSaleDraft`/`Unpaid`/`Undelivered` are **not** reusable here — they describe what the *selector* wants doing about a sale (`paid` → "sin entregar"), whereas a list column must state the status itself (`paid` → "pagada"), and `cancelled` has no label at all today (`''`). |

Existing keys are reused wherever the copy already exists — `posNewSaleAction`,
`posCreateCustomerAction`, `posPaymentTermsImmediate`, `posPaymentTermsCredit`,
`posCustomerCreditLabel`, `posCustomerNoCredit`, `posTotals*`,
`posContinueToPayment`, `posSaleReadOnlyBanner`, and `PosGateScreen`'s copy for
the blocked new-sale action.

## §8 Widget keys that MUST survive

Existing tests and the integration flows key on these; the restyle moves the
widgets but must not rename them:

| Key | Now in | After |
|---|---|---|
| `pos_continue_to_payment` | `capture_step.dart` footer band | inside the totals footer |
| `pos_product_search_field` | `capture_step.dart` | unchanged |
| `pos_customer_picker` | `customer_bar.dart` | present while the band is `searching` |
| `pos_create_customer_button` | `customer_bar.dart` | unchanged |
| `pos_customer_facts` | `customer_bar.dart` | present while the band is `facts` |
| `pos_delivery_refusal` | `fulfillment_mode_selector.dart` | unchanged |
| `open_sales_selector` | `open_sales_selector.dart` | unchanged, now in the app bar title |
| `pos_step_indicator` / `pos_step_progress` | `pos_header_band.dart` | unchanged, now in the app bar title |
| `sale_line_card_<id>` | `sale_line_card.dart` | unchanged |
| `start_new_sale_button` | `pos_screen.dart` completion dialog | unchanged |

New keys: `pos_sales_list_table`, `pos_sales_new_sale_button`,
`pos_sales_date_range_chip`, `pos_workspace_back`, `pos_sale_unreachable`,
`pos_customer_search_button`, `pos_payment_terms_dropdown`,
`sale_line_row_<id>`, `pos_totals_footer`.
