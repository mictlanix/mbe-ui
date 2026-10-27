import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/orders/foreign_order_guard.dart';

/// A cash session's one-line label, `#id · cashier · date` — what the Pagos
/// filter picker lists and what its selected value shows (spec 054 FR-006a).
String cashSessionLabel(CashSession session, AppFormatters fmt) =>
    '#${session.cashSessionId} · ${session.cashierName} · '
    '${fmt.display.date(session.start)}';

/// [cashSessionLabel] for a session known only by id — the picker's selected
/// value on a cold load (a shared link carrying only `cash-session=<id>`).
/// `null` on any failure, so the caller falls back to the bare number.
final cashSessionLabelProvider = FutureProvider.family<String?, int>((
  ref,
  cashSessionId,
) async {
  try {
    final session = await ref
        .watch(cashSessionRepositoryProvider)
        .get(cashSessionId: cashSessionId);
    return cashSessionLabel(session, ref.watch(formattersProvider));
  } catch (_) {
    return null;
  }
});

/// The options the Pagos "Sesión de caja" filter offers for [query] (spec 054
/// R7). `GET /cash-sessions` has no search parameter, so:
/// - an all-digits [query] looks that session up by id, and offers it only if
///   it belongs to [facilityId] — the server would hand back any facility's
///   session, so this is the only thing keeping the picker inside the user's
///   own facility. A miss, an error or a foreign session offers nothing.
/// - anything else lists the facility's most recent sessions, so an empty
///   box still shows something to pick.
Future<List<CashSession>> cashSessionPickerOptions(
  CashSessionRepository repository, {
  required int? facilityId,
  required String query,
}) async {
  if (facilityId == null) return const [];
  final trimmed = query.trim();
  try {
    final id = RegExp(r'^\d+$').hasMatch(trimmed) ? int.parse(trimmed) : null;
    if (id != null) {
      final session = await repository.get(cashSessionId: id);
      return session.cashDrawerFacilityId == facilityId ? [session] : const [];
    }
    final page = await repository.list(facilityId: facilityId, limit: 20);
    return page.items;
  } catch (_) {
    return const [];
  }
}

/// Where an application's order opens, or `null` when it should show as plain
/// text (spec 054 FR-015, research R8).
///
/// An application carries only the order's id, and `/sales/orders/:id` shows a
/// dead-end notice for a register sale, so the order is fetched to learn its
/// origin and [isForeignOrder] decides: a register sale opens in the register
/// (`/sales/pos/:id`), anything else in Pedidos. Each destination is offered
/// only to a user who can read it. Fetching the order needs Sales Orders read,
/// so without it the answer is `null` without a request, and so it is for any
/// fetch error.
///
/// An order with no recorded origin (every order before mbe-api#209) goes
/// through [isForeignOrder]'s own fallback, which reads a paid order as a
/// register sale — the same call the order workspace makes when opened.
final orderLinkTargetProvider = FutureProvider.family<String?, int>((
  ref,
  saleId,
) async {
  final access = ref.watch(accessControlProvider);
  if (!access.can(SystemObject.salesOrders, AccessRight.read)) return null;
  try {
    final sale = await ref
        .watch(salesOrderRepositoryProvider)
        .getById(saleId: saleId);
    final foreign = isForeignOrder(
      sale,
      settings: ref.watch(appSettingsProvider),
    );
    if (!foreign) return '/sales/orders/$saleId';
    return access.can(SystemObject.pos, AccessRight.read)
        ? '/sales/pos/$saleId'
        : null;
  } catch (_) {
    return null;
  }
});
