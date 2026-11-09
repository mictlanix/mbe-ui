# Contract: Error body → ApiProblem → AppError

The server side is mbe-api spec 036, `contracts/api.md`. This document is the client's reading of it, all in `mapDioException` (`lib/core/network/auth_interceptor.dart`). Every repository's `_toAppError` already delegates there, so no repository changes for the generic path.

## 1. Reading the body

1. The body is taken as today: JSON, or bytes re-read as JSON when the content type contains `json`. `application/problem+json` contains `json`, so print and export requests (`ResponseType.bytes`) are covered.
2. If the body is a `Map` and `body['code']` is a `String`, an `ApiProblem` is built:
   - `codeName = body['code']`;
   - `code` comes from deserializing `codeName` with `ErrorCode.serializer` through `appSerializers`. Any exception (an unknown wire name) gives `code = null` (R2);
   - `params = body['params']` if it is a `Map`, else empty;
   - each entry of `body['errors']` that is a `Map` becomes an `ApiProblemPart`. Its `code` is read the same way, its `params` from `entry['params']`, and its `extra` from the remaining keys;
   - `detail` uses today's `_detailFrom` rule: a string `detail`, or `detail.message`.
3. Otherwise there is no problem, and everything below behaves exactly as today (FR-001).
4. A request-validation 422 (`detail` is a list) never has a top-level `code`. Its `FieldError`s gain `ctx` (data-model).

## 2. Choosing the variant

| Condition (first match wins) | Variant | Change from today |
|---|---|---|
| no response | `network(message)` | none |
| `problem?.code` ∈ the customer credit codes (credit hold, limit exceeded, limit reached, no credit limit, walk-in no credit) | `creditHold(detail, problem)` | new: by code, on any route |
| status 401 | `auth(detail, problem)` | + problem |
| status 404 | `notFound(detail, problem)` | + problem |
| status 422 | `validation(fieldErrors, detail, problem)` | + problem |
| otherwise | `server(statusCode, detail, problem)` | + problem |

`_toSalesOrderError`'s check, a 422 with a string detail, still maps to `creditHold`. It does so only when the error is not already a `creditHold` and `problem == null`, so it stays as the fallback for a server that sends no code (FR-017).

## 3. Interceptor side effects

| Path | Rule | Fallback kept |
|---|---|---|
| Password change pending | `problem?.code == auth.passwordChangeRequired` → `onPasswordChangeRequired` | status 403 and `message == 'password_change_required'` (FR-016) |
| Session invalid | `AuthError` → `onUnauthorized` | unchanged |

## 4. Logging (FR-020)

When `mapDioException` builds a problem, it writes one line through `debugPrint`, in this form:

`api-error <status> <codeName> params=<json> detail=<detail>`

- Mapping happens once per failed request, so the line is never repeated on rebuild.
- Never logged: the request body, headers, or the `input` of validation entries.

## 5. Structured refusals (`_toConfirmError`, FR-019)

`POST /sales-orders/{id}/confirm` refusals, in order:

| Shape | Recognized by | Result |
|---|---|---|
| Today: `detail = {message, lines: [str]}` (zero-priced lines, insufficient stock) or `{message, missing: [str]}` (missing delivery details) | `detail` is a `Map` with a string `message` | `ApiProblem.detailItems` = the `lines` or `missing` strings. The fallback `message` stays `[message, ...items].join('\n')`, as today; today's handling drops `missing`, and this fixes that. |
| Phase 3: `detail` is a string and `errors = [{code, params}, …]` | `problem.parts` is not empty | Parts as in §1; `detailItems` is empty. |
| A credit refusal on confirm | `creditHold` from §2 | unchanged path |
| Anything else | — | the generic path (§2) |

**Rendering**, for `sales_order.zero_priced_lines`, `sales_order.insufficient_stock` and `sales_order.missing_delivery_details`:
- the localized headline comes first, then one line per item, so both shapes give the same lines in the same order;
- an item from `detailItems` is the server's English prose and is shown as-is, because today's shape has no per-line code;
- an item from `parts` with a known code is localized;
- an item from `parts` with an unknown code shows its `params.product_code` when present, and is otherwise left out (R9).

If the headline code is unknown, the whole refusal falls back to today's joined English `message`.

## 6. Open-session 409 (FR-018)

| Condition | Form error | Fallback kept |
|---|---|---|
| `problem?.code == cash_session.drawerBusy` | `drawerBusy` | |
| `problem?.code == cash_session.userBusy` | `cashierBusy`. The other session id comes from `params.cash_session_id`, so no second request is made. | |
| 409 without a problem | | today's re-fetch to tell the two apart |

## 7. Refund open (`refund_open_or_resume.dart`)

| Condition | Result |
|---|---|
| `problem?.code` is `refund.nothingRefundable` or `refund.noReturnableLines` | `RefundRefusal.nothingToReturn`. The snackbar shows the localized refusal only, with no English appended. |
| a 409 without a problem | today's behaviour: the generic refusal, with `serverDetail` appended as today |
| `refund.orderNotPaid` / `refund.orderNotCompleted` | the existing `notPaid` / `notCompleted` refusals. They are already caught client-side before the call; this covers a race. |
