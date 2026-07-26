import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester,
  AppError error, {
  Locale locale = const Locale('en'),
}) {
  return tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ErrorBanner(error: error)),
    ),
  );
}

void main() {
  group('ErrorBanner localization (017-ui-consistency-filters, research §6)', () {
    testWidgets(
      'renders the localized English message for each generic variant',
      (tester) async {
        await _pump(tester, const AppError.auth());
        expect(find.text('Invalid username or password.'), findsOneWidget);

        await _pump(tester, const AppError.notFound());
        expect(find.text('The requested item was not found.'), findsOneWidget);

        await _pump(tester, const AppError.server());
        expect(
          find.text(
            'Something went wrong on the server. Please try again later.',
          ),
          findsOneWidget,
        );

        await _pump(tester, const AppError.network());
        expect(
          find.text(
            'Could not reach the server. Check your connection and try again.',
          ),
          findsOneWidget,
        );

        await _pump(tester, const AppError.validation([]));
        expect(
          find.text('Please correct the highlighted fields.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders the localized Spanish message for each generic variant',
      (tester) async {
        const es = Locale('es');

        await _pump(tester, const AppError.auth(), locale: es);
        expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);

        await _pump(tester, const AppError.notFound(), locale: es);
        expect(
          find.text('No se encontró el elemento solicitado.'),
          findsOneWidget,
        );

        await _pump(tester, const AppError.server(), locale: es);
        expect(
          find.text(
            'Ocurrió un error en el servidor. Inténtalo de nuevo más tarde.',
          ),
          findsOneWidget,
        );

        await _pump(tester, const AppError.network(), locale: es);
        expect(
          find.text(
            'No se pudo conectar con el servidor. Verifica tu conexión e inténtalo de nuevo.',
          ),
          findsOneWidget,
        );

        await _pump(tester, const AppError.validation([]), locale: es);
        expect(find.text('Corrige los campos marcados.'), findsOneWidget);
      },
    );

    testWidgets(
      'ValidationError with field errors shows the server-provided messages, not the generic one',
      (tester) async {
        await _pump(
          tester,
          const AppError.validation([
            FieldError(loc: ['name'], msg: 'Name is required', type: 'missing'),
          ]),
        );
        expect(find.text('Name is required'), findsOneWidget);
        expect(
          find.text('Please correct the highlighted fields.'),
          findsNothing,
        );
      },
    );
  });
}
