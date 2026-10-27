# UI Contracts: Payments List and Search

**Spec**: [../spec.md](../spec.md) | **Data model**: [../data-model.md](../data-model.md) | **Wireframes**: [../wireframes.md](../wireframes.md)

## C1. Routes and navigation (changed)

| Route | Kind | Gate | Screen |
|---|---|---|---|
| `/sales/payments` | Shell branch, appended as `NavBranch.salesPayments` | `customerPayments` (8) read | `PaymentsListScreen` |
| `/sales/payments/:paymentId` | Top-level | `customerPayments` (8) read | `PaymentDetailScreen` |

- **`_routeGate`:** the prefix `/sales/payments` maps to `PrivilegeGate(SystemObject.customerPayments, AccessRight.read)`.
- **Navigation:** the "Pagos" entry in `nav_destinations.dart`'s sales section goes right after cash-sessions, with the same gate and the `Icons.payments_outlined` icon.
- A non-numeric `:paymentId` renders the not-found state. It doesn't throw.

## C2. `PaymentsListScreen` (new)

`lib/features/sales/presentation/payments/payments_list_screen.dart`

The page is the standard list layout: `CatalogFilterBar`, then `Expanded(CatalogListStateView(DataTableView(pagination:)))`, the same as cash sessions.

**`CatalogFilterBar` slots:**

| Slot | This facility (`scope` absent) | All facilities (`scope=all`) |
|---|---|---|
| `actions:` | `SegmentedButton<PaymentsScope>`, only if `can(paymentsEditor, read)` | same |
| `search:` | omitted | `CatalogSearchBar` (hint "Buscar referencia…") writes `ListQuery.search` |
| `filters:` | badged `IconButton.outlined(Icons.tune)` → `showCatalogFilterSheet` | same |

**Columns** (`DataTableView`):

| Column | Facility mode | All facilities mode | Kind |
|---|---|---|---|
| Folio | ✓ | ✓ | `fixedWidth` |
| Fecha | ✓ | ✓ | `fmt.display.dateTime` |
| Sucursal | — | ✓ | `.text`, from `facilityDisplayNameProvider` |
| Cliente | ✓ | ✓ | `.text`. Shows "…" while loading and `#<id>` when the name is null (FR-018) |
| Importe | ✓ | ✓ | Right-aligned, untruncated: `fmt.display.currency(amount)` + `currencyCodeLabel` |
| Forma de pago | ✓ | ✓ | `paymentMethodLabel`, plus " · option name" when present. A missing option shows `#<id>` |
| Referencia | ✓ | ✓ | `.text`. Null shows "—" |
| Tipo | ✓ | ✓ | `paymentTypeLabel` |
| Sin aplicar | ✓ | ✓ | Right-aligned currency |
| Verificado | ✓ | ✓ | `StatusChip` |

- **Row behaviour:** `onRowTap` → `context.push('/sales/payments/<id>')`. There are no row actions (FR-003).
- **Empty state:** filtered shows `paymentsListEmptyFiltered` with a "Quitar filtros" button; unfiltered shows `paymentsListEmpty`.
- **Error state:** retry invalidates the controller. Filters stay in the URL.

**Filter drawer** (`showCatalogFilterSheet`, content in `CurrentListQueryBuilder`):

| Facet | Control | Shown when |
|---|---|---|
| Cliente | `CatalogEntityPicker<CustomerListItem>` | always |
| Fecha | `DateRangeFilterChip` | always |
| Forma de pago | single-select menu over `PaymentMethod` (all values) with a "Todas" option | facility mode |
| Verificado | 3 `ChoiceChip`s: Todos, Verificados, Sin verificar | facility mode |
| Corte de caja | `CatalogEntityPicker<CashSession>` (R7) | facility mode **and** `can(pos, read)` |

Every facet change calls `context.go(query.withFacet(...).copyWith(pageIndex: 0).toUri(...))`. "Limpiar todo" keeps `scope` and clears everything else.

## C3. `PaymentDetailScreen` (new)

`lib/features/sales/presentation/payments/payment_detail_screen.dart`

- **AppBar:** "Ver pago" with Back and no actions.
- **States:** loading uses a centered `CircularProgressIndicator`. Errors use `ErrorBanner` with a retry. Not-found (a 404, or the facility guard tripping) uses `ErrorBanner` with "El pago N no existe." and a "Volver a Pagos" button.

**Body**, top to bottom:

1. **Header row:** "Pago N" and the verified `StatusChip`.
2. **Summary line:**
   - Importe `<amount> <CODE>` · Aplicado `<applied>` · Sin aplicar `<unapplied>` (FR-013a).
   - Aplicado shows a small progress indicator until the applications load. If they fail, it shows "—".
3. **`ResponsiveFormGrid(maxColumns: 2)`** of label/value pairs:
   - Cliente, Fecha, Forma de pago, Opción de pago, Referencia, Tipo, Sucursal, Corte de caja, Verificado por.
   - Empty values show "—".
   - Corte de caja links to `/sales/cash-sessions/:id` only with `can(pos, read)`; otherwise it's plain text.
4. **Aplicaciones section:**
   - The title, then an unpaginated `DataTableView<PaymentApplication>`.
   - **Columns:** Pedido (a link via `orderLinkTargetProvider`, otherwise plain `#id`), Aplicado, Cambio, Aplicó, Fecha and Estado (a "Revertida" `StatusChip` or "—").
   - Reversed rows are rendered with the theme's disabled foreground colour.
   - There is no `onRowTap`.
   - **Empty:** "Este pago no se ha aplicado a ningún pedido."
   - **Error:** an inline `ErrorBanner` with a retry for this section only.

## C4. Repository surface (changed)

`CustomerPaymentRepository` (domain) gains:

```dart
Future<CatalogPage<CustomerPayment>> list({required int facilityId, int? customerId,
    int? cashSessionId, DateTime? dateFrom, DateTime? dateTo, int? methodCode,
    bool? verified, int skip = 0, int limit = 20});
Future<CatalogPage<CustomerPayment>> searchAcrossFacilities({int? customerId,
    String? reference, DateTime? dateFrom, DateTime? dateTo, int skip = 0, int limit = 20});
Future<CustomerPayment> get({required int customerPaymentId});
Future<List<PaymentApplication>> listApplications({required int customerPaymentId});
```

- `facilityId` is **required** on `list`, so no caller can rely on the server's implicit default or forget the scope (R4).
- **Errors:** `DioException` maps through the existing `_toAppError`. A 404 becomes `AppError.notFound`, and a 403 becomes `AppError.auth`.

`CashSessionRepository.list` gains `int? facilityId`.

## C5. Localization (both `.arb` files)

New keys, with Spanish shown and English in `app_en.arb`:

- **Nav and screens:**
  - `navPayments` "Pagos"
  - `paymentsScopeFacility` "Esta sucursal"
  - `paymentsScopeAll` "Todas las sucursales"
  - `paymentsSearchReferenceHint` "Buscar referencia…"
- **Columns:**
  - `paymentsColumnFolio`, `paymentsColumnDate`, `paymentsColumnFacility`, `paymentsColumnCustomer`, `paymentsColumnAmount`
  - `paymentsColumnMethod`, `paymentsColumnReference`, `paymentsColumnType`, `paymentsColumnUnapplied`, `paymentsColumnVerified`
- **Filters:**
  - `paymentsFilterCustomer`, `paymentsFilterDate`, `paymentsFilterMethod`, `paymentsFilterMethodAll` "Todas"
  - `paymentsFilterVerified`, `paymentsVerifiedAny` "Todos", `paymentsVerifiedYes` "Verificados", `paymentsVerifiedNo` "Sin verificar"
  - `paymentsFilterCashSession` "Corte de caja"
- **Status chips:**
  - `paymentVerified` "Verificado"
  - `paymentUnverified` "Sin verificar"
  - `paymentApplicationReversed` "Revertida"
- **Payment types:** `paymentTypeNa`, `paymentTypeImmediate` "Contado", `paymentTypeCreditPayment` "Pago de crédito", `paymentTypePaymentInAdvance` "Pago anticipado", `paymentTypeCreditNote` "Nota de crédito", `paymentTypeExpense` "Gasto"
- **Empty states:** `paymentsListEmpty`, `paymentsListEmptyFiltered`
- **Detail screen:**
  - `paymentViewTitle` "Ver pago"
  - `paymentHeaderTitle` "Pago {id}"
  - `paymentSummaryAmount` "Importe", `paymentSummaryApplied` "Aplicado", `paymentSummaryUnapplied` "Sin aplicar"
- **Detail fields:**
  - `paymentFieldPaymentOption` "Opción de pago"
  - `paymentFieldFacility` "Sucursal"
  - `paymentFieldCashSession` "Corte de caja"
  - `paymentFieldVerifier` "Verificado por"
- **Applications:**
  - `paymentApplicationsTitle` "Aplicaciones"
  - `paymentApplicationsEmpty`
  - `paymentApplicationsColumnOrder` "Pedido", `…Applied` "Aplicado", `…Change` "Cambio", `…Applier` "Aplicó", `…Date` "Fecha", `…Status` "Estado"
- **Not found:** `paymentNotFound` "El pago {id} no existe.", `paymentBackToList` "Volver a Pagos"

Existing keys are reused where they already exist: the filter, apply and clear labels, the retry button, and the payment-method labels.

## C6. Generated client (unchanged)

No regeneration is needed for this delivery: all four operations and their models are present. When mbe-api#270 ships, a follow-up regenerates the client and maps `customerDisplayName` (R2).
