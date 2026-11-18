# Quickstart: CFDI Stamping, Refresh and Cancellation

How to prove the feature works. Contracts are in [contracts/ui-contracts.md](./contracts/ui-contracts.md),
entities in [data-model.md](./data-model.md), and decisions in [research.md](./research.md).

## Prerequisites

- **Backend**: mbe-api `main` ≥ 1c81e07 on xolotl dev (`:8765`), with `PAC_PROVIDER=simulated`
  (mbe-ui#274 says it's enabled on dev and test).
- **Accounts**:
  - an `admin` account from `.env`, with Update on 23;
  - `qareadonly`, for the read-only checks (seeded by `tool/seed_test_accounts.py`).
- **Data**: an issuer with an active certificate (spec 065 seed) and a customer with a
  taxpayer record and a completed sales order. Spec 066's live test creates such drafts.
- **Simulator controls**: only through the API, with a token for the same user:
  - `PUT /api/v1/pac-simulator/fiscal-documents/{id}` sets the next outcome;
  - `POST …/{id}/receiver` gives the receiver's answer.

  The scenario table is in mbe-ui#274 §5.

## Automated checks

```sh
flutter analyze
flutter test test/unit/features/invoicing test/widget/features/invoicing test/unit/core/errors
flutter test   # the whole suite stays green
```

Format only the changed files (`dart format <files>`), never the whole repo.

**Live** (dev tenant only). It consumes folios and stamps documents, so ask before
running:

```sh
MBE_WRITE=true flutter test test/integration/fiscal_documents_live_test.dart
```

It must pass:
- seal → stamp → issued, `stamp.simulated == true`;
- stamp with `timeout_stamped` → stamping → refresh → issued;
- cancel 02 accepted → cancelled;
- cancel `pending` → receiver `reject` → refresh → issued, with a `rejected` history row;
- cancel 01 with a substitute → cancelled, `cancellation_substitution` set.

## Manual walk (app against dev)

| # | Do | Expect |
|---|---|---|
| 1 | Facturas → Filtros → Estado | Six states listed (C15) |
| 2 | Seal a draft invoice | Sellado banner without the "not available" text. Timbrar and Reabrir (C16, C18) |
| 3 | Timbrar → confirm | Emitido; UUID, Timbrado, Certificado SAT, PAC `SIM010101SIM`; simulated badge; PDF/XML; no Reabrir (C17) |
| 4 | Simulator `stamp:"rejected"` on another sealed invoice → Timbrar | The PAC's message quoted; still Sellado |
| 5 | Simulator `stamp:"timeout_stamped"` → Timbrar | Timeout message; Timbrando banner; only "Consultar estado" |
| 6 | Consultar estado | Emitido (snackbar) |
| 7 | Simulator `stamp:"timeout_not_stamped"` → Timbrar → Consultar estado at once | "Sigue en proceso" info notice (C23) |
| 8 | Issued invoice → Cancelar ante el SAT → 02 | Cancelado; history row "Aceptada" |
| 9 | Simulator `cancellation:"pending"` → cancel 03 | Cancelación pendiente banner with time; PDF/XML still offered; no Cancel |
| 10 | Simulator receiver `reject` → Consultar estado | Emitido again; history has the "Rechazada" row; Cancel offered |
| 11 | Cancel with 01 | Picker shows issued documents of the same recipient, not the document itself; Enviar disabled until picked |
| 12 | Invoice with a live payment receipt (legacy REP in dev) → cancel | "Primero cancela … P12" (series+folio list) |
| 13 | Log in as `qareadonly`, open documents 3, 5 and 9 | States, stamp facts and history visible; no Timbrar, Cancel or Consultar |
| 14 | Compact width (≈390 pt) and largest text size | The pending chip wraps; the action row wraps; the dialog goes full-screen; nothing clips |
| 15 | Switch the app to English | Every new label, reason and error is translated |
