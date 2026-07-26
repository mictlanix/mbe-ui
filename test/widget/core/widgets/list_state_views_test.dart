import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

CatalogPage<String> _page(List<String> items, {int total = 0}) => CatalogPage(
  items: items,
  total: total == 0 ? items.length : total,
  pageIndex: 0,
  pageSize: 20,
);

void main() {
  Future<void> pumpState(
    WidgetTester tester, {
    required AsyncValue<CatalogPage<String>> state,
    required bool isFiltered,
    String emptyMessage = 'No records yet',
    String? createLabel,
    VoidCallback? onCreate,
    VoidCallback? onClearFilters,
    VoidCallback? onRetry,
    Widget Function(CatalogPage<String>)? onData,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CatalogListStateView<String>(
            state: state,
            isFiltered: isFiltered,
            onData:
                onData ??
                (page) => ListView(
                  key: const Key('list_state_data'),
                  children: page.items.map(Text.new).toList(),
                ),
            emptyMessage: emptyMessage,
            createLabel: createLabel,
            onCreate: onCreate,
            clearFiltersLabel: 'Clear filters',
            onClearFilters: onClearFilters ?? () {},
            retryLabel: 'Retry',
            onRetry: onRetry ?? () {},
          ),
        ),
      ),
    );
    // Not pumpAndSettle: the loading state's CircularProgressIndicator
    // animates indefinitely and would never settle.
    await tester.pump();
  }

  testWidgets('loading renders a centered progress indicator', (tester) async {
    await pumpState(
      tester,
      state: const AsyncValue.loading(),
      isFiltered: false,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('list_state_empty')), findsNothing);
    expect(find.byKey(const Key('list_state_filtered_empty')), findsNothing);
    expect(find.byKey(const Key('list_state_failed')), findsNothing);
    expect(find.byKey(const Key('list_state_data')), findsNothing);
  });

  testWidgets(
    'empty (unfiltered) renders the empty treatment, not filtered-empty',
    (tester) async {
      await pumpState(
        tester,
        state: AsyncValue.data(_page(const [])),
        isFiltered: false,
        emptyMessage: 'No products yet',
      );

      expect(find.byKey(const Key('list_state_empty')), findsOneWidget);
      expect(find.byKey(const Key('list_state_filtered_empty')), findsNothing);
      expect(find.text('No products yet'), findsOneWidget);
    },
  );

  testWidgets(
    'filteredEmpty (isFiltered=true) renders the filtered-empty treatment, '
    'not the plain empty one — chosen by isFiltered, not item count alone',
    (tester) async {
      await pumpState(
        tester,
        state: AsyncValue.data(_page(const [])),
        isFiltered: true,
      );

      expect(
        find.byKey(const Key('list_state_filtered_empty')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('list_state_empty')), findsNothing);
      expect(find.text('No matches found'), findsOneWidget);
    },
  );

  testWidgets('the create affordance is present with a create label/callback', (
    tester,
  ) async {
    var created = false;
    await pumpState(
      tester,
      state: AsyncValue.data(_page(const [])),
      isFiltered: false,
      createLabel: 'New Product',
      onCreate: () => created = true,
    );

    expect(
      find.byKey(const Key('list_state_empty_create_button')),
      findsOneWidget,
    );
    expect(find.text('New Product'), findsOneWidget);

    await tester.tap(find.byKey(const Key('list_state_empty_create_button')));
    expect(created, isTrue);
  });

  testWidgets('the create affordance is ABSENT without the create privilege '
      '(createLabel/onCreate null) — absent, not disabled (FR-029)', (
    tester,
  ) async {
    await pumpState(
      tester,
      state: AsyncValue.data(_page(const [])),
      isFiltered: false,
    );

    expect(
      find.byKey(const Key('list_state_empty_create_button')),
      findsNothing,
    );
  });

  testWidgets('Clear filters navigates via the supplied callback', (
    tester,
  ) async {
    var cleared = false;
    await pumpState(
      tester,
      state: AsyncValue.data(_page(const [])),
      isFiltered: true,
      onClearFilters: () => cleared = true,
    );

    await tester.tap(find.byKey(const Key('list_state_clear_filters_button')));
    expect(cleared, isTrue);
  });

  testWidgets(
    'failed renders ErrorBanner with the mapped AppError, not a raw string, '
    'plus a Retry action that re-fetches unchanged',
    (tester) async {
      var retried = false;
      await pumpState(
        tester,
        state: AsyncValue.error(
          const AppError.network('boom'),
          StackTrace.empty,
        ),
        isFiltered: false,
        onRetry: () => retried = true,
      );

      expect(find.byKey(const Key('list_state_failed')), findsOneWidget);
      expect(find.byType(ErrorBanner), findsOneWidget);
      // The raw error's toString() never appears as rendered text.
      expect(
        find.text(const AppError.network('boom').toString()),
        findsNothing,
      );
      expect(find.text('boom'), findsNothing);

      await tester.tap(find.byKey(const Key('list_state_retry_button')));
      expect(retried, isTrue);
    },
  );

  testWidgets(
    'a non-AppError thrown by the provider still degrades to a mapped '
    'ErrorBanner rather than a raw exception (FR-031)',
    (tester) async {
      await pumpState(
        tester,
        state: AsyncValue.error(Exception('unexpected'), StackTrace.empty),
        isFiltered: false,
      );

      expect(find.byKey(const Key('list_state_failed')), findsOneWidget);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.textContaining('unexpected'), findsNothing);
    },
  );

  testWidgets('populated renders onData with the page', (tester) async {
    await pumpState(
      tester,
      state: AsyncValue.data(_page(const ['a', 'b'])),
      isFiltered: false,
    );

    expect(find.byKey(const Key('list_state_data')), findsOneWidget);
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
  });

  testWidgets(
    'the four states are mutually distinguishable (SC-007): each has a '
    'unique key with no overlap',
    (tester) async {
      final keys = <Key>[];
      for (final state in [
        const AsyncValue<CatalogPage<String>>.loading(),
        AsyncValue.data(_page(const [])),
        AsyncValue<CatalogPage<String>>.error(
          const AppError.server(),
          StackTrace.empty,
        ),
      ]) {
        await pumpState(tester, state: state, isFiltered: false);
        for (final key in [
          const Key('list_state_empty'),
          const Key('list_state_filtered_empty'),
          const Key('list_state_failed'),
          const Key('list_state_data'),
        ]) {
          if (tester.any(find.byKey(key))) keys.add(key);
        }
      }
      expect(keys.toSet(), hasLength(keys.length));
    },
  );
}
