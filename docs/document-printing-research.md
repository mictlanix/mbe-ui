# Document & Ticket Printing — Research & Design Foundation

**Status**: Pre-spec — foundation for a future `NNN-document-printing` feature
**Date**: 2026-09-12
**Audience**: whoever writes the spec, and whoever picks up the mbe-api side
**Sources**: legacy `mbe` (`Web/Mvc/CustomController.cs`, `Web/Views/`, `Web/Content/`),
mbe-api source (`app/`, `pyproject.toml`), the generated OpenAPI client in this repo,
`DESIGN.md` §3.5–§3.6 and §7, and `.specify/memory/constitution.md` v1.13.0

---

## 0. Executive Summary

Legacy `mbe` prints ~52 Razor templates through a **jsreport 3.8.1 sidecar using the
PhantomJS recipe**. We need to replace both halves of that — printable documents and POS
tickets — in a stack where the client is Flutter and the backend is Python/FastAPI.

Four findings dominate everything else:

1. **This is greenfield in both repos, not a migration.** mbe-api has **zero** document
   surface: no PDF/report/print/ticket endpoint across all 34 routers, no templating
   engine, no HTML→PDF library, no QR/barcode library, no object storage beyond a local
   PNG directory, and no background-job mechanism. mbe-ui has no printing code at all, and
   the `printing` package mandated by the constitution's Technology Stack is **not in
   `pubspec.yaml`**. (§2, §3)

2. **The constitution already decided the shape, and it is permissive.** Principle VII
   bans *client-side rendering* but explicitly blesses the consumption path. A
   fetch-and-preview feature needs **no amendment**; a client-side PDF builder would be a
   MAJOR violation. Principle III then fixes the sequencing: mbe-ui must not patch
   mbe-api, so the backend endpoints must be filed as issues and shipped first. (§3.2)

3. **"Documents" and "tickets" are two different problems.** Legacy makes them look like
   one because jsreport solved both — it rendered a 72 mm PDF for receipts and let the
   browser print dialog raster it. **There is no ESC/POS anywhere in the legacy codebase.**
   That means there is no legacy behaviour to preserve, but also no existing local-agent
   infrastructure to lean on. (§1.4, §5)

4. **Cloud-hosted mbe-api + printers behind NAT has a better answer than a relay agent.**
   Since mbe-api cannot open a socket to port 9100, the obvious fix is an on-prem agent per
   store. Inverting the direction — **letting the printer poll** via Star CloudPRNT or
   Epson Server Direct Print — removes that component entirely and permanently closes
   `DESIGN.md` §7's open question about thermal printers. (§5.2)

The single largest scope risk is **CFDI**: it carries 14 per-tenant/per-version layouts in
legacy, and `FiscalDocument` is modelled in mbe-api but has **no router at all**. (§6.3)

---

## 1. How Legacy Prints Today

### 1.1 The pipeline

There is no "printing service". The whole thing is a set of methods on
`mbe/Web/Mvc/CustomController.cs`, the abstract base every MVC controller inherits:

```csharp
public FileStreamResult PdfView (string viewPath, object model)
{
    var rgx = new Regex (@"(src|href)\s?=\s?('|"")/");
    var content = RenderView (viewPath, model);
    string result = rgx.Replace (content, string.Format ("$1=$2{0}/", WebConfig.AppServerUrl));
    var reportingService = new ReportingService (ReportServerUrl);
    var report = reportingService.RenderAsync (new RenderRequest {
        Template = new Template {
            Content = result,
            Engine = Engine.None,
            Recipe = Recipe.PhantomPdf,
            Phantom = new Phantom { Format = PhantomFormat.Letter, Margin = "6 mm", ... }
        }
    }).Result;
    return File (report.Content, MIME_TYPE_PDF);
}
```

Four steps: Razor renders the `.cshtml` **in-process** to an HTML string → a regex rewrites
root-relative `src`/`href` to absolute `AppServerUrl` URLs → the HTML is POSTed to jsreport
with `Engine.None` (jsreport does **no** templating; it is used purely as an HTML→PDF
renderer) → the PDF stream is returned.

Config (`Web/Web.config`) — jsreport is an **unauthenticated local sidecar**, no API key,
no TLS:

```xml
<add key="AppServerUrl"    value="http://localhost:8080" />
<add key="ReportServerUrl" value="http://localhost:3000" />
```

### 1.2 Ticket geometry

The receipt variant only changes the page box:

```csharp
public Stream GetPdfTicket (string viewPath, object model)
{
    return GetPdf (viewPath, model, new Phantom {
        Width = "72 mm", Height = "297 mm", Margin = "0 mm", ...
    });
}
```

Reasserted in `Web/Content/ticket.css`:

```css
@page { size: 72mm 297mm; margin: 0 0; }
body  { font: normal 7.5pt 'Open Sans', sans-serif; }
```

Note the width is **72 mm**, not the 58/80 mm the hardware is usually specified at.

### 1.3 Template inventory

Razor `.cshtml`, not `.html` — there are **zero `.html` files** in the repo. 775 `.cshtml`
total, of which **~52 are print/ticket documents**, plus 3 shared layouts and 2 stylesheets.

| Group | Count | Examples |
|---|---|---|
| Layouts + CSS | 3 + 2 | `_PrintLayout`, `_PrintDLayout`, `_TicketLayout`; `print.css`, `ticket.css` |
| CFDI / fiscal | 14 | `Print40T02Blue` (+`_PageFoot`), `Print33T02Blue`, `Print32*`, `Print22*`, `Print20*` |
| Sales / POS | 9 | `POS/Print` (ticket), `SalesOrders/Print`, `Quotations/Print`, `Payments/_CashCountTicket` |
| Logistics / delivery | 8 | `DeliveryOrders/DeliveryTicket`, `PickUpTicket`, `DeliveryItineraries/ItineraryTicket` |
| Purchasing | 4 | `Purchases/PrintQuotation`, `PurchaseRequests/Print` |
| Inventory | 3 | `Inventory/Issues/Print`, `Receipts/Print`, `Transfers/Print` |
| Other documents | 8 | `ExpenseVoucher/Print`, `ProductionOrders/Print`, `TechnicalService*/Print` |
| Reports (PDF) | 3 | `Reports/PrintCustomerDebtReport`, `CommissionAgentTicket` |

25 call sites across 14 controllers. CFDI naming is **version × tenant brand** (`40` = CFDI
4.0), selected at runtime from a JSON blob on `taxpayer_batch.Template`:

```csharp
template = JsonConvert.DeserializeObject<Template> (batch.Template);
view = string.Format ("Print{0:00}{1}", model.Version * 10, template.Name);
```

with `Template` = `{ Name, Logo, HeaderHeight, FooterHeight, ExtraInfo }`.

### 1.4 How output reaches the printer

**Browser print dialog on a returned PDF. No local agent, no raw printing, no spooler
call.** Every action returns `File(stream, "application/pdf")` and the UI opens it in a tab:

```razor
@Html.ActionLink(Resources.Print, "Pdf", new { id = Model.Id },
                 new { @class = "button icon print", target = "_blank" })
```

Searching the whole `Web/` tree for `escpos`, `RawPrint`, `winspool`, `WritePrinter`,
`StartDocPrinter`, `spooler`, `PrintDocument`, `qz-tray` returns **zero hits**. The
`DeliveryOrdersUseMiniPrinter` setting is only a *template selector* — it picks a 72 mm view
instead of a letter view and does not change the transport.

A second delivery channel exists: **email**, via MimeKit, attaching the same PDF.

### 1.5 Why it is end-of-life

- **PhantomJS has been abandoned since 2018**, and jsreport 3.x dropped the `phantom-pdf`
  recipe in favour of `chrome-pdf` — the current code pins an old jsreport server forever.
- **Windows/.NET-bound beyond jsreport**: `System.Drawing` renders the Code128 barcodes and
  `Gma.QrCodeNet.Encoding.Windows.Render` renders the SAT QR.
- **Rendering has hard network dependencies.** Phantom fetches the CSS, store logo, barcode
  PNG and QR PNG *back* from the MVC app over HTTP, and `ticket.css` pulls three
  `@font-face` files from **`http://fonts.gstatic.com` over plain HTTP**. Any of these
  failing silently degrades or breaks a printed invoice.
- **The render blocks the request thread** — `.Result` on the async call.

---

## 2. What mbe-api Has Today

**No document surface whatsoever.** `grep -riE "pdf|weasyprint|wkhtmltopdf|playwright|reportlab|jinja2|puppeteer|chromium"`
over `app/` and `pyproject.toml` returns **zero hits**. None of the 34 registered routers is
`documents`, `reports`, `print`, `render`, or `fiscal-documents`, and the generated Dart
client in this repo confirms the published OpenAPI spec has no such operation.

Near-misses that should not be mistaken for capability:

- `app/services/documents.py` is **not** document rendering — it is folio assignment
  (`assign_folio`) and editability guards (`assert_editable`).
- `app/enums.py:228-259` carries legacy `SystemObjects` report constants with no
  implementation behind them.

Relevant capabilities and gaps:

| Capability | State |
|---|---|
| Framework | Python ≥3.12, FastAPI 0.136.3, SQLAlchemy 2.x async + aiomysql, `uv` |
| HTML→PDF library | **None** |
| Templating engine | **None** — no `templates/`, no Jinja environment |
| QR / barcode | **None** |
| Blob storage | Local filesystem only — `images_dir` (content-addressed) + `pod_dir`. **No S3/minio** |
| Background jobs | **None** — one cron script `app/jobs/expire_orders.py`; no celery/arq/broker/scheduler |
| Per-tenant template data | **Already mapped** — `TaxpayerBatch.template` (`app/models/fiscal.py:50`) |
| Ticket layout flag | **Already on the wire** — `PaymentMethodOption.display_on_ticket` |

**Every entity that needs printing is already modelled**, including `SalesOrder`,
`CustomerPayment`, `CustomerRefund`, `CreditNote`, `CashSession` (with `POST /{id}/close` —
the exact moment legacy prints the cut ticket), delivery orders and itineraries, and the
full fiscal set `FiscalDocument` / `FiscalDocumentDetail` / `FiscalDocumentXml` /
`TaxpayerBatch`.

The fiscal models are the exception worth flagging: **modelled but not exposed.** Only
`/taxpayer-issuers`, `/taxpayer-certificates` and `/taxpayer-recipients` exist.

---

## 3. What mbe-ui Has Today

### 3.1 No printing code at all

No `printing`, `pdf`, `dart:html`, `package:web`, `Blob`, `file_saver`, `share_plus`, or
ESC/POS anywhere. The only file-IO dependency is `file_picker` (photo and CSD certificate
*uploads*). The only hits for "ticket"/"receipt" are **data** fields consumed by a future
server-side renderer:

- `PaymentMethodOption.displayOnTicket` — "Mostrar en ticket" (spec 015)
- `Facility.receiptMessage` — a free-text ticket footer (spec 014)

Printing has been explicitly deferred by four specs: 020 (`Printing or emailing a sale
ticket or receipt`), 023 (`Reprinting, invoicing, cancelling…`), 029 (assumption **A5 — no
printing**) and 039 (**OS-4**). Spec 029's A5 is worth quoting, because it states the
precondition this document removes:

> **A5 (no printing)**: There is no server-rendered document for a sales order, so legacy's
> printer row action has no counterpart here.

### 3.2 The constitutional frame

`.specify/memory/constitution.md` v1.13.0, principle VII:

> mbe-ui MUST NOT implement offline storage, local sync, or caching layers. All reads and
> writes go directly to mbe-api.
>
> - PDF generation (CFDI invoice representations, POS tickets) MUST remain server-side in
>   mbe-api. mbe-ui only previews, prints, downloads, or shares the rendered bytes via the
>   `printing` package.

This is **permissive, not prohibitive** — the consumption path is pre-blessed and needs no
amendment. Technology Stack likewise already names `printing` as the mandated package.

Principle III is the sequencing constraint:

> mbe-ui MUST NOT directly modify mbe-api's source (or any other sibling repository) […]
> the feature's plan MUST record it as an external dependency […] and a corresponding issue
> MUST be filed against mbe-api.

`DESIGN.md` §3.6 anticipates the renderer choice ("WeasyPrint […] vs ReportLab/fpdf2") and
names a URL shape, `GET /invoices/{id}/pdf` — an invoice path only; **no ticket endpoint URL
is pinned anywhere.**

`DESIGN.md` §7 records the open question this document answers:

> Direct ESC-POS/thermal receipt printer access from cashier stations (§3.6) — browser/
> desktop print dialogs can't drive thermal printers directly; needs its own investigation
> if required for launch.

---

## 4. Decision: WeasyPrint + Jinja2

Render in-process in mbe-api, replacing jsreport+Phantom with no sidecar.

**Why it fits these templates specifically:**

- Legacy templates are already HTML+CSS. Razor → Jinja2 is near-mechanical: same DOM, same
  CSS, same Bootstrap-3 grid classes.
- **None of the 52 templates use JavaScript.** The only dynamic elements were
  server-rendered PNGs, so there is nothing a headless browser would buy.
- Real CSS Paged Media support, which is what both geometries need — `@page { size: Letter }`
  and `@page { size: 72mm 297mm; margin: 0 }` are already written in `print.css` /
  `ticket.css` and port as-is.
- One `uv` dependency plus system pango/cairo. **No Node, no PhantomJS, no sidecar, no
  ~300 MB Chromium layer**, nothing listening unauthenticated on a local port.

**Three improvements over legacy, each closing a real failure mode:**

1. **Zero-network rendering.** Use WeasyPrint's `url_fetcher` to resolve every asset
   in-process — fonts self-hosted and bundled, the store logo read from `images_dir`,
   barcodes and QR inlined as SVG `data:` URIs. This deletes the URL-rewriting regex, the
   HTTP round-trips, and the plain-HTTP `fonts.gstatic.com` dependency in one move.
2. **QR and Code128 become pure Python** — `segno` for QR, `python-barcode` for Code128,
   emitted as inline SVG. Removes the last Windows bindings and prints sharper than the
   legacy PNGs.
3. **Render off the event loop.** mbe-api is fully async with **no job queue**, and a
   WeasyPrint render is ~230 ms. It MUST run via `fastapi.concurrency.run_in_threadpool` —
   otherwise it blocks every other request, repeating legacy's `.Result` mistake in a worse
   place.

**Do not persist PDFs.** Render on demand and stream inline. Every document is deterministic
from data mbe-api already owns, and for CFDI the legally significant artifact is the XML
(already modelled as `FiscalDocumentXml`), not the representation. This avoids introducing
object storage entirely — which matters given mbe-api has only a local PNG directory and no
S3/minio client.

### Alternatives rejected

| Option | Why not |
|---|---|
| **Headless Chromium (Playwright)** | What jsreport itself migrated to, and the most faithful renderer. But ~300 MB image growth, requires a long-lived browser instance to be fast, and buys nothing because no template uses JavaScript. |
| **Typst** | Genuinely excellent and millisecond-fast, but a new template language with zero reuse of existing HTML/CSS — it would mean rewriting 14 CFDI variants from scratch in an unfamiliar system. |
| **ReportLab / fpdf2** | Programmatic layout turns per-tenant CFDI variants into Python branches — worse than the template-per-tenant mechanism legacy already has. |
| **Client-side rendering in Flutter** (`pdf` widget API) | MAJOR constitution violation (§VII), reimplemented per document, with no CFDI-compliance story. |

---

## 5. POS Tickets

### 5.1 The problem

The printers in the field are **thermal ESC/POS, network/Ethernet**, and mbe-api is
**cloud-hosted with the printers behind NAT**. So mbe-api cannot open a socket to port 9100,
and a browser cannot open a raw TCP/serial/USB connection either — on Flutter web, ESC/POS
packages compile but no connection type is functional, because browsers expose no raw TCP,
SPP or USB access.

Legacy sidesteps this by never speaking ESC/POS at all: it renders a 72 mm PDF and lets the
browser print dialog raster it. That works, but at a register it means a print dialog per
sale, slow raster output, and **no cash-drawer kick**.

### 5.2 Decision: printer-initiated cloud polling

The obvious fix is an on-prem relay agent per store — a whole new component to deploy and
maintain. **Inverting the direction removes it.**

Star's **CloudPRNT** and Epson's **Server Direct Print** are firmware features in which the
printer itself periodically issues an outbound HTTPS POST to a URL you host, asking whether
it has work. mbe-api implements that polling endpoint. Consequences:

- **No relay agent, no VPN, no port forwarding, no firewall changes.** The printer is the
  client; NAT is irrelevant because the connection is outbound.
- Works identically regardless of what the cashier runs — **web, Windows desktop, Android
  tablet or phone** — because the client never touches hardware. This matches the stated
  cross-platform trajectory and permanently closes `DESIGN.md` §7.
- Real ESC/POS means instant output, a proper paper cut, and the drawer kick (`ESC p`) that
  the PDF path cannot do at all.
- From mbe-ui the call is a plain `POST` with no bytes to handle.

Printer identity keys naturally to the existing `PointSale` / `CashDrawer` models.

> **Gating unknown — confirm before committing to Phase 2:** the make and model of the
> thermal printers in the field, and whether their firmware supports CloudPRNT or Server
> Direct Print. This is a fact about the hardware that neither repo records.
>
> If the fleet does *not* support it, fall back to a small on-prem relay agent. mbe-api
> generates the identical ESC/POS byte stream either way, so **only the transport differs**
> and no Phase 1 work is affected.

---

## 6. Scope

Four documents, agreed with the user.

### 6.1 POS sale ticket

72 mm × 297 mm. Ports `POS/Print.cshtml` + `_TicketLayout.cshtml`. Consumes
`PaymentMethodOption.display_on_ticket` and `Facility.receipt_message`, both already on the
wire. Highest-frequency document and the primary Phase 2 target.

### 6.2 Sales order / pedido

Letter. Ports `SalesOrders/Print.cshtml` + `_PrintLayout.cshtml`. Reverses specs 029/039's
A5 / OS-4, which deferred printing *only* because no server-rendered document existed.

### 6.3 CFDI invoice representation — the big one

Letter, and it has a **prerequisite: there is no `/fiscal-documents` router at all**, so the
router must land before the renderer.

What legacy does, which must be preserved:

- **PDF and XML are separate artifacts, not embedded** — there is no PDF/A-3 embedding. The
  two files travel side by side (both attached on email).
- **The SAT QR is required.** The payload is the `consultaqr` format: issuer RFC, recipient
  RFC, total, UUID, and **the last 8 characters of the sello**:
  ```csharp
  var data = string.Format (Resources.FiscalDocumentQRCode33FormatString,
                item.Issuer.Id, item.Recipient, item.Total, item.StampId,
                item.IssuerDigitalSeal.Substring (item.IssuerDigitalSeal.Length - 8));
  ```
- Sello/cadena blocks live in per-tenant `*_PageFoot` partials, with header/footer heights
  driven by the `TaxpayerBatch.template` JSON.
- Stamping is external (`PacClient.cs`, DFacture/FacturacionMexico). **PDF generation is
  strictly downstream of stamping** and is not affected by it.

**Recommendation: ship CFDI 4.0 only first.** `Print40T02Blue` is the only current template;
the `Print20/22/32/33` families are historical-reprint support and can follow.

### 6.4 Cash session cut / corte de caja

Ticket geometry. Ports `Payments/_CashCountTicket.cshtml`. Legacy prints this at close, and
mbe-api already has `POST /cash-sessions/{id}/close`.

---

## 7. RBAC — No New `SystemObject` Needed

`lib/core/access/system_object.dart` has **no dedicated print object**. Legacy gated
printing on the document's own object plus the read right, so printing a sales order is
`salesOrders:read`. Reuse the existing guard helpers in
`lib/core/access/access_control.dart`; no enum change and no privilege plumbing.

The enum mirrors mbe-api/legacy `SystemObjects` one-for-one, so inventing a client-only
`print` value would desynchronize it from server-side enforcement — exactly what principle
IV's rationale forbids. The exact helper is
`AccessControlService.can(SystemObject, AccessRight)`
(`lib/core/access/access_control.dart:36`) via `ref.watch(accessControlProvider)`, the idiom
already used at `pos_sales_list_screen.dart:88-90`.

| Document | `SystemObject` | Right |
|---|---|---|
| POS ticket | `pos` | `read` |
| Sales order | `salesOrders` | `read` |
| CFDI representation | `fiscalDocuments` | `read` |
| Cash session cut | ⚠️ **no `cashSessions` object exists** | — |

**Gap to resolve:** there is no `cashSessions` `SystemObject` — only `cashDrawers(10)` and
`cashSessionClose(111)`. `cash_session_detail_screen.dart:64` already gates closing on
`cashSessionClose + update`, so gating the corte print on `cashSessionClose + read` is the
consistent choice even though it reads oddly. Worth one clarifying question to the spec
author (see §11).

Derive the gate from a getter on the document reference rather than repeating it at four
call sites, and re-check it defensively immediately before firing — the way
`close_session_form_controller.dart:111` re-checks before submitting.

The enum does carry ~30 legacy report codes (`customerDebtReport(46)`,
`fiscalDocumentsReport(48)`, `expenseTicket(82)`, `paymentReceipt(85)`, …) that are wired to
nothing. They are for the *reports* module, not for per-document printing, and should be
left alone here.

---

## 8. mbe-ui Consumption Design

### 8.1 Shared module

Add `printing` to `pubspec.yaml` (mandated by Technology Stack, currently absent), then a
new `lib/core/documents/` module holding one fetch path and **one shared
present-a-document surface** — following the precedent of `showRecordSheet`
(`lib/core/widgets/record_sheet.dart:22`) being the single surface for fourteen catalogs.

It must support **both shapes from day one**:

- *fetch bytes → preview / print / download locally* (Phase 1)
- *ask the server to print → receive only success/failure* (Phase 2 ESC/POS)

so adding ESC/POS later is additive, not a rewrite of every call site.

### 8.2 The binary-response trap — and where it actually bites

There is currently **no `ResponseType.bytes` anywhere in the codebase** — every existing
call returns JSON through the generated client.

The good news: **this repo's own generator template already handles it.**
`tool/openapi-templates/dart-dio/api.mustache:56-59` emits

```mustache
    {{#isResponseFile}}
    responseType: ResponseType.bytes,
    {{/isResponseFile}}
```

so the generated method is correct *provided* the OpenAPI operation marks its 200 response
as a file. No raw-dio bypass is needed in that case, which keeps principle III's preferred
path intact.

**The trap is upstream, in FastAPI's default output.** `isResponseFile` is only true for a
`{"type": "string", "format": "binary"}` response schema. A route returning
`Response(content=pdf_bytes, media_type="application/pdf")` with no explicit `responses=`
emits `"content": {"application/json": {"schema": {}}}` instead. Then `responseType` stays
`json`, and dio 5.9.2's default transformer does:

```dart
} else if (!isJsonContent || responseBytes.isNotEmpty) {
  response = utf8.decode(responseBytes, allowMalformed: true);
}
```

`allowMalformed: true` means it **does not throw** — it silently substitutes U+FFFD for every
invalid byte sequence. **The failure mode is a corrupt PDF, not an exception.** This is
structurally identical to the `multipart/form-data` trap principle III already codifies, and
deserves the same treatment.

Therefore:

1. **The mbe-api issue must require the response declaration**, not just the endpoint:
   ```python
   @router.get(
       "/api/v1/sales-orders/{sales_order_id}/ticket",
       response_class=Response,
       responses={200: {"content": {"application/pdf": {"schema": {"type": "string", "format": "binary"}}}}},
   )
   ```
2. **After regenerating, verify the emitted method before trusting it** — the same
   verification principle III already mandates for uploads. Two things must both hold: the
   signature is `Future<Response<Uint8List>>`, **and** the body contains
   `responseType: ResponseType.bytes`.
3. **If either check fails**, fall back to a hand-written `dio.get<List<int>>` with
   `Options(responseType: ResponseType.bytes)` — the same escape hatch
   `ProductRepositoryImpl.uploadPhoto` (`lib/features/catalog/data/product_repository_impl.dart:227`)
   already uses. Compliant either way: principle III requires HTTP through `dio` and forbids
   hand-written *DTOs*, and a PDF has no DTO.

Route everything through the shared `dioProvider` (`lib/core/network/dio_client.dart:30`),
which already attaches the bearer token and 401 handling via `AuthInterceptor`, so the bytes
path inherits auth for free.

### 8.3 Errors

Map to the existing types in `lib/core/errors/app_error.dart` and surface through
`lib/core/widgets/error_banner.dart`. The established convention is a private
`_toAppError(DioException)` per repository (e.g. `sales_order_repository_impl.dart:353`)
alongside the shared `toAppError` in `lib/core/widgets/list_state_views.dart:110` — match it
rather than inventing a new one.

**One case is genuinely new, and it needs a fix in shared code.** `ResponseType.bytes`
applies to **error** responses too, so a `404 {"detail": "Ticket not found"}` arrives as a
`Uint8List`. `_detailFrom` (`lib/core/network/auth_interceptor.dart:71`) does
`if (data is! Map) return null;` — the server's only explanation is dropped and `ErrorBanner`
renders a bare generic message. Worse, `AuthInterceptor.onError` runs *before* the
repository, so `error.error` is already the detail-less `AppError` by the time
`_toAppError` sees it.

Recommended fix, one file and it benefits every future binary endpoint: teach `_detailFrom`
and `_fieldErrorsFrom` to re-hydrate a JSON body from bytes when `data is List<int>` and the
content-type is JSON, *before* the existing `is! Map` guards. This must ship with a unit
test or it will regress silently.

### 8.4 Call sites

All constrained by principle VI — `AppBar.actions` MUST stay empty, screen actions are body
buttons via `CatalogFilterBar`'s `actions` slot or `RecordFormActions`, and a list row may
expose **at most one** action beyond Edit before it must collapse into a kebab.

| Screen | Placement |
|---|---|
| `pos_workspace_screen.dart` `_finish` (~L631-659) | The sale-completed dialog currently has exactly one action, "Nueva venta". Add "Imprimir ticket" beside it. Primary surface. |
| `pos_sales_list_screen.dart` | Reprint row action — consumes the single permitted extra row action. |
| `lib/features/sales/presentation/orders/` | Sales-order document; reverses spec 029 A5 / spec 039 OS-4. |
| `cash_session_detail_screen.dart` | Cut ticket, at close. |

### 8.5 Localization

~11 new keys, in **both** `.arb` files. Note the mechanical detail: `l10n.yaml` sets
`template-arb-file: app_en.arb`, and `app_en.arb` is the file that carries the `@key`
metadata blocks (2533 lines vs `app_es.arb`'s 1129). So while es-MX is authored first and is
the runtime default via `AppSettings.defaultLocale`, **the `@key` blocks go in
`app_en.arb`**.

Conventions to match: flat camelCase, feature-prefixed, fixed suffix vocabulary —
`...Action`, `...ButtonLabel`, `...Tooltip`, `...Title`, `...Message`, `...Error`.

Shared surface: `documentPrintAction`, `documentDownloadAction`, `documentLoadFailedError`,
`documentPrintFailedError`, `documentPreviewUnavailableMessage`. Per-document:
`posSalePrintTicketAction`, `posTicketDocumentTitle`, `salesOrderPrintAction`,
`salesOrderDocumentTitle`, `cashSessionPrintCutAction`, `cashSessionCutDocumentTitle`.
Phase 2 adds `documentPrintSentMessage`.

Reuse rather than duplicate: `retryButton`, `cancelButton`, `okButton`,
`editActionTooltip`, and the `errorNetworkGeneric` / `errorServerGeneric` /
`errorNotFoundGeneric` family already rendered by `ErrorBanner`.

**Do not add CFDI strings yet.** There is no invoicing feature in `lib/features/` (only
`auth, catalog, home, pricing, sales, settings`), so the CFDI document has no call site and
its keys would be unreachable.

### 8.6 `printing` on Flutter web — the risk is narrower than it looks

Reading the package's web plugin settles the design question:

- **`Printing.layoutPdf` does NOT touch pdf.js.** It builds a `Blob`, injects a hidden
  `<iframe>`, and calls `contentWindow.print()`. On desktop browsers the user gets the
  browser's own print preview for free.
- **`PdfPreview` DOES need pdf.js** — it `eval`s a dynamic `import()` of
  `https://unpkg.com/pdfjs-dist@5.7.284/…`. That means a public-CDN runtime dependency, and a
  CSP allowing `script-src unpkg.com 'unsafe-eval'`, which is a hard no in hardened
  deployments.
- **`Printing.sharePdf` on web is a download**, not a share — a separate "Share" action would
  be meaningless.

So make **going straight to the print dialog the default path**, and treat an in-app preview
as optional. **Phase 1 can ship with no `PdfPreview` at all** and still satisfy every
requirement — no CDN, no `unsafe-eval`, nothing in `web/index.html`. If a preview is wanted
later, self-host pdf.js by setting `dartPdfJsBaseUrl` in `web/index.html` and vendoring the
`.mjs` files, rather than accepting the unpkg dependency.

Two further notes:

- **Page format is cosmetic on web.** The web plugin never reads `layoutPdf`'s `format:`
  argument; the browser derives paper size from the PDF's own MediaBox. **The 72 mm ticket
  geometry therefore comes entirely from WeasyPrint's `@page` rule** — which is exactly what
  principle VII wants, but it means a wrong ticket width is always an mbe-api bug and can
  never be patched client-side.
- **Mobile browsers degrade to "open in a new tab".** The iframe path requires a non-mobile
  UA; on a mobile UA `layoutPdf` falls through to an `<a target="_blank">` click — popup-blocker
  territory, and it opens rather than prints. On a *native* Android build this is a non-issue
  (real print plugin), but web-in-a-tablet-browser silently degrades. Worth stating in the
  spec given the stated tablet trajectory.

---

## 9. Sequencing & Dependencies

Principle III fixes the order: **mbe-api ships endpoints first; mbe-ui consumes them after
codegen.** Nothing in this repo can be built against a contract that does not exist.

**Track B — mbe-api (filed as issues, never edited from an mbe-ui session):**

1. **Rendering core** — add `weasyprint`, `jinja2`, `segno`, `python-barcode`; an
   `app/services/rendering/` module with a Jinja environment, a zero-network `url_fetcher`,
   bundled fonts, and `render_pdf(template, context, page) -> bytes` wrapped in
   `run_in_threadpool`. Two base templates mirroring `_PrintLayout` and `_TicketLayout`.
2. `GET /sales-orders/{id}/document` → `application/pdf`, Letter.
3. `GET /sales-orders/{id}/ticket` → `application/pdf`, 72 mm × 297 mm.
4. `GET /cash-sessions/{id}/ticket`.
5. **CFDI** — `/fiscal-documents` router first, then `GET /fiscal-documents/{id}/pdf`.
6. *(Phase 2)* ESC/POS encoder, job queue table, CloudPRNT / Server Direct Print polling
   endpoint, plus `POST /sales-orders/{id}/ticket/print` for mbe-ui to enqueue.

**Track A — mbe-ui:** a spec folder carrying the contracts (endpoint shapes, media types,
page geometries, error cases) so both repos build against one agreed surface, with the
mbe-api issues referenced as dependencies. Then §8's code once endpoints ship.

**Phasing.** Phase 1 ships the full PDF pipeline for all four documents and prints through
the browser dialog — **exactly matching legacy's behaviour, so there is no regression** — on
every platform, with no new infrastructure. Phase 2 adds ESC/POS for the POS ticket alone.
The PDF ticket is still needed after Phase 2 for reprints, email, and any site without a
polling-capable printer, so nothing in Phase 1 is throwaway.

---

## 10. Verification

- **Fidelity** — render each document against a known legacy record and diff against the
  jsreport output for the same id: same page geometry, same totals, same folio. Legacy
  remains available to generate the reference.
- **Geometry** — assert the ticket PDF's MediaBox is 72 mm × 297 mm and the document PDF's
  is Letter.
- **Zero-network render** — run the renderer with outbound network blocked; it must still
  produce a byte-identical PDF. This is the regression test for the single worst legacy
  failure mode (§1.5).
- **CFDI** — decode the generated QR and assert the payload matches the SAT `consultaqr`
  format, including the last 8 characters of the sello.
- **Concurrency** — fire concurrent renders and assert unrelated endpoints stay responsive,
  proving the threadpool wrapper works.
- **mbe-ui** — widget tests for the shared document surface with a faked byte source; an
  `integration_test` covering POS sale → complete → print against a live mbe-api, following
  the established pattern in `test/integration/`.
- **End-to-end, Phase 1** — complete a POS sale in Chrome and print the ticket on a real
  72 mm thermal printer via the OS dialog; verify legibility and width.
- **End-to-end, Phase 2** — enqueue a ticket and confirm the printer polls, prints, cuts,
  and kicks the drawer.

---

## 11. Open Questions

1. **Printer make/model and CloudPRNT / Server Direct Print support** — gates the Phase 2
   transport choice (§5.2). Needs a field check.
2. **Per-tenant template variants** — legacy carries 14 CFDI layouts across brands and
   versions. Recommend one template per document plus CFDI 4.0 only, driving tenant
   customization from the existing `TaxpayerBatch.template` blob rather than porting all 14
   upfront (§6.3).
3. **Email delivery** — legacy attaches the PDF *and* the CFDI XML via MimeKit; mbe-api has
   no SMTP dependency. Out of scope here, but the natural follow-on, and it shares the
   renderer.
4. **The other ~40 legacy documents** — delivery orders/itineraries, purchasing, inventory
   movements, expense vouchers, technical service. Most have no mbe-api router yet (§2).
   They are out of scope for the first pass but reuse the same rendering core at zero
   marginal architectural cost.
5. ~~**`printing` on Flutter web**~~ **Resolved** (§8.6): `Printing.layoutPdf` needs nothing
   in `web/index.html` — only `PdfPreview` pulls pdf.js from a CDN. Ship Phase 1 without an
   in-app preview and the question disappears.
6. **Which `SystemObject` gates the corte de caja print** — there is no `cashSessions`
   object; `cashSessionClose + read` is the consistent choice but reads oddly (§7). Needs a
   spec-author decision.
7. **Does reprinting a corte contradict the close dialog?** `cashSessionCloseSuccessMessage`
   currently tells the user "estas cifras no se mostrarán de nuevo". If a closed session's
   cut can be reprinted later, that sentence becomes false. A product question, not a
   technical one.
8. **Where the sales-order print action lives** depends on spec 039, which is
   spec+research-only on this branch and replaces `order_screen.dart` with a three-step
   workspace. The durable placement is *the step that commits the order* — so this should be
   settled with 039 rather than against today's code.
