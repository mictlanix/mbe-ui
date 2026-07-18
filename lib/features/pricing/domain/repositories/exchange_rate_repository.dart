import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';

/// Exchange-rate calls to mbe-api (contracts/mbe-api-pricing.md §3). Access
/// is gated by `AccessControlService.can(SystemObject.exchangeRates, ...)`
/// at the screen level.
abstract class ExchangeRateRepository {
  /// `GET /api/v1/exchange-rates` (FR-014, FR-015).
  Future<ExchangeRateResult> list({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? base,
    int? target,
    int skip = 0,
    int limit = 20,
  });

  /// `GET /api/v1/exchange-rates/{exchange_rate_id}`. Throws `NotFoundError`
  /// on `404`.
  Future<ExchangeRate> get({required int exchangeRateId});

  /// `POST /api/v1/exchange-rates` (FR-016). Throws `ValidationError` on
  /// `422`.
  Future<ExchangeRate> create({
    required DateTime date,
    required String rate,
    required int base,
    required int target,
  });

  /// `PUT /api/v1/exchange-rates/{exchange_rate_id}` (FR-017). All fields
  /// optional; only non-null values are sent. Throws `NotFoundError` on
  /// `404`, `ValidationError` on `422`.
  Future<ExchangeRate> update({
    required int exchangeRateId,
    DateTime? date,
    String? rate,
    int? base,
    int? target,
  });

  /// `DELETE /api/v1/exchange-rates/{exchange_rate_id}` (FR-017). Throws
  /// `NotFoundError` on `404`.
  Future<void> delete({required int exchangeRateId});
}

/// `ListResponse[ExchangeRateResponse]` (`items`, `total`).
class ExchangeRateResult {
  const ExchangeRateResult({required this.items, required this.total});

  final List<ExchangeRate> items;
  final int total;
}
