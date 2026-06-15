import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/auth/presentation/login/login_controller.dart';

/// Sign-in screen (FR-001, FR-008; contracts/routes.md "Login is a centered
/// single-column form"). On submit, delegates to [LoginController], which
/// drives `AuthNotifier.signIn`. The redirect guard (app_router.dart) takes
/// the user to `/` once the resulting `AuthState` becomes `authenticated`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign in',
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
                    decoration: const InputDecoration(labelText: 'Username'),
                    textInputAction: TextInputAction.next,
                    enabled: !formState.submitting,
                    onChanged: controller.usernameChanged,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('login_password_field'),
                    initialValue: formState.password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    enabled: !formState.submitting,
                    onChanged: controller.passwordChanged,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                    onFieldSubmitted: (_) => _submit(controller),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: formState.submitting ? null : () => _submit(controller),
                    child: formState.submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(LoginController controller) {
    if (_formKey.currentState?.validate() ?? false) {
      controller.submit();
    }
  }
}
