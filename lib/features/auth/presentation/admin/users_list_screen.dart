import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
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
    final filter = ref.watch(userFilterControllerProvider);
    final filterController = ref.read(userFilterControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.users, AccessRight.create);
    final canUpdate = access.can(SystemObject.users, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    // Body-only: the shell owns the Scaffold/app bar (spec 010 US1). The Add
    // action sits beside the search bar, emphasised as primary (US4).
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('users_search_field'),
              label: l10n.usersSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: filterController.searchChanged,
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_user_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newUserTooltip),
                  onPressed: () => context.push('/users/new'),
                ),
            ],
          ),
        ),
        Expanded(
          child: usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.usersLoadError(e))),
            data: (CatalogPage<UserSummary> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noUsersFound))
                : DataTableView<UserSummary>(
                    key: const Key('users_table'),
                    columns: [
                      DataTableColumn.text(
                        label: l10n.columnUsername,
                        text: (u) => u.userId,
                        size: ColumnSize.M,
                      ),
                      DataTableColumn.text(
                        label: l10n.columnEmail,
                        text: (u) => u.email,
                        size: ColumnSize.L,
                      ),
                      DataTableColumn(
                        label: l10n.columnAdmin,
                        size: ColumnSize.S,
                        cellBuilder: (_, u) => u.administrator
                            ? const Icon(Icons.check)
                            : const SizedBox.shrink(),
                      ),
                      DataTableColumn(
                        label: l10n.columnStatus,
                        size: ColumnSize.S,
                        cellBuilder: (_, u) => Text(
                          u.disabled ? l10n.statusDisabled : l10n.statusActive,
                        ),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => ref
                        .read(usersControllerProvider.notifier)
                        .goToPage(pageIndex),
                    onRowTap: (u) =>
                        context.push('/users/${u.userId}?view=true'),
                    rowActionsBuilder: (context, u) => buildCatalogRowActions(
                      editTooltip: l10n.editActionTooltip,
                      onEdit: canUpdate
                          ? () => context.push('/users/${u.userId}')
                          : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
