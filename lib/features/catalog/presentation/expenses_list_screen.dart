import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/expense.dart';
import 'package:mbe_ui/features/catalog/presentation/expenses_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _expensesPath = '/expenses';

/// Expenses catalog list screen (FR-001, FR-002, US1). Gated by
/// `can(SystemObject.expenses, AccessRight.read)` in the router. Search-only
/// (no filter drawer): the list endpoint exposes no facets beyond `search`
/// (plan.md Constitution Check note on §VI).
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ExpenseFilter.fromQuery(query);
    final pageAsync = ref.watch(expensesListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.expenses, AccessRight.create);
    final canUpdate = access.can(SystemObject.expenses, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('expenses_search_field'),
            label: l10n.expensesSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _expensesPath,
              submitted: value,
              current: filter.search,
              refresh: () =>
                  ref.invalidate(expensesListControllerProvider(filter)),
            ),
          ),
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('new_expense_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.newExpenseTooltip),
                onPressed: () => context.push('/expenses/new'),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<Expense>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noExpensesFound,
            createLabel: canCreate ? l10n.newExpenseTooltip : null,
            onCreate: canCreate ? () => context.push('/expenses/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_expensesPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(expensesListControllerProvider(filter)),
            onData: (page) => DataTableView<Expense>(
              key: const Key('expenses_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.nameLabel,
                  text: (ex) => ex.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.commentLabel,
                  text: (ex) => ex.comment ?? '',
                  size: ColumnSize.L,
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_expensesPath)
                    .toString(),
              ),
              onRowTap: (ex) =>
                  context.push('/expenses/${ex.expenseId}?view=true'),
              rowActionsBuilder: (context, ex) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/expenses/${ex.expenseId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
