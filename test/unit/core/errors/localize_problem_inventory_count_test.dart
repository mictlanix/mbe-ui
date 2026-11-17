import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_test_env.dart';

void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  test('no_lines with resource inventory_count is masculine', () {
    const problem = ApiProblem(
      codeName: 'inventory_document.no_lines',
      code: api.ErrorCode.inventoryDocumentPeriodNoLines,
      params: {'resource': 'inventory_count'},
    );

    expect(
      localizeProblem(problem, env.es, env.fmtEs),
      'El conteo no tiene partidas.',
    );
  });
}
