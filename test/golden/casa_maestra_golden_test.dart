import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/brand_logo.dart';
import 'package:mbe_ui/core/widgets/brand_nav_header.dart';
import 'package:mbe_ui/core/widgets/inline_error_text.dart';
import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/auth/presentation/login/login_branding_pane.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'golden_harness.dart';

/// Goldens for the Casa Maestra brand (`BRAND_ID=xbe.cm`, spec 077), kept apart
/// from `core_widgets_golden_test.dart` so the default brand's baselines are
/// untouched. Same matrix as every other golden: light/dark × 400/1024.
///
/// Also the largest-text-size check (SC-007): Bitter is wider than Archivo, so
/// the login pane and the nav header are pumped at the largest level and must
/// not overflow.
void main() {
  setUpAll(loadGoldenFonts);

  final brand = BrandConfig.resolve(
    brandId: 'xbe.cm',
    displayName: 'unused',
    seedColorHex: '',
    hasSeedColor: false,
    lockupAsset: 'unused',
    markAsset: 'unused',
  );
  final overrides = [brandConfigProvider.overrideWithValue(brand)];

  group('golden: Casa Maestra', () {
    testWidgets('login branding pane', (tester) async {
      await expectGoldenMatrix(
        tester,
        'casa_maestra_login_pane',
        (brightness, width) => SizedBox(
          width: width,
          height: 700,
          child: const LoginBrandingPane(),
        ),
        overrides: overrides,
        brand: brand,
      );
    });

    testWidgets('brand logo and nav header', (tester) async {
      await expectGoldenMatrix(
        tester,
        'casa_maestra_brand_logo',
        (brightness, width) => const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandLogo(style: BrandLogoStyle.lockup, width: 236),
            SizedBox(height: 24),
            SizedBox(width: 240, child: BrandNavHeader()),
          ],
        ),
        overrides: overrides,
        brand: brand,
      );
    });

    testWidgets('app bar with the accent rule', (tester) async {
      await expectGoldenMatrix(
        tester,
        'casa_maestra_app_bar',
        (brightness, width) => SizedBox(
          width: width,
          height: 80,
          child: AppBar(title: const Text('Catálogo de Productos')),
        ),
        overrides: overrides,
        brand: brand,
      );
    });

    testWidgets('app bar with the accent rule (default XBE brand)', (
      tester,
    ) async {
      await expectGoldenMatrix(
        tester,
        'xbe_app_bar',
        (brightness, width) => SizedBox(
          width: width,
          height: 80,
          child: AppBar(title: const Text('Catálogo de Productos')),
        ),
      );
    });

    testWidgets('status tones and inline error', (tester) async {
      await expectGoldenMatrix(
        tester,
        'casa_maestra_status_tones',
        (brightness, width) => SizedBox(
          width: width - 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (tone, label) in const [
                    (StatusTone.neutral, 'Borrador'),
                    (StatusTone.info, 'En ruta'),
                    (StatusTone.warning, 'Pendiente'),
                    (StatusTone.success, 'Pagado'),
                    (StatusTone.error, 'Cancelado'),
                    (StatusTone.promo, 'Oferta'),
                  ])
                    StatusChip<StatusTone>(
                      value: tone,
                      label: label,
                      tone: tone,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const InlineErrorText('El RFC debe tener 12 o 13 caracteres'),
            ],
          ),
        ),
        overrides: overrides,
        brand: brand,
      );
    });

    testWidgets('type sample: Bitter, Roboto, Roboto Mono', (tester) async {
      await expectGoldenMatrix(
        tester,
        'casa_maestra_type_sample',
        (brightness, width) => Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final t = theme.textTheme;
            final mono = theme.typeRoles;
            return SizedBox(
              width: width - 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bienvenido de vuelta', style: t.displaySmall),
                  Text('Catálogo de Productos', style: t.headlineSmall),
                  Text('Pedidos', style: t.titleLarge),
                  Text('Datos Fiscales', style: t.titleMedium),
                  Text(
                    'Materiales, herramienta y ferretería para tu obra.',
                    style: t.bodyLarge,
                  ),
                  Text('PÚBLICO EN GENERAL · Contado', style: t.bodyMedium),
                  Text('Límite de crédito', style: t.bodySmall),
                  Text('Guardar', style: t.labelLarge),
                  Text('00337298 · SABE5513950918', style: mono.recordId),
                  Text('2026-07-28 14:32', style: mono.timestamp),
                ],
              ),
            );
          },
        ),
        overrides: overrides,
        brand: brand,
      );
    });
  });

  group('largest text size (SC-007)', () {
    final theme = AppTheme.of(brand);

    for (final brightness in Brightness.values) {
      for (final width in [goldenNarrowWidth, goldenWideWidth]) {
        testWidgets('login pane and nav header do not overflow at 1.3× '
            '(${brightness.name}, ${width.toInt()}px)', (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            ProviderScope(
              retry: (_, _) => null,
              overrides: overrides,
              child: MaterialApp(
                theme: brightness == Brightness.light
                    ? theme.light
                    : theme.dark,
                locale: const Locale('es', 'MX'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                builder: (context, child) {
                  final tier = LayoutBreakpoints.tierOfContext(context);
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(1.3)),
                    child: Theme(
                      data: DesignTheme.forTier(Theme.of(context), tier),
                      child: child!,
                    ),
                  );
                },
                home: const Scaffold(
                  body: Column(
                    children: [
                      Expanded(child: LoginBrandingPane()),
                      SizedBox(width: 240, child: BrandNavHeader()),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
