import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Whether [order] is one the back-office workspace should decline to edit —
/// a register sale reached through the "Pedidos" list, which does not
/// distinguish origin (spec 039 A1, FR-053, research R5).
///
/// The decision is **three-way**, on `Sale.origin` (mbe-api#209):
///
/// | `origin`      | Decision                                  |
/// |---------------|-------------------------------------------|
/// | `backOffice`  | resume — never consult a proxy (FR-052)   |
/// | `pointOfSale` | decline — on the field alone (FR-053)     |
/// | `null`        | [_looksLikeARegisterSale], below           |
///
/// The `null` arm is not a leftover. Every order the previous back-office
/// editor raised (specs 029, 032, 037) predates the field and carries no
/// origin, and mbe-api#209 shipped without a backfill deliberately — so
/// "no origin ⇒ decline" would refuse to reopen real orders belonging to
/// real customers (SC-008), and "no origin ⇒ admit" would let every
/// historical register sale in. FR-052's no-proxy rule governs orders that
/// *carry* an origin; a row with none has no field to read, so the fallback
/// is the only answer available rather than a violation of it (spec A9).
bool isForeignOrder(Sale order, {required AppSettings settings}) =>
    switch (order.origin) {
      SaleOrigin.backOffice => false,
      SaleOrigin.pointOfSale => true,
      null => _looksLikeARegisterSale(order, settings: settings),
    };

/// The three signals that an order with no recorded origin came from the
/// register. Deliberately **one-sided**: each is *sufficient* to prove an
/// order is not a back-office order, and none is necessary. This workspace
/// raises none of these states — it forbids the walk-in customer (FR-011),
/// always intends delivery (FR-021), and takes no payment — so the check
/// never wrongly rejects an order it raised itself, while catching the large
/// majority of register sales.
bool _looksLikeARegisterSale(Sale order, {required AppSettings settings}) {
  if (settings.isGenericCustomer(order.customer)) return true;
  if (order.fulfillmentIntent == FulfillmentMode.counterPickup) return true;
  // `Sale` carries no payment list, so the readable trace of a payment is a
  // balance that has fallen below the total — which is exactly what the
  // register's payment step leaves behind. A cancelled order is excluded:
  // its payments are cancelled with it, and it is read-only either way.
  if (order.status != SaleStatus.cancelled &&
      parseAmount(order.balanceOrZero) < parseAmount(order.total)) {
    return true;
  }
  return false;
}
