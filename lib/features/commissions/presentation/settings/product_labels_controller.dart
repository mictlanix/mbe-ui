import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

part 'product_labels_controller.g.dart';

/// Rows per server page of the product labels list (research R10).
const commissionProductLabelsPageSize = 20;

/// One page of product labels with the filters and the page index that made it.
class ProductLabelsView {
  const ProductLabelsView({
    required this.labelId,
    required this.productId,
    required this.pageIndex,
    required this.page,
  });

  final int? labelId;
  final int? productId;
  final int pageIndex;
  final CommissionProductLabelPage page;
}

/// The product labels list (spec 078 FR-016): the Etiqueta and Producto
/// filters and a server-side page of [commissionProductLabelsPageSize]. The
/// endpoint has no text search, only the `commission` and `product` ids
/// (research R10). [set] and [remove] write and then re-read the page.
@riverpod
class ProductLabelsController extends _$ProductLabelsController {
  int? _labelId;
  int? _productId;
  int _pageIndex = 0;

  /// The filters now in force, also while a page is loading.
  int? get labelId => _labelId;
  int? get productId => _productId;

  @override
  Future<ProductLabelsView> build() => _load();

  Future<ProductLabelsView> _load() async {
    final labelId = _labelId;
    final productId = _productId;
    var pageIndex = _pageIndex;
    var page = await _read(labelId, productId, pageIndex);
    // The page is gone (the last row of it was removed): the new last page.
    if (page.items.isEmpty && page.total > 0 && pageIndex > 0) {
      pageIndex = (page.total - 1) ~/ commissionProductLabelsPageSize;
      _pageIndex = pageIndex;
      page = await _read(labelId, productId, pageIndex);
    }
    return ProductLabelsView(
      labelId: labelId,
      productId: productId,
      pageIndex: pageIndex,
      page: page,
    );
  }

  Future<CommissionProductLabelPage> _read(
    int? labelId,
    int? productId,
    int pageIndex,
  ) => ref
      .read(commissionRepositoryProvider)
      .listProductLabels(
        labelId: labelId,
        productId: productId,
        skip: pageIndex * commissionProductLabelsPageSize,
        limit: commissionProductLabelsPageSize,
      );

  Future<void> _reload() async {
    state = const AsyncLoading<ProductLabelsView>();
    state = await AsyncValue.guard(_load);
  }

  /// Filters by label (`null` clears); back to the first page.
  Future<void> setLabel(int? labelId) {
    _labelId = labelId;
    _pageIndex = 0;
    return _reload();
  }

  /// Filters by product (`null` clears); back to the first page.
  Future<void> setProduct(int? productId) {
    _productId = productId;
    _pageIndex = 0;
    return _reload();
  }

  /// Both filters off.
  Future<void> clearFilters() {
    _labelId = null;
    _productId = null;
    _pageIndex = 0;
    return _reload();
  }

  Future<void> setPage(int pageIndex) {
    _pageIndex = pageIndex;
    return _reload();
  }

  /// `PUT /product-labels/{product}`: gives the product the label, or changes
  /// it. The refusal, or `null` when it went through.
  Future<AppError?> set(int productId, int labelId) => _write(
    () => ref
        .read(commissionRepositoryProvider)
        .setProductLabel(productId, labelId),
  );

  /// `DELETE /product-labels/{product}`.
  Future<AppError?> remove(int productId) => _write(
    () => ref.read(commissionRepositoryProvider).removeProductLabel(productId),
  );

  Future<AppError?> _write(Future<Object?> Function() write) async {
    AppError? refusal;
    try {
      await write();
    } on AppError catch (error) {
      refusal = error;
    }
    await _reload();
    return refusal;
  }
}
