import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_certificate_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificates_controller.dart';

class MockTaxpayerCertificateRepository extends Mock
    implements TaxpayerCertificateRepository {}

TaxpayerCertificate _certificate(String id) => TaxpayerCertificate(
  taxpayerCertificateId: id,
  taxpayer: 'XAXX010101000',
  validFrom: DateTime(2025, 1, 1),
  validTo: DateTime(2029, 1, 1),
  status: EntityStatus.active,
);

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

  group('TaxpayerCertificatesController', () {
    test('build() scopes to the given RFC and performs exactly one '
        'listForIssuer call — no per-row lookup (FR-020, FR-026, SC-006)', () async {
      when(
        () => repository.listForIssuer('XAXX010101000'),
      ).thenAnswer((_) async => [_certificate('CERT1')]);

      final result = await container.read(
        taxpayerCertificatesControllerProvider('XAXX010101000').future,
      );

      expect(result, hasLength(1));
      verify(() => repository.listForIssuer('XAXX010101000')).called(1);
      verifyNever(() => repository.upload(
        taxpayer: any(named: 'taxpayer'),
        certificateBytes: any(named: 'certificateBytes'),
        keyBytes: any(named: 'keyBytes'),
        keyPassword: any(named: 'keyPassword'),
      ));
    });

    test('a different RFC gets its own independent provider instance '
        '(family scoping)', () async {
      when(
        () => repository.listForIssuer('XAXX010101000'),
      ).thenAnswer((_) async => [_certificate('CERT1')]);
      when(
        () => repository.listForIssuer('BBB010101B01'),
      ).thenAnswer((_) async => <TaxpayerCertificate>[]);

      final resultA = await container.read(
        taxpayerCertificatesControllerProvider('XAXX010101000').future,
      );
      final resultB = await container.read(
        taxpayerCertificatesControllerProvider('BBB010101B01').future,
      );

      expect(resultA, hasLength(1));
      expect(resultB, isEmpty);
    });
  });
}
