import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The Home destination body: a branded welcome that never renders blank
/// (spec 010 US3, FR-015/016/017; contracts/home-welcome.md). Shows the
/// deployment's configured welcome asset + display name, or a bundled default
/// placeholder when none is configured (or the configured asset fails to load).
class HomeWelcome extends ConsumerWidget {
  const HomeWelcome({super.key});

  static const _defaultAsset = 'assets/branding/default_welcome.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandConfigProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final Widget image = brand.hasWelcomeAsset
        ? Image.asset(
            brand.welcomeAsset!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => _defaultImage(),
          )
        : _defaultImage();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
              const SizedBox(height: 24),
              Text(
                brand.displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeWelcomeMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultImage() => Image.asset(
    _defaultAsset,
    key: const Key('home_welcome_default'),
    fit: BoxFit.contain,
  );
}
