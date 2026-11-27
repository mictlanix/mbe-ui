import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

part 'approval_queue_controller.freezed.dart';
part 'approval_queue_controller.g.dart';

const _pageSize = 20;

/// The approval queue's addressable view state (spec 079 data-model
/// "ApprovalQueueFilter"). URL keys: `facility`, `page`. The endpoint has no
/// search, so there is no search box.
@freezed
abstract class ApprovalQueueFilter with _$ApprovalQueueFilter {
  const ApprovalQueueFilter._();

  const factory ApprovalQueueFilter({
    int? facilityId,
    @Default(0) int pageIndex,
  }) = _ApprovalQueueFilter;

  /// A non-numeric `facility` is ignored.
  factory ApprovalQueueFilter.fromQuery(ListQuery query) => ApprovalQueueFilter(
    facilityId: int.tryParse(query.facet('facility') ?? ''),
    pageIndex: query.pageIndex,
  );

  /// What the drawer badge counts: the facility, when chosen.
  int get activeFilterCount => facilityId != null ? 1 : 0;
}

/// Fetches and holds a page of "Aprobación de solicitudes" (spec 079 FR-019,
/// research R10): every facility's submitted requests, oldest first as the
/// server orders them, optionally narrowed to one facility.
///
/// A page left empty by an approval on its last row steps back to the last
/// page that has rows ([fetchClampedPage]).
@riverpod
class ApprovalQueueController extends _$ApprovalQueueController {
  @override
  Future<PurchaseRequestPage> build(ApprovalQueueFilter filter) =>
      fetchClampedPage(
        pageIndex: filter.pageIndex,
        pageSize: _pageSize,
        fetch: (pageIndex) => _fetch(filter, pageIndex),
      );

  Future<PurchaseRequestPage> _fetch(
    ApprovalQueueFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(purchaseRequestRepositoryProvider)
        .approvalQueue(
          facilityId: filter.facilityId,
          skip: pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
  }
}
