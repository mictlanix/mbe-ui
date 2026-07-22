import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode): register a taxpayer issuer,
/// add a certificate to it from what the issuer detail's Certificates
/// section would call, then create a facility and a payment method option
/// under it (tasks.md T060; spec 015 US1–US3).
///
/// Requires mbe-api running at [apiBaseUrl] (default `http://127.0.0.1:8000`)
/// and a user with create+delete rights on `Taxpayers`/`PaymentMethodOptions`/
/// `Facilities`/`Addresses`, in an environment already seeded with at least
/// one SAT tax regime and one SAT postal code. Configure via `--dart-define`:
///   --dart-define=MBE_CATALOG_TEST_USERNAME=...
///   --dart-define=MBE_CATALOG_TEST_PASSWORD=...
///
/// The certificate-upload step additionally needs a real CSD test pair on
/// disk (e.g. the SAT test certificates) — optional, since a CSD pair isn't
/// always available in every environment:
///   --dart-define=MBE_CSD_CERTIFICATE_PATH=/path/to/test.cer
///   --dart-define=MBE_CSD_KEY_PATH=/path/to/test.key
///   --dart-define=MBE_CSD_KEY_PASSWORD=...
/// When these are absent, the issuer/facility/payment-method-option path is
/// still exercised — only the certificate-upload assertion is skipped, with
/// a note (research §8's byte→string encoding is confirmed there when run).
///
/// Skipped entirely when login credentials aren't provided — this test
/// creates and then deletes real records, so it must never run unattended
/// against an unknown environment.
const _username = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');
const _certPath = String.fromEnvironment('MBE_CSD_CERTIFICATE_PATH');
const _keyPath = String.fromEnvironment('MBE_CSD_KEY_PATH');
const _keyPassword = String.fromEnvironment('MBE_CSD_KEY_PASSWORD');

const _canRun = _username != '' && _password != '';
const _canRunCertificateStep =
    _certPath != '' && _keyPath != '' && _keyPassword != '';

void main() {
  test('create taxpayer issuer → [add its certificate] → create facility → '
      'create payment method option', () async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';

    final satRepository = SatCatalogRepositoryImpl(dio);
    final taxpayerIssuerRepository = TaxpayerIssuerRepositoryImpl(dio);
    final taxpayerCertificateRepository = TaxpayerCertificateRepositoryImpl(
      dio,
    );
    final addressRepository = AddressRepositoryImpl(dio);
    final facilityRepository = FacilityRepositoryImpl(dio);
    final paymentMethodOptionRepository = PaymentMethodOptionRepositoryImpl(
      dio,
    );
    final addressesApi = AddressesApi(dio, standardSerializers);

    final suffix = DateTime.now().millisecondsSinceEpoch;
    final rfc = 'XAXX$suffix'.substring(0, 13.clamp(0, 'XAXX$suffix'.length));

    // Prerequisites the seeded environment must provide.
    final regime = (await satRepository.listTaxRegimes()).items.first;
    final postalCode = (await satRepository.listPostalCodes()).items.first;

    // 1. US2 — register a taxpayer issuer (FR-011).
    final issuer = await taxpayerIssuerRepository.create(
      rfc: rfc,
      name: 'Integration Issuer',
      regime: regime.code,
      postalCode: postalCode.code,
    );
    expect(issuer.rfc, rfc);

    // 2. US3 — add a certificate to that issuer, exactly as the issuer
    // detail's Certificates section's Agregar action would (FR-021,
    // research §8's byte→string encoding).
    if (_canRunCertificateStep) {
      final certificate = await taxpayerCertificateRepository.upload(
        taxpayer: issuer.rfc,
        certificateBytes: await File(_certPath).readAsBytes(),
        keyBytes: await File(_keyPath).readAsBytes(),
        keyPassword: _keyPassword,
      );
      expect(certificate.taxpayer, issuer.rfc);

      final certificates = await taxpayerCertificateRepository.listForIssuer(
        issuer.rfc,
      );
      expect(
        certificates.map((c) => c.taxpayerCertificateId),
        contains(certificate.taxpayerCertificateId),
      );
    }

    // 3. US1 depends on a facility — create one using this issuer as its
    // taxpayer (spec-014 precedent: a facility needs an address + taxpayer).
    final address = await addressRepository.create(
      AddressCreatePayload(
        street: 'Integration Street',
        exteriorNumber: '$suffix',
        postalCode: postalCode.code,
        neighborhood: 'Centro',
        borough: 'Cuauhtémoc',
        addressState: 'CDMX',
        country: 'México',
      ),
    );
    final facility = await facilityRepository.create(
      code: 'FAC-$suffix',
      name: 'Integration Facility',
      location: postalCode.code,
      address: address.addressId,
      taxpayer: issuer.rfc,
    );

    // 4. US1 — create a payment method option under that facility (FR-003).
    final option = await paymentMethodOptionRepository.create(
      facilityId: facility.facilityId,
      name: 'Integration Cash Option',
      paymentMethod: 1, // Cash
    );
    expect(option.facilityId, facility.facilityId);
    expect(option.facilityName, 'Integration Facility');

    // Cleanup: delete in reverse dependency order. The certificate itself is
    // never deleted (immutable, FR-024) — only its owning issuer, once
    // nothing else references it.
    await paymentMethodOptionRepository.delete(
      paymentMethodOptionId: option.paymentMethodOptionId,
    );
    await facilityRepository.delete(facilityId: facility.facilityId);
    await addressesApi.deleteAddressApiV1AddressesAddressIdDelete(
      addressId: address.addressId,
    );
    // The issuer itself is intentionally left in place if a certificate was
    // registered against it above (deleting an issuer with certificates may
    // be rejected server-side, spec Edge Cases) — only clean it up when the
    // certificate step didn't run.
    if (!_canRunCertificateStep) {
      await taxpayerIssuerRepository.delete(issuer.rfc);
    }
  }, skip: !_canRun);
}
