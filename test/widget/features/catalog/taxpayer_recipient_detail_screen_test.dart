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
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

class MockSatCatalogRepository extends Mock implements SatCatalogRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 15),
  ],
);

const _existing = TaxpayerRecipient(
  taxpayerRecipientId: 'XAXX010101000',
  name: 'Acme Corp',
  email: 'test@example.com',
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockTaxpayerRecipientRepository repository;
  late MockSatCatalogRepository satRepository;

  setUp(() {
    repository = MockTaxpayerRecipientRepository();
    satRepository = MockSatCatalogRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    String? taxpayerRecipientId,
    bool forceReadOnly = false,
  }) async {
    if (taxpayerRecipientId != null) {
      when(
        () => repository.get(taxpayerRecipientId: taxpayerRecipientId),
      ).thenAnswer((_) async => _existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taxpayerRecipientRepositoryProvider.overrideWithValue(repository),
          satCatalogRepositoryProvider.overrideWithValue(satRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TaxpayerRecipientDetailScreen(
              taxpayerRecipientId: taxpayerRecipientId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('create mode', () {
    testWidgets('shows an editable id field, Save, and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      final idField = tester.widget<TextFormField>(
        find.byKey(const Key('taxpayer_recipient_id_field')),
      );
      expect(idField.enabled, isTrue);
      expect(find.byKey(const Key('postal_code_field')), findsOneWidget);
      expect(find.byKey(const Key('regime_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(
        find.byKey(const Key('delete_taxpayer_recipient_button')),
        findsNothing,
      );
    });
  });

  group('view mode (forceReadOnly)', () {
    testWidgets('renders the id read-only, with no Save/Delete, and the AppBar '
        'carries only the edit toggle (constitution v1.8.0)', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        taxpayerRecipientId: 'XAXX010101000',
        forceReadOnly: true,
      );

      final idField = tester.widget<TextFormField>(
        find.byKey(const Key('taxpayer_recipient_id_field')),
      );
      expect(idField.enabled, isFalse);
      expect(idField.initialValue, 'XAXX010101000');
      expect(find.byKey(const Key('save_button')), findsNothing);
      expect(
        find.byKey(const Key('delete_taxpayer_recipient_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('edit_taxpayer_recipient_button')),
        findsOneWidget,
      );
    });
  });

  group('edit mode', () {
    testWidgets('the id field is not editable even with update privilege '
        '(immutable, research.md §9)', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        taxpayerRecipientId: 'XAXX010101000',
      );

      final idField = tester.widget<TextFormField>(
        find.byKey(const Key('taxpayer_recipient_id_field')),
      );
      expect(idField.enabled, isFalse);
    });

    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _readOnlyUser,
        taxpayerRecipientId: 'XAXX010101000',
      );

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('taxpayer_recipient_name_field')),
      );
      expect(nameField.enabled, isFalse);
      expect(
        find.byKey(const Key('delete_taxpayer_recipient_button')),
        findsNothing,
      );
    });

    testWidgets(
      'a user with delete privilege sees the Delete button and confirming '
      'opens the confirm dialog',
      (tester) async {
        when(
          () => repository.delete(taxpayerRecipientId: 'XAXX010101000'),
        ).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Taxpayer recipient is referenced by a fiscal document',
          ),
        );

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          taxpayerRecipientId: 'XAXX010101000',
        );

        expect(
          find.byKey(const Key('delete_taxpayer_recipient_button')),
          findsOneWidget,
        );
        await tester.ensureVisible(
          find.byKey(const Key('delete_taxpayer_recipient_button')),
        );
        await tester.tap(
          find.byKey(const Key('delete_taxpayer_recipient_button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('confirm_delete_taxpayer_recipient_button')),
          findsOneWidget,
        );
      },
    );
  });
}
