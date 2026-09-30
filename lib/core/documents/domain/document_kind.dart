import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';

/// The documents mbe-api renders as PDF (mbe-api#231, issue #230), and the
/// privilege each one is gated by. The gates are exactly what mbe-api enforces:
/// the ticket and the pedido need the same read right as a sales order, and
/// the cut the same as the point of sale (spec 044 FR-040, research R12).
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
  cashCut(SystemObject.pos);

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
  };

  static String _pad(int id, int width) => id.toString().padLeft(width, '0');
}
