import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';

part 'taxpayer_batch.freezed.dart';

/// A bank account printed on a series' documents: one entry of the print
/// template's `extra_info` (spec 065 data-model.md). Free text, not linked
/// to the company's bank-account records. Mapped from `BatchAccount`.
@freezed
abstract class TaxpayerBatchAccount with _$TaxpayerBatchAccount {
  const TaxpayerBatchAccount._();

  const factory TaxpayerBatchAccount({
    @Default('') String bank,
    @Default('') String account,
    @Default('') String clabe,
    @Default('') String currency,
  }) = _TaxpayerBatchAccount;

  factory TaxpayerBatchAccount.fromResponse(BatchAccount a) =>
      TaxpayerBatchAccount(
        bank: a.bank ?? '',
        account: a.account ?? '',
        clabe: a.clabe ?? '',
        currency: a.currency ?? '',
      );

  /// Whether every field is empty once trimmed — such a row is dropped on
  /// save rather than stored as an empty account (FR-007).
  bool get isBlank =>
      bank.trim().isEmpty &&
      account.trim().isEmpty &&
      clabe.trim().isEmpty &&
      currency.trim().isEmpty;
}

/// How the documents of a series are printed (spec 065 data-model.md).
/// Mapped from `BatchTemplate`.
@freezed
abstract class TaxpayerBatchTemplate with _$TaxpayerBatchTemplate {
  const factory TaxpayerBatchTemplate({
    required String name,

    /// A file name the print service looks up, not an upload. `null` is no
    /// logo.
    String? logo,

    /// Millimetres, ≥ 0. The API's default is 0.
    @Default(0) int headerHeight,

    /// Millimetres, ≥ 0. The API's default is 15.
    @Default(15) int footerHeight,

    /// In the order they print.
    @Default(<TaxpayerBatchAccount>[]) List<TaxpayerBatchAccount> accounts,
  }) = _TaxpayerBatchTemplate;

  factory TaxpayerBatchTemplate.fromResponse(BatchTemplate t) =>
      TaxpayerBatchTemplate(
        name: t.name,
        logo: t.logo,
        headerHeight: t.headerHeight ?? 0,
        footerHeight: t.footerHeight ?? 15,
        accounts: [
          for (final a in t.extraInfo ?? const <BatchAccount>[])
            TaxpayerBatchAccount.fromResponse(a),
        ],
      );
}

/// A folio series of a taxpayer issuer — one prefix numbering one kind of
/// fiscal document, with its print template (spec 065, FR-001). Displayed
/// only inside the Taxpayer Issuer detail's Series section. Mapped from
/// `TaxpayerBatchResponse`.
@freezed
abstract class TaxpayerBatch with _$TaxpayerBatch {
  const factory TaxpayerBatch({
    required int taxpayerBatchId,

    /// The issuer's RFC.
    required String taxpayer,

    /// The prefix (the API's `batch`): 1–10 characters, unique per issuer.
    required String series,

    /// The raw API code, kept so a code this app doesn't know still renders.
    required int typeCode,

    /// `null` for an unknown [typeCode].
    required FiscalDocumentKind? kind,
    required TaxpayerBatchTemplate template,

    /// Once any of the issuer's fiscal documents carries the series, its
    /// prefix and kind are locked and it can't be deleted (FR-010, FR-014).
    required bool inUse,
  }) = _TaxpayerBatch;

  factory TaxpayerBatch.fromResponse(TaxpayerBatchResponse r) => TaxpayerBatch(
    taxpayerBatchId: r.taxpayerBatchId,
    taxpayer: r.taxpayer,
    series: r.batch,
    typeCode: r.type,
    kind: FiscalDocumentKind.fromCode(r.type),
    template: TaxpayerBatchTemplate.fromResponse(r.template),
    inUse: r.inUse,
  );
}

/// The input of a create or update: what the dialog sends. Never persisted
/// directly — the saved series comes back as a [TaxpayerBatch].
@freezed
abstract class TaxpayerBatchDraft with _$TaxpayerBatchDraft {
  const factory TaxpayerBatchDraft({
    required String series,
    required FiscalDocumentKind kind,
    required TaxpayerBatchTemplate template,
  }) = _TaxpayerBatchDraft;
}
