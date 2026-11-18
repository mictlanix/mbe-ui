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
  FiscalStamp? stamp,
  DateTime? stampingSince,
  String? cancellationSubstitution,
  List<FiscalCancellation> cancellations = const [],
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
  paymentForm: 99,
  currencyCode: 100,
  exchangeRate: Decimal.one,
  lines: lines ?? [anInvoiceLine()],
  relations: relations,
  stamp: stamp,
  stampingSince: stampingSince,
  cancellationSubstitution: cancellationSubstitution,
  cancellations: cancellations,
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
}) => InvoiceLine(
  id: id,
  productId: 3,
  orderLineId: orderLineId,
  productCode: 'P-1',
  productName: 'Tornillo',
  satProductKey: '01010101',
  unitKey: 'H87',
  unitName: 'Pieza',
  quantity: Decimal.parse(quantity),
  price: Decimal.parse(price),
  discountRate: Decimal.zero,
  taxRate: Decimal.parse('0.16'),
  taxIncluded: false,
);
