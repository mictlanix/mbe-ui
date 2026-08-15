import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_profiles_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _userProfilesPath = '/user-profiles';

/// Admin screen listing all user profiles (024-user-profiles FR-001,
/// contracts/user-profile-screens.md §1). Gated by
/// `AccessControlService.isAdministrator` in the router — profiles have no
/// `SystemObject` of their own (research.md §2), unlike every other catalog
/// screen this mirrors structurally (`UsersListScreen`).
///
/// [query] is decoded from the route by the router builder — the URL is
/// this screen's only source of view state (017-ui-consistency-filters
/// FR-017).
class UserProfilesListScreen extends ConsumerWidget {
  const UserProfilesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = UserProfileFilter.fromQuery(query);
    final profilesAsync = ref.watch(userProfilesControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final isAdministrator = access.isAdministrator;
    final l10n = AppLocalizations.of(context)!;

    // Body-only: the shell owns the Scaffold/app bar (spec 010 US1).
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('user_profiles_search_field'),
              label: l10n.userProfilesSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_userProfilesPath)
                    .toString(),
              ),
            ),
            actions: [
              if (isAdministrator)
                FilledButton.icon(
                  key: const Key('new_user_profile_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newUserProfileTooltip),
                  onPressed: () => context.push('/user-profiles/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('user_profiles_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_userProfilesPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _UserProfileFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<UserProfileSummary>(
            state: profilesAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noUserProfilesYetMessage,
            createLabel: isAdministrator ? l10n.newUserProfileTooltip : null,
            onCreate: isAdministrator
                ? () => context.push('/user-profiles/new')
                : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_userProfilesPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(userProfilesControllerProvider(filter)),
            onData: (page) => DataTableView<UserProfileSummary>(
              key: const Key('user_profiles_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnProfileName,
                  text: (p) => p.name,
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.columnProfileDescription,
                  text: (p) => p.description ?? '',
                  size: ColumnSize.L,
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  size: ColumnSize.S,
                  cellBuilder: (_, p) => EntityStatusCell(status: p.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_userProfilesPath)
                    .toString(),
              ),
              onRowTap: (p) =>
                  context.push('/user-profiles/${p.userProfileId}?view=true'),
              rowActionsBuilder: (context, p) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: isAdministrator
                    ? () => context.push('/user-profiles/${p.userProfileId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The profile catalog's status facet, rendered inside the filter sheet
/// opened from the Filters button, mirroring `_UserFiltersPanel`.
class _UserProfileFiltersPanel extends ConsumerWidget {
  const _UserProfileFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = UserProfileFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;

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
          filterKey: 'user_profiles_filter_status',
          value: filter.status,
          onChanged: (status) => context.go(
            query
                .withFacet('status', status?.name)
                .copyWith(pageIndex: 0)
                .toUri(_userProfilesPath)
                .toString(),
          ),
        ),
      ],
    );
  }
}
