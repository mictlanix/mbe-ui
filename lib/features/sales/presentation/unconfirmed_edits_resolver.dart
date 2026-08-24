import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/unconfirmed_changes_dialog.dart';

/// The keep / discard / keep-editing decision a critical action raises when
/// [scope] still holds typed-but-unconfirmed text (spec 031 FR-024…FR-030,
/// spec 029 FR-036). Extracted from `capture_step.dart`'s
/// `_onContinuePressed`, which is now this function plus a single call to its
/// own confirm — the extraction is deliberately behaviour-neutral, so both
/// the register's continue action and the back-office order screen's confirm
/// resolve the same question the same way, on their own [scope].
///
/// Returns whether the caller should proceed with its own critical action:
///
/// - no unconfirmed entries → `true` immediately, no dialog shown;
/// - **keep** → every entry commits through its own field's path (FR-026) —
///   the same write, the same registration in the outstanding-writes
///   signal, the same refusal handling a confirmed edit already has. Returns
///   `true` only once every one of them has actually landed;
/// - **discard** → every entry discards, and the caller proceeds (`true`);
/// - **keep editing** → every entry `resume()`s, restoring the typed text the
///   dialog's own focus loss would otherwise have discarded (FR-028); the
///   caller does not proceed (`false`).
///
/// If [context] is unmounted by the time the dialog resolves, none of the
/// three branches run — matching what `_onContinuePressed` did before this
/// extraction.
Future<bool> resolveUnconfirmedEdits(
  BuildContext context,
  WidgetRef ref,
  String scope,
) async {
  final entries = ref.read(unconfirmedEditsProvider(scope));
  if (entries.isEmpty) return true;

  final answer = await showUnconfirmedChangesDialog(context);
  if (!context.mounted) return false;

  switch (answer) {
    case UnconfirmedChangesAnswer.keep:
      final results = await Future.wait(entries.map((e) => e.confirm()));
      return results.every((ok) => ok);
    case UnconfirmedChangesAnswer.discard:
      for (final entry in entries) {
        entry.discard();
      }
      return true;
    case UnconfirmedChangesAnswer.keepEditing:
      for (final entry in entries) {
        entry.resume();
      }
      return false;
  }
}
