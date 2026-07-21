//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_certification_provider.g.dart';

class FiscalCertificationProvider extends EnumClass {
  /// PAC (Proveedor Autorizado de Certificación) integration used for CFDI stamping.
  @BuiltValueEnumConst(wireNumber: 0)
  static const FiscalCertificationProvider number0 = _$number0;

  /// PAC (Proveedor Autorizado de Certificación) integration used for CFDI stamping.
  @BuiltValueEnumConst(wireNumber: 1)
  static const FiscalCertificationProvider number1 = _$number1;

  /// PAC (Proveedor Autorizado de Certificación) integration used for CFDI stamping.
  @BuiltValueEnumConst(wireNumber: 2)
  static const FiscalCertificationProvider number2 = _$number2;

  /// PAC (Proveedor Autorizado de Certificación) integration used for CFDI stamping.
  @BuiltValueEnumConst(wireNumber: 3)
  static const FiscalCertificationProvider number3 = _$number3;

  /// PAC (Proveedor Autorizado de Certificación) integration used for CFDI stamping.
  @BuiltValueEnumConst(wireNumber: 4)
  static const FiscalCertificationProvider number4 = _$number4;

  static Serializer<FiscalCertificationProvider> get serializer =>
      _$fiscalCertificationProviderSerializer;

  const FiscalCertificationProvider._(String name) : super(name);

  static BuiltSet<FiscalCertificationProvider> get values => _$values;
  static FiscalCertificationProvider valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FiscalCertificationProviderMixin = Object
    with _$FiscalCertificationProviderMixin;
