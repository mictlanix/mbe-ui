import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_test_env.dart';

void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  ApiProblem problem(api.ErrorCode code, Map<String, Object?> params) =>
      ApiProblem(codeName: code.name, code: code, params: params);

  const params = {'year': 2026, 'month': 10};

  test('not_ended names the month in Spanish and English', () {
    final p = problem(api.ErrorCode.commissionPeriodPeriodNotEnded, params);

    expect(
      localizeProblem(p, env.es, env.fmtEs),
      'Todavía no termina octubre de 2026; no se puede cerrar.',
    );
    expect(localizeProblem(p, env.en, env.fmtEn), contains('October 2026'));
  });

  test('previous_not_closed and later_closed carry the month', () {
    final previous = problem(
      api.ErrorCode.commissionPeriodPeriodPreviousNotClosed,
      params,
    );
    final later = problem(
      api.ErrorCode.commissionPeriodPeriodLaterClosed,
      params,
    );

    expect(
      localizeProblem(previous, env.es, env.fmtEs),
      contains('octubre de 2026'),
    );
    expect(
      localizeProblem(later, env.es, env.fmtEs),
      'Ya hay un mes posterior a octubre de 2026 cerrado.',
    );
    expect(localizeProblem(later, env.en, env.fmtEn), contains('October 2026'));
  });

  test('a missing or mistyped month has no message', () {
    for (final bad in [
      {'year': 2026},
      {'month': 10},
      {'year': 2026, 'month': 'ten'},
    ]) {
      expect(
        localizeProblem(
          problem(api.ErrorCode.commissionPeriodPeriodNotEnded, bad),
          env.es,
          env.fmtEs,
        ),
        isNull,
      );
    }
  });

  test('salesperson_not_agent names the employee', () {
    expect(
      localizeProblem(
        problem(api.ErrorCode.commissionAgentPeriodSalespersonNotAgent, {
          'salesperson_id': 7,
        }),
        env.es,
        env.fmtEs,
      ),
      'El empleado #7 no es agente de comisiones.',
    );
  });
}
