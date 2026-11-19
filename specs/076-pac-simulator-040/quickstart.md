# Quickstart: validate spec 076

## Prerequisites

- mbe-api on `main` at 1713acd or later (mbe-api spec 040) is running locally on port 8000 for codegen. Dev runs it with `PAC_PROVIDER=simulated`.
- Credentials for the live tests: `MBE_POS_*` in `.env`, the admin account (see the memory note on POS integration-test invocation).
- Live writes stamp real documents on dev and spend folios. Ask the user before running with `MBE_WRITE=true`.

## 1. Contract

```sh
tool/generate_api_client.sh
grep -rn "next_stamp\|next_cancellation\|nextStamp\|nextCancellation" lib test integration_test
```

Expected: the grep finds nothing (SC-002), and the client diff is limited to the simulator response plus any unrelated upstream changes, each listed in the PR.

## 2. Offline suite

```sh
flutter analyze
flutter test test/unit/features/invoicing test/widget/features/invoicing
flutter test
```

Expected: everything passes (SC-005). In particular:
- refreshing a `cancellationPending` document shows the 72-hour notice in es and en (C1, SC-004);
- refreshing a `stamping` one still shows "unos minutos" (C1);
- an issued document with a `failed` request offers "Cancelar" (C2);
- both RFCs show the simulated badge (C3).

## 3. Live, simulator on (dev)

```sh
flutter test test/integration/fiscal_documents_live_test.dart \
  --dart-define-from-file=.env --dart-define=MBE_WRITE=true
```

Expected: the 072, 073 and 074 groups pass with no fewer steps than before (SC-001), and every simulated stamp carries `SIM010101SI0` (C5).

## 4. Live, simulator off

Point the run at a server whose `PAC_PROVIDER` is not `simulated`, for example a local mbe-api started with `PAC_PROVIDER=none`.

Expected: the three simulated groups report **skipped** with the "simulator is off" reason, none fail, and no document is sealed (C4, SC-003).

## 5. By hand (optional)

On dev, open an invoice stamped before 2026-11-19. It shows the badge and `SIM010101SIM`. Open one stamped today: badge and `SIM010101SI0`. Cancel a fresh one with outcome `pending` and tap "Consultar estado". The 72-hour notice shows.
