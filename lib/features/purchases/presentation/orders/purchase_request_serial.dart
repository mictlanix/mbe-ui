import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';

/// The folio (`serial`) of the purchase request with this id, for the "Sol.
/// {serial}" under an order line from a request (spec 080 FR-016, research
/// R8). An order line carries the request's id, not its folio.
///
/// Kept for the session once fetched, so the lines from one request share
/// one `GET`. A missing right (no read on PurchaseRequest, 86) or a request
/// not found resolves to null, as does an unsubmitted draft with no folio
/// yet; the cell then shows `#id`. Any other failure is an error, not kept,
/// so the next look fetches again; the cell shows `#id` meanwhile.
final purchaseRequestSerialProvider = FutureProvider.autoDispose
    .family<int?, int>((ref, requestId) async {
      try {
        final request = await ref
            .watch(purchaseRequestRepositoryProvider)
            .get(requestId);
        ref.keepAlive();
        return request.serial;
      } on AppError catch (error) {
        if (_isMissingRightOrNotFound(error)) return null;
        rethrow;
      }
    });

bool _isMissingRightOrNotFound(AppError error) =>
    error.problem?.code == api.ErrorCode.authPeriodForbidden ||
    switch (error) {
      AuthError() || NotFoundError() || ServerError(statusCode: 403) => true,
      _ => false,
    };
