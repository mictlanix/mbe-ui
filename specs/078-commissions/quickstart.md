# Quickstart: Commissions

**Feature**: [spec.md](spec.md) | **Contracts**: [contracts/](contracts/)

## Prerequisites

- mbe-api running with spec 025 deployed (`/api/v1/commissions/*` in `/openapi.json`).
- `.env` and `.env.settings` with an admin account (`MBE_POS_*`) and a non-admin with Read only on 112 (`tool/seed_test_accounts.py` after a DB reset; add a read-only-on-112 account there if none exists).
- For steps 6–8: **a throwaway database**. Closing starts the month chain, and paying is final, for everyone using that database (research R14).

## Automated

```bash
flutter test test/unit/features/commissions test/widget/features/commissions
flutter test test/unit/core/errors/catalog_coverage_test.dart test/unit/core/formatting
flutter test test/unit/core/navigation test/unit/app/router

# live, read-only
flutter test test/integration/commissions_live_test.dart \
  --dart-define-from-file=.env.settings --dart-define-from-file=.env
# live settings round trips
  … --dart-define=MBE_WRITE=true
# live close/reopen (throwaway DB only)
  … --dart-define=MBE_WRITE=true --dart-define=MBE_COMMISSIONS_PERIODS=true

# device walkthrough (macOS)
caffeinate -dimsu flutter test integration_test/commissions_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings --dart-define-from-file=.env
```

## Manual walkthrough

| # | Do | Expect | Covers |
|---|---|---|---|
| 1 | Sign in as admin, open Finanzas › Comisiones | The months list (or the empty state with "Ver {previous month}") | US3, FR-001/002 |
| 2 | Abrir mes… → previous month | Month screen: Abierto, live banner, grand total, agents table, no lines | US1 sc. 1, FR-003 |
| 3 | Tap an agent row | Strip shows the agent; by-label totals and paged lines; label totals = sum of that agent's lines | US1 sc. 2, SC-002 |
| 4 | Tap a line; tap a refund line | Read-only panel with every value; refund shows ↩ and negative amounts | FR-005/005a |
| 5 | On a "Sin etiqueta" line: Asignar… → a label | The month recomputes; the line now earns at that rate | FR-016a |
| 6 | Close the month (throwaway DB) | Confirmation with lines and total → Cerrado, audit line with your name; the banner is gone | US1 sc. 3 |
| 7 | Reassign a customer in that month and change a label's rate; reopen the month view | Identical figures | US1 sc. 5, SC-003 |
| 8 | Reabrir → close again → Marcar pagado | Abierto (live), then Cerrado, then Pagado with no actions left | US2 |
| 9 | Open the current month | No Cerrar mes, "el mes aún no termina" | US1 sc. 4 |
| 10 | Configuración › Etiquetas: create 3%, edit to 3.5%, try 120%, delete | Saved; 120% refused before sending; deleted | US4 sc. 1 |
| 11 | Delete a label that products use | "No se puede eliminar…" in Spanish, naming the products | US4 sc. 2, FR-019 |
| 12 | Agentes: add a salesperson under Pagos parciales; switch to Pago total; Ver tasas | Saved, with the scheme note; the grid opens on that agent | US4 sc. 3/4 |
| 13 | Tasas: type 100 in an empty cell, Enter; change to 80; clear it | Created, updated, removed; leaving without Enter discards with acknowledgement | US5 |
| 14 | Productos: filter by a label; pick a product; Asignar etiqueta on an unlabelled product; change; remove | Each reflected in the list | US6 |
| 15 | Sign in as the read-only-on-112 account | Every screen readable; no Create, ✎, Eliminar, Cerrar, Reabrir, Pagar, Asignar; grid as text | FR-020, SC-006 |
| 16 | Sign in as a user without 112 | No Comisiones in the menu; `/commissions` redirects | FR-021 |
| 17 | Largest text size, ≥ 1280 px: months list, month with lines, rate grid | No clipping or horizontal scroll | §V, §VI |
| 18 | Switch to English | All commissions text and refusals in English | §III |
