import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list_delete_preview.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_form.dart';
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

    // The delete review dialog's formattersProvider (spec 028) reads through
    // resolvedLocaleProvider, which needs a real SharedPreferences instance.
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          priceListRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PriceListForm(
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
    testWidgets(
      'renders fields disabled with no Save/Delete, and the edit toggle '
      'appears in the record action area — this form has no AppBar of its '
      'own at all now (spec 035)',
      (tester) async {
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
        expect(find.byKey(const Key('edit_price_list_button')), findsOneWidget);

        expect(find.byType(AppBar), findsNothing);
      },
    );

    testWidgets(
      'the form carries no profit-margin fields — retired with the '
      'sales-order validation that read them (spec 033 US7/FR-034, '
      'mbe-api#185)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          priceListId: 1,
          forceReadOnly: true,
        );

        expect(
          find.byKey(const Key('price_list_high_margin_field')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('price_list_low_margin_field')),
          findsNothing,
        );
        // The name field is untouched — the record is still editable.
        expect(find.byKey(const Key('price_list_name_field')), findsOneWidget);
      },
    );
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
      'a user with delete privilege sees the Delete button, and it opens '
      'the review dialog (specs/034-price-list-retirement-ui, replacing '
      'the old plain confirmation)',
      (tester) async {
        when(
          () => repository.deletePreview(priceListId: 1),
        ).thenAnswer(
          (_) async => const PriceListDeletePreview(
            categories: [
              PriceListDeleteCategory(key: 'product_price.list', count: 4312),
            ],
            total: 4312,
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, priceListId: 1);

        expect(
          find.byKey(const Key('delete_price_list_button')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('delete_price_list_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('price_list_delete_dialog')), findsOneWidget);
        expect(find.byKey(const Key('price_list_delete_summary')), findsOneWidget);
      },
    );

    testWidgets(
      'confirming a server rejection leaves the dialog open and the form '
      'in place (US1 §6)',
      (tester) async {
        when(
          () => repository.deletePreview(priceListId: 1),
        ).thenAnswer(
          (_) async => const PriceListDeletePreview(
            categories: [
              PriceListDeleteCategory(key: 'product_price.list', count: 4312),
            ],
            total: 4312,
          ),
        );
        when(
          () => repository.delete(
            priceListId: 1,
            replacement: any(named: 'replacement'),
          ),
        ).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Price list is assigned to a customer',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, priceListId: 1);
        await tester.tap(find.byKey(const Key('delete_price_list_button')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('price_list_delete_confirm')));
        await tester.pumpAndSettle();

        // Still on the detail screen, and the dialog is still open with the
        // refusal shown — the deletion did not go through.
        expect(find.byKey(const Key('price_list_name_field')), findsOneWidget);
        expect(find.byKey(const Key('price_list_delete_dialog')), findsOneWidget);
        expect(
          find.textContaining('Price list is assigned to a customer'),
          findsOneWidget,
        );
      },
    );
  });

  group('in-panel Edit toggle (spec 035 FR-027/FR-028)', () {
    testWidgets(
      'pressing Edit on a read-only form makes it editable in place — no '
      'navigation, since there is no route to navigate to anymore',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          priceListId: 1,
          forceReadOnly: true,
        );

        expect(
          tester
              .widget<TextFormField>(
                find.byKey(const Key('price_list_name_field')),
              )
              .enabled,
          isFalse,
        );

        await tester.tap(find.byKey(const Key('edit_price_list_button')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<TextFormField>(
                find.byKey(const Key('price_list_name_field')),
              )
              .enabled,
          isTrue,
        );
        expect(find.byKey(const Key('save_button')), findsOneWidget);
      },
    );
  });

  group('isDirty (spec 035 FR-032, data-model.md §3)', () {
    testWidgets('false immediately after a create-mode form mounts', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final key = GlobalKey<PriceListFormPanelState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            priceListRepositoryProvider.overrideWithValue(repository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PriceListForm(key: key)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);
    });

    testWidgets('false until loading finishes, then true after a field edit', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final key = GlobalKey<PriceListFormPanelState>();
      when(
        () => repository.get(priceListId: 1),
      ).thenAnswer((_) async => _existing);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            priceListRepositoryProvider.overrideWithValue(repository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PriceListForm(key: key, priceListId: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);

      await tester.enterText(
        find.byKey(const Key('price_list_name_field')),
        'Retail (updated)',
      );
      await tester.pump();

      expect(key.currentState!.isDirty(), isTrue);
    });
  });
}
