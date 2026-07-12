import 'dart:typed_data';

import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';

/// Product catalog calls to mbe-api (contracts/mbe-api-products.md). Access
/// is gated by `AccessControlService.can(SystemObject.products, ...)` at the
/// screen level (research.md §1 — these endpoints are not yet server-side
/// privilege-gated; tracked as mictlanix/mbe-api#70).
///
/// [delete] performs a genuine hard delete against mbe-api's
/// `DELETE /api/v1/products/{product_id}` (confirmed via code review: it
/// runs `db.delete(product)`, permanently removing the row and its price
/// records) — it replaces the product UI's former soft-delete-via-[update]
/// flow (spec.md Clarifications, 2026-07-05).
abstract class ProductRepository {
  /// `GET /api/v1/products` (FR-001, FR-002). [labels] filters to products
  /// matching any of the given label ids (FR-008, OR semantics) — mbe-api's
  /// `label` query param now accepts repeated values
  /// (`?label=1&label=2`); this previously accepted only a single value
  /// (research.md §4), resolved server-side 2026-07-05.
  Future<ProductListResult> list({
    String? search,
    bool? deactivated,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    List<int> labels = const [],
    int skip = 0,
    int limit = 20,
  });

  /// `GET /api/v1/products/{product_id}` (FR-008). Throws `NotFoundError` on
  /// `404`.
  Future<Product> get({required int productId});

  /// `DELETE /api/v1/products/{product_id}` (FR-016a). A genuine hard
  /// delete — permanently removes the product and its price records.
  /// Irreversible; there is no undo. Throws `NotFoundError` on `404`, and
  /// whatever `AppError` mbe-api maps a referential-integrity rejection to
  /// (e.g. a product still referenced by orders/quotations) so the caller
  /// can surface it and leave the product in place (FR-016b).
  Future<void> delete({required int productId});

  /// `POST /api/v1/products` (FR-003). Throws `ValidationError` on `422`
  /// (e.g. duplicate code, invalid name length, invalid barcode).
  Future<Product> create({
    required String code,
    required String name,
    required String unitOfMeasurement,
    String? sku,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    String? taxRate,
    String? comment,
    bool stockable = false,
    bool perishable = false,
    bool seriable = false,
    bool purchasable = false,
    bool salable = false,
    bool invoiceable = false,
    int? supplier,
    String? key,
    List<int> labels = const [],
  });

  /// `PUT /api/v1/products/{product_id}` (FR-009, FR-010). All fields
  /// optional; only non-null values are sent (mirrors `UserRepository.
  /// update`'s convention). Used both for ordinary edits (FR-009) and for
  /// soft-delete (FR-010 — call with only `deactivated: true`). Throws
  /// `NotFoundError` on `404`, `ValidationError` on `422` (e.g. duplicate
  /// code on rename).
  ///
  /// **Known limitation ([supplier], research.md §5)**: this "only send
  /// non-null" convention means [supplier] cannot express "clear the
  /// supplier" — mbe-api's `update_product` does
  /// `if data.supplier is not None: product.supplier = data.supplier`, so a
  /// null value is read server-side as "leave unchanged", not "unset".
  /// Assigning/changing the supplier works; clearing it does not, until
  /// mbe-api adopts the same `model_fields_set`-based null-means-clear
  /// pattern it already uses for `photo`.
  Future<Product> update({
    required int productId,
    String? code,
    String? name,
    String? unitOfMeasurement,
    String? sku,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    String? taxRate,
    String? comment,
    bool? stockable,
    bool? perishable,
    bool? seriable,
    bool? purchasable,
    bool? salable,
    bool? invoiceable,
    bool? deactivated,
    int? supplier,
    String? key,
    List<int>? labels,
  });

  /// `POST /api/v1/products/{product_id}/image` (FR-003, FR-004). Issued as
  /// a raw multipart `dio` call rather than through the generated client —
  /// the generated method's `file` param is codegen'd as a plain string,
  /// not a binary-capable parameter (research.md §3, contracts/
  /// mbe-api-products-photo.md). Throws `NotFoundError` on `404`,
  /// `ValidationError` on `422` (unsupported image type or over the 2 MB
  /// limit).
  Future<Product> uploadPhoto({
    required int productId,
    required Uint8List bytes,
    required String filename,
  });

  /// `PUT /api/v1/products/{product_id}` with a raw `{"photo": null}` body
  /// (FR-005). Issued as a raw `dio` call rather than through the generated
  /// `ProductUpdate` model — that model's serializer never emits a field
  /// once it's `null`, so it cannot express "clear this field" (research.md
  /// §3, contracts/mbe-api-products-photo.md). Throws `NotFoundError` on
  /// `404`.
  Future<Product> removePhoto({required int productId});

  /// `POST /api/v1/products/merge` (specs/008-merge-products FR-008).
  /// Merges [duplicateId] into [productId]: mbe-api remaps the duplicate's
  /// transactional references (sales/purchase order details, inventory
  /// receipt/issue/transfer details, lot-serial tracking, …) and its labels
  /// onto the canonical product, deletes the duplicate's price and label
  /// rows, then permanently deletes the duplicate. Irreversible; there is
  /// no undo.
  ///
  /// Returns normally on `204 No Content`. Throws:
  /// - `ServerError(statusCode: 400, ...)` if [productId] == [duplicateId]
  ///   ("Cannot merge a product with itself") — a backstop; the UI blocks
  ///   this client-side (FR-006).
  /// - `NotFoundError` on `404` if the canonical or duplicate product no
  ///   longer exists (FR-011).
  /// - `ServerError` / `NetworkError` on other backend/transport failures
  ///   (FR-011) — surfaced with mbe-api's `detail` message where present.
  Future<void> mergeProducts({required int productId, required int duplicateId});
}

/// `ListResponse[ProductListItem]` (`items`, `total`) — used by
/// `ProductsListController` for pagination (research.md §5).
class ProductListResult {
  const ProductListResult({required this.items, required this.total});

  final List<ProductListItem> items;
  final int total;
}
