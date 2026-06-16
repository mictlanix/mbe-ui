import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Admin screen listing all user accounts (FR-011). Gated by
/// `can(SystemObject.users, AccessRight.read)` in the router.
class UsersListScreen extends ConsumerWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersControllerProvider);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.users, AccessRight.create);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.usersTitle),
        actions: [
          if (canCreate)
            IconButton(
              key: const Key('new_user_button'),
              icon: const Icon(Icons.person_add),
              tooltip: l10n.newUserTooltip,
              onPressed: () => context.push('/users/new'),
            ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.usersLoadError(e))),
        data: (users) => users.isEmpty
            ? Center(child: Text(l10n.noUsersFound))
            : DataTableView<UserSummary>(
                key: const Key('users_table'),
                columns: [
                  DataTableColumn(
                    label: l10n.columnUsername,
                    cellBuilder: (_, u) => Text(u.userId),
                    comparator: (a, b) => a.userId.compareTo(b.userId),
                  ),
                  DataTableColumn(
                    label: l10n.columnEmail,
                    cellBuilder: (_, u) => Text(u.email),
                    comparator: (a, b) => a.email.compareTo(b.email),
                  ),
                  DataTableColumn(
                    label: l10n.columnAdmin,
                    cellBuilder: (_, u) =>
                        u.administrator ? const Icon(Icons.check) : const SizedBox.shrink(),
                  ),
                  DataTableColumn(
                    label: l10n.columnStatus,
                    cellBuilder: (_, u) =>
                        Text(u.disabled ? l10n.statusDisabled : l10n.statusActive),
                  ),
                ],
                rows: users,
                onRowTap: (u) => context.push('/users/${u.userId}'),
              ),
      ),
    );
  }
}
