import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Landing screen after sign-in (FR-005/006/007; contracts/routes.md "/").
/// Lists nav entries gated by [AccessControlService.can], and provides the
/// sign-out action (FR-004).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider).valueOrNull;
    final access = ref.watch(accessControlProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.email),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (access.can(SystemObject.users, AccessRight.read))
            ListTile(
              key: const Key('home_nav_users'),
              leading: const Icon(Icons.people),
              title: Text(l10n.usersMenuTitle),
              onTap: () => context.push('/users'),
            ),
        ],
      ),
    );
  }
}
