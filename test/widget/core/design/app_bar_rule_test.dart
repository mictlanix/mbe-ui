import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brands/casa_maestra_brand.dart';
import 'package:mbe_ui/core/branding/semantic_colors.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

/// Every app bar carries a 3px rule in the brand accent color (spec 077
/// FR-017, contracts/nav-sections.md).
void main() {
  final brands = {
    'xbe': const BrandConfig(displayName: 'XBE'),
    'xbe.cm': const BrandConfig(
      displayName: 'Casa Maestra',
      seedColor: casaMaestraNavy,
      definition: casaMaestraBrand,
    ),
  };

  Future<void> pump(WidgetTester tester, ThemeData base) => tester.pumpWidget(
    MaterialApp(
      theme: base,
      builder: (context, child) => Theme(
        data: DesignTheme.forTier(Theme.of(context), LayoutTier.expanded),
        child: child!,
      ),
      home: Scaffold(appBar: AppBar(title: const Text('Pedidos'))),
    ),
  );

  brands.forEach((name, brand) {
    for (final brightness in Brightness.values) {
      testWidgets('$name ${brightness.name}: 3px accent rule, height kept', (
        tester,
      ) async {
        final themes = AppTheme.of(brand);
        final base = brightness == Brightness.light
            ? themes.light
            : themes.dark;
        await pump(tester, base);

        final material = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(AppBar),
                matching: find.byType(Material),
              )
              .first,
        );
        final shape = material.shape! as Border;
        expect(shape.bottom.width, 3);
        expect(shape.bottom.color, base.extension<SemanticColors>()!.accent);
        expect(shape.top, BorderSide.none);
        // The border paints inside the bar: it does not grow it.
        expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight);
      });
    }
  });
}
