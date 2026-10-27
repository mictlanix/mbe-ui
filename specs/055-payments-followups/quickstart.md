# Quickstart: Payments Follow-ups

How to check this feature end to end against the dev tenant. Contract details are in [contracts/ui-contracts.md](./contracts/ui-contracts.md).

## Prerequisites

- mbe-api running locally at `main` `b5fb935` or later, with PRs #273, #274 and #275, serving `http://127.0.0.1:8000`.
- Docker running (Colima on macOS), for `tool/generate_api_client.sh` when regenerating the client.
- `.env` with `MBE_ADMIN_*`, `MBE_POS_*` (admin) and `MBE_QA054_*` (non-editor). After a database reset, run `python3 tool/seed_test_accounts.py`.
- The seed fixture:

  ```
  python3 tool/seed_payment_fixtures.py
  ```

  It prints the credit payment and the back-office order it is applied to. Running it again creates nothing.

## Automated

```
flutter analyze
flutter test test/unit/features/sales test/unit/core/documents test/widget/features/sales
caffeinate -dimsu flutter test integration_test/payments_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings \
  --dart-define=MBE_POS_USERNAME=... --dart-define=MBE_POS_PASSWORD=... \
  --dart-define=MBE_QA054_USERNAME=... --dart-define=MBE_QA054_PASSWORD=...
```

The walkthrough must end with `==== RESULTS ====` showing every step `PASS`, with no `SOFT` (SC-006).

## Manual walkthrough

1. **Names (US2):** Open Pagos. Every customer cell shows a name immediately, never "…" (SC-003).
2. **Search (US2):**
   - Type part of a customer's name, in another letter case, and press Enter. Only that customer's payments remain, and the URL has `?search=`.
   - Add a date range in the drawer. Both apply.
   - Switch to "Todas las sucursales" (admin). The box is empty and its hint now says "Buscar referencia…".
3. **Ticket from the payment view (US1):** Open the seeded `QA055-SEED` payment and press "Ver ticket". The preview shows a 72 mm "Pago" ticket. Print and Descargar both work.
4. **Ticket from a row (US1):** Back on the list, the same row has a receipt icon. It opens the same preview. A Contado row has no icon.
5. **Back-office link (US4):** On the seeded payment, the application's order number opens `/sales/orders/<id>`.
6. **Date picker (US4):** Open the date chip, pick a range in the dialog and save. The list narrows. Clearing the chip ("Cualquier fecha") restores it.
7. **Facility checks (US3):** Sign in as QA054 and open `/sales/payments/<another facility's payment>`. The screen shows "El pago N no existe." and no Retry.

## Not covered here

- Printing on the physical thermal printer and on phone browsers (mbe-ui#185).
- Printing right after recording a credit payment or advance (no recording flow yet).
- "Sin aplicar" vs the ticket's balance when change was handed back (mbe-api#276).
