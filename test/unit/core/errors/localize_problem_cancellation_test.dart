import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_test_env.dart';

/// Spec 072 research R9: the stamp, cancel and refresh codes whose message
/// carries a param.
void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  ApiProblem problem(api.ErrorCode code, Map<String, Object?> params) =>
      ApiProblem(codeName: code.name, code: code, params: params);

  group('fiscal_document.has_live_documents', () {
    final code = api.ErrorCode.fiscalDocumentPeriodHasLiveDocuments;

    test('lists the documents by series and folio, in both languages', () {
      final p = problem(code, {
        'documents': ['P12', 'NC3'],
      });

      expect(
        localizeProblem(p, env.es, env.fmtEs),
        'No se puede cancelar: primero cancela los documentos que dependen de '
        'este: P12, NC3.',
      );
      expect(localizeProblem(p, env.en, env.fmtEn), contains('P12, NC3'));
    });

    test('a missing, empty or mistyped list has no message', () {
      for (final params in <Map<String, Object?>>[
        {},
        {'documents': <String>[]},
        {'documents': 'P12'},
        {
          'documents': ['P12', 3],
        },
      ]) {
        expect(
          localizeProblem(problem(code, params), env.es, env.fmtEs),
          isNull,
          reason: '$params',
        );
      }
    });
  });

  group('pac.rejected', () {
    final code = api.ErrorCode.pacPeriodRejected;

    test("shows the PAC's code and message as the PAC wrote them", () {
      final p = problem(code, {
        'pac_code': '301',
        'pac_message': 'XML mal formado: «Rfc» no válido',
      });

      expect(
        localizeProblem(p, env.es, env.fmtEs),
        'El PAC rechazó la solicitud: 301 · «XML mal formado: «Rfc» no '
        'válido».',
      );
      expect(
        localizeProblem(p, env.en, env.fmtEn),
        contains('XML mal formado: «Rfc» no válido'),
      );
    });

    test('a missing code or message has no message', () {
      for (final params in <Map<String, Object?>>[
        {},
        {'pac_code': '301'},
        {'pac_message': 'x'},
        {'pac_code': 301, 'pac_message': 'x'},
      ]) {
        expect(
          localizeProblem(problem(code, params), env.es, env.fmtEs),
          isNull,
          reason: '$params',
        );
      }
    });
  });

  group('fiscal_document.unknown_cancellation_reason', () {
    final code = api.ErrorCode.fiscalDocumentPeriodUnknownCancellationReason;

    test('names the reason', () {
      expect(
        localizeProblem(problem(code, {'reason': '09'}), env.es, env.fmtEs),
        'El motivo de cancelación «09» no es válido.',
      );
    });

    test('a missing reason has no message', () {
      expect(localizeProblem(problem(code, {}), env.es, env.fmtEs), isNull);
    });
  });

  test('pac.timeout, pac.unavailable and substitution_invalid are fixed '
      'sentences that ignore their params', () {
    for (final code in [
      api.ErrorCode.pacPeriodTimeout,
      api.ErrorCode.pacPeriodUnavailable,
      api.ErrorCode.fiscalDocumentPeriodSubstitutionInvalid,
    ]) {
      expect(
        localizeProblem(problem(code, {}), env.es, env.fmtEs),
        isNotEmpty,
        reason: code.name,
      );
      expect(
        localizeProblem(
          problem(code, {'state': 'stamping'}),
          env.es,
          env.fmtEs,
        ),
        isNotEmpty,
        reason: code.name,
      );
    }
  });
}
