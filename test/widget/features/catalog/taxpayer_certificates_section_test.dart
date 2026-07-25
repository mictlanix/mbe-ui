import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_certificate_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificates_section.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockTaxpayerCertificateRepository extends Mock
    implements TaxpayerCertificateRepository {}

const _createUser = User(
  userId: 'creator',
  email: 'creator@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // create + read on taxpayers.
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 3)],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 2)],
);

final _certificates = [
  TaxpayerCertificate(
    taxpayerCertificateId: '00001000000203341766',
    taxpayer: 'XAXX010101000',
    validFrom: DateTime(2025, 1, 1),
    validTo: DateTime(2029, 1, 1),
    status: EntityStatus.active,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockTaxpayerCertificateRepository repository;

  setUp(() {
    repository = MockTaxpayerCertificateRepository();
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    required User signedInAs,
    bool readOnly = false,
    List<TaxpayerCertificate> certificates = const [],
  }) async {
    when(
      () => repository.listForIssuer('XAXX010101000'),
    ).thenAnswer((_) async => certificates);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taxpayerCertificateRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TaxpayerCertificatesSection(
                rfc: 'XAXX010101000',
                readOnly: readOnly,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the issuer\'s certificates read-only, with no per-row '
      'Edit or Delete action (FR-024)', (tester) async {
    await pumpSection(
      tester,
      signedInAs: _createUser,
      certificates: _certificates,
    );

    expect(find.text('00001000000203341766'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets('the section has no taxpayer picker and no search box — it is a '
      'bounded per-issuer collection (FR-020)', (tester) async {
    await pumpSection(
      tester,
      signedInAs: _createUser,
      certificates: _certificates,
    );

    expect(find.byType(CatalogEntityPicker), findsNothing);
    expect(find.byType(CatalogSearchBar), findsNothing);
  });

  testWidgets('an empty section shows its empty state', (tester) async {
    await pumpSection(tester, signedInAs: _createUser, certificates: const []);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.noCertificatesFound), findsOneWidget);
    expect(find.byKey(const Key('taxpayer_certificates_table')), findsNothing);
  });

  testWidgets('the Agregar action is hidden without taxpayers create '
      'privilege (FR-025)', (tester) async {
    await pumpSection(
      tester,
      signedInAs: _readOnlyUser,
      certificates: _certificates,
    );

    expect(find.byKey(const Key('add_certificate_button')), findsNothing);
  });

  testWidgets('the Agregar action is hidden when the issuer detail is '
      'read-only, EVEN with create privilege (FR-025, Acceptance Scenario 8)', (
    tester,
  ) async {
    await pumpSection(
      tester,
      signedInAs: _createUser,
      readOnly: true,
      certificates: _certificates,
    );

    expect(find.byKey(const Key('add_certificate_button')), findsNothing);
  });

  testWidgets('the Agregar action is shown with create privilege on an '
      'editable (not read-only) issuer', (tester) async {
    await pumpSection(
      tester,
      signedInAs: _createUser,
      readOnly: false,
      certificates: _certificates,
    );

    expect(find.byKey(const Key('add_certificate_button')), findsOneWidget);
  });
}
