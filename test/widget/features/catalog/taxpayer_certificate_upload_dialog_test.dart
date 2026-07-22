import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_certificate_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificate_upload_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificate_upload_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockTaxpayerCertificateRepository extends Mock
    implements TaxpayerCertificateRepository {}

const _createUser = User(
  userId: 'creator',
  email: 'creator@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 3)],
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockTaxpayerCertificateRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockTaxpayerCertificateRepository();
    container = ProviderContainer(
      overrides: [
        taxpayerCertificateRepositoryProvider.overrideWithValue(repository),
        accessControlProvider.overrideWithValue(_accessFor(_createUser)),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showTaxpayerCertificateUploadDialog(
                  context,
                  rfc: 'XAXX010101000',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('submit is disabled until both files and a password are set '
      '(FR-023)', (tester) async {
    await pumpDialog(tester);

    // No repository call yet — nothing has been selected.
    await tester.tap(find.byKey(const Key('upload_certificate_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repository.upload(
      taxpayer: any(named: 'taxpayer'),
      certificateBytes: any(named: 'certificateBytes'),
      keyBytes: any(named: 'keyBytes'),
      keyPassword: any(named: 'keyPassword'),
    ));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.certificateFileRequiredError), findsOneWidget);
    expect(find.text(l10n.keyFileRequiredError), findsOneWidget);
    expect(find.text(l10n.keyPasswordRequiredError), findsOneWidget);
  });

  testWidgets('the taxpayer is fixed to the open issuer — no picker or '
      'selector is rendered for it (FR-021)', (tester) async {
    await pumpDialog(tester);

    expect(find.text('XAXX010101000'), findsNothing);
    // The dialog exposes exactly the three input surfaces (cert file, key
    // file, password) plus Cancel/Submit — no taxpayer field of any kind.
    expect(find.byKey(const Key('certificate_file_field')), findsOneWidget);
    expect(find.byKey(const Key('key_file_field')), findsOneWidget);
    expect(find.byKey(const Key('key_password_field')), findsOneWidget);
  });

  testWidgets('a valid submission uploads and closes the dialog', (
    tester,
  ) async {
    when(
      () => repository.upload(
        taxpayer: 'XAXX010101000',
        certificateBytes: any(named: 'certificateBytes'),
        keyBytes: any(named: 'keyBytes'),
        keyPassword: 'secret',
      ),
    ).thenAnswer(
      (_) async => TaxpayerCertificate(
        taxpayerCertificateId: 'CERT1',
        taxpayer: 'XAXX010101000',
        validFrom: DateTime(2025, 1, 1),
        validTo: DateTime(2029, 1, 1),
        status: EntityStatus.active,
      ),
    );

    await pumpDialog(tester);

    // Driving the platform file picker isn't feasible in a widget test —
    // seed the selection directly on the controller (the address
    // inline-create dialog's precedent for pickers it can't drive either).
    container
        .read(
          taxpayerCertificateUploadControllerProvider(
            'XAXX010101000',
          ).notifier,
        )
        .certificateFilePicked([1, 2, 3], 'cert.cer');
    container
        .read(
          taxpayerCertificateUploadControllerProvider(
            'XAXX010101000',
          ).notifier,
        )
        .keyFilePicked([4, 5, 6], 'key.key');
    await tester.enterText(
      find.byKey(const Key('key_password_field')),
      'secret',
    );

    await tester.tap(find.byKey(const Key('upload_certificate_button')));
    await tester.pumpAndSettle();

    verify(
      () => repository.upload(
        taxpayer: 'XAXX010101000',
        certificateBytes: [1, 2, 3],
        keyBytes: [4, 5, 6],
        keyPassword: 'secret',
      ),
    ).called(1);
    // The dialog pops itself on success (constitution §VI-adjacent).
    expect(find.byKey(const Key('upload_certificate_button')), findsNothing);
  });

  testWidgets('a server rejection is surfaced while preserving the file '
      'selection (FR-023)', (tester) async {
    when(
      () => repository.upload(
        taxpayer: any(named: 'taxpayer'),
        certificateBytes: any(named: 'certificateBytes'),
        keyBytes: any(named: 'keyBytes'),
        keyPassword: any(named: 'keyPassword'),
      ),
    ).thenThrow(
      const AppError.server(statusCode: 400, message: 'Wrong key password'),
    );

    await pumpDialog(tester);

    container
        .read(
          taxpayerCertificateUploadControllerProvider(
            'XAXX010101000',
          ).notifier,
        )
        .certificateFilePicked([1, 2, 3], 'cert.cer');
    container
        .read(
          taxpayerCertificateUploadControllerProvider(
            'XAXX010101000',
          ).notifier,
        )
        .keyFilePicked([4, 5, 6], 'key.key');
    await tester.enterText(
      find.byKey(const Key('key_password_field')),
      'wrong',
    );

    await tester.tap(find.byKey(const Key('upload_certificate_button')));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.certificateUploadFailedError), findsOneWidget);
    expect(find.text('cert.cer'), findsOneWidget);
    expect(find.text('key.key'), findsOneWidget);
  });
}
