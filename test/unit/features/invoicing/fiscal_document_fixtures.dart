import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';

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
