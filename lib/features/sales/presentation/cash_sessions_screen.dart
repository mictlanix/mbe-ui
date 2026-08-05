import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/presentation/cash_sessions_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/open_session_form_controller.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/cash_session_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _cashSessionsPath = '/sales/cash-sessions';

/// The shift panel + history list screen (contracts/cash-session-screens.md
/// §1). Shift panel (US1) stacked above the history list (US3), in one
/// scroll view — not a filter bar `search:` slot, since the endpoint has no
/// `search` parameter and a session has no free-text field (research.md §12,
/// spec D-003); the slot renders an empty [SizedBox], a deliberate,
/// documented departure from every other list screen.
class CashSessionsScreen extends ConsumerWidget {
  const CashSessionsScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShiftPanel(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _HistoryListSection(query: query),
        ],
      ),
    );
  }
}

class _ShiftPanel extends ConsumerWidget {
  const _ShiftPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAsync = ref.watch(currentSessionControllerProvider);

    return currentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorBanner(error: toAppError(error)),
      data: (current) => switch (current.state) {
        SessionState.none => const _OpenForm(),
        SessionState.open => _OpenShiftCard(session: current.session!, stale: false),
        SessionState.stale => _OpenShiftCard(session: current.session!, stale: true),
      },
    );
  }
}

class _OpenForm extends ConsumerWidget {
  const _OpenForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final authState = ref.watch(authNotifierProvider).valueOrNull;
    final settings = authState is AuthAuthenticated ? authState.user.settings : null;
    final formState = ref.watch(openSessionFormControllerProvider);
    final controller = ref.read(openSessionFormControllerProvider.notifier);

    final canOpen = access.can(SystemObject.pos, AccessRight.create);
    final canBrowseDrawers = access.can(SystemObject.cashDrawers, AccessRight.read);
    final hasAssignedDrawer = settings?.cashDrawerId != null;

    // Seeded here, not from the screen's initState: `openSessionFormControllerProvider`
    // is autoDispose, so seeding it before anything watches it (e.g. from a
    // StatefulWidget's initState, before this widget has even built once) risks
    // the seeded state being disposed — zero listeners — before this widget
    // ever sees it. Seeding from inside the very build() that watches the
    // provider means the provider is guaranteed alive for at least this
    // frame. Guarded by `cashDrawerId == null` so it never re-fires once
    // seeded or once the cashier has made their own pick.
    if (formState.cashDrawerId == null && settings?.cashDrawerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.seedAssignedDrawer(settings?.cashDrawerId, settings?.cashDrawerName);
      });
    }

    if (!canOpen) {
      return Text(l10n.cashSessionNoOpenSessionMessage);
    }

    if (!canBrowseDrawers && !hasAssignedDrawer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cashSessionNoOpenSessionMessage),
          const SizedBox(height: 8),
          Text(
            l10n.cashSessionDrawerBlockedMessage,
            key: const Key('cash_session_drawer_blocked_message'),
          ),
        ],
      );
    }

    final drawerField = canBrowseDrawers
        ? CatalogEntityPicker<CashDrawer>(
            key: const Key('cash_session_drawer_field'),
            label: l10n.cashSessionDrawerFieldLabel,
            displayStringForOption: (d) => d.name,
            optionsBuilder: (query) async {
              final result = await ref
                  .read(cashDrawerRepositoryProvider)
                  .list(search: query.isEmpty ? null : query);
              return result.items;
            },
            onSelected: (d) => controller.drawerSelected(d.cashDrawerId, d.name),
            initialDisplayText: formState.cashDrawerDisplayText,
            enabled: !formState.submitting,
          )
        : KeyedSubtree(
            key: const Key('cash_session_drawer_static_label'),
            // `TextFormField.initialValue` only ever seeds on first mount
            // (the same Flutter behavior `CatalogEntityPicker` documents and
            // works around) — the assigned drawer's name arrives
            // asynchronously via `seedAssignedDrawer`, after this field has
            // already mounted with an empty value. Keying by the value being
            // displayed forces a remount, and therefore a re-seed, the
            // moment it arrives.
            child: TextFormField(
              key: ValueKey('cash_session_drawer_static_label-${formState.cashDrawerDisplayText}'),
              initialValue: formState.cashDrawerDisplayText,
              decoration: InputDecoration(labelText: l10n.cashSessionDrawerFieldLabel),
              enabled: false,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cashSessionNoOpenSessionMessage),
        const SizedBox(height: 16),
        if (formState.error != null) ...[
          ErrorBanner(
            error: AppError.validation([
              FieldError(loc: const [], msg: _localizeOpenFormError(l10n, formState.error!), type: 'error'),
              if (formState.errorDetail != null)
                FieldError(loc: const [], msg: formState.errorDetail!, type: 'error'),
            ]),
          ),
          if (formState.blockingSessionId != null)
            TextButton(
              key: const Key('cash_session_go_close_blocking_session_button'),
              onPressed: () => context.push(
                '$_cashSessionsPath/${formState.blockingSessionId}',
              ),
              child: Text(l10n.cashSessionCloseButtonLabel),
            ),
          const SizedBox(height: 8),
        ],
        drawerField,
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('cash_session_opening_amount_field'),
          initialValue: formState.openingAmount,
          decoration: InputDecoration(
            labelText: l10n.cashSessionOpeningAmountFieldLabel,
            errorText: formState.fieldErrors['openingAmount'],
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: !formState.submitting,
          onChanged: controller.openingAmountChanged,
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('cash_session_open_button'),
          onPressed: formState.submitting ? null : controller.submit,
          child: Text(l10n.cashSessionOpenButtonLabel),
        ),
      ],
    );
  }
}

class _OpenShiftCard extends ConsumerWidget {
  const _OpenShiftCard({required this.session, required this.stale});

  final CashSession session;
  final bool stale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final hasOtherOpenSessions = ref.watch(hasOtherOpenSessionsProvider).valueOrNull ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(session.cashDrawerName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            CashSessionStatusChip(status: stale ? CashSessionStatus.stale : CashSessionStatus.open),
          ],
        ),
        if (stale) ...[
          const SizedBox(height: 8),
          Text(l10n.cashSessionStaleWarningMessage),
        ],
        const SizedBox(height: 8),
        Text('${l10n.cashSessionStartFieldLabel}: ${MoneyFormatters.dateTime(session.start, locale: locale)}'),
        Text(
          '${l10n.cashSessionOpeningAmountFieldLabel}: '
          '${MoneyFormatters.currency(session.openingAmount, locale: locale)}',
        ),
        const SizedBox(height: 8),
        Text(l10n.cashSessionPaymentsByMethodLabel, style: Theme.of(context).textTheme.titleSmall),
        for (final total in session.paymentsByMethod)
          Text(
            '${paymentMethodLabel(l10n, total.method)}: '
            '${MoneyFormatters.currency(total.total, locale: locale)}',
          ),
        // FR-004: `hasOtherOpenSessionsProvider` is a direct, exact query
        // (cashier + status=open), not an approximation — but it can only
        // ever say "yes" or "no more found yet" while loading, so absence
        // here is intentionally not asserted as "no others exist" (research
        // §17). A `false` value covers both "checked, none found" and
        // "still loading" — the note simply doesn't show for either.
        if (hasOtherOpenSessions) ...[
          const SizedBox(height: 8),
          Text(
            l10n.cashSessionOtherSessionsWarningMessage,
            key: const Key('cash_session_other_sessions_warning'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('cash_session_close_button'),
          onPressed: () =>
              context.push('$_cashSessionsPath/${session.cashSessionId}'),
          child: Text(l10n.cashSessionCloseButtonLabel),
        ),
      ],
    );
  }
}

class _HistoryListSection extends ConsumerWidget {
  const _HistoryListSection({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = CashSessionFilter.fromQuery(query);
    final pageAsync = ref.watch(cashSessionsListControllerProvider(filter));
    final locale = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogFilterBar(
          // No `search:` capability exists for this endpoint (research.md
          // §12) — the slot is required by the widget, so it renders empty
          // rather than a dead search box wired to nothing.
          search: const SizedBox.shrink(),
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.hasActiveFilters,
              child: IconButton.outlined(
                key: const Key('cash_sessions_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(_cashSessionsPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _CashSessionFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 480,
          child: CatalogListStateView<CashSession>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.cashSessionsListEmptyMessage,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_cashSessionsPath),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(cashSessionsListControllerProvider(filter)),
            onData: (page) => DataTableView<CashSession>(
              key: const Key('cash_sessions_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.cashSessionColumnDrawer,
                  text: (s) => s.cashDrawerName,
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.cashSessionColumnCashier,
                  text: (s) => s.cashierName,
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.cashSessionColumnStart,
                  size: ColumnSize.M,
                  cellBuilder: (context, s) =>
                      Text(MoneyFormatters.dateTime(s.start, locale: locale)),
                ),
                DataTableColumn(
                  label: l10n.cashSessionColumnEnd,
                  size: ColumnSize.M,
                  cellBuilder: (context, s) => Text(
                    s.end == null ? '—' : MoneyFormatters.dateTime(s.end!, locale: locale),
                  ),
                ),
                DataTableColumn(
                  label: l10n.cashSessionColumnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, s) => CashSessionStatusChip(
                    status: cashSessionStatusOf(s, today: DateTime.now()),
                  ),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query.copyWith(pageIndex: pageIndex).toUri(_cashSessionsPath).toString(),
              ),
              // No row action icons — a session is never edited or deleted;
              // the row itself is the only affordance (FR-030).
              onRowTap: (s) => context.push('$_cashSessionsPath/${s.cashSessionId}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The history list's three facets (data-model.md §9, research.md §17):
/// cash drawer, cashier, and status. No date-range facet — nothing in this
/// feature requires one, despite the endpoint supporting it.
class _CashSessionFiltersPanel extends ConsumerWidget {
  const _CashSessionFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = CashSessionFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final cashDrawerRepo = ref.read(cashDrawerRepositoryProvider);
    final employeeRepo = ref.read(employeeRepositoryProvider);

    final resolvedDrawerName = filter.cashDrawerId != null
        ? ref.watch(cashDrawerDisplayNameProvider(filter.cashDrawerId!)).valueOrNull
        : null;
    final resolvedCashierName = filter.cashierId != null
        ? ref.watch(employeeDisplayNameProvider(filter.cashierId!)).valueOrNull
        : null;

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_cashSessionsPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<CashDrawer>(
          key: const Key('cash_sessions_filter_drawer'),
          label: l10n.cashSessionsFilterDrawerLabel,
          displayStringForOption: (d) => d.name,
          optionsBuilder: (searchQuery) async {
            final result = await cashDrawerRepo.list(
              search: searchQuery.isEmpty ? null : searchQuery,
            );
            return result.items;
          },
          onSelected: (d) => goTo(
            query.withFacet('cash-drawer', '${d.cashDrawerId}').copyWith(pageIndex: 0),
          ),
          initialDisplayText: resolvedDrawerName ?? filter.cashDrawerId?.toString(),
        ),
        const SizedBox(height: 12),
        CatalogEntityPicker<EmployeeListItem>(
          key: const Key('cash_sessions_filter_cashier'),
          label: l10n.cashSessionsFilterCashierLabel,
          displayStringForOption: (e) => e.fullName,
          optionsBuilder: (searchQuery) async {
            final result = await employeeRepo.list(
              search: searchQuery.isEmpty ? null : searchQuery,
            );
            return result.items;
          },
          onSelected: (e) => goTo(
            query.withFacet('cashier', '${e.employeeId}').copyWith(pageIndex: 0),
          ),
          initialDisplayText: resolvedCashierName ?? filter.cashierId?.toString(),
        ),
        const SizedBox(height: 12),
        Text(l10n.cashSessionsFilterStatusLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const Key('cash_sessions_filter_status_all'),
              label: Text(l10n.statusFilterAll),
              selected: filter.status == null,
              onSelected: (_) => goTo(query.withFacet('status', null).copyWith(pageIndex: 0)),
            ),
            for (final status in CashSessionStatus.values)
              ChoiceChip(
                key: Key('cash_sessions_filter_status_${status.name}'),
                label: Text(cashSessionStatusLabel(l10n, status)),
                selected: filter.status == status,
                onSelected: (_) =>
                    goTo(query.withFacet('status', status.name).copyWith(pageIndex: 0)),
              ),
          ],
        ),
      ],
    );
  }
}

String _localizeOpenFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case OpenSessionFormErrorCode.drawerBusy:
      return l10n.cashSessionDrawerBusyError;
    case OpenSessionFormErrorCode.cashierBusy:
      return l10n.cashSessionCashierBusyError;
    case OpenSessionFormErrorCode.drawerNotFound:
      return l10n.cashSessionDrawerBlockedMessage;
    case OpenSessionFormErrorCode.noDrawerConfigured:
      return l10n.cashSessionDrawerBlockedMessage;
    case OpenSessionFormErrorCode.openPermissionDenied:
      return l10n.cashSessionOpenPermissionDeniedError;
    case OpenSessionFormErrorCode.openFailed:
      return l10n.cashSessionOpenFailedError;
    default:
      return code;
  }
}
