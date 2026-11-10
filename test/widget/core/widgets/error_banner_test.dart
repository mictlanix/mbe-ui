import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
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

  testWidgets('a validation entry with a localized type shows the localized '
      'text; any other entry keeps its server message (spec 058)', (
    tester,
  ) async {
    await _pump(
      tester,
      const AppError.validation([
        FieldError(
          loc: ['body', 'barcode'],
          msg: 'Barcode must be empty or exactly 13 digits (EAN-13)',
          type: 'product_barcode_invalid',
        ),
        FieldError(
          loc: ['body', 'name'],
          msg: 'Field required',
          type: 'missing',
        ),
      ]),
      locale: const Locale('es'),
    );

    expect(
      find.text(
        'El código de barras debe estar vacío o tener exactamente 13 dígitos '
        '(EAN-13).',
      ),
      findsOneWidget,
    );
    expect(find.text('Field required'), findsOneWidget);
    expect(find.textContaining('Barcode must be'), findsNothing);
  });

  group('ErrorBanner with a coded server refusal (spec 058)', () {
    const english = 'Customer is on credit hold: 4 overdue credit order(s)';

    AppError creditHold({Object? count = 4}) => AppError.creditHold(
      english,
      ApiProblem(
        codeName: 'customer.credit_hold',
        code: api.ErrorCode.customerPeriodCreditHold,
        params: {'customer_id': 812, 'overdue_count': count},
      ),
    );

    Future<void> pumpCoded(
      WidgetTester tester,
      AppError error, {
      Locale locale = const Locale('es', 'MX'),
      String datePattern = 'yyyy-MM-dd',
    }) async {
      await initializeDateFormatting();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appSettingsProvider.overrideWithValue(
              AppSettings(
                apiBaseUrl: 'x',
                photosBaseUrl: 'x',
                posDefaultCustomerId: 1,
                brand: const BrandConfig(displayName: 'X'),
                defaultLocale: locale,
                formatting: FormattingSettings(datePattern: datePattern),
              ),
            ),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: ErrorBanner(error: error)),
          ),
        ),
      );
    }

    testWidgets('a known code in Spanish shows only the localized message', (
      tester,
    ) async {
      await pumpCoded(tester, creditHold());

      expect(
        find.text(
          'Este cliente tiene 4 pedidos a crédito vencidos. Liquídalos antes '
          'de crear un nuevo pedido a crédito.',
        ),
        findsOneWidget,
      );
      // Neither the generic headline nor the server's English line.
      expect(find.textContaining('credit hold'), findsNothing);
      expect(find.text('Este cliente no puede recibir crédito'), findsNothing);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('the same code in English shows the English message from the '
        "app's own text", (tester) async {
      await pumpCoded(tester, creditHold(), locale: const Locale('en', 'US'));

      expect(
        find.text(
          'This customer has 4 overdue credit orders. Settle them before '
          'creating a new credit order.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Customer is on credit hold'), findsNothing);
    });

    testWidgets('amounts and dates follow the formatting settings', (
      tester,
    ) async {
      await pumpCoded(
        tester,
        AppError.validation(
          const [],
          'Some English',
          ApiProblem(
            codeName: 'supplier_agreement.end_before_start',
            code: api.ErrorCode.supplierAgreementPeriodEndBeforeStart,
            params: const {'start': '2026-01-31', 'end': '2025-12-31'},
          ),
        ),
        datePattern: 'dd/MM/yyyy',
      );

      expect(
        find.text(
          'La fecha de fin (31/12/2025) es anterior a la de inicio '
          '(31/01/2026).',
        ),
        findsOneWidget,
      );

      await pumpCoded(
        tester,
        AppError.validation(
          const [],
          'Some English',
          ApiProblem(
            codeName: 'customer.credit_limit_exceeded',
            code: api.ErrorCode.customerPeriodCreditLimitExceeded,
            params: const {'outstanding': '18450.00', 'limit': '15000.00'},
          ),
        ),
      );
      expect(find.textContaining(r'$18,450.00'), findsOneWidget);
    });

    testWidgets('a code the app does not know shows the generic headline and '
        'the English detail, as before', (tester) async {
      await pumpCoded(
        tester,
        const AppError.server(
          statusCode: 409,
          message: 'Some new English refusal',
          problem: ApiProblem(codeName: 'future.not_yet_invented'),
        ),
      );

      expect(
        find.text(
          'Ocurrió un error en el servidor. Inténtalo de nuevo más tarde.',
        ),
        findsOneWidget,
      );
      expect(find.text('Some new English refusal'), findsOneWidget);
    });

    testWidgets('a body with no code at all shows what it showed before', (
      tester,
    ) async {
      await pumpCoded(
        tester,
        const AppError.server(statusCode: 409, message: 'Plain English'),
      );

      expect(find.text('Plain English'), findsOneWidget);
    });

    testWidgets('a known code with a mistyped param falls back instead of '
        'failing', (tester) async {
      await pumpCoded(tester, creditHold(count: 'four'));

      expect(tester.takeException(), isNull);
      expect(find.text(english), findsOneWidget);
      expect(
        find.text('Este cliente no puede recibir crédito en este momento.'),
        findsOneWidget,
      );
    });
  });
}
