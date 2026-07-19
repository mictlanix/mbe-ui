import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/label_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockLabelRepository extends Mock implements LabelRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.labels, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.labels, rawValue: 15)],
);

const _existing = Label(labelId: 1, name: 'Clearance', comment: 'Sale');

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockLabelRepository repository;

  setUp(() {
    repository = MockLabelRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? labelId,
    bool forceReadOnly = false,
  }) async {
    if (labelId != null) {
      when(
        () => repository.get(labelId: labelId),
      ).thenAnswer((_) async => _existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          labelRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LabelDetailScreen(
              labelId: labelId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('create mode', () {
    testWidgets('shows an empty form with Save and no Delete', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('label_name_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_label_button')), findsNothing);
    });
  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'renders fields disabled with no Save/Delete, and the AppBar carries '
      'only the edit toggle (constitution v1.8.0)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          labelId: 1,
          forceReadOnly: true,
        );

        final nameField = tester.widget<TextFormField>(
          find.byKey(const Key('label_name_field')),
        );
        expect(nameField.enabled, isFalse);
        expect(find.byKey(const Key('save_button')), findsNothing);
        expect(find.byKey(const Key('delete_label_button')), findsNothing);
        expect(find.byKey(const Key('edit_label_button')), findsOneWidget);
      },
    );
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, labelId: 1);

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('label_name_field')),
      );
      expect(nameField.enabled, isFalse);
      expect(find.byKey(const Key('delete_label_button')), findsNothing);
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a still-assigned rejection leaves the form in place',
      (tester) async {
        when(() => repository.delete(labelId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Label is assigned to a product',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, labelId: 1);

        expect(find.byKey(const Key('delete_label_button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('delete_label_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_delete_label_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('label_name_field')), findsOneWidget);
      },
    );
  });
}
