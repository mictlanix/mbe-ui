//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_status.g.dart';

class ExportStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const ExportStatus pending = _$pending;
  @BuiltValueEnumConst(wireName: r'running')
  static const ExportStatus running = _$running;
  @BuiltValueEnumConst(wireName: r'ready')
  static const ExportStatus ready = _$ready;
  @BuiltValueEnumConst(wireName: r'failed')
  static const ExportStatus failed = _$failed;

  static Serializer<ExportStatus> get serializer => _$exportStatusSerializer;

  const ExportStatus._(String name) : super(name);

  static BuiltSet<ExportStatus> get values => _$values;
  static ExportStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ExportStatusMixin = Object with _$ExportStatusMixin;
