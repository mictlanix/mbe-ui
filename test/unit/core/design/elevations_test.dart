import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/elevations.dart';

void main() {
  group('Elevations', () {
    const scheme = ColorScheme.light();
    final e = Elevations.resolve(scheme);

    test('resolves each level to its documented ColorScheme role', () {
      expect(e.flat.surfaceColor, scheme.surface);
      expect(e.sunken.surfaceColor, scheme.surfaceContainerLowest);
      expect(e.raised.surfaceColor, scheme.surfaceContainerLow);
      expect(e.engaged.surfaceColor, scheme.surfaceContainer);
      expect(e.floating.surfaceColor, scheme.surfaceContainerHigh);
      expect(e.modal.surfaceColor, scheme.surfaceContainerHighest);
    });

    test(
      'persistent surfaces carry no shadow; transient overlays do (data-model.md §3 Invariant)',
      () {
        expect(e.flat.shadowDp, 0);
        expect(e.sunken.shadowDp, 0);
        expect(e.raised.shadowDp, 0);
        expect(e.engaged.shadowDp, 0);
        expect(e.floating.shadowDp, greaterThan(0));
        expect(e.modal.shadowDp, greaterThan(0));
      },
    );

    test(
      'the role mapping is fixed even as the resolved color varies by scheme',
      () {
        const otherScheme = ColorScheme.dark();
        final other = Elevations.resolve(otherScheme);
        // Same mapping (surfaceContainerLow), different resolved colors --
        // proving the *rule* is brand-independent even though its *output*
        // legitimately isn't (spec 022 FR-010 as it actually applies here).
        expect(e.raised.surfaceColor, scheme.surfaceContainerLow);
        expect(other.raised.surfaceColor, otherScheme.surfaceContainerLow);
        expect(e.raised.surfaceColor, isNot(other.raised.surfaceColor));
      },
    );
  });
}
