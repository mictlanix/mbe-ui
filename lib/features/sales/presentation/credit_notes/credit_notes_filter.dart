import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';

part 'credit_notes_filter.freezed.dart';

/// The "Notas de crédito" list's addressable view state (spec 056 data-model
/// §7). Every field lives in the URL, so Back from a payment returns to the
/// same page and filters.
///
/// There is no search box: `GET /credit-notes` has no free-text parameter, so
/// the customer picker and the balance switch are the whole filter.
@freezed
abstract class CreditNotesFilter with _$CreditNotesFilter {
  const CreditNotesFilter._();

  const factory CreditNotesFilter({
    int? customerId,

    /// Only notes the server reports something remaining on (FR-011).
    @Default(false) bool openOnly,
    @Default(0) int pageIndex,
  }) = _CreditNotesFilter;

  factory CreditNotesFilter.fromQuery(ListQuery query) {
    final customer = query.facet('customer');
    return CreditNotesFilter(
      customerId: customer == null ? null : int.tryParse(customer),
      openOnly: query.facet('open') == '1',
      pageIndex: query.pageIndex,
    );
  }

  /// What the drawer badge counts: the customer, and the balance switch.
  int get activeFilterCount =>
      (customerId != null ? 1 : 0) + (openOnly ? 1 : 0);

  bool get isNarrowed => activeFilterCount > 0;
}
