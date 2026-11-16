import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';

part 'taxpayer_batches_controller.g.dart';

/// Loads the open issuer's series for the Series section (spec 065 US1,
/// FR-001) — a family provider keyed by RFC, scoped to that issuer only. No
/// search or pagination: a per-issuer collection is small and bounded.
/// Refreshed (via `ref.invalidate`) after a save, a delete, or a refusal that
/// shows the list is stale.
///
/// Sorted by document kind (the enum's order, an unknown code last), then by
/// series (research R5): the server orders by series only, and an
/// administrator wants to see which kinds are covered at a glance.
@riverpod
class TaxpayerBatchesController extends _$TaxpayerBatchesController {
  @override
  Future<List<TaxpayerBatch>> build(String rfc) async {
    final batches = await ref
        .read(taxpayerBatchRepositoryProvider)
        .listForIssuer(rfc);
    return sortTaxpayerBatches(batches);
  }
}

/// [batches] ordered by kind, then series, then id. Never mutates [batches].
List<TaxpayerBatch> sortTaxpayerBatches(List<TaxpayerBatch> batches) {
  int rank(TaxpayerBatch b) {
    final kind = b.kind;
    return kind == null ? FiscalDocumentKind.values.length : kind.index;
  }

  return [...batches]..sort((a, b) {
    final byKind = rank(a).compareTo(rank(b));
    if (byKind != 0) return byKind;
    final bySeries = a.series.compareTo(b.series);
    return bySeries != 0
        ? bySeries
        : a.taxpayerBatchId.compareTo(b.taxpayerBatchId);
  });
}
