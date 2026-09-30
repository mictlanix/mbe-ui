# Research: Document Printing

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-30

This feature builds on [docs/document-printing-research.md](../../docs/document-printing-research.md). That document is the pre-spec foundation, and its §0.1 records what mbe-api#231 shipped. The entries below settle only the questions the plan had to answer. Citations to the `printing` package refer to `printing-5.15.1`; to `file_picker` they refer to `8.3.7`, the locked version.

---

## R1. The `printing` package: version and SDK

**Decision**: Add `printing: ^5.15.1`. It brings `pdf ^3.13.0`, `image`, `http` and `web` with it. **Leave `environment.sdk` at `^3.10.3`** (revised during implementation; see below).

**Rationale**: Constitution Technology Stack names `printing` for preview, print and share, and research §3.1 notes it is absent from the repo. Version 5.15.1 declares `sdk >=3.12.0`, `flutter >=3.41.0`, and the installed toolchain (Flutter 3.44.2, Dart 3.12.2) satisfies that, so it resolves.

**Revised at implementation: the planned bump to `^3.12.0` is not made.** pub checks a dependency's SDK requirement against the *installed* SDK, not the root's declared lower bound, so `printing` resolves and builds under `^3.10.3`. Raising the root bound alone also breaks the app: it moves `mbe_ui` to language version 3.12 while the generated `mbe_api_client` package stays at 3.10, and every library that imports the client then fails to compile with "The language version override has to be the same in the library and its part(s)." `tool/generate_api_client.sh` (lines 101-111) deliberately copies the root's lower bound into the generated package's `pubspec.yaml`, so the two move together at a regeneration. Patching only the generated pubspec by hand would edit a generated file (§III). A developer on an SDK older than 3.12 gets pub's own clear error when resolving `printing`. If the bound is raised later, do it together with a regeneration of the client.

**Alternatives considered**: Pinning an older `printing`. Rejected: older versions default pdf.js to older unpkg builds. Raising `environment.sdk` to `^3.12.0`, as first planned. Rejected for the reason above.

---

## R2. The preview renders its own pages; `PdfPreview` is not used

**Decision**: Build the preview on `Printing.raster(bytes, dpi:)`, which returns `Stream<PdfRaster>`, and draw the pages with `Image` inside our own zoomable viewer. Do not use the package's `PdfPreview` widget.

**Rationale**: The spec fixes the preview's shape: a modal dialog with our own title bar, zoom controls, a page indicator that is always shown, and an action bar with Descargar and Imprimir (FR-010–FR-012). `PdfPreview` brings its own toolbar, its own actions and its own layout, so bending it to that shape would cost more than drawing the pages ourselves. `raster()` yields one image per page, which gives the page count the indicator needs as a by-product (`lib/src/raster.dart:55-72`).

The raster backend on each platform:

| Platform | Raster backend |
|---|---|
| Web | pdf.js (R3) |
| macOS / iOS | CoreGraphics |
| Android | `PdfRenderer` |
| Windows / Linux | PDFium, which is fetched at *build* time, never at runtime |

All six platforms support both raster and print.

**Alternatives considered**: `PdfPreview`. Rejected: it can't take our layout, and on web it needs the same pdf.js setup anyway. A browser `<iframe>` or `<embed>` of the PDF was also rejected: it would render the browser's own viewer chrome, give no zoom or page indicator we control, and wouldn't work on native platforms.

---

## R3. pdf.js on web: served by the app itself (FR-014)

**Decision**: Vendor `pdf.min.mjs` and `pdf.worker.min.mjs` from `pdfjs-dist@6.2.108/build/` into `web/pdfjs/`, together with pdf.js's `LICENSE`. In `web/index.html`, before the Flutter bootstrap script, set `<script>var dartPdfJsBaseUrl = "./pdfjs/";</script>`. The value is relative to the app's base href and needs its trailing slash.

**Rationale**: `printing`'s web plugin loads pdf.js from `https://unpkg.com/pdfjs-dist@6.2.108/build/` unless that global is set (`printing_web.dart:38-39, 52-54, 75-87`). A request to a third-party CDN on every preview breaks FR-014 and SC-004. The global is the package's documented self-hosting knob (`README.md:55-67`). Version 6.2.108 is pinned to match what the package expects, and moving it is a deliberate act done together with a `printing` upgrade.

**Verified in a real browser (2026-09-30).** A page served from the release web build ran the same steps `printing_web` does (an `eval`'d dynamic `import()` of `pdf.min.mjs`, then `workerSrc`) in headless Chrome 154. With `dartPdfJsBaseUrl = "./pdfjs/"` it loaded, the worker ran, and a 204 × 200 pt page rastered at 200 dpi to 567 × 556 px with its text drawn. The only host contacted was the page's own origin. With the bare `"pdfjs/"` it failed with `Failed to resolve module specifier 'pdfjs/pdf.min.mjs'`, which is why the value must start with `./`. This reproduces the package's loading path; it is not the app's own preview, which still needs the manual check in quickstart M3/M9.

**Not needed**: `cmaps/`, because the package never configures it (`printing_web.dart:311`). The WeasyPrint output embeds TrueType subsets and needs no CMap lookups. The `wasm/` JPEG2000 decoders are also not needed: mbe-api's templates embed SVG barcodes and PNG/JPEG logos, never JPX.

**Licensing**: `printing` is Apache-2.0, and so is pdf.js. The vendored folder keeps pdf.js's `LICENSE` beside the two files.

**Alternatives considered**: Leaving the CDN default. Rejected, as it violates FR-014. Loading pdf.js through our own `dart:js_interop` wrapper, to avoid the package's `eval` (R4), was also rejected. It would be about 150 lines of interop to maintain, it would duplicate what the mandated package already does, and it wouldn't remove the CSP needs of `layoutPdf` (R4), so it would buy nothing.

---

## R4. Content Security Policy: what the package needs

**Decision**: Record as a deployment constraint (see [quickstart.md](./quickstart.md) § Deployment): any Content Security Policy added in the future must allow what the package needs:
- `script-src 'self' 'unsafe-eval' 'unsafe-inline'`
- `worker-src 'self' blob:`

No CSP is added by this feature.

**Rationale**: Today `web/index.html` sets no CSP. Its only inline script is the existing splash remover. So nothing is blocked now, and the feature does not introduce a policy it would then have to relax. But the requirement is real and non-obvious:
- `raster()` and `info()` both reach pdf.js through `window.eval`, even when it is self-hosted (`printing_web.dart:58-64, 93-104, 116, 304`). That requires `'unsafe-eval'`.
- `layoutPdf` prints by injecting an inline `<script>` into a hidden iframe (`printing_web.dart:181-188`). That requires `'unsafe-inline'`.

Research §8.6 called `'unsafe-eval'` "a hard no in hardened deployments". That judgement was about pulling code from a *public CDN* under `'unsafe-eval'`. With every script served from the app's own origin, the remaining exposure is that the same-origin code may evaluate strings. FR-014 as written, "no third-party service", is met in full.

**Alternatives considered**: A custom interop path with no `eval`. Rejected for the reasons in R3, and because the print path's `'unsafe-inline'` would remain.

---

## R5. Printing: `Printing.layoutPdf`, and what the web can't know

**Decision**: Print with `Printing.layoutPdf(onLayout: (_) async => bytes, name: filename)` and ignore its return value.

**Rationale**:
- On desktop browsers, `layoutPdf` loads the bytes into a hidden iframe as a Blob and calls `contentWindow.print()`. The browser's own print preview then applies (`printing_web.dart:165-241`).
- The page size comes from the PDF itself; `format` is ignored on web (research §8.6, `printing_web.dart:134`). The 72 mm ticket geometry is therefore entirely mbe-api's.
- On a phone or tablet browser (a UA containing "Mobile"), it clicks an `<a target="_blank">` instead (`printing_web.dart:245, 267-275`).
- **On web, `layoutPdf` returns `true` whether the user printed, cancelled, or the pop-up was blocked** (`printing_web.dart:159-161, 220, 276`). On native platforms, `false` means cancelled.

Consequences for the spec, applied in the same change as this plan:

1. **FR-031** (cancelling print is not an error) holds on every platform: `false` is treated as "nothing to report", never as a failure.
2. **Spec edge case "the browser blocks the new tab … the user is told"** cannot be met. The package gives no signal on any platform. The edge case now reads: Descargar stays available as the fallback, and no message is promised. The wireframe's "print hand-off failed" state is removed.

**Alternatives considered**: Detecting a blocked pop-up ourselves with `window.open` and checking for `null`. Rejected: it means writing our own mobile print path beside the package's, and it still can't detect a user cancelling the print.

---

## R6. Downloading: `Printing.sharePdf` on every platform

**Decision**: Descargar calls `Printing.sharePdf(bytes: bytes, filename: filename)` on every platform.

**Rationale**:

| Platform | What `sharePdf` does |
|---|---|
| Web (primary target) | A real download with `download=filename` (`printing_web.dart:257, 268-269`) |
| Android / iOS | Opens the share sheet, which includes "Save to Files" / Drive |
| macOS | Opens the share sheet |
| Windows / Linux | Opens the file in the default PDF viewer, where the user can Save As (`print_job.cpp:334-362`, `print_job.cc:250-270`) |

Every platform meets US2-3 ("saved **or offered for saving**"). No second package or platform branch is needed.

**Alternatives considered**: `file_picker.saveFile` for a real save dialog on desktop. Rejected for this feature:
- In 8.3.7 it throws `UnimplementedError` on web, so web would still need `sharePdf`.
- On macOS it rejects bytes, and on Windows/Linux it ignores them, so we'd have to write the file ourselves with `dart:io` (`file_picker.dart:157-198`, `file_picker_macos.dart:82-83`).

That is three platform branches for a secondary target. It can come later if desktop users ask for a real Save dialog.

---

## R7. Raster resolution, and zoom without re-rendering

**Decision**:
- Raster once per open, at **200 dpi**, lowered for very tall or very large pages so that no page exceeds **30 000 px on a side or 16 MP in area**.
- Zoom scales the rastered images. It never renders the pages again.
- The zoom range is **50 %–400 %** of fit-to-width. The steps are 50, 75, 100, 125, 150, 200, 300 and 400 %, and fit-to-width is where every document opens (FR-011).

**Rationale**:
- **Letter at 200 dpi** is 1700 × 2200 px. That stays sharp at 200 % in a dialog about 900 px wide.
- **A 72 mm ticket at 200 dpi** is 567 px wide. A 1000 mm ticket (about 200 lines) is 7 874 px tall, which is 4.5 MP and well inside browser canvas limits (about 32 767 px a side in Chrome and Firefox, about 16.7 MP of area on iOS Safari). The cap only matters for a ticket longer than about 3.8 m.
- **Why not re-render on zoom**: pdf.js on web makes a PNG round trip per page, and re-rendering on every zoom step would stall the dialog.
- Above about 200 % the pages soften. That trade-off is accepted.

**Alternatives considered**: DPI tied to the zoom level with re-rendering. Rejected: it's slow on web, and it means state for cancelling renders.

---

## R8. The zoomable viewer: `InteractiveViewer` plus our own input handling

**Decision**: Stack the page images vertically inside `InteractiveViewer(constrained: false)`, driven by a `TransformationController`.
- **Pinch** on touch screens and trackpads is the viewer's built-in scaling.
- **Buttons** (`[−]`, `[+]`, fit-to-width) set the controller's matrix to the chosen step, keeping the viewport's centre in place.
- **Mouse wheel**: a `Listener` on `PointerScrollEvent` zooms when Ctrl or ⌘ is held and pans vertically otherwise. The viewer's own wheel-to-zoom is turned off with `scaleFactor`.
- **The page indicator** is worked out from the controller's vertical translation and scale against the pages' laid-out heights. The page shown is the one crossing the viewport's vertical centre.

**Rationale**: `InteractiveViewer` is the framework's pan-and-zoom widget. By default, a plain mouse wheel *zooms* it, which on desktop would make scrolling through a pedido impossible. Wheel-pans, Ctrl-wheel-zooms is the convention every desktop PDF viewer follows. Panning both ways once zoomed happens inside a document canvas, not in a data table, so §VI's horizontal-scroll rule doesn't apply (wireframes, Open Question 4).

**Alternatives considered**:
- A `ListView` of pages with `Transform.scale`. Rejected: it can't pan sideways, and pinch would need its own gesture code.
- `PdfPreview`'s built-in zoom. Rejected in R2.

---

## R9. Server error bodies arrive as bytes (FR-030)

**Decision**: In `lib/core/network/auth_interceptor.dart`, `_detailFrom` and `_fieldErrorsFrom` first normalize `response.data`. When it is a `List<int>` and the response's `content-type` is JSON, they decode it as UTF-8 and parse the JSON. Their existing `is! Map` / `is! List` guards then run unchanged. A new `test/unit/core/network/auth_interceptor_test.dart` covers:
- a JSON 404 body delivered as bytes
- a JSON 409 body delivered as bytes
- a 422 body delivered as bytes
- a non-JSON byte body, which must still yield `null` and must not throw

**Rationale**:
- `ResponseType.bytes` applies to error responses too. So "Sales order not found", "Cash session not found", "Cash session is not closed" and "Insufficient privileges" all reach `_detailFrom` as a `Uint8List`, and `if (data is! Map) return null;` (`auth_interceptor.dart:76-84`) throws them away.
- The fix belongs in `mapDioException`'s helpers, not in a repository. The interceptor attaches the mapped `AppError` before any repository sees the exception (`auth_interceptor.dart:34-40`). The integration tests run without the interceptor and fall back to the same `mapDioException`. So one change covers both paths, and every future binary endpoint too.
- **409 has no dedicated case.** It maps to `ServerError(statusCode: 409, message: detail)`, which `ErrorBanner` already renders through `serverMessage` (`app_error.dart:46-59`). No new `AppError` subtype is needed.
- **There is no `auth_interceptor` test today**, so this adds the first one.

**Alternatives considered**: Decoding in the document repository's `_toAppError`. Rejected: the interceptor's `AppError` has already lost the detail by then, and the fix wouldn't reach other binary endpoints.

---

## R10. The file name comes from `Content-Disposition`

**Decision**: Read `filename="…"` from the response's `content-disposition` header. When the header is missing or can't be parsed, fall back to `<kind>-<id>.pdf`: `ticket-`, `pedido-`, `corte-`.

**Rationale**: mbe-api sends `inline; filename="ticket-00001234.pdf"` (`pedido-{id:08d}`, `corte-{id:06d}`), which the spec's US2-3 asks for verbatim. The generated method returns the full `Response<Uint8List>`, headers included, so no dio bypass is needed. The fallback is for resilience only; the padding it applies matches mbe-api's so the names don't visibly change.

---

## R11. Where the fetch lives: one shared document source in `core/documents/`

**Decision**: `lib/core/documents/` holds the whole feature's shared part:

| Layer | Contents |
|---|---|
| `domain/` | `DocumentRef`, `RenderedDocument`, and the `DocumentSource` and `DocumentOutput` interfaces |
| `data/` | `DocumentSourceImpl`, which calls the three generated methods through `dioProvider` and `appSerializers` |
| `data/` | `PrintingDocumentOutput`, which wraps `Printing.layoutPdf`, `sharePdf` and `raster` |
| `presentation/` | `showDocumentPreview`, the preview controller and the page viewer, plus a `DocumentActions` facade that call sites use |

**Rationale**:
- Research §8.1 asked for one fetch path and one shared present-a-document surface, following `showRecordSheet`.
- Three features' screens consume it: the POS sale, the orders workspace and cash sessions. That makes it shared infrastructure under `core/`, like `core/network/` (Principle I).
- Hiding the `printing` package behind `DocumentOutput` makes every widget test independent of platform channels and pdf.js (Principle II: services as providers).
- **FR-015** (room for a future server-side print path) is met by call sites depending only on `DocumentActions.preview(ref)` and `DocumentActions.printDirect(ref)`. A later "send to printer" becomes a different `printDirect` behind the same call, not an edit at four call sites. No speculative code is written for it now.
- The document types have no DTO, so there is no generated-to-`freezed` mapping. A PDF is bytes plus a file name (Principle III permits this, research §8.2).

**Alternatives considered**: A `printTicket` method on each feature's repository (`SalesOrderRepository`, `CashSessionRepository`). Rejected: it spreads one concern across two repositories plus a third call path for the pedido, and the preview would still need a common input type.

---

## R12. Access gates (FR-040, FR-041)

**Decision**: Each `DocumentKind` carries its gate:
- `saleTicket` → `SystemObject.salesOrders` + `AccessRight.read`
- `salesOrder` → `SystemObject.salesOrders` + `AccessRight.read`
- `cashCut` → `SystemObject.pos` + `AccessRight.read`

Call sites hide the action with `accessControlProvider.can(kind.gate…)`. `DocumentActions` re-checks immediately before fetching and fails with the permission error without touching the network, the same way `close_session_form_controller.dart:111` re-checks.

**Rationale**: These are exactly what mbe-api enforces (research §0.1 and §7). Putting the gate on the kind means it is written down once, not four times. There is no new `SystemObject`, so the constitution's "update the SystemObject table" workflow step is not triggered.

---

## R13. Letting the order workspace settle before "Ver pedido" (FR-009)

**Decision**: "Ver pedido" follows the pattern the workspace's other critical actions use:
- It is **disabled while** `pendingWritesProvider(saleWritesScopeProvider) > 0` (the reactive gate at `capture_step.dart:240-242`).
- On press, it `await`s `resolveUnconfirmedEdits(context, ref, scope)` and opens the preview only when that returns `true`. "Seguir editando" returns `false`, which cancels (`unconfirmed_edits_resolver.dart:30-56`).
- The scope is the workspace's `'back-office-sale'` (`sales_order_write_scope.dart:10`).

**Rationale**: Nothing in the codebase *awaits* pending writes. The established gate disables the action until they land, which meets "let in-flight edits finish" without a new waiting primitive. Reusing the resolver keeps the keep/discard prompt identical to the one users already see before continuing to delivery.

---

## R14. Refreshing the cash session detail after close (FR-007)

**Decision**: After a successful close, invalidate `cashSessionDetailControllerProvider(sessionId)`, alongside the two providers it already invalidates (`close_session_form_controller.dart:~131-141`).

**Rationale**: The detail controller is an autoDispose family keyed by id. Today nothing invalidates it, so the screen keeps showing the pre-close session. The "Ver corte" action (FR-006) would then never appear after a close. Invalidating it where the other two lists are invalidated keeps the refresh in one place.

---

## R15. Tests

**Decision**:

| Level | What |
|---|---|
| Unit | `auth_interceptor_test.dart` (R9). |
| Unit | `document_source_impl_test.dart`: the real generated client through the stubbed dio adapter already used in `cash_session_repository_impl_test.dart`. It checks the bytes come through intact, the file name is parsed and falls back correctly, and 404/409/403 byte bodies map to their `AppError` with the server's detail. |
| Unit | Preview-controller tests with a fake `DocumentOutput`: loading → pages, errors, retry refetches, zoom step arithmetic, and the page-in-view calculation. |
| Widget | The preview dialog (every state in the wireframes, fullscreen on Compact); the "Venta completada" dialog (busy, error, primary action); the POS list row action gating; the cash detail with "Ver corte" on closed/open and the refresh after close; "Ver pedido" gating plus the resolver path. |
| Integration | One `test/integration/document_printing_flow_test.dart` against live mbe-api (`--dart-define-from-file=.env`). It fetches all three documents, asserts `%PDF-` and byte-equality against a direct dio fetch (SC-003), and asserts that an open session's cut surfaces "Cash session is not closed" (SC-005). |

**Rationale**: This follows the constitution's quality gates and the existing layout under `test/unit/features/sales/` and `test/widget/features/sales/`. No goldens: the pages are the server's pixels, and the frame is covered by widget tests.

**Manual checks** (in [quickstart.md](./quickstart.md)): printing to a real thermal printer (SC-006), a DevTools network capture showing no third-party host (SC-004), and a phone-browser pass.
