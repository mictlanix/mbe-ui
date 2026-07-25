import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';

part 'taxpayer_certificate.freezed.dart';

/// A CSD (Certificado de Sello Digital) fiscal signing certificate, belonging
/// to a taxpayer issuer — data-model.md §3. Displayed **only** inside the
/// Taxpayer Issuer detail's Certificates section, scoped to the open
/// issuer's RFC (research §9); there is no standalone list/detail screen.
/// Mapped from `TaxpayerCertificateResponse`. Immutable — never edited or
/// deleted through this feature (FR-024); superseded by uploading a newer
/// one.
@freezed
class TaxpayerCertificate with _$TaxpayerCertificate {
  const factory TaxpayerCertificate({
    required String taxpayerCertificateId,
    required String taxpayer,
    required DateTime validFrom,
    required DateTime validTo,
    required EntityStatus status,
  }) = _TaxpayerCertificate;

  factory TaxpayerCertificate.fromResponse(TaxpayerCertificateResponse r) =>
      TaxpayerCertificate(
        taxpayerCertificateId: r.taxpayerCertificateId,
        taxpayer: r.taxpayer,
        validFrom: r.validFrom,
        validTo: r.validTo,
        status: EntityStatus.fromApi(r.status),
      );
}

/// The certificate-upload dialog's form input (FR-021, FR-022) — never
/// persisted directly; the registered number/validity are server-derived
/// and only appear afterward in the resulting [TaxpayerCertificate].
/// [taxpayer] is fixed to the open issuer's RFC, not re-selected (FR-021).
@freezed
class CertificateUpload with _$CertificateUpload {
  const factory CertificateUpload({
    required String taxpayer,
    List<int>? certificateBytes,
    String? certificateFileName,
    List<int>? keyBytes,
    String? keyFileName,
    @Default('') String keyPassword,
  }) = _CertificateUpload;
}
