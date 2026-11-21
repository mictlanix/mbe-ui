import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/branding/semantic_colors.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/brand_logo.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The login screen's branding pane (spec 019 FR-014; contracts/
/// brand-tokens.md Login & Home layout contract): full lockup, tagline,
/// subhead, and the brand's accent bars. Purely decorative — no interactive
/// elements, no dependency on [LoginController] state.
///
/// How it is painted comes from the active brand's `LoginPaneStyle` (spec 077
/// FR-009): XBE keeps its always-dark pane with three fixed bars; a brand that
/// follows the theme (Casa Maestra) takes its background and text from the
/// theme and its bar from `SemanticColors.accent`.
class LoginBrandingPane extends ConsumerWidget {
  const LoginBrandingPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typeRoles = theme.typeRoles;
    final pane = ref.watch(brandConfigProvider).definition.loginPane;
    final scheme = theme.colorScheme;
    final background = pane.followsTheme ? scheme.surface : pane.background!;
    final titleColor = pane.followsTheme ? scheme.onSurface : pane.title!;
    final subtitleColor = pane.followsTheme
        ? scheme.onSurfaceVariant
        : pane.subtitle!;
    return ColoredBox(
      color: background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandLogo(
                style: BrandLogoStyle.lockup,
                width: XbePalette.lockupLoginWidth,
              ),
              const SizedBox(height: 40),
              Text(
                l10n.loginTagline,
                // A fixed-color pane (XBE's always-dark one, spec 019
                // FR-014) pins its text colors explicitly regardless of the
                // user's theme choice -- only the typeface/size/weight come
                // from the role.
                style: typeRoles.heroHeading.copyWith(
                  color: titleColor,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.loginSubhead,
                style: typeRoles.heroSubhead.copyWith(
                  color: subtitleColor,
                  height: 1.5,
                ),
              ),
              if (pane.accentBars.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    for (var i = 0; i < pane.accentBars.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      _AccentBar(
                        color:
                            pane.accentBars[i] ?? theme.semanticColors.accent,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentBar extends StatelessWidget {
  const _AccentBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
