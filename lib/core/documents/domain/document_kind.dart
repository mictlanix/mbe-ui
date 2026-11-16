import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';

/// The documents mbe-api renders as PDF (mbe-api#231, issue #230), and the
/// privilege each one is gated by. The gates are exactly what mbe-api enforces:
/// the ticket and the pedido need the same read right as a sales order, and
/// the cut the same as the point of sale (spec 044 FR-040, research R12), and
/// a payment's ticket the same as the payments list (spec 055 R4).
///
/// The page geometry is the server's, so nothing here (or anywhere in mbe-ui)
/// branches on it (FR-021).
enum DocumentKind {
  /// `GET /sales-orders/{id}/ticket` — the pre-payment ticket before an order
  /// is completed, the final receipt after. The server decides which.
  saleTicket(SystemObject.salesOrders),

  /// `GET /sales-orders/{id}/document` — the Letter-size pedido, in any state.
  salesOrder(SystemObject.salesOrders),

  /// `GET /cash-sessions/{id}/ticket` — the "Corte de Caja" of a closed session.
  cashCut(SystemObject.pos),

  /// `GET /sales-quotes/{id}/document` — the Letter-size quote, in any state
  /// (mbe-api spec 024).
  salesQuote(SystemObject.salesQuotes),

  /// `GET /customer-payments/{id}/ticket` — the 72 mm proof of a credit
  /// payment or a payment in advance (mbe-api#272, spec 055). Any other type
  /// is a 409 on the server, so call sites offer it only for those two.
  customerPaymentTicket(SystemObject.customerPayments),

  /// `GET /customer-refunds/{id}/ticket` — the receipt of a confirmed refund
  /// (mbe-api#287, spec 057). An open or cancelled refund is a 409 on the
  /// server, so call sites offer it only for a completed one.
  customerRefundReceipt(SystemObject.customerRefunds),

  /// `GET /delivery-orders/{id}/ticket` — the 72 mm delivery ticket, or the
  /// pickup ticket for a counter pickup (the server chooses, spec 064 FR-022).
  /// DRAFT and PENDING_APPROVAL orders are a 409 on the server, so call sites
  /// offer it only from approval on. Optionally limited to one warehouse's
  /// lines (mbe-api spec 026).
  deliveryTicket(SystemObject.deliveryOrders),

  /// `GET /delivery-orders/{id}/document` — the Letter-size delivery order,
  /// always with every line (mbe-api spec 026).
  deliveryOrderDocument(SystemObject.deliveryOrders),

  /// `GET /fiscal-documents/{id}/pdf` — the Letter-size CFDI of a stamped
  /// invoice (mbe-api spec 020, spec 066 research R9). A never-issued,
  /// unstamped or pre-4.0 document is a 409 on the server with its own code,
  /// so the preview shows that reason.
  fiscalDocument(SystemObject.fiscalDocuments);

  const DocumentKind(this.gateObject);

  /// The [SystemObject] whose read right offers this document.
  final SystemObject gateObject;

  /// The right that offers it: always read.
  AccessRight get gateRight => AccessRight.read;

  /// The file name to use when the response carries no usable
  /// `Content-Disposition`. Padded as mbe-api pads its own, so a fallback name
  /// does not visibly differ from the server's (research R10).
  String fallbackFilename(int recordId) => switch (this) {
    DocumentKind.saleTicket => 'ticket-${_pad(recordId, 8)}.pdf',
    DocumentKind.salesOrder => 'pedido-${_pad(recordId, 8)}.pdf',
    DocumentKind.cashCut => 'corte-${_pad(recordId, 6)}.pdf',
    DocumentKind.salesQuote => 'cotizacion-${_pad(recordId, 8)}.pdf',
    DocumentKind.customerPaymentTicket => 'pago-${_pad(recordId, 8)}.pdf',
    DocumentKind.customerRefundReceipt => 'devolucion-${_pad(recordId, 8)}.pdf',
    DocumentKind.deliveryTicket => 'entrega-${_pad(recordId, 8)}.pdf',
    DocumentKind.deliveryOrderDocument =>
      'orden-entrega-${_pad(recordId, 8)}.pdf',
    DocumentKind.fiscalDocument => 'factura-$recordId.pdf',
  };

  static String _pad(int id, int width) => id.toString().padLeft(width, '0');
}
