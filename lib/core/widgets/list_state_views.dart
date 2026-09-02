import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Renders a catalog list's four states — loading, empty, filtered-empty,
/// failed — identically across every list screen
/// (017-ui-consistency-filters US5, contracts/list-state-views.md §1–§3).
/// Replaces the ad-hoc `AsyncValue.when(...)` + `page.items.isEmpty ? ... :
/// ...` rendering previously repeated in all 18 catalog list screens plus
/// the pricing screen.
///
/// [isFiltered] — normally a route's `ListQuery.isFiltered` — is what
/// distinguishes `empty` from `filteredEmpty` (FR-028), not item count
/// alone. [createLabel]/[onCreate] are both required together to show the
/// "create the first record" affordance in the plain `empty` state; either
/// left `null` omits it (FR-029 — absent, not disabled, without the create
/// privilege).
class CatalogListStateView<T> extends StatelessWidget {
  const CatalogListStateView({
    super.key,
    required this.state,
    required this.isFiltered,
    required this.onData,
    required this.emptyMessage,
    this.createLabel,
    this.onCreate,
    required this.clearFiltersLabel,
    required this.onClearFilters,
    required this.retryLabel,
    required this.onRetry,
  });

  final AsyncValue<CatalogPage<T>> state;
  final bool isFiltered;
  final Widget Function(CatalogPage<T> page) onData;
  final String emptyMessage;
  final String? createLabel;
  final VoidCallback? onCreate;
  final String clearFiltersLabel;
  final VoidCallback onClearFilters;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final page = state.valueOrNull;
    if (page == null && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasError) {
      return ListFailedView(
        error: toAppError(state.error),
        retryLabel: retryLabel,
        onRetry: onRetry,
      );
    }
    if (page == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (page.items.isEmpty) {
      return isFiltered
          ? _FilteredEmptyListView(
              clearFiltersLabel: clearFiltersLabel,
              onClearFilters: onClearFilters,
            )
          : ListEmptyView(
              message: emptyMessage,
              createLabel: createLabel,
              onCreate: onCreate,
            );
    }
    // `state.isLoading` here means a background refresh is in flight while
    // data from a previous fetch is still shown (Riverpod's own
    // `copyWithPrevious` — an invalidated provider transitions to
    // `AsyncData(isLoading: true)`, not `AsyncLoading`, precisely so the
    // list is never blanked/replaced by a spinner here). This is the
    // visible confirmation that a refresh actually happened — e.g. pressing
    // the search button on an unchanged term (spec 035 FR-008) — without
    // disturbing the content, scroll position, or page below it. Reuses the
    // exact same bare `CircularProgressIndicator()` this file already shows
    // for the first-load/pagination-change case above (line 52/62), not a
    // custom size/stroke, so every loading affordance in this component
    // looks identical.
    if (state.isLoading) {
      return Column(
        children: [
          const SizedBox(
            height: 56,
            child: Center(
              key: Key('list_state_refreshing'),
              child: CircularProgressIndicator(),
            ),
          ),
          Expanded(child: onData(page)),
        ],
      );
    }
    return onData(page);
  }
}

/// Maps an arbitrary thrown [error] to the [AppError] `ErrorBanner` expects,
/// degrading anything unmapped to a generic [ServerError] rather than
/// surfacing it raw (FR-031). Repositories already throw [AppError]
/// subtypes, so this is only a safety net for the unexpected case.
AppError toAppError(Object? error) =>
    error is AppError ? error : const AppError.server();

/// The plain (non-filtered) `empty` state shared by every list screen
/// (017-ui-consistency-filters US5). Exposed publicly — not just used by
/// [CatalogListStateView] — so `pricing_screen.dart` can render the same
/// treatment for its "no price lists" state despite not being a paginated
/// catalog list (contracts/list-state-views.md §4).
class ListEmptyView extends StatelessWidget {
  const ListEmptyView({
    super.key,
    required this.message,
    this.createLabel,
    this.onCreate,
  });

  final String message;
  final String? createLabel;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        key: const Key('list_state_empty'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.bodyLarge),
          if (createLabel != null && onCreate != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('list_state_empty_create_button'),
              onPressed: onCreate,
              child: Text(createLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilteredEmptyListView extends StatelessWidget {
  const _FilteredEmptyListView({
    required this.clearFiltersLabel,
    required this.onClearFilters,
  });

  final String clearFiltersLabel;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        key: const Key('list_state_filtered_empty'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(l10n.filteredEmptyTitle, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(
            l10n.filteredEmptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            key: const Key('list_state_clear_filters_button'),
            onPressed: onClearFilters,
            child: Text(clearFiltersLabel),
          ),
        ],
      ),
    );
  }
}

/// The `failed` state shared by every list screen (017-ui-consistency-filters
/// US5). Exposed publicly — not just used by [CatalogListStateView] — so
/// `pricing_screen.dart` can render the same treatment despite not being a
/// paginated catalog list (contracts/list-state-views.md §4).
class ListFailedView extends StatelessWidget {
  const ListFailedView({
    super.key,
    required this.error,
    required this.retryLabel,
    required this.onRetry,
  });

  final AppError error;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          key: const Key('list_state_failed'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.loadErrorTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ErrorBanner(error: error),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('list_state_retry_button'),
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
