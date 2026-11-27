# Data Model: Purchase Requests with Approval (079)

Domain entities are freezed classes in `lib/features/purchases/domain/entities/`, mapped from the generated `mbe_api_client` models in the repository impl. No hand-written DTOs (§III).

## Entities

### PurchaseRequestStatus (enum)

| Value | Wire (`RequestStatus`) | Label (es) | Chip tone / icon |
|---|---|---|---|
| `draft` | `draft` | Borrador | neutral / `edit_note` |
| `submitted` | `submitted` | Enviada | info / `schedule_send` |
| `approved` | `approved` | Aprobada | success / `task_alt` |
| `cancelled` | `cancelled` | Cancelada | error / `block` |

An unknown wire value maps to `AppError.server` in the repository, as receipts do.

### PurchaseRequestSummary

From `PurchaseRequestSummary` (list and queue rows).

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `purchaseRequestId` | |
| serial | int? | `serial` | null until the first submit |
| status | PurchaseRequestStatus | `status` | |
| warehouseId | int | `warehouse` | name via `warehouseDisplayNameProvider` |
| facilityId | int? | `facility` | name via `facilityDisplayNameProvider` |
| date | DateTime | `date` | local wall clock (spec 043) |
| comment | String? | `comment` | |
| creatorId | int | `creator` | employee id; name via `employeeDisplayNameProvider` |
| updaterId | int | `updater` | |
| approverId | int? | `approver` | set on approve, cleared on reject |
| approvalTime | DateTime? | `approvalTime` | |
| lineCount | int | `lineCount` | |

Derived: `folioLabel` = `serial` formatted, or "Borrador #{id}" when `serial` is null (FR-004). Title = "Solicitud {serial}" or "Solicitud · Borrador #{id}" (FR-005).

### PurchaseRequest

The summary's fields, plus `lines: List<PurchaseRequestLine>`. The server's `warnings` (English, uncoded) are dropped in the mapping (§III, research R7).

### PurchaseRequestLine

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `purchaseRequestDetailId` | |
| productId | int | `product` | |
| productCode | String | `productCode` | empty string when null |
| productName | String | `productName` | ≤ 250, editable on a draft |
| quantity | Decimal | `quantity` (String) | > 0, ≤ 2 decimals |
| warehouseId | int? | `warehouse` | destination; any facility, never in transit |
| toPurchase | bool | `toPurchase` | the purchase mark |
| minOrderQty | int? | `minOrderQty` | |
| purchaseOrderId | int? | `purchaseOrder` | the live PO holding this line |
| purchaseOrderStatus | InventoryDocumentStatus? | `purchaseOrderStatus` (`DocumentStatus`) | draft / completed / cancelled; shown with the inventory status chip |

### PurchaseRequestPage

`items: List<PurchaseRequestSummary>`, `total: int`, wrapped as the shared `CatalogPage`.

### BulkApproveOutcome

From `BulkApproveResponse.results`.

| Field | Type | Notes |
|---|---|---|
| requestId | int | |
| approved | bool | |
| problem | ApiProblem? | built from `code` + `params` when refused; localized with `localizeProblem` |

### BelowMinimum (derived, FR-013)

`belowMinimum(lines)` → one per line where `minOrderQty != null && minOrderQty > 1 && quantity < minOrderQty`: `{productCode, quantity, minimum}`. Same rule as the server's `below_minimum_warning`. Pure domain function with unit tests.

## Filters

### PurchaseRequestsFilter (list, in the URL via `ListQuery`)

`all: bool` (false), `status: PurchaseRequestStatus?`, `facilityId: int?`, `warehouseId: int?`, `creatorId: int?`, `from: Date?`, `to: Date?`, `serial: int?`, `pageIndex: int`. The badge counts status, facility, warehouse, creator and the date range (not `all`, not `serial`).

### ApprovalQueueFilter

`facilityId: int?`, `pageIndex: int`.

## State transitions

```text
            create                submit (first: takes the facility's next serial)
  (none) ─────────▶ draft ───────────────────────────────▶ submitted
                     ▲                                       │   │
                     └──────────── reject (reason) ──────────┘   │ approve / bulk approve
                                    (keeps serial)                ▼
   draft / submitted / approved ── cancel ──▶ cancelled      approved
```

- Only a draft is editable (header, lines) and submittable.
- Only a submitted request can be approved or rejected.
- Lines can be marked or unmarked only on a submitted or approved request; a line on a live PO cannot be unmarked.
- Cancel is refused while any line is on a live PO. A cancelled request never changes.

## Action availability

`can(o, r)` is `accessControlProvider.can`. `own` = the user is an administrator, or the request's facility is null, or it equals `UserSettings.facilityId` (research R12).

| Action | Where | State | Rights | Facility |
|---|---|---|---|---|
| Open list | nav | — | read 86 | — |
| Nueva solicitud | list bar | — | create 86 + read 4 | picker scoped (R6) |
| Editar encabezado | detail | draft | update 86 + read 4 | own |
| Agregar producto | detail | draft | update 86 + read products | own |
| Line ✎ / 🗑 | detail lines | draft | update 86 | own |
| Enviar | detail | draft | update 86 | own |
| Cancelar | detail | draft, submitted, approved | delete 86 | own |
| Mark / unmark line | detail lines | submitted, approved | update 20 | any |
| Aprobar | detail | submitted | update 96 (+ read 86 to be on the detail) | any |
| Rechazar | detail | submitted | update 96 (+ read 86) | any |
| Open queue | nav | — | read 96 | — |
| Row ✓ Aprobar | queue | submitted | update 96 | any |
| Select + Aprobar seleccionadas | queue | submitted | update 96 | any |
| Row tap → detail | queue | — | read 86 | — |
| Filter: facility / warehouse / requester | list, queue | — | read on facilities / warehouses / employees | — |

A cancelled request offers nothing. Absent, never disabled (§IV, FR-025). The one disabled control is "Aprobar seleccionadas" with an empty selection, which is present because the user can act.
