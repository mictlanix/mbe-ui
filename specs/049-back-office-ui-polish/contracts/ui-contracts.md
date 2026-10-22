# UI Contracts: Back-Office UI Polish

**Feature**: [spec.md](../spec.md) | **Research**: [research.md](../research.md)

Each contract is something a widget test can verify. The keys listed are the ones tests find widgets by.

## C1 — Multi-currency option

Covers FR-001–FR-007 (R1–R3).

| Option | Surface | Expected |
|---|---|---|
| off | Navigation (rail and drawer) | No item with id `exchange-rates`, even for an administrator. |
| off | `go('/exchange-rates')` | Redirects to `/`. |
| off | Order header, expanded | No `sales_order_currency_field` and no `salesOrderExchangeRateLabel` text. |
| off | Quote header | No `salesQuoteCurrencyLabel` text. |
| off | Product form (create and edit) | No `currency_field`. A create request carries `currency: MXN`. An edit resends the loaded currency. |
| off | Payment step | `payment_amount_field` has no `prefixText`. |
| on | All of the above | Same as before this feature, still subject to the privilege gates. |

## C2 — Facility logo control

Covers FR-008–FR-012 (R4).

**Keys**:
- `facility_logo_section`
- `facility_logo_upload_button`, shown when there is no logo and nothing staged
- `facility_logo_replace_button`, shown when there is a logo or something staged
- `logo_field` is **gone**.

**Behavior**:
- **Display.** The section shows an `Image.memory` preview while bytes are staged. Otherwise it shows `ProductPhoto(photoUrl: logoUrl)`, which renders its placeholder when the URL is `null` or unreachable, without throwing.
- **Buttons.** The buttons appear only when the form fields are enabled (create, or edit with update privilege), and are disabled while submitting.
- **Invalid file.** An invalid pick shows `facilityLogoInvalidTypeError` or `facilityLogoTooLargeError` under the section, and nothing is staged.
- **Save order.** Create or update runs first, then `uploadLogo` if bytes are staged.
  - **Upload failed.** The form stays open, showing `facilityLogoUploadFailedError`, and the record stays saved. Saving again retries as update + upload, even right after a create.
  - **Create failed.** No upload is attempted.

## C3 — `CatalogSearchBar`

Covers FR-013–FR-015 (R5).

- **One icon.** Exactly one `Icons.search` is a descendant, and it is the suffix `IconButton`. Tapping it calls `onSubmitted` with the current text.
- **Submitting.** Enter calls `onSubmitted`. Typing alone doesn't.
- **Shape.** The resolved `enabledBorder` and `focusedBorder` are `OutlineInputBorder`s with a corner radius ≥ the box height / 2.
- **Shared helper.** `ProductSearchField`'s border comes from the same `pillInputBorder` helper.

## C4 — `FactStripRow` (quote and order headers)

Covers FR-016–FR-019 (R6).

- **Wide layout.** At 1440px with the quote facts (Referencia, Estado, Fecha, Vencimiento and Moneda, the last only when the option is on), every fact has the same `dy`, so they sit on one line.
- **Trailing edge.** `sales_quote_more_details_toggle`'s right edge is within the card padding of the card's right edge. The same holds for the order screen's trailing group (`sales_order_more_details_toggle`).
- **Narrow layouts.** At 390px and at the largest text scale, there are no overflow errors in either label state ("Más detalles" / "Menos detalles"), and the toggle is fully on screen.

## C5 — Embedded certificates table

Covers FR-020–FR-021 (R7).

- **No inner scroll.** With 1 and with 8 certificates, every `Scrollable` inside `taxpayer_certificates_table` reports `maxScrollExtent == 0` vertically.
- **Edges.** The table's left and right global edges are within 1px of those of the first `ResponsiveFormGrid` field on the issuer screen, at 1024px and at 1600px.
- **Empty.** With no certificates, the existing `noCertificatesFound` text shows, with no fixed-height box.

## C6 — Pricing screen alignment

Covers FR-022 (R8).

The search field, the first worklist `ChoiceChip`, the table `Card` and the hint text have left edges within 1px of one another at 800px (Medium) and 1440px (Expanded). The same holds for the right edges of the search row and the table.

## C7 — Employee form

Covers FR-023–FR-024 (R9).

- **Two columns.** At two-column width, `sales_person_switch`'s `dy` equals `enroll_number_field`'s, and its `dx` is greater.
- **Estado.** The status field's width equals the form content width.
- **Saving.** Toggling the switch and saving persists `salesPerson` exactly as before.
