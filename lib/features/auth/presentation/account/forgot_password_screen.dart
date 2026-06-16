import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/auth/presentation/account/account_controller.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recoverPasswordTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: formState.success
                ? _SuccessView()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HelpText(),
                      const SizedBox(height: 24),
                      if (formState.error != null) ...[
                        ErrorBanner(
                          error: AppError.validation([
                            FieldError(
                              loc: const [],
                              msg: formState.error!,
                              type: 'error',
                            ),
                          ]),
                        ),
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
                                  labelText: l10n.recoveryTokenLabel),
                              textInputAction: TextInputAction.next,
                              enabled: !formState.submitting,
                              onChanged: controller.recoveryTokenChanged,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? l10n.fieldRequired : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: const Key('new_password_field'),
                              decoration: InputDecoration(
                                  labelText: l10n.newPasswordLabel),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              enabled: !formState.submitting,
                              onChanged: controller.newPasswordChanged,
                              validator: (v) {
                                if (v == null || v.isEmpty) return l10n.fieldRequired;
                                if (v.length < 6) return l10n.fieldMinLength6;
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(controller),
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
                                          strokeWidth: 2),
                                    )
                                  : Text(l10n.setNewPasswordButton),
                            ),
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
      children: [
        Icon(Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary, size: 64),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.passwordResetSuccess),
      ],
    );
  }
}
