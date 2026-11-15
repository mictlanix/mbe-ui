import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart'
    show encodePaymentsDateFacet, parsePaymentsDateFacet;

part 'payment_verification_filter.freezed.dart';

/// The queue's opening method: a bank transfer (`PaymentMethod.eft`), the
/// legacy `PaymentMethodsVerificationRequired` setting (spec 060 R3).
///
/// A literal because a freezed `@Default` needs a constant and an enum's
/// field isn't one; a test pins it to `PaymentMethod.eft.code`.
const int verificationDefaultMethodCode = 3;

/// Which payment method the verification queue lists (spec 060 R3).
///
/// Its own type, not an `int?`, so "no method filter" and "the default" can't
/// be confused: `null` would have to mean both.
@freezed
sealed class VerificationMethodFilter with _$VerificationMethodFilter {
  /// Every method — chosen on purpose, from the method filter.
  const factory VerificationMethodFilter.all() = VerificationMethodAll;

  /// One method, by its mbe-api code.
  const factory VerificationMethodFilter.code(int code) =
      VerificationMethodCode;
}

/// The queue's addressable view state (spec 060 data-model §2). Every field
/// lives in the URL, so reload and Back keep the same page and filters.
///
/// **There is no facility scoping here.** The queue is company-wide on
/// purpose: verification is, on the server and in the legacy screen. The
/// facility is only an optional narrowing.
@freezed
abstract class PaymentVerificationFilter with _$PaymentVerificationFilter {
  const PaymentVerificationFilter._();

  const factory PaymentVerificationFilter({
    /// `null` is every facility.
    int? facilityId,

    /// Both ends or neither: a half-open range is dropped by [fromQuery].
    DateTime? dateFrom,
    DateTime? dateTo,
    @Default(VerificationMethodFilter.code(verificationDefaultMethodCode))
    VerificationMethodFilter method,

    /// Tri-state (mbe-api#310): `null` lists both, `true` only payments
    /// rejected at least once, `false` only those never rejected.
    bool? rejected,
    @Default(0) int pageIndex,
  }) = _PaymentVerificationFilter;

  /// Reads the address. An absent `method` is Transfer, `all` is no method
  /// filter, and a code is that method; anything else (a hand-edited address,
  /// or a code the app has no method for) reads as Transfer, so the method
  /// dropdown always has an item to show.
  factory PaymentVerificationFilter.fromQuery(ListQuery query) {
    var from = parsePaymentsDateFacet(query.facet('date-from'));
    var to = parsePaymentsDateFacet(query.facet('date-to'));
    // As in Pagos: a half-open or reversed range can't be drawn by the date
    // chip, so only a hand-edited address gets here, and dropping both is the
    // one reading that can't show an empty list for a filter nobody can see.
    if (from == null || to == null || to.isBefore(from)) {
      from = null;
      to = null;
    }
    final facility = query.facet('facility');
    return PaymentVerificationFilter(
      facilityId: facility == null ? null : int.tryParse(facility),
      dateFrom: from,
      dateTo: to,
      method: _methodFromFacet(query.facet('method')),
      rejected: switch (query.facet('rejected')) {
        'true' => true,
        'false' => false,
        _ => null,
      },
      pageIndex: query.pageIndex,
    );
  }

  /// The address that reads back as this filter. The default method is left
  /// out of it, so the bare path is the opening state.
  ListQuery toQuery() => const ListQuery()
      .withFacet('facility', facilityId?.toString())
      .withFacet(
        'date-from',
        dateFrom == null ? null : encodePaymentsDateFacet(dateFrom!),
      )
      .withFacet(
        'date-to',
        dateTo == null ? null : encodePaymentsDateFacet(dateTo!),
      )
      .withFacet('method', methodFacetValue(method))
      .withFacet('rejected', rejected?.toString())
      .copyWith(pageIndex: pageIndex);

  /// The method code to send, or `null` for every method.
  int? get methodCode => switch (method) {
    VerificationMethodAll() => null,
    VerificationMethodCode(:final code) => code,
  };

  /// How many facets the drawer badge counts: the facility, the date range
  /// (one facet), the rejected facet, and the method whenever it isn't
  /// "every method" — so the badge reads 1 on the opening view, where
  /// Transfer is already narrowing.
  int get activeFilterCount =>
      (facilityId != null ? 1 : 0) +
      (dateFrom != null ? 1 : 0) +
      (rejected != null ? 1 : 0) +
      (method is! VerificationMethodAll ? 1 : 0);

  /// Whether the view differs from how the queue opens (Transfer, every
  /// facility, any date) — what decides whether the empty state offers to
  /// clear the filters, and what "clear" returns to.
  bool get differsFromDefault =>
      facilityId != null ||
      dateFrom != null ||
      rejected != null ||
      method !=
          const VerificationMethodFilter.code(verificationDefaultMethodCode);
}

/// The `method` facet's value for [method]: `null` for the default (so it
/// stays out of the address), `all`, or the code.
String? methodFacetValue(VerificationMethodFilter method) => switch (method) {
  VerificationMethodAll() => 'all',
  VerificationMethodCode(:final code) =>
    code == verificationDefaultMethodCode ? null : '$code',
};

VerificationMethodFilter _methodFromFacet(String? value) {
  const fallback = VerificationMethodFilter.code(verificationDefaultMethodCode);
  if (value == null) return fallback;
  if (value == 'all') return const VerificationMethodFilter.all();
  final code = int.tryParse(value);
  if (code == null || PaymentMethod.fromCode(code) == null) return fallback;
  return VerificationMethodFilter.code(code);
}
