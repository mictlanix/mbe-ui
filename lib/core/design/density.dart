import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

/// Named density and minimum-interactive-target settings (spec 022 FR-007),
/// data-model.md §4. Keyed on **input modality** (touch platform vs.
/// pointer platform), not on display width — a wide Android/iOS tablet gets
/// touch metrics regardless of how much screen space it has, and a narrow
/// desktop window still gets pointer metrics (research R2). This corrects
/// the spec's own Assumptions, which named `MediaQuery.navigationModeOf` as
/// the signal; that API actually reports keyboard-traversal mode
/// (`traditional`/`directional`), not touch-vs-pointer.
@immutable
class Density extends ThemeExtension<Density> {
  const Density({
    required this.visualDensity,
    required this.minTargetSize,
    required this.tableHeadingRowHeight,
    required this.tableDataRowHeight,
    required this.listRowMinHeight,
    required this.iconButtonSize,
    required this.inputIsDense,
  });

  final VisualDensity visualDensity;
  final double minTargetSize;

  /// `null` on touch platforms — table screens render as card lists there
  /// (out of scope for this feature, FR-025), so no row height applies.
  final double? tableHeadingRowHeight;
  final double? tableDataRowHeight;

  final double listRowMinHeight;
  final double iconButtonSize;
  final bool inputIsDense;

  static const _touch = Density(
    visualDensity: VisualDensity.standard,
    minTargetSize: 48,
    tableHeadingRowHeight: null,
    tableDataRowHeight: null,
    listRowMinHeight: 56,
    iconButtonSize: 48,
    inputIsDense: false,
  );

  static const _pointer = Density(
    visualDensity: VisualDensity.compact,
    minTargetSize: 40,
    tableHeadingRowHeight: 48,
    tableDataRowHeight: 44,
    listRowMinHeight: 48,
    iconButtonSize: 40,
    inputIsDense: true,
  );

  static const _touchPlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.fuchsia,
  };

  /// Pure, testable core — mirrors
  /// `VisualDensity.defaultDensityForPlatform`'s own touch/pointer split.
  factory Density.forPlatform(TargetPlatform platform) {
    return _touchPlatforms.contains(platform) ? _touch : _pointer;
  }

  /// Convenience wrapper reading the ambient [defaultTargetPlatform] (which,
  /// on web, reports the host platform — so a mobile browser gets touch
  /// metrics and a desktop browser gets pointer metrics).
  factory Density.resolve() => Density.forPlatform(defaultTargetPlatform);

  @override
  Density copyWith({
    VisualDensity? visualDensity,
    double? minTargetSize,
    double? tableHeadingRowHeight,
    double? tableDataRowHeight,
    double? listRowMinHeight,
    double? iconButtonSize,
    bool? inputIsDense,
  }) {
    return Density(
      visualDensity: visualDensity ?? this.visualDensity,
      minTargetSize: minTargetSize ?? this.minTargetSize,
      tableHeadingRowHeight:
          tableHeadingRowHeight ?? this.tableHeadingRowHeight,
      tableDataRowHeight: tableDataRowHeight ?? this.tableDataRowHeight,
      listRowMinHeight: listRowMinHeight ?? this.listRowMinHeight,
      iconButtonSize: iconButtonSize ?? this.iconButtonSize,
      inputIsDense: inputIsDense ?? this.inputIsDense,
    );
  }

  @override
  Density lerp(Density? other, double t) {
    // Density is a discrete platform choice, not a tier-animated value —
    // there is no meaningful mid-lerp density. Snap at the midpoint, same
    // convention as Spacing.contentMaxWidth's infinity handling.
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}
