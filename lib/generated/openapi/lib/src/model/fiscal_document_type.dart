//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_document_type.g.dart';

/// `fiscal_document.type`, `taxpayer_batch.type` — legacy's FiscalDocumentType.
class FiscalDocumentType extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 0)
  static const FiscalDocumentType number0 = _$number0;
  @BuiltValueEnumConst(wireNumber: 1)
  static const FiscalDocumentType number1 = _$number1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const FiscalDocumentType number2 = _$number2;
  @BuiltValueEnumConst(wireNumber: 3)
  static const FiscalDocumentType number3 = _$number3;
  @BuiltValueEnumConst(wireNumber: 100)
  static const FiscalDocumentType number100 = _$number100;
  @BuiltValueEnumConst(wireNumber: 101)
  static const FiscalDocumentType number101 = _$number101;
  @BuiltValueEnumConst(wireNumber: 200)
  static const FiscalDocumentType number200 = _$number200;

  static Serializer<FiscalDocumentType> get serializer =>
      _$fiscalDocumentTypeSerializer;

  const FiscalDocumentType._(String name) : super(name);

  static BuiltSet<FiscalDocumentType> get values => _$values;
  static FiscalDocumentType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FiscalDocumentTypeMixin = Object with _$FiscalDocumentTypeMixin;
