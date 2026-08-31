import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/facility_child_row.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Spec 035 FR-023/FR-024/FR-025: the facility child rows carry the same
/// hairline outline as the list surfaces, take their radii from the shared
/// shape scale rather than per-widget literals, and stay legible with it.
///
/// The `FacilityCard` itself is a plain `Card`, so its outline comes from
/// `cardTheme` — covered by `component_themes`' own contract rather than
/// re-asserted per widget here.
void main() {
  const warehouse = Warehouse(
    warehouseId: 1,
    facilityId: 1,
    facilityName: 'Main',
    code: 'WH-1',
    name: 'Warehouse One',
    status: EntityStatus.active,
  );

  Future<ThemeData> pumpRow(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appTheme = AppTheme.of(const BrandConfig(displayName: 'Test'));
    final base = brightness == Brightness.light
        ? appTheme.light
        : appTheme.dark;

    late ThemeData resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: base,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => Theme(
          data: DesignTheme.forTier(
            Theme.of(context),
            LayoutBreakpoints.tierOfContext(context),
          ),
          child: Builder(
            builder: (context) {
              resolved = Theme.of(context);
              return child!;
            },
          ),
        ),
        home: Scaffold(
          body: WarehouseChildRow(warehouse: warehouse, onTap: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return resolved;
  }

  /// The row's own `Material` — the one carrying the shape under test, as
  /// opposed to the `Material` `Scaffold`/`MaterialApp` put above it.
  RoundedRectangleBorder shapeOfRow(WidgetTester tester) {
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byKey(const Key('warehouse_row_1')),
            matching: find.byType(Material),
          )
          .first,
    );
    return material.shape! as RoundedRectangleBorder;
  }

  testWidgets('carries a 1px hairline outline in outlineVariant (FR-023)', (
    tester,
  ) async {
    final theme = await pumpRow(tester);

    final side = shapeOfRow(tester).side;
    expect(side.color, theme.colorScheme.outlineVariant);
    expect(side.width, 1);
    expect(side.style, BorderStyle.solid);
  });

  testWidgets('the outline follows the dark scheme too (FR-022)', (
    tester,
  ) async {
    final theme = await pumpRow(tester, brightness: Brightness.dark);

    expect(shapeOfRow(tester).side.color, theme.colorScheme.outlineVariant);
  });

  testWidgets(
    'the corner radius comes from the shared shape scale, not a literal '
    '(FR-024)',
    (tester) async {
      final theme = await pumpRow(tester);

      expect(shapeOfRow(tester).borderRadius, theme.shapes.mdRadius);
    },
  );

  testWidgets(
    'the row stays tappable and its ripple is clipped to the same corners, '
    'so hover/press remain legible against the new outline (FR-025)',
    (tester) async {
      final theme = await pumpRow(tester);

      final ink = tester.widget<InkWell>(
        find.descendant(
          of: find.byKey(const Key('warehouse_row_1')),
          matching: find.byType(InkWell),
        ),
      );
      expect(ink.onTap, isNotNull);
      expect(ink.borderRadius, theme.shapes.mdRadius);
    },
  );
}
