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

/// The widest page `GET /credit-notes` allows.
const _readPage = 100;

/// Fetches and holds the "Notas de crédito" page (spec 056 FR-010, FR-011,
/// research R8).
///
/// Without the balance switch this is plain server paging, newest first.
/// With it, every matching note is read and filtered here on
/// [CreditNote.isOpen], then paged locally — never through the server's
/// `open_only`, which filters *after* paging (mbe-api#278): its first page can
/// come back empty while open notes exist further down, and its `total` counts
/// every note. The count this screen shows is the filtered set's own.
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
    if (filter.openOnly) return _openOnly(filter);
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

  Future<CatalogPage<CreditNote>> _openOnly(CreditNotesFilter filter) async {
    final repository = ref.read(creditNoteRepositoryProvider);
    final customerId = filter.customerId;
    // simplified: reads every page while mbe-api#278 is open (984 notes, about
    // 10 requests on the dev tenant); pass open_only and page on the server
    // once it ships.
    final all = customerId != null
        ? await repository.listForCustomer(customerId)
        : await _readEveryNote();
    final open = [
      for (final note in all)
        if (note.isOpen) note,
    ]..sort(_newestFirst);

    final lastPage = open.isEmpty ? 0 : (open.length - 1) ~/ _pageSize;
    final pageIndex = filter.pageIndex.clamp(0, lastPage);
    final start = pageIndex * _pageSize;
    final end = (start + _pageSize).clamp(0, open.length);
    return CatalogPage(
      items: open.sublist(start, end),
      total: open.length,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
  }

  /// Every note, page by page, until the server's `total` is reached.
  Future<List<CreditNote>> _readEveryNote() async {
    final repository = ref.read(creditNoteRepositoryProvider);
    final notes = <CreditNote>[];
    var skip = 0;
    while (true) {
      final page = await repository.list(skip: skip, limit: _readPage);
      notes.addAll(page.items);
      skip += page.items.length;
      // A short page ends the loop as well as the count, so a server that
      // reports `total` differently cannot spin it forever.
      if (page.items.isEmpty || skip >= page.total) return notes;
    }
  }
}

int _newestFirst(CreditNote a, CreditNote b) {
  final da = a.date;
  final db = b.date;
  final byDate = da == null || db == null
      ? (da == null ? (db == null ? 0 : 1) : -1)
      : db.compareTo(da);
  return byDate != 0 ? byDate : b.id.compareTo(a.id);
}
