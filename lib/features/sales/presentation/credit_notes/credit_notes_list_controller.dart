import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/presentation/credit_notes/credit_notes_filter.dart';

part 'credit_notes_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Notas de crédito" page (spec 056 FR-010, FR-011,
/// research R8): server paging, newest first, in the caller's facility.
///
/// The "Solo utilizables" switch is mbe-api's `open_only`, which keeps the
/// notes a customer can spend from their balance — something left, not paid
/// back in cash, and not the walk-in customer's (mbe-api spec 034 FR-004) —
/// and counts only those.
///
/// A user without credit-payments read gets an empty page and no request; the
/// route and the navigation are what actually keep them out (FR-013).
@riverpod
class CreditNotesListController extends _$CreditNotesListController {
  @override
  Future<CatalogPage<CreditNote>> build(CreditNotesFilter filter) {
    final canRead = ref
        .watch(accessControlProvider)
        .can(SystemObject.creditPayments, AccessRight.read);
    if (!canRead) {
      return Future.value(
        const CatalogPage(
          items: [],
          total: 0,
          pageIndex: 0,
          pageSize: _pageSize,
        ),
      );
    }
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter, pageIndex),
    );
  }

  Future<CatalogPage<CreditNote>> _fetch(
    CreditNotesFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(creditNoteRepositoryProvider)
        .list(
          customerId: filter.customerId,
          openOnly: filter.openOnly,
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
