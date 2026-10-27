# Data Model: Payments List and Search

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

This feature is read-only, so every entity is a client-side projection of a server response, and nothing has a lifecycle the UI drives.

## 1. `CustomerPayment` (new, freezed)

`lib/features/sales/domain/entities/customer_payment.dart`. Mapped from `api.CustomerPaymentResponse`.

| Field | Type | From | Notes |
|---|---|---|---|
| `customerPaymentId` | `int` | `customerPaymentId` | Folio |
| `customerId` | `int` | `customer` | The name resolves through `customerDisplayNameProvider` (R2) |
| `amount` | `String` | `amount` | A decimal string, as the API sends it |
| `currency` | `Currency` | `currency` | `currencyFromApi`; unknown → `Currency.mxn` is **not** assumed. The mapping throws `AppError.server()` instead (contract break) |
| `methodCode` | `int` | `method` | `paymentMethodCodeFromApi` (R10), labelled by `paymentMethodLabel` |
| `paymentOptionId` | `int?` | `paymentCharge` | The name resolves through `paymentMethodOptionNameProvider` (R3) |
| `reference` | `String?` | `reference` | |
| `date` | `DateTime` | `date` | Wall-clock (spec 043) |
| `facilityId` | `int` | `facility` | Used by the detail guard (R4) and the cross-facility column |
| `cashSessionId` | `int?` | `cashSession` | `null` for back-office and migrated payments |
| `type` | `PaymentType` | `paymentType` | §3 |
| `verifierId` | `int?` | `verifier` | |
| `unapplied` | `String` | `unapplied` | Server-derived |

Derived: `bool get isVerified => verifierId != null`.

**Validation**: none, because the user enters nothing. If the server returns an unrecognised `PaymentType` or `CurrencyCode`, that's a contract error, raised as `AppError.server()` and shown in the error state.

## 2. `PaymentApplication` (new, freezed)

In the same file. Mapped from `api.ApplicationResponse`.

| Field | Type | From |
|---|---|---|
| `id` | `int` | `salesOrderPaymentId` |
| `saleId` | `int` | `salesOrder` |
| `amount` | `String` | `amount` |
| `change` | `String` | `amountChange` |
| `applierId` | `int?` | `applier` |
| `date` | `DateTime?` | `date` |
| `reversed` | `bool` | `cancelled` |

Applications are listed in server order. The **Aplicado** total (FR-013a) is the decimal sum of `amount` over applications where `!reversed`. It's computed in the detail controller with `package:decimal`, never with `double`.

## 3. `PaymentType` (new enum)

`lib/features/sales/domain/payment_type.dart`

| Value | Code | Label (es) | Label (en) |
|---|---|---|---|
| `na` | 0 | N/A | N/A |
| `immediate` | 1 | Contado | Cash sale |
| `creditPayment` | 2 | Pago de crédito | Credit payment |
| `paymentInAdvance` | 3 | Pago anticipado | Payment in advance |
| `creditNote` | 4 | Nota de crédito | Credit note |
| `expense` | 5 | Gasto | Expense |

## 4. `PaymentsFilter` (new, freezed): the list's URL state

Built by `PaymentsFilter.fromQuery(ListQuery, {required bool canSearchAllFacilities})`.

| Field | Facet / source | Mode |
|---|---|---|
| `scope` | `scope` (`all` → `PaymentsScope.allFacilities`, else `facility`) | both. Forced to `facility` when `!canSearchAllFacilities` |
| `customerId` | `customer` | both |
| `dateFrom`, `dateTo` | `date-from`, `date-to` (`yyyy-MM-dd`) | both. A range whose end is before its start is dropped |
| `methodCode` | `method` | facility only |
| `verified` | `verified` (`true` / `false`; absent = any) | facility only |
| `cashSessionId` | `cash-session` | facility only |
| `reference` | `ListQuery.search` | all only |
| `pageIndex` | `page` | both |

- `activeFilterCount` counts the facets valid in the current mode. It feeds the badge.
- **Mode switch:** `switchScope(ListQuery, PaymentsScope) → ListQuery` keeps `customer`, `date-from` and `date-to`, drops every other facet and the search, and resets the page (FR-012).

## 5. Changes to existing types

| Type | Change |
|---|---|
| `CashSession` | Gains `int cashDrawerFacilityId`, from the embedded `CashDrawerSummary.facility` (R7) |
| `CashSessionRepository.list` | Gains `int? facilityId` |
| `CustomerPaymentRepository` | Gains `list`, `searchAcrossFacilities`, `get` and `listApplications` (R1) |
| `lib/core/domain/payment_method.dart` | Gains `paymentMethodCodeFromApi`, moved from `sale_payment.dart` (R10) |
| `lib/core/domain/currency.dart` | Gains `currencyCodeLabel(Currency)` (R9) |

## 6. Providers (new)

| Provider | Kind | Returns |
|---|---|---|
| `PaymentsListController(filter)` | `@riverpod` class | `CatalogPage<CustomerPayment>`. Picks `list` (always with the user's facility) or `searchAcrossFacilities` by `filter.scope` |
| `PaymentDetailController(paymentId)` | `@riverpod` class | `CustomerPayment`, or `AppError.notFound` when the facility guard trips (R4) |
| `PaymentApplicationsController(paymentId)` | `@riverpod` class | `List<PaymentApplication>`. Watched only after the guard passes. The `applied` total is a derived getter over it |
| `customerDisplayNameProvider(id)` | `FutureProvider.family<String?, int>` | |
| `paymentMethodOptionNameProvider(id)` | `FutureProvider.family<String?, int>` | |
| `cashSessionLabelProvider(id)` | `FutureProvider.family<String?, int>` | `#id · cashier · date` |
| `orderLinkTargetProvider(saleId)` | `FutureProvider.family<String?, int>` | A route, or `null` for plain text (R8) |

**Detail loading order**: load the payment, apply the guard, then load the applications. If the applications fail, the payment fields still render, and only the applications section shows the error with a retry (wireframe "loading / error / not found"). To support that, the applications get their own `PaymentApplicationsController(paymentId)`, which `PaymentDetailController` doesn't wait on.
