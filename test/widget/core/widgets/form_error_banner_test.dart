import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/widgets/form_error_banner.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _alreadyExists = AppError.server(
  statusCode: 409,
  message: 'A warehouse with that code already exists',
  problem: ApiProblem(
    codeName: 'resource.already_exists',
    code: api.ErrorCode.resourcePeriodAlreadyExists,
    params: {'resource': 'warehouse', 'field': 'code'},
  ),
);

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pump(
    WidgetTester tester, {
    required String headline,
    AppError? cause,
    Locale locale = const Locale('es', 'MX'),
  }) => tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FormErrorBanner(headline: headline, cause: cause),
        ),
      ),
    ),
  );

  testWidgets('no cause: the headline alone', (tester) async {
    await pump(tester, headline: 'No se pudo guardar.');

    expect(find.text('No se pudo guardar.'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('a known code: the headline and the localized reason, with no '
      'English', (tester) async {
    await pump(tester, headline: 'No se pudo guardar.', cause: _alreadyExists);

    expect(find.text('No se pudo guardar.'), findsOneWidget);
    expect(
      find.text('Ese valor ya está en uso en otro almacén.'),
      findsOneWidget,
    );
    expect(find.textContaining('already exists'), findsNothing);
  });

  testWidgets('the reason follows a change of language without a new '
      'request', (tester) async {
    await pump(tester, headline: 'No se pudo guardar.', cause: _alreadyExists);
    expect(
      find.text('Ese valor ya está en uso en otro almacén.'),
      findsOneWidget,
    );

    await pump(
      tester,
      headline: "Couldn't save.",
      cause: _alreadyExists,
      locale: const Locale('en', 'US'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('That value is already in use. Another warehouse has it.'),
      findsOneWidget,
    );
    expect(find.textContaining('Ese valor'), findsNothing);
  });

  testWidgets('an unknown code: the headline and the server English, as '
      'before', (tester) async {
    await pump(
      tester,
      headline: 'No se pudo guardar.',
      cause: const AppError.server(
        statusCode: 409,
        message: 'Some new English refusal',
        problem: ApiProblem(codeName: 'future.not_yet_invented'),
      ),
    );

    expect(find.text('No se pudo guardar.'), findsOneWidget);
    expect(find.text('Some new English refusal'), findsOneWidget);
  });

  testWidgets('a field-level validation refusal: the headline only, the '
      'fields carry the rest', (tester) async {
    await pump(
      tester,
      headline: 'No se pudo guardar.',
      cause: const AppError.validation([
        FieldError(
          loc: ['body', 'code'],
          msg: 'Too short',
          type: 'string_short',
        ),
      ]),
    );

    expect(find.text('No se pudo guardar.'), findsOneWidget);
    expect(find.text('Too short'), findsNothing);
  });

  testWidgets('a network failure shows no raw exception text', (tester) async {
    await pump(
      tester,
      headline: 'No se pudo guardar.',
      cause: const AppError.network('SocketException: Connection refused'),
    );

    expect(find.text('No se pudo guardar.'), findsOneWidget);
    expect(find.textContaining('SocketException'), findsNothing);
  });
}
