# Contract: UI Surfaces

The Dart-facing surfaces this feature adds or changes. These are signatures and behaviour
guarantees only; bodies belong to implementation. Layout follows [wireframes.md](../wireframes.md).

## C1 — `ResponsiveDialog` *(new, `lib/core/widgets/responsive_dialog.dart`)*

```dart
class ResponsiveDialogAction {
  const ResponsiveDialogAction({required this.label, required this.onPressed,
      this.busy = false, this.key});
  final String label;
  final VoidCallback? onPressed;   // null → disabled
  final bool busy;                 // shows a spinner in place of the label
  final Key? key;
}

class ResponsiveDialog extends StatelessWidget {
  const ResponsiveDialog({super.key, required this.title, required this.body,
      required this.primaryAction, this.secondaryAction,
      this.dismissible = true, this.maxWidth = 560});
  final String title;
  final Widget body;               // the dialog scrolls it; callers must not wrap it in a scroll view
  final ResponsiveDialogAction primaryAction;
  final ResponsiveDialogAction? secondaryAction;  // wide only; compact uses the close control
  final bool dismissible;
  final double maxWidth;
}

Future<T?> showResponsiveDialog<T>(BuildContext context,
    {required WidgetBuilder builder, bool barrierDismissible = true});
```

**Guarantees**

- **Tier**: decided by `LayoutBreakpoints.isCompact(context)` alone. No per-caller breakpoint.
- **Wide layout**: a `Dialog` laid out as title, then body (scrollable), then a trailing action row.
  - The action row holds `[secondary] [primary]`, with primary as a `FilledButton`.
  - Width is `min(maxWidth, screen − 80)`.
- **Compact layout**: `Dialog.fullscreen`.
  - The top bar is `[close] title … [primary]`, with primary as a `TextButton`.
  - The body scrolls, and there is no bottom action row.
  - `secondaryAction` is not rendered; the close control replaces it.
- **Non-dismissible** (`dismissible: false`):
  - `PopScope(canPop: false)` is set;
  - the close control and the secondary action are disabled;
  - Escape and back do nothing.

  A tap on the barrier also does nothing, because `PopScope` blocks the pop it triggers;
  this is tested, not assumed. `barrierDismissible` only controls barrier taps while the
  dialog is dismissible. Callers flip `dismissible` while busy.
- **Styling**: all spacing comes from `Theme.of(context).spacing`, colours from
  `ColorScheme`, and there are no literals (§V/§VI).
- **Goldens**: four goldens, light/dark × narrow/wide, registered in
  `test/golden/core_widgets_golden_test.dart`'s covered set.

## C2 — Document kind *(extends `lib/core/documents/`)*

```dart
enum DocumentKind { saleTicket(...), salesOrder(...), cashCut(...),
  /// `GET /sales-quotes/{id}/document` — the letter-size quote, in any state.
  salesQuote(SystemObject.salesQuotes); ... }
// fallbackFilename: DocumentKind.salesQuote => 'cotizacion-${_pad(recordId, 8)}.pdf'
```

`DocumentSourceImpl` takes an `api.SalesQuotesApi` built from the same `dio` +
`appSerializers`. No call site changes beyond the quote screen.

## C3 — Repository *(extends `lib/features/sales/domain/repositories/sales_quote_repository.dart`)*

```dart
/// POST /sales-quotes/{id}/email. Throws AppError (via _toAppError — never
/// CreditHoldError): ServerError(409|502|503), ValidationError(422), NetworkError.
Future<QuoteEmailReceipt> email({required int quoteId, required List<String> recipients});
```

## C4 — Email dialog *(new, `lib/features/sales/presentation/quotes/`)*

```dart
// quote_email_dialog.dart
Future<QuoteEmailOutcome?> showQuoteEmailDialog(BuildContext context, {required Sale quote});

// quote_email_controller.dart
@riverpod
class QuoteEmailController extends _$QuoteEmailController {
  QuoteEmailState build(int quoteId);
  void seed({required List<Contact> contacts, required List<TaxpayerRecipient> taxpayers});
  RecipientToggleResult toggle(String key);          // toggled | limitReached
  AddTypedResult addTyped(String text);              // added | selectedExisting | invalid | limitReached
  Future<QuoteEmailReceipt?> send();                 // null on failure (state.failure set)
  void clearFailure();
}
QuoteEmailFailure quoteEmailFailureOf(AppError error);
```

**Widget keys**:
- Dialog: `quote_email_dialog`
- Chips: `quote_email_chip_<key>`
- Typed field: `quote_email_other_field`
- Add button: `quote_email_add_button`
- Send: `quote_email_send_button`
- Cancel/close: `quote_email_cancel_button`
- Failure banner: `quote_email_error_banner`
- Suggestions retry: `quote_email_suggestions_retry`

**Guarantees**: FR-007 to FR-014. Chips are `FilterChip`s in a `Wrap` with token spacing,
and the label ellipsizes the owner before the address.

## C5 — Quote header actions *(changes `quote_header_panel.dart`)*

| Action | Key (button / menu item) | Shown when | Disabled when | Does |
|---|---|---|---|---|
| Ver cotización | `sales_quote_view_document_button` / `…_menu_item` | `canOpenDocument(access, salesQuote)` | `pendingWrites(salesQuoteWritesScope) > 0` | `resolveUnconfirmedEdits` → `documentActions.preview(DocumentRef(kind: salesQuote, recordId: id, title: documentSalesQuoteTitle(id padded 8)))` |
| Enviar por correo | `sales_quote_email_button` / `…_menu_item` | `can(salesQuotes, read)` && `status == completed` | never | `showQuoteEmailDialog` → snackbar on `sent`, `refresh()` on `staleQuote` |

**Tiers**:
- **Compact**: `[Más detalles] [⋮]`. The overflow trigger is an `IconButton(Icons.more_vert)`
  with key `sales_quote_more_actions_button`. It opens a `MenuAnchor` holding the same items.
- **Other tiers**: `[Ver cotización] [Enviar por correo] [Más detalles]` in the existing
  trailing `Wrap`.
- **No actions available**: the overflow trigger is absent.
