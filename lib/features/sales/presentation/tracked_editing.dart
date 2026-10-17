import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// The document-agnostic scaffold every `SaleEditor` implementation shares
/// (spec 040 research.md R3) — extracted from `SaleEditing`, which used to
/// declare this outright, so a third editor (a quote's) does not have to
/// duplicate it. What stays here is genuinely generic: "which document",
/// "which write-gate scope", and the publish-before-return discipline
/// [tracked] enforces. Everything that assumes a *sales order* specifically
/// — `origin`, `ensureOpen()`'s call to `SalesOrderRepository.open`, and
/// every mutation body's twelve-or-so order-shaped parameters — stays on
/// `SaleEditing` (and its quote counterpart, `QuoteEditing`), because a
/// shared repository interface wide enough to cover both documents would
/// have to accept fields one of them silently drops.
///
/// No `on` clause: the common ancestor every generated notifier base
/// (`PosSaleController`'s and the order- and quote-id-keyed family
/// notifiers' generated `$AsyncNotifier` bases) actually share is a package-private type that cannot be
/// named from outside `package:riverpod` — verified against the generated
/// code for both shapes rather than assumed. Declaring [ref] and [state]
/// here instead, matching `AsyncNotifierBase`'s own signatures exactly, lets
/// Dart's structural mixin application satisfy them from whichever concrete
/// base a mixing-in class actually has.
mixin TrackedEditing {
  // The `ref` type every generated notifier base declares — plain `Ref`
  // since riverpod 3. Restated here because this is a structural mixin with
  // no `on` clause to inherit the type from.
  Ref get ref;
  AsyncValue<Sale?> get state;
  set state(AsyncValue<Sale?> value);

  /// The scope this notifier's writes and unconfirmed edits register
  /// against (spec 031, spec 029 FR-038, spec 040 FR-041) — `posWritesScope`
  /// for the register, `salesOrderWritesScope` for the back-office order
  /// screen, `salesQuoteWritesScope` for a quote. Never shared between any
  /// two of them.
  String get writesScope;

  /// For the mutations that cannot be a first action — there is nothing to
  /// update, remove or confirm before a document exists.
  Sale get openSale {
    final current = state.value;
    if (current == null) {
      throw StateError('This action needs an open sale; none is started.');
    }
    return current;
  }

  /// Registers this call in `pendingWritesProvider(writesScope)` for the
  /// whole of [action] — including [action]'s own
  /// `state = AsyncValue.data(...)` assignment, which must happen *before*
  /// [action] returns so the count only reaches zero once the figures a
  /// gated step reads are already the document's own (spec 031 FR-003,
  /// research R6). Every mutating method on `SaleEditing`/`QuoteEditing`
  /// routes through this rather than registering by hand.
  ///
  /// The editor is kept alive for the whole call: under riverpod 3 an
  /// auto-disposed notifier that nothing watches can otherwise be disposed
  /// mid-request, losing the document the request returns.
  Future<T> tracked<T>(Future<T> Function() action) async {
    final keepAlive = ref.keepAlive();
    try {
      return await ref
          .read(pendingWritesProvider(writesScope).notifier)
          .track(action);
    } finally {
      keepAlive.close();
    }
  }

  /// Publishes [sale] as this editor's document — unless the editor was
  /// disposed while the request that produced it was in flight (its screen
  /// closed mid-write). Riverpod 3 throws on a disposed notifier's `state`;
  /// riverpod 2 dropped such a write silently, and dropping it is still
  /// right: nothing is left to show it.
  void publish(Sale sale) {
    if (ref.mounted) state = AsyncValue.data(sale);
  }
}
