import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_cancellation.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_stamp.dart';

/// A document for tests; override what the case is about.
FiscalDocument aDocument({
  int id = 7,
  FiscalDocumentStatus status = FiscalDocumentStatus.draft,
  int typeCode = 0,
  int? serial,
  String? series = 'A',
  int? customerId = 4,
  Decimal? total,
  List<InvoiceLine>? lines,
  List<InvoiceRelation> relations = const [],
  InvoicePaymentTerms paymentTerms = InvoicePaymentTerms.pue,
  int paymentForm = 99,
  FiscalStamp? stamp,
  DateTime? stampingSince,
  String? cancellationSubstitution,
  List<FiscalCancellation> cancellations = const [],
  DateTime? paymentDate,
  Decimal? paymentAmount,
  String? paymentReference,
  int? customerPaymentId,
  List<PaidInvoice> paidInvoices = const [],
  String? reference,
}) => FiscalDocument(
  summary: FiscalDocumentSummary(
    id: id,
    typeCode: typeCode,
    version: '4.0',
    series: series,
    serial: serial,
    issuerRfc: 'XAXX010101000',
    issuerName: 'Emisor SA',
    recipientRfc: 'XEXX010101000',
    recipientName: 'Receptor SA',
    status: status,
    total: total,
  ),
  customerId: customerId,
  facilityId: 2,
  issuedLocation: '64000',
  usage: 'G01',
  paymentTerms: paymentTerms,
  paymentForm: paymentForm,
  currencyCode: 100,
  exchangeRate: Decimal.one,
  lines: lines ?? [anInvoiceLine()],
  relations: relations,
  stamp: stamp,
  stampingSince: stampingSince,
  cancellationSubstitution: cancellationSubstitution,
  cancellations: cancellations,
  paymentDate: paymentDate,
  paymentAmount: paymentAmount,
  paymentReference: paymentReference,
  customerPaymentId: customerPaymentId,
  paidInvoices: paidInvoices,
  reference: reference,
);

/// A relation row; a credit note's link to its invoice by default (type 01).
InvoiceRelation aRelation({
  int id = 1,
  int documentId = 12,
  InvoiceRelationType? type = InvoiceRelationType.creditNoteOf,
  String? series = 'GR',
  int? serial = 12,
}) => InvoiceRelation(
  id: id,
  documentId: documentId,
  type: type,
  series: series,
  serial: serial,
);

/// A credit note (type 100) relating invoice 12; `withRelation: false` is a
/// legacy one with no relation. Its payment form is a real one unless given.
FiscalDocument aCreditNote({
  int id = 7,
  FiscalDocumentStatus status = FiscalDocumentStatus.draft,
  int paymentForm = 3,
  bool withRelation = true,
  int? serial,
  String? series = 'NC',
  List<InvoiceLine>? lines,
}) => aDocument(
  id: id,
  status: status,
  typeCode: 100,
  series: series,
  serial: serial,
  paymentForm: paymentForm,
  lines: lines,
  relations: withRelation ? [aRelation()] : const [],
);

/// One invoice a receipt pays (spec 074).
PaidInvoice aPaidInvoice({
  int relationId = 31,
  int invoiceId = 12,
  String? series = 'A',
  int? serial = 5238,
  String previousBalance = '8000.00',
  String amount = '8000.00',
  String remaining = '0.00',
  int installment = 1,
}) => PaidInvoice(
  relationId: relationId,
  invoiceId: invoiceId,
  series: series,
  serial: serial,
  stampUuid: '6F1C2A9E-0000-4000-8000-00000000AB21',
  installment: installment,
  previousBalance: Decimal.parse(previousBalance),
  amount: Decimal.parse(amount),
  remaining: Decimal.parse(remaining),
);

/// A payment receipt (type 200) for a payment of 8,000.00 that pays one
/// invoice in full, so the draft has nothing left to assign. `paidInvoices`
/// and `paymentAmount` are overridable; `customerPaymentId: null` is a
/// by-hand receipt.
FiscalDocument aPaymentReceipt({
  int id = 7,
  FiscalDocumentStatus status = FiscalDocumentStatus.draft,
  int paymentForm = 3,
  int? serial,
  String? series = 'CP',
  int? customerPaymentId = 4127,
  Decimal? paymentAmount,
  bool paysInvoice = true,
  List<PaidInvoice>? paidInvoices,
  DateTime? paymentDate,
  String? reference,
}) => aDocument(
  id: id,
  status: status,
  typeCode: 200,
  series: series,
  serial: serial,
  paymentForm: paymentForm,
  lines: const [],
  customerPaymentId: customerPaymentId,
  paymentAmount: paymentAmount ?? Decimal.parse('8000.00'),
  paymentDate: paymentDate ?? DateTime(2026, 11, 12),
  paymentReference: 'SPEI 99812',
  reference: reference,
  paidInvoices: paidInvoices ?? (paysInvoice ? [aPaidInvoice()] : const []),
);

/// A PAC stamp; simulated by default, as on dev and test.
FiscalStamp aStamp({
  String uuid = '6F1C2A9E-0000-4000-8000-00000000AB21',
  bool simulated = true,
  String? satCertificate = '00001000000509846663',
  String? providerRfc = 'SIM010101SIM',
}) => FiscalStamp(
  uuid: uuid,
  stamped: DateTime(2026, 11, 17, 9, 13),
  satCertificate: satCertificate,
  providerRfc: providerRfc,
  simulated: simulated,
);

/// One cancellation request; accepted by default.
FiscalCancellation aCancellation({
  int id = 1,
  String reason = '02',
  String? substitution,
  CancellationOutcome outcome = CancellationOutcome.accepted,
  String? pacCode,
  String? pacMessage,
  int requestedBy = 5,
  DateTime? answeredAt,
  DateTime? resolvedAt,
}) => FiscalCancellation(
  id: id,
  reason: reason,
  substitution: substitution,
  outcome: outcome,
  rawOutcome: outcome.name,
  pacCode: pacCode,
  pacMessage: pacMessage,
  requestedBy: requestedBy,
  requestedAt: DateTime(2026, 11, 17, 12, 30),
  answeredAt: answeredAt,
  resolvedAt: resolvedAt,
);

InvoiceLine anInvoiceLine({
  int id = 10,
  int? orderLineId = 5,
  String quantity = '2',
  String price = '100',
  String productCode = 'P-1',
  String productName = 'Tornillo',
  String discountRate = '0',
}) => InvoiceLine(
  id: id,
  productId: 3,
  orderLineId: orderLineId,
  productCode: productCode,
  productName: productName,
  satProductKey: '01010101',
  unitKey: 'H87',
  unitName: 'Pieza',
  quantity: Decimal.parse(quantity),
  price: Decimal.parse(price),
  discountRate: Decimal.parse(discountRate),
  taxRate: Decimal.parse('0.16'),
  taxIncluded: false,
);
