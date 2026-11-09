//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_source.g.dart';

class ExportSource extends EnumClass {
  @BuiltValueEnumConst(wireName: r'query')
  static const ExportSource query = _$query;
  @BuiltValueEnumConst(wireName: r'dashboard')
  static const ExportSource dashboard = _$dashboard;
  @BuiltValueEnumConst(wireName: r'detail')
  static const ExportSource detail = _$detail;

  static Serializer<ExportSource> get serializer => _$exportSourceSerializer;

  const ExportSource._(String name) : super(name);

  static BuiltSet<ExportSource> get values => _$values;
  static ExportSource valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ExportSourceMixin = Object with _$ExportSourceMixin;
