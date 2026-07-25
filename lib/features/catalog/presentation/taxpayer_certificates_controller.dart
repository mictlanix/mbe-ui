import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';

part 'taxpayer_certificates_controller.g.dart';

/// Loads the open issuer's certificates for the Certificates section
/// (US3, FR-019, FR-020) — a family provider keyed by RFC, scoped to that
/// issuer only. No search/pagination: a per-issuer collection is small and
/// bounded, unlike a top-level catalog list (FR-020, research §9). Refreshed
/// (via `ref.invalidate`) after a successful upload.
@riverpod
class TaxpayerCertificatesController extends _$TaxpayerCertificatesController {
  @override
  Future<List<TaxpayerCertificate>> build(String rfc) {
    return ref.read(taxpayerCertificateRepositoryProvider).listForIssuer(rfc);
  }
}
