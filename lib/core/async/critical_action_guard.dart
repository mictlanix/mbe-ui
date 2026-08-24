/// One mechanism for "does a critical action need to wait?" — reusable by
/// any screen with a critical submit, not just point of sale (spec 031
/// FR-011). Two questions, two providers, kept in one file because they are
/// two halves of the same gate:
///
/// - [pendingWritesProvider] — how many changes are outstanding right now.
/// - [unconfirmedEditsProvider] — which fields hold typed text nobody has
///   confirmed yet.
///
/// Neither provider knows what a "sale" is, or anything else about a
/// specific feature. A caller declares its own opaque scope string (the
/// point of sale's is `posWritesScope`,
/// `lib/features/sales/presentation/pos_write_scope.dart`) and reads/writes
/// against it; two different scopes never see each other's state (spec 031
/// research R1).
library;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'critical_action_guard.g.dart';

/// How many changes are outstanding in [scope] — begun and not yet settled,
/// including a value confirmed locally but not yet sent (spec 031 FR-001,
/// FR-002, FR-004).
///
/// `keepAlive: true` is load-bearing, not idiomatic drift: an autoDisposed
/// family entry is recreated at zero once its last listener leaves, and a
/// writer that only `ref.read`s this (never `ref.watch`es it) does not keep
/// it alive — a write could begin against one instance and end against
/// another, silently wrong. Every gate this feature adds `ref.watch`es it,
/// which is enough to keep it alive while a step is on screen, but the
/// writers cannot be relied on for that (spec 031 research R1).
@Riverpod(keepAlive: true)
class PendingWrites extends _$PendingWrites {
  @override
  int build(String scope) => 0;

  /// Registers an ordinary write: increments before running [action],
  /// decrements in a `finally` so a throw releases exactly as a success
  /// does (FR-006), and rethrows unchanged — registering a write must not
  /// change what it does, returns, or throws (FR-012).
  ///
  /// Callers that publish new state as part of [action] must publish it
  /// *before* this method's own decrement runs. `finally` runs after
  /// [action] returns, so as long as [action] itself does the publishing
  /// synchronously before it returns, the ordering (spec 031 research R6)
  /// holds without any extra ceremony here — publish first, in the caller,
  /// is the caller's responsibility, and it is the one rule that keeps a
  /// step's action from becoming available a moment before its own figures
  /// do (SC-002).
  Future<T> track<T>(Future<T> Function() action) async {
    state = state + 1;
    try {
      return await action();
    } finally {
      state = state - 1;
    }
  }

  /// Tokens from [begin] not yet released by [end] — what makes a duplicate
  /// [end] call a no-op instead of driving [state] negative (a pending write
  /// flushed twice, once by its own debounce and once by `dispose`'s
  /// fire-and-forget, is exactly this case).
  final Set<Object> _liveTokens = {};

  /// A hold for work that is outstanding before any [Future] exists — the
  /// coalescing window a debounced control waits out before it has anything
  /// to `await` (FR-004, research R2). Returns a token; release it exactly
  /// once with [end].
  Object begin() {
    final token = Object();
    _liveTokens.add(token);
    state = state + 1;
    return token;
  }

  /// Releases a hold from [begin]. Idempotent: releasing the same token
  /// twice, or a token this scope never issued, is a no-op — the count never
  /// goes negative.
  void end(Object token) {
    if (!_liveTokens.remove(token)) return;
    state = state - 1;
  }

  /// Drops the count to zero — for a boundary where a scope's outstanding
  /// work provably ends (a new sale opened, a different one loaded). Not an
  /// error-recovery path: a leaked hold is a bug, and this assertion is what
  /// makes it fail a test rather than silently stranding a cashier with a
  /// permanently disabled step action (FR-006, research R2).
  void reset() {
    assert(
      state == 0,
      'PendingWrites.reset() for scope "$scope" dropped a non-zero count '
      '($state) — a write or a hold was never released. This would leave a '
      "critical action's gate disabled with nothing left to clear it.",
    );
    _liveTokens.clear();
    state = 0;
  }
}

/// One field's typed-but-unconfirmed text, registered in [scope] while it
/// exists (spec 031 FR-024, FR-030, data-model.md §2).
///
/// Stored as a value object carrying callbacks — unusual for provider state,
/// and deliberate: "keep" (FR-026) has to commit through the *same* path
/// Enter would have taken, which needs a handle on the field, not just a
/// dirty flag (research R5).
@immutable
class UnconfirmedEdit {
  const UnconfirmedEdit({
    required this.id,
    required this.text,
    required this.confirm,
    required this.discard,
    required this.resume,
  });

  /// Stable for the field's lifetime, unique within its scope.
  final Object id;

  /// What the user typed and has not confirmed.
  final String text;

  /// Commits [text] exactly as pressing Enter in the field would.
  /// `false` means the server refused it — never throws (spec 031
  /// contracts/confirmable-field.md §1).
  final Future<bool> Function() confirm;

  /// Discards [text] exactly as a focus loss would, including the same
  /// acknowledgement.
  final void Function() discard;

  /// Re-establishes [text] as the field's live draft — the "keep editing"
  /// answer (FR-028). Raising the question at all requires a modal dialog,
  /// and opening one blurs whatever field was focused, which discards its
  /// draft by the ordinary rule (FR-014) before the cashier ever answers;
  /// this undoes that incidental discard so "keep editing" genuinely means
  /// what it says rather than silently losing the value it claims to keep.
  /// A no-op if the field's draft was never actually lost.
  final void Function() resume;

  @override
  bool operator ==(Object other) => other is UnconfirmedEdit && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Which fields in [scope] currently hold unconfirmed text (FR-024, FR-030).
/// Membership never disables anything by itself (FR-005) — it is read only
/// when a critical action fires.
@Riverpod(keepAlive: true)
class UnconfirmedEdits extends _$UnconfirmedEdits {
  @override
  List<UnconfirmedEdit> build(String scope) => const [];

  /// Adds a new entry, or replaces the existing one sharing [edit.id].
  void put(UnconfirmedEdit edit) {
    state = [
      for (final existing in state)
        if (existing.id != edit.id) existing,
      edit,
    ];
  }

  /// Removes the entry for [id], if one exists — on confirm, on discard, and
  /// on the field's own disposal, so an entry never outlives its field.
  void remove(Object id) {
    if (state.every((e) => e.id != id)) return;
    state = [
      for (final existing in state)
        if (existing.id != id) existing,
    ];
  }
}
