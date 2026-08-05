import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';

part 'facility_payment_options_controller.g.dart';

/// The tenders [PaymentMethodGrid] offers — the sale's facility's own active
/// payment method options, each carrying its `requiresReference` flag
/// straight from the server (research.md §6, resolved: no client-side
/// reference table exists).
@riverpod
Future<List<PaymentMethodOption>> facilityPaymentOptionsController(
  Ref ref,
  int facilityId,
) async {
  final result = await ref
      .watch(paymentMethodOptionRepositoryProvider)
      .list(facilityId: facilityId, status: EntityStatus.active, limit: 100);
  return result.items;
}
