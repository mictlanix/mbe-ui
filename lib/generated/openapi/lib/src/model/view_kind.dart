//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'view_kind.g.dart';

class ViewKind extends EnumClass {
  @BuiltValueEnumConst(wireName: r'query')
  static const ViewKind query = _$query;
  @BuiltValueEnumConst(wireName: r'dashboard')
  static const ViewKind dashboard = _$dashboard;
  @BuiltValueEnumConst(wireName: r'detail')
  static const ViewKind detail = _$detail;
  @BuiltValueEnumConst(wireName: r'customer')
  static const ViewKind customer = _$customer;

  static Serializer<ViewKind> get serializer => _$viewKindSerializer;

  const ViewKind._(String name) : super(name);

  static BuiltSet<ViewKind> get values => _$values;
  static ViewKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ViewKindMixin = Object with _$ViewKindMixin;
