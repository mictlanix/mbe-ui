# Quickstart: Purchase Requests with Approval (079)

How to prove the feature works end to end. Behaviour is specified in [spec.md](spec.md) and [contracts/ui-contract.md](contracts/ui-contract.md); this is only the run guide.

## Prerequisites

- mbe-api with migration 028 (approver columns), on the dev tenant.
- `.env` with `MBE_POS_*` (the admin account, which holds 86, 96 and 20) and `.env.settings`.
- In the tenant: a purchasable product with a minimum order quantity above 1; a non-transit warehouse in the admin's facility and one in another facility; a non-administrator with read/create/update on 86 in a different facility (the seeded QA accounts, re-seeded with `tool/seed_test_accounts.py` after a DB reset; add 86 rights to one if none has them).

## Automated checks

```bash
# unit + widget (never with the .env defines)
flutter test test/unit/features/purchases test/widget/features/purchases \
  test/unit/core/navigation test/unit/app/router test/unit/core/errors/catalog_coverage_test.dart

# live repository test (writes only with MBE_WRITE=true)
flutter test test/integration/purchase_requests_live_test.dart \
  --dart-define-from-file=.env.settings --dart-define-from-file=.env --dart-define=MBE_WRITE=true

# device walkthrough on macOS (keep the machine awake: caffeinate -dims)
flutter test integration_test/purchase_requests_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings --dart-define-from-file=.env
```

## Walkthrough (also automated by the device test)

1. **Navigation.** As admin, Compras shows Solicitudes de compra and Aprobación de solicitudes between Inventario and Finanzas. As `qanoaccess`, the group is absent and `/purchases/requests` redirects home.
2. **Create.** Nueva solicitud starts at the admin's POS warehouse. Create it: the detail opens as "Solicitud · Borrador #{id}".
3. **Lines.** Add the min-order product: the line has its name, quantity = its minimum, destination = the header's warehouse. Edit it to below the minimum: the warning band names the minimum. The live test reads the line back and checks the quantity string sent (research R6). Try 0 and 1.234: the dialog refuses both. Set the destination to a warehouse of another facility: saved.
4. **Header.** Edit the notes, then clear them: reopen and check the notes are empty (research R8).
5. **Submit.** Submit an empty second draft: `purchase_request.no_lines` in Spanish. Submit the first: it shows a folio and Enviada, with no edit actions.
6. **Approve.** In the queue the request appears, oldest first, with its line count. Open it, Aprobar: it shows Aprobada, Aprobó and the time, and leaves the queue.
7. **Reject and resubmit.** Submit another request, reject it with a reason: it is Borrador with the same folio. Resubmit: Enviada, same folio, back in the queue.
8. **Bulk approve.** Submit three requests. Select them in the queue; in another session cancel one. Aprobar seleccionadas: the result dialog says 2 of 3 and names the cancelled one with "La solicitud ya no está enviada…".
9. **List.** Mis solicitudes shows the admin's requests without cancelled ones. Todas shows everyone's. Filter Cancelada: cancelled ones appear (checks the server honours it in the default scope). Search the folio: matching rows, one per facility.
10. **Marks.** On an approved request, unmark a line and reopen: still unmarked. On a draft, the Comprar checkboxes are read-only.
11. **Cancel.** Cancel a draft and an approved request: both Cancelada, no actions left.
12. **Facility.** As the non-administrator, open a request of the admin's facility: no Editar, Agregar, Enviar or Cancelar. Nueva solicitud offers only their facility's warehouses.
13. **Approval rights.** With a user holding 96 but not 86 read (temporarily grant it): the queue shows, ✓ and bulk work, rows don't open.
14. **Largest text.** At the largest text level the list, detail and queue tables stay readable (§V).

A purchase order holding a request line cannot be created until #71 ships, so the "line on a live order" refusals (`line_on_live_order`, `lines_on_live_order`) are covered by unit tests only, unless legacy data has such a line (the live test looks for one and skips otherwise).
