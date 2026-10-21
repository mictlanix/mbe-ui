import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';

part 'password_policy.freezed.dart';

/// A rule of the deployment's password policy, with its server name.
enum PasswordRule {
  minLength('min_length'),
  upper('require_upper'),
  lower('require_lower'),
  digit('require_digit'),
  symbol('require_symbol');

  const PasswordRule(this.serverName);

  final String serverName;
}

/// The password policy published by `GET /auth/password-policy`
/// (spec 048 data-model §1). The server enforces it; the client only mirrors
/// it for the live checklist.
@freezed
abstract class PasswordPolicy with _$PasswordPolicy {
  const PasswordPolicy._();

  const factory PasswordPolicy({
    required int minLength,
    required bool requireUpper,
    required bool requireLower,
    required bool requireDigit,
    required bool requireSymbol,
  }) = _PasswordPolicy;

  /// The enabled rules, in checklist order.
  List<PasswordRule> get rules => [
    PasswordRule.minLength,
    if (requireUpper) PasswordRule.upper,
    if (requireLower) PasswordRule.lower,
    if (requireDigit) PasswordRule.digit,
    if (requireSymbol) PasswordRule.symbol,
  ];

  /// The enabled rules [password] does not satisfy.
  Set<PasswordRule> unmet(String password) {
    final chars = password.split('');
    return {
      for (final rule in rules)
        if (!_isMet(rule, password, chars)) rule,
    };
  }

  bool _isMet(PasswordRule rule, String password, List<String> chars) {
    switch (rule) {
      case PasswordRule.minLength:
        return password.length >= minLength;
      case PasswordRule.upper:
        return chars.any((c) => c != c.toLowerCase());
      case PasswordRule.lower:
        return chars.any((c) => c != c.toUpperCase());
      case PasswordRule.digit:
        return chars.any((c) => RegExp('[0-9]').hasMatch(c));
      case PasswordRule.symbol:
        // Matches the server: not a letter, not a digit, not whitespace.
        return RegExp(r'[^\p{L}\p{N}\s]', unicode: true).hasMatch(password);
    }
  }
}

/// The rules a `422 password_policy` [FieldError] reports as failed; empty
/// for any other error. Unknown rule names are ignored.
Set<PasswordRule> rulesFromFieldError(FieldError error) {
  if (error.type != 'password_policy') return const {};
  return {
    for (final rule in PasswordRule.values)
      if (error.failedRules.contains(rule.serverName)) rule,
  };
}
