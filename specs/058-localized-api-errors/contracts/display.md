# Contract: Showing an error

## 1. Text API (`lib/core/errors/localize_problem.dart`)

```text
String? localizeProblem(ApiProblem p, AppLocalizations l10n, AppFormatters fmt)
String? localizeValidationType(String type, AppLocalizations l10n)   // null for unknown types and for password_policy
String  resourceNoun(String? resource, AppLocalizations l10n)   // generic noun when unknown

extension AppErrorText on AppError {
  /// Localized text for this error, or null when none can be built.
  String? localizedMessage(AppLocalizations l10n, AppFormatters fmt);
  /// localizedMessage ?? serverMessage. The only way server text reaches a screen (FR-014).
  String? userMessage(AppLocalizations l10n, AppFormatters fmt);
}
```

`localizedMessage` is built in this order:
1. If the error has a `problem` and `localizeProblem` returns text, use it.
2. Otherwise, for a `ValidationError` with field errors, `localizeValidationType(entry.type)` applies to each one. Text is returned only when every entry localizes; the entries are joined with a newline.
3. Otherwise `null`.

`userMessage` is `localizedMessage`, else `serverMessage`, else, for a field-level `ValidationError`, each entry's `localizeValidationType(type) ?? msg` joined by a newline. Single-line consumers such as tooltips and snackbars use it.

`serverMessage` (existing) keeps its meaning and stays public, for logs and tests. After this feature the only code that reads it is the fallback inside `userMessage`; SC-004's search enforces this.

## 2. `ErrorBanner` (`lib/core/widgets/error_banner.dart`)

The widget becomes a `ConsumerWidget`, because it reads `formattersProvider`. Its constructor is unchanged, so the 62 call sites compile as they are. Its message list:

| Error | Lines shown |
|---|---|
| `localizedMessage` is not null | that text only, with no headline and no English (FR-012) |
| `ValidationError` with field errors, not all localizable | each entry's localized text when it has one, else its `msg`, as today |
| otherwise | today's output: the generic headline plus the English detail, for the same variants as today |

A known code whose `localizeProblem` returns `null`, because a param is broken, lands in the last row. That fallback is FR-002 and scenario 6 of Story 1.

## 3. `FormErrorBanner` (new, `lib/core/widgets/form_error_banner.dart`)

```text
FormErrorBanner({required String headline, AppError? cause})
```

| `cause` | Lines shown |
|---|---|
| null | `headline` |
| otherwise | `headline` + `cause.userMessage(l10n, fmt)` when not empty: the localized reason, or the English text when there is none (today's output) |

This replaces the hand-built `ErrorBanner(error: AppError.validation([FieldError(msg: _localizeFormError(...)), FieldError(msg: errorDetail)]))` in the form screens. The form's `_localizeFormError` still supplies `headline`: what failed, such as "Couldn't save the operator". The cause supplies why.

## 4. Form controllers (FR-013)

- In each state, `String? errorDetail` becomes `AppError? errorCause` (data-model).
- `errorDetail: e.serverMessage` becomes `errorCause: e`.
- `errorDetail: null` becomes `errorCause: null`.
- `users_controller.dart:416` sets `errorDetail: (e as ValidationError).errors.first.msg`. It becomes `errorCause: e`, and the entry is localized by `userMessage`. Lines 420 and 467 of the same file, and `user_profiles_controller.dart:234, 255`, store `e.errors.first.msg` in `error`. They store `e.errors.first.type` when `localizeValidationType` knows it, else the `msg`, and the screens' default branch calls `localizeValidationType` (§7).
- Screens pass `headline: _localizeFormError(l10n, state.error!)` and `cause: state.errorCause` to `FormErrorBanner`.

Files: the 24 controllers and 29 display files found by `errorDetail` (research R6). Tests that assert `errorDetail` text (13 files, 23 references) switch to asserting `errorCause` or the rendered text.

## 5. Other displays

| File | Today | After |
|---|---|---|
| `sales/presentation/delivery/destination_card.dart:188` | `posDeliveryAssignmentRefused(e.serverMessage ?? errorServerGeneric)` | `posDeliveryAssignmentRefused(e.userMessage(l10n, fmt) ?? errorServerGeneric)` |
| `sales/presentation/refunds/refund_detail_screen.dart:206, 233` | `e.serverMessage ?? errorServerGeneric` | `e.userMessage(l10n, fmt) ?? errorServerGeneric` |
| `sales/presentation/refunds/refund_open_or_resume.dart:75, 113` | appends `e.message`; snackbar `e.serverMessage` | by code (error-mapping.md §7); `e.userMessage(...)` |
| `pricing/presentation/price_cell.dart:269` and `pricing_grid_controller.dart:941` | the controller sets `RejectedEdit.reason` to `errors.first.msg` for a field-level 422, else to the generic `saveFailed` code. The tooltip shows that string. | `RejectedEdit` gains `AppError? cause`. Every server failure sets `reason = saveFailed` and `cause = e`. The tooltip for `saveFailed` is `cause?.userMessage(l10n, fmt) ?? pricingSaveFailedError`. For example, `price_list.cost_read_only` now explains itself. |

## 6. Server field errors in forms (FR-011)

Only the screens that can receive a known validation type change: product form, user and user-profile admin forms, the inline contact form, the supplier agreement dialog. The quote email dialog needs nothing, because it shows its error through `ErrorBanner`. The other form controllers' `_fieldErrorsFromServer` helpers keep storing `fieldError.msg`.

- **Controller**: a helper `String serverFieldValue(FieldError e)` in `lib/core/errors/localize_problem.dart` returns `e.type` when `localizedValidationTypes` contains it, else `e.msg`. The controllers above store its result.
- **Screen**: the default branch of `_localizeFieldError` (or of the `error` text switch) returns `localizeValidationType(code, l10n) ?? code`.

## 7. Locale changes

Text is built at build time from `AppLocalizations.of(context)` and `formattersProvider`. No message is cached in state, so switching language re-renders every visible error in the new language (Story 2, scenario 2).
