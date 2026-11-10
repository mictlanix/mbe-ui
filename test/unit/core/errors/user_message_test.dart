import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations_en.dart';

/// `userMessage` is the only way server text reaches a screen (spec 058
/// FR-014): the localized message, else the server's English detail, else a
/// field-level refusal's own lines.
void main() {
  final l10n = AppLocalizationsEn();
  late AppFormatters fmt;

  setUpAll(() async {
    await initializeDateFormatting();
    fmt = AppFormatters(
      locale: const Locale('en'),
      settings: const FormattingSettings(),
    );
  });

  group('with no localized message to offer', () {
    test('a server error shows the server detail', () {
      const error = AppError.server(statusCode: 409, message: 'Some English');

      expect(error.localizedMessage(l10n, fmt), isNull);
      expect(error.userMessage(l10n, fmt), 'Some English');
    });

    test(
      'a coded server error with an unknown code still shows the detail',
      () {
        final error = AppError.server(
          statusCode: 409,
          message: 'Some English',
          problem: const ApiProblem(codeName: 'future.code'),
        );

        expect(error.localizedMessage(l10n, fmt), isNull);
        expect(error.userMessage(l10n, fmt), 'Some English');
      },
    );

    test('not found and credit hold show their detail too', () {
      expect(
        const AppError.notFound('Missing').userMessage(l10n, fmt),
        'Missing',
      );
      expect(
        const AppError.creditHold('On hold').userMessage(l10n, fmt),
        'On hold',
      );
    });

    test('an auth detail is never shown (a failed sign-in stays vague)', () {
      expect(
        const AppError.auth('Wrong password').userMessage(l10n, fmt),
        isNull,
      );
    });

    test('an empty detail counts as no detail', () {
      expect(const AppError.server(message: '').userMessage(l10n, fmt), isNull);
    });

    test('a network error has nothing to show', () {
      expect(const AppError.network('socket').userMessage(l10n, fmt), isNull);
    });

    test('a field-level validation refusal joins its entries', () {
      const error = AppError.validation([
        FieldError(
          loc: ['body', 'name'],
          msg: 'Field required',
          type: 'missing',
        ),
        FieldError(
          loc: ['body', 'code'],
          msg: 'Too short',
          type: 'string_short',
        ),
      ]);

      expect(error.userMessage(l10n, fmt), 'Field required\nToo short');
    });

    test('a validation refusal with a plain detail shows the detail', () {
      const error = AppError.validation([], 'Customer has overdue orders');

      expect(error.userMessage(l10n, fmt), 'Customer has overdue orders');
    });
  });

  test('problem exposes the coded problem of every server variant', () {
    const problem = ApiProblem(codeName: 'x');

    expect(const AppError.server(problem: problem).problem, problem);
    expect(const AppError.notFound('m', problem).problem, problem);
    expect(const AppError.auth('m', problem).problem, problem);
    expect(const AppError.creditHold('m', problem).problem, problem);
    expect(const AppError.validation([], 'm', problem).problem, problem);
    expect(const AppError.network('m').problem, isNull);
    expect(const AppError.server().problem, isNull);
  });

  test('serverFieldValue stores the English msg until a type is localized', () {
    const entry = FieldError(loc: ['body'], msg: 'English', type: 'some_type');

    expect(serverFieldValue(entry), 'English');
  });
}
