import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
/// - `state == stale`: renders the non-blocking banner —
///   `PosWorkspaceScreen` still proceeds, embedding this widget in its
///   header band.
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
        SessionState.stale => const _StaleSessionBanner(),
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
            Icon(Icons.point_of_sale_outlined, size: 48, color: theme.colorScheme.outline),
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

class _StaleSessionBanner extends StatelessWidget {
  const _StaleSessionBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        key: const Key('pos_stale_session_banner'),
        l10n.posStaleSessionBanner,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}
