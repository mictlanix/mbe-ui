# Contract: Routes, Navigation & RBAC Gating

**Feature**: `015-fiscal-catalogs` | **Date**: 2026-07-21

## NavBranch ↔ router branch-order invariant

`NavBranch` indices are **positional** and MUST match the shell-branch order in
`app_router.dart` (documented at `nav_destinations.dart`; honored by specs
012/013/014). This feature appends three branches after `facilities(17)` in the
**same order** in both files:

| NavBranch | Index | Route | Nav group |
|---|---|---|---|
| `paymentMethodOptions` | 18 | `/payment-method-options` | `catalogs` |
| `taxpayerIssuers` | 19 | `/taxpayer-issuers` | `sales` |
| `taxpayerCertificates` | 20 | `/taxpayer-certificates` | `sales` |

## Shell branches (list screens) — appended in `app_router.dart`

```
/payment-method-options   → PaymentMethodOptionsListScreen
/taxpayer-issuers         → TaxpayerIssuersListScreen
/taxpayer-certificates    → TaxpayerCertificatesListScreen
```

## Flat detail sub-routes (appended after `/facilities/:facilityId`)

```
/payment-method-options/new                        → PaymentMethodOptionDetailScreen()          (create)
/payment-method-options/:paymentMethodOptionId     → PaymentMethodOptionDetailScreen(id: int.parse(...), forceReadOnly: ?view=true)

/taxpayer-issuers/new                              → TaxpayerIssuerDetailScreen()               (create)
/taxpayer-issuers/:rfc                             → TaxpayerIssuerDetailScreen(rfc: <String>, forceReadOnly: ?view=true)
                                                     // String path param — RFC, NO int.parse (recipient precedent)

/taxpayer-certificates/new                         → TaxpayerCertificateUploadScreen()          (upload/create)
/taxpayer-certificates/:taxpayerCertificateId      → TaxpayerCertificateDetailScreen(id: <String>, forceReadOnly: true)
                                                     // String path param; ALWAYS read-only — no edit route target,
                                                     // no delete action (research §9)
```

**Notes**
- Payment Method Options follows the int-keyed catalog route shape (`/new` + `int.parse(:id)` + `?view=true`), exactly like Warehouses.
- Taxpayer Issuers follows the **String-keyed** shape (Taxpayer Recipients precedent): no `int.parse`, RFC is the raw path param, editable only in create mode.
- Taxpayer Certificates has **no edit route** — its detail is always read-only; its "create" route is the upload form. The read-only detail's AppBar carries **no** read-only→edit toggle (there is no editable form to switch to).

## `_routeGate` additions (`app_router.dart`)

```dart
if (location.startsWith('/payment-method-options')) {
  return (object: SystemObject.paymentMethodOptions, right: AccessRight.read);
}
if (location.startsWith('/taxpayer-issuers')) {
  return (object: SystemObject.taxpayers, right: AccessRight.read);
}
if (location.startsWith('/taxpayer-certificates')) {
  return (object: SystemObject.taxpayers, right: AccessRight.read);
}
```

Placement: alongside the other catalog gates; all gate on `AccessRight.read`
(the screen then further restricts create/update/delete actions). **Order the
issuer gate before any hypothetical prefix collision** — there is none here
(`/taxpayer-issuers` vs `/taxpayer-certificates` vs `/taxpayer-recipients` are
distinct prefixes).

## Nav destinations (`nav_destinations.dart`)

- **`catalogs` group** — add a `payment-method-options` destination gated on
  `(paymentMethodOptions, read)`. Icon: a payments/receipt glyph
  (e.g. `Icons.payment_outlined` / `Icons.payment`).
- **`sales` group** — add two destinations:
  - `taxpayer-issuers` gated on `(taxpayers, read)` — icon e.g. `Icons.corporate_fare_outlined` / `Icons.corporate_fare` (legal-entity / "razón social").
  - `taxpayer-certificates` gated on `(taxpayers, read)` — icon e.g. `Icons.verified_user_outlined` / `Icons.verified_user` (digital seal certificate).
- Each destination adds a `NavBranch.*` constant (18/19/20) and a label tear-off
  resolving a new l10n title, kept as top-level functions so `kNavigationTree`
  stays `const`.
- The existing access-filter (`navDestinationsProvider` → `_filterTree`) hides a
  destination the user cannot read and drops a group left with no visible
  children — no per-feature work (FR-028).

## RBAC objects

Both `paymentMethodOptions(84)` and `taxpayers(24)` already exist in
`lib/core/access/system_object.dart`. **No `system_object.dart` edit** (contrast
spec 014's `facilities(29)` correction). Taxpayer Issuers and Taxpayer
Certificates deliberately share `taxpayers(24)`.

## Action-level gating (per screen)

| Screen | Create | Update | Delete |
|---|---|---|---|
| Payment Method Options | `can(paymentMethodOptions, create)` | `can(paymentMethodOptions, update)` | `can(paymentMethodOptions, delete)` |
| Taxpayer Issuers | `can(taxpayers, create)` | `can(taxpayers, update)` | `can(taxpayers, delete)` |
| Taxpayer Certificates | `can(taxpayers, create)` (upload) | — (none) | — (none) |

Affordances are **hidden, not disabled**, when the right is absent (constitution §IV).
