# Contract: mbe-api Catalog Endpoints (Customers, Employees, Suppliers, Labels, Taxpayer Recipients)

**Feature**: `012-catalog-master-entities` | **Date**: 2026-07-19

All five endpoint families already exist in the committed generated client
(`lib/generated/openapi/`); this contract records the exact methods, DTOs, and
query params mbe-ui consumes. **No codegen re-run and no generated-file edits**
(research.md §2). All routes are under `OAuth2PasswordBearer` (the shared
`dio` auth interceptor attaches the token).

---

## 1. Suppliers — `SuppliersApi` (RBAC `suppliers(3)`)

| Op | Method | Returns |
|---|---|---|
| list | `listSuppliersApiV1SuppliersGet({search, skip, limit})` | `ListResponseSupplierResponse` |
| get | `getSupplierApiV1SuppliersSupplierIdGet(supplierId)` | `SupplierResponse` |
| create | `createSupplierApiV1SuppliersPost(supplierCreate)` | `SupplierResponse` |
| update | `updateSupplierApiV1SuppliersSupplierIdPut(supplierId, supplierUpdate)` | `SupplierResponse` |
| delete | `deleteSupplierApiV1SuppliersSupplierIdDelete(supplierId)` | `void` |

- `SupplierResponse`: `supplierId, code, name, zone, creditLimit(String),
  creditDays(int), comment`.
- `SupplierCreate`: `code`, `name` required; `zone`, `creditLimit`(→`CreditLimit`
  AnyOf), `creditDays`(default 0), `comment` optional.
- `SupplierUpdate`: all optional; `creditLimit`→`CreditLimit1` AnyOf.
- List has **only** `search` beyond skip/limit → no filter drawer.

## 2. Labels — `LabelsApi` (RBAC `labels(1)`)

| Op | Method | Returns |
|---|---|---|
| list | `listLabelsApiV1LabelsGet({search, skip, limit})` | `ListResponseLabelResponse` |
| get | `getLabelApiV1LabelsLabelIdGet(labelId)` | `LabelResponse` |
| create | `createLabelApiV1LabelsPost(labelCreate)` | `LabelResponse` |
| update | `updateLabelApiV1LabelsLabelIdPut(labelId, labelUpdate)` | `LabelResponse` |
| delete | `deleteLabelApiV1LabelsLabelIdDelete(labelId)` | `void` |

- `LabelResponse`: `labelId, name, comment`.
- `LabelCreate`: `name` required, `comment` optional. `LabelUpdate`: both optional.
- List has **only** `search` → no filter drawer.
- **Consumer note**: after any mutation, invalidate `allLabelsProvider` so the
  product form's label picker and the products-list label filter refresh
  (FR-014). The existing `list()` consumers are otherwise untouched.

## 3. Employees — `EmployeesApi` (RBAC `employees(6)`)

| Op | Method | Returns |
|---|---|---|
| list | `listEmployeesApiV1EmployeesGet({search, active, salesPerson, skip, limit})` | `ListResponseEmployeeResponse` |
| get | `getEmployeeApiV1EmployeesEmployeeIdGet(employeeId)` | `EmployeeResponse` |
| create | `createEmployeeApiV1EmployeesPost(employeeCreate)` | `EmployeeResponse` |
| update | `updateEmployeeApiV1EmployeesEmployeeIdPut(employeeId, employeeUpdate)` | `EmployeeResponse` |
| delete | `deleteEmployeeApiV1EmployeesEmployeeIdDelete(employeeId)` | `void` |

- `EmployeeResponse`: `employeeId, firstName, lastName, nickname, gender(int),
  birthday(Date), taxpayerId, salesPerson(bool), active(bool), personalId,
  startJobDate(Date), enrollNumber(int), comment, disabled(bool)`.
- `EmployeeCreate`: `firstName, lastName, nickname, gender, birthday,
  startJobDate` required; rest optional (`salesPerson` default false, `active`
  default true). `EmployeeUpdate`: all optional + `disabled`.
- `gender` is a bare `int` → mapped via the shared `Gender` enum (research.md §6).
- `birthday`/`startJobDate` are `Date` (y/m/d) → `DateTime` in domain, entered
  via `showDatePicker` (research.md §8).
- List facets: `active`, `salesPerson` (both nullable bool) → filter drawer.

## 4. Customers — `CustomersApi` (RBAC `customers(2)`)

| Op | Method | Returns |
|---|---|---|
| list | `listCustomersApiV1CustomersGet({search, disabled, priceList, salesperson, skip, limit})` | `ListResponseCustomerListItem` |
| get | `getCustomerApiV1CustomersCustomerIdGet(customerId)` | `CustomerResponse` |
| create | `createCustomerApiV1CustomersPost(customerCreate)` | `CustomerResponse` |
| update | `updateCustomerApiV1CustomersCustomerIdPut(customerId, customerUpdate)` | `CustomerResponse` |
| delete | `deleteCustomerApiV1CustomersCustomerIdDelete(customerId)` | `void` |

- `CustomerResponse`: `customerId, code, name, zone, creditLimit(String),
  creditDays(int), priceList(PriceListResponse — expanded), shipping(bool),
  shippingRequiredDocument(bool), salesperson(EmployeeResponse — expanded),
  disabled(bool), comment`.
- `CustomerListItem`: `customerId, code, name, zone, creditLimit, creditDays,
  priceList(expanded), salesperson(expanded), disabled`.
- `CustomerCreate`: `code`, `name`, `priceList`(int) required; `creditLimit`
  (→`CreditLimit`), `creditDays`(default 0), `zone`, `shipping`(default false),
  `shippingRequiredDocument`(default false), `salesperson`(int), `comment`
  optional. `CustomerUpdate`: all optional + `disabled`; `creditLimit`→`CreditLimit1`.
- **FKs expanded on read, plain ids on write** (research.md §7).
- List facets: `disabled`(bool), `priceList`(int), `salesperson`(int) → filter
  drawer (tri-state disabled chip + two `CatalogEntityPicker` FK filters).

## 5. Taxpayer Recipients — `TaxpayerRecipientsApi` (RBAC `taxpayerRecipients(54)`)

| Op | Method | Returns |
|---|---|---|
| list | `listTaxpayerRecipientsApiV1TaxpayerRecipientsGet({search, skip, limit})` | `ListResponseTaxpayerRecipientResponse` |
| get | `get…TaxpayerRecipientIdGet(taxpayerRecipientId)` | `TaxpayerRecipientResponse` |
| create | `create…Post(taxpayerRecipientCreate)` | `TaxpayerRecipientResponse` |
| update | `update…TaxpayerRecipientIdPut(taxpayerRecipientId, taxpayerRecipientUpdate)` | `TaxpayerRecipientResponse` |
| delete | `delete…TaxpayerRecipientIdDelete(taxpayerRecipientId)` | `void` |

- `TaxpayerRecipientResponse`: `taxpayerRecipientId(String), name, email,
  postalCode(SatCatalogResponse — expanded), regime(SatCatalogResponse — expanded)`.
- `TaxpayerRecipientCreate`: `taxpayerRecipientId`(String) **required, client-
  supplied**, `email` required; `name`, `postalCode`(String code),
  `regime`(String code) optional. `TaxpayerRecipientUpdate`: `name, email,
  postalCode, regime` optional — **no id** (immutable, research.md §9).
- Path key is the String id. List has **only** `search` → no filter drawer.

## 6. SAT picker methods (extension to `SatCatalogRepository`)

Backed by the already-present `SatCatalogsApi`:
- `listPostalCodesApiV1SatPostalCodesGet({search, skip, limit})` →
  `ListResponseSatCatalogResponse`.
- `listTaxRegimesApiV1SatTaxRegimesGet({search, skip, limit})` →
  `ListResponseSatCatalogResponse`.

Both map through the existing `SatCatalogItem.fromResponse` and back the
TaxpayerRecipient form's `postalCode`/`regime` pickers. No upstream gap.

## 7. Money `AnyOf` write path (creditLimit)

`creditLimit` on Supplier and Customer is `anyOf: [number, string]`, wrapper
classes `CreditLimit` (create) / `CreditLimit1` (update). **Always** send the
String arm:

```dart
builder.anyOf = AnyOf2<String, num>(values: {0: value});
```

This is the exact construction proven in `price_list_repository_impl.dart` /
`product_price_repository_impl.dart` (specs/011 research.md §4). A repository
round-trip unit test per entity is mandatory before any UI wiring, mirroring
the specs/011 precedent that caught the `RangeError` form.

## 8. Error mapping

Every repository wraps `DioException` → shared `AppError` via the existing
`_toAppError` helper (`mapped is AppError ? mapped : mapDioException(error)`),
so validation/not-found/conflict/server/network errors surface through the
shared `ErrorBanner`, never handled ad hoc (constitution §III). Duplicate
TaxpayerRecipient id and deletion-while-referenced rejections arrive this way
(FR-027, spec Edge Cases).

## 9. Upstream gaps

**None.** All endpoints, DTOs, and query params this feature needs already
exist in the committed client. The only non-generated addition is the `Gender`
constant enum, which mirrors a legacy constant with no published schema (not a
DTO) — recorded as a candidate mbe-api follow-up to publish the enum, not a
blocking dependency (plan.md Follow-ups).
