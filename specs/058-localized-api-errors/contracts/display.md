# Contract: Showing an error

## 1. Text API (`lib/core/errors/localize_problem.dart`)

```text
String? localizeProblem(ApiProblem p, AppLocalizations l10n, AppFormatters fmt)
String? localizeFieldError(FieldError e, AppLocalizations l10n, AppFormatters fmt)
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
2. Otherwise, for a `ValidationError` with field errors, `localizeFieldError` applies to each one. Text is returned only when every entry localizes; the entries are joined with a newline.
3. Otherwise `null`.

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
- `users_controller.dart:416` sets `errorDetail: (e as ValidationError).errors.first.msg`. It becomes `errorCause: e`, and the field entry is localized through `localizeFieldError`.
- Screens pass `headline: _localizeFormError(l10n, state.error!)` and `cause: state.errorCause` to `FormErrorBanner`.

Files: the 24 controllers and 29 display files found by `errorDetail` (research R6). Tests that assert `errorDetail` text (13 files, 23 references) switch to asserting `errorCause` or the rendered text.

## 5. Other displays

| File | Today | After |
|---|---|---|
| `sales/presentation/delivery/destination_card.dart:188` | `posDeliveryAssignmentRefused(e.serverMessage ?? errorServerGeneric)` | `posDeliveryAssignmentRefused(e.userMessage(l10n, fmt) ?? errorServerGeneric)` |
| `sales/presentation/refunds/refund_detail_screen.dart:206, 233` | `e.serverMessage ?? errorServerGeneric` | `e.userMessage(l10n, fmt) ?? errorServerGeneric` |
| `sales/presentation/refunds/refund_open_or_resume.dart:75, 113` | appends `e.message`; snackbar `e.serverMessage` | by code (error-mapping.md §7); `e.userMessage(...)` |
| `pricing/presentation/price_cell.dart:269` | tooltip = the raw server message carried in `rejected.reason` | the controller stores the localized field text when it has one (next row), so the tooltip shows it |
| `pricing/presentation/{pricing_grid_controller:941, pricing_controller:184, price_list_form_controller:244, exchange_rate_form_controller:272}` | `fieldError.msg` | `localizeFieldError(...) ?? fieldError.msg`, resolved where the controller has `l10n`/`fmt`. Otherwise it stores the `FieldError` and resolves it in the widget. Decided per file in tasks. |

## 6. Locale changes

Text is built at build time from `AppLocalizations.of(context)` and `formattersProvider`. No message is cached in state, so switching language re-renders every visible error in the new language (Story 2, scenario 2).
