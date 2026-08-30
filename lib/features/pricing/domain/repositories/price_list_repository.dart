import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list_delete_preview.dart';

/// Price-list catalog calls to mbe-api (contracts/mbe-api-pricing.md §1).
/// Access is gated by `AccessControlService.can(SystemObject.priceLists,
/// ...)` at the screen level.
abstract class PriceListRepository {
  /// `GET /api/v1/price-lists` (FR-001, FR-005).
  Future<PriceListResult> list({String? search, int skip = 0, int limit = 20});

  /// `GET /api/v1/price-lists/{price_list_id}`. Throws `NotFoundError` on
  /// `404`.
  Future<PriceList> get({required int priceListId});

  /// `POST /api/v1/price-lists` (FR-002). Throws `ValidationError` on `422`
  /// (e.g. duplicate name).
  Future<PriceList> create({
    required String name,
  });

  /// `PUT /api/v1/price-lists/{price_list_id}` (FR-003). All fields
  /// optional; only non-null values are sent. Throws `NotFoundError` on
  /// `404`, `ValidationError` on `422`.
  Future<PriceList> update({
    required int priceListId,
    String? name,
  });

  /// `DELETE /api/v1/price-lists/{price_list_id}[?replacement={id}]`
  /// (specs/034-price-list-retirement-ui FR-012). `replacement` is omitted
  /// from the request when `null`, preserving the exact behaviour of a
  /// caller that names none (FR-013). Throws `NotFoundError` on `404`
  /// (the list, or the named replacement), `ServerError(400, …)` when
  /// `replacement` names the list itself, `ServerError(409, …)` when
  /// something other than the list's prices and its customers still
  /// references it (contracts/mbe-api-price-list-retirement.md §2).
  Future<void> delete({required int priceListId, int? replacement});

  /// `GET /api/v1/price-lists/{price_list_id}/delete/preview`
  /// (specs/034-price-list-retirement-ui FR-001, FR-007). Read-only —
  /// changes nothing by being asked. Throws `NotFoundError` on `404`.
  Future<PriceListDeletePreview> deletePreview({required int priceListId});
}

/// `ListResponse[PriceListResponse]` (`items`, `total`).
class PriceListResult {
  const PriceListResult({required this.items, required this.total});

  final List<PriceList> items;
  final int total;
}
