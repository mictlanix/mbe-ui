import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/auth/presentation/account/account_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Allows a signed-in user to change their own password (FR-009).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(changePasswordControllerProvider);
    final controller = ref.read(changePasswordControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: formState.success
                ? _SuccessView(onBack: () => context.pop())
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        TextFormField(
                          key: const Key('new_password_field'),
                          decoration: InputDecoration(
                            labelText: l10n.newPasswordLabel,
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          enabled: !formState.submitting,
                          onChanged: controller.newPasswordChanged,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return l10n.fieldRequired;
                            }
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
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.changePasswordButton),
                        ),
                      ],
                    ),
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
          color: Theme.of(context).colorScheme.primary,
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
