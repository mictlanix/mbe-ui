import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/auth/presentation/login/login_branding_pane.dart';
import 'package:mbe_ui/features/auth/presentation/login/login_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Sign-in screen (FR-001, FR-008). A two-pane layout on Medium tier and
/// wider — a dark [LoginBrandingPane] beside the sign-in form — matching
/// the XBE brand guide (spec 019 FR-014); the branding pane is omitted at
/// the Compact tier rather than forcing horizontal scroll. On submit,
/// delegates to [LoginController], which drives `AuthNotifier.signIn`. The
/// redirect guard (app_router.dart) takes the user to `/` once the
/// resulting `AuthState` becomes `authenticated`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isCompact = LayoutBreakpoints.isCompact(context);

    return Scaffold(
      body: isCompact
          ? Center(
              child: _SignInForm(formKey: _formKey, onSubmit: _submit),
            )
          : Row(
              children: [
                const Expanded(flex: 5, child: LoginBrandingPane()),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: _SignInForm(formKey: _formKey, onSubmit: _submit),
                  ),
                ),
              ],
            ),
    );
  }

  void _submit(LoginController controller) {
    if (_formKey.currentState?.validate() ?? false) {
      controller.submit();
    }
  }
}

class _SignInForm extends ConsumerWidget {
  const _SignInForm({required this.formKey, required this.onSubmit});

  final GlobalKey<FormState> formKey;
  final void Function(LoginController controller) onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.signInTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (formState.error != null) ...[
                ErrorBanner(error: const AppError.auth()),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const Key('login_username_field'),
                initialValue: formState.username,
                decoration: InputDecoration(labelText: l10n.usernameLabel),
                textInputAction: TextInputAction.next,
                enabled: !formState.submitting,
                onChanged: controller.usernameChanged,
                validator: (value) => (value == null || value.isEmpty)
                    ? l10n.fieldRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('login_password_field'),
                initialValue: formState.password,
                decoration: InputDecoration(labelText: l10n.passwordLabel),
                obscureText: true,
                textInputAction: TextInputAction.done,
                enabled: !formState.submitting,
                onChanged: controller.passwordChanged,
                validator: (value) => (value == null || value.isEmpty)
                    ? l10n.fieldRequired
                    : null,
                onFieldSubmitted: (_) => onSubmit(controller),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: formState.submitting
                    ? null
                    : () => onSubmit(controller),
                child: formState.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.signInButton),
              ),
              const SizedBox(height: 12),
              TextButton(
                key: const Key('forgot_password_link'),
                onPressed: () => context.push('/auth/recover'),
                child: Text(l10n.forgotPasswordLink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
