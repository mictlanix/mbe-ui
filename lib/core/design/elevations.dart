import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// One named depth level: a resolved surface color plus a shadow depth in
/// dp. `shadowDp == 0` marks a persistent surface (elevation carried by
/// color alone, M3's preferred idiom); `shadowDp > 0` marks a transient
/// overlay. No level may mix the two (data-model.md §3 Invariant).
@immutable
class ElevationLevel {
  const ElevationLevel({required this.surfaceColor, required this.shadowDp});

  final Color surfaceColor;
  final double shadowDp;

  static ElevationLevel lerp(ElevationLevel a, ElevationLevel b, double t) {
    return ElevationLevel(
      surfaceColor: Color.lerp(a.surfaceColor, b.surfaceColor, t)!,
      shadowDp: lerpDouble(a.shadowDp, b.shadowDp, t)!,
    );
  }
}

/// Named elevation model (spec 022 FR-006), data-model.md §3. Six levels,
/// each pointing at a fixed [ColorScheme] role and a fixed shadow depth —
/// the *mapping* (which named level uses which role) is identical across
/// every deployment (FR-010), even though the *resolved color* each level
/// paints with legitimately varies with the active brand, exactly as
/// [BrandConfig]-derived [ColorScheme] roles already do. This is why
/// [Elevations] is resolved from a [ColorScheme] via [Elevations.resolve]
/// rather than held as brand-independent literals like [Spacing]/[Shapes].
@immutable
class Elevations extends ThemeExtension<Elevations> {
  const Elevations({
    required this.flat,
    required this.sunken,
    required this.raised,
    required this.engaged,
    required this.floating,
    required this.modal,
  });

  /// Page background. `ColorScheme.surface`, no shadow.
  final ElevationLevel flat;

  /// The sunken well behind a card list. `surfaceContainerLowest`, no
  /// shadow.
  final ElevationLevel sunken;

  /// Cards, panels at rest. `surfaceContainerLow`, no shadow. Depends on
  /// FR-002's light-mode pin — unusable correctly in light mode before it.
  final ElevationLevel raised;

  /// Search bar, filter bar, selected row. `surfaceContainer`, no shadow.
  final ElevationLevel engaged;

  /// Popup menu, autocomplete, FAB. `surfaceContainerHigh`, 6dp shadow.
  final ElevationLevel floating;

  /// Modal dialog, side sheet, drag proxy. `surfaceContainerHighest`,
  /// 8–12dp shadow (10dp — the midpoint of the M3 spec range).
  final ElevationLevel modal;

  factory Elevations.resolve(ColorScheme scheme) {
    return Elevations(
      flat: ElevationLevel(surfaceColor: scheme.surface, shadowDp: 0),
      sunken: ElevationLevel(
        surfaceColor: scheme.surfaceContainerLowest,
        shadowDp: 0,
      ),
      raised: ElevationLevel(
        surfaceColor: scheme.surfaceContainerLow,
        shadowDp: 0,
      ),
      engaged: ElevationLevel(
        surfaceColor: scheme.surfaceContainer,
        shadowDp: 0,
      ),
      floating: ElevationLevel(
        surfaceColor: scheme.surfaceContainerHigh,
        shadowDp: 6,
      ),
      modal: ElevationLevel(
        surfaceColor: scheme.surfaceContainerHighest,
        shadowDp: 10,
      ),
    );
  }

  @override
  Elevations copyWith({
    ElevationLevel? flat,
    ElevationLevel? sunken,
    ElevationLevel? raised,
    ElevationLevel? engaged,
    ElevationLevel? floating,
    ElevationLevel? modal,
  }) {
    return Elevations(
      flat: flat ?? this.flat,
      sunken: sunken ?? this.sunken,
      raised: raised ?? this.raised,
      engaged: engaged ?? this.engaged,
      floating: floating ?? this.floating,
      modal: modal ?? this.modal,
    );
  }

  @override
  Elevations lerp(Elevations? other, double t) {
    if (other == null) return this;
    return Elevations(
      flat: ElevationLevel.lerp(flat, other.flat, t),
      sunken: ElevationLevel.lerp(sunken, other.sunken, t),
      raised: ElevationLevel.lerp(raised, other.raised, t),
      engaged: ElevationLevel.lerp(engaged, other.engaged, t),
      floating: ElevationLevel.lerp(floating, other.floating, t),
      modal: ElevationLevel.lerp(modal, other.modal, t),
    );
  }
}
