import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The app bar's single trailing control: the signed-in user's menu
/// (spec 010 US2, FR-009–FR-014; contracts/user-menu.md). Shows identity, the
/// current store/POS/cash-drawer location context, Change Password, and
/// Logout. All data comes from the already-loaded `/auth/me` session — no
/// network call, no catalog RBAC.
class UserMenuButton extends ConsumerWidget {
  const UserMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider).valueOrNull;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final user = authState.user;
    final settings = user.settings;

    return MenuAnchor(
      builder: (context, controller, _) => IconButton(
        key: const Key('user_menu_button'),
        icon: const Icon(Icons.account_circle),
        tooltip: user.email,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        Padding(
          key: const Key('user_menu_identity'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            user.email,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ..._locationLines(context, l10n, settings),
        const Divider(height: 8),
        MenuItemButton(
          key: const Key('user_menu_change_password'),
          leadingIcon: const Icon(Icons.lock_outline),
          onPressed: () => context.push('/auth/account/password'),
          child: Text(l10n.changePasswordMenuTitle),
        ),
        MenuItemButton(
          key: const Key('user_menu_logout'),
          leadingIcon: const Icon(Icons.logout),
          onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          child: Text(l10n.userMenuLogout),
        ),
      ],
    );
  }

  /// The store / POS / cash-drawer lines. A line is omitted when its id is
  /// null (FR-014); when the id is present it shows the labeled-ID fallback
  /// until `/auth/me` carries resolved names (mbe-api#79), at which point the
  /// helper below prefers the name (FR-011).
  List<Widget> _locationLines(
    BuildContext context,
    AppLocalizations l10n,
    UserSettings? settings,
  ) {
    if (settings == null) return const [];
    final lines = <Widget>[];
    final store = settings.storeId;
    final pos = settings.pointSaleId;
    final drawer = settings.cashDrawerId;
    if (store != null) {
      lines.add(_infoLine(
        context,
        const Key('user_menu_store'),
        // TODO(mbe-api#79): prefer settings.storeName ("name (code)") once
        // /auth/me carries it; fall back to the labeled id below.
        l10n.userMenuStoreFallback(store),
      ));
    }
    if (pos != null) {
      lines.add(_infoLine(
        context,
        const Key('user_menu_pos'),
        // TODO(mbe-api#79): prefer settings.pointSaleName ("name (code)").
        l10n.userMenuPosFallback(pos),
      ));
    }
    if (drawer != null) {
      lines.add(_infoLine(
        context,
        const Key('user_menu_cash_drawer'),
        // TODO(mbe-api#79): prefer settings.cashDrawerName ("name (code)").
        l10n.userMenuDrawerFallback(drawer),
      ));
    }
    return lines;
  }

  Widget _infoLine(BuildContext context, Key key, String text) {
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
