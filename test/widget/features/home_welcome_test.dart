import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/home/presentation/home_welcome.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTokenStorage extends Mock implements TokenStorage {}

const _user = User(
  userId: 'rramos',
  email: 'rramos@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

void main() {
  late _MockAuthRepository authRepository;
  late _MockTokenStorage tokenStorage;

  setUp(() {
    authRepository = _MockAuthRepository();
    tokenStorage = _MockTokenStorage();
    // Default: signed-out session, so the dashboard's greeting resolves
    // without touching real platform-channel storage. Tests exercising the
    // greeting override tokenStorage.read()/authRepository.me() before
    // calling pumpWelcome.
    when(() => tokenStorage.read()).thenAnswer((_) async => null);
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  Future<void> pumpWelcome(
    WidgetTester tester, {
    required BrandConfig brand,
    Size size = const Size(1000, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          brandConfigProvider.overrideWithValue(brand),
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: HomeWelcome()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('welcomeAsset configured — unchanged deployment-branded layout', () {
    testWidgets(
      'shows the configured display name and image, not the XBE dashboard',
      (tester) async {
        await pumpWelcome(
          tester,
          brand: const BrandConfig(
            displayName: 'CASA MAESTRA',
            welcomeAsset: 'assets/branding/default_welcome.png',
          ),
        );

        expect(find.text('CASA MAESTRA'), findsOneWidget);
        expect(find.byKey(const Key('home_welcome_default')), findsNothing);
        // None of the XBE dashboard's static content leaks into a
        // welcomeAsset-configured deployment (isolation — spec 019 FR-007).
        expect(find.byKey(const Key('home_greeting_card')), findsNothing);
        expect(find.byKey(const Key('home_dashboard_tiles')), findsNothing);
        expect(find.byKey(const Key('home_activity_feed')), findsNothing);
      },
    );

    testWidgets('falls back to the bundled placeholder image on load failure', (
      tester,
    ) async {
      await pumpWelcome(
        tester,
        brand: const BrandConfig(
          displayName: 'CASA MAESTRA',
          welcomeAsset: 'assets/branding/does_not_exist.png',
        ),
      );

      expect(find.byKey(const Key('home_welcome_default')), findsOneWidget);
    });
  });

  group(
    'no welcomeAsset (XBE default build) — dashboard (spec 019 FR-015/016)',
    () {
      const defaultBrand = BrandConfig(
        displayName: 'Mictlanix Business Essentials',
      );

      testWidgets('renders the greeting card instead of the old placeholder', (
        tester,
      ) async {
        await pumpWelcome(tester, brand: defaultBrand);

        expect(find.byKey(const Key('home_greeting_card')), findsOneWidget);
        expect(find.byKey(const Key('home_welcome_default')), findsNothing);
      });

      testWidgets(
        'greeting reflects the signed-in user, not a hardcoded name',
        (tester) async {
          when(() => tokenStorage.read()).thenAnswer((_) async => 'token');
          when(() => authRepository.me()).thenAnswer((_) async => _user);

          await pumpWelcome(tester, brand: defaultBrand);

          expect(find.textContaining('rramos'), findsOneWidget);
        },
      );

      testWidgets('renders all 4 static indicator tiles verbatim', (
        tester,
      ) async {
        await pumpWelcome(tester, brand: defaultBrand);

        expect(find.byKey(const Key('home_dashboard_tiles')), findsOneWidget);
        expect(find.text('Ventas de hoy'), findsOneWidget);
        expect(find.text(r'$184,320'), findsOneWidget);
        expect(find.text('Listas por autorizar'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('Productos activos'), findsOneWidget);
        expect(find.text('21,542'), findsOneWidget);
        expect(find.text('Instalaciones activas'), findsOneWidget);
        expect(find.text('9 / 14'), findsOneWidget);
      });

      testWidgets('renders all 4 static recent-activity entries verbatim', (
        tester,
      ) async {
        await pumpWelcome(tester, brand: defaultBrand);

        expect(find.byKey(const Key('home_activity_feed')), findsOneWidget);
        expect(
          find.text('Lista de precios «Mayoreo Q3» enviada a autorización'),
          findsOneWidget,
        );
        expect(
          find.text('38 productos GREENFIELD actualizados por importación'),
          findsOneWidget,
        );
        expect(find.text('Corte de caja CMC3 cerrado'), findsOneWidget);
        expect(
          find.text('Alta de empleado: J. Domínguez · CMHU'),
          findsOneWidget,
        );
      });
    },
  );

  testWidgets('renders no navigation list (regression: old Home nav)', (
    tester,
  ) async {
    await pumpWelcome(
      tester,
      brand: const BrandConfig(displayName: 'Mictlanix Business Essentials'),
    );

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('renders without overflow at narrow and wide widths', (
    tester,
  ) async {
    await pumpWelcome(
      tester,
      brand: const BrandConfig(displayName: 'Mictlanix Business Essentials'),
      size: const Size(400, 800),
    );
    expect(tester.takeException(), isNull);

    await pumpWelcome(
      tester,
      brand: const BrandConfig(displayName: 'Mictlanix Business Essentials'),
      size: const Size(1400, 900),
    );
    expect(tester.takeException(), isNull);
  });
}
