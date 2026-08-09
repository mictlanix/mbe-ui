import 'package:flutter/material.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';

/// Named spacing scale (spec 022 FR-004) plus tier-dependent layout metrics
/// (FR-012), data-model.md §1. Every field is a `const`-constructible number
/// with no [BrandConfig] input — the fixed 8-step scale is identical across
/// every tier, and the 7 layout metrics vary only with [LayoutTier], never
/// with which brand is deployed (FR-010).
@immutable
class Spacing extends ThemeExtension<Spacing> {
  const Spacing({
    this.none = 0,
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 48,
    this.xxxl = 64,
    required this.screenMargin,
    required this.paneGutter,
    required this.cardPadding,
    required this.fieldGapVertical,
    required this.fieldGapHorizontal,
    required this.sectionGap,
    required this.contentMaxWidth,
  });

  // --- fixed 8-step scale — identical at every tier ---------------------
  final double none;
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  // --- tier-dependent layout metrics (data-model.md §1) ------------------

  /// Screen-edge inset.
  final double screenMargin;

  /// Gutter between list and detail panes. `0` at [LayoutTier.compact],
  /// where panes are stacked rather than side by side — never `null`, so
  /// call sites need no null branch (mirrors [contentMaxWidth]'s
  /// `double.infinity` convention).
  final double paneGutter;

  /// Card/panel internal padding.
  final double cardPadding;

  /// Vertical gap between stacked form fields.
  final double fieldGapVertical;

  /// Horizontal gap between fields in a multi-column form grid. `0` at
  /// [LayoutTier.compact], which is single-column.
  final double fieldGapHorizontal;

  /// Gap between logical form/page sections.
  final double sectionGap;

  /// Maximum content width before centering. `double.infinity` where
  /// unbounded (every tier except [LayoutTier.large]).
  final double contentMaxWidth;

  factory Spacing.forTier(LayoutTier tier) {
    return switch (tier) {
      LayoutTier.compact => const Spacing(
        screenMargin: 16,
        paneGutter: 0,
        cardPadding: 16,
        fieldGapVertical: 16,
        fieldGapHorizontal: 0,
        sectionGap: 24,
        contentMaxWidth: double.infinity,
      ),
      LayoutTier.medium => const Spacing(
        screenMargin: 24,
        paneGutter: 24,
        cardPadding: 16,
        fieldGapVertical: 16,
        fieldGapHorizontal: 16,
        sectionGap: 32,
        contentMaxWidth: double.infinity,
      ),
      LayoutTier.expanded => const Spacing(
        screenMargin: 24,
        paneGutter: 24,
        cardPadding: 24,
        fieldGapVertical: 16,
        fieldGapHorizontal: 24,
        sectionGap: 32,
        contentMaxWidth: double.infinity,
      ),
      LayoutTier.large => const Spacing(
        screenMargin: 24,
        paneGutter: 24,
        cardPadding: 24,
        fieldGapVertical: 16,
        fieldGapHorizontal: 24,
        sectionGap: 32,
        contentMaxWidth: 1440,
      ),
    };
  }

  @override
  Spacing copyWith({
    double? none,
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? screenMargin,
    double? paneGutter,
    double? cardPadding,
    double? fieldGapVertical,
    double? fieldGapHorizontal,
    double? sectionGap,
    double? contentMaxWidth,
  }) {
    return Spacing(
      none: none ?? this.none,
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      screenMargin: screenMargin ?? this.screenMargin,
      paneGutter: paneGutter ?? this.paneGutter,
      cardPadding: cardPadding ?? this.cardPadding,
      fieldGapVertical: fieldGapVertical ?? this.fieldGapVertical,
      fieldGapHorizontal: fieldGapHorizontal ?? this.fieldGapHorizontal,
      sectionGap: sectionGap ?? this.sectionGap,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
    );
  }

  @override
  Spacing lerp(Spacing? other, double t) {
    if (other == null) return this;
    double l(double a, double b) => a + (b - a) * t;
    return Spacing(
      none: l(none, other.none),
      xxs: l(xxs, other.xxs),
      xs: l(xs, other.xs),
      sm: l(sm, other.sm),
      md: l(md, other.md),
      lg: l(lg, other.lg),
      xl: l(xl, other.xl),
      xxl: l(xxl, other.xxl),
      xxxl: l(xxxl, other.xxxl),
      screenMargin: l(screenMargin, other.screenMargin),
      paneGutter: l(paneGutter, other.paneGutter),
      cardPadding: l(cardPadding, other.cardPadding),
      fieldGapVertical: l(fieldGapVertical, other.fieldGapVertical),
      fieldGapHorizontal: l(fieldGapHorizontal, other.fieldGapHorizontal),
      sectionGap: l(sectionGap, other.sectionGap),
      contentMaxWidth:
          contentMaxWidth.isInfinite || other.contentMaxWidth.isInfinite
          ? (t < 0.5 ? contentMaxWidth : other.contentMaxWidth)
          : l(contentMaxWidth, other.contentMaxWidth),
    );
  }
}
