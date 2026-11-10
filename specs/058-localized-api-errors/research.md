# Research: Localized API Messages from Error Codes

Inputs:
- spec.md;
- mbe-api spec 036: `contracts/api.md`, `contracts/error-codes.md` and `raise-map.md` at mbe-api `227c334`;
- the hand-over issue mictlanix/mbe-ui#232;
- the design doc [mbe-ui: Localized API messages](https://claude.ai/artifact/7zNdHW5xENQGZCBCP2fJnr) (2026-10-21);
- the code as of `efcec8f`.

## R1. Which codes are in scope

**Decision**: localize every code that an endpoint the app calls today can return, plus the generic codes. The method:
1. List every API method the app calls, through the generated client or raw `dio`.
2. Find each method's endpoint in mbe-api and the services it reaches.
3. Mark every code raised there as IN.

Over-inclusion is accepted; a missed code only falls back. The list, with params and es/en text, is [contracts/message-catalog.md](contracts/message-catalog.md).

**Result**, measured 2026-11-09 against mbe-api `227c334`, by loading its FastAPI route table and following a function-level call graph from each route:

| | In scope | Out of scope |
|---|---|---|
| Routes the app calls | 182: 178 generated client, 4 raw `dio` (facility logo removal, product image upload and removal, CSD upload) | — |
| Error codes | 96 (16 generic, 80 area) | 155 |
| Validation types | 9 | 13 |
| Record nouns | 49 | the rest map to the generic noun |

Findings that change the earlier guesses:
- **`delivery_order` is partly in.** The POS delivery step creates, edits and cancels delivery orders and their lines, so 10 delivery codes are reachable. Approve and transition codes are not.
- **`csd.*`, `taxpayer_certificate.*` and `taxpayer_issuer.unknown` are in**, because of the CSD upload and taxpayer issuer screens.
- **`payment` is mostly out.** The app creates payments but never applies, verifies or reverses them, so only `payment.no_ticket` is reachable.
- **`refund.quantity_exceeds_refundable` and `refund.warehouse_other_facility` are out.** They sit in functions the app's refund routes don't reach. If live testing shows either, add it.

**Accepted limits**:
- The graph doesn't follow calls through non-`self` objects or dynamic dispatch. A looser match added a single false positive and found no misses.
- It ignores runtime branches, so some IN codes may never fire from the app, for example `facility.required` via refunds. Their cost is a message that is never shown.

**Rationale**: this is spec FR-009 and FR-010. A code no screen can trigger cannot be checked in context. The spec that builds that area's screens adds it.

**Alternatives considered**:
- All 251 codes: about 150 messages that can't be checked in context, so rejected in the clarification.
- Choosing by domain name: it misses cross-cutting raises. For example, `lock.busy` and `facility.other_facility` come from sales routes.

## R2. Reading the code without trusting the generated deserializer

**Decision**:
- Read `code` as a string from the raw body.
- Map it to `ErrorCode` with `appSerializers.deserializeWith(ErrorCode.serializer, codeName)`, inside `try`.
- Any exception gives `code = null`, with `codeName` kept.
- Read `params` and `errors` as plain JSON maps.

**Rationale**:
- The generated `ErrorCode` is a built_value `EnumClass`. Its deserializer resolves wire names through `valueOf`, which throws `ArgumentError` on an unknown name. A newer server, which adds codes but never renames them, would therefore make every one of its new errors throw inside the interceptor. That breaks FR-002.
- The generated `Problem.params` is `BuiltMap<String, JsonObject?>`, which is awkward for typed reads.
- `_detailFrom` and `_fieldErrorsFrom` already read the raw body, so this follows the existing pattern.

The generated enum is still the vocabulary the localizer switches over. A code removed from a regenerated client stops compiling where it is mapped, which is the "removed code fails the build" behaviour the spec wants.

**Alternatives considered**:
- String literals in the switch (`'customer.credit_hold'`): no compile-time check, and typos are silent.
- The generated `Problem` deserializer in a `try`: one unknown code would lose the params and parts too.

**Note**: the generated Dart names insert `Period` for the dot, as in `customerPeriodCreditHold`. That is noisy but harmless, and code reads by wire name in comments and ARB descriptions.

## R3. Where the problem lives on `AppError`

**Decision**: add an optional, last `ApiProblem? problem` to `validation`, `auth`, `notFound`, `server` and `creditHold`. `network` is unchanged.

**Rationale**:
- Every server-sourced variant can carry a code. Many business refusals are 422s, which map to `validation` today, for example `refund.warehouse_other_facility`.
- An optional last parameter keeps every existing constructor call and pattern match compiling. There are 154 files using `AppError`.

**Alternatives considered**:
- A new `AppError.problem` variant: it would change which variant many responses map to, and break exhaustive switches across the app.
- Moving variant selection to codes entirely: a larger behavioural change than the spec asks for. Statuses still select variants, except for credit (R8).

## R4. One localizer, returning null

**Decision**: `localizeProblem(ApiProblem, AppLocalizations, AppFormatters)` is a single `switch (p.code)` over the in-scope codes. Any other value returns `null`. Each case reads params through typed accessors, and if an accessor returns `null` the case returns `null` (FR-004). It lives in one file, `lib/core/errors/localize_problem.dart`, next to `resourceNoun` and `localizeFieldError`.

**Rationale**:
- This follows the password-rule precedent (`rulesFromFieldError` + `localizePasswordRule`): known values map to ARB keys, and unknown ones are ignored.
- One file is easy to grep and to extend: a later area spec adds cases, ARB keys and set members together.

**Param formatting** (FR-006):
| Param kind | Rendering |
|---|---|
| money decimals (`outstanding`, `limit`, `balance`, `amount`, `unapplied`, …) | `fmt.display.currency` |
| quantity decimals (`requested`, `refundable`, `available`, `remaining`) | `fmt.display.quantity` |
| ISO dates | parsed wall-clock, then `fmt.display.date` |
| counts (`overdue_count`, `count`, `more`, `max`) | ICU `plural` in the ARB, the int passed as is |

Which kind each param is comes from its code, and the catalog records it per param.

**`auth.forbidden`**: the `required` grants are not listed. The app has no localized privilege names (`SystemObject` has none in the ARB), and the user can't act on raw grant numbers. The message is a generic, localized "You don't have permission for this action."

**`resource`**: `resourceNoun` maps the public resource names reachable in scope (R1) to `apiResource*` nouns. Any other name maps to a generic noun, "registro" / "record" (spec edge case). `still_referenced` names up to five blocking kinds with counts, plus "and N more".

## R5. `ErrorBanner` reads the formatters

**Decision**: `ErrorBanner` becomes a `ConsumerWidget` and reads `formattersProvider` once per build. Tests that pump it without a `ProviderScope` gain one; the existing `ErrorBanner` unit tests pump bare `MaterialApp`s. The default `formattersProvider` builds from `AppSettings.fromEnvironment()` and the resolved locale, with no overrides needed.

**Rationale**: money and date params need the spec 028 formatters, and they live in Riverpod (§II).

**Alternatives considered**:
- Passing `fmt` into `ErrorBanner` from every call site: 62 call-site edits for nothing.
- Building `AppFormatters` from the `Localizations` locale alone: it would ignore the user's formatting settings, contrary to spec 028.

## R6. Forms keep the error, not its text

**Decision**: replace `String? errorDetail` with `AppError? errorCause` in every form or dialog controller state, and render through the new `FormErrorBanner(headline, cause)`.

**Measured**:
- 442 `errorDetail` references across 55 files: 24 controllers, 29 display files, plus the inline-create and dialog controllers;
- 13 test files with 23 references.

One controller sets it from a validation entry rather than `serverMessage` (`users_controller.dart:416`).

**Rationale**:
- Story 2 asks for text that follows a language change, so text must be built at render time (FR-013).
- The 25 screens hand-build a fake `AppError.validation` from two strings. One shared widget is the §III "shared error display" and deletes the copies.
- The form keeps its own headline, because it says what failed (save, delete, load). The localized reason replaces only the English line, which said why.

**Alternatives considered**:
- Keeping `errorDetail` and localizing at catch time: text is frozen in the catch-time locale (Story 2, scenario 2 fails), and controllers would need `l10n`.
- Dropping the form headline when a reason is localized: the user loses which action failed. Rejected.

## R7. Validation types

**Decision**: `FieldError` is unchanged. `localizeValidationType(type, l10n)` switches on `type` for the in-scope validation types (R1), with messages that carry no `ctx` values: the field already shows the value, and dropping them keeps forms from storing anything but a string. `password_policy` keeps `localizePasswordRule`. An unknown `type` returns `null`, and the display shows `msg` as today.

**Rationale**: spec FR-011. `ErrorBanner` shows `FieldError.msg` today, which is English server text.

**Where the nine types can arrive** (from code-scope.tsv): product form (`product_barcode_invalid`, `product_code_has_whitespace`), the user and user-profile admin forms, the inline contact form, the supplier agreement dialog, and the quote email dialog. No pricing endpoint returns one, so the pricing field messages stay as they are (standard validator text, with no custom type).

**How forms localize them without storing text**: the 28 form controllers keep a `Map<String, String>` of server field messages in state, and each screen's `_localizeFieldError(l10n, code)` already turns stored codes into text. For the places above, the controller stores the entry's `type` when it is a known validation type, else its `msg`. The screen's default branch calls `localizeValidationType`, which returns the message for a known type and the stored string otherwise. Type names don't collide with client-side codes (`driverRequired`, …), so no marker is needed.

## R8. Special paths by code

| Path | Code(s) | Where | Fallback kept |
|---|---|---|---|
| Password change pending | `auth.password_change_required` | `AuthInterceptor.onError` | the 403 + exact `detail` match |
| Credit refusal | `customer.credit_hold`, `.credit_limit_exceeded`, `.credit_limit_reached`, `.no_credit_limit`, `.walk_in_no_credit` | `mapDioException`, selecting `creditHold` | `_toSalesOrderError`'s check, a 422 with a string detail, when there is no problem |
| Busy drawer / busy cashier | `cash_session.drawer_busy` / `.user_busy` (`cash_session_id`) | `open_session_form_controller.dart:174` | re-fetching the session when there is no code |
| Nothing to refund | `refund.nothing_refundable`, `refund.no_returnable_lines` | `refund_open_or_resume.dart:73` | any 409, as today |

`AppError.creditHold` already covers "arrears, no credit limit, or over the limit" (its doc comment, spec 039 R8). The five codes are exactly those refusals, and only sales and quote routes raise them, so mapping them globally does not mis-categorize anything. FR-017 asks for create, update, confirm and convert; global mapping covers those and any future credit route.

## R9. Structured refusals and phase 3

**Decision**: read both shapes (contracts/error-mapping.md §5).
- Today's dict items are English prose, kept in `ApiProblem.detailItems` and shown under the localized headline.
- Phase-3 parts are localized when their code is known.

**The gap**: mbe-api has announced phase 3 but has not defined the per-line codes its `errors[]` items will carry. `ProblemPart` carries only `code` and `params`, with no per-part English, so a part with a code the app doesn't know has no text to fall back to. The app shows the part's `params.product_code` when present.

**External dependency**: ask mbe-api, before phase 3 ships, either to publish the per-line codes and params in `error-codes.md`, so this catalog can add them first, or to give each part a `detail`.

Draft issue, to file with the user's go-ahead (§III):

> **Phase 3: publish per-line part codes before switching the dict details**
>
> mbe-ui 058 reads both the current dict details and the phase-3 `errors[]` shape for zero-priced lines, insufficient stock and missing delivery details. A `ProblemPart` has only `code` and `params`, so a part whose code mbe-ui doesn't know yet has no fallback text.
>
> Please add the part codes and their params to `contracts/error-codes.md` ahead of the phase-3 release, so mbe-ui can ship their messages first. Alternatively, include a per-part `detail`. Either way, please keep `product_code` in each line's params.

**Out of scope**: the over-committed itinerary dict, because the app has no itinerary screens, and the plain-text warning lists.

## R10. Logging

**Decision**:
- When `mapDioException` builds a problem, it writes one `debugPrint` line with the status, code name, params and English detail (FR-020).
- The line is written at mapping time, not render time, so a rebuild never repeats it.
- No request data and no validation `input` is logged.

**Rationale**: the app has no logging package. `debugPrint` is the existing pattern (`app_settings.dart`, `brand_config.dart`, `formatting_settings.dart`). Logging at render time would repeat on every rebuild.

## R11. ARB naming and coverage

**Decision**:
- Keys are:
  - `apiError` + the code in PascalCase, e.g. `customer.credit_hold` → `apiErrorCustomerCreditHold`;
  - `apiValidation` + the type in PascalCase;
  - `apiResource` + the name in PascalCase.
- Each `@key` description starts with the wire code, so grep finds it.
- Formatted values are `String` placeholders, and counts are `int` with ICU `plural`.
- The coverage test checks three things:
  - every member of `localizedErrorCodes` renders a non-null, non-empty message in `en` and `es` from the sample params in the test;
  - the set equals the catalog list (SC-001);
  - a missing or mistyped param gives `null`.

**Rationale**: as in the design doc. Codes can be found by text search, and the parity test keeps en and es in step.

## R12. Design-doc decisions revisited

| Design doc (2026-10-21) | Now | Why |
|---|---|---|
| Open question: literals or an enum | the generated enum, parsed defensively (R2) | the enum shipped in the client |
| `problem` on four variants | on five, including `validation` (R3) | business 422s map to `validation` |
| "Show the English detail behind an expander?" | hidden, but logged | clarification 2026-11-09 |
| Steps 2, 3 and 6 follow the API's phased rollout | one release | phases 0–2 shipped together in mbe-api #289 |
| Spec number 049 | 058 | 049 was used by back-office polish |
| Itinerary warnings read in two shapes | out of scope | no itinerary screens yet |
