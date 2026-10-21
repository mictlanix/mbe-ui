import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/branding/brand_ink.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/account/account_controller.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/auth/presentation/widgets/new_password_fields.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Allows a signed-in user to change their own password (FR-009).
///
/// [forced] is the first-login variant (spec 048 US5): it can't be left
/// except by changing the password or logging out.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key, this.forced = false});

  final bool forced;

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final forced = widget.forced;
    if (forced) {
      ref.listen(changePasswordControllerProvider, (previous, next) {
        if (next.success && !(previous?.success ?? false)) {
          ref.read(authProvider.notifier).reloadCurrentUser();
        }
      });
    }
    final formState = ref.watch(changePasswordControllerProvider);
    final controller = ref.read(changePasswordControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final passwordPolicy = ref.watch(passwordPolicyProvider);
    final bannerError = passwordFormBannerError(
      l10n,
      policy: passwordPolicy.value,
      error: formState.error,
      failure: formState.failure,
    );

    return PopScope(
      canPop: !forced,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            forced ? l10n.passwordRequiredTitle : l10n.changePasswordTitle,
          ),
          automaticallyImplyLeading: !forced,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            // Scrolls so the rule checklist never overflows a short viewport;
            // shrink-wrapped to stay vertically centered otherwise.
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                formState.success && !forced
                    ? _SuccessView(onBack: () => context.pop())
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (forced) ...[
                              Text(l10n.passwordRequiredExplanation),
                              const SizedBox(height: 16),
                            ],
                            if (bannerError != null) ...[
                              ErrorBanner(error: bannerError),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              key: const Key('current_password_field'),
                              decoration: InputDecoration(
                                labelText: l10n.currentPasswordLabel,
                              ),
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              enabled: !formState.submitting,
                              onChanged: controller.oldPasswordChanged,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? l10n.fieldRequired
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            NewPasswordFields(
                              newLabel: l10n.newPasswordLabel,
                              confirmLabel: l10n.confirmNewPasswordLabel,
                              policy: passwordPolicy,
                              enabled: !formState.submitting,
                              onNewChanged: controller.newPasswordChanged,
                              onConfirmChanged:
                                  controller.confirmPasswordChanged,
                              onSubmitted: () => _submit(controller),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: formState.submitting
                                  ? null
                                  : () => _submit(controller),
                              child: formState.submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.changePasswordButton),
                            ),
                            if (forced) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                key: const Key('forced_change_logout'),
                                onPressed: () =>
                                    ref.read(authProvider.notifier).signOut(),
                                child: Text(l10n.userMenuLogout),
                              ),
                            ],
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(ChangePasswordController controller) {
    if (_formKey.currentState?.validate() ?? false) {
      controller.submit();
    }
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).brandInk.primary,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.passwordChangedSuccess),
        const SizedBox(height: 24),
        TextButton(
          onPressed: onBack,
          child: Text(AppLocalizations.of(context)!.backButton),
        ),
      ],
    );
  }
}
