import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_test_env.dart';

void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  group('localizeValidationType', () {
    test(
      'renders every known type in both languages, with no placeholders',
      () {
        expect(localizedValidationTypes, hasLength(8));
        for (final type in localizedValidationTypes) {
          final en = localizeValidationType(type, env.en);
          final es = localizeValidationType(type, env.es);
          expect(en, isNotNull, reason: type);
          expect(es, isNotNull, reason: type);
          expect(en, isNot(es), reason: '$type is untranslated');
          expect(en, isNot(contains(RegExp(r'[{}]'))), reason: type);
          expect(es, isNot(contains(RegExp(r'[{}]'))), reason: type);
        }
      },
    );

    test('reads as the form needs it', () {
      expect(
        localizeValidationType('product_barcode_invalid', env.es),
        'El código de barras debe estar vacío o tener exactamente 13 dígitos '
        '(EAN-13).',
      );
      expect(
        localizeValidationType('user_id_not_alphanumeric', env.en),
        'The username can only have letters and numbers.',
      );
    });

    test(
      'password_policy keeps its own per-rule messages, so has none here',
      () {
        expect(localizeValidationType('password_policy', env.es), isNull);
      },
    );

    test('an unknown type has no message', () {
      expect(localizeValidationType('future_rule', env.es), isNull);
      expect(localizeValidationType('missing', env.es), isNull);
    });
  });

  group('serverFieldValue', () {
    test('stores the type when it is localized, so the screen resolves it at '
        'render time', () {
      const known = FieldError(
        loc: ['body', 'barcode'],
        msg: 'Barcode must be empty or exactly 13 digits (EAN-13)',
        type: 'product_barcode_invalid',
      );
      expect(serverFieldValue(known), 'product_barcode_invalid');
    });

    test('stores the English msg for any other type, as before', () {
      const standard = FieldError(
        loc: ['body', 'name'],
        msg: 'Field required',
        type: 'missing',
      );
      expect(serverFieldValue(standard), 'Field required');
    });
  });

  group('a field-level refusal through userMessage', () {
    test('uses the localized text for known types and the msg otherwise', () {
      const error = AppError.validation([
        FieldError(
          loc: ['body', 'a'],
          msg: 'English A',
          type: 'contact_name_blank',
        ),
        FieldError(loc: ['body', 'b'], msg: 'English B', type: 'missing'),
      ]);

      expect(
        error.userMessage(env.es, env.fmtEs),
        'El nombre no puede estar vacío.\nEnglish B',
      );
      expect(error.localizedMessage(env.es, env.fmtEs), isNull);
    });

    test('is fully localized when every entry is', () {
      const error = AppError.validation([
        FieldError(
          loc: ['body', 'a'],
          msg: 'English',
          type: 'contact_name_blank',
        ),
        FieldError(
          loc: ['body', 'b'],
          msg: 'English',
          type: 'product_code_has_whitespace',
        ),
      ]);

      expect(
        error.localizedMessage(env.es, env.fmtEs),
        'El nombre no puede estar vacío.\nEl código no puede contener espacios.',
      );
    });
  });
}
