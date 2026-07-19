# Phase 1 Data Model: Catalog Master Entities

**Feature**: `012-catalog-master-entities` | **Date**: 2026-07-19

All domain entities are immutable `freezed` classes in
`lib/features/catalog/domain/entities/`, mapped from generated DTOs via a
`fromResponse` factory (constitution §III). Money (`creditLimit`) is `String`
end-to-end; dates use `DateTime?` in domain/form state and convert to the
generated `Date` at the repository boundary. FK fields arrive pre-expanded on
responses and are mapped to display names (research.md §7).

Legend: **PK** = primary key, **FK** = foreign key (expanded on read),
`?` = optional/nullable.

---

## §1 Supplier

**Endpoint**: `/api/v1/suppliers` (`SuppliersApi`). **RBAC**: `suppliers(3)`.

Two types: the existing lightweight `SupplierListItem` (kept for the product
form's picker) and a new full `Supplier` for the catalog list/detail.

### `Supplier` (detail/list)
| Field | Type | Notes |
|---|---|---|
| supplierId | int | PK, server-assigned |
| code | String | required |
| name | String | required |
| zone | String? | free text |
| creditLimit | String | money-as-String; `AnyOf` on write (research.md §4) |
| creditDays | int | default 0 |
| comment | String? | |

- `Supplier.fromResponse(SupplierResponse)` — direct field copy.
- `SupplierListItem` (unchanged): `{ supplierId, code, name }` — remains the
  product-form picker's item type; **not** removed.
- Create sends `SupplierCreate` (code/name required; creditLimit via
  `CreditLimit` wrapper). Update sends `SupplierUpdate` (all optional;
  creditLimit via `CreditLimit1`).

### Validation (`supplier_form_controller.dart`)
- code: required, non-empty/non-whitespace.
- name: required, non-empty.
- creditLimit: optional; if present, non-negative decimal.
- creditDays: optional; if present, non-negative integer.

---

## §2 Label

**Endpoint**: `/api/v1/labels` (`LabelsApi`). **RBAC**: `labels(1)`.

The existing `LabelItem` (`{ labelId, name }`, sorted for the picker) stays as
the picker/filter type. The detail screen needs `comment` too.

### `Label` (detail)
| Field | Type | Notes |
|---|---|---|
| labelId | int | PK, server-assigned |
| name | String | required |
| comment | String? | |

- Reuse `LabelItem` for the list rows if a `comment` column is not shown; use a
  full `Label` entity (or extend `LabelItem` with `comment`) for the detail
  screen. **Decision**: add a `Label` detail entity so `LabelItem` stays the
  minimal picker type (parallels Supplier/SupplierListItem).
- Create sends `LabelCreate` (name required, comment optional); update sends
  `LabelUpdate` (both optional).
- `allLabelsProvider` (the product form/filter cache) MUST be invalidated after
  any create/update/delete so the product surfaces see the change (FR-014).

### Validation (`label_form_controller.dart`)
- name: required, non-empty.

---

## §3 Employee

**Endpoint**: `/api/v1/employees` (`EmployeesApi`). **RBAC**: `employees(6)`.

### `Employee` (detail) / `EmployeeListItem` (list + picker)
| Field | Type | Notes |
|---|---|---|
| employeeId | int | PK, server-assigned |
| firstName | String | required |
| lastName | String | required |
| nickname | String | required |
| gender | Gender | enum (female=0/male=1), see §7 |
| birthday | DateTime | required; `Date` on the wire |
| taxpayerId | String? | RFC |
| salesPerson | bool | default false |
| active | bool | default true |
| personalId | String? | |
| startJobDate | DateTime | required; `Date` on the wire |
| enrollNumber | int? | |
| comment | String? | |

> **`EmployeeResponse.disabled`/`EmployeeUpdate.disabled` are deliberately NOT
> mapped** (corrected 2026-07-19, `/speckit-analyze` finding U1): the backend
> carries this alongside `active` with no documented distinction between the
> two. Rather than surface a second, seemingly-redundant toggle, this feature
> manages only `active`. A candidate mbe-api issue is filed requesting the
> field be removed or the distinction documented (plan.md Follow-ups).

- `EmployeeListItem` (for the Customer salesperson picker + the Employees list):
  `{ employeeId, fullName (firstName + lastName), nickname, active, salesPerson }`.
  Picker `displayStringForOption` → `"$fullName ($nickname)"`.
- `Employee.fromResponse(EmployeeResponse)` maps `Date`→`DateTime` and
  `int`→`Gender` via `Gender.fromValue`; `disabled` is read but discarded.
- Create sends `EmployeeCreate` (firstName/lastName/nickname/gender/birthday/
  startJobDate required); update sends `EmployeeUpdate` (all optional).
  `EmployeeUpdate.disabled` is never set (left at its default). `Date` built
  from `DateTime` (y/m/d).

### Validation (`employee_form_controller.dart`)
- firstName, lastName, nickname: required, non-empty.
- gender: required (dropdown, defaults to unset → must pick).
- birthday, startJobDate: required (date picker).
- enrollNumber: optional; if present, non-negative integer.

---

## §4 Customer

**Endpoint**: `/api/v1/customers` (`CustomersApi`). **RBAC**: `customers(2)`.

### `Customer` (detail) / `CustomerListItem` (list)
| Field | Type | Notes |
|---|---|---|
| customerId | int | PK, server-assigned |
| code | String | required |
| name | String | required |
| zone | String? | free text |
| creditLimit | String | money-as-String; `AnyOf` on write |
| creditDays | int | default 0 |
| priceList | PriceListRef | **FK, required**, expanded → `{ id, name }` |
| shipping | bool | default false |
| shippingRequiredDocument | bool | default false |
| salesperson | EmployeeRef? | **FK, optional**, expanded → `{ id, name }` |
| disabled | bool | active/inactive |
| comment | String? | |

- `PriceListRef` / `EmployeeRef` are tiny value objects (id + display name)
  mapped from the expanded `PriceListResponse` / `EmployeeResponse` on the
  response. On write, `CustomerCreate`/`Update` send `priceList: int` and
  `salesperson: int?` (plain ids) — response-only expansion (research.md §7).
- `CustomerListItem` (list rows): `{ customerId, code, name, disabled,
  salespersonName?, priceListName }`.
- A `null`/unresolved salesperson renders the localized "none assigned"
  fallback; an unresolved price list renders "unknown price list" (never
  crash — spec Edge Cases).
- creditLimit via `CreditLimit`/`CreditLimit1` (same as Supplier).

### Validation (`customer_form_controller.dart`)
- code, name: required, non-empty.
- priceList: required (picker selection).
- creditLimit: optional; if present, non-negative decimal.
- creditDays: optional; if present, non-negative integer.

---

## §5 TaxpayerRecipient

**Endpoint**: `/api/v1/taxpayer-recipients` (`TaxpayerRecipientsApi`).
**RBAC**: `taxpayerRecipients(54)`.

### `TaxpayerRecipient` (detail) / `TaxpayerRecipientListItem` (list)
| Field | Type | Notes |
|---|---|---|
| taxpayerRecipientId | String | **PK, client-supplied, immutable** (research.md §9) |
| name | String | required |
| email | String | required |
| postalCode | SatRef? | **FK**, expanded → `{ code, description }` |
| regime | SatRef? | **FK**, expanded → `{ code, description }` |

- `SatRef` maps from the expanded `SatCatalogResponse` (code + description).
- On write, `TaxpayerRecipientCreate` sends `taxpayerRecipientId` (required),
  `name`, `email`, and `postalCode`/`regime` as plain code Strings;
  `TaxpayerRecipientUpdate` omits the id (immutable) and sends the rest.
- `TaxpayerRecipientListItem` (list rows): `{ taxpayerRecipientId, name,
  email }`.
- Unresolved postalCode/regime render a fallback description (FR-026-equiv).

### Validation (`taxpayer_recipient_form_controller.dart`)
- taxpayerRecipientId: required on create; not editable on update.
- name, email: required, non-empty (email non-empty; format left to backend to
  keep parity with the Users email field's posture).

---

## §6 Reused / shared types (no new work on the source entity)

- **PriceList** (`lib/features/pricing/...`) — reused read-only via
  `PriceListRepository.list()` as the Customer price-list picker's item type
  and to resolve `CustomerListItem.priceListName`. No pricing change.
- **SatCatalogItem** (`lib/features/catalog/...`) — reused as the postal-code
  and tax-regime picker item type via the two new `SatCatalogRepository`
  methods (research.md §5).

---

## §7 Gender (shared kernel)

`lib/core/domain/gender.dart` — constant enum, mirrors legacy
`mbe/docs/constants.md §GenderEnum`:

| enum | value |
|---|---|
| `Gender.female` | 0 |
| `Gender.male` | 1 |

- `int value` and `static Gender? fromValue(int)` (returns `null` for an
  unknown code → UI shows a localized "unknown"/raw fallback, mirroring
  `SystemObject.fromValue`).
- Localized labels `genderFemaleLabel` / `genderMaleLabel` in the `.arb` files;
  rendered as a `DropdownButtonFormField<Gender>` on the employee form (same
  shape as the product form's `Currency` dropdown) and as a text label on
  list/detail.

---

## §8 Repository interfaces (summary)

Each new/extended interface lives in
`lib/features/catalog/domain/repositories/` and returns domain entities, never
DTOs. `list` returns a `{ items, total }` result record used by the list
controllers to build `CatalogPage<T>`.

| Repository | Methods | Status |
|---|---|---|
| `SupplierRepository` | `list` (existing) + `get`/`create`/`update`/`delete` | **extended** |
| `LabelRepository` | `list` (existing) + `get`/`create`/`update`/`delete` | **extended** |
| `SatCatalogRepository` | existing 2 + `listPostalCodes`/`listTaxRegimes` | **extended** |
| `CustomerRepository` | `list`(search/disabled/priceList/salesperson) / `get` / `create` / `update` / `delete` | **new** |
| `EmployeeRepository` | `list`(search/active/salesPerson) / `get` / `create` / `update` / `delete` | **new** |
| `TaxpayerRecipientRepository` | `list`(search) / `get` / `create` / `update` / `delete` | **new** |

All impls follow the `SuppliersApi`-wrapping shape already in
`supplier_repository_impl.dart`: construct the `*Api(dio, standardSerializers)`,
`try`/`on DioException` → `_toAppError`, `throw const AppError.server()` on a
null body.
