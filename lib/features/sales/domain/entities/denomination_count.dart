import 'package:freezed_annotation/freezed_annotation.dart';

part 'denomination_count.freezed.dart';

/// One row of a closing count: a currency denomination and how many of it
/// were counted (data-model.md §6). Submitted at close and never read back —
/// no operation returns it (spec FR-033, D-004).
///
/// Only rows with `quantity > 0` are ever submitted (FR-020); [denomination]
/// is always one of [kMxnDenominations]'s values.
@freezed
class DenominationCount with _$DenominationCount {
  const factory DenominationCount({required String denomination, required int quantity}) =
      _DenominationCount;
}
