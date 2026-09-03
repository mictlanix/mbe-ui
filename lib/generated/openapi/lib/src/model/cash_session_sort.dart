//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cash_session_sort.g.dart';

/// Ordering for the session list; a `-` prefix reads descending.  `ID_DESC` is the default because it is the ordering the list has always had.
class CashSessionSort extends EnumClass {
  @BuiltValueEnumConst(wireName: r'-id')
  static const CashSessionSort id = _$id;
  @BuiltValueEnumConst(wireName: r'start')
  static const CashSessionSort start = _$start;
  @BuiltValueEnumConst(wireName: r'-start')
  static const CashSessionSort start2 = _$start2;

  static Serializer<CashSessionSort> get serializer =>
      _$cashSessionSortSerializer;

  const CashSessionSort._(String name) : super(name);

  static BuiltSet<CashSessionSort> get values => _$values;
  static CashSessionSort valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CashSessionSortMixin = Object with _$CashSessionSortMixin;
