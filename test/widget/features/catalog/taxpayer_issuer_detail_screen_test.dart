import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus, ValidationError;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_certificate_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuer_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuer_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockTaxpayerIssuerRepository extends Mock
    implements TaxpayerIssuerRepository {}

class MockSatCatalogRepository extends Mock implements SatCatalogRepository {}

class MockTaxpayerCertificateRepository extends Mock
    implements TaxpayerCertificateRepository {}

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 15)],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 2)],
);

const _issuer = TaxpayerIssuer(
  rfc: 'XAXX010101000',
  name: 'Acme Corp',
  provider: FiscalCertificationProvider.number0,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockTaxpayerIssuerRepository repository;
  late MockSatCatalogRepository satRepository;
  late MockTaxpayerCertificateRepository certificateRepository;

  setUp(() {
    repository = MockTaxpayerIssuerRepository();
    satRepository = MockSatCatalogRepository();
    certificateRepository = MockTaxpayerCertificateRepository();
    when(
      () => certificateRepository.listForIssuer(any()),
    ).thenAnswer((_) async => const <TaxpayerCertificate>[]);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    String? rfc,
    bool forceReadOnly = false,
  }) async {
    if (rfc != null) {
      when(() => repository.getDetail(rfc)).thenAnswer((_) async => _issuer);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taxpayerIssuerRepositoryProvider.overrideWithValue(repository),
          satCatalogRepositoryProvider.overrideWithValue(satRepository),
          taxpayerCertificateRepositoryProvider.overrideWithValue(
            certificateRepository,
          ),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TaxpayerIssuerDetailScreen(
              rfc: rfc,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('RFC is editable on create', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    final rfcField = tester.widget<TextFormField>(
      find.byKey(const Key('rfc_field')),
    );
    expect(rfcField.enabled, isTrue);
  });

  testWidgets('RFC is disabled once editing an existing issuer (FR-012)', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, rfc: 'XAXX010101000');

    final rfcField = tester.widget<TextFormField>(
      find.byKey(const Key('rfc_field')),
    );
    expect(rfcField.enabled, isFalse);
  });

  testWidgets('the Certificates section is ABSENT on the create form '
      '(FR-025, Acceptance Scenario 2)', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byType(TextFormField).evaluate().isNotEmpty, isTrue);
    expect(find.text('Certificates'), findsNothing);
  });

  testWidgets('the Certificates section IS present on an existing issuer', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, rfc: 'XAXX010101000');

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.certificatesSectionTitle), findsOneWidget);
  });

  testWidgets('a user without update privilege gets no edit toggle', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _readOnlyUser,
      rfc: 'XAXX010101000',
      forceReadOnly: true,
    );

    expect(find.byKey(const Key('edit_taxpayer_issuer_button')), findsNothing);
  });

  testWidgets('delete requires a confirmation dialog before submit (FR-016)', (
    tester,
  ) async {
    when(
      () => repository.getDetail('XAXX010101000'),
    ).thenAnswer((_) async => _issuer);
    when(() => repository.delete('XAXX010101000')).thenAnswer((_) async {});

    final router = GoRouter(
      initialLocation: '/taxpayer-issuers',
      routes: [
        GoRoute(
          path: '/taxpayer-issuers',
          builder: (_, _) => const Scaffold(body: Text('taxpayer issuers list')),
        ),
        GoRoute(
          path: '/taxpayer-issuers/:rfc',
          builder: (_, state) => TaxpayerIssuerDetailScreen(
            rfc: state.pathParameters['rfc'],
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taxpayerIssuerRepositoryProvider.overrideWithValue(repository),
          satCatalogRepositoryProvider.overrideWithValue(satRepository),
          taxpayerCertificateRepositoryProvider.overrideWithValue(
            certificateRepository,
          ),
          accessControlProvider.overrideWithValue(_accessFor(_fullAccessUser)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/taxpayer-issuers/XAXX010101000');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete_taxpayer_issuer_button')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    verifyNever(() => repository.delete('XAXX010101000'));

    await tester.tap(
      find.byKey(const Key('confirm_delete_taxpayer_issuer_button')),
    );
    await tester.pumpAndSettle();

    verify(() => repository.delete('XAXX010101000')).called(1);
    expect(find.text('taxpayer issuers list'), findsOneWidget);
  });

  testWidgets('a duplicate-RFC server rejection is surfaced on the form '
      'without discarding input (FR-017)', (tester) async {
    when(
      () => repository.create(
        rfc: any(named: 'rfc'),
        name: any(named: 'name'),
        regime: any(named: 'regime'),
        provider: any(named: 'provider'),
        postalCode: any(named: 'postalCode'),
        comment: any(named: 'comment'),
      ),
    ).thenThrow(
      const AppError.validation([
        FieldError(
          loc: ['body', 'taxpayer_issuer_id'],
          msg: 'Taxpayer issuer already exists',
          type: 'value_error',
        ),
      ]),
    );

    final container = ProviderContainer(
      overrides: [
        taxpayerIssuerRepositoryProvider.overrideWithValue(repository),
        satCatalogRepositoryProvider.overrideWithValue(satRepository),
        taxpayerCertificateRepositoryProvider.overrideWithValue(
          certificateRepository,
        ),
        accessControlProvider.overrideWithValue(_accessFor(_fullAccessUser)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TaxpayerIssuerDetailScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    container
        .read(taxpayerIssuerFormControllerProvider.notifier)
        .regimeSelected('601', 'General de Ley');
    await tester.enterText(
      find.byKey(const Key('rfc_field')),
      'XAXX010101000',
    );
    await tester.enterText(find.byKey(const Key('name_field')), 'Duplicate');

    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Taxpayer issuer already exists'), findsOneWidget);
  });
}
