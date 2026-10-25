import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/contact_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/contact_inline_create.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockContactRepository extends Mock implements ContactRepository {}

void main() {
  late MockContactRepository repository;
  late bool closed;

  setUp(() {
    repository = MockContactRepository();
    closed = false;
  });

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [contactRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await showContactInlineCreateDialog(context);
                    closed = true;
                  },
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
  }

  testWidgets('a failure keeps the dialog open with its input and an '
      'ErrorBanner', (tester) async {
    when(
      () => repository.create(
        name: any(named: 'name'),
        jobTitle: any(named: 'jobTitle'),
        phone: any(named: 'phone'),
        mobile: any(named: 'mobile'),
        email: any(named: 'email'),
      ),
    ).thenThrow(const AppError.server(statusCode: 500, message: 'down'));
    await openDialog(tester);

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

    expect(closed, isFalse);
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('contact_name_field')),
        matching: find.text('Ana López'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('contact_mobile_field')),
        matching: find.text('5512345678'),
      ),
      findsOneWidget,
    );
  });
}
