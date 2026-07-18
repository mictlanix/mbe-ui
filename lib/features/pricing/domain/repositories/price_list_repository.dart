import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';

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
    String? highProfitMargin,
    String? lowProfitMargin,
  });

  /// `PUT /api/v1/price-lists/{price_list_id}` (FR-003). All fields
  /// optional; only non-null values are sent. Throws `NotFoundError` on
  /// `404`, `ValidationError` on `422`.
  Future<PriceList> update({
    required int priceListId,
    String? name,
    String? highProfitMargin,
    String? lowProfitMargin,
  });

  /// `DELETE /api/v1/price-lists/{price_list_id}` (FR-004). Throws
  /// `NotFoundError` on `404`, and whatever `AppError` mbe-api maps a
  /// still-in-use rejection to (e.g. assigned to a customer — US1 §6,
  /// contracts/mbe-api-pricing.md G3) so the caller can surface it and leave
  /// the list in place.
  Future<void> delete({required int priceListId});
}

/// `ListResponse[PriceListResponse]` (`items`, `total`).
class PriceListResult {
  const PriceListResult({required this.items, required this.total});

  final List<PriceList> items;
  final int total;
}
