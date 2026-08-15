import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_profiles_controller.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the confirmation dialog for applying a profile to [userId]
/// (024-user-profiles FR-011, FR-020, contracts/user-profile-screens.md
/// §3c). [isSelf] additionally warns that the signed-in administrator's own
/// session will end (FR-024).
Future<void> showApplyProfileDialog(
  BuildContext context, {
  required String userId,
  required bool isSelf,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ApplyProfileDialog(userId: userId, isSelf: isSelf),
  );
}

class _ApplyProfileDialog extends ConsumerStatefulWidget {
  const _ApplyProfileDialog({required this.userId, required this.isSelf});

  final String userId;
  final bool isSelf;

  @override
  ConsumerState<_ApplyProfileDialog> createState() =>
      _ApplyProfileDialogState();
}

class _ApplyProfileDialogState extends ConsumerState<_ApplyProfileDialog> {
  int? _profileId;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProfileRepo = ref.read(userProfileRepositoryProvider);
    final hasProfilesAsync = ref.watch(hasActiveUserProfilesProvider);

    return AlertDialog(
      key: const Key('apply_profile_dialog'),
      title: Text(l10n.applyProfileDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasProfilesAsync.valueOrNull == false)
              Text(
                l10n.noUserProfilesYetMessage,
                key: const Key('apply_profile_no_profiles_yet'),
              )
            else
              CatalogEntityPicker<UserProfileSummary>(
                key: const Key('apply_profile_picker'),
                label: l10n.userProfilePickerLabel,
                displayStringForOption: (p) => p.name,
                optionsBuilder: (query) async {
                  final result = await userProfileRepo.list(
                    search: query.isEmpty ? null : query,
                    status: EntityStatus.active,
                  );
                  return result.items;
                },
                onSelected: (p) =>
                    setState(() => _profileId = p.userProfileId),
                enabled: !_submitting,
              ),
            const SizedBox(height: 16),
            Text(
              l10n.applyProfileReplaceWarning,
              key: const Key('apply_profile_replace_warning'),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.applyProfileSessionWarning,
              key: const Key('apply_profile_session_warning'),
            ),
            if (widget.isSelf) ...[
              const SizedBox(height: 8),
              Text(
                l10n.applyProfileSelfWarning,
                key: const Key('apply_profile_self_warning'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('apply_profile_cancel'),
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          key: const Key('apply_profile_confirm'),
          onPressed: (_profileId == null || _submitting) ? null : _confirm,
          child: Text(l10n.applyProfileConfirmLabel),
        ),
      ],
    );
  }

  Future<void> _confirm() async {
    // Captured before the `await` — by the time it resolves, this dialog's
    // own context may already be gone, but the underlying screen's
    // ScaffoldMessenger ancestor is what a success SnackBar needs anyway.
    final messenger = ScaffoldMessenger.of(context);
    final successText = AppLocalizations.of(context)!.applyProfileSuccessMessage;

    setState(() => _submitting = true);
    await ref
        .read(userFormControllerProvider.notifier)
        .applyProfile(userId: widget.userId, profileId: _profileId!);
    if (!mounted) return;

    // A failure leaves `UserFormState.error` set (FR-023), which the
    // underlying UserDetailScreen already renders via its own ErrorBanner —
    // this dialog doesn't duplicate that display, it just closes and lets
    // the screen show it.
    final failed = ref.read(userFormControllerProvider).error != null;
    Navigator.of(context).pop();
    if (!failed) {
      messenger.showSnackBar(SnackBar(content: Text(successText)));
    }
  }
}
