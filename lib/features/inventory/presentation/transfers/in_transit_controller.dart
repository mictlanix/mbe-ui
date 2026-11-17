import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';

part 'in_transit_controller.g.dart';

int? _userFacilityId(Ref ref) {
  final state = ref.watch(authProvider).value;
  return state is AuthAuthenticated ? state.user.settings?.facilityId : null;
}

/// The facility the in-transit view shows (spec 069 research R9). Starts on
/// the user's own, from the session settings; `null` means no facility.
@riverpod
class InTransitFacility extends _$InTransitFacility {
  @override
  int? build() => _userFacilityId(ref);

  /// Shows [facilityId]'s view (administrators only: the screen hides the
  /// picker otherwise).
  void select(int facilityId) => state = facilityId;

  /// Returns to the user's own facility ("Mi sucursal").
  void reset() => state = _userFacilityId(ref);
}

/// What is in transit toward a facility (spec 069 research R9): a single
/// load, keyed by the facility id. A failed load keeps the `AppError`.
@riverpod
class InTransitController extends _$InTransitController {
  @override
  Future<InTransitView> build(int facilityId) => ref
      .watch(inventoryTransferRepositoryProvider)
      .inTransit(facilityId: facilityId);

  /// Re-fetches the view, keeping the current one on screen meanwhile.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref
          .read(inventoryTransferRepositoryProvider)
          .inTransit(facilityId: facilityId),
    );
  }
}
