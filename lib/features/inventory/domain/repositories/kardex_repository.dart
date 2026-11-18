import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';

/// The kardex (spec 071), over the generated `KardexApi`. Throws `AppError`
/// on failure. The range is not checked here: the presentation layer checks
/// it first (research R4), and the server's `kardex.*` codes still come back
/// as coded errors.
abstract class KardexRepository {
  /// `GET /kardex?product&warehouse&from&to`. Only the dates of [from] and
  /// [to] are sent.
  Future<Kardex> read({
    required int productId,
    required int warehouseId,
    required DateTime from,
    required DateTime to,
  });
}
