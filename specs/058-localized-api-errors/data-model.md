# Data Model: Localized API Messages from Error Codes

All entities are client-side and immutable. Nothing is persisted.

## ApiProblem (new, `lib/core/errors/api_problem.dart`)

The server's coded explanation, read from an error body (mbe-api spec 036 `Problem`).

| Field | Type | From the body | Notes |
|---|---|---|---|
| `codeName` | `String` | `code` | Always kept as sent, including codes the client doesn't know. Used for logs and fallback decisions. |
| `code` | `ErrorCode?` | `code` | The generated enum value, or `null` when `codeName` is not in the client's `ErrorCode` (a newer server). Never throws (R2). |
| `params` | `Map<String, Object?>` | `params` | Raw JSON values (`int`, `String`, `List`, `Map`, `bool`, `null`). Empty when absent. |
| `parts` | `List<ApiProblemPart>` | `errors` | Empty when absent. |
| `detail` | `String?` | `detail` | The English text: a string, or `detail.message` when the detail is one of the dicts that stays until phase 3. |
| `detailItems` | `List<String>` | `detail.lines` / `detail.missing` | The per-line English prose of today's dict refusals. Empty otherwise, and empty after phase 3, when parts take over. |

The class has typed accessors, each returning `null` on a missing key or wrong type, never throwing:
- `int? intParam(String key)` accepts an int, or a string that parses as an int;
- `String? stringParam(String key)`;
- `String? decimalParam(String key)` accepts a decimal string, or a number, which it renders back as a string;
- `DateTime? dateParam(String key)` parses an ISO date or datetime as a wall-clock value, like `appSerializers`' LocalDateTime;
- `List<Map<String, Object?>>? mapListParam(String key)`;
- `List<Object?>? listParam(String key)`.

**Built only when** the body is a JSON object with a string `code`. Any other body has no `ApiProblem`, and the error maps as today (FR-001).

## ApiProblemPart (new)

One item of `errors[]`.

| Field | Type | Notes |
|---|---|---|
| `codeName` | `String` | Same rules as `ApiProblem.codeName`. |
| `code` | `ErrorCode?` | Same rules as `ApiProblem.code`. |
| `params` | `Map<String, Object?>` | Same typed accessors as `ApiProblem`. |
| `extra` | `Map<String, Object?>` | The item's other keys, kept as sent. For example, the inventory count batch keeps `index`, `product_code` and `reason`. |

## AppError (changed, `lib/core/errors/app_error.dart`)

Each variant that comes from a server response gains an optional problem:

```text
validation(List<FieldError> errors, [String? message, ApiProblem? problem])
auth([String? message, ApiProblem? problem])
notFound([String? message, ApiProblem? problem])
server({int? statusCode, String? message, ApiProblem? problem})
creditHold([String? message, ApiProblem? problem])
network([String? message])            // unchanged: no response, no problem
```

- `message` keeps its meaning: the server's English text, used for the fallback and the log (FR-003).
- Existing constructors and pattern matches compile unchanged, because the new parameter is optional and last.

**Variant selection** (contracts/error-mapping.md §2) keeps today's status rules. The one change is that these codes select `creditHold` whatever the status: `customer.credit_hold`, `customer.credit_limit_exceeded`, `customer.credit_limit_reached`, `customer.no_credit_limit` and `customer.walk_in_no_credit` (R8).

## FieldError (changed)

| Field | Type | Notes |
|---|---|---|
| `loc`, `msg`, `type`, `failedRules` | unchanged | |
| `ctx` | `Map<String, Object?>` | New. The raw `ctx` of a 422 validation entry, or empty. `input` is still never read. |

## Form state (changed, per controller)

In each form or dialog controller state that has it:

| Before | After |
|---|---|
| `String? error` (client-side headline code) | unchanged |
| `String? errorDetail` (English text captured at catch time) | `AppError? errorCause`, the caught error itself, rendered at display time (FR-013) |

Every `errorDetail: e.serverMessage` becomes `errorCause: e`, and every `errorDetail: null` becomes `errorCause: null`. A controller that sets `errorDetail` from something other than a server error is listed in contracts/display.md §4 and keeps a client-side cause.

## Localized message (derived, never stored)

`String? localizeProblem(ApiProblem, AppLocalizations, AppFormatters)` gives the text for a code, or `null` when it has none.

It returns `null` when:
- `code` is `null`;
- the code is not in the in-scope switch;
- a param the template needs fails its typed accessor.

`AppError.userMessage(l10n, fmt)` is that text when there is one, otherwise the error's `serverMessage`. It is the only path from an error to text shown on screen (FR-014).

## In-scope code set (new constant)

`const Set<ErrorCode> localizedErrorCodes` lists every code the switch renders, the same set as contracts/message-catalog.md. The coverage test (SC-001) checks two things:
- every member renders in `en` and `es` with sample params;
- the set equals the catalog list.

A later spec that adds an area extends the set, the switch and the ARB files together.
