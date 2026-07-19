import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';

part 'taxpayer_recipients_list_controller.g.dart';

const _pageSize = 20;

/// Holds the current search text for the Taxpayer Recipients catalog screen
/// (FR-001, FR-002).
@riverpod
class TaxpayerRecipientSearchController
    extends _$TaxpayerRecipientSearchController {
  @override
  String build() => '';

  void searchChanged(String value) => state = value;
}

/// Fetches and holds the Taxpayer Recipients list (FR-001), re-fetching
/// page 0 whenever the search text changes.
@riverpod
class TaxpayerRecipientsListController
    extends _$TaxpayerRecipientsListController {
  @override
  Future<CatalogPage<TaxpayerRecipientListItem>> build() {
    final search = ref.watch(taxpayerRecipientSearchControllerProvider);
    return _fetch(search, pageIndex: 0);
  }

  Future<CatalogPage<TaxpayerRecipientListItem>> _fetch(
    String search, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(taxpayerRecipientRepositoryProvider)
        .list(
          search: search.isEmpty ? null : search,
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

  /// Fetches [pageIndex] and replaces the current page with it.
  Future<void> goToPage(int pageIndex) async {
    final search = ref.read(taxpayerRecipientSearchControllerProvider);
    state =
        const AsyncLoading<
          CatalogPage<TaxpayerRecipientListItem>
        >().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(search, pageIndex: pageIndex));
  }
}
