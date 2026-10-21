import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/password_policy.dart';
import 'package:mbe_ui/features/auth/presentation/account/account_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The new-password field and its confirmation (spec 048 FR-001..003).
/// Re-validates the confirmation whenever the new password changes, and shows
/// the policy checklist (FR-030/031).
class NewPasswordFields extends StatefulWidget {
  const NewPasswordFields({
    super.key,
    this.newFieldKey = const Key('new_password_field'),
    required this.newLabel,
    required this.confirmLabel,
    required this.policy,
    this.enabled = true,
    required this.onNewChanged,
    required this.onConfirmChanged,
    this.onSubmitted,
  });

  final Key newFieldKey;
  final String newLabel;
  final String confirmLabel;
  final AsyncValue<PasswordPolicy> policy;
  final bool enabled;
  final ValueChanged<String> onNewChanged;
  final ValueChanged<String> onConfirmChanged;
  final VoidCallback? onSubmitted;

  @override
  State<NewPasswordFields> createState() => _NewPasswordFieldsState();
}

class _NewPasswordFieldsState extends State<NewPasswordFields> {
  final _confirmKey = GlobalKey<FormFieldState<String>>();
  String _newValue = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: widget.newFieldKey,
          decoration: InputDecoration(labelText: widget.newLabel),
          obscureText: true,
          textInputAction: TextInputAction.next,
          enabled: widget.enabled,
          onChanged: (v) {
            setState(() => _newValue = v);
            widget.onNewChanged(v);
            final confirm = _confirmKey.currentState;
            if (confirm != null && (confirm.value ?? '').isNotEmpty) {
              confirm.validate();
            }
          },
          validator: (v) =>
              (v == null || v.isEmpty) ? l10n.fieldRequired : null,
        ),
        const SizedBox(height: 12),
        // The GlobalKey must sit on the TextFormField itself to reach its
        // state, so the addressable key goes on this wrapper.
        KeyedSubtree(
          key: const Key('new_password_confirm_field'),
          child: TextFormField(
            key: _confirmKey,
            decoration: InputDecoration(labelText: widget.confirmLabel),
            obscureText: true,
            textInputAction: TextInputAction.done,
            enabled: widget.enabled,
            onChanged: widget.onConfirmChanged,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.fieldRequired;
              if (v != _newValue) return l10n.passwordMismatchError;
              return null;
            },
            onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          ),
        ),
        _PasswordRules(policy: widget.policy, password: _newValue),
      ],
    );
  }
}

/// The live rule checklist (C1): hidden while the policy loads, a notice if
/// it could not be loaded (the server still enforces it).
class _PasswordRules extends StatelessWidget {
  const _PasswordRules({required this.policy, required this.password});

  final AsyncValue<PasswordPolicy> policy;
  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final Widget content;
    if (policy.hasError) {
      content = Text(
        l10n.passwordRulesUnavailable,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
    } else if (policy.hasValue) {
      final value = policy.requireValue;
      final unmet = value.unmet(password);
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rule in value.rules)
            Padding(
              key: Key('password_rule_${rule.name}'),
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    unmet.contains(rule)
                        ? Icons.circle_outlined
                        : Icons.check_circle,
                    size: 16,
                    color: unmet.contains(rule)
                        ? scheme.onSurfaceVariant
                        : scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(localizePasswordRule(l10n, rule, value)),
                  ),
                ],
              ),
            ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
    return Padding(
      key: const Key('password_rules'),
      padding: const EdgeInsets.only(top: 12),
      child: content,
    );
  }
}

/// The localized text of [rule] under [policy].
String localizePasswordRule(
  AppLocalizations l10n,
  PasswordRule rule,
  PasswordPolicy policy,
) {
  switch (rule) {
    case PasswordRule.minLength:
      return l10n.passwordRuleMinLength(policy.minLength);
    case PasswordRule.upper:
      return l10n.passwordRuleUpper;
    case PasswordRule.lower:
      return l10n.passwordRuleLower;
    case PasswordRule.digit:
      return l10n.passwordRuleDigit;
    case PasswordRule.symbol:
      return l10n.passwordRuleSymbol;
  }
}

/// Localizes a [PasswordFormErrorCode] for the password forms' local
/// `error`.
String localizePasswordFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case PasswordFormErrorCode.fieldsRequired:
      return l10n.fieldRequired;
    case PasswordFormErrorCode.passwordMismatch:
      return l10n.passwordMismatchError;
    default:
      return code;
  }
}

/// The banner error for a password form's local code or repository failure.
AppError? passwordFormBannerError(
  AppLocalizations l10n, {
  String? error,
  AppError? failure,
  PasswordPolicy? policy,
}) {
  if (failure != null) {
    return policy == null ? failure : _withRuleMessages(l10n, failure, policy);
  }
  if (error == null) return null;
  return AppError.validation([
    FieldError(
      loc: const [],
      msg: localizePasswordFormError(l10n, error),
      type: 'error',
    ),
  ]);
}

/// Replaces a `422 password_policy` rejection's raw message with one
/// localized message per failed rule (R3); any other error is unchanged.
AppError _withRuleMessages(
  AppLocalizations l10n,
  AppError failure,
  PasswordPolicy policy,
) {
  if (failure is! ValidationError) return failure;
  final rules = failure.errors.expand(rulesFromFieldError).toSet();
  if (rules.isEmpty) return failure;
  return AppError.validation([
    for (final rule in PasswordRule.values)
      if (rules.contains(rule))
        FieldError(
          loc: const [],
          msg: localizePasswordRule(l10n, rule, policy),
          type: 'error',
        ),
  ]);
}
