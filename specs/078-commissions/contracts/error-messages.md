# Contract: Error Messages (§III coverage)

These are the codes the commissions routes can return, measured from mbe-api's
`app/services/commission_service.py` and `app/api/v1/endpoints/commissions.py` (research R13).

## New (add to `localizedErrorCodes`, the `localizeProblem` switch, `app_es.arb`, `app_en.arb`, `problem_fixtures.dart`; flip `code-scope.tsv` to `IN`)

`{period}` is `formatters.monthYear(year, month)`, lowercase as Spanish writes it ("octubre de 2026"). No Spanish message starts with `{period}`, so it never needs capitalizing.

| Code | Status | Params | Routes | es |
|---|---|---|---|---|
| `commission_period.not_ended` | 409 | `year`, `month` | close | Todavía no termina {period}; no se puede cerrar. |
| `commission_period.previous_not_closed` | 409 | `year`, `month` | close | Para cerrar {period} primero hay que cerrar el mes anterior. |
| `commission_period.later_closed` | 409 | `year`, `month` | close, reopen | Ya hay un mes posterior a {period} cerrado. |
| `commission_period.already_closed` | 409 | `year`, `month` | close | El mes de {period} ya está cerrado. |
| `commission_period.already_paid` | 409 | `year`, `month` | close, pay | El mes de {period} ya está pagado. |
| `commission_period.not_closed` | 409 | `year`, `month` | reopen, pay | El mes de {period} no está cerrado. |
| `commission_period.paid_cannot_reopen` | 409 | `year`, `month` | reopen | El mes de {period} ya está pagado y no se puede reabrir. |
| `commission_agent.salesperson_not_agent` | 422 | `salesperson_id` | agent-rates create | El empleado #{salesperson_id} no es agente de comisiones. |

- All 8 join `needParams` in `catalog_coverage_test.dart`. A missing or mistyped `year` or `month` falls back to the generic message (§III resilience).
- `catalog_coverage_test.dart`: `expect(checked, 206)` → `214`.

## New resource nouns (`resourceNoun`, `resourceGender`, arb `apiResource…`)

These let the reused `resource.*` messages name the thing:

| Resource | es (singular / plural) | Gender |
|---|---|---|
| `commission` | etiqueta de comisión / etiquetas de comisión | f |
| `commission_agent` | agente / agentes | m |
| `commission_participation` | tipo de participación / tipos de participación | m |
| `commission_salesperson` | tasa de agente / tasas de agente | f |
| `commission_product` | etiqueta de producto / etiquetas de producto | f |
| `commission_period` | periodo de comisiones / periodos de comisiones | m |
| `commission_period_line` | línea de comisión / líneas de comisión | f |

`commission_history` is not added: no commissions route returns it. It appears only when deleting employees or products, which is covered by the generic fallback.

## Already localized, reused

| Code | Where |
|---|---|
| `resource.not_found` | unknown label, participation, agent, employee, rate, product, product label |
| `resource.already_exists` | `commission_agent` (employee already an agent), `commission_salesperson` (duplicate rate triple) |
| `resource.still_referenced` | delete label (products or rates), participation (rates), agent (rates or stored lines), product label |
| `auth.forbidden` | missing right on 112 |
| `request.*` / validation types | body and path validation (out-of-range rate, month outside 1–12) |

## Screen-side handling

- A refused close, reopen or pay: `ErrorBanner` above the action row, then the month and the list re-read (FR-010).
- A refused rate cell: `InlineErrorText` under the cell, and the cell reverts to its previous value (`ConfirmableTextField` discard).
- A refused settings form: `FormErrorBanner` in the panel.
