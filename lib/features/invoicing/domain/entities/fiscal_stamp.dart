import 'package:freezed_annotation/freezed_annotation.dart';

part 'fiscal_stamp.freezed.dart';

/// The PAC's fiscal stamp on a document (spec 072 data-model). Legacy-stamped
/// documents carry one too; [simulated] is true only when the simulated PAC
/// stamped it, which can never happen in production.
@freezed
abstract class FiscalStamp with _$FiscalStamp {
  const factory FiscalStamp({
    required String uuid,
    DateTime? stamped,
    String? satCertificate,
    String? providerRfc,
    @Default(false) bool simulated,
  }) = _FiscalStamp;
}
