import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/contact_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/contact_inline_create.dart';
import 'package:mbe_ui/features/catalog/presentation/label_form.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockLabelRepository extends Mock implements LabelRepository {}

class MockContactRepository extends Mock implements ContactRepository {}

const _editor = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.labels, rawValue: 15)],
);

/// Spec 058 User Story 2: a form keeps the server's refusal and builds its
/// text when it shows it, so the reason is localized and follows a change of
/// language, while a refusal the app does not know stays as it was.
void main() {
  late MockLabelRepository labels;
  late SharedPreferences prefs;
  final locale = ValueNotifier<Locale>(const Locale('es', 'MX'));

  setUp(() async {
    await initializeDateFormatting();
    labels = MockLabelRepository();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    locale.value = const Locale('es', 'MX');
  });

  void failCreateWith(AppError error) => when(
    () => labels.create(
      name: any(named: 'name'),
      comment: any(named: 'comment'),
    ),
  ).thenThrow(error);

  Future<void> pumpLabelForm(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          labelRepositoryProvider.overrideWithValue(labels),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(token: 't', user: _editor),
            ),
          ),
        ],
        child: ValueListenableBuilder<Locale>(
          valueListenable: locale,
          builder: (context, value, _) => MaterialApp(
            locale: value,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: LabelForm()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('label_name_field')),
      'Clearance',
    );
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();
  }

  group('a form refused by the server with a code the app knows', () {
    const alreadyExists = AppError.server(
      statusCode: 409,
      message: 'A label with that name already exists',
      problem: ApiProblem(
        codeName: 'resource.already_exists',
        code: api.ErrorCode.resourcePeriodAlreadyExists,
        params: {'resource': 'label', 'field': 'name'},
      ),
    );

    testWidgets('shows its own headline and the localized reason, with no '
        'English (scenario 1)', (tester) async {
      failCreateWith(alreadyExists);
      await pumpLabelForm(tester);
      await submit(tester);

      expect(find.text('No se pudo crear la etiqueta.'), findsOneWidget);
      expect(
        find.text('Ese valor ya está en uso en otra etiqueta.'),
        findsOneWidget,
      );
      expect(find.textContaining('already exists'), findsNothing);
    });

    testWidgets('re-renders in the new language when the language changes '
        'with the error on screen, without resubmitting (scenario 2)', (
      tester,
    ) async {
      failCreateWith(alreadyExists);
      await pumpLabelForm(tester);
      await submit(tester);
      expect(find.textContaining('en uso'), findsOneWidget);

      locale.value = const Locale('en', 'US');
      await tester.pumpAndSettle();

      expect(find.text('Failed to create label.'), findsOneWidget);
      expect(
        find.text('That value is already in use. Another label has it.'),
        findsOneWidget,
      );
      expect(find.textContaining('en uso'), findsNothing);
      verify(
        () => labels.create(
          name: any(named: 'name'),
          comment: any(named: 'comment'),
        ),
      ).called(1);
    });
  });

  testWidgets('a code the app does not know shows the headline and the server '
      'English, as before (scenario 3)', (tester) async {
    failCreateWith(
      const AppError.server(
        statusCode: 409,
        message: 'Some new English refusal',
        problem: ApiProblem(codeName: 'future.not_yet_invented'),
      ),
    );
    await pumpLabelForm(tester);
    await submit(tester);

    expect(find.text('No se pudo crear la etiqueta.'), findsOneWidget);
    expect(find.text('Some new English refusal'), findsOneWidget);
  });

  testWidgets('an error the app raises itself is unchanged (scenario 4)', (
    tester,
  ) async {
    await pumpLabelForm(tester);
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.text('El nombre es obligatorio.'), findsOneWidget);
    expect(find.text('No se pudo crear la etiqueta.'), findsNothing);
    verifyNever(
      () => labels.create(
        name: any(named: 'name'),
        comment: any(named: 'comment'),
      ),
    );
  });

  testWidgets('a field-level refusal with a known validation type shows the '
      'localized message at the field (scenario 5)', (tester) async {
    final contacts = MockContactRepository();
    when(
      () => contacts.create(
        name: any(named: 'name'),
        jobTitle: any(named: 'jobTitle'),
        phone: any(named: 'phone'),
        mobile: any(named: 'mobile'),
        email: any(named: 'email'),
      ),
    ).thenThrow(
      const AppError.validation([
        FieldError(
          loc: ['body', 'name'],
          msg: 'Name must not be blank',
          type: 'contact_name_blank',
        ),
      ]),
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [contactRepositoryProvider.overrideWithValue(contacts)],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showContactInlineCreateDialog(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('contact_name_field')),
      'Ana López',
    );
    await tester.enterText(
      find.byKey(const Key('contact_mobile_field')),
      '5512345678',
    );
    await tester.tap(find.byKey(const Key('contact_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('El nombre no puede estar vacío.'), findsOneWidget);
    expect(find.textContaining('must not be blank'), findsNothing);
  });
}
