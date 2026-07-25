import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_certificate_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificate_upload_controller.dart';

class MockTaxpayerCertificateRepository extends Mock
    implements TaxpayerCertificateRepository {}

void main() {
  late MockTaxpayerCertificateRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockTaxpayerCertificateRepository();
    container = ProviderContainer(
      overrides: [
        taxpayerCertificateRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  group('TaxpayerCertificateUploadController', () {
    test('taxpayer is fixed to the open issuer, not user-editable (FR-021)', () {
      final state = container.read(
        taxpayerCertificateUploadControllerProvider('XAXX010101000'),
      );
      expect(state.taxpayer, 'XAXX010101000');
    });

    test('both files and a password are required before submit (FR-023)', () async {
      final notifier = container.read(
        taxpayerCertificateUploadControllerProvider('XAXX010101000').notifier,
      );

      await notifier.submit();

      final state = container.read(
        taxpayerCertificateUploadControllerProvider('XAXX010101000'),
      );
      expect(
        state.fieldErrors['certificate'],
        TaxpayerCertificateUploadErrorCode.certificateFileRequired,
      );
      expect(
        state.fieldErrors['key'],
        TaxpayerCertificateUploadErrorCode.keyFileRequired,
      );
      expect(
        state.fieldErrors['keyPassword'],
        TaxpayerCertificateUploadErrorCode.keyPasswordRequired,
      );
      verifyNever(() => repository.upload(
        taxpayer: any(named: 'taxpayer'),
        certificateBytes: any(named: 'certificateBytes'),
        keyBytes: any(named: 'keyBytes'),
        keyPassword: any(named: 'keyPassword'),
      ));
    });

    test('a valid submission uploads the raw bytes for the open issuer', () async {
      when(
        () => repository.upload(
          taxpayer: 'XAXX010101000',
          certificateBytes: [1, 2, 3],
          keyBytes: [4, 5, 6],
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

      final notifier = container.read(
        taxpayerCertificateUploadControllerProvider('XAXX010101000').notifier,
      );
      notifier
        ..certificateFilePicked([1, 2, 3], 'cert.cer')
        ..keyFilePicked([4, 5, 6], 'key.key')
        ..keyPasswordChanged('secret');

      await notifier.submit();

      final state = container.read(
        taxpayerCertificateUploadControllerProvider('XAXX010101000'),
      );
      expect(state.uploaded?.taxpayerCertificateId, 'CERT1');
    });

    test('a server rejection (invalid pair/wrong password) is surfaced '
        'while preserving the file selection (FR-023)', () async {
      when(
        () => repository.upload(
          taxpayer: 'XAXX010101000',
          certificateBytes: any(named: 'certificateBytes'),
          keyBytes: any(named: 'keyBytes'),
          keyPassword: any(named: 'keyPassword'),
        ),
      ).thenThrow(
        const AppError.server(statusCode: 400, message: 'Wrong key password'),
      );

      final notifier = container.read(
        taxpayerCertificateUploadControllerProvider('XAXX010101000').notifier,
      );
      notifier
        ..certificateFilePicked([1, 2, 3], 'cert.cer')
        ..keyFilePicked([4, 5, 6], 'key.key')
        ..keyPasswordChanged('wrong');

      await notifier.submit();

      final state = container.read(
        taxpayerCertificateUploadControllerProvider('XAXX010101000'),
      );
      expect(state.error, TaxpayerCertificateUploadErrorCode.uploadFailed);
      // The selection is preserved — not cleared on rejection.
      expect(state.certificateFileName, 'cert.cer');
      expect(state.keyFileName, 'key.key');
      expect(state.uploaded, isNull);
    });
  });
}
