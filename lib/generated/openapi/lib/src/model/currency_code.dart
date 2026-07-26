//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'currency_code.g.dart';

class CurrencyCode extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 0)
  static const CurrencyCode number0 = _$number0;
  @BuiltValueEnumConst(wireNumber: 1)
  static const CurrencyCode number1 = _$number1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const CurrencyCode number2 = _$number2;

  static Serializer<CurrencyCode> get serializer => _$currencyCodeSerializer;

  const CurrencyCode._(String name) : super(name);

  static BuiltSet<CurrencyCode> get values => _$values;
  static CurrencyCode valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CurrencyCodeMixin = Object with _$CurrencyCodeMixin;
