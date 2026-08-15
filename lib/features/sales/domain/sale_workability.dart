import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart' show SaleStatus;
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Whether a listed sale can still be worked on, and therefore whether its
/// row offers Edit (spec 023 FR-006, data-model §3).
///
/// Cheap for two of the three cases: a `draft` is always workable, a
/// `cancelled` sale never is, and a `completed`/`paid` sale with a non-zero
/// balance is workable because it still owes money. The one case a summary
/// cannot decide alone is a **zero-balance paid sale** — workable only when
/// it is a delivery sale whose distribution is unfinished, which spec 020
/// FR-058 already answers via the register's open-sales set. [resumableIds]
/// is exactly that set (`openSalesSelectorControllerProvider`'s own answer),
/// so this costs zero additional requests per row: the expensive computation
/// (a `getById` plus a delivery-orders lookup plus a facility-address lookup)
/// already happens once, for today, behind a provider every caller here
/// already watches.
///
/// A [resumableIds] that has not resolved yet (or failed) should be passed as
/// an empty set — a zero-balance paid sale then reads as **not** workable
/// rather than offering an Edit that would land on a refusal.
bool saleIsWorkable(OpenSale sale, {required Set<int> resumableIds}) {
  switch (sale.status) {
    case SaleStatus.cancelled:
      return false;
    case SaleStatus.draft:
      return true;
    case SaleStatus.completed:
    case SaleStatus.paid:
      if (!isZeroAmount(sale.balance)) return true;
      return resumableIds.contains(sale.id);
  }
}
