import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';

/// The amounts of one line (spec 066 research R11).
class LineAmounts {
  const LineAmounts({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.taxes,
  });

  final Decimal subtotal;
  final Decimal discount;
  final Decimal total;
  final Decimal taxes;

  /// What the line shows in the Importe column.
  Decimal get net => subtotal - discount;
}

/// The amounts of a whole invoice, summed over its lines.
class InvoiceAmounts {
  const InvoiceAmounts({
    required this.subtotal,
    required this.discount,
    required this.taxes,
    required this.total,
  });

  final Decimal subtotal;
  final Decimal discount;
  final Decimal taxes;
  final Decimal total;
}

/// Half away from zero to 2 places.
Decimal _round2(Rational value) {
  final cents = (value * Rational.fromInt(100)).round();
  return Decimal.fromBigInt(cents).shift(-2);
}

/// Mirrors mbe-api `cfdi_invoice.line_amounts`, so a draft shows the total
/// the server will seal. Exempt (-1) counts as 0. The live test compares
/// this with the server's total after confirm.
LineAmounts lineAmounts(InvoiceLine line) {
  final one = Rational.one;
  final t = line.taxRate > Decimal.zero
      ? line.taxRate.toRational()
      : Rational.zero;
  final d = line.discountRate.toRational();
  final qp = (line.quantity * line.price).toRational();
  final divided = line.taxIncluded && t > Rational.zero;
  final base = divided ? qp / (one + t) : qp;

  final subtotal = _round2(base);
  final discount = _round2(divided ? qp * d / (one + t) : qp * d);
  final gross = d > Rational.zero
      ? _round2(qp * d).toRational()
      : Rational.zero;
  final net = qp - gross;
  final total = (line.taxIncluded || t <= Rational.zero)
      ? _round2(net)
      : _round2(net * (one + t));
  return LineAmounts(
    subtotal: subtotal,
    discount: discount,
    total: total,
    taxes: total - subtotal + discount,
  );
}

/// The invoice amounts: each is the sum over the lines.
InvoiceAmounts invoiceAmounts(List<InvoiceLine> lines) {
  var subtotal = Decimal.zero;
  var discount = Decimal.zero;
  var taxes = Decimal.zero;
  var total = Decimal.zero;
  for (final line in lines) {
    final a = lineAmounts(line);
    subtotal += a.subtotal;
    discount += a.discount;
    taxes += a.taxes;
    total += a.total;
  }
  return InvoiceAmounts(
    subtotal: subtotal,
    discount: discount,
    taxes: taxes,
    total: total,
  );
}
