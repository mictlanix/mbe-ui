# Data Model: Physical Inventory Counts (070)

Domain entities are freezed and live in `lib/features/inventory/domain/`. Quantities are `Decimal` in the domain, as in the shipped issues entities (the wire carries them as strings), and are formatted by `formattersProvider`. The `String` types in the tables below read as `Decimal` for quantity fields.

## Entities

### InventoryCountSummary (list row)

| Field | Type | From `InventoryCountSummary` |
|---|---|---|
| id | int | `inventoryCountId` |
| facilityId | int | `facility` |
| warehouseId | int | `warehouse` |
| serial | int? | `serial` (null on drafts and cancelled counts) |
| status | `InventoryDocumentStatus` | `status` |
| creatorId | int | `creator` |
| createdAt | DateTime | `creationTime` |

No names: the shared name cells look them up by id (research R12).

### InventoryCount (detail)

The summary's fields, plus:

| Field | Type | From `InventoryCountResponse` |
|---|---|---|
| comment | String? | `comment` (≤ 500) |
| updaterId | int | `updater` |
| updatedAt | DateTime | `modificationTime` |
| lines | `List<InventoryCountLine>` | `lines` (null → empty) |

Derived values:
- `isDraft`, `isCompleted` and `isCancelled` come from the status.
- `title`: "Conteo {serial}" when completed, otherwise "Conteo · Borrador #{id}" (FR-004a).

### InventoryCountLine

| Field | Type | From `InventoryCountLineResponse` | Notes |
|---|---|---|---|
| id | int | `countDetailId` | |
| productId | int | `product` | |
| productCode | String | `productCode ?? ''` | |
| productName | String | `productName ?? ''` | |
| quantity | String | `quantity` | Counted, ≥ 0, up to 4 decimals |
| quantityOnHand | String? | `quantityOnHand` | Null until completed (blind) |
| difference | String? | `difference` | Null until completed; counted minus on hand |

### CountWarnings (confirm response only, never stored)

- `negativeAvailable`: a list of `{productId, productCode, counted, reserved, available}` from `NegativeAvailable`.
- `correctedByOtherCounts`: a list of `{productId, productCode, otherCountId, otherCountSerial?}` from `CorrectedByOtherCount`.
- `isEmpty`: true when both lists are empty.

`CountConfirmResult` is `{InventoryCount count, CountWarnings warnings}`.

### CountLineInput (write side)

- `CountLineInput.byProduct(int productId, String quantity)` is used by Agregar producto.
- `CountLineInput.byCode(String code, String quantity)` is used by quick entry and paste.

It maps to the generated `CountLineSet` with exactly one of `product` and `productCode`.

### CountPaste (paste parser output, research R7)

| Field | Type |
|---|---|
| rows | `List<CountPasteRow>`: `{int row, String code, String quantity}` |
| problems | `List<CountPasteProblem>`: `{int row, String raw, CountPasteProblemKind kind}` |
| readCount | int (non-blank rows) |
| canSend | `rows.isNotEmpty && problems.isEmpty` |

`CountPasteProblemKind` is one of `fieldCount`, `missingCode`, `notANumber`, `negative`, `tooManyDecimals` or `repeatedCode`.

### Paste sending state (presentation, research R8)

```
idle → sending(batch k of n, rowsSent) → done(rowsApplied)
                                        ↘ refused(rowsApplied, List<RejectedRow>{row, code, reasonCode} | AppError)
```

## State transitions (server-driven)

```
Draft ──confirm(includeUncounted)──► Completed   (folio assigned; differences posted; terminal)
Draft ──cancel──────────────────────► Cancelled   (nothing posted; terminal)
Completed ──cancel──► refused: inventory_count.confirmed_cannot_cancel
```

## Validation (client side, mirroring the server)

- Warehouse is required. A non-administrator chooses only from their own facility; the server refuses in-transit warehouses.
- The comment is optional, with at most 500 characters.
- A counted quantity is a decimal ≥ 0 with at most 4 decimals. 0 is valid.
- A paste batch has at most 2,000 rows.

## Action availability

| Action | Needs on 74 | Count state |
|---|---|---|
| See list or detail | read | any |
| Nuevo conteo | create (+ read on warehouses) | n/a |
| Editar encabezado | update | draft |
| Agregar producto, quick entry, Pegar lista, ✎, 🗑 | update (+ read on products for the picker) | draft |
| Confirmar | update | draft |
| Cancelar | delete | draft only |

A missing action is absent, never disabled (FR-015).
