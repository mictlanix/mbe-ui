import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/xbe_palette.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/brand_logo.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The login screen's dark branding pane (spec 019 FR-014; contracts/
/// brand-tokens.md Login & Home layout contract): full lockup, tagline,
/// subhead, and the three brand accent-color bars. Purely decorative — no
/// interactive elements, no dependency on [LoginController] state.
class LoginBrandingPane extends StatelessWidget {
  const LoginBrandingPane({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeRoles = Theme.of(context).typeRoles;
    return ColoredBox(
      color: XbePalette.darkSurface,
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
                // This pane is deliberately always-dark regardless of the
                // user's theme choice (spec 019 FR-014), so the color is
                // pinned to the dark tokens explicitly -- only the
                // typeface/size/weight come from the role.
                style: typeRoles.heroHeading.copyWith(
                  color: XbePalette.darkOnSurface,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.loginSubhead,
                style: typeRoles.heroSubhead.copyWith(
                  color: XbePalette.darkOnSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  _AccentBar(color: XbePalette.red),
                  SizedBox(width: 6),
                  _AccentBar(color: XbePalette.orange),
                  SizedBox(width: 6),
                  _AccentBar(color: XbePalette.gold),
                ],
              ),
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
