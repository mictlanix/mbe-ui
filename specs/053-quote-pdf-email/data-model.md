# Data Model: Quotation PDF and Email

**Feature**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

Nothing is persisted on the client (§VII). These are the immutable domain values and the
one piece of local UI state the feature adds. The quote document itself is bytes in the
existing `RenderedDocument` (spec 044), with no new entity.

## DocumentKind.salesQuote *(extends `lib/core/documents/domain/document_kind.dart`)*

| Aspect | Value |
|---|---|
| Endpoint | `GET /sales-quotes/{id}/document` |
| Gate | `SystemObject.salesQuotes` + `AccessRight.read` |
| Fallback filename | `cotizacion-{id padded to 8}.pdf` |
| Valid states | every `SaleStatus` |

## QuoteEmailReceipt *(new, `lib/features/sales/domain/quote_email.dart`, freezed)*

What the server confirms after a successful send. It is mapped from `QuoteEmailResponse`.

| Field | Type | Source | Notes |
|---|---|---|---|
| `recipients` | `List<String>` | `recipients` | As normalised by the server (trimmed, deduplicated). Shown in the success message (FR-012). |
| `sentAt` | `DateTime` | `sent_at` | Mexico City local wall time. Not displayed in this spec; kept for a future send history. |

Also in this file: `bool isPlausibleEmail(String)`, the server's pattern, with a maximum
length of 254 after trimming (research R8).

## RecipientChip *(new, presentation state, `quote_email_controller.dart`)*

One selectable address in the dialog.

| Field | Type | Notes |
|---|---|---|
| `address` | `String` | Trimmed, original letter case kept for display and sending. |
| `key` | `String` | `address.toLowerCase()`, used for identity and deduplication. |
| `owner` | `String?` | Contact or fiscal-recipient name; `null` for a typed address. |
| `origin` | `RecipientOrigin` | `contact` \| `fiscalRecipient` \| `typed`. Orders the chips. |

Label: `"$owner · $address"` when `owner` is non-null, otherwise just `address` (FR-008).

## QuoteEmailState *(new, presentation state)*

Held by `QuoteEmailController`, an autoDispose `Notifier` family keyed by quote id.

| Field | Type | Initial | Notes |
|---|---|---|---|
| `chips` | `List<RecipientChip>` | `[]` | Contacts, then fiscal recipients, then typed, each group keeping its arrival order. |
| `selected` | `Set<String>` (chip keys) | `{}` | The recipients are exactly these (FR-009). |
| `sending` | `bool` | `false` | While true, every mutator is a no-op and the dialog is not dismissible (FR-011). |
| `failure` | `QuoteEmailFailure?` | `null` | Last send failure; cleared on the next send or dismiss. |
| `failureError` | `AppError?` | `null` | The error behind `failure`, rendered through `ErrorBanner` (research R5). |
| `sawNotSendable` | `bool` | `false` | Latches true on a 409, so closing the dialog returns `staleQuote` (FR-014). |

### Derived

- `canSend` = `!sending && selected.isNotEmpty && selected.length <= 10`
- `atLimit` = `selected.length >= 10`
- `recipients` = the `address` of each selected chip, in chip order

### Rules (the controller's mutators)

| Mutator | Rule |
|---|---|
| `seed(contacts, taxpayers)` | Adds chips for emails that pass `isPlausibleEmail` and are not already present (by `key`); a stored address the server would refuse is not offered, since selecting it could only fail the whole send. The first occurrence wins, so a contact's name beats a fiscal recipient's for a shared address. It never removes chips or changes `selected`, so it is idempotent across a reload or retry. |
| `toggle(key)` | Deselects if selected. Otherwise selects only if `!atLimit`, and returns `limitReached` when it cannot. |
| `addTyped(text)` | Trims the text. If it fails `isPlausibleEmail` → returns `invalid`. If its key matches an existing chip → selects that chip (subject to the limit) → returns `selectedExisting`. If at the limit → returns `limitReached`. Otherwise it appends a `typed` chip, selected → returns `added`. |
| *(deselect a typed chip)* | The chip stays, unselected (wireframe review, OQ4). |
| `send()` | No-op unless `canSend`. Sets `sending`, calls `SalesQuoteRepository.email`, and returns the receipt. On `AppError` it classifies the failure (`quoteEmailFailureOf`), keeps the selection, and latches `sawNotSendable` on 409. It always clears `sending`. |

## QuoteEmailFailure *(new enum)*

| Value | From | Message source |
|---|---|---|
| `notSendable` | `ServerError(409)` | `salesQuoteEmailNotSendable` |
| `invalidRecipients` | `ValidationError` (422) | the server's field errors or `detail` |
| `mailRefused` | `ServerError(502)` | `salesQuoteEmailMailRefused` |
| `mailUnavailable` | `ServerError(503)` | `salesQuoteEmailMailUnavailable` |
| `other` | anything else | the original `AppError` |

## QuoteEmailOutcome *(new, sealed, dialog result)*

| Variant | When | Caller does |
|---|---|---|
| `sent(QuoteEmailReceipt)` | send succeeded | shows the snackbar listing `receipt.recipients` |
| `staleQuote` | closed after a 409 | `quoteEditorControllerProvider(id).notifier.refresh()` |
| *(null)* | cancelled otherwise | nothing |

## State transitions (dialog)

```
            seed / toggle / addTyped
   ┌────────────────────────────────────┐
   ▼                                    │
 idle ──send()──▶ sending ──ok──▶ closed(sent)
   ▲                 │
   │                 └──AppError──▶ failed (selection kept; 409 latches staleQuote)
   │                                    │
   └────────── edit / retry ────────────┘
 idle | failed ──close──▶ closed(staleQuote if latched, else null)
 sending ──close──✗ (not dismissible)
```
