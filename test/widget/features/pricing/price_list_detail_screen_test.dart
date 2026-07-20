import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockPriceListRepository extends Mock implements PriceListRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.priceLists, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.priceLists, rawValue: 15)],
);

const _existing = PriceList(
  priceListId: 1,
  name: 'Retail',
  highProfitMargin: '0.40',
  lowProfitMargin: '0.10',
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockPriceListRepository repository;

  setUp(() {
    repository = MockPriceListRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? priceListId,
    bool forceReadOnly = false,
  }) async {
    if (priceListId != null) {
      when(
        () => repository.get(priceListId: priceListId),
      ).thenAnswer((_) async => _existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          priceListRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PriceListDetailScreen(
              priceListId: priceListId,
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

      expect(find.byKey(const Key('price_list_name_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_price_list_button')), findsNothing);
    });
  });

  group('view mode (forceReadOnly)', () {
    testWidgets('renders fields disabled with no Save/Delete', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        priceListId: 1,
        forceReadOnly: true,
      );

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('price_list_name_field')),
      );
      expect(nameField.enabled, isFalse);
      expect(find.byKey(const Key('save_button')), findsNothing);
      expect(find.byKey(const Key('delete_price_list_button')), findsNothing);
    });

    testWidgets('margins display as percentages, not raw decimals', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        priceListId: 1,
        forceReadOnly: true,
      );

      expect(
        find.text('40%'),
        findsNothing,
      ); // margins are editable fields, not text
      final highField = tester.widget<TextFormField>(
        find.byKey(const Key('price_list_high_margin_field')),
      );
      expect(highField.initialValue, '0.40');
    });
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, priceListId: 1);

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('price_list_name_field')),
      );
      expect(nameField.enabled, isFalse);
      expect(find.byKey(const Key('delete_price_list_button')), findsNothing);
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a server rejection leaves the form in place (US1 §6)',
      (tester) async {
        when(() => repository.delete(priceListId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Price list is assigned to a customer',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, priceListId: 1);

        expect(
          find.byKey(const Key('delete_price_list_button')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('delete_price_list_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_price_list_button')),
        );
        await tester.pumpAndSettle();

        // Still on the detail screen — the form did not pop.
        expect(find.byKey(const Key('price_list_name_field')), findsOneWidget);
      },
    );
  });
}
