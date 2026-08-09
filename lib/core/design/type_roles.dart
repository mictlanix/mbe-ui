import 'package:flutter/material.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';

/// The slot → M3 role mapping (spec 022 FR-008), data-model.md §5. 21 named
/// UI slots, each resolved to a ready `TextStyle` for the current
/// [LayoutTier].
///
/// [TypeRoles] is resolved from the app's own [TextTheme] via
/// [TypeRoles.resolve] rather than held as brand-independent literals: the
/// *role assignment* (which M3 role, and how much extra weight emphasis,
/// each slot uses) is identical across every deployment (FR-010) — only the
/// underlying [TextTheme] varies by brand (spec 019's typeface knob), the
/// same "fixed mapping, brand-derived input" pattern [Elevations] uses for
/// color.
///
/// `recordId`/`timestamp` are the two exceptions: they force `RobotoMono`,
/// a fixed bundled utility face used identically by every deployment, never
/// brand-substituted. `productCode` is deliberately **not** monospaced
/// (FR-028, clarified 2026-08-08) — spec 019's typography contract assigned
/// codes/SKUs to RobotoMono, but the product never built that, so this
/// narrows the contract to match reality rather than extending monospacing
/// to ordinary product codes.
@immutable
class TypeRoles extends ThemeExtension<TypeRoles> {
  const TypeRoles({
    required this.screenTitle,
    required this.heroHeading,
    required this.heroSubhead,
    required this.pageHeading,
    required this.sectionHeading,
    required this.cardTitle,
    required this.metricValue,
    required this.metricLabel,
    required this.navLabel,
    required this.navHeader,
    required this.tableHeader,
    required this.tableCell,
    required this.fieldInput,
    required this.fieldLabel,
    required this.chipLabel,
    required this.buttonLabel,
    required this.money,
    required this.recordId,
    required this.timestamp,
    required this.productCode,
    required this.overlayText,
  });

  final TextStyle screenTitle;
  final TextStyle heroHeading;
  final TextStyle heroSubhead;
  final TextStyle pageHeading;
  final TextStyle sectionHeading;
  final TextStyle cardTitle;
  final TextStyle metricValue;
  final TextStyle metricLabel;
  final TextStyle navLabel;
  final TextStyle navHeader;
  final TextStyle tableHeader;
  final TextStyle tableCell;
  final TextStyle fieldInput;
  final TextStyle fieldLabel;
  final TextStyle chipLabel;
  final TextStyle buttonLabel;
  final TextStyle money;

  /// Record identifiers — monospaced (`RobotoMono`).
  final TextStyle recordId;

  /// Timestamps — monospaced (`RobotoMono`).
  final TextStyle timestamp;

  /// Ordinary product codes/SKUs — standard body role, **not** monospaced
  /// (FR-028).
  final TextStyle productCode;

  final TextStyle overlayText;

  static const _mono = 'RobotoMono';

  /// The brand's monospace family name, for the rare case a call site needs
  /// to keep an existing role's size/weight (a small inline badge, a
  /// selectable-token display) but only fix which *font* renders it —
  /// e.g. replacing a hardcoded `fontFamily: 'monospace'` (the generic OS
  /// fallback, not this product's own RobotoMono) with
  /// `.copyWith(fontFamily: TypeRoles.monoFamily)`. Prefer a named slot
  /// ([recordId], [timestamp]) whenever its size/weight already fits.
  static const monoFamily = _mono;

  factory TypeRoles.resolve(TextTheme textTheme, LayoutTier tier) {
    TextStyle role(TextStyle? style) => style ?? const TextStyle();
    TextStyle emphasize(TextStyle? style) =>
        role(style).copyWith(fontWeight: FontWeight.w700);
    TextStyle mono(TextStyle? style) => role(style).copyWith(fontFamily: _mono);
    TextStyle tabular(TextStyle? style) => role(
      style,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

    final isCompact = tier == LayoutTier.compact;
    final isExpandedOrLarge =
        tier == LayoutTier.expanded || tier == LayoutTier.large;

    return TypeRoles(
      screenTitle: role(textTheme.titleLarge),
      heroHeading: isCompact
          ? role(textTheme.headlineMedium)
          : role(textTheme.displaySmall),
      heroSubhead: role(textTheme.bodyLarge),
      pageHeading: isCompact
          ? emphasize(textTheme.headlineSmall)
          : emphasize(textTheme.headlineMedium),
      sectionHeading: isExpandedOrLarge
          ? role(textTheme.titleLarge)
          : role(textTheme.titleMedium),
      cardTitle: role(textTheme.titleMedium),
      metricValue: isCompact
          ? emphasize(textTheme.headlineSmall)
          : emphasize(textTheme.headlineMedium),
      metricLabel: role(textTheme.bodySmall),
      navLabel: role(textTheme.labelLarge),
      navHeader: role(textTheme.titleSmall),
      tableHeader: role(textTheme.labelLarge),
      tableCell: role(textTheme.bodyMedium),
      fieldInput: isExpandedOrLarge
          ? role(textTheme.bodyMedium)
          : role(textTheme.bodyLarge),
      fieldLabel: role(textTheme.bodySmall),
      chipLabel: isExpandedOrLarge
          ? role(textTheme.labelMedium)
          : role(textTheme.labelLarge),
      buttonLabel: role(textTheme.labelLarge),
      money: tabular(textTheme.bodyMedium),
      recordId: mono(textTheme.bodyMedium),
      timestamp: mono(textTheme.bodySmall),
      productCode: role(textTheme.bodyMedium),
      overlayText: isExpandedOrLarge
          ? role(textTheme.bodySmall)
          : role(textTheme.bodyMedium),
    );
  }

  @override
  TypeRoles copyWith({
    TextStyle? screenTitle,
    TextStyle? heroHeading,
    TextStyle? heroSubhead,
    TextStyle? pageHeading,
    TextStyle? sectionHeading,
    TextStyle? cardTitle,
    TextStyle? metricValue,
    TextStyle? metricLabel,
    TextStyle? navLabel,
    TextStyle? navHeader,
    TextStyle? tableHeader,
    TextStyle? tableCell,
    TextStyle? fieldInput,
    TextStyle? fieldLabel,
    TextStyle? chipLabel,
    TextStyle? buttonLabel,
    TextStyle? money,
    TextStyle? recordId,
    TextStyle? timestamp,
    TextStyle? productCode,
    TextStyle? overlayText,
  }) {
    return TypeRoles(
      screenTitle: screenTitle ?? this.screenTitle,
      heroHeading: heroHeading ?? this.heroHeading,
      heroSubhead: heroSubhead ?? this.heroSubhead,
      pageHeading: pageHeading ?? this.pageHeading,
      sectionHeading: sectionHeading ?? this.sectionHeading,
      cardTitle: cardTitle ?? this.cardTitle,
      metricValue: metricValue ?? this.metricValue,
      metricLabel: metricLabel ?? this.metricLabel,
      navLabel: navLabel ?? this.navLabel,
      navHeader: navHeader ?? this.navHeader,
      tableHeader: tableHeader ?? this.tableHeader,
      tableCell: tableCell ?? this.tableCell,
      fieldInput: fieldInput ?? this.fieldInput,
      fieldLabel: fieldLabel ?? this.fieldLabel,
      chipLabel: chipLabel ?? this.chipLabel,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      money: money ?? this.money,
      recordId: recordId ?? this.recordId,
      timestamp: timestamp ?? this.timestamp,
      productCode: productCode ?? this.productCode,
      overlayText: overlayText ?? this.overlayText,
    );
  }

  @override
  TypeRoles lerp(TypeRoles? other, double t) {
    if (other == null) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return TypeRoles(
      screenTitle: l(screenTitle, other.screenTitle),
      heroHeading: l(heroHeading, other.heroHeading),
      heroSubhead: l(heroSubhead, other.heroSubhead),
      pageHeading: l(pageHeading, other.pageHeading),
      sectionHeading: l(sectionHeading, other.sectionHeading),
      cardTitle: l(cardTitle, other.cardTitle),
      metricValue: l(metricValue, other.metricValue),
      metricLabel: l(metricLabel, other.metricLabel),
      navLabel: l(navLabel, other.navLabel),
      navHeader: l(navHeader, other.navHeader),
      tableHeader: l(tableHeader, other.tableHeader),
      tableCell: l(tableCell, other.tableCell),
      fieldInput: l(fieldInput, other.fieldInput),
      fieldLabel: l(fieldLabel, other.fieldLabel),
      chipLabel: l(chipLabel, other.chipLabel),
      buttonLabel: l(buttonLabel, other.buttonLabel),
      money: l(money, other.money),
      recordId: l(recordId, other.recordId),
      timestamp: l(timestamp, other.timestamp),
      productCode: l(productCode, other.productCode),
      overlayText: l(overlayText, other.overlayText),
    );
  }
}
