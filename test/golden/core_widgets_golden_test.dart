import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/core/navigation/nav_destinations.dart';
import 'package:mbe_ui/core/widgets/app_navigation.dart';
import 'package:mbe_ui/core/widgets/brand_logo.dart';
import 'package:mbe_ui/core/widgets/brand_nav_header.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/label_multi_picker.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/number_pad.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/core/widgets/user_menu_button.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';

import 'golden_harness.dart';

/// Widget files with no `Widget` class of their own, or that cannot be
/// meaningfully constructed in isolation — see `README.md` for the reasoning
/// behind each. This list is the directory-scan test's source of truth: a
/// widget file added to `lib/core/widgets/` in the future and *not* added
/// either here (with justification) or to `_coveredFiles` below fails the
/// scan (`FR-023`).
const _excludedFiles = {
  'money_formatters.dart', // static formatting utility, no Widget class
  'catalog_action_icons.dart', // CatalogRowAction/CatalogAction: data classes
  'catalog_pagination.dart', // CatalogPage<T>: a data class, not a Widget
  'app_shell.dart', // requires a live go_router StatefulNavigationShell
  // spec 035 — pure function, no Widget class of its own; showRecordSheet
  // pins width/confirmDismiss and forwards straight to app_side_sheet.dart's
  // showAppSideSheet (already covered above via catalog_filter_sheet.dart's
  // golden), so it has no visual surface of its own to test.
  'record_sheet.dart',
};

/// Every widget file with real golden coverage below.
const _coveredFiles = {
  'app_navigation.dart',
  'app_side_sheet.dart', // spec 027 R6 — shell extracted from catalog_filter_sheet.dart, covered by its golden below (showCatalogFilterSheet delegates to showAppSideSheet)
  'brand_logo.dart',
  'brand_nav_header.dart',
  'catalog_entity_picker.dart',
  'catalog_filter_bar.dart',
  'catalog_filter_sheet.dart',
  'catalog_search_bar.dart',
  'confirmable_text_field.dart', // spec 031 — extracted from quantity_stepper.dart
  'data_table_view.dart',
  'date_range_filter_chip.dart', // spec 023 T023 — the sales list's date filter
  'entity_status_controls.dart',
  'error_banner.dart',
  'label_multi_picker.dart',
  'list_state_views.dart',
  'number_pad.dart',
  'product_photo.dart',
  'record_form_actions.dart',
  'responsive_form_grid.dart',
  'status_chip.dart', // added in Phase 5 (T026), golden coverage added here (T029)
  'user_menu_button.dart',
};

class _FixtureAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async {
    return const AuthState.authenticated(
      token: 'golden-fixture-token',
      user: User(
        userId: 'u-1',
        email: 'golden.fixture@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        privileges: [],
      ),
    );
  }
}

final _navFixtureOverride = navDestinationsProvider.overrideWithValue([
  NavDestination(
    id: 'home',
    label: (_) => 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    route: '/',
    branchIndex: 0,
  ),
  NavDestination(
    id: 'products',
    label: (_) => 'Products',
    icon: Icons.inventory_2_outlined,
    route: '/products',
    branchIndex: 1,
  ),
]);

void main() {
  setUpAll(loadGoldenFonts);

  test(
    'every widget-bearing file in lib/core/widgets/ has golden coverage or a documented exclusion',
    () {
      final dir = Directory('lib/core/widgets');
      final files = dir
          .listSync()
          .whereType<File>()
          .map((f) => f.path.split(Platform.pathSeparator).last)
          .where((name) => name.endsWith('.dart'))
          .toSet();

      final unaccounted = files
          .difference(_coveredFiles)
          .difference(_excludedFiles);
      expect(
        unaccounted,
        isEmpty,
        reason:
            'New widget file(s) added to lib/core/widgets/ with no golden '
            'coverage and no documented exclusion (FR-023): $unaccounted',
      );

      final coveredButMissing = _coveredFiles.difference(files);
      expect(
        coveredButMissing,
        isEmpty,
        reason: 'Covered file(s) no longer exist: $coveredButMissing',
      );
    },
  );

  group('golden: core widgets', () {
    testWidgets('AppNavigation (rail mode)', (tester) async {
      await expectGoldenMatrix(
        tester,
        'app_navigation',
        (brightness, width) => const AppNavigation(
          mode: AppNavigationMode.rail,
          currentIndex: 0,
          onDestinationSelected: _noopInt,
        ),
        overrides: [_navFixtureOverride],
      );
    });

    testWidgets('BrandLogo (mark)', (tester) async {
      await expectGoldenMatrix(
        tester,
        'brand_logo',
        (brightness, width) =>
            const BrandLogo(style: BrandLogoStyle.mark, height: 34),
      );
    });

    testWidgets('BrandNavHeader', (tester) async {
      await expectGoldenMatrix(
        tester,
        'brand_nav_header',
        (brightness, width) =>
            const SizedBox(width: 240, child: BrandNavHeader()),
      );
    });

    testWidgets('CatalogEntityPicker (read-only)', (tester) async {
      await expectGoldenMatrix(
        tester,
        'catalog_entity_picker',
        (brightness, width) => SizedBox(
          width: 280,
          child: CatalogEntityPicker<String>(
            label: 'Supplier',
            displayStringForOption: (s) => s,
            optionsBuilder: (query) async => const <String>[],
            onSelected: _noopString,
            initialDisplayText: 'Acme Corp',
            enabled: false,
          ),
        ),
      );
    });

    testWidgets('CatalogFilterBar', (tester) async {
      await expectGoldenMatrix(
        tester,
        'catalog_filter_bar',
        (brightness, width) => SizedBox(
          width: width - 32,
          child: CatalogFilterBar(
            search: CatalogSearchBar(label: 'Search', onSubmitted: _noopString),
            filters: const [
              FilterChip(
                label: Text('Active'),
                selected: true,
                onSelected: null,
              ),
            ],
          ),
        ),
      );
    });

    testWidgets('CatalogFilterSheet (via showCatalogFilterSheet)', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        for (final width in [goldenNarrowWidth, goldenWideWidth]) {
          await pumpGoldenScenario(
            tester,
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: 'Filters',
                  clearAllLabel: 'Clear all',
                  applyLabel: 'Apply',
                  builder: (context) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Status: Active'),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
            brightness: brightness,
            width: width,
          );
          // A real tap()-by-offset is flaky here across the width-changing
          // pumpWidget cycles in this loop (observed: 2 of 4 iterations miss
          // the hit test and silently golden the closed state instead of the
          // open sheet). Invoking the button's callback directly is exactly
          // as faithful for this widget -- what's under test is the sheet
          // showCatalogFilterSheet produces, not ElevatedButton's own hit
          // testing -- and removes the flakiness entirely.
          tester
              .widget<ElevatedButton>(find.byType(ElevatedButton))
              .onPressed!();
          await tester.pumpAndSettle();
          final widthLabel = width == goldenNarrowWidth ? 'narrow' : 'wide';
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              'goldens/catalog_filter_sheet_${brightness.name}_$widthLabel.png',
            ),
          );
        }
      }
    });

    testWidgets('CatalogSearchBar', (tester) async {
      await expectGoldenMatrix(
        tester,
        'catalog_search_bar',
        (brightness, width) => SizedBox(
          width: 320,
          child: CatalogSearchBar(
            label: 'Search products',
            onSubmitted: _noopString,
          ),
        ),
      );
    });

    testWidgets('DataTableView', (tester) async {
      await expectGoldenMatrix(
        tester,
        'data_table_view',
        (brightness, width) => SizedBox(
          width: width - 32,
          height: 220,
          child: DataTableView<String>(
            columns: [
              DataTableColumn<String>.text(label: 'Name', text: (s) => s),
              DataTableColumn<String>.text(label: 'SKU', text: (s) => 'SKU-$s'),
            ],
            rows: const ['Widget A', 'Widget B', 'Widget C'],
          ),
        ),
      );
    });

    testWidgets('EntityStatusCell', (tester) async {
      await expectGoldenMatrix(
        tester,
        'entity_status_controls',
        (brightness, width) => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EntityStatusCell(status: EntityStatus.active),
            SizedBox(width: 16),
            EntityStatusCell(status: EntityStatus.inactive),
            SizedBox(width: 16),
            EntityStatusCell(status: EntityStatus.archived),
          ],
        ),
      );
    });

    testWidgets('ErrorBanner', (tester) async {
      await expectGoldenMatrix(
        tester,
        'error_banner',
        (brightness, width) => SizedBox(
          width: width - 32,
          child: const ErrorBanner(error: AppError.network('Connection lost')),
        ),
      );
    });

    testWidgets('LabelMultiPicker', (tester) async {
      await expectGoldenMatrix(
        tester,
        'label_multi_picker',
        (brightness, width) => SizedBox(
          width: width - 32,
          child: LabelMultiPicker(
            labels: const [
              LabelItem(labelId: 1, name: 'Fragile'),
              LabelItem(labelId: 2, name: 'Perishable'),
            ],
            selectedIds: const [1],
            onChanged: _noopIntList,
          ),
        ),
      );
    });

    testWidgets('ListEmptyView', (tester) async {
      await expectGoldenMatrix(
        tester,
        'list_state_views',
        (brightness, width) =>
            const ListEmptyView(message: 'No products found'),
      );
    });

    testWidgets('ConfirmableTextField', (tester) async {
      await expectGoldenMatrix(
        tester,
        'confirmable_text_field',
        (brightness, width) => SizedBox(
          width: 200,
          child: ConfirmableTextField(
            controller: ConfirmableFieldController(
              value: '15',
              parse: (t) => t,
              commit: (_) async => true,
            ),
            decoration: const InputDecoration(labelText: 'Desc. %'),
          ),
        ),
      );
    });

    testWidgets('NumberPad', (tester) async {
      final controller = TextEditingController(text: '12.50');
      await expectGoldenMatrix(
        tester,
        'number_pad',
        (brightness, width) => NumberPad(controller: controller),
      );
    });

    testWidgets('ProductPhoto', (tester) async {
      await expectGoldenMatrix(
        tester,
        'product_photo',
        (brightness, width) => const ProductPhoto(photoUrl: null),
      );
    });

    testWidgets('RecordFormActions', (tester) async {
      await expectGoldenMatrix(
        tester,
        'record_form_actions',
        (brightness, width) => RecordFormActions(
          mode: RecordFormMode.edit,
          saveLabel: 'Save',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
          onSave: _noop,
          onDelete: _noop,
        ),
      );
    });

    testWidgets('ResponsiveFormGrid', (tester) async {
      await expectGoldenMatrix(
        tester,
        'responsive_form_grid',
        (brightness, width) => SizedBox(
          width: width - 32,
          child: ResponsiveFormGrid(
            children: [
              FormGridChild(
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              FormGridChild(
                TextFormField(
                  decoration: const InputDecoration(labelText: 'SKU'),
                ),
              ),
            ],
          ),
        ),
      );
    });

    testWidgets('DateRangeFilterChip (today, no clear affordance)', (tester) async {
      await expectGoldenMatrix(
        tester,
        'date_range_filter_chip_today',
        (brightness, width) => DateRangeFilterChip(
          from: DateTime(2026, 8, 10),
          to: DateTime(2026, 8, 10),
          isToday: true,
          onChanged: (_) {},
          onClear: _noop,
        ),
      );
    });

    testWidgets('DateRangeFilterChip (custom range, clear affordance shown)', (
      tester,
    ) async {
      await expectGoldenMatrix(
        tester,
        'date_range_filter_chip_range',
        (brightness, width) => DateRangeFilterChip(
          from: DateTime(2026, 8, 1),
          to: DateTime(2026, 8, 10),
          isToday: false,
          onChanged: (_) {},
          onClear: _noop,
        ),
      );
    });

    testWidgets('StatusChip', (tester) async {
      await expectGoldenMatrix(
        tester,
        'status_chip',
        (brightness, width) => StatusChip<EntityStatus>(
          value: EntityStatus.inactive,
          label: 'Inactive',
          colors: (scheme) => (scheme.errorContainer, scheme.onErrorContainer),
        ),
      );
    });

    testWidgets('UserMenuButton', (tester) async {
      await expectGoldenMatrix(
        tester,
        'user_menu_button',
        (brightness, width) => const UserMenuButton(),
        overrides: [
          authNotifierProvider.overrideWith(_FixtureAuthNotifier.new),
        ],
      );
    });
  });
}

void _noop() {}
void _noopInt(int _) {}
void _noopString(String _) {}
void _noopIntList(List<int> _) {}
