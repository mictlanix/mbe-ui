import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';

/// The folio (`serial`) of the purchase request with this id, for the "Sol.
/// {serial}" under an order line from a request (spec 080 FR-016, research
/// R8). An order line carries the request's id, not its folio.
///
/// Cached for the session, so the lines from one request share one `GET`. A
/// failure (for example no read on PurchaseRequest, 86) resolves to null, as
/// does an unsubmitted draft with no folio yet; the cell then shows `#id`.
final purchaseRequestSerialProvider = FutureProvider.family<int?, int>((
  ref,
  requestId,
) async {
  try {
    final request = await ref
        .watch(purchaseRequestRepositoryProvider)
        .get(requestId);
    return request.serial;
  } catch (_) {
    return null;
  }
});
