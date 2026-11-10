# Quickstart: validating localized API messages

## 1. Automated checks

```bash
flutter analyze lib test
flutter test test/unit/core/errors/                 # ApiProblem parsing, localizeProblem (every in-scope code, en + es), coverage
flutter test test/unit/core/network/auth_interceptor_test.dart
flutter test test/widget/core/widgets/              # ErrorBanner, FormErrorBanner
flutter test test/unit/core/l10n_parity_test.dart
flutter test                                        # the whole suite: SC-006
```

The suite must show four things:
- **Coverage (SC-001)**: every member of `localizedErrorCodes` renders in both locales, and the set equals [contracts/message-catalog.md](contracts/message-catalog.md).
- **Fallbacks (SC-003)** each show today's output:
  - an unknown code string, such as `"future.code"`;
  - a body with no code;
  - a known code with a missing param;
  - a known code with a mistyped param, such as `overdue_count: "four"`.
- **Shapes (FR-019)**: the confirm refusal as today's dict and as `errors[]` gives the same line count and order.
- **Special paths (Story 3)**: each one triggers both from the code alone and from the old signal alone.

**SC-004, no direct server text**: this search must print only the fallback inside `userMessage` and the definition in `app_error.dart`:

```bash
grep -rn "serverMessage\|errorDetail" lib --include='*.dart' | grep -v "\.freezed\.dart\|\.g\.dart\|lib/generated"
```

## 2. Live checks against mbe_dev (SC-005)

**Prerequisites**:
- the dev API reachable, through the usual SSH tunnel;
- `.env` with the dev base URL;
- the app run on macOS or web with the locale set to Español (Settings → Idioma).

| # | Do | Expect |
|---|---|---|
| 1 | In Pedidos, set credit terms on an order for a customer with overdue credit orders, then save. | The banner reads "Este cliente tiene N pedido(s) a crédito vencido(s)…" with the right count, and shows no English. Switch to English and the same banner re-renders in English. |
| 2 | Sign in as a user flagged to change their password. | You land on the change-password screen, as before. |
| 3 | In the POS, add a product with no price and try to confirm. | The headline "Algunas partidas no tienen precio:" appears, followed by the affected lines. |
| 4 | Open a cash session on a drawer another cashier holds. | "Esa caja ya tiene una sesión abierta." appears, and the network log shows no follow-up session request. |
| 5 | On any catalog form, create a record with a duplicate unique value, such as a warehouse code. | The form headline plus "Ya existe un almacén con ese valor." |
| 6 | Delete a customer who has orders. | "Este registro todavía está en uso por N pedidos… y no se puede eliminar." |
| 7 | Read the app log after checks 1–6. | Each refusal logged once: `api-error <status> <code> params=… detail=…`. |

Find fixtures at runtime rather than hard-coding ids. For example, search for a customer whose credit order is overdue. For a password-change account, use one seeded by `tool/seed_test_accounts.py`, or set the flag on a throwaway user.

## 3. Unknown code from a newer server

There is no live way to get one. The widget test feeds `{"status": 409, "code": "future.code", "detail": "Some English"}` and checks the banner shows the generic headline plus "Some English", and that nothing throws.
