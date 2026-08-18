import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/brand_logo.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/home/presentation/home_activity_feed.dart';
import 'package:mbe_ui/features/home/presentation/home_dashboard_tiles.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The Home destination body: a branded welcome that never renders blank
/// (spec 010 US3, FR-015/016/017; contracts/home-welcome.md).
///
/// Branches on `BrandConfig.hasWelcomeAsset` (spec 019 data-model.md's
/// `welcomeAsset` reconciliation): a deployment that configured its own
/// welcome image keeps today's simple image + display name layout
/// unchanged (that deployment's own branding, not XBE's); the XBE default
/// build (no welcome asset configured) renders the brand guide's dashboard
/// instead — greeting card, indicator tiles, and recent activity.
class HomeWelcome extends ConsumerWidget {
  const HomeWelcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandConfigProvider);
    return brand.hasWelcomeAsset
        ? _BrandedWelcome(brand: brand)
        : const _XbeDashboard();
  }
}

/// Unchanged from before spec 019 — a deployment's own configured welcome
/// image + display name, falling back to the bundled placeholder if unset
/// or if the configured asset fails to load.
class _BrandedWelcome extends StatelessWidget {
  const _BrandedWelcome({required this.brand});

  final BrandConfig brand;

  static const _defaultAsset = 'assets/branding/default_welcome.png';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final Widget image = Image.asset(
      brand.welcomeAsset!,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => _defaultImage(),
    );

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

/// The XBE default build's dashboard: greeting card + indicator tiles +
/// recent activity (spec 019 FR-015). Tile/activity content is static
/// placeholder data (FR-016) — see [HomeDashboardTiles]/[HomeActivityFeed].
class _XbeDashboard extends ConsumerWidget {
  const _XbeDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider).valueOrNull;
    final greetingName = authState is AuthAuthenticated
        ? _localPart(authState.user.email)
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: [
            _GreetingCard(greetingName: greetingName, l10n: l10n, theme: theme),
            const HomeDashboardTiles(),
            const HomeActivityFeed(),
          ],
        ),
      ),
    );
  }

  static String _localPart(String email) {
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.greetingName,
    required this.l10n,
    required this.theme,
  });

  final String greetingName;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_greeting_card'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -40,
            bottom: -70,
            child: BrandWatermark(width: 320),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.homeGreeting(greetingName),
                  style: theme.typeRoles.pageHeading,
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    l10n.homeSummary,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: () => context.push('/price-lists'),
                      child: Text(l10n.homeReviewPendingButton),
                    ),
                    // No sales/order-creation screen exists yet in this
                    // catalog-management app — the button renders (matching
                    // the brand guide's mockup) but stays inert rather than
                    // navigating to a fabricated destination.
                    OutlinedButton(
                      onPressed: null,
                      child: Text(l10n.homeNewSaleButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
