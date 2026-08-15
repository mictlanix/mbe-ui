import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _usersPath = '/users';

/// Admin screen listing all user accounts (FR-001, FR-002, FR-011). Gated
/// by `can(SystemObject.users, AccessRight.read)` in the router. Ships a
/// status filter drawer since the list endpoint exposes a `status` facet
/// (constitution §VI).
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class UsersListScreen extends ConsumerWidget {
  const UsersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = UserFilter.fromQuery(query);
    final usersAsync = ref.watch(usersControllerProvider(filter));
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
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_usersPath)
                    .toString(),
              ),
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
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('users_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_usersPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _UserFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<UserSummary>(
            state: usersAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noUsersFound,
            createLabel: canCreate ? l10n.newUserTooltip : null,
            onCreate: canCreate ? () => context.push('/users/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_usersPath),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(usersControllerProvider(filter)),
            onData: (page) => DataTableView<UserSummary>(
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
                // Provenance only — never a live description of the
                // account's current permissions (024-user-profiles FR-027,
                // FR-030).
                DataTableColumn.text(
                  label: l10n.columnProfile,
                  text: (u) => u.profileName ?? '',
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  size: ColumnSize.S,
                  cellBuilder: (_, u) => EntityStatusCell(status: u.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_usersPath)
                    .toString(),
              ),
              onRowTap: (u) => context.push('/users/${u.userId}?view=true'),
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

/// The Users catalog's status facet, rendered inside the filter panel
/// opened from the Filters button (FR-011). A [ConsumerWidget] so the
/// controls stay reactive as the URL changes while the sheet — which lives
/// on its own navigator route — is open. Each change navigates immediately
/// via `context.go`; the panel itself holds no state.
class _UserFiltersPanel extends ConsumerWidget {
  const _UserFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = UserFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    // The picker itself calls an administrator-only endpoint
    // (024-user-profiles research.md §2), so it is omitted for a
    // non-administrator rather than shown-and-failing
    // (contracts/user-profile-screens.md §4).
    final isAdministrator = ref.watch(accessControlProvider).isAdministrator;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'users_filter_status',
          value: filter.status,
          onChanged: (status) => context.go(
            query
                .withFacet('status', status?.name)
                .copyWith(pageIndex: 0)
                .toUri(_usersPath)
                .toString(),
          ),
        ),
        if (isAdministrator) ...[
          const SizedBox(height: 16),
          _ProfileFilterField(query: query, profileId: filter.profileId),
        ],
      ],
    );
  }
}

/// The profile filter's `CatalogEntityPicker`, isolated so `profileId`'s
/// resolved display name (`userProfileNameProvider`, only needed when a
/// filter is actually applied) is watched only here, not on every panel
/// build (024-user-profiles research.md §8, mirroring
/// `cash_sessions_screen.dart`'s cashier facet).
class _ProfileFilterField extends ConsumerWidget {
  const _ProfileFilterField({required this.query, required this.profileId});

  final ListQuery query;
  final int? profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userProfileRepo = ref.read(userProfileRepositoryProvider);
    final resolvedName = profileId != null
        ? ref.watch(userProfileNameProvider(profileId!)).valueOrNull
        : null;

    return CatalogEntityPicker<UserProfileSummary>(
      key: const Key('users_filter_profile'),
      label: l10n.userProfilePickerLabel,
      displayStringForOption: (p) => p.name,
      optionsBuilder: (searchQuery) async {
        final result = await userProfileRepo.list(
          search: searchQuery.isEmpty ? null : searchQuery,
        );
        return result.items;
      },
      onSelected: (p) => context.go(
        query
            .withFacet('profile', '${p.userProfileId}')
            .copyWith(pageIndex: 0)
            .toUri(_usersPath)
            .toString(),
      ),
      initialDisplayText: resolvedName ?? profileId?.toString() ?? '',
      enabled: true,
    );
  }
}
