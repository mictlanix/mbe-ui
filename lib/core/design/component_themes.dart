import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/density.dart';
import 'package:mbe_ui/core/design/elevations.dart';
import 'package:mbe_ui/core/design/shapes.dart';
import 'package:mbe_ui/core/design/spacing.dart';
import 'package:mbe_ui/core/design/type_roles.dart';

/// The 20 Material 3 component sub-themes (spec 022 FR-015/016), assembled
/// from the tier/platform-resolved product tokens plus the brand-resolved
/// [ColorScheme]. Applied once, centrally, here — never restated per screen
/// (FR-017). See `contracts/design-tokens.md` for the full ownership table.
///
/// Lives beside [DesignTheme.forTier] (not [AppTheme._buildTheme]) because
/// most of these read [Spacing]/[Shapes]/[Density]/[TypeRoles], which are
/// only resolved once the width tier is known — `AppTheme.of` runs before
/// that, so it cannot supply them.
ThemeData applyComponentThemes(
  ThemeData base, {
  required ColorScheme scheme,
  required Spacing spacing,
  required Shapes shapes,
  required Elevations elevations,
  required Density density,
  required TypeRoles typeRoles,
}) {
  return base.copyWith(
    // --- AppBarTheme, CardThemeData, InputDecorationTheme, ChipThemeData
    appBarTheme: AppBarTheme(
      titleTextStyle: typeRoles.screenTitle,
      centerTitle: false,
      scrolledUnderElevation: elevations.floating.shadowDp,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
    ),
    cardTheme: CardThemeData(
      color: elevations.raised.surfaceColor,
      elevation: elevations.raised.shadowDp,
      // spacing.cardPadding (16/16/24/24 across tiers), not the fixed
      // spacing.sm -- Card has no internal-padding field of its own, so the
      // tier-dependent metric is expressed as margin instead. Using the
      // fixed sm here was a real bug: it made cardPadding a dead token that
      // nothing actually consumed, silently defeating FR-013's "shared
      // controls visibly adapt" claim for every Card-bearing screen.
      margin: EdgeInsets.all(spacing.cardPadding),
      // A hairline outline (spec 035 FR-019/FR-023), same colour/width as
      // dividerTheme and dataTableTheme's own dividerThickness below --
      // one outline definition for every card-based surface, including
      // DataTableView's table card and FacilityCard.
      shape: RoundedRectangleBorder(
        borderRadius: shapes.lgRadius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      // Card defaults to Clip.none, so a child that paints to its own edges
      // (e.g. DataTableView's heading row fill) squares off this shape's
      // rounded corners instead of being clipped to them (spec 035
      // FR-017/FR-018/FR-020) -- this is the one line that fixes every
      // table's square-top-corners bug, and every other Card at once.
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      isDense: density.inputIsDense,
      labelStyle: typeRoles.fieldLabel,
      helperStyle: typeRoles.fieldLabel,
      errorStyle: typeRoles.fieldLabel.copyWith(color: scheme.error),
      border: OutlineInputBorder(
        borderRadius: shapes.xsRadius,
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: shapes.xsRadius,
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: shapes.xsRadius,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: shapes.xsRadius,
        borderSide: BorderSide(color: scheme.error),
      ),
    ),
    chipTheme: ChipThemeData(
      labelStyle: typeRoles.chipLabel,
      // shapes.sm (8dp) -- matches Flutter's own M3 ChipThemeData default
      // (verified in the SDK source: _ChipDefaultsM3 uses circular(8.0)),
      // not the stadium shape buttons/nav indicators use.
      shape: RoundedRectangleBorder(
        borderRadius: shapes.smRadius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      side: BorderSide(color: scheme.outlineVariant),
      padding: EdgeInsets.symmetric(horizontal: spacing.xs),
    ),

    // --- DataTableThemeData, DividerThemeData, DialogThemeData
    dataTableTheme: DataTableThemeData(
      headingTextStyle: typeRoles.tableHeader,
      dataTextStyle: typeRoles.tableCell,
      headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainer),
      dividerThickness: 1,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: spacing.md,
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: shapes.xlRadius),
      titleTextStyle: typeRoles.sectionHeading,
      backgroundColor: elevations.modal.surfaceColor,
      elevation: elevations.modal.shadowDp,
    ),

    // --- NavigationRailThemeData, NavigationDrawerThemeData
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorShape: Shapes.full,
      indicatorColor: scheme.secondaryContainer,
      // Weight carries the selected/unselected distinction (matches the
      // original hand-rolled style this sub-theme replaces) -- color alone
      // isn't enough contrast between the two states.
      selectedLabelTextStyle: typeRoles.navLabel.copyWith(
        color: scheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: typeRoles.navLabel.copyWith(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: scheme.surface,
      indicatorShape: Shapes.full,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return typeRoles.navLabel.copyWith(
          color: selected
              ? scheme.onSecondaryContainer
              : scheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        );
      }),
    ),

    // --- Filled/Outlined/TextButtonTheme, ListTileThemeData,
    //     SegmentedButtonThemeData
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: typeRoles.buttonLabel,
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.sm,
        ),
        visualDensity: density.visualDensity,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: typeRoles.buttonLabel,
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.sm,
        ),
        visualDensity: density.visualDensity,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: typeRoles.buttonLabel,
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        visualDensity: density.visualDensity,
      ),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: typeRoles.cardTitle,
      subtitleTextStyle: typeRoles.overlayText,
      minVerticalPadding: spacing.sm,
      visualDensity: density.visualDensity,
      minLeadingWidth: spacing.lg,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        textStyle: typeRoles.buttonLabel,
        visualDensity: density.visualDensity,
        shape: const StadiumBorder(),
      ),
    ),

    // --- BottomSheetThemeData, SnackBar/Tooltip/PopupMenu/Switch/
    //     ProgressIndicatorThemeData
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: elevations.modal.surfaceColor,
      elevation: elevations.modal.shadowDp,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(shapes.xl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: typeRoles.overlayText.copyWith(
        color: scheme.onInverseSurface,
      ),
      backgroundColor: scheme.inverseSurface,
      shape: RoundedRectangleBorder(borderRadius: shapes.xsRadius),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: typeRoles.overlayText.copyWith(color: scheme.onInverseSurface),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: shapes.xsRadius,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      textStyle: typeRoles.tableCell,
      color: elevations.floating.surfaceColor,
      elevation: elevations.floating.shadowDp,
      shape: RoundedRectangleBorder(borderRadius: shapes.smRadius),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      circularTrackColor: scheme.surfaceContainerHighest,
    ),
  );
}
