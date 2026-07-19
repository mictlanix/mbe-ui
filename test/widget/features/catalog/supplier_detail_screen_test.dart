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
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 15)],
);

const _existing = Supplier(
  supplierId: 1,
  code: 'SUP-001',
  name: 'Acme Corp',
  creditLimit: '1000.50',
  creditDays: 30,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockSupplierRepository repository;

  setUp(() {
    repository = MockSupplierRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? supplierId,
    bool forceReadOnly = false,
  }) async {
    if (supplierId != null) {
      when(
        () => repository.get(supplierId: supplierId),
      ).thenAnswer((_) async => _existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supplierRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SupplierDetailScreen(
              supplierId: supplierId,
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

      expect(find.byKey(const Key('code_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_supplier_button')), findsNothing);
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
          supplierId: 1,
          forceReadOnly: true,
        );

        final codeField = tester.widget<TextFormField>(
          find.byKey(const Key('code_field')),
        );
        expect(codeField.enabled, isFalse);
        expect(find.byKey(const Key('save_button')), findsNothing);
        expect(find.byKey(const Key('delete_supplier_button')), findsNothing);
        expect(find.byKey(const Key('edit_supplier_button')), findsOneWidget);
      },
    );
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, supplierId: 1);

      final codeField = tester.widget<TextFormField>(
        find.byKey(const Key('code_field')),
      );
      expect(codeField.enabled, isFalse);
      expect(find.byKey(const Key('delete_supplier_button')), findsNothing);
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a server rejection leaves the form in place (US1 §6)',
      (tester) async {
        when(() => repository.delete(supplierId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Supplier is referenced by a product',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, supplierId: 1);

        expect(find.byKey(const Key('delete_supplier_button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('delete_supplier_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_supplier_button')),
        );
        await tester.pumpAndSettle();

        // Still on the detail screen — the form did not pop.
        expect(find.byKey(const Key('code_field')), findsOneWidget);
      },
    );
  });
}
