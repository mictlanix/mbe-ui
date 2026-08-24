/// The back-office order screen's scope for
/// [pendingWritesProvider]/[unconfirmedEditsProvider]
/// (`lib/core/async/critical_action_guard.dart`) — one screen, one scope
/// (spec 029 FR-038), mirroring `pos_write_scope.dart`'s own comment about
/// its own constant. Every mutating call on `OrderEditorController`
/// registers here, and the order screen's own confirm gates on it — never on
/// `posWritesScope`, so the two screens' outstanding-writes and
/// unconfirmed-edits state can never hold each other's confirm gate open or
/// shut.
const salesOrderWritesScope = 'back-office-sale';
