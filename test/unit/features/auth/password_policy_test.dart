import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/password_policy.dart';

void main() {
  const serverDefault = PasswordPolicy(
    minLength: 8,
    requireUpper: true,
    requireLower: true,
    requireDigit: true,
    requireSymbol: false,
  );
  const symbolOnly = PasswordPolicy(
    minLength: 1,
    requireUpper: false,
    requireLower: false,
    requireDigit: false,
    requireSymbol: true,
  );

  group('PasswordPolicy.unmet', () {
    test('a compliant password misses nothing', () {
      expect(serverDefault.unmet('Abcdefg1'), isEmpty);
    });

    test('flags each missed rule', () {
      expect(serverDefault.unmet('Abc1'), {PasswordRule.minLength});
      expect(serverDefault.unmet('abcdefg1'), {PasswordRule.upper});
      expect(serverDefault.unmet('ABCDEFG1'), {PasswordRule.lower});
      expect(serverDefault.unmet('Abcdefgh'), {PasswordRule.digit});
      expect(serverDefault.unmet(''), serverDefault.rules.toSet());
    });

    test('a symbol is any non-letter, non-digit, non-space character', () {
      expect(symbolOnly.unmet('a1'), {PasswordRule.symbol});
      expect(symbolOnly.unmet('a b'), {PasswordRule.symbol});
      expect(symbolOnly.unmet('a!'), isEmpty);
      expect(symbolOnly.unmet('a_'), isEmpty);
    });
  });

  group('PasswordPolicy.rules', () {
    test('lists only the enabled rules, in order', () {
      expect(serverDefault.rules, [
        PasswordRule.minLength,
        PasswordRule.upper,
        PasswordRule.lower,
        PasswordRule.digit,
      ]);
      expect(symbolOnly.rules, [PasswordRule.minLength, PasswordRule.symbol]);
    });
  });

  group('rulesFromFieldError', () {
    test('reads the failed rules of a password_policy rejection', () {
      const error = FieldError(
        loc: ['body', 'new_password'],
        msg: 'x',
        type: 'password_policy',
        failedRules: ['min_length', 'require_digit', 'require_unknown'],
      );

      expect(rulesFromFieldError(error), {
        PasswordRule.minLength,
        PasswordRule.digit,
      });
    });

    test('is empty for any other error type', () {
      const error = FieldError(
        loc: ['body', 'new_password'],
        msg: 'x',
        type: 'value_error',
        failedRules: ['min_length'],
      );

      expect(rulesFromFieldError(error), isEmpty);
    });
  });
}
