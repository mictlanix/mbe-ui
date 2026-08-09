import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/brand_logo.dart';

/// Brand mark + display name (spec 019 FR-004). Used in two places that
/// must look consistent: fixed in the app bar's leading zone at the
/// Expanded/Large tier (see `AppShell`, aligned above the persistent rail),
/// and at the top of the `NavigationDrawer` at the Compact tier (see
/// `AppNavigation._buildDrawer`). Sized to fit within a standard app-bar
/// toolbar height.
class BrandNavHeader extends ConsumerWidget {
  const BrandNavHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(brandConfigProvider).displayName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const BrandLogo(
            style: BrandLogoStyle.mark,
            height: XbePalette.markNavHeight,
          ),
          const SizedBox(width: 12),
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
