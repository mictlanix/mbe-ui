import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';

part 'cash_session_detail_controller.g.dart';

/// Fetches one session for the detail screen (User Story 2).
@riverpod
class CashSessionDetailController extends _$CashSessionDetailController {
  @override
  Future<CashSession> build(int cashSessionId) {
    return ref.watch(cashSessionRepositoryProvider).get(cashSessionId: cashSessionId);
  }
}
