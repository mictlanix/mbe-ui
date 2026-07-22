# Contract: Routes, Navigation & RBAC Gating

**Feature**: `015-fiscal-catalogs` | **Date**: 2026-07-21 (revised 2026-07-22)

> **2026-07-22 revision**: Taxpayer Certificates is **no longer** a standalone
> catalog — it is a child section of the Taxpayer Issuer detail (spec US3,
> research §9). So this feature appends **two** branches/destinations, not three,
> and adds **no** `/taxpayer-certificates` route or gate.

## NavBranch ↔ router branch-order invariant

`NavBranch` indices are **positional** and MUST match the shell-branch order in
`app_router.dart` (documented at `nav_destinations.dart`; honored by specs
012/013/014). This feature appends two branches after `facilities(17)` in the
**same order** in both files:

| NavBranch | Index | Route | Nav group |
|---|---|---|---|
| `paymentMethodOptions` | 18 | `/payment-method-options` | `catalogs` |
| `taxpayerIssuers` | 19 | `/taxpayer-issuers` | `sales` |

*(No `taxpayerCertificates` branch — certificates live inside the issuer detail.)*

## Shell branches (list screens) — appended in `app_router.dart`

```
/payment-method-options   → PaymentMethodOptionsListScreen
/taxpayer-issuers         → TaxpayerIssuersListScreen
```

## Flat detail sub-routes (appended after `/facilities/:facilityId`)

```
/payment-method-options/new                        → PaymentMethodOptionDetailScreen()          (create)
/payment-method-options/:paymentMethodOptionId     → PaymentMethodOptionDetailScreen(id: int.parse(...), forceReadOnly: ?view=true)

/taxpayer-issuers/new                              → TaxpayerIssuerDetailScreen()               (create)
/taxpayer-issuers/:rfc                             → TaxpayerIssuerDetailScreen(rfc: <String>, forceReadOnly: ?view=true)
                                                     // String path param — RFC, NO int.parse (recipient precedent)
```

**Notes**
- Payment Method Options follows the int-keyed catalog route shape (`/new` + `int.parse(:id)` + `?view=true`), exactly like Warehouses.
- Taxpayer Issuers follows the **String-keyed** shape (Taxpayer Recipients precedent): no `int.parse`, RFC is the raw path param, editable only in create mode.
- **Taxpayer Certificates has no routes.** Certificates are viewed and added from within the Taxpayer Issuer detail's Certificates section (the `/taxpayer-issuers/:rfc` screen), with the Agregar upload rendered as a modal dialog — not a route (research §9).

## `_routeGate` additions (`app_router.dart`)

```dart
if (location.startsWith('/payment-method-options')) {
  return (object: SystemObject.paymentMethodOptions, right: AccessRight.read);
}
if (location.startsWith('/taxpayer-issuers')) {
  return (object: SystemObject.taxpayers, right: AccessRight.read);
}
```

Placement: alongside the other catalog gates; both gate on `AccessRight.read`
(the screen then further restricts create/update/delete actions). No
`/taxpayer-certificates` gate — the certificate section is inside the already
`taxpayers`-read-gated issuer detail. `/taxpayer-issuers` vs `/taxpayer-recipients`
are distinct prefixes, so no collision.

## Nav destinations (`nav_destinations.dart`)

- **`catalogs` group** — add a `payment-method-options` destination gated on
  `(paymentMethodOptions, read)`. Icon: a payments/receipt glyph
  (e.g. `Icons.payment_outlined` / `Icons.payment`).
- **`sales` group** — add **one** destination:
  - `taxpayer-issuers` gated on `(taxpayers, read)` — icon e.g. `Icons.corporate_fare_outlined` / `Icons.corporate_fare` (legal-entity / "razón social").
  - *(No taxpayer-certificates destination — reached via the issuer detail.)*
- Each destination adds a `NavBranch.*` constant (18/19) and a label tear-off
  resolving a new l10n title, kept as top-level functions so `kNavigationTree`
  stays `const`.
- The existing access-filter (`navDestinationsProvider` → `_filterTree`) hides a
  destination the user cannot read and drops a group left with no visible
  children — no per-feature work (FR-028).

## RBAC objects

Both `paymentMethodOptions(84)` and `taxpayers(24)` already exist in
`lib/core/access/system_object.dart`. **No `system_object.dart` edit** (contrast
spec 014's `facilities(29)` correction). The issuer detail and its embedded
certificate section both fall under `taxpayers(24)`.

## Action-level gating (per screen)

| Screen / section | Create | Update | Delete |
|---|---|---|---|
| Payment Method Options | `can(paymentMethodOptions, create)` | `can(paymentMethodOptions, update)` | `can(paymentMethodOptions, delete)` |
| Taxpayer Issuers | `can(taxpayers, create)` | `can(taxpayers, update)` | `can(taxpayers, delete)` |
| Issuer detail → Certificates section (Agregar upload) | `can(taxpayers, create)` | — (none) | — (none) |

Affordances are **hidden, not disabled**, when the right is absent (constitution §IV).
