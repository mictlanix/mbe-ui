import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_cancellation.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_stamp.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/sat_cancellation_reason.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart'
    show wireDate, wireDateEnd;

final fiscalDocumentRepositoryProvider = Provider<FiscalDocumentRepository>((
  ref,
) {
  return FiscalDocumentRepositoryImpl(ref.watch(dioProvider));
});

/// `FiscalDocumentRepository` over the generated `FiscalDocumentsApi`
/// (spec 066 research R3).
class FiscalDocumentRepositoryImpl implements FiscalDocumentRepository {
  FiscalDocumentRepositoryImpl(Dio dio)
    : _api = api.FiscalDocumentsApi(dio, appSerializers);

  final api.FiscalDocumentsApi _api;

  @override
  Future<FiscalDocumentPage> list({
    String? search,
    String? issuer,
    int? type,
    FiscalDocumentStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listFiscalDocumentsApiV1FiscalDocumentsGet(
        search: search,
        issuer: issuer,
        type: type,
        status: status?.wireName,
        dateFrom: dateFrom == null ? null : wireDate(dateFrom),
        dateTo: dateTo == null ? null : wireDateEnd(dateTo),
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return FiscalDocumentPage(
        items: result.items.map(_summary).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<FiscalDocument> getById(int id) => _document(
    () => _api.getFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdGet(
      fiscalDocumentId: id,
    ),
  );

  @override
  Future<XmlDownload> downloadXml(int id) async {
    try {
      final response = await _api
          .downloadFiscalDocumentXmlApiV1FiscalDocumentsFiscalDocumentIdXmlGet(
            fiscalDocumentId: id,
          );
      final bytes = response.data;
      if (bytes == null) throw const AppError.server();
      return XmlDownload(
        bytes: bytes,
        filename: _filenameFrom(response.headers),
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<FiscalDocument> create(NewInvoice invoice) => _document(
    () => _api.createInvoiceApiV1FiscalDocumentsPost(
      invoiceCreate: api.InvoiceCreate(
        (b) => b
          ..customer = invoice.customerId
          ..recipient = invoice.recipientRfc,
      ),
    ),
  );

  @override
  Future<FiscalDocument> createCreditNote(int invoiceId) => _document(
    () => _api.createCreditNoteApiV1FiscalDocumentsCreditNotesPost(
      creditNoteCreate: api.CreditNoteCreate((b) => b.invoice = invoiceId),
    ),
  );

  @override
  Future<FiscalDocument> createPaymentReceipt(NewPaymentReceipt receipt) =>
      _document(
        () => _api.createPaymentReceiptApiV1FiscalDocumentsPaymentReceiptsPost(
          paymentReceiptCreate: api.PaymentReceiptCreate(
            (b) => b
              ..customer = receipt.customerId
              ..recipient = receipt.recipientRfc
              ..customerPayment = receipt.customerPaymentId,
          ),
        ),
      );

  @override
  Future<FiscalDocument> addPaidInvoice(
    int id,
    int invoiceId, {
    Decimal? amount,
  }) => _document(
    () =>
        _api.addPaidInvoiceApiV1FiscalDocumentsFiscalDocumentIdPaidInvoicesPost(
          fiscalDocumentId: id,
          paidInvoiceAdd: api.PaidInvoiceAdd((b) {
            b.invoice = invoiceId;
            if (amount != null) {
              b.amount = api.Amount3(
                (a) => a.anyOf = AnyOf2<String, num>(values: {0: '$amount'}),
              ).toBuilder();
            }
          }),
        ),
  );

  @override
  Future<FiscalDocument> updatePaidInvoice(
    int id,
    int relationId,
    Decimal amount,
  ) => _document(
    () => _api
        .updatePaidInvoiceApiV1FiscalDocumentsFiscalDocumentIdPaidInvoicesRelationIdPut(
          fiscalDocumentId: id,
          relationId: relationId,
          paidInvoiceUpdate: api.PaidInvoiceUpdate(
            (b) => b
              ..amount = api.Amount4(
                (a) => a.anyOf = AnyOf2<String, num>(values: {0: '$amount'}),
              ).toBuilder(),
          ),
        ),
  );

  @override
  Future<FiscalDocument> removePaidInvoice(int id, int relationId) => _document(
    () => _api
        .removePaidInvoiceApiV1FiscalDocumentsFiscalDocumentIdPaidInvoicesRelationIdDelete(
          fiscalDocumentId: id,
          relationId: relationId,
        ),
  );

  @override
  Future<FiscalDocument> updateHeader(int id, InvoiceHeaderPatch patch) =>
      _document(
        () => _api.updateInvoiceApiV1FiscalDocumentsFiscalDocumentIdPut(
          fiscalDocumentId: id,
          invoiceUpdate: api.InvoiceUpdate((b) {
            b
              ..recipient = patch.recipientRfc
              ..batch = patch.series
              ..usage = patch.usage
              // `issued` is Mexico City wall-clock time, sent as a plain
              // local value like every other date (spec 043).
              ..issued = patch.issued
              ..facility = patch.facilityId
              ..reference = patch.reference
              ..comment = patch.comment;
            // A payment receipt's fields (spec 074). Only set ones are sent,
            // so a receipt patch never carries invoice fields and an invoice
            // patch never carries these.
            final paymentDate = patch.paymentDate;
            if (paymentDate != null) b.paymentDate = paymentDate.toDate();
            final paymentAmount = patch.paymentAmount;
            if (paymentAmount != null) {
              b.paymentAmount = api.PaymentAmount(
                (a) => a.anyOf = AnyOf2<String, num>(
                  values: {0: '$paymentAmount'},
                ),
              ).toBuilder();
            }
            b
              ..paymentReference = patch.paymentReference
              ..orderingBank = patch.orderingBank;
            final terms = patch.paymentTerms;
            if (terms != null) b.paymentTerms = _termsToApi(terms);
            // PPD sends no form: the server forces 99.
            if (terms != InvoicePaymentTerms.ppd) {
              b.paymentMethod = patch.paymentForm;
            }
          }),
        ),
      );

  @override
  Future<FiscalDocument> addSalesOrder(int id, int salesOrderId) => _document(
    () => _api.addSalesOrderApiV1FiscalDocumentsFiscalDocumentIdSalesOrdersPost(
      fiscalDocumentId: id,
      invoiceSalesOrderAdd: api.InvoiceSalesOrderAdd(
        (b) => b.salesOrder = salesOrderId,
      ),
    ),
  );

  @override
  Future<FiscalDocument> addProduct(int id, int productId) => _document(
    () => _api.addInvoiceLineApiV1FiscalDocumentsFiscalDocumentIdLinesPost(
      fiscalDocumentId: id,
      invoiceLineAdd: api.InvoiceLineAdd((b) => b.product = productId),
    ),
  );

  @override
  Future<FiscalDocument> copyInvoiceLine(
    int id,
    int invoiceLineId, {
    required Decimal quantity,
  }) => _document(
    () => _api
        .copyInvoiceLineApiV1FiscalDocumentsFiscalDocumentIdInvoiceLinesPost(
          fiscalDocumentId: id,
          invoiceLineCopy: api.InvoiceLineCopy(
            (b) => b
              ..line = invoiceLineId
              ..quantity = api.Quantity4(
                (q) => q.anyOf = AnyOf2<String, num>(values: {0: '$quantity'}),
              ).toBuilder(),
          ),
        ),
  );

  @override
  Future<FiscalDocument> updateLine(
    int id,
    int lineId,
    InvoiceLinePatch patch,
  ) => _document(
    () => _api
        .updateInvoiceLineApiV1FiscalDocumentsFiscalDocumentIdLinesLineIdPut(
          fiscalDocumentId: id,
          lineId: lineId,
          invoiceLineUpdate: api.InvoiceLineUpdate((b) {
            final quantity = patch.quantity;
            if (quantity != null) {
              b.quantity = api.Quantity4(
                (q) => q.anyOf = AnyOf2<String, num>(values: {0: '$quantity'}),
              ).toBuilder();
            }
            final price = patch.price;
            if (price != null) {
              b.price = api.Price(
                (p) => p.anyOf = AnyOf2<String, num>(values: {0: '$price'}),
              ).toBuilder();
            }
            final percent = patch.discountPercent;
            if (percent != null) {
              // A percentage in the UI, a 0–1 fraction on the wire. Exact: the
              // division by 100 is a shift of the decimal point.
              final fraction = (percent / Decimal.fromInt(100)).toDecimal(
                scaleOnInfinitePrecision: 6,
              );
              b.discount = api.Discount1(
                (d) => d.anyOf = AnyOf2<String, num>(values: {0: '$fraction'}),
              ).toBuilder();
            }
            final tax = patch.taxRate;
            if (tax != null) {
              b.taxRate = api.TaxRate(
                (t) =>
                    t.anyOf = AnyOf2<String, num>(values: {0: '${tax.rate}'}),
              ).toBuilder();
            }
            b
              ..productCode = patch.productCode
              ..productName = patch.productName
              ..comment = patch.comment;
          }),
        ),
  );

  @override
  Future<FiscalDocument> removeLine(int id, int lineId) => _document(
    () => _api
        .removeInvoiceLineApiV1FiscalDocumentsFiscalDocumentIdLinesLineIdDelete(
          fiscalDocumentId: id,
          lineId: lineId,
        ),
  );

  @override
  Future<FiscalDocument> addRelation(
    int id,
    int documentId,
    InvoiceRelationType type,
  ) => _document(
    () => _api
        .addInvoiceRelationApiV1FiscalDocumentsFiscalDocumentIdRelationsPost(
          fiscalDocumentId: id,
          invoiceRelationAdd: api.InvoiceRelationAdd(
            (b) => b
              ..relation = documentId
              ..type = type == InvoiceRelationType.substitution
                  ? api.InvoiceRelationAddTypeEnum.n04
                  : api.InvoiceRelationAddTypeEnum.n07,
          ),
        ),
  );

  @override
  Future<FiscalDocument> removeRelation(int id, int relationId) => _document(
    () => _api
        .removeInvoiceRelationApiV1FiscalDocumentsFiscalDocumentIdRelationsRelationIdDelete(
          fiscalDocumentId: id,
          relationId: relationId,
        ),
  );

  @override
  Future<FiscalDocument> confirm(int id) => _document(
    () => _api.confirmInvoiceApiV1FiscalDocumentsFiscalDocumentIdConfirmPost(
      fiscalDocumentId: id,
    ),
  );

  @override
  Future<FiscalDocument> reopen(int id) => _document(
    () => _api.reopenInvoiceApiV1FiscalDocumentsFiscalDocumentIdReopenPost(
      fiscalDocumentId: id,
    ),
  );

  @override
  Future<FiscalDocument> stamp(int id) => _document(
    () => _api.stampFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdStampPost(
      fiscalDocumentId: id,
    ),
  );

  @override
  Future<FiscalDocument> cancel(
    int id,
    SatCancellationReason reason, {
    String? substitution,
  }) => _document(
    () =>
        _api.cancelFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdCancelPost(
          fiscalDocumentId: id,
          fiscalDocumentCancelRequest: api.FiscalDocumentCancelRequest(
            (b) => b
              ..reason = reason.code
              // Only reason 01 names a substitute; the server ignores it for the
              // others, but it is not sent.
              ..substitution = reason.needsSubstitute ? substitution : null,
          ),
        ),
  );

  @override
  Future<FiscalDocument> refresh(int id) => _document(
    () => _api
        .refreshFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdRefreshPost(
          fiscalDocumentId: id,
        ),
  );

  Future<FiscalDocument> _document(
    Future<Response<api.FiscalDocumentResponse>> Function() call,
  ) async {
    try {
      final response = await call();
      final result = response.data;
      if (result == null) throw const AppError.server();
      return _detail(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

api.PaymentTerms _termsToApi(InvoicePaymentTerms terms) =>
    terms == InvoicePaymentTerms.pue
    ? api.PaymentTerms.number0
    : api.PaymentTerms.number1;

/// Each constant of the generated status enums maps to its own state, and an
/// unmapped one throws: a state falling back to draft would open a stamped
/// document as editable (spec 072 R1). A test iterates both enums' `values`,
/// so a state added on the server fails there after regeneration.
FiscalDocumentStatus _responseStatus(
  api.FiscalDocumentResponseStatusEnum status,
) => switch (status) {
  api.FiscalDocumentResponseStatusEnum.draft => FiscalDocumentStatus.draft,
  api.FiscalDocumentResponseStatusEnum.sealed_ => FiscalDocumentStatus.sealed,
  api.FiscalDocumentResponseStatusEnum.stamping =>
    FiscalDocumentStatus.stamping,
  api.FiscalDocumentResponseStatusEnum.issued => FiscalDocumentStatus.issued,
  api.FiscalDocumentResponseStatusEnum.cancellationPending =>
    FiscalDocumentStatus.cancellationPending,
  api.FiscalDocumentResponseStatusEnum.cancelled =>
    FiscalDocumentStatus.cancelled,
  _ => throw StateError('Unmapped fiscal document status: ${status.name}'),
};

/// The list's twin of [_responseStatus].
FiscalDocumentStatus _summaryStatus(
  api.FiscalDocumentSummaryStatusEnum status,
) => switch (status) {
  api.FiscalDocumentSummaryStatusEnum.draft => FiscalDocumentStatus.draft,
  api.FiscalDocumentSummaryStatusEnum.sealed_ => FiscalDocumentStatus.sealed,
  api.FiscalDocumentSummaryStatusEnum.stamping => FiscalDocumentStatus.stamping,
  api.FiscalDocumentSummaryStatusEnum.issued => FiscalDocumentStatus.issued,
  api.FiscalDocumentSummaryStatusEnum.cancellationPending =>
    FiscalDocumentStatus.cancellationPending,
  api.FiscalDocumentSummaryStatusEnum.cancelled =>
    FiscalDocumentStatus.cancelled,
  _ => throw StateError('Unmapped fiscal document status: ${status.name}'),
};

Decimal? _decimal(String? s) => s == null ? null : Decimal.tryParse(s);

FiscalDocumentSummary _summary(api.FiscalDocumentSummary r) =>
    FiscalDocumentSummary(
      id: r.fiscalDocumentId,
      typeCode: r.type,
      version: r.version,
      series: r.batch,
      serial: r.serial,
      issuerRfc: r.issuer,
      issuerName: r.issuerName,
      recipientRfc: r.recipient,
      recipientName: r.recipientName,
      issued: r.issued,
      stampUuid: r.stampUuid,
      status: _summaryStatus(r.status),
      total: _decimal(r.total),
    );

FiscalDocument _detail(api.FiscalDocumentResponse r) => FiscalDocument(
  summary: FiscalDocumentSummary(
    id: r.fiscalDocumentId,
    typeCode: r.type,
    version: r.version,
    series: r.batch,
    serial: r.serial,
    issuerRfc: r.issuer,
    issuerName: r.issuerName,
    recipientRfc: r.recipient,
    recipientName: r.recipientName,
    issued: r.issued,
    stampUuid: r.stampUuid,
    status: _responseStatus(r.status),
    total: _decimal(r.total),
  ),
  issuerRegime: r.issuerRegime,
  issuerRegimeName: r.issuerRegimeName,
  customerId: r.customer,
  facilityId: r.facility,
  issuedLocation: r.issuedLocation,
  taxpayerRegime: r.taxpayerRegime,
  taxpayerPostalCode: r.taxpayerPostalCode,
  usage: r.usage,
  paymentTerms: r.paymentTerms == 1
      ? InvoicePaymentTerms.ppd
      : InvoicePaymentTerms.pue,
  paymentForm: r.paymentMethod,
  currencyCode: r.currency,
  exchangeRate: _decimal(r.exchangeRate) ?? Decimal.one,
  reference: r.reference,
  comment: r.comment,
  stamped: r.stamped,
  cancellationDate: r.cancellationDate,
  cancellationReason: r.cancellationReason,
  stamp: r.stamp == null ? null : _stamp(r.stamp!),
  stampingSince: r.stampingSince,
  cancellationSubstitution: r.cancellationSubstitution,
  cancellations:
      (r.cancellations ?? const <api.FiscalDocumentCancellationResponse>[])
          .map(_cancellation)
          .toList(),
  lines: r.lines.map(_line).toList(),
  relations: (r.relations ?? const <api.FiscalDocumentRelationResponse>[])
      .map(_relation)
      .toList(),
  paymentDate: r.paymentDate?.toDateTime(),
  paymentAmount: _decimal(r.paymentAmount),
  paymentReference: r.paymentReference,
  customerPaymentId: r.customerPayment,
  paidInvoices: (r.paidInvoices ?? const <api.PaidInvoiceResponse>[])
      .map(_paidInvoice)
      .toList(),
);

PaidInvoice _paidInvoice(api.PaidInvoiceResponse p) => PaidInvoice(
  relationId: p.fiscalDocumentRelationId,
  invoiceId: p.invoice,
  series: p.batch,
  serial: p.serial,
  stampUuid: p.stampUuid,
  installment: p.installment,
  previousBalance: _decimal(p.previousBalance) ?? Decimal.zero,
  amount: _decimal(p.amount) ?? Decimal.zero,
  remaining: _decimal(p.remaining) ?? Decimal.zero,
);

FiscalStamp _stamp(api.FiscalDocumentStamp s) => FiscalStamp(
  uuid: s.uuid,
  stamped: s.stamped,
  satCertificate: s.satCertificate,
  providerRfc: s.providerRfc,
  simulated: s.simulated,
);

FiscalCancellation _cancellation(api.FiscalDocumentCancellationResponse c) =>
    FiscalCancellation(
      id: c.fiscalDocumentCancellationId,
      reason: c.reason,
      substitution: c.substitution,
      outcome: CancellationOutcome.fromWire(c.status),
      rawOutcome: c.status,
      pacCode: c.pacCode,
      pacMessage: c.pacMessage,
      requestedBy: c.requestedBy,
      requestedAt: c.requestedAt,
      answeredAt: c.answeredAt,
      resolvedAt: c.resolvedAt,
    );

InvoiceLine _line(api.FiscalDocumentLine l) => InvoiceLine(
  id: l.fiscalDocumentDetailId,
  productId: l.product,
  orderLineId: l.orderDetail,
  productCode: l.productCode,
  productName: l.productName,
  satProductKey: l.productService,
  unitKey: l.unitOfMeasurement,
  unitName: l.unitOfMeasurementName,
  quantity: _decimal(l.quantity) ?? Decimal.zero,
  price: _decimal(l.price) ?? Decimal.zero,
  discountRate: _decimal(l.discount) ?? Decimal.zero,
  taxRate: _decimal(l.taxRate) ?? Decimal.zero,
  taxIncluded: l.taxIncluded,
  comment: l.comment,
);

InvoiceRelation _relation(api.FiscalDocumentRelationResponse r) =>
    InvoiceRelation(
      id: r.fiscalDocumentRelationId,
      documentId: r.relation,
      type: InvoiceRelationType.fromCode(r.type?.name.replaceFirst('n', '')),
      stampUuid: r.stampUuid,
      series: r.batch,
      serial: r.serial,
    );

final _quotedFilename = RegExp(r'filename="([^"]*)"', caseSensitive: false);
final _bareFilename = RegExp(r'filename=([^;\s]+)', caseSensitive: false);

/// The `filename` of a `Content-Disposition` header, reduced to its last path
/// segment so a server-supplied name can never carry a directory.
String? _filenameFrom(Headers headers) {
  final disposition = headers.value('content-disposition');
  if (disposition == null) return null;
  final match =
      _quotedFilename.firstMatch(disposition) ??
      _bareFilename.firstMatch(disposition);
  final raw = match?.group(1)?.trim();
  if (raw == null || raw.isEmpty) return null;
  final name = raw.split(RegExp(r'[\\/]')).last.trim();
  return name.isEmpty ? null : name;
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
