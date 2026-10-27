import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The cash-session gate (contracts/pos-screen.md §0, FR-002a, FR-002b). No
/// sale is ever opened without a current session. Owns every rendering
/// decision that follows purely from `CurrentSession`, independent of the
/// `Sale` itself, so `PosWorkspaceScreen` never has to duplicate this logic:
///
/// - `state == none`: the full-screen explanation + link —
///   `PosWorkspaceScreen` renders this in place of everything else (header
///   band, step host, footer), none of which exist yet
///   (contracts/pos-screen.md §1).
/// - `state == open`: renders nothing — `PosWorkspaceScreen` proceeds to its
///   own header band and step host below/around this widget.
/// - `state == stale`: renders the blocking banner
///   ([PosSessionBlockedBanner]) — payments are refused until the session is
///   closed (spec 047).
///
/// Has no state of its own beyond watching `currentSessionControllerProvider`
/// (021-cash-sessions, reused as-is: no new repository, no new entity here).
class PosGateScreen extends ConsumerWidget {
  const PosGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(currentSessionControllerProvider);
    return currentSession.when(
      data: (current) => switch (current.state) {
        SessionState.none => _GateBody(theme: Theme.of(context)),
        SessionState.open => const SizedBox.shrink(),
        SessionState.stale => const PosSessionBlockedBanner(),
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      // A failed session lookup is treated like `none` — safer to block a
      // sale from opening than to assume the session is fine.
      error: (error, stackTrace) => _GateBody(theme: Theme.of(context)),
    );
  }
}

class _GateBody extends StatelessWidget {
  const _GateBody({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.point_of_sale_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              key: const Key('pos_gate_no_session_title'),
              l10n.posGateNoSessionTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.posGateNoSessionBody,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('pos_gate_open_session_button'),
              onPressed: () => context.go('/sales/cash-sessions'),
              child: Text(l10n.posGateOpenSessionAction),
            ),
          ],
        ),
      ),
    );
  }
}

/// The blocking banner (spec 047 contracts C2): shown wherever a sale is in
/// hand but the cash session is not valid — expired (`stale`) or absent
/// (`none`) — in place of the old non-blocking stale notice. It says payments
/// are blocked and offers the one action that unblocks them: the stale
/// session's close screen, or the cash-sessions list when there is none.
/// Renders nothing while the session is open (or still loading).
class PosSessionBlockedBanner extends ConsumerWidget {
  const PosSessionBlockedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentSessionControllerProvider);
    // A failed lookup reads like `none`, as in `PosGateScreen`.
    final state = current.hasError ? null : current.value;
    if (current.isLoading && state == null) return const SizedBox.shrink();
    if (state != null && state.isValid) return const SizedBox.shrink();
    final sessionId = state?.state == SessionState.stale
        ? state?.session?.cashSessionId
        : null;
    return _BlockedBanner(sessionId: sessionId);
  }
}

class _BlockedBanner extends StatelessWidget {
  const _BlockedBanner({required this.sessionId});

  /// The stale session to close, or `null` when there is no session.
  final int? sessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final stale = sessionId != null;
    return Container(
      key: const Key('pos_session_blocked_banner'),
      width: double.infinity,
      color: theme.colorScheme.errorContainer,
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.screenMargin,
        vertical: theme.spacing.xs,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: theme.spacing.sm,
        children: [
          Text(
            stale
                ? l10n.posSessionExpiredPaymentsBlocked
                : l10n.posGateNoSessionBody,
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
          TextButton(
            key: const Key('pos_session_blocked_action'),
            // The close screen is pushed so Back returns to the sale; the
            // sessions list is a shell branch, reached with `go` as before.
            onPressed: () => stale
                ? context.push('/sales/cash-sessions/$sessionId')
                : context.go('/sales/cash-sessions'),
            child: Text(
              stale
                  ? l10n.posSessionCloseAction
                  : l10n.posGateOpenSessionAction,
            ),
          ),
        ],
      ),
    );
  }
}
