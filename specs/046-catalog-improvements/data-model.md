# Data Model: Catalog Improvements (046)

This feature adds no new backend entity and changes no API contract. Every change below happens client-side, in a domain entity, in form state, or in a repository signature.

## 1. `CustomerFormState` (`lib/features/catalog/presentation/customer_form_controller.dart`)

| Field | Before | After |
|---|---|---|
| `taxpayerId` | `String?` | **removed** |
| `taxpayerDisplayText` | `String` | **removed** |
| `taxpayers` | — | `@Default([]) List<TaxpayerRecipientListItem>` |
| `addresses` | — | `@Default([]) List<AddressListItem>` |
| `contacts` | — | `@Default([]) List<Contact>` |

**Controller methods** (each one clears field errors, following the existing `_clear` pattern):

| Method | Effect |
|---|---|
| `addressAdded(AddressListItem)` | Ignored if `addressId` is already in the list. |
| `addressRemoved(int addressId)` | Removes the address from the list. |
| `contactAdded(Contact)` | Ignored if `contactId` is already in the list. |
| `contactRemoved(int contactId)` | Removes the contact from the list. |
| `taxpayerAdded(TaxpayerRecipientListItem)` | Ignored if `taxpayerRecipientId` is already in the list. |
| `taxpayerRemoved(String rfc)` | Removes the taxpayer from the list. |
| `taxpayerSelected(String rfc, String name)` | Kept for the POS quick-create. Replaces the list with exactly one item (research R4). |

**Loading** (`loadForEdit`): the three lists are seeded from `customer.addresses`, `customer.contacts` and `customer.taxpayers.map(TaxpayerRecipientListItem.fromRecipient)`.

**Saving** (`submitCreate` / `submitUpdate`):
- Both always pass three lists:
  - `addresses: [for a in addresses: a.addressId]`
  - `contacts: [...contactId]`
  - `taxpayers: [...taxpayerRecipientId]`
- The API treats each list as replace-all.
- `_taxpayersOf` is deleted.

**Dirty check**: unchanged. Freezed equality now includes the three lists, so any link change marks the form dirty.

## 2. `AddressListItem` (`lib/features/catalog/domain/entities/address_list_item.dart`)

- **New field**: `@Default(EntityStatus.active) EntityStatus status`, mapped in `fromResponse` from `AddressResponse.status`.
- **Display**: `label` (built with `formatAddress`) stays the row text. When `status != active`, the row shows the shared status badge.

## 3. `AddressRepository.list`

```text
list({String? search, EntityStatus? status, int skip = 0, int limit = 20})
```

`status` is new and optional. When it is non-null, it is passed to the generated `listAddresses(status:)`. Existing callers are unaffected.

## 4. `TaxpayerRecipientListItem`

New factory: `TaxpayerRecipientListItem.fromRecipient(TaxpayerRecipient r)`, which carries `taxpayerRecipientId`, `name` and `email`. Create it only if it doesn't already exist.

## 5. `TaxpayerRecipientFormState`

- **New field**: `TaxpayerRecipient? created`, set by `submitCreate` from the return value of `repository.create(...)`.
- **Form behavior**: on `saved`, the form calls `Navigator.pop(state.created)`. On update, `created` is null and the pop carries no value, the same as today.

## 6. Facility children (`FacilityChildrenState`)

- **Shape**: unchanged.
- **Behavior**: `pointsOfSaleReadable` and `cashDrawersReadable` depend only on `can(..., read)`, not on `facility.type`.

## 7. Relationship summary

```text
Customer ──< customer_address >── Address    (shared; also referenced by orders and deliveries)
Customer ──< customer_contact >── Contact    (shared)
Customer ──< customer_taxpayer >─ TaxpayerRecipient (RFC; shared)
Facility(type: store | productionSite "Planta") ──< Warehouse
                                                  ──< PointOfSale   (now for both types)
                                                  ──< CashDrawer    (now for both types)
Product ── photo (single URL; used for both thumbnail and preview)
```

## Validation rules

- A record cannot be linked to the same customer twice (FR, edge case: duplicate link). This is enforced in the controller's add methods, and the picker options also leave out records that are already linked.
- No minimum count applies to any list.
- Unlinking changes only the customer's link list and never deletes the record.
