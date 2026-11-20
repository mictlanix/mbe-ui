import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/semantic_colors.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/cash_session_status_chip.dart';
import 'package:mbe_ui/core/branding/brands/casa_maestra_brand.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('es', 'MX'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: child),
);

void main() {
  group('StatusChip (SC-010: one shared implementation, not two)', () {
    testWidgets(
      'EntityStatusCell renders a non-active status through StatusChip<EntityStatus>',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const EntityStatusCell(status: EntityStatus.inactive)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StatusChip<EntityStatus>), findsOneWidget);
        expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
      },
    );

    testWidgets('EntityStatusCell renders active as plain text, not a chip', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const EntityStatusCell(status: EntityStatus.active)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<EntityStatus>), findsNothing);
    });

    testWidgets(
      'CashSessionStatusChip renders through StatusChip<CashSessionStatus>',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const CashSessionStatusChip(status: CashSessionStatus.stale)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StatusChip<CashSessionStatus>), findsOneWidget);
        expect(
          find.byKey(const Key('cash_session_status_chip_stale')),
          findsOneWidget,
        );
      },
    );

    testWidgets('the two status enums never share a StatusChip type', (
      tester,
    ) async {
      // The generic type parameter is what makes "one shared implementation"
      // (SC-010) verifiable at all -- confirms EntityStatus and
      // CashSessionStatus each instantiate their own StatusChip<T>, not a
      // dynamic/untyped one that would hide a divergence.
      await tester.pumpWidget(
        _wrap(
          Column(
            children: const [
              EntityStatusCell(status: EntityStatus.archived),
              CashSessionStatusChip(status: CashSessionStatus.closed),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<EntityStatus>), findsOneWidget);
      expect(find.byType(StatusChip<CashSessionStatus>), findsOneWidget);
    });
  });

  group('StatusTone (spec 077 FR-014, FR-015)', () {
    final brands = {
      'xbe': const BrandConfig(displayName: 'XBE'),
      'xbe.cm': const BrandConfig(
        displayName: 'Casa Maestra',
        seedColor: casaMaestraNavy,
        definition: casaMaestraBrand,
      ),
    };

    Widget chip(StatusTone tone, {IconData? icon}) => StatusChip<StatusTone>(
      key: Key('chip_${tone.name}'),
      value: tone,
      label: tone.name,
      tone: tone,
      icon: icon,
    );

    brands.forEach((brandName, brand) {
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? AppTheme.of(brand).light
            : AppTheme.of(brand).dark;
        final scheme = theme.colorScheme;
        final sem = theme.extension<SemanticColors>()!;
        final expected = <StatusTone, (Color, Color)>{
          StatusTone.neutral: (
            scheme.surfaceContainerHighest,
            scheme.onSurfaceVariant,
          ),
          StatusTone.info: (scheme.primaryContainer, scheme.onPrimaryContainer),
          StatusTone.warning: (sem.warningContainer, sem.onWarningContainer),
          StatusTone.success: (sem.successContainer, sem.onSuccessContainer),
          StatusTone.error: (scheme.errorContainer, scheme.onErrorContainer),
          StatusTone.promo: (sem.accentContainer, sem.onAccentContainer),
        };

        for (final tone in StatusTone.values) {
          testWidgets(
            '$brandName ${brightness.name}: ${tone.name} shows an icon, '
            'the word and its colors',
            (tester) async {
              await tester.pumpWidget(
                MaterialApp(
                  theme: theme,
                  home: Scaffold(body: chip(tone)),
                ),
              );
              final c = tester.widget<Chip>(find.byType(Chip));
              expect(find.text(tone.name), findsOneWidget);
              expect(c.avatar, isA<Icon>());
              expect((c.avatar! as Icon).icon, tone.defaultIcon);
              expect(c.backgroundColor, expected[tone]!.$1);
              expect(c.labelStyle!.color, expected[tone]!.$2);
              expect((c.avatar! as Icon).color, expected[tone]!.$2);
            },
          );
        }
      }
    });

    testWidgets('an icon override replaces the tone default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(brands['xbe']!).light,
          home: Scaffold(body: chip(StatusTone.neutral, icon: Icons.edit_note)),
        ),
      );
      final c = tester.widget<Chip>(find.byType(Chip));
      expect((c.avatar! as Icon).icon, Icons.edit_note);
    });

    test('every tone has a distinct default icon', () {
      final icons = StatusTone.values.map((t) => t.defaultIcon).toSet();
      expect(icons, hasLength(StatusTone.values.length));
    });

    test('only promo uses the accent container (FR-015)', () {
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? AppTheme.of(brands['xbe.cm']!).light
            : AppTheme.of(brands['xbe.cm']!).dark;
        final accent = theme.extension<SemanticColors>()!.accentContainer;
        for (final tone in StatusTone.values) {
          final bg = tone.colors(theme).$1;
          expect(
            bg == accent,
            tone == StatusTone.promo,
            reason: '${tone.name} ${brightness.name}',
          );
        }
      }
    });

    testWidgets(
      'only promo has an accent outline, so it never reads as error',
      (tester) async {
        final theme = AppTheme.of(brands['xbe.cm']!).light;
        for (final tone in StatusTone.values) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(body: chip(tone)),
            ),
          );
          final side = tester.widget<Chip>(find.byType(Chip)).side;
          if (tone == StatusTone.promo) {
            expect(side?.color, theme.extension<SemanticColors>()!.accent);
          } else {
            expect(side, isNull, reason: tone.name);
          }
        }
      },
    );

    test('in Casa Maestra, error and promo grounds are not the same color', () {
      for (final theme in [
        AppTheme.of(brands['xbe.cm']!).light,
        AppTheme.of(brands['xbe.cm']!).dark,
      ]) {
        expect(
          StatusTone.error.colors(theme).$1,
          isNot(StatusTone.promo.colors(theme).$1),
        );
      }
    });
  });
}
