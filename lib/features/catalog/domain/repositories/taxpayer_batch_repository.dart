import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';

/// Taxpayer batch (folio series) maintenance, consumed **only** as a
/// per-issuer child collection of the Taxpayer Issuer detail's Series section
/// (spec 065) — the API nests it at `/taxpayer-issuers/{rfc}/batches` and has
/// no list of its own. [listForIssuer] wraps the generated list; [create] and
/// [update] take a [TaxpayerBatchDraft] and convert its kind to the wire enum
/// internally, so callers never see the generated `FiscalDocumentType`.
///
/// An update or delete of a series already used by fiscal documents is
/// refused by the server (`taxpayer_batch.in_use`); callers recognise that by
/// the error's `problem.code`.
abstract class TaxpayerBatchRepository {
  Future<List<TaxpayerBatch>> listForIssuer(String rfc);

  Future<TaxpayerBatch> create(String rfc, TaxpayerBatchDraft draft);

  Future<TaxpayerBatch> update(
    String rfc,
    int taxpayerBatchId,
    TaxpayerBatchDraft draft,
  );

  Future<void> delete(String rfc, int taxpayerBatchId);
}
