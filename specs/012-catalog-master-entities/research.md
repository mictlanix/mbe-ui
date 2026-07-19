# Phase 0 Research: Catalog Master Entities

**Feature**: `012-catalog-master-entities` | **Date**: 2026-07-19

This document resolves the technical unknowns behind the plan. Each section is
Decision / Rationale / Alternatives considered.

## §1 — No new RBAC plumbing

**Decision**: Reuse the five `SystemObject`s already present in
`lib/core/access/system_object.dart`: `labels(1)`, `customers(2)`,
`suppliers(3)`, `employees(6)`, `taxpayerRecipients(54)`. No new privilege, no
edit to `system_object.dart`, no `PrivilegesGrid` change.

**Rationale**: Verified all five enum entries exist. Gating reuses the same
`accessControlProvider.can(object, right)` call every catalog already uses;
routes gate on `AccessRight.read` in `_routeGate`, mutations gate on
`create`/`update`/`delete` in the form controllers.

**Alternatives considered**: Introducing finer-grained sub-objects (e.g. a
separate object for salesperson assignment) — rejected: mbe-api's model has one
object per entity, and mirroring it 1:1 is the constitution's §IV rule.

## §2 — No codegen re-run

**Decision**: Treat the committed generated client as current. All five APIs
(`CustomersApi`, `EmployeesApi`, `TaxpayerRecipientsApi`, `SuppliersApi`,
`LabelsApi`) already expose `create`/`get`/`list`/`update`/`delete`, and all
request/response models (`*Create`, `*Update`, `*Response`, `*ListItem`,
`ListResponse*`) are present under `lib/generated/openapi/`.

**Rationale**: `grep` confirmed each `*_api.dart` has the five `Future<Response<…>>`
methods, and the model files exist. Same no-codegen posture specs/011 recorded;
quickstart's live checks exercise every endpoint so any drift fails loudly.

**Alternatives considered**: Regenerating from a fresh `openapi.json` — rejected
as unnecessary scope; the committed client is the contract of record (§III's
"generated files MUST NOT be hand-edited" is honored either way).

## §3 — Promote Suppliers/Labels lookups to full CRUD without breaking consumers

**Decision**: Add `get`/`create`/`update`/`delete` to the existing
`SupplierRepository` and `LabelRepository` interfaces (and their impls),
keeping `list()` exactly as-is. Introduce a full `Supplier` detail entity
alongside the existing `SupplierListItem`; the label detail can reuse
`LabelItem` extended with `comment` (or a thin `Label` entity) — decided in
data-model.md.

**Rationale**: The product form's supplier picker
(`product_detail_screen.dart`) and label multi-picker, and the products list's
label filter (`products_list_screen.dart` / `allLabelsProvider`), only call
`list()`. Adding methods is a superset change — no existing call site needs to
change. `SupplierListItem` (id/code/name) stays the picker's lightweight type;
the new `Supplier` entity carries the full field set for the detail screen.

**Alternatives considered**: Forking new `SupplierCrudRepository` /
`LabelCrudRepository` interfaces — rejected: two interfaces over one endpoint
family duplicates the provider wiring and confuses ownership; one interface per
entity is the established pattern (`ProductRepository`, `PriceListRepository`).

## §4 — `creditLimit` AnyOf write path

**Decision**: Send Supplier/Customer `creditLimit` as the String arm via
`AnyOf2<String, num>(values: {0: value})`, with separate create-side
(`CreditLimit`) and update-side (`CreditLimit1`) builder helpers — identical to
how `price_list_repository_impl.dart` handles `HighProfitMargin`/`…Margin1` and
`product_price_repository_impl.dart` handles `Price`/`Price1`.

**Rationale**: Inspected `credit_limit.dart` — it is an `AnyOf` wrapper (`Any Of
[String], [num]`) with the same custom serializer as the pricing wrappers. The
"String first, key 0" form is the one specs/011 proved against a live
round-trip after `AnyOf2<num, String>`/key-`1` threw `RangeError`. There is a
pre-existing `_setTaxRate` precedent in `product_repository_impl.dart` too.
`creditLimit` is optional on create (`[optional]`), so it is only set when
non-empty.

**Alternatives considered**: Parsing to `num` and sending the number arm —
rejected: the whole-codebase convention is money-as-`String` end-to-end
(§ specs/011 research.md §3), avoiding float rounding.

## §5 — Two new SAT picker methods

**Decision**: Add `listPostalCodes` and `listTaxRegimes` to the existing
`SatCatalogRepository` interface + impl, mirroring `listUnitsOfMeasurement`/
`listProductServices` exactly (same `search`/`skip`/`limit` params,
`SatCatalogListResult` return, `SatCatalogItem.fromResponse` mapping).

**Rationale**: The generated `SatCatalogsApi` already has
`listPostalCodesApiV1SatPostalCodesGet` and `listTaxRegimesApiV1SatTaxRegimesGet`,
both returning `ListResponseSatCatalogResponse` — the same type the two existing
methods consume. No upstream/backend gap; purely a client-side repository
extension. These back the TaxpayerRecipient form's `postalCode`/`regime`
pickers via the shared `CatalogEntityPicker`.

**Alternatives considered**: A dedicated `TaxpayerRecipientLookupRepository` —
rejected: `SatCatalogRepository` is precisely the "read-only SAT catalog lookup"
home; postal codes and tax regimes are SAT catalogs.

## §6 — `Gender` constant enum → `core/domain/`

**Decision**: Add `lib/core/domain/gender.dart` — a constant enum
`Gender { female(0), male(1) }` with `fromValue(int)` (graceful `null`/unknown
fallback) and an `int value`, mirroring `mbe/docs/constants.md §GenderEnum`
(0 = Female, 1 = Male). Rendered on the employee form as a localized dropdown
and on list/detail as a localized label.

**Rationale**: Employee `gender` is a bare `int` in the generated client with no
enum schema — nothing to generate from. This is the identical situation
specs/011 faced with exchange-rate `Currency`, whose resolution (a constant enum
in `core/domain/` mirroring a legacy constant) is the precedent, alongside
`SystemObject`. Placed in the shared kernel because the legacy `GenderEnum` also
backs `customer.gender` (per the constants doc's DB-column note), so it is
cross-entity even if the current `CustomerResponse` does not surface it.

**Alternatives considered**: A per-feature enum in `catalog/domain/` — rejected
by §I (shared, cross-feature constants live in the kernel). A raw dropdown of
`[0,1]` ints — rejected: unreadable and unlocalizable.

## §7 — FK expansion on Customer / TaxpayerRecipient responses

**Decision**: Rely on server-side FK expansion. Map
`CustomerResponse.priceList` (a `PriceListResponse`) and `.salesperson` (an
`EmployeeResponse`) to display names directly; map
`CustomerListItem.priceList`/`.salesperson` the same way. Map
`TaxpayerRecipientResponse.postalCode`/`.regime` (each a `SatCatalogResponse`)
to their description. Unresolvable/absent FKs render a localized fallback
("none assigned" / "unknown"), never crash.

**Rationale**: The generated model docs confirm these fields are typed as the
expanded response objects, not bare ids — identical to how specs/005 established
that `ProductResponse.supplier`/`unit_of_measurement`/`key` arrive pre-expanded.
So the list and detail screens need no extra per-row lookup. Write paths
(`CustomerCreate`/`Update`) still send plain ids (`priceList: int`,
`salesperson: int`), matching specs/005's response-only-expansion rule.

**Alternatives considered**: Fetching each FK by id on render — rejected: N+1
round-trips, and unnecessary since the response is pre-expanded.

## §8 — Date fields (Employee birthday / startJobDate)

**Decision**: Represent `birthday`/`startJobDate` with the generated `Date`
value type (year/month/day ints). In the form state keep them as `DateTime?`
and convert at the repository boundary; enter them via Flutter's built-in
`showDatePicker` (localized), the exact call-site pattern
`exchange_rate_detail_screen.dart` already uses for exchange-rate dates. Render
via `intl` `DateFormat` in `es-MX`.

**Rationale**: specs/011's Assumptions already decided that no shared
date-picker widget is warranted for a handful of call sites — call
`showDatePicker` directly. Employees add two date fields; reusing that decision
keeps parity. `Date` ↔ `DateTime` conversion is a trivial y/m/d mapping in the
repository, keeping the domain entity framework-agnostic.

**Alternatives considered**: A new shared `DateField` widget — deferred; two
more call sites still do not justify a shared component (same reasoning as
specs/011). Free-text date entry — rejected by §V (locale-aware entry, no manual
string parsing).

## §9 — TaxpayerRecipient client-supplied String primary key

**Decision**: In create mode, the form shows an editable `taxpayerRecipientId`
text field (the RFC-like tax id); in edit mode it is shown read-only/disabled.
The path route key is the String id (`/taxpayer-recipients/:taxpayerRecipientId`).
Duplicate-id rejection is surfaced from the backend via the shared error path;
the UI does not pre-check.

**Rationale**: This is structurally identical to the Users admin screen
(`user_detail_screen.dart`), whose `user_id_field` is a client-supplied String
id shown only in create mode (`if (!_isEdit) …`) and used as the record's route
key. `TaxpayerRecipientCreate` requires `taxpayerRecipientId`;
`TaxpayerRecipientUpdate` omits it (immutable) — the generated DTOs enforce the
immutability, and the form mirrors it. All other four entities use
server-assigned `int` ids and the standard `/entity/new` + `/entity/:id` shape.

**Alternatives considered**: Auto-generating the id client-side — rejected: the
tax id is a real-world identifier the user must supply, not a surrogate key.

## §10 — Filter drawers only where the endpoint has facets

**Decision**: Ship a `CatalogFilterSheet` drawer for **Customers** (disabled
tri-state, price-list `CatalogEntityPicker`, salesperson `CatalogEntityPicker`)
and **Employees** (active tri-state, salesPerson tri-state). Ship **no** drawer
for Suppliers, Labels, TaxpayerRecipients — their list endpoints expose only
`search`.

**Rationale**: The generated list methods confirm the query params:
`listCustomersApiV1CustomersGet(search, disabled, priceList, salesperson, …)`,
`listEmployeesApiV1EmployeesGet(search, active, salesPerson, …)`, and
search-only for the other three. §VI mandates search on every catalog and facet
controls "if the entity has obvious facets" — matched exactly to the endpoint's
capability. The drawer is modeled on `products_list_screen.dart`'s
`_ProductFiltersPanel` (a `Badge.count`-wrapped `IconButton.outlined` opening
`showCatalogFilterSheet`). Filter selection lives in a `freezed`
`Notifier` (like `ExchangeRateFilterController` / `ProductFilterController`),
with an `activeFilterCount` badge extension.

**Alternatives considered**: A client-side filter over a full fetch — rejected
by §VI (server-side, paginated). Inventing facets the endpoint cannot serve
(e.g. a supplier "zone" filter) — rejected: the endpoint has no such param, and
adding one is an upstream change, not a UI workaround (§III).

## §11 — Reuse the PriceList picker for the Customer salesperson/price-list fields

**Decision**: The Customer form's price-list field is a `CatalogEntityPicker<PriceList>`
backed by the existing `PriceListRepository.list()` (specs/011); the salesperson
field is a `CatalogEntityPicker<EmployeeListItem>` backed by this feature's new
`EmployeeRepository.list()`. Same for the Customers filter drawer's price-list
and salesperson pickers.

**Rationale**: `PriceListRepository` already ships and already exposes `list()`
with search — no new pricing work. The employee picker is the reason Employees
(User Story 3) is sequenced before Customers (User Story 4): the picker needs a
real repository to search. Both reuse the shared `CatalogEntityPicker` verbatim
(the supplier picker on the product form is the reference call).

**Alternatives considered**: A bespoke dropdown of all price lists / employees —
rejected: unbounded sets need search-as-you-type, which `CatalogEntityPicker`
already provides; a static dropdown violates §VI's unbounded-dataset rule.
