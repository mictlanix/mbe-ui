import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';

part 'register_controller.g.dart';

/// The register this cashier is signed in to — `user_settings.point_sale`,
/// surfaced on `GET /auth/me` as `UserResponse.settings`.
///
/// This is the one piece of register context available **before any sale
/// exists**, which is what lets the screen list the register's open sales and
/// resolve its default warehouse on a POS nobody has touched yet. Everything
/// else about the register (its walk-in customer, above all) is only revealed
/// by `POST /sales-orders`, so a sale still has to be opened before the
/// customer area can say anything.
///
/// `null` for an account with no default POS configured; the screen then
/// falls back to whatever the sale in hand reports.
@riverpod
int? registerPointSale(Ref ref) {
  final state = ref.watch(authNotifierProvider).valueOrNull;
  return state is AuthAuthenticated ? state.user.settings?.pointSaleId : null;
}

/// `user_settings.facility` — the signed-in user's own facility (spec 029
/// FR-006). `null` for an account with none configured, which the Sales
/// Orders list treats as its own blocked state: there is nothing to scope a
/// listing to, so no request is issued at all (distinct from
/// [registerPointSale]'s `null`, which only blocks *creating* an order).
@riverpod
int? userFacilityId(Ref ref) {
  final state = ref.watch(authNotifierProvider).valueOrNull;
  return state is AuthAuthenticated ? state.user.settings?.facilityId : null;
}
