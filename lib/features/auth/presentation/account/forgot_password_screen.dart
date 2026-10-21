import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_ink.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/account/account_controller.dart';
import 'package:mbe_ui/features/auth/presentation/widgets/new_password_fields.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Two-purpose screen for FR-010:
///  - Shows an informational message instructing the user to contact an
///    administrator for a recovery token.
///  - Provides a form to submit that recovery token + a new password.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(recoveryControllerProvider);
    final controller = ref.read(recoveryControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final passwordPolicy = ref.watch(passwordPolicyProvider);
    final bannerError = passwordFormBannerError(
      l10n,
      policy: passwordPolicy.value,
      error: formState.error,
      failure: formState.failure,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recoverPasswordTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          // Scrolls so the rule checklist never overflows a short viewport;
          // shrink-wrapped to stay vertically centered otherwise.
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              formState.success
                  ? _SuccessView()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HelpText(),
                        const SizedBox(height: 24),
                        if (bannerError != null) ...[
                          ErrorBanner(error: bannerError),
                          const SizedBox(height: 16),
                        ],
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                key: const Key('recovery_token_field'),
                                decoration: InputDecoration(
                                  labelText: l10n.recoveryTokenLabel,
                                ),
                                textInputAction: TextInputAction.next,
                                enabled: !formState.submitting,
                                onChanged: controller.recoveryTokenChanged,
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
                                    : Text(l10n.setNewPasswordButton),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(RecoveryController controller) {
    if (_formKey.currentState?.validate() ?? false) {
      controller.submit();
    }
  }
}

class _HelpText extends StatelessWidget {
  const _HelpText();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.recoveryHelpText,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).brandInk.primary,
          size: 64,
        ),
        Text(AppLocalizations.of(context)!.passwordResetSuccess),
      ],
    );
  }
}
