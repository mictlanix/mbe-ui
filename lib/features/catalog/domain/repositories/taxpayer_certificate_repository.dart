import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';

/// Taxpayer Certificate (CSD) management, consumed **only** as a per-issuer
/// child collection of the Taxpayer Issuer detail's Certificates section
/// (data-model.md §3, contracts/mbe-api-catalogs.md §3, research §9) — not a
/// standalone catalog. [listForIssuer] wraps the generated `list(taxpayer:
/// rfc)`; [upload] registers a new CSD pair, taking the raw file bytes and
/// encoding them to the wire's `String` fields internally (base64-of-DER;
/// research §8) — callers never handle the encoding. **No `update`, no
/// `delete`** — `TaxpayerCertificatesApi` exposes neither: a CSD is
/// immutable, superseded by uploading a newer one (FR-024).
abstract class TaxpayerCertificateRepository {
  Future<List<TaxpayerCertificate>> listForIssuer(String rfc);

  Future<TaxpayerCertificate> upload({
    required String taxpayer,
    required List<int> certificateBytes,
    required List<int> keyBytes,
    required String keyPassword,
  });
}
