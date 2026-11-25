# Contract: `CommissionRepository` ↔ mbe-api

`lib/features/commissions/domain/repositories/commission_repository.dart` (interface)
and `data/commission_repository_impl.dart` (`commissionRepositoryProvider`,
`api.CommissionsApi(dio, appSerializers)`, DTO→entity mapping, `DioException` → `AppError`
via the interceptor's error or `mapDioException`, the inventory-transfer pattern).

Every route is `/api/v1/commissions/...` and needs SystemObject 112. Every method throws
`AppError`. Error codes per method are in [error-messages.md](error-messages.md).

## Periods

| Method | Route | Returns |
|---|---|---|
| `listPeriods()` | `GET /periods` | `List<CommissionPeriodSummary>`, newest first |
| `getPeriod(CommissionMonth, {int? agentId})` | `GET /periods/{y}/{m}?salesperson=` | `CommissionPeriod` |
| `closePeriod(CommissionMonth)` | `POST /periods/{y}/{m}/close` | `CommissionPeriodSummary` |
| `reopenPeriod(CommissionMonth)` | `POST /periods/{y}/{m}/reopen` | `CommissionPeriodSummary` |
| `payPeriod(CommissionMonth)` | `POST /periods/{y}/{m}/pay` | `CommissionPeriodSummary` |

The three actions return the period's new state. The caller then re-reads the detail and
the months list (FR-010), because a close changes what the detail serves (stored instead of
live).

## Settings

| Method | Route |
|---|---|
| `listLabels()` / `createLabel(name, rate, comment)` / `updateLabel(id, …)` / `deleteLabel(id)` | `/labels`, `/labels/{id}` |
| `listParticipations()` / `createParticipation(name)` / `updateParticipation(id, name)` / `deleteParticipation(id)` | `/participations`, `/participations/{id}` |
| `listAgents()` / `createAgent(employeeId, scheme)` / `updateAgent(employeeId, scheme)` / `deleteAgent(employeeId)` | `/agents`, `/agents/{employee}` |
| `listAgentRates({int? agentId, int? labelId})` / `createAgentRate(agentId, labelId, participationId, share)` / `updateAgentRate(id, share)` / `deleteAgentRate(id)` | `/agent-rates`, `/agent-rates/{id}` |
| `listProductLabels({int? labelId, int? productId, int skip, int limit})` → `CommissionProductLabelPage` | `GET /product-labels` |
| `setProductLabel(productId, labelId)` / `removeProductLabel(productId)` | `PUT` / `DELETE /product-labels/{product}` |

Rates and shares cross the boundary as `Decimal` fractions and are serialized as the
generated model's string or number type, never a `double` (FR-017).

## Controllers (riverpod_generator)

| Provider | Kind | Reads | Invalidated by |
|---|---|---|---|
| `commissionPeriodsController` | `AsyncNotifier<List<CommissionPeriodSummary>>`, plus a client-side status filter and page | `listPeriods` | close / reopen / pay |
| `commissionPeriodController(month, agentId)` | family `AsyncNotifier<CommissionPeriod>` | `getPeriod` | close / reopen / pay, `setProductLabel` from a line |
| `commissionPeriodActions` | keepAlive notifier → `AppError?` | close, reopen, pay | — |
| `commissionAgentsProvider` | `FutureProvider<List<CommissionAgent>>` | `listAgents` | agent create / update / delete |
| `commissionLabelsProvider`, `commissionParticipationsProvider` | `FutureProvider` | lists | their own writes |
| `agentRatesController(agentId)` | family `AsyncNotifier<AgentRateGrid>` | labels, participations, `listAgentRates(agentId:)` | cell writes (patched in place, no refetch) |
| `productLabelsController` | `AsyncNotifier` with filter (label, product) + page | `listProductLabels` | set / remove |
| settings form controllers | per panel (label, participation, agent), the `label_form_controller` pattern | — | — |
