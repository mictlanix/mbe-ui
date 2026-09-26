/// The quote screen's scope for
/// [pendingWritesProvider]/[unconfirmedEditsProvider]
/// (`lib/core/async/critical_action_guard.dart`) — one screen, one scope
/// (spec 040 FR-041), mirroring `sales_order_write_scope.dart`'s own comment
/// about its own constant. Every mutating call on `QuoteEditorController`
/// registers here, and the quote screen's own confirm/cancel/convert/
/// duplicate actions gate on it — never on `posWritesScope` or
/// `salesOrderWritesScope`, so a quote's outstanding-writes and
/// unconfirmed-edits state can never hold either other host's confirm gate
/// open or shut, and vice versa.
const salesQuoteWritesScope = 'back-office-quote';
