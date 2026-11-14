# UI Contracts: Payment Verification

**Spec**: [spec.md](../spec.md) | **Wireframes**: [wireframes.md](../wireframes.md) | **Research**: [research.md](../research.md)

Keys named here are the ones tests find widgets by.

## C1 — Navigation and route

- **`NavDestination`:**

  | Property | Value |
  |---|---|
  | `id` | `'payment-verification'` |
  | label | `l10n.paymentVerificationMenuTitle` ("Verificación de pagos" / "Payment verification") |
  | icon | `Icons.fact_check_outlined` |
  | selected icon | `Icons.fact_check` |
  | route | `/sales/payment-verification` |
  | branch | `NavBranch.paymentVerification` (25) |
  | gate | `PrivilegeGate(SystemObject.paymentsVerification, AccessRight.read)` |
  | position | right after `payments` |

- **Router:** a new `StatefulShellBranch` is appended last. The gate clause for `/sales/payment-verification` goes before the `/sales/payments` clause (R1).
- **SystemObject:** `PaymentsVerification` (108), documented on the route as §IV requires.

## C2 — Queue screen (`PaymentVerificationScreen`)

- **Filter row:** `CatalogFilterBar` with no search control (§VI: the endpoint has no search).
  - `filters`: the badged button `Key('verification_filter_button')`, which opens `showCatalogFilterSheet`. `onClearAll` goes to the bare path.
  - `actions`: empty. The total is the pagination footer's ("1–20 de N", FR-004). §VI keeps this row for the search box and entity actions, so no count is put here.
- **Filter sheet:**

  | Facet | Key | Control | Shown |
  |---|---|---|---|
  | Facility | `verification_filter_facility` | `CatalogEntityPicker<FacilityListItem>`, unset text "Todas" | only with `can(facilities, read)` (R7) |
  | Date | — | the date-range control Pagos uses | always |
  | Method | `verification_filter_method` | dropdown of "Todos" plus each `PaymentMethod` | always |

- **Table:** `DataTableView<CustomerPayment>`, `Key('verification_table')`. The columns, in order:

  | Column | Alignment |
  |---|---|
  | Folio | text |
  | Sucursal | text |
  | Fecha | text |
  | Cliente | text |
  | Método | text |
  | Referencia | text |
  | Monto | numeric |

  Then the action column. Existing `paymentsColumn*` labels are reused, plus `paymentsColumnFacility`.
- **Row actions:** `buildCatalogRowActions` with no `onEdit`:
  - `primaryAction`: ✓ `Icons.check_circle_outline`, tooltip `l10n.paymentVerifyAction`, key `verify_payment_<id>`.
  - `extraActions`: one action, ✕ `Icons.block`, tooltip `l10n.paymentRejectAction`, key `reject_payment_<id>`.
  - Both actions appear only with `can(paymentsVerification, update)`. Without it, `rowActionsBuilder` is `null`, so the column is left out.
- **Row tap:** opens C4.
- **States:** `CatalogListStateView`.
  - Empty: `l10n.paymentVerificationEmpty`. "Quitar filtros" shows only when `differsFromDefault`.
  - Error: retry.
  - 403: a forbidden view with no retry, as Pagos has, reusing `l10n.paymentsListForbidden`.
- **After a write:** a `SnackBar` shows `l10n.paymentVerifiedSnack(id)` or `l10n.paymentRejectedSnack(id)`, and the page reloads.
- **Compact tier:** `DataTableView`'s stacked rows, with no column dropped. ✓ and ✕ stay on the first line.

## C3 — `buildCatalogRowActions` (core, extended)

- **New parameter:** `CatalogRowAction? primaryAction`.
- **Assert:** `onEdit == null || primaryAction == null`.
- **Order:** `[Edit | primary] + (one extra direct | ⋮ for 2+)`, so a row has at most two icons.
- **Compatibility:** every existing call is unchanged.

## C4 — Read-only payment panel

- **Call:** `showRecordSheet(title: l10n.paymentHeaderTitle(id), isDirty: () => false, form: (_) => VerificationPaymentPanel(payment))`.
- **Header:** `PaymentVerifiedChip(verified: false)`.
- **Body:** a `ResponsiveFormGrid` (2 columns, or 1 at compact width) of label and value pairs:
  - Sucursal, Fecha, Cliente, Tipo, Método, Referencia;
  - Monto with currency, Sin aplicar;
  - Caja (`#id` text or `—`).
- **Behaviour:** no network request beyond the name providers, no editable field and no action button. The key is `Key('verification_panel_<id>')`.

## C5 — Verify dialog (`showVerifyPaymentDialog(context, payment)`)

- **Body:** a `ResponsiveDialog` showing Folio, Cliente, Monto and Referencia, then `l10n.paymentVerifyIrreversible`.
- **Buttons:** Cancelar, and `FilledButton` `Key('verify_payment_confirm')`.
- **Submitting:** both buttons are disabled, the dialog can't be dismissed, and the confirm button shows a spinner.
- **Result:** `null` closes the dialog with `true`. An `AppError` shows a `FormErrorBanner` (`localizeProblem`, or `l10n.paymentVerifyUnknown` for network or timeout), and the confirm button is replaced by "Cerrar" (`MaterialLocalizations.of(context).closeButtonLabel`).
- **Shared:** the queue and the payment view call the same dialog.

## C6 — Reject dialog (`showRejectPaymentDialog(context, payment)`)

- **Body:** the same facts as C5, then the reason field and the note.
  - Reason field `Key('reject_reason_field')`: multi-line, `maxLength: 500` with a counter.
  - Note: `l10n.paymentRejectNote`.
- **Confirm:** `Key('reject_payment_confirm')`, enabled only when `reason.trim().isNotEmpty`.
- **Submitting and result:** as in C5. The unknown-result wording is `l10n.paymentRejectUnknown`.

## C7 — Payment view (`payment_detail_screen.dart`)

- **Buttons:** in the header `Wrap`, after `PaymentVerifiedChip`:
  - `OutlinedButton.icon` `Key('payment_verify_button')`, ✓ "Verificar";
  - `OutlinedButton.icon` `Key('payment_reject_button')`, ✕ "Rechazar".
- **Shown when:** `payment.verifierId == null && can(paymentsVerification, update)`.
- **Behaviour:** they open C5 and C6. After a verification the view reloads (R4), showing "Verificado" and "Verificado por <name>".

## C8 — Strings and error codes

- **New `.arb` keys (es and en):**
  - `paymentVerificationMenuTitle`, `paymentVerificationEmpty`;
  - `paymentVerifyAction`, `paymentRejectAction`, `paymentVerifyTitle`, `paymentRejectTitle`;
  - `paymentVerifyIrreversible`, `paymentRejectReasonLabel`, `paymentRejectNote`;
  - `paymentVerifiedSnack`, `paymentRejectedSnack`, `paymentVerifyUnknown`, `paymentRejectUnknown`;
  - `paymentVerificationMethodAll`, `paymentVerificationFacilityAll`;
  - `apiErrorPaymentAlreadyVerified`.
- **Error codes:** `payment.already_verified` goes into `localizeProblem`, `localizedErrorCodes`, the fixtures and `code-scope.tsv`, where it becomes `IN` (R8).
