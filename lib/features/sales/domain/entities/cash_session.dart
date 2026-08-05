import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'cash_session.freezed.dart';

/// A cashier's shift on one cash drawer (data-model.md §1), mapped from
/// `CashSessionResponse`. Used for both list rows and detail — the backend
/// returns the same shape from all three read operations, so there is no
/// separate `CashSessionListItem`.
///
/// `cashDrawer`/`cashier`/`cashSupervisor` arrive already expanded
/// (`CashDrawerSummary`/`EmployeeResponse` — mbe-api#141, research.md §17),
/// so their names are flattened here with no resolution step of any kind,
/// the same way `CashDrawer.facilityName` is flattened from its own expanded
/// FK. A closed session's status is never returned by the API — deliberately
/// absent here; see `cash_session_status.dart`.
@freezed
class CashSession with _$CashSession {
  const factory CashSession({
    required int cashSessionId,
    required int cashDrawerId,
    required String cashDrawerName,
    required String cashDrawerCode,
    required int cashierId,
    required String cashierName,
    required DateTime start,
    DateTime? end,
    int? cashSupervisorId,
    String? cashSupervisorName,
    required String openingAmount,
    @Default(<PaymentMethodTotal>[]) List<PaymentMethodTotal> paymentsByMethod,
  }) = _CashSession;

  factory CashSession.fromResponse(CashSessionResponse r) => CashSession(
    cashSessionId: r.cashSessionId,
    cashDrawerId: r.cashDrawer.cashDrawerId,
    cashDrawerName: r.cashDrawer.name,
    cashDrawerCode: r.cashDrawer.code,
    cashierId: r.cashier.employeeId,
    cashierName: '${r.cashier.firstName} ${r.cashier.lastName}',
    start: r.start,
    end: r.end,
    cashSupervisorId: r.cashSupervisor?.employeeId,
    cashSupervisorName: r.cashSupervisor == null
        ? null
        : '${r.cashSupervisor!.firstName} ${r.cashSupervisor!.lastName}',
    openingAmount: r.openingAmount,
    paymentsByMethod: (r.paymentsByMethod ?? const <MethodTotal>[])
        .map(PaymentMethodTotal.fromResponse)
        .toList(),
  );
}

/// One payment method's total for a session (data-model.md §2). [method]
/// stays a raw code, not a [PaymentMethod] enum — [PaymentMethod.fromCode]
/// returns `null` for an unrecognized value, and the documented posture is to
/// render the raw code rather than crash; that mapping happens at the display
/// edge (`paymentMethodLabel`), not here.
///
/// Net of cash refunds paid out of the drawer — a method's [total] can be
/// lower than the gross received, and in principle negative. Never describe
/// this as "cash received."
@freezed
class PaymentMethodTotal with _$PaymentMethodTotal {
  const factory PaymentMethodTotal({required int method, required String total}) =
      _PaymentMethodTotal;

  factory PaymentMethodTotal.fromResponse(MethodTotal r) =>
      PaymentMethodTotal(method: r.method, total: r.total);
}
