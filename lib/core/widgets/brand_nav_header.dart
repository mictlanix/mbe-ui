import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/brand_logo.dart';

/// Brand mark + display name (spec 019 FR-004). Used in two places that
/// must look consistent: fixed in the app bar's leading zone from the Medium
/// tier up (see `AppShell`, aligned above the persistent rail), and at the top
/// of the `NavigationDrawer` at the Compact tier (see
/// `AppNavigation._buildDrawer`). Sized to fit within a standard app-bar
/// toolbar height.
///
/// Below the Expanded tier (under 840px) it shows the mark alone; from there
/// up, the mark plus the brand's display name (spec 077 FR-012, every brand).
class BrandNavHeader extends ConsumerWidget {
  const BrandNavHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(brandConfigProvider).displayName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: 12,
        children: [
          const BrandLogo(
            style: BrandLogoStyle.mark,
            height: XbePalette.markNavHeight,
          ),
          if (LayoutBreakpoints.isExpanded(context))
            Expanded(
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).typeRoles.navHeader,
              ),
            ),
        ],
      ),
    );
  }
}
